#pragma once

#include "common_types.h"

struct Operand {
    Point pOperand;
    operand_t operand;
    WdRiscv::OperandType type;
    WdRiscv::OperandMode mode;

    Point     pValue;
    Attribute value;
};