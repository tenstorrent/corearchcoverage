// SPDX-FileCopyrightText: © 2026 Tenstorrent AI ULC
// SPDX-License-Identifier: Apache-2.0
#pragma once

#include <string>

namespace ArchCov {
     class Descriptor {
        public:
            Descriptor() : name_("") {}
    
            explicit Descriptor(const std::string& name) : name_(name) {}
    
            virtual ~Descriptor() = default;
    
            const std::string& getName() const { return name_; }
    
            void setName(const std::string& name) { name_ = name; }
    
        protected:
            std::string name_;
        };
}