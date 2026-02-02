#pragma once

#include "common_types.h"
#include <string>
#include <utility>
#include <variant>
#include <vector>

namespace ArchCov {
  class Inst {
    public:
      uint64_t id = 0;
      std::string format;
      std::string ext;
      vec_of_operands_t operands;
      std::vector<std::pair<Point, operand_t>> extra;
  };
}
