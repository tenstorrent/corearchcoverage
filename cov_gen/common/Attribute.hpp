#pragma once

namespace ArchCov {
  class Attribute {
    public:
      Attribute() : width(0) {};

      Attribute(uint64_t width) : width(width) {}
      uint64_t width;
  };
}
