#pragma once

#include "common/Points.hpp"
#include "common/types.hpp"
// #include "Inst.hpp"
// #include "Fields.hpp"
#include "magic_enum/magic_enum.hpp"
#include "trapEnums.hpp"
#include "Hart.hpp"

namespace ArchCov
{

  // only instruction info is special
  enum class Group { Inst, Csr, Custom };

  /// Architectural coverage definition. Should be provided as a json file.
  template <typename URV>
  class Info
  {
  public:

    Info(WdRiscv::Hart<URV>& hart);

    enum RESOLVE : uint64_t { COALESCE, SEPARATE, NONE };
    
    typedef typename std::vector<Enum> enumBins;

    typedef typename std::vector<Attribute> attBins;

    typedef typename std::vector<Fields> fieldsBins;

    typedef typename std::vector<Csr> csrBins;

    typedef typename std::vector<Inst> instBins;

    void dumpInfo()
    {
      enumBins enums;
      attBins atts;
      fieldsBins fields;
      instBins insts;
      csrBins csrs;
      points(enums, atts, fields, insts, csrs); 
    }

    void points(enumBins& enums, attBins& atts, fieldsBins& fields, instBins& insts, csrBins& csrs) const; //instBins& insts, csrBins& csrs) const;

    Group getGroup(Point p) const
    {
      if (p >= Point::InstId and p <= Point::Op3)
        return Group::Inst;
      if (p >= Point::CsrNum and p <= Point::CsrValue)
        return Group::Csr;
      return Group::Custom;
    }

    Point getInstPoint() const
    { return Point::Inst; }

  protected:

    void addInsts(attBins& atts, instBins& insts) const;

    void addCsrs(csrBins& csr) const;
    
    template <Point p>
    void addPrivilegeMode(enumBins& enums) const;

    template <Point p>
    void addPtes(fieldsBins& fields) const;

    template <Point p>
    void addPageSize(enumBins& enums) const;

    template <Point p>
    void addPageCross(attBins& atts) const;

    void addInterrupt(enumBins& enums) const;

    void addException(enumBins& enums) const;

    void addAtts(attBins& atts) const;

    // void addPmas(fieldsBins& fields) const;

    // void addPmps(fieldsBins& fields) const;

    void addCancelLrCause(enumBins& enums) const;

    WdRiscv::Hart<URV>& hart_;
    static constexpr bool isRv64_ = sizeof(URV) == 8;
  };
}
