#pragma once

#include<string>
#include<map>

namespace ArchCov {
    typedef std::map<std::string, uint64_t> enum_val_t;
    class Descriptor {
    public:
      std::string name;
      Descriptor() : name("") {}
      Descriptor(std::string name) : name(name) {}
    };

    class Attribute : public Descriptor {
    public:
      Attribute() : Descriptor(), width(0) {};
      Attribute(std::string name, uint64_t width) : Descriptor(name), width(width) {}
      uint64_t width;
    };
  
    class Enum : public Descriptor {
    public:
        enum_val_t enum_values;
        Enum() : Descriptor(), enum_values() {}
        Enum(std::string name) : Descriptor(name), enum_values() {}
        Enum(std::string name, enum_val_t enum_values) : Descriptor(name), enum_values(enum_values) {}
        void add_enum_value(std::string name, uint64_t value) { enum_values[name] = value; }
        void clear() { enum_values.clear(); }
    };
}
