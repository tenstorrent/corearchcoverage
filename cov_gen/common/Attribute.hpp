#pragma once
#include <string>
#include <cstdint>
#include "Descriptor.hpp"

namespace ArchCov {
    /**
     * @brief Attribute descriptor with width
     */
    class Attribute : public Descriptor {
        public:
            Attribute() : Descriptor(), width_(0) {}
    
            Attribute(const std::string& name, uint64_t width)
                : Descriptor(name)
                , width_(width) {}
    
            Attribute(uint64_t width)
                : Descriptor()
                , width_(width) {}
    
            // Getters
            uint64_t getWidth() const { return width_; }
    
            // Setters
            void setWidth(uint64_t width) { width_ = width; }
    
            std::string toSvAttribute(std::string attr_name="") const {
                if(width_ > 1) {
                    if(attr_name == "") {
                        return "logic [" + std::to_string(width_ - 1) + ":0] " + getName() + ";";
                    } else {
                        return "logic [" + std::to_string(width_ - 1) + ":0] " + attr_name + ";";
                    }
                } else {
                    if(attr_name == "") {
                        return "logic " + getName() + ";";
                    } else {
                        return "logic " + attr_name + ";";
                    }
                }
            }
    
        private:
            uint64_t width_;
        };
}