#pragma once

#include <string> 
#include <map> 

namespace ArchCov {
  class Enum {
    public:
      void enu(std::string s, uint64_t v)
      { descriptor[s] = v; }

      void clear()
      { descriptor.clear(); }

      std::map<std::string, uint64_t> descriptor;
  };
}
