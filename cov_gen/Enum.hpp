#pragma once

#include <string>

namespace ArchCov {
  class Enum {
    public:
      void enu(std::string s, unsigned v)
      { descriptor[std::move(s)] = v; }

      void clear()
      { descriptor.clear(); }

      std::map<std::string, unsigned> descriptor;
  };
}
