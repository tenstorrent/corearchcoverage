#pragma once

#include "common_types.h"
#include "Enum.hpp"

namespace ArchCov {
  class Fields {
    public:
      struct Field
      {
        std::string name;
        uint64_t width;
        Enum descriptors;
      };

      void field(struct Field f)
      { fields.push_back(f); }

      void clear()
      { fields.clear(); }

      std::vector<struct Field> fields;
  };

  class Csr : public Fields {
    public:
      uint64_t num;
  };
}
