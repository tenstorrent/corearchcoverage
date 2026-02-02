#pragma once

#include<string>
#include<vector>
#include<cstdint>
#include<map>

#include "Enum.hpp"
#include "Attribute.hpp"
#include "Operand.hpp"
#include "Points.hpp"

typedef std::pair<std::string, uint64_t> pair_t;
typedef std::map<std::string, uint64_t> uint64_map_t;

typedef std::vector<pair_t> vec_t;
typedef std::map<std::string, vec_t> vec_map_t;

typedef std::variant<Attribute, Enum> operand_t;
typedef std::vector<Operand> vec_of_operands_t;
