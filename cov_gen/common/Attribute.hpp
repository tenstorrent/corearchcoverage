// SPDX-FileCopyrightText: © 2026 Tenstorrent AI ULC
// SPDX-License-Identifier: Apache-2.0
#pragma once
#include <string>
#include <cstdint>
#include "Descriptor.hpp"

namespace ArchCov {

    class Attribute : public Descriptor {
        public:
            Attribute() : Descriptor(), width_(0) {}
    
            Attribute(const std::string& name, uint64_t width)
                : Descriptor(name)
                , width_(width) {}
    
            Attribute(uint64_t width)
                : Descriptor()
                , width_(width) {}
    
            uint64_t getWidth() const { return width_; }
    
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