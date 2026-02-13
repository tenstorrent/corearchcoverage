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
#include "common/types.hpp"

using namespace ArchCov;
using namespace WdRiscv;

template <typename URV>
Info<URV>::Info(Hart<URV>& hart)
  : hart_(hart)
{

}

template <typename URV>
void
Info<URV>::points(enumBins& enums, attBins& atts, fieldsBins& fields, csrBins& csrs) const //instBins& insts, csrBins& csrs) const
{
  enums.clear();
  atts.clear();
  fields.clear();
  // insts.clear();
  csrs.clear();

  // addInsts(atts, insts);
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
  //addPmas(fields);
  //addPmps(fields);
  addAtts(atts);
}


// template <typename URV>
// void
// Info<URV>::addInsts(attBins& atts, instBins& insts) const
// {
//   atts.emplace_back(std::string(magic_enum::enum_name(Point::Inst)), Attribute(32), RESOLVE::NONE);

//   // generate Enum for csr
//   Enum csrs;
//   for (uint32_t reg = 0; reg < uint32_t(CsrNumber::MAX_CSR_); ++reg) {
//     CsrNumber num = static_cast<CsrNumber>(reg);
//     const auto csr = hart_.csRegs().findCsr(num);
//     // if (csr and csr->isImplemented())
//     if (csr)  // to generate exception, tests will try with unimplemented csr
//       csrs.enu(std::string(csr->getName()), uint32_t(num));
//   }

//   // generate enum for rounding mode
//   Enum rms;
//   magic_enum::enum_for_each<RoundingMode>([&rms] (auto val) {
//       constexpr RoundingMode rm = val;
//       if (rm != RoundingMode::Invalid1 and rm != RoundingMode::Invalid2)
//         rms.enu(std::string(magic_enum::enum_name(rm)), unsigned(rm));
//   });

//   InstTable table;
//   for (auto& entry : table.getInstVec()) {

//     Inst inst;
//     inst.id = uint64_t(entry.instId());
//     inst.format = std::string(magic_enum::enum_name(entry.format()));
//     inst.ext = (entry.isCompressed()) ? std::string(magic_enum::enum_name(RvExtension::C)) : std::string(magic_enum::enum_name(entry.extension()));
//     for (unsigned i = 0; i < 4; i++) {
//       Inst::Operand op;
//       op.pOperand = Point(uint32_t(Point::Op0) + i);
//       op.type = entry.ithOperandType(i);
//       op.mode = entry.ithOperandMode(i);

//       op.pValue = Point(uint32_t(Point::Op0Val) + i);
//       op.value = Attribute(8*sizeof(URV));

//       if (entry.ithOperandType(i) != OperandType::None) {
//         std::bitset<32> bits;
//         bits = entry.ithOperandMask(i);

//         if (not bits.count())
//           continue;

//         if (entry.ithOperandType(i) == OperandType::CsReg)
//           op.operand = csrs;
//         else if (entry.ithOperandType(i) == OperandType::Imm) {
//           op.operand = Attribute(0);
//           op.value = Attribute(bits.count());
//         }
//         else
//           op.operand = Attribute(bits.count());

//         inst.operands.push_back(op);
//       }
//     }

//     if (entry.hasRoundingMode())
//       inst.operands.push_back({Point::Rm, rms, OperandType::Imm, OperandMode::None, Point::Undefined, Attribute()});
//     if (entry.isBranch())
//       inst.extra.push_back(std::make_pair<Point, std::variant<Attribute, Enum>>(Point::BrTaken, Attribute(1)));
//     insts.emplace_back(entry.name(), inst);
//   }
//}


template <typename URV>
void
Info<URV>::addCsrs(csrBins& csrs) const
{
  for (uint64_t reg = 0; reg < uint64_t(CsrNumber::MAX_CSR_); ++reg) {

    const auto csr = hart_.csRegs().findCsr(static_cast<CsrNumber>(reg));
    if (csr) {
      const auto fields = csr->fields();
      if (fields.size() > 0) { // defined fields?
        Csr pl;
        pl.num = reg;
        pl.setName(std::string(csr->getName()));
        for (const auto& field : fields) {
          // special enums for certain CSR fields
          // if (csr->getNumber() == CsrNumber::SATP and field.field == "MODE") {
          //   Enum e("SATP_MODE");
          //   magic_enum::enum_for_each<VirtMem::Mode>([&e] (auto val) {
          //     constexpr VirtMem::Mode mode = val;
          //     e.addEnumValue(std::string(magic_enum::enum_name(mode)), uint64_t(mode));
          //   });
          //   pl.addField(Field(field.field, e));
          // }
          // else if (csr->getNumber() == CsrNumber::VTYPE and field.field == "LMUL") {
          //   // Enum e;
          //   // magic_enum::enum_for_each<GroupMultiplier>([&e] (auto val) {
          //   //   constexpr GroupMultiplier lmul = val;
          //   //   e.enu(std::string(magic_enum::enum_name(lmul)), unsigned(lmul));
          //   // });
          //   // pl.field(ArchCov::Csr::Field{field.field, field.width, e});
          // }
          // else if (csr->getNumber() == CsrNumber::VTYPE and field.field == "SEW") {
          //   // Enum e;
          //   // magic_enum::enum_for_each<ElementWidth>([&e] (auto val) {
          //   //   constexpr ElementWidth sew = val;
          //   //   e.enu(std::string(magic_enum::enum_name(sew)), unsigned(sew));
          //   // });
          //   // pl.field(ArchCov::Csr::Field{field.field, field.width, e});
          // }
          // else
            pl.addField(Field(field.field, field.width));
        }
        csrs.push_back(pl);
      }
    }
  }
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
  atts.push_back(Attribute(std::string(magic_enum::enum_name(Point::Trigger)), 64));
  atts.push_back(Attribute(std::string(magic_enum::enum_name(Point::TriggerHitVec)), 64));
  atts.push_back(Attribute(std::string(magic_enum::enum_name(Point::FPmaFault)), 64));
  atts.push_back(Attribute(std::string(magic_enum::enum_name(Point::DPmaFault)), 64));
  atts.push_back(Attribute(std::string(magic_enum::enum_name(Point::FPtwFaultIsLeaf)), 1));
  atts.push_back(Attribute(std::string(magic_enum::enum_name(Point::DPtwFaultIsLeaf)), 1));
  atts.push_back(Attribute(std::string(magic_enum::enum_name(Point::FPtwFaultLevel)), 64));
  atts.push_back(Attribute(std::string(magic_enum::enum_name(Point::DPtwFaultLevel)), 64));
}

// template <typename URV>
// void
// Info<URV>::addPmas(fieldsBins& fields) const
// {
//   Pma p_(Pma::Attrib(~0U));// Placeholder for now
//   Fields f;
//   f.field({"attrib", 64, {}});
//   fields.emplace_back(std::string(magic_enum::enum_name(Point::DPma)),              f, RESOLVE::NONE);
//   fields.emplace_back(std::string(magic_enum::enum_name(Point::FPma)),              f, RESOLVE::NONE);
//   fields.emplace_back(std::string(magic_enum::enum_name(Point::DPma_GStageLevel1)), f, RESOLVE::NONE);
//   fields.emplace_back(std::string(magic_enum::enum_name(Point::FPma_GStageLevel1)), f, RESOLVE::NONE);
//   fields.emplace_back(std::string(magic_enum::enum_name(Point::DPma_GStageLevel2)), f, RESOLVE::NONE);
//   fields.emplace_back(std::string(magic_enum::enum_name(Point::FPma_GStageLevel2)), f, RESOLVE::NONE);
//   fields.emplace_back(std::string(magic_enum::enum_name(Point::DPma_GStageLevel3)), f, RESOLVE::NONE);
//   fields.emplace_back(std::string(magic_enum::enum_name(Point::FPma_GStageLevel3)), f, RESOLVE::NONE);
//   fields.emplace_back(std::string(magic_enum::enum_name(Point::DPma_GStageLevel4)), f, RESOLVE::NONE);
//   fields.emplace_back(std::string(magic_enum::enum_name(Point::FPma_GStageLevel4)), f, RESOLVE::NONE);
//   fields.emplace_back(std::string(magic_enum::enum_name(Point::DPma_GStageLevel5)), f, RESOLVE::NONE);
//   fields.emplace_back(std::string(magic_enum::enum_name(Point::FPma_GStageLevel5)), f, RESOLVE::NONE);

//   fields.emplace_back(std::string(magic_enum::enum_name(Point::FPmaPtw)),           f, RESOLVE::NONE);
//   fields.emplace_back(std::string(magic_enum::enum_name(Point::DPmaPtw)),           f, RESOLVE::NONE);
//   fields.emplace_back(std::string(magic_enum::enum_name(Point::FPmaCrossing)),      f, RESOLVE::NONE);
//   fields.emplace_back(std::string(magic_enum::enum_name(Point::DPmaCrossing)),      f, RESOLVE::NONE);
//   fields.emplace_back(std::string(magic_enum::enum_name(Point::FPmaRoot)),              f, RESOLVE::NONE);
//   fields.emplace_back(std::string(magic_enum::enum_name(Point::DPmaRoot)),              f, RESOLVE::NONE);

//   fields.emplace_back(std::string(magic_enum::enum_name(Point::DPmaLeaf)),              f, RESOLVE::NONE);
//   fields.emplace_back(std::string(magic_enum::enum_name(Point::FPmaLeaf)),              f, RESOLVE::NONE);
//   fields.emplace_back(std::string(magic_enum::enum_name(Point::DPmaLeaf_GStageLevel1)), f, RESOLVE::NONE);
//   fields.emplace_back(std::string(magic_enum::enum_name(Point::FPmaLeaf_GStageLevel1)), f, RESOLVE::NONE);
//   fields.emplace_back(std::string(magic_enum::enum_name(Point::DPmaLeaf_GStageLevel2)), f, RESOLVE::NONE);
//   fields.emplace_back(std::string(magic_enum::enum_name(Point::FPmaLeaf_GStageLevel2)), f, RESOLVE::NONE);
//   fields.emplace_back(std::string(magic_enum::enum_name(Point::DPmaLeaf_GStageLevel3)), f, RESOLVE::NONE);
//   fields.emplace_back(std::string(magic_enum::enum_name(Point::FPmaLeaf_GStageLevel3)), f, RESOLVE::NONE);
//   fields.emplace_back(std::string(magic_enum::enum_name(Point::DPmaLeaf_GStageLevel4)), f, RESOLVE::NONE);
//   fields.emplace_back(std::string(magic_enum::enum_name(Point::FPmaLeaf_GStageLevel4)), f, RESOLVE::NONE);
//   fields.emplace_back(std::string(magic_enum::enum_name(Point::DPmaLeaf_GStageLevel5)), f, RESOLVE::NONE);
//   fields.emplace_back(std::string(magic_enum::enum_name(Point::FPmaLeaf_GStageLevel5)), f, RESOLVE::NONE);
// }

// template <typename URV>
// void
// Info<URV>::addPmps(fieldsBins& fields) const
// {
//   // Placeholder for now
//   Fields f;
//   f.field({"attrib", 64, {}});
//   fields.emplace_back(std::string(magic_enum::enum_name(Point::DPmp)),              f, RESOLVE::NONE);
//   fields.emplace_back(std::string(magic_enum::enum_name(Point::FPmp)),              f, RESOLVE::NONE);
//   fields.emplace_back(std::string(magic_enum::enum_name(Point::DPmp_GStageLevel1)), f, RESOLVE::NONE);
//   fields.emplace_back(std::string(magic_enum::enum_name(Point::FPmp_GStageLevel1)), f, RESOLVE::NONE);
//   fields.emplace_back(std::string(magic_enum::enum_name(Point::DPmp_GStageLevel2)), f, RESOLVE::NONE);
//   fields.emplace_back(std::string(magic_enum::enum_name(Point::FPmp_GStageLevel2)), f, RESOLVE::NONE);
//   fields.emplace_back(std::string(magic_enum::enum_name(Point::DPmp_GStageLevel3)), f, RESOLVE::NONE);
//   fields.emplace_back(std::string(magic_enum::enum_name(Point::FPmp_GStageLevel3)), f, RESOLVE::NONE);
//   fields.emplace_back(std::string(magic_enum::enum_name(Point::DPmp_GStageLevel4)), f, RESOLVE::NONE);
//   fields.emplace_back(std::string(magic_enum::enum_name(Point::FPmp_GStageLevel4)), f, RESOLVE::NONE);
//   fields.emplace_back(std::string(magic_enum::enum_name(Point::DPmp_GStageLevel5)), f, RESOLVE::NONE);
//   fields.emplace_back(std::string(magic_enum::enum_name(Point::FPmp_GStageLevel5)), f, RESOLVE::NONE);

//   fields.emplace_back(std::string(magic_enum::enum_name(Point::FPmpPtw)),           f, RESOLVE::NONE);
//   fields.emplace_back(std::string(magic_enum::enum_name(Point::DPmpPtw)),           f, RESOLVE::NONE);
//   fields.emplace_back(std::string(magic_enum::enum_name(Point::FPmpCrossing)),      f, RESOLVE::NONE);
//   fields.emplace_back(std::string(magic_enum::enum_name(Point::DPmpCrossing)),      f, RESOLVE::NONE);

//   fields.emplace_back(std::string(magic_enum::enum_name(Point::DPmpLeaf)),              f, RESOLVE::NONE);
//   fields.emplace_back(std::string(magic_enum::enum_name(Point::FPmpLeaf)),              f, RESOLVE::NONE);
//   fields.emplace_back(std::string(magic_enum::enum_name(Point::DPmpLeaf_GStageLevel1)), f, RESOLVE::NONE);
//   fields.emplace_back(std::string(magic_enum::enum_name(Point::FPmpLeaf_GStageLevel1)), f, RESOLVE::NONE);
//   fields.emplace_back(std::string(magic_enum::enum_name(Point::DPmpLeaf_GStageLevel2)), f, RESOLVE::NONE);
//   fields.emplace_back(std::string(magic_enum::enum_name(Point::FPmpLeaf_GStageLevel2)), f, RESOLVE::NONE);
//   fields.emplace_back(std::string(magic_enum::enum_name(Point::DPmpLeaf_GStageLevel3)), f, RESOLVE::NONE);
//   fields.emplace_back(std::string(magic_enum::enum_name(Point::FPmpLeaf_GStageLevel3)), f, RESOLVE::NONE);
//   fields.emplace_back(std::string(magic_enum::enum_name(Point::DPmpLeaf_GStageLevel4)), f, RESOLVE::NONE);
//   fields.emplace_back(std::string(magic_enum::enum_name(Point::FPmpLeaf_GStageLevel4)), f, RESOLVE::NONE);
//   fields.emplace_back(std::string(magic_enum::enum_name(Point::DPmpLeaf_GStageLevel5)), f, RESOLVE::NONE);
//   fields.emplace_back(std::string(magic_enum::enum_name(Point::FPmpLeaf_GStageLevel5)), f, RESOLVE::NONE);
//}

template class ArchCov::Info<uint32_t>;
template class ArchCov::Info<uint64_t>;
