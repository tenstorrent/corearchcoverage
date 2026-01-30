#include <iostream>
#include <fstream>
#include <bitset>
#include <optional>
#include <limits.h>
#include <math.h>
#include <boost/bimap.hpp>
#include "Info.hpp"
#include "Hart.hpp"
#include "Points.hpp"
#include "InstEntry.hpp"
#include "FpRegs.hpp"
#include "magic_enum.hpp"
#include "instforms.hpp"

using namespace ArchCov;
using namespace WdRiscv;
template <typename URV>
Info<URV>::Info(Hart<URV>& hart)
  : hart_(hart)
{

}

template <typename URV>
void
Info<URV>::points(enumBins& enums, attBins& atts, fieldsBins& fields, instBins& insts, csrBins& csrs) const
{
  enums.clear();
  atts.clear();
  insts.clear();
  csrs.clear();
  fields.clear();

  addInsts(atts, insts);
  addCsrs(csrs);
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
  addPmas(fields);
  addPmps(fields);
  addAtts(atts);
}


template <typename URV>
void
Info<URV>::addInsts(attBins& atts, instBins& insts) const
{
  atts.emplace_back(std::string(magic_enum::enum_name(Point::Inst)), Attribute(32), RESOLVE::NONE);

  // generate Enum for csr
  Enum csrs;
  for (uint32_t reg = 0; reg < uint32_t(CsrNumber::MAX_CSR_); ++reg) {
    CsrNumber num = static_cast<CsrNumber>(reg);
    const auto csr = hart_.csRegs().findCsr(num);
    // if (csr and csr->isImplemented())
    if (csr)  // to generate exception, tests will try with unimplemented csr
      csrs.enu(std::string(csr->getName()), uint32_t(num));
  }

  // generate enum for rounding mode
  Enum rms;
  magic_enum::enum_for_each<RoundingMode>([&rms] (auto val) {
      constexpr RoundingMode rm = val;
      if (rm != RoundingMode::Invalid1 and rm != RoundingMode::Invalid2)
        rms.enu(std::string(magic_enum::enum_name(rm)), unsigned(rm));
  });

  InstTable table;
  for (auto& entry : table.getInstVec()) {

    Inst inst;
    inst.id = uint64_t(entry.instId());
    inst.format = std::string(magic_enum::enum_name(entry.format()));
    inst.ext = (entry.isCompressed()) ? std::string(magic_enum::enum_name(RvExtension::C)) : std::string(magic_enum::enum_name(entry.extension()));
    for (unsigned i = 0; i < 4; i++) {
      Inst::Operand op;
      op.pOperand = Point(uint32_t(Point::Op0) + i);
      op.type = entry.ithOperandType(i);
      op.mode = entry.ithOperandMode(i);

      op.pValue = Point(uint32_t(Point::Op0Val) + i);
      op.value = Attribute(8*sizeof(URV));

      if (entry.ithOperandType(i) != OperandType::None) {
        std::bitset<32> bits;
        bits = entry.ithOperandMask(i);

        if (not bits.count())
          continue;

        if (entry.ithOperandType(i) == OperandType::CsReg)
          op.operand = csrs;
        else if (entry.ithOperandType(i) == OperandType::Imm) {
          op.operand = Attribute(0);
          op.value = Attribute(bits.count());
        }
        else
          op.operand = Attribute(bits.count());

        inst.operands.push_back(op);
      }
    }

    if (entry.hasRoundingMode())
      inst.operands.push_back({Point::Rm, rms, OperandType::Imm, OperandMode::None, Point::Undefined, Attribute()});
    if (entry.isBranch())
      inst.extra.push_back(std::make_pair<Point, std::variant<Attribute, Enum>>(Point::BrTaken, Attribute(1)));
    insts.emplace_back(entry.name(), inst);
  }
}


template <typename URV>
void
Info<URV>::addCsrs(csrBins& csrs) const
{
  for (uint32_t reg = 0; reg < uint32_t(CsrNumber::MAX_CSR_); ++reg) {
    CsrNumber num = static_cast<CsrNumber>(reg);
    const auto csr = hart_.csRegs().findCsr(num);
    
    if (csr) {
      const auto fields = csr->fields();
      if (fields.size() > 0) { // defined fields?
        Csr pl;
        pl.num = uint32_t(num);
        for (const auto& field : fields) {
          else if (csr->getNumber() == CsrNumber::VTYPE and field.field == "LMUL") {
            Enum e;
            magic_enum::enum_for_each<GroupMultiplier>([&e] (auto val) {
              constexpr GroupMultiplier lmul = val;
              e.enu(std::string(magic_enum::enum_name(lmul)), unsigned(lmul));
            });
            pl.field(ArchCov::Csr::Field{field.field, field.width, e});
          }
          else if (csr->getNumber() == CsrNumber::VTYPE and field.field == "SEW") {
            Enum e;
            magic_enum::enum_for_each<ElementWidth>([&e] (auto val) {
              constexpr ElementWidth sew = val;
              e.enu(std::string(magic_enum::enum_name(sew)), unsigned(sew));
            });
            pl.field(ArchCov::Csr::Field{field.field, field.width, e});
          }
          else
            pl.field(ArchCov::Csr::Field{field.field, field.width, {}});
        }
        csrs.emplace_back(csr->getName(), pl);
      }
    }
  }
}

template <typename URV>
template <Point p>
void
Info<URV>::addPrivilegeMode(enumBins& enums) const 
{
  Enum bins;
  magic_enum::enum_for_each<PrivilegeMode>([&bins] (auto val) {
    constexpr PrivilegeMode mode = val;
    bins.enu(std::string(magic_enum::enum_name(mode)), unsigned(mode));
  );
  enums.emplace_back(std::string(magic_enum::enum_name(p)), bins);
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
    f.field({"v", uint32_t(bits.count()), {}});
    bits = pte.read();
    f.field({"r", uint32_t(bits.count()), {}});
    bits = pte.write();
    f.field({"w", uint32_t(bits.count()), {}});
    bits = pte.exec();
    f.field({"x", uint32_t(bits.count()), {}});
    bits = pte.user();
    f.field({"u", uint32_t(bits.count()), {}});
    bits = pte.global();
    f.field({"g", uint32_t(bits.count()), {}});
    bits = pte.accessed();
    f.field({"a", uint32_t(bits.count()), {}});
    bits = pte.dirty();
    f.field({"d", uint32_t(bits.count()), {}});
    bits = pte.rsw();
    f.field({"rsw", uint32_t(bits.count()), {}});
    bits = pte.ppn();
    f.field({"ppn", uint32_t(bits.count()), {}});
    bits = pte.reserved(false);
    f.field({"res", uint32_t(bits.count()), {}});
    bits = pte.pbmt();
    f.field({"pbmt", uint32_t(bits.count()), {}});
    bits = pte.hasNapot();
    f.field({"napot", uint32_t(bits.count()), {}});
  }
  else {
    Pte32 pte(~0U);
    std::bitset<32> bits;

    bits = pte.valid();
    f.field({"v", uint32_t(bits.count()), {}});
    bits = pte.read();
    f.field({"r", uint32_t(bits.count()), {}});
    bits = pte.write();
    f.field({"w", uint32_t(bits.count()), {}});
    bits = pte.exec();
    f.field({"x", uint32_t(bits.count()), {}});
    bits = pte.user();
    f.field({"u", uint32_t(bits.count()), {}});
    bits = pte.global();
    f.field({"g", uint32_t(bits.count()), {}});
    bits = pte.accessed();
    f.field({"a", uint32_t(bits.count()), {}});
    bits = pte.dirty();
    f.field({"d", uint32_t(bits.count()), {}});
    bits = pte.rsw();
    f.field({"rsw", uint32_t(bits.count()), {}});
    bits = pte.ppn();
    f.field({"ppn", uint32_t(bits.count()), {}});
    bits = pte.res();
  }
  fields.emplace_back(std::string(magic_enum::enum_name(p)), f, RESOLVE::COALESCE);
}

template <typename URV>
template <Point p>
void
Info<URV>::addPageSize(enumBins& enums) const
{
  Enum bins;
  Pte57 pte(0);

  for (uint32_t level = 0; level < pte.levels(); ++level) {
    std::string sizeStr = VirtMem::pageSize(VirtMem::Mode::Sv57, level);
    bins.enu(sizeStr, level);
  }
  enums.emplace_back(std::string(magic_enum::enum_name(p)), bins);
}

template <typename URV>
void
Info<URV>::addCancelLrCause(enumBins& enums) const
{
  Enum bins;
  magic_enum::enum_for_each<CancelLrCause>([&bins] (auto val) {
    constexpr CancelLrCause cause = val;
    bins.enu(std::string(magic_enum::enum_name(cause)), unsigned(cause));
  });
  enums.emplace_back(std::string(magic_enum::enum_name(Point::CancelLrCause)), bins);
}

template <typename URV>
template <Point p>
void
Info<URV>::addPageCross(attBins& atts) const
{
  Attribute att(1);
  atts.emplace_back(std::string(magic_enum::enum_name(p)), att, RESOLVE::NONE);
}

template <typename URV>
void
Info<URV>::addInterrupt(enumBins& enums) const
{
  Enum bins;
  magic_enum::enum_for_each<InterruptCause>([&bins] (auto val) {
    constexpr InterruptCause cause = val;
    bool disable = false;
    // if (std::string(magic_enum::enum_name(cause)).find("RESERVED") != std::string::npos)
    //   disable = true;
    if (not disable)
      bins.enu(std::string(magic_enum::enum_name(cause)), unsigned(cause));
    if (cause == InterruptCause::MAX_CAUSE)
      disable = true;
  });
  enums.emplace_back(std::string(magic_enum::enum_name(Point::Interrupt)), bins);
}

template <typename URV>
void
Info<URV>::addException(enumBins& enums) const
{
  Enum bins;
  magic_enum::enum_for_each<ExceptionCause>([&bins] (auto val) {
    constexpr ExceptionCause cause = val;
    bool disable = false;
    // if (std::string(magic_enum::enum_name(cause)).find("RESERVED") != std::string::npos)
    //   disable = true;
    if (cause == ExceptionCause::MAX_CAUSE or cause == ExceptionCause::NONE)
      disable = true;

    if (not disable)
      bins.enu(std::string(magic_enum::enum_name(cause)), unsigned(cause));
  });
  enums.emplace_back(std::string(magic_enum::enum_name(Point::Exception)), bins);
}

template <typename URV>
void
Info<URV>::addAtts(attBins& atts) const
{
  atts.emplace_back(std::string(magic_enum::enum_name(Point::HartIndex)),      Attribute(64), RESOLVE::SEPARATE);

  atts.emplace_back(std::string(magic_enum::enum_name(Point::VirtLdStAddr)),   Attribute(64), RESOLVE::SEPARATE);
  atts.emplace_back(std::string(magic_enum::enum_name(Point::PhysLdStAddr)),   Attribute(64), RESOLVE::SEPARATE);
  atts.emplace_back(std::string(magic_enum::enum_name(Point::LastStoreValue)), Attribute(64), RESOLVE::SEPARATE);

  atts.emplace_back(std::string(magic_enum::enum_name(Point::VirtPc)),         Attribute(64), RESOLVE::NONE);
  atts.emplace_back(std::string(magic_enum::enum_name(Point::PhysPc)),         Attribute(64), RESOLVE::NONE);
  atts.emplace_back(std::string(magic_enum::enum_name(Point::NextVirtPc)),     Attribute(64), RESOLVE::NONE);

  atts.emplace_back(std::string(magic_enum::enum_name(Point::LdStMisal)),       Attribute(1),  RESOLVE::NONE);
  atts.emplace_back(std::string(magic_enum::enum_name(Point::VirtualMode)),     Attribute(1),  RESOLVE::NONE);
  atts.emplace_back(std::string(magic_enum::enum_name(Point::NextVirtualMode)), Attribute(1),  RESOLVE::NONE);
  atts.emplace_back(std::string(magic_enum::enum_name(Point::DebugMode)),       Attribute(1),  RESOLVE::NONE);
  atts.emplace_back(std::string(magic_enum::enum_name(Point::NextDebugMode)),   Attribute(1),  RESOLVE::NONE);
  atts.emplace_back(std::string(magic_enum::enum_name(Point::ValidLR)),         Attribute(1),  RESOLVE::NONE);
  atts.emplace_back(std::string(magic_enum::enum_name(Point::NumVectorPagesAccessed)), Attribute(64), RESOLVE::NONE);

  atts.emplace_back(std::string(magic_enum::enum_name(Point::DPmaMultihit)), Attribute(1), RESOLVE::NONE);
  atts.emplace_back(std::string(magic_enum::enum_name(Point::FPmaMultihit)), Attribute(1), RESOLVE::NONE);
  atts.emplace_back(std::string(magic_enum::enum_name(Point::DPmpMultihit)), Attribute(1), RESOLVE::NONE);
  atts.emplace_back(std::string(magic_enum::enum_name(Point::FPmpMultihit)), Attribute(1), RESOLVE::NONE);

  atts.emplace_back(std::string(magic_enum::enum_name(Point::DPmpIndex)), Attribute(64), RESOLVE::NONE);
  atts.emplace_back(std::string(magic_enum::enum_name(Point::FPmpIndex)), Attribute(64), RESOLVE::NONE);
  atts.emplace_back(std::string(magic_enum::enum_name(Point::FPmpCrossingIndex)), Attribute(64), RESOLVE::NONE);
  atts.emplace_back(std::string(magic_enum::enum_name(Point::DPmpCrossingIndex)), Attribute(64), RESOLVE::NONE);

  atts.emplace_back(std::string(magic_enum::enum_name(Point::DGPA)),               Attribute(64), RESOLVE::NONE);
  atts.emplace_back(std::string(magic_enum::enum_name(Point::DGPA_GStageLevel1)),  Attribute(64), RESOLVE::NONE);
  atts.emplace_back(std::string(magic_enum::enum_name(Point::DGPA_GStageLevel2)),  Attribute(64), RESOLVE::NONE);
  atts.emplace_back(std::string(magic_enum::enum_name(Point::DGPA_GStageLevel3)),  Attribute(64), RESOLVE::NONE);
  atts.emplace_back(std::string(magic_enum::enum_name(Point::DGPA_GStageLevel4)),  Attribute(64), RESOLVE::NONE);
  atts.emplace_back(std::string(magic_enum::enum_name(Point::DGPA_GStageLevel5)),  Attribute(64), RESOLVE::NONE);

  atts.emplace_back(std::string(magic_enum::enum_name(Point::FGPA)),               Attribute(64), RESOLVE::NONE);
  atts.emplace_back(std::string(magic_enum::enum_name(Point::FGPA_GStageLevel1)),  Attribute(64), RESOLVE::NONE);
  atts.emplace_back(std::string(magic_enum::enum_name(Point::FGPA_GStageLevel2)),  Attribute(64), RESOLVE::NONE);
  atts.emplace_back(std::string(magic_enum::enum_name(Point::FGPA_GStageLevel3)),  Attribute(64), RESOLVE::NONE);
  atts.emplace_back(std::string(magic_enum::enum_name(Point::FGPA_GStageLevel4)),  Attribute(64), RESOLVE::NONE);
  atts.emplace_back(std::string(magic_enum::enum_name(Point::FGPA_GStageLevel5)),  Attribute(64), RESOLVE::NONE);
  atts.emplace_back(std::string(magic_enum::enum_name(Point::Trigger)),            Attribute(64), RESOLVE::NONE);
  atts.emplace_back(std::string(magic_enum::enum_name(Point::TriggerHitVec)),      Attribute(64), RESOLVE::NONE);
  atts.emplace_back(std::string(magic_enum::enum_name(Point::FPmaFault)),          Attribute(64), RESOLVE::NONE);
  atts.emplace_back(std::string(magic_enum::enum_name(Point::DPmaFault)),          Attribute(64), RESOLVE::NONE);
  atts.emplace_back(std::string(magic_enum::enum_name(Point::FPtwFaultIsLeaf)),    Attribute(1),  RESOLVE::NONE);
  atts.emplace_back(std::string(magic_enum::enum_name(Point::DPtwFaultIsLeaf)),    Attribute(1),  RESOLVE::NONE);
  atts.emplace_back(std::string(magic_enum::enum_name(Point::FPtwFaultLevel)),     Attribute(64), RESOLVE::NONE);
  atts.emplace_back(std::string(magic_enum::enum_name(Point::DPtwFaultLevel)),     Attribute(64), RESOLVE::NONE);
}

template <typename URV>
void
Info<URV>::addPmas(fieldsBins& fields) const
{
  Pma p_(Pma::Attrib(~0U));// Placeholder for now
  Fields f;
  f.field({"attrib", 64, {}});
  fields.emplace_back(std::string(magic_enum::enum_name(Point::DPma)),              f, RESOLVE::NONE);
  fields.emplace_back(std::string(magic_enum::enum_name(Point::FPma)),              f, RESOLVE::NONE);
  fields.emplace_back(std::string(magic_enum::enum_name(Point::DPma_GStageLevel1)), f, RESOLVE::NONE);
  fields.emplace_back(std::string(magic_enum::enum_name(Point::FPma_GStageLevel1)), f, RESOLVE::NONE);
  fields.emplace_back(std::string(magic_enum::enum_name(Point::DPma_GStageLevel2)), f, RESOLVE::NONE);
  fields.emplace_back(std::string(magic_enum::enum_name(Point::FPma_GStageLevel2)), f, RESOLVE::NONE);
  fields.emplace_back(std::string(magic_enum::enum_name(Point::DPma_GStageLevel3)), f, RESOLVE::NONE);
  fields.emplace_back(std::string(magic_enum::enum_name(Point::FPma_GStageLevel3)), f, RESOLVE::NONE);
  fields.emplace_back(std::string(magic_enum::enum_name(Point::DPma_GStageLevel4)), f, RESOLVE::NONE);
  fields.emplace_back(std::string(magic_enum::enum_name(Point::FPma_GStageLevel4)), f, RESOLVE::NONE);
  fields.emplace_back(std::string(magic_enum::enum_name(Point::DPma_GStageLevel5)), f, RESOLVE::NONE);
  fields.emplace_back(std::string(magic_enum::enum_name(Point::FPma_GStageLevel5)), f, RESOLVE::NONE);

  fields.emplace_back(std::string(magic_enum::enum_name(Point::FPmaPtw)),           f, RESOLVE::NONE);
  fields.emplace_back(std::string(magic_enum::enum_name(Point::DPmaPtw)),           f, RESOLVE::NONE);
  fields.emplace_back(std::string(magic_enum::enum_name(Point::FPmaCrossing)),      f, RESOLVE::NONE);
  fields.emplace_back(std::string(magic_enum::enum_name(Point::DPmaCrossing)),      f, RESOLVE::NONE);
  fields.emplace_back(std::string(magic_enum::enum_name(Point::FPmaRoot)),              f, RESOLVE::NONE);
  fields.emplace_back(std::string(magic_enum::enum_name(Point::DPmaRoot)),              f, RESOLVE::NONE);

  fields.emplace_back(std::string(magic_enum::enum_name(Point::DPmaLeaf)),              f, RESOLVE::NONE);
  fields.emplace_back(std::string(magic_enum::enum_name(Point::FPmaLeaf)),              f, RESOLVE::NONE);
  fields.emplace_back(std::string(magic_enum::enum_name(Point::DPmaLeaf_GStageLevel1)), f, RESOLVE::NONE);
  fields.emplace_back(std::string(magic_enum::enum_name(Point::FPmaLeaf_GStageLevel1)), f, RESOLVE::NONE);
  fields.emplace_back(std::string(magic_enum::enum_name(Point::DPmaLeaf_GStageLevel2)), f, RESOLVE::NONE);
  fields.emplace_back(std::string(magic_enum::enum_name(Point::FPmaLeaf_GStageLevel2)), f, RESOLVE::NONE);
  fields.emplace_back(std::string(magic_enum::enum_name(Point::DPmaLeaf_GStageLevel3)), f, RESOLVE::NONE);
  fields.emplace_back(std::string(magic_enum::enum_name(Point::FPmaLeaf_GStageLevel3)), f, RESOLVE::NONE);
  fields.emplace_back(std::string(magic_enum::enum_name(Point::DPmaLeaf_GStageLevel4)), f, RESOLVE::NONE);
  fields.emplace_back(std::string(magic_enum::enum_name(Point::FPmaLeaf_GStageLevel4)), f, RESOLVE::NONE);
  fields.emplace_back(std::string(magic_enum::enum_name(Point::DPmaLeaf_GStageLevel5)), f, RESOLVE::NONE);
  fields.emplace_back(std::string(magic_enum::enum_name(Point::FPmaLeaf_GStageLevel5)), f, RESOLVE::NONE);
}

template <typename URV>
void
Info<URV>::addPmps(fieldsBins& fields) const
{
  // Placeholder for now
  Fields f;
  f.field({"attrib", 64, {}});
  fields.emplace_back(std::string(magic_enum::enum_name(Point::DPmp)),              f, RESOLVE::NONE);
  fields.emplace_back(std::string(magic_enum::enum_name(Point::FPmp)),              f, RESOLVE::NONE);
  fields.emplace_back(std::string(magic_enum::enum_name(Point::DPmp_GStageLevel1)), f, RESOLVE::NONE);
  fields.emplace_back(std::string(magic_enum::enum_name(Point::FPmp_GStageLevel1)), f, RESOLVE::NONE);
  fields.emplace_back(std::string(magic_enum::enum_name(Point::DPmp_GStageLevel2)), f, RESOLVE::NONE);
  fields.emplace_back(std::string(magic_enum::enum_name(Point::FPmp_GStageLevel2)), f, RESOLVE::NONE);
  fields.emplace_back(std::string(magic_enum::enum_name(Point::DPmp_GStageLevel3)), f, RESOLVE::NONE);
  fields.emplace_back(std::string(magic_enum::enum_name(Point::FPmp_GStageLevel3)), f, RESOLVE::NONE);
  fields.emplace_back(std::string(magic_enum::enum_name(Point::DPmp_GStageLevel4)), f, RESOLVE::NONE);
  fields.emplace_back(std::string(magic_enum::enum_name(Point::FPmp_GStageLevel4)), f, RESOLVE::NONE);
  fields.emplace_back(std::string(magic_enum::enum_name(Point::DPmp_GStageLevel5)), f, RESOLVE::NONE);
  fields.emplace_back(std::string(magic_enum::enum_name(Point::FPmp_GStageLevel5)), f, RESOLVE::NONE);

  fields.emplace_back(std::string(magic_enum::enum_name(Point::FPmpPtw)),           f, RESOLVE::NONE);
  fields.emplace_back(std::string(magic_enum::enum_name(Point::DPmpPtw)),           f, RESOLVE::NONE);
  fields.emplace_back(std::string(magic_enum::enum_name(Point::FPmpCrossing)),      f, RESOLVE::NONE);
  fields.emplace_back(std::string(magic_enum::enum_name(Point::DPmpCrossing)),      f, RESOLVE::NONE);

  fields.emplace_back(std::string(magic_enum::enum_name(Point::DPmpLeaf)),              f, RESOLVE::NONE);
  fields.emplace_back(std::string(magic_enum::enum_name(Point::FPmpLeaf)),              f, RESOLVE::NONE);
  fields.emplace_back(std::string(magic_enum::enum_name(Point::DPmpLeaf_GStageLevel1)), f, RESOLVE::NONE);
  fields.emplace_back(std::string(magic_enum::enum_name(Point::FPmpLeaf_GStageLevel1)), f, RESOLVE::NONE);
  fields.emplace_back(std::string(magic_enum::enum_name(Point::DPmpLeaf_GStageLevel2)), f, RESOLVE::NONE);
  fields.emplace_back(std::string(magic_enum::enum_name(Point::FPmpLeaf_GStageLevel2)), f, RESOLVE::NONE);
  fields.emplace_back(std::string(magic_enum::enum_name(Point::DPmpLeaf_GStageLevel3)), f, RESOLVE::NONE);
  fields.emplace_back(std::string(magic_enum::enum_name(Point::FPmpLeaf_GStageLevel3)), f, RESOLVE::NONE);
  fields.emplace_back(std::string(magic_enum::enum_name(Point::DPmpLeaf_GStageLevel4)), f, RESOLVE::NONE);
  fields.emplace_back(std::string(magic_enum::enum_name(Point::FPmpLeaf_GStageLevel4)), f, RESOLVE::NONE);
  fields.emplace_back(std::string(magic_enum::enum_name(Point::DPmpLeaf_GStageLevel5)), f, RESOLVE::NONE);
  fields.emplace_back(std::string(magic_enum::enum_name(Point::FPmpLeaf_GStageLevel5)), f, RESOLVE::NONE);
}
template class ArchCov::Info<uint32_t>;
template class ArchCov::Info<uint64_t>;
