// SPDX-FileCopyrightText: © 2026 Tenstorrent AI ULC
// SPDX-License-Identifier: Apache-2.0
#include <iostream>
#include <fstream>
#include <bitset>
#include <optional>
#include <limits.h>
#include <math.h>
#include <boost/bimap.hpp>
#include "Info.hpp"
#include "Hart.hpp"
#include "common/Points.hpp"
#include "InstEntry.hpp"
#include "FpRegs.hpp"
#include "magic_enum/magic_enum.hpp"
#include "magic_enum/magic_enum_utility.hpp"
#include "instforms.hpp"
#include "common/utils.hpp"
#include "common/Operand.hpp"
#include "common/Coverage.hpp"
#include "common/Inst.hpp"
#include "common/Csr.hpp"
#include "common/Fields.hpp"
#include "common/Enum.hpp"
#include "common/Attribute.hpp"


using namespace ArchCov;
using namespace WdRiscv;

template <typename URV>
Info<URV>::Info(Hart<URV>& hart)
  : hart_(hart)
{

}

template <typename URV>
void
Info<URV>::points(enumBins& enums, attBins& atts, fieldsBins& fields, instBins& insts, csrBins& csrs) const //instBins& insts, csrBins& csrs) const
{
  enums.clear();
  atts.clear();
  fields.clear();
  insts.clear();
  csrs.clear();

  addInsts(atts, enums, insts);
  addCsrs(csrs, enums);
  addPrivilegeMode<Point::PrivilegeMode>(enums);
  addPrivilegeMode<Point::NextPrivilegeMode>(enums);

  addPtes<Point::FPTENonLeaf>(fields);
  addPtes<Point::FPTENonLeaf_GStageLevel1>(fields);
  addPtes<Point::FPTENonLeaf_GStageLevel2>(fields);
  addPtes<Point::FPTENonLeaf_GStageLevel3>(fields);
  addPtes<Point::FPTENonLeaf_GStageLevel4>(fields);
  addPtes<Point::FPTENonLeaf_GStageLevel5>(fields);

  addPtes<Point::FPTELeaf>(fields);
  addPtes<Point::FPTELeaf_GStageLevel1>(fields);
  addPtes<Point::FPTELeaf_GStageLevel2>(fields);
  addPtes<Point::FPTELeaf_GStageLevel3>(fields);
  addPtes<Point::FPTELeaf_GStageLevel4>(fields);
  addPtes<Point::FPTELeaf_GStageLevel5>(fields);

  addPtes<Point::DPTENonLeaf>(fields);
  addPtes<Point::DPTENonLeaf_GStageLevel1>(fields);
  addPtes<Point::DPTENonLeaf_GStageLevel2>(fields);
  addPtes<Point::DPTENonLeaf_GStageLevel3>(fields);
  addPtes<Point::DPTENonLeaf_GStageLevel4>(fields);
  addPtes<Point::DPTENonLeaf_GStageLevel5>(fields);

  addPtes<Point::DPTELeaf>(fields);
  addPtes<Point::DPTELeaf_GStageLevel1>(fields);
  addPtes<Point::DPTELeaf_GStageLevel2>(fields);
  addPtes<Point::DPTELeaf_GStageLevel3>(fields);
  addPtes<Point::DPTELeaf_GStageLevel4>(fields);
  addPtes<Point::DPTELeaf_GStageLevel5>(fields);

  addPtes<Point::FVPTE>(fields);
  addPtes<Point::FVPTE_Level1>(fields);
  addPtes<Point::FVPTE_Level2>(fields);
  addPtes<Point::FVPTE_Level3>(fields);
  addPtes<Point::FVPTE_Level4>(fields);
  addPtes<Point::FVPTE_Level5>(fields);
  addPtes<Point::DVPTE>(fields);
  addPtes<Point::DVPTE_Level1>(fields);
  addPtes<Point::DVPTE_Level2>(fields);
  addPtes<Point::DVPTE_Level3>(fields);
  addPtes<Point::DVPTE_Level4>(fields);
  addPtes<Point::DVPTE_Level5>(fields);

  addPageSize<Point::FPageSize>(enums);
  addPageSize<Point::DPageSize>(enums);
  addPageSize<Point::FPageSize_GStageLevel1>(enums);
  addPageSize<Point::DPageSize_GStageLevel1>(enums);
  addPageSize<Point::FPageSize_GStageLevel2>(enums);
  addPageSize<Point::DPageSize_GStageLevel2>(enums);
  addPageSize<Point::FPageSize_GStageLevel3>(enums);
  addPageSize<Point::DPageSize_GStageLevel3>(enums);
  addPageSize<Point::FPageSize_GStageLevel4>(enums);
  addPageSize<Point::DPageSize_GStageLevel4>(enums);
  addPageSize<Point::FPageSize_GStageLevel5>(enums);
  addPageSize<Point::DPageSize_GStageLevel5>(enums);
  addPageSize<Point::FVPageSize>(enums);
  addPageSize<Point::DVPageSize>(enums);

  addPageSize<Point::FPageCrossSize>(enums);
  addPageSize<Point::DPageCrossSize>(enums);
  addPageCross<Point::FPageCross>(atts);
  addPageCross<Point::DPageCross>(atts);

  addInterrupt(enums);
  addException(enums);
  addCancelLrCause(enums);
  addAtts(atts);
}

bool isCustomCsr(uint32_t num) { 
  uint32_t umode_rw_range_start = 0x800;
  uint32_t umode_rw_range_end = 0x8FF;
  uint32_t smode_rw_range_start_1 = 0x5C0;
  uint32_t smode_rw_range_end_1 = 0x5FF;
  uint32_t smode_rw_range_start_2 = 0x9C0;
  uint32_t smode_rw_range_end_2 = 0x9FF;
  uint32_t hmode_rw_range_start_1 = 0x6C0;
  uint32_t hmode_rw_range_end_1 = 0x6FF;
  uint32_t hmode_rw_range_start_2 = 0xAC0;
  uint32_t hmode_rw_range_end_2 = 0xAFF;
  uint32_t mmode_rw_range_start = 0x7C0;
  uint32_t mmode_rw_range_end = 0x7FF;
  uint32_t mmode_rw_range_start_2 = 0xBC0;
  uint32_t mmode_rw_range_end_2 = 0xBFF;
  uint32_t umode_ro_range_start = 0xCC0;
  uint32_t umode_ro_range_end = 0xCFF;
  uint32_t smode_ro_range_start_1 = 0xDC0;
  uint32_t smode_ro_range_end_1 = 0xDFF;
  uint32_t smode_ro_range_start_2 = 0xFC0;
  uint32_t smode_ro_range_end_2 = 0xFFF;
  uint32_t hmode_ro_range_start_1 = 0xEC0;
  uint32_t hmode_ro_range_end_1 = 0xEFF;
  uint32_t hmode_ro_range_start_2 = 0xFC0;
  uint32_t hmode_ro_range_end_2 = 0xFFF;

  if (num >= umode_rw_range_start and num <= umode_rw_range_end) {
    return true;
  }
  if (num >= smode_rw_range_start_1 and num <= smode_rw_range_end_1) {
    return true;
  }
  if (num >= smode_rw_range_start_2 and num <= smode_rw_range_end_2) {
    return true;
  }
  if (num >= hmode_rw_range_start_1 and num <= hmode_rw_range_end_1) {
    return true;
  }
  if (num >= hmode_rw_range_start_2 and num <= hmode_rw_range_end_2) {
    return true;
  }
  if (num >= mmode_rw_range_start and num <= mmode_rw_range_end) {
    return true;
  }
  if (num >= mmode_rw_range_start_2 and num <= mmode_rw_range_end_2) {
    return true;
  }
  if (num >= umode_ro_range_start and num <= umode_ro_range_end) {
    return true;
  }
  if (num >= smode_ro_range_start_1 and num <= smode_ro_range_end_1) {
    return true;
  }
  if (num >= smode_ro_range_start_2 and num <= smode_ro_range_end_2) {
    return true;
  }
  if (num >= hmode_ro_range_start_1 and num <= hmode_ro_range_end_1) {
    return true;
  }
  if (num >= hmode_ro_range_start_2 and num <= hmode_ro_range_end_2) {
    return true;
  }
  return false;
}

template <typename URV>
void
Info<URV>::addInsts(attBins& atts, enumBins& enums, instBins& insts) const
{
  atts.emplace_back(Attribute(std::string(magic_enum::enum_name(Point::Inst)), 32));

  // generate Enum for csr
  Enum csrs;
  for (uint32_t reg = 0; reg < uint32_t(CsrNumber::MAX_CSR_); ++reg) {
    CsrNumber num = static_cast<CsrNumber>(reg);
    const auto csr = hart_.csRegs().findCsr(num);
    if (csr and not isCustomCsr(reg)) {
      csrs.addEnumValue(std::string(csr->getName()), uint64_t(num));   
    }
  }
  csrs.setPrefix("csr_Op2");
  enums.push_back(csrs);

  // generate enum for rounding mode
  Enum rms;
  magic_enum::enum_for_each<RoundingMode>([&rms] (auto val) {
      constexpr RoundingMode rm = val;
      if (rm != RoundingMode::Invalid1 and rm != RoundingMode::Invalid2)
        rms.addEnumValue(std::string(magic_enum::enum_name(rm)), uint64_t(rm));
  });
  rms.setPrefix("fext_Rm");
  enums.push_back(rms);

  Enum instrEnum;
  std::unordered_map<std::string, std::vector<std::pair<std::string, uint64_t>>> formatMap, ExtensionMap;
  InstTable table;
  for (auto& entry : table.getInstVec()) {

    Inst inst;
    auto instName = std::string(entry.name());
    auto extension = (entry.isCompressed()) ? std::string(magic_enum::enum_name(RvExtension::C)) : std::string(magic_enum::enum_name(entry.extension()));

    inst.setName(instName);
    inst.setId(uint64_t(entry.instId()));
    inst.setFormat(std::string(magic_enum::enum_name(entry.format())));
    inst.setExt(extension);
    
    // Create Instruction Enums 
    instrEnum.addEnumValue(format_name(instName, '.', '_'), uint64_t(entry.instId()));

    // Create Format and Extension Enums 
    formatMap[std::string(magic_enum::enum_name(entry.format()))].push_back(std::make_pair(instName, uint64_t(entry.instId())));
    ExtensionMap[extension].push_back(std::make_pair(instName, uint64_t(entry.instId())));
    
    for (unsigned i = 0; i < 4; i++) {
      Operand op;
      op.setpOperand(Point(uint64_t(Point::Op0) + i));
      op.setType(entry.ithOperandType(i));
      op.setMode(entry.ithOperandMode(i));

      op.setpValue(Point(uint64_t(Point::Op0Val) + i));
      op.setValue(Attribute(8*sizeof(URV)));

      if (entry.ithOperandType(i) != OperandType::None) {
        std::bitset<32> bits;
        bits = entry.ithOperandMask(i);

        if (not bits.count())
          continue;

        if (entry.ithOperandType(i) == OperandType::CsReg)
          op.setOperand(csrs);
        else if (entry.ithOperandType(i) == OperandType::Imm) {
          op.setOperand(Attribute(0));
          op.setValue(Attribute(bits.count()));
        }
        else
          op.setOperand(Attribute(bits.count()));

        inst.addOperand(op);
      }
    }

    if (entry.hasRoundingMode())
      inst.addOperand(Operand(Point::Rm, rms, Point::Undefined, Attribute(), OperandType::Imm, OperandMode::None));
    if (entry.isBranch())
      inst.addExtra(Point::BrTaken, Attribute(1));
    insts.push_back(inst);
  }

  for (auto& entry : formatMap) {
    Enum formatEnum;
    for (auto& inst : entry.second) {
      formatEnum.addEnumValue(format_name(inst.first, '.', '_'), inst.second);
    }
    formatEnum.setPrefix(entry.first+"Format");
    enums.push_back(formatEnum);
  }

  for (auto& entry : ExtensionMap) {
    Enum extensionEnum;
    for (auto& inst : entry.second) {
      extensionEnum.addEnumValue(format_name(inst.first, '.', '_'), inst.second);
    }
    extensionEnum.setPrefix(entry.first+"Ext");
    enums.push_back(extensionEnum);
  }
  instrEnum.setPrefix("instrEnum");
  enums.push_back(instrEnum);
}

template <typename URV>
void
Info<URV>::addCsrs(csrBins& csrs, enumBins& enums) const
{
  Enum csrEnum;
  for (uint64_t reg = 0; reg < uint64_t(CsrNumber::MAX_CSR_); ++reg) {

    const auto csr = hart_.csRegs().findCsr(static_cast<CsrNumber>(reg));
    if (csr and not isCustomCsr(reg)) {

      csrEnum.addEnumValue(std::string(csr->getName()), uint64_t(reg));

      const auto fields = csr->fields();
      if (fields.size() > 0) { // defined fields?
        Csr pl;
        pl.num = reg;
        pl.setName(std::string(csr->getName()));
        for (const auto& field : fields) {
          // special enums for certain CSR fields
          pl.addField(Field(field.field, field.width));
        }
        csrs.push_back(pl);
      }
    }
  }
  csrEnum.setPrefix("csrEnum");
  enums.push_back(csrEnum);
}

template <typename URV>
template <Point p>
void
Info<URV>::addPrivilegeMode(enumBins& enums) const 
{
  Enum enum_bin(std::string(magic_enum::enum_name(p)));
  magic_enum::enum_for_each<PrivilegeMode>([&enum_bin] (auto val) {
    constexpr PrivilegeMode mode = val;
    enum_bin.addEnumValue(std::string(magic_enum::enum_name(mode)), uint64_t(mode));
  });
  enums.push_back(enum_bin);
}

template <typename URV>
template <Point p>
void
Info<URV>::addPtes(fieldsBins& fields) const
{

  Fields f = Fields();

  if constexpr (isRv64_) {
    Pte57 pte(~0ULL);
    std::bitset<64> bits;

    bits = pte.valid();
    f.addField(Field("v", Attribute(uint64_t(bits.count()))));
    bits = pte.read();
    f.addField(Field("r", Attribute(uint64_t(bits.count()))));
    bits = pte.write();
    f.addField(Field("w", Attribute(uint64_t(bits.count()))));
    bits = pte.exec();
    f.addField(Field("x", Attribute(uint64_t(bits.count()))));
    bits = pte.user();
    f.addField(Field("u", Attribute(uint64_t(bits.count()))));
    bits = pte.global();
    f.addField(Field("g", Attribute(uint64_t(bits.count()))));
    bits = pte.accessed();
    f.addField(Field("a", Attribute(uint64_t(bits.count()))));
    bits = pte.dirty();
    f.addField(Field("d", Attribute(uint64_t(bits.count()))));
    bits = pte.rsw();
    f.addField(Field("rsw", Attribute(uint64_t(bits.count()))));
    bits = pte.ppn();
    f.addField(Field("ppn", Attribute(uint64_t(bits.count()))));
    bits = pte.reserved(false);
    f.addField(Field("res", Attribute(uint64_t(bits.count()))));
    bits = pte.pbmt();
    f.addField(Field("pbmt", Attribute(uint64_t(bits.count()))));
    bits = pte.hasNapot();
    f.addField(Field("napot", Attribute(uint64_t(bits.count()))));
    f.setTotalWidth(57);
  }
  else {
    Pte32 pte(~0U);
    std::bitset<32> bits;

    bits = pte.valid();
    f.addField(Field("v", Attribute(uint64_t(bits.count()))));
    bits = pte.read();
    f.addField(Field("r", Attribute(uint64_t(bits.count()))));
    bits = pte.write();
    f.addField(Field("w", Attribute(uint64_t(bits.count()))));
    bits = pte.exec();
    f.addField(Field("x", Attribute(uint64_t(bits.count()))));
    bits = pte.user();
    f.addField(Field("u", Attribute(uint64_t(bits.count()))));
    bits = pte.global();
    f.addField(Field("g", Attribute(uint64_t(bits.count()))));
    bits = pte.accessed();
    f.addField(Field("a", Attribute(uint64_t(bits.count()))));
    bits = pte.dirty();
    f.addField(Field("d", Attribute(uint64_t(bits.count()))));
    bits = pte.rsw();
    f.addField(Field("rsw", Attribute(uint64_t(bits.count()))));
    bits = pte.ppn();
    f.addField(Field("ppn", Attribute(uint64_t(bits.count()))));
    bits = pte.res();
    f.addField(Field("res", Attribute(uint64_t(bits.count()))));
    f.setTotalWidth(32);
  }
  f.setName(std::string(magic_enum::enum_name(p)));
  fields.push_back(f);
}

template <typename URV>
template <Point p>
void
Info<URV>::addPageSize(enumBins& enums) const
{
  Enum enum_bin(std::string(magic_enum::enum_name(p)));
  Pte57 pte(0);

  for (uint64_t level = 0; level < pte.levels(); ++level) {
    std::string sizeStr = VirtMem::pageSize(VirtMem::Mode::Sv57, level);
    enum_bin.addEnumValue(sizeStr, level);
  }
  enums.push_back(enum_bin);
}


template <typename URV>
void
Info<URV>::addCancelLrCause(enumBins& enums) const
{
  Enum enum_bin(std::string(magic_enum::enum_name(Point::CancelLrCause)));
  magic_enum::enum_for_each<CancelLrCause>([&enum_bin] (auto val) {
    constexpr CancelLrCause cause = val;
    enum_bin.addEnumValue(std::string(magic_enum::enum_name(cause)), unsigned(cause));
  });
  enums.push_back(enum_bin);
}

template <typename URV>
template <Point p>
void
Info<URV>::addPageCross(attBins& atts) const
{
  atts.push_back(Attribute(std::string(magic_enum::enum_name(p)), 1));
}

template <typename URV>
void
Info<URV>::addInterrupt(enumBins& enums) const
{
  Enum enum_bin(std::string(magic_enum::enum_name(Point::Interrupt)));
  magic_enum::enum_for_each<InterruptCause>([&enum_bin] (auto val) {
    constexpr InterruptCause cause = val;
    bool disable = false;
    if (std::string(magic_enum::enum_name(cause)).find("RESERVED") != std::string::npos)
      disable = true;
    if (not disable)
      enum_bin.addEnumValue(std::string(magic_enum::enum_name(cause)), unsigned(cause));
  });
  enums.push_back(enum_bin);
}

template <typename URV>
void
Info<URV>::addException(enumBins& enums) const
{
  Enum enum_bin(std::string(magic_enum::enum_name(Point::Exception)));
  magic_enum::enum_for_each<ExceptionCause>([&enum_bin] (auto val) {
    constexpr ExceptionCause cause = val;
    bool disable = false;
    if (std::string(magic_enum::enum_name(cause)).find("RESERVED") != std::string::npos)
      disable = true;
    if (cause == ExceptionCause::MAX_CAUSE or cause == ExceptionCause::NONE)
      disable = true;
    if (not disable)
      enum_bin.addEnumValue(std::string(magic_enum::enum_name(cause)), unsigned(cause));
  });
  enums.push_back(enum_bin);
}

template <typename URV>
void
Info<URV>::addAtts(attBins& atts) const
{
  atts.push_back(Attribute(std::string(magic_enum::enum_name(Point::HartIndex)), 64));

  atts.push_back(Attribute(std::string(magic_enum::enum_name(Point::VirtLdStAddr)), 64));
  atts.push_back(Attribute(std::string(magic_enum::enum_name(Point::PhysLdStAddr)), 64));
  atts.push_back(Attribute(std::string(magic_enum::enum_name(Point::LastStoreValue)), 64));

  atts.push_back(Attribute(std::string(magic_enum::enum_name(Point::VirtPc)), 64));
  atts.push_back(Attribute(std::string(magic_enum::enum_name(Point::PhysPc)), 64));
  atts.push_back(Attribute(std::string(magic_enum::enum_name(Point::NextVirtPc)), 64));

  atts.push_back(Attribute(std::string(magic_enum::enum_name(Point::LdStMisal)), 1));
  atts.push_back(Attribute(std::string(magic_enum::enum_name(Point::VirtualMode)), 1));
  atts.push_back(Attribute(std::string(magic_enum::enum_name(Point::NextVirtualMode)), 1));
  atts.push_back(Attribute(std::string(magic_enum::enum_name(Point::DebugMode)), 1));
  atts.push_back(Attribute(std::string(magic_enum::enum_name(Point::NextDebugMode)), 1));
  atts.push_back(Attribute(std::string(magic_enum::enum_name(Point::ValidLR)), 1));
  atts.push_back(Attribute(std::string(magic_enum::enum_name(Point::NumVectorPagesAccessed)), 64));

  atts.push_back(Attribute(std::string(magic_enum::enum_name(Point::DPmaMultihit)), 1));
  atts.push_back(Attribute(std::string(magic_enum::enum_name(Point::FPmaMultihit)), 1));
  atts.push_back(Attribute(std::string(magic_enum::enum_name(Point::DPmpMultihit)), 1));
  atts.push_back(Attribute(std::string(magic_enum::enum_name(Point::FPmpMultihit)), 1));

  atts.push_back(Attribute(std::string(magic_enum::enum_name(Point::DPmpIndex)), 64));
  atts.push_back(Attribute(std::string(magic_enum::enum_name(Point::FPmpIndex)), 64));
  atts.push_back(Attribute(std::string(magic_enum::enum_name(Point::FPmpCrossingIndex)), 64));
  atts.push_back(Attribute(std::string(magic_enum::enum_name(Point::DPmpCrossingIndex)), 64));

  atts.push_back(Attribute(std::string(magic_enum::enum_name(Point::DGPA)), 64));
  atts.push_back(Attribute(std::string(magic_enum::enum_name(Point::DGPA_GStageLevel1)), 64));
  atts.push_back(Attribute(std::string(magic_enum::enum_name(Point::DGPA_GStageLevel2)), 64));
  atts.push_back(Attribute(std::string(magic_enum::enum_name(Point::DGPA_GStageLevel3)), 64));
  atts.push_back(Attribute(std::string(magic_enum::enum_name(Point::DGPA_GStageLevel4)), 64));
  atts.push_back(Attribute(std::string(magic_enum::enum_name(Point::DGPA_GStageLevel5)), 64));

  atts.push_back(Attribute(std::string(magic_enum::enum_name(Point::FGPA)), 64));
  atts.push_back(Attribute(std::string(magic_enum::enum_name(Point::FGPA_GStageLevel1)), 64));
  atts.push_back(Attribute(std::string(magic_enum::enum_name(Point::FGPA_GStageLevel2)), 64));
  atts.push_back(Attribute(std::string(magic_enum::enum_name(Point::FGPA_GStageLevel3)), 64));
  atts.push_back(Attribute(std::string(magic_enum::enum_name(Point::FGPA_GStageLevel4)), 64));
  atts.push_back(Attribute(std::string(magic_enum::enum_name(Point::FGPA_GStageLevel5)), 64));

  // Whole-PTE (64-bit) attributes for the V-stage PTE Points. These sit
  // alongside the per-field decompositions emitted by addPtes (e.g. FVPTE_Level1_v,
  // FVPTE_Level1_ppn, ...) so SV samplers can reference the full PTE word as
  // well as its individual fields.
  atts.push_back(Attribute(std::string(magic_enum::enum_name(Point::FVPTE)), 64));
  atts.push_back(Attribute(std::string(magic_enum::enum_name(Point::FVPTE_Level1)), 64));
  atts.push_back(Attribute(std::string(magic_enum::enum_name(Point::FVPTE_Level2)), 64));
  atts.push_back(Attribute(std::string(magic_enum::enum_name(Point::FVPTE_Level3)), 64));
  atts.push_back(Attribute(std::string(magic_enum::enum_name(Point::FVPTE_Level4)), 64));
  atts.push_back(Attribute(std::string(magic_enum::enum_name(Point::FVPTE_Level5)), 64));
  atts.push_back(Attribute(std::string(magic_enum::enum_name(Point::DVPTE)), 64));
  atts.push_back(Attribute(std::string(magic_enum::enum_name(Point::DVPTE_Level1)), 64));
  atts.push_back(Attribute(std::string(magic_enum::enum_name(Point::DVPTE_Level2)), 64));
  atts.push_back(Attribute(std::string(magic_enum::enum_name(Point::DVPTE_Level3)), 64));
  atts.push_back(Attribute(std::string(magic_enum::enum_name(Point::DVPTE_Level4)), 64));
  atts.push_back(Attribute(std::string(magic_enum::enum_name(Point::DVPTE_Level5)), 64));

  // Whole-PTE (64-bit) attributes for selected G-stage leaf PTE Points
  // (Levels 1, 2, 4). Levels 3 and 5 are intentionally not exposed here.
  atts.push_back(Attribute(std::string(magic_enum::enum_name(Point::FPTELeaf_GStageLevel1)), 64));
  atts.push_back(Attribute(std::string(magic_enum::enum_name(Point::FPTELeaf_GStageLevel2)), 64));
  atts.push_back(Attribute(std::string(magic_enum::enum_name(Point::FPTELeaf_GStageLevel3)), 64));
  atts.push_back(Attribute(std::string(magic_enum::enum_name(Point::FPTELeaf_GStageLevel4)), 64));
  atts.push_back(Attribute(std::string(magic_enum::enum_name(Point::FPTELeaf_GStageLevel5)), 64));
  atts.push_back(Attribute(std::string(magic_enum::enum_name(Point::FPTENonLeaf_GStageLevel1)), 64));
  atts.push_back(Attribute(std::string(magic_enum::enum_name(Point::FPTENonLeaf_GStageLevel2)), 64));
  atts.push_back(Attribute(std::string(magic_enum::enum_name(Point::FPTENonLeaf_GStageLevel3)), 64));
  atts.push_back(Attribute(std::string(magic_enum::enum_name(Point::FPTENonLeaf_GStageLevel4)), 64));
  atts.push_back(Attribute(std::string(magic_enum::enum_name(Point::FPTENonLeaf_GStageLevel5)), 64));
  
  atts.push_back(Attribute(std::string(magic_enum::enum_name(Point::DPTENonLeaf_GStageLevel1)), 64));
  atts.push_back(Attribute(std::string(magic_enum::enum_name(Point::DPTENonLeaf_GStageLevel2)), 64));
  atts.push_back(Attribute(std::string(magic_enum::enum_name(Point::DPTENonLeaf_GStageLevel3)), 64));
  atts.push_back(Attribute(std::string(magic_enum::enum_name(Point::DPTENonLeaf_GStageLevel4)), 64));
  atts.push_back(Attribute(std::string(magic_enum::enum_name(Point::DPTENonLeaf_GStageLevel5)), 64));
  atts.push_back(Attribute(std::string(magic_enum::enum_name(Point::DPTELeaf_GStageLevel1)), 64));
  atts.push_back(Attribute(std::string(magic_enum::enum_name(Point::DPTELeaf_GStageLevel2)), 64));
  atts.push_back(Attribute(std::string(magic_enum::enum_name(Point::DPTELeaf_GStageLevel3)), 64));
  atts.push_back(Attribute(std::string(magic_enum::enum_name(Point::DPTELeaf_GStageLevel4)), 64));
  atts.push_back(Attribute(std::string(magic_enum::enum_name(Point::DPTELeaf_GStageLevel5)), 64));


  atts.push_back(Attribute(std::string(magic_enum::enum_name(Point::Trigger)), 64));
  atts.push_back(Attribute(std::string(magic_enum::enum_name(Point::TriggerHitVec)), 64));
  atts.push_back(Attribute(std::string(magic_enum::enum_name(Point::FPmaFault)), 64));
  atts.push_back(Attribute(std::string(magic_enum::enum_name(Point::DPmaFault)), 64));
  atts.push_back(Attribute(std::string(magic_enum::enum_name(Point::FPtwFaultIsLeaf)), 1));
  atts.push_back(Attribute(std::string(magic_enum::enum_name(Point::DPtwFaultIsLeaf)), 1));
  atts.push_back(Attribute(std::string(magic_enum::enum_name(Point::FPtwFaultLevel)), 64));
  atts.push_back(Attribute(std::string(magic_enum::enum_name(Point::DPtwFaultLevel)), 64));
}

template class ArchCov::Info<uint32_t>;
template class ArchCov::Info<uint64_t>;
