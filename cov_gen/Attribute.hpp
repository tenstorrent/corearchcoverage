#pragma once

#include <string>

namespace ArchCov {
  class Attribute {
    public:
      Attribute() : width(0) {};

      Attribute(int width)
      { this->width = width; }
      int width;
  };
}
