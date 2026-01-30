#pragma once

#include "Attribute.hpp"
#include "Enum.hpp"
#include "Points.hpp"
#include "InstEntry.hpp"
#include <string>
#include <utility>
#include <variant>
#include <vector>

namespace ArchCov {
  class Inst {
    public:
      struct Operand {
        Point pOperand;
        std::variant<Attribute, Enum> operand;
        WdRiscv::OperandType type;
        WdRiscv::OperandMode mode;

        Point pValue;
        Attribute value;
      };

      uint64_t id = 0;
      std::string format;
      std::string ext;
      std::vector<Operand> operands;
      std::vector<std::pair<Point, std::variant<Attribute, Enum>>> extra;
  };
}
