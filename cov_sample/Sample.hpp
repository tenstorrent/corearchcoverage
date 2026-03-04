#pragma once

#include <vector>
#include "Points.hpp"

namespace ArchCov
{
  typedef struct arch
  {
    typedef std::pair<uint64_t, uint64_t> entry;
    std::vector<entry> entries_;

    void addEntry(Point p, uint64_t val)
    { entries_.emplace_back(uint64_t(p), val); }

  } arch_t;
}
