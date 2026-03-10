#pragma once

#include <string>

namespace ArchCov {
    /**
     * @brief Base descriptor class
     */
     class Descriptor {
        public:
            Descriptor() : name_("") {}
    
            explicit Descriptor(const std::string& name) : name_(name) {}
    
            virtual ~Descriptor() = default;
    
            // Getters
            const std::string& getName() const { return name_; }
    
            // Setters
            void setName(const std::string& name) { name_ = name; }
    
        protected:
            std::string name_;
        };
}