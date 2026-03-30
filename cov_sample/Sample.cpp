//  SPDX-FileCopyrightText: © 2026 Tenstorrent AI ULC
//  SPDX-License-Identifier: Apache-2.0
#include <cstring>
#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <sys/socket.h>
#include <netinet/tcp.h>
#include <arpa/inet.h>
#include <unistd.h>
#include "Sample.hpp"
#include "Trace.hpp"
#include "InstEntry.hpp"
#include "Points.hpp"
#include "instforms.hpp"
#include "magic_enum.hpp"

using namespace ArchCov;
using namespace WdRiscv;

extern "C" void trace(arch_t& table);

template <typename URV>
static void
sampleInst(TraceRecord<URV>* tr, arch_t& table)
{
  static const InstTable insts;
  auto entry = insts.getEntry(tr->instId());

  for (unsigned i = 0; i < 4; ++i)
  {
    if (entry.ithOperandMask(i) == 0)
      continue;

    if (tr->ithOperandMode(i) != OperandMode::None and tr->ithOperandType(i) != OperandType::Imm)
    {
      auto op = tr->ithOperand(i);
      if ((tr->ithOperandType(i) == OperandType::IntReg or tr->ithOperandType(i) == OperandType::FpReg) and std::bitset<32>(entry.ithOperandMask(i)).count() != 5)
        op -= 8;
      table.addEntry(Point(uint32_t(Point::Op0) + i), op);
    }

    URV value;
    unsigned op = tr->ithOperand(i);
    if (tr->ithOperandType(i) == OperandType::IntReg)
    {
      if (tr->peekIntReg(op, value))
        table.addEntry(Point(uint32_t(Point::Op0Val) + i), value);
    }
    else if (tr->ithOperandType(i) == OperandType::FpReg)
    {
      uint64_t fpVal;
      if (tr->peekFpReg(op, fpVal))
        table.addEntry(Point(uint32_t(Point::Op0Val) + i), fpVal);
    }
    else if (tr->ithOperandType(i) == OperandType::CsReg)
    {
      if (tr->peekCsReg(CsrNumber(op), value))
        table.addEntry(Point(uint32_t(Point::Op0Val) + i), value);
    }
    else if (tr->ithOperandType(i) == OperandType::Imm)
      table.addEntry(Point(uint32_t(Point::Op0Val) + i), int64_t(static_cast<int32_t>(tr->ithOperand(i)>>(tr->immediateShiftSize()))));
  }

  table.addEntry(Point::InstId, uint64_t(tr->instId()));
  table.addEntry(Point::Inst, tr->instruction());
  if (entry.hasRoundingMode())
    table.addEntry(Point::Rm, tr->roundingMode());
  if (entry.isBranch())
  {
    auto [_, taken] = tr->lastBranchTaken();
    table.addEntry(Point::BrTaken, taken);
  }
}

template <typename URV>
static void
sampleCsr(TraceRecord<URV>* tr, arch_t& table, std::vector<std::pair<URV, URV>>& csrs)
{
  std::vector<CsrNumber> shadowCsrs;

  for (const auto& pair : csrs)
  {
    table.addEntry(Point::CsrNum, pair.first & 0xfff);
    table.addEntry(Point::CsrValue, pair.second);

    switch (pair.first)         
    {
      case URV(CsrNumber::MIP):
        shadowCsrs.emplace_back(CsrNumber::SIP); break;
      case URV(CsrNumber::MIE):
        shadowCsrs.emplace_back(CsrNumber::SIE); break;
      default: break;
    }
  }

  for (auto csrNumber : shadowCsrs)
  {
    std::pair<URV, URV> sCsr;
    URV value;
    sCsr.first = URV(csrNumber);

    auto it = std::find_if(csrs.begin(), csrs.end(), [&sCsr](const std::pair<URV, URV> &csr) {
        return sCsr.first == csr.first;
    });

    if (it == csrs.end())
    {
      if (not tr->peekCsReg(csrNumber, value))
        continue;
      table.addEntry(Point::CsrNum,   URV(csrNumber));
      table.addEntry(Point::CsrValue, value);
    }
  }
}

template <typename URV>
static void
samplePmpData(TraceRecord<URV>* tr, arch_t& table,
              VirtMem::Mode pagingMode, uint64_t physLdStAddr,
              uint64_t ldStSize, uint64_t physPc, unsigned instSize)
{
  bool fPmp = false, fPmpCrossing = false, fPmpPtw = false, fMultihit = false;
  bool dPmp = false, dPmpCrossing = false, dPmpPtw = false, dMultihit = false;
  uint64_t dIndex = 0, fIndex = 0;
  std::vector<std::pair<uint64_t, uint64_t>> fpmps, dpmps;
  std::vector<PmpManager::PmpTrace> pmps; tr->getPmpsAccessed(pmps); std::reverse(pmps.begin(), pmps.end());

  for (auto& entry : pmps)
  {
    URV pmpCfgVal;
    tr->peekCsReg(CsrNumber(0x3A0), pmpCfgVal);
    pmpCfgVal = (pmpCfgVal >> (entry.ix_ * 8)) & 0xff;

    if (entry.reason_ == PmpManager::AccessReason::Fetch)
    {
      if ( entry.addr_ >= (physPc & ~(uint64_t(3))) &&
          (entry.addr_ < (physPc+instSize)))
      {
        if (!fPmp)
        {
          fPmp = true;
          fIndex = entry.ix_;
          fpmps.emplace_back(pmpCfgVal, entry.ix_);
          if (!fMultihit && tr->matchMultiplePmp(entry.addr_))
            fMultihit = true;
        }
        else if (!fPmpCrossing)
        {
          if (fIndex != entry.ix_)
          {
            fPmpCrossing = true;
            fpmps.emplace_back(pmpCfgVal, entry.ix_);
            if (!fMultihit && tr->matchMultiplePmp(entry.addr_))
              fMultihit = true;
          }
        }
      }
      else if (!fPmpPtw)
      {
        if (pagingMode != VirtMem::Mode::Bare)
        {
          fPmpPtw = true;
          table.addEntry(Point::FPmpPtw, pmpCfgVal);
        }
      }
    }
    else if (entry.reason_ == PmpManager::AccessReason::LdSt)
    {
      if ( entry.addr_ >= (physLdStAddr & ~(uint64_t(3))) &&
          (entry.addr_ < (physLdStAddr+ldStSize)))
      {
        if (!dPmp)
        {
          dPmp = true;
          dIndex = entry.ix_;
          dpmps.emplace_back(pmpCfgVal, entry.ix_);
          if (!dMultihit && tr->matchMultiplePmp(entry.addr_))
            dMultihit = true;
        }
        else if ((!dPmpCrossing))
        {
          if (dIndex != entry.ix_)
          {
            dPmpCrossing = true;
            dpmps.emplace_back(pmpCfgVal, entry.ix_);
            if (!dMultihit && tr->matchMultiplePmp(entry.addr_))
              dMultihit = true;
          }
        }
      }
      else if (!dPmpPtw)
      {
        dPmpPtw = true;
        table.addEntry(Point::DPmpPtw, pmpCfgVal);
      }
    }
  }
  switch (fpmps.size()) {
    case 2:  table.addEntry(Point::FPmpCrossing,      fpmps[0].first);
             table.addEntry(Point::FPmpCrossingIndex, fpmps[0].second);
    case 1:  table.addEntry(Point::FPmp,      fpmps.back().first);
             table.addEntry(Point::FPmpIndex, fpmps.back().second);
    default: table.addEntry(Point::FPmpMultihit, int(fMultihit));
  }
  switch (dpmps.size()) {
    case 2:  table.addEntry(Point::DPmpCrossing,      dpmps[0].first);
             table.addEntry(Point::DPmpCrossingIndex, dpmps[0].second);
    case 1:  table.addEntry(Point::DPmp,      dpmps.back().first);
             table.addEntry(Point::DPmpIndex, dpmps.back().second);
    default: table.addEntry(Point::DPmpMultihit, int(dMultihit));
  }
}

template <typename URV>
static void
samplePagingData(TraceRecord<URV>*,   
                arch_t& table,
                bool instr,
                const VirtMem::Walk& walk,
                unsigned numPageTableWalks)
{
  if (not walk.complete())
    return;

  unsigned p = (instr)? unsigned(Point::FPTELeaf) : unsigned(Point::DPTELeaf);
  table.addEntry(Point(p), walk.pteValues().back());

  int pageSize = walk.maxLevels() - walk.size();  
  if (pageSize >= 0) {
    table.addEntry(instr? Point::FPageSize : Point::DPageSize, pageSize);
    if (numPageTableWalks > 1) {
      table.addEntry(instr? Point::FPageCrossSize : Point::DPageCrossSize, pageSize);
      table.addEntry(instr? Point::FPageCross     : Point::DPageCross,     true);
    }
  }

  if (walk.size() > 1) {   
    auto pte_val = walk.ithPte(walk.size() - 2);  
    unsigned p = (instr)? unsigned(Point::FPTENonLeaf): unsigned(Point::DPTENonLeaf);
    table.addEntry(Point(p), pte_val);
  }

  auto adUpdated = (unsigned(walk.aUpdated()) << 1) | unsigned(walk.dUpdated());
  if (adUpdated)
    table.addEntry(instr?Point::FPTELeafADUpdate : Point::DPTELeafADUpdate, adUpdated);
}


template <typename URV>
static void
samplePageTables(TraceRecord<URV>* tr, arch_t& table, VirtMem::Mode, bool isInstr)
{
  const auto& walks = isInstr? tr->getFetchPageTableWalks() : tr->getDataPageTableWalks();
  unsigned numPageTableWalks = walks.size();

  for (const auto& walk: walks)
    samplePagingData(tr, table, isInstr, walk, numPageTableWalks);
}

template <typename URV>
static void
samplePmaData(TraceRecord<URV>* tr, arch_t& table,
              VirtMem::Mode pagingMode, uint64_t physLdStAddr,
              uint64_t ldStSize, uint64_t physPc, unsigned instSize)
{
  bool fPma = false, fPmaCrossing = false, fPmaPtw = false, fMultihit = false;
  bool dPma = false, dPmaCrossing = false, dPmaPtw = false, dMultihit = false;
  uint64_t dPmaCfgVal = 0, fPmaCfgVal = 0;
  std::vector<uint64_t> fpmas, dpmas;
  std::vector<PmaManager::PmaTrace> pmas; tr->getPmasAccessed(pmas); std::reverse(pmas.begin(), pmas.end());
  for (auto& entry : pmas)
  {
    int index = entry.ix_ <= 31 ? 0x7E0 : 0xBE0;
    URV pmaCfgVal;
    tr->peekCsReg(CsrNumber(index + entry.ix_), pmaCfgVal);
    if (entry.reason_ == PmaManager::AccessReason::Fetch)
    {
      if ( entry.addr_ >= (physPc & ~(uint64_t(3))) && 
          (entry.addr_ < (physPc+instSize)))
      {
        if (!fPma)
        {
          fPma = true;
          fpmas.push_back(pmaCfgVal);
          fPmaCfgVal = pmaCfgVal;
          if (!fMultihit && tr->matchMultiplePma(entry.addr_))
            fMultihit = true;
        }
        else if (!fPmaCrossing)
        {
          if (fPmaCfgVal != pmaCfgVal)
          {
            fPmaCrossing = true;
            fpmas.push_back(pmaCfgVal);
            if (!fMultihit && tr->matchMultiplePma(entry.addr_))
              fMultihit = true;
          }
        }
      }
      else if (!fPmaPtw)
      {
        if (pagingMode != VirtMem::Mode::Bare)
        {
          fPmaPtw = true;
          table.addEntry(Point::FPmaPtw, pmaCfgVal);
        }
      }
    }
    else if (entry.reason_ == PmaManager::AccessReason::LdSt)
    {
      if ( entry.addr_ >= (physLdStAddr & ~(uint64_t(3))) &&
          (entry.addr_ < (physLdStAddr+ldStSize)))
      {
        if (!dPma)
        {
          dPma = true;
          dPmaCfgVal = pmaCfgVal;
          dpmas.push_back(pmaCfgVal);
          if (!dMultihit && tr->matchMultiplePma(entry.addr_))
            dMultihit = true;

        }
        else if (!dPmaCrossing)
        {
          if (pmaCfgVal != dPmaCfgVal)
          {
            dPmaCrossing = true;
            dpmas.push_back(pmaCfgVal);
            if (!dMultihit && tr->matchMultiplePma(entry.addr_))
              dMultihit = true;
          }
        }
      }
      else if (!dPmaPtw)
      {
        if (pagingMode != VirtMem::Mode::Bare)
        {
          dPmaPtw = true;
          table.addEntry(Point::DPmaPtw, pmaCfgVal);
        }
      }
    }
  }
  switch (fpmas.size()) {
    case 2:  table.addEntry(Point::FPmaCrossing, fpmas[0]);
    case 1:  table.addEntry(Point::FPma, fpmas.back());
    default: table.addEntry(Point::FPmaMultihit, int(fMultihit));
  }
  switch (dpmas.size()) {
    case 2:  table.addEntry(Point::DPmaCrossing, dpmas[0]);
    case 1:  table.addEntry(Point::DPma, dpmas.back());
    default: table.addEntry(Point::DPmaMultihit, int(dMultihit));
  }
}

template <typename URV>
static void fillPmp2Stage(std::vector<PmpManager::PmpTrace> pmps, uint64_t addr, uint64_t size, uint32_t point, uint64_t stage, uint64_t cpLen, arch_t& table, TraceRecord<URV>* tr)
{
  URV pmpCfgVal;
  for (auto& entry : pmps)
    if (entry.addr_ >= (addr & ~(uint64_t(3))) &&
            (entry.addr_ < (addr+size)))
    {
      tr->peekCsReg(CsrNumber(0x3A0), pmpCfgVal);
      pmpCfgVal = (pmpCfgVal >> (entry.ix_ * 8)) & 0xff;
      point = point + (stage * cpLen);
      table.addEntry(Point(point), pmpCfgVal);
      return;
    }
}

template <typename URV>
static void fillPma2Stage(std::vector<PmaManager::PmaTrace> pmas, uint64_t addr, uint64_t /*size*/, uint32_t point, uint64_t stage, uint64_t cpLen, arch_t& table, TraceRecord<URV>* tr)
{
  URV pmaCfgVal;
  uint64_t mask =  0xfffffffffffff000; 
  for (auto& entry : pmas)
    if ((entry.addr_ & mask) == (addr & mask))
    {
      auto num = entry.ix_ <=31 ? 0x7E0 + entry.ix_ : 0xBE0 + entry.ix_;
      tr->peekCsReg(CsrNumber(num), pmaCfgVal);
      point = point + (stage * cpLen);
      table.addEntry(Point(point), pmaCfgVal);
      return;
    }
}

#if 1
template <typename URV>
static void
sampleTwoStagePagingData(TraceRecord<URV>* tr,
                         arch_t& table,
                         const std::vector<VirtMem::Walk>& walks,
                         std::vector<PmaManager::PmaTrace>& pmas,
                         std::vector<PmpManager::PmpTrace>& pmps,
                         bool instr, bool hostBareMode, bool guestBareMode, uint64_t ) 
{
  int point = 0;
  uint32_t cpLen = uint32_t(Point::FGPA_GStageLevel1) - uint32_t(Point::FGPA);

  size_t lastIx = 0;  
  if (not walks.empty() and  (walks.front().isStage1() or walks.front().isOneStage()))
    {
      for (size_t ix = 0; ix < walks.size(); ++ix)
        if (walks.at(ix).isStage1() or walks.at(ix).isOneStage())
          lastIx = ix;
      if (lastIx > 0)
        table.addEntry(instr? Point::FPageCross : Point::DPageCross, true);
    }

  for (size_t ix = lastIx; ix < walks.size(); ++ix)
    {
      const auto& walk = walks.at(ix);
      if (walk.isStage1())
        {
          for (unsigned i = 0; i < walk.size(); ++i)
            {
              uint64_t addr = walk.ithPteAddr(i);
              point = instr? uint32_t(Point::FGPA) : uint32_t(Point::DGPA);
              auto offset = i * cpLen;  
              table.addEntry(Point(point+offset), addr);
            }
          auto adUpdated = (unsigned(walk.aUpdated()) << 1) | unsigned(walk.dUpdated());
          if (adUpdated)
            {
              point = instr? uint32_t(Point::FVPTE_ADUpdate) : uint32_t(Point::DVPTE_ADUpdate);
              point += (walk.size() * cpLen);
              table.addEntry(Point(point), adUpdated);
            }

        }
      else if (walk.isStage2())
        {

          auto offset = walk.size() * cpLen;

          if (walk.complete())    
            {
              auto leafVal = walk.pteValues().back();
              point = instr? uint32_t(Point::FPTELeaf) : uint32_t(Point::DPTELeaf);
              table.addEntry(Point(point+offset), leafVal);
            }
          if (walk.size() > 1)    
            {
              auto pte = walk.pteValues().front();
              point = instr? uint32_t(Point::FPTENonLeaf) : uint32_t(Point::DPTENonLeaf);
              table.addEntry(Point(point+offset), pte);
            }

          unsigned gLevel = 0;
          for (auto addr : walk.pteAddrs())
            {
              fillPma2Stage(pmas, addr, 8, instr? uint32_t(Point::FPmaLeaf) : uint32_t(Point::DPmaLeaf), gLevel, cpLen, table, tr);
              fillPmp2Stage(pmps, addr, 8, instr? uint32_t(Point::FPmpLeaf) : uint32_t(Point::DPmpLeaf), gLevel++, cpLen, table, tr);
            }

          if (not hostBareMode and walk.size() > 0)
            fillPma2Stage(pmas, walk.pteAddrs().front(), 8, instr? uint32_t(Point::FPmaRoot) : uint32_t(Point::DPmaRoot), 0, 0, table, tr);

          auto adUpdated = (unsigned(walk.aUpdated()) << 1) | unsigned(walk.dUpdated());
          if (adUpdated)
            {
              point = instr? uint32_t(Point::FPTELeafADUpdate) : uint32_t(Point::DPTELeafADUpdate);
              point += (walk.size() * cpLen);
              table.addEntry(Point(point), adUpdated);
            }
        }
      else
        assert(0);
    }

  if (not walks.empty() and walks.back().isStage2())
    {
      auto addr = walks.back().ithPteAddr(0);
      fillPma2Stage(pmas, addr, 8, instr? uint32_t(Point::FPmaRoot) : uint32_t(Point::DPmaRoot), 0, 0, table, tr);
    }

  if (walks.size() > 1 and not guestBareMode)
    {
      uint64_t vPageSize = walks.back().size(); 
      table.addEntry(instr? Point::FVPageSize : Point::DVPageSize, vPageSize);
    }
}


#else

template <typename URV, typename HPTE, typename GPTE>
static void
sampleTwoStagePagingData(TraceRecord<URV>* tr,
                         arch_t& table,
                         std::vector<std::vector<VirtMem::WalkEntry>>& walkData,
                         std::vector<PmaManager::PmaTrace>& pmas,
                         std::vector<PmpManager::PmpTrace>& pmps,
                         bool instr, bool hostBareMode, bool guestBareMode, uint64_t ) //, physAddr)
{

  int point;
  int vaEntries = 0, vPageSize = 0, gPageSize;
  int hLevels = hostBareMode?  0 : HPTE(0).levels();
  int gLevels = guestBareMode? 0 : GPTE(0).levels();
  gLevels++; 
  uint32_t cpLen = uint32_t(Point::FGPA_GStageLevel1) - uint32_t(Point::FGPA);
  int lastGlevel = 0;

  
  for (auto& walk : walkData)
    for (auto& entry : walk)
      if (entry.type_ == VirtMem::WalkEntry::GVA)
        vaEntries++;
      else
        break;
  if (vaEntries > 1)
    table.addEntry(instr? Point::FPageCross : Point::DPageCross, true);

  uint64_t lastGpa = 0;
  for (auto& walk : walkData) {
    uint64_t hPteNonLeafVal = 0;
    uint64_t hPteNonLeafPma = 0;
    bool hPteNonLeafPrinted = false;
    for (auto& entry : walk) {
      if (entry.type_ == VirtMem::WalkEntry::GVA)
          vaEntries--;
      if (vaEntries != 0) 
          break;

      if (entry.type_ == VirtMem::WalkEntry::GPA) {
        gPageSize = 0; 
        if (entry.addr_ != lastGpa) { 
          gLevels--;
          if (gLevels < 0) break; 
          lastGpa = entry.addr_;
          point = instr? uint32_t(Point::FGPA) : uint32_t(Point::DGPA);
          auto offset = gLevels * cpLen;
          table.addEntry(Point(point+offset), entry.addr_);
          hPteNonLeafVal = 0; 
        }

      } else if ((entry.type_ == VirtMem::WalkEntry::PA) && !hostBareMode && (gLevels >= 0)) {
        uint64_t hPteVal;
        gPageSize++;
        tr->peekMemory(entry.addr_, hPteVal, true);

        if (gPageSize == 1 && gLevels == 0) {
          fillPma2Stage(pmas, entry.addr_, 8, instr? uint32_t(Point::FPmaRoot) : uint32_t(Point::DPmaRoot), 0, 0, table, tr);
        }

        bool hPteLeaf = HPTE(hPteVal).leaf();
        if (!hPteLeaf) {
          hPteNonLeafVal = hPteVal;
          hPteNonLeafPma = entry.addr_;

        } else { 
          auto offset = gLevels * cpLen;
          point = instr? uint32_t(Point::FPTELeaf) : uint32_t(Point::DPTELeaf);
          table.addEntry(Point(point+offset), hPteVal);

          if (hPteNonLeafVal) {
            hPteNonLeafPrinted = true;
            point = instr? uint32_t(Point::FPTENonLeaf) : uint32_t(Point::DPTENonLeaf);
            table.addEntry(Point(point+offset), hPteNonLeafVal);
          }

          gPageSize = hLevels - gPageSize;
          if (gPageSize >= 0 && !hostBareMode) {
            point = instr? uint32_t(Point::FPageSize) : uint32_t(Point::DPageSize);
            table.addEntry(Point(point+offset), gPageSize);
            gPageSize = 0;
          }
          fillPma2Stage(pmas, entry.addr_, 8, instr? uint32_t(Point::FPmaLeaf) : uint32_t(Point::DPmaLeaf), gLevels, cpLen, table, tr);
          fillPmp2Stage(pmps, entry.addr_, 8, instr? uint32_t(Point::FPmpLeaf) : uint32_t(Point::DPmpLeaf), gLevels, cpLen, table, tr);
        }

      } else if (entry.type_ == VirtMem::WalkEntry::RE && (gLevels >= 0)) {
        auto offset = gLevels * cpLen;
        if (gLevels == 0) {
          fillPma2Stage(pmas, entry.addr_, 8, instr? uint32_t(Point::FPma) : uint32_t(Point::DPma), gLevels, cpLen, table, tr);
          fillPmp2Stage(pmps, entry.addr_, 8, instr? uint32_t(Point::FPmp) : uint32_t(Point::DPmp), gLevels, cpLen, table, tr);
          break;
        }
        uint64_t vPteVal;
        tr->peekMemory(entry.addr_, vPteVal, true);
        point = instr? uint32_t(Point::FVPTE) : uint32_t(Point::DVPTE);
        table.addEntry(Point(point+offset), vPteVal);

        fillPma2Stage(pmas, entry.addr_, 8, instr? uint32_t(Point::FPma) : uint32_t(Point::DPma), gLevels, cpLen, table, tr);
        fillPmp2Stage(pmps, entry.addr_, 8, instr? uint32_t(Point::FPmp) : uint32_t(Point::DPmp), gLevels, cpLen, table, tr);

        auto ADUpdated = (unsigned(entry.aUpdated_)<<1) | unsigned(entry.dUpdated_);
        if (ADUpdated) {
          if (entry.stage2_) { 
            point = instr? uint32_t(Point::FPTELeafADUpdate) : uint32_t(Point::DPTELeafADUpdate);
            point += (gLevels * cpLen);
          } else {
            point = instr? uint32_t(Point::FVPTE_ADUpdate) : uint32_t(Point::DVPTE_ADUpdate);
            point += (lastGlevel * cpLen);
          }
          table.addEntry(Point(point), ADUpdated);
        }
        lastGlevel = gLevels;

        bool vPteLeaf = GPTE(vPteVal).leaf();
        if (vPteLeaf) { 
          if (!vPageSize) vPageSize = gLevels-1;
          gLevels = 1;
        }
      }
    }
    
    if (!hPteNonLeafPrinted && hPteNonLeafVal && (gLevels >= 0)) {
      point = instr? uint32_t(Point::FPTENonLeaf) : uint32_t(Point::DPTENonLeaf);
      table.addEntry(Point(point+(gLevels*cpLen)), hPteNonLeafVal);
      fillPma2Stage(pmas, hPteNonLeafPma, 8, instr? uint32_t(Point::FPmaFault) : uint32_t(Point::DPmaFault), 0, 0, table, tr);
      uint64_t pteVal;
      tr->peekMemory(hPteNonLeafPma, pteVal, false);
      table.addEntry(instr? Point::FPtwFaultIsLeaf : Point::DPtwFaultIsLeaf, int(HPTE(pteVal).leaf()));
      table.addEntry(instr? Point::FPtwFaultLevel : Point::DPtwFaultLevel, gLevels);
    }
  } 
  if (!guestBareMode)
    table.addEntry(instr? Point::FVPageSize : Point::DVPageSize, vPageSize);
}

#endif

template <typename URV>
static void
sampleTwoStagePageTables(TraceRecord<URV>* tr, arch_t &table, VirtMem::Mode vsMode, VirtMem::Mode pageModeStage2, bool instr, uint64_t physAddr)
{
    const auto& walks = instr? tr->getFetchPageTableWalks() : tr->getDataPageTableWalks();
    std::vector<PmaManager::PmaTrace> pmas;
    tr->getPmasAccessed(pmas);
    std::reverse(pmas.begin(), pmas.end());

    std::vector<PmpManager::PmpTrace> pmps;
    tr->getPmpsAccessed(pmps);
    std::reverse(pmps.begin(), pmps.end());

    bool hostBareMode =  pageModeStage2 == VirtMem::Mode::Bare;
    bool guestBareMode =  vsMode == VirtMem::Mode::Bare;

    sampleTwoStagePagingData(tr, table, walks, pmas, pmps, instr, hostBareMode, guestBareMode, physAddr);
}

template <typename URV>
static void
sampleImsicData(TraceRecord<URV>* tr, arch_t &table)
{
  using SVP = std::pair<URV, uint64_t>;  
  std::vector<SVP> mcvps, scvps;
  std::vector<std::vector<SVP>> gcvps;

  std::vector<unsigned int> mmsi, smsi;
  std::vector<std::vector<unsigned int>> gmsi;
  
  tr->getImsicChanges(mcvps, scvps, gcvps, mmsi, smsi, gmsi);

  for (auto &pair : mcvps) {
      table.addEntry(Point::ImsicMCsrNum, pair.first);
      table.addEntry(Point::ImsicMCsrValue, pair.second);
  }
  for (auto &pair : scvps) {
      table.addEntry(Point::ImsicSCsrNum, pair.first);
      table.addEntry(Point::ImsicSCsrValue, pair.second);
  }

  int guest=0;
  for (auto &vector : gcvps) {
    for (auto &pair : vector) { 
      if(guest == 0) continue;
      table.addEntry(Point::ImsicGCsrNum, pair.first);
      table.addEntry(Point::ImsicGCsrValue, pair.second);
      table.addEntry(Point::ImsicGuest, guest);
    }
    guest++;
  }

  for (auto &id : mmsi) {
    table.addEntry(Point::ImsicMMSI, id);
  }

  for (auto &id : smsi) {
    table.addEntry(Point::ImsicSMSI, id);
  }

  guest=0;
  for (auto &vid : gmsi) {
    for (auto &id : vid) { 
      if(guest == 0) continue;
      table.addEntry(Point::ImsicMSIGuest, guest);
      table.addEntry(Point::ImsicGMSI, id);
    }
    guest++;
  }

}

__attribute__ ((used, destructor))
void finish()
{
  arch_t table;
  Point p = Point::EndOfSim;
  table.addEntry(p,1);
  trace(table);
}

template <typename URV>
void sample(TraceRecord<URV>* tr)
{
  static int step = 0;
  step = step + 1;
  arch_t table;

  table.addEntry(Point::HartIndex, unsigned(tr->hartIndex()));

  sampleInst(tr, table);

  table.addEntry(Point::VirtPc,     tr->virtPc());
  table.addEntry(Point::PhysPc,     tr->physPc());
  table.addEntry(Point::NextVirtPc, tr->nextVirtPc());

  std::vector<std::pair<URV, URV>> csrs;
  tr->getModifiedCsrs(csrs);
  sampleCsr(tr, table, csrs);

  table.addEntry(Point::PrivilegeMode,     unsigned(tr->privMode()));
  table.addEntry(Point::NextPrivilegeMode, unsigned(tr->nextPrivMode()));
  table.addEntry(Point::DebugMode,         unsigned(tr->debugMode()));
  table.addEntry(Point::NextDebugMode,     unsigned(tr->nextDebugMode()));

  uint64_t virtLdStAddr, physLdStAddr = ~0 , lastStoreValue;
  uint64_t ldStSize = tr->lastLdStAddress(virtLdStAddr, physLdStAddr);
  bool ldStMisal;
  if (ldStSize)
  {
    table.addEntry(Point::VirtLdStAddr, virtLdStAddr);
    table.addEntry(Point::PhysLdStAddr, physLdStAddr);
    if (tr->lastStVal(lastStoreValue))
      table.addEntry(Point::LastStoreValue, lastStoreValue);
  }
  if (tr->misalignedLdSt(ldStMisal))
    table.addEntry(Point::LdStMisal, ldStMisal);

  URV cause = 0;
  bool trap = tr->hasTrap(cause);
  if (trap)
  {
    constexpr size_t shift = (sizeof(URV)*8 - 1);
    bool interrupt = cause >> shift;
    if (interrupt) {
      table.addEntry(Point::Interrupt, cause & ~(uint64_t(1) << shift));

    } else {
      table.addEntry(Point::Exception, cause);

      bool trigger_hit = false;     
      uint64_t trigger_hit_vec = 0;
      URV csr_tdata1 = 0x7a1;
      auto iter = csrs.begin();
      while ((iter= std::find_if(iter, csrs.end(),
                                    [&](const std::pair<URV, URV>& csr_p) {
                                        return (csr_p.first & 0xfff) == csr_tdata1;})) != csrs.end())
      {
        trigger_hit = true;
        uint64_t tdata1_csr = ((iter->first)>>16) & 0xf;
        trigger_hit_vec = trigger_hit_vec | (1<<tdata1_csr);
        iter++;
      }
      if (trigger_hit) {
        table.addEntry(Point::Trigger, 1);
        table.addEntry(Point::TriggerHitVec, trigger_hit_vec);
      }
    }
  }

  unsigned virtualMode = unsigned(tr->virtualMode());
  table.addEntry(Point::VirtualMode,            virtualMode);
  table.addEntry(Point::ValidLR,                unsigned(tr->hasLr()));
  table.addEntry(Point::CancelLrCause,          unsigned(tr->cancelLrCause()));
  table.addEntry(Point::NumVectorPagesAccessed, unsigned(tr->numVecPagesAccessed()));
  table.addEntry(Point::NextVirtualMode,        unsigned(tr->nextVirtualMode()));

  sampleImsicData(tr, table);

  if (virtualMode)
  {
    VirtMem::Mode vsPagingMode, pageModeStage2;
    vsPagingMode = tr->vsMode();
    pageModeStage2 = tr->pageModeStage2();
    sampleTwoStagePageTables(tr, table, vsPagingMode, pageModeStage2, true,  tr->physPc());
    sampleTwoStagePageTables(tr, table, vsPagingMode, pageModeStage2, false, physLdStAddr);
  } 
  else
  {
    auto instSize = instructionSize(tr->instruction());
    VirtMem::Mode pagingMode = tr->pageMode();
    samplePageTables(tr, table, pagingMode, true);
    bool twoStage = false;

    const auto& walks = tr->getDataPageTableWalks();
    for (auto& walk : walks) if (walk.isTwoStage()) { twoStage = true; break; }
    if (twoStage) 
    {
      sampleTwoStagePageTables(tr, table, tr->vsMode(), tr->pageModeStage2(), false, physLdStAddr);
    }
    else
    {
      samplePageTables(tr, table, pagingMode, false);
      samplePmaData(tr, table, pagingMode, physLdStAddr, ldStSize, tr->physPc(), instSize);
      samplePmpData(tr, table, pagingMode, physLdStAddr, ldStSize, tr->physPc(), instSize);
    }
  }

#ifdef DEBUG
  std::cout<<std::dec<<"Step: #"<< step << "\n";
  for (auto& entry : table.entries_)
    std::cout << std::dec << "CP: " << entry.first << " (" << magic_enum::enum_name(static_cast<Point>(entry.first)) << ") " << std::hex <<" VAL: " << entry.second << '\n';

#endif
  trace(table);
}

extern "C"
{
  __attribute__ ((visibility("default")))
  void tracerExtension32(TraceRecord<uint32_t>* tr)
  {
    sample<uint32_t>(tr);
  }

  __attribute__ ((visibility("default")))
  void tracerExtension64(TraceRecord<uint64_t>* tr)
  {
    sample<uint64_t>(tr);
  }
}
