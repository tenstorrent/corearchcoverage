#pragma once

#include <string> 
#include <map> 
#include "Descriptor.hpp"
#include "utils.hpp"
#include <cstdint>

namespace ArchCov {
    
    // Type aliases
    using EnumValueMap = std::map<std::string, uint64_t>;

    /**
     * @brief Enumeration descriptor with name-value pairs
     */
    class Enum : public Descriptor {
    public:
        Enum() : Descriptor(), enumValues_() {}
    
        explicit Enum(const std::string& name)
            : Descriptor(name)
            , enumValues_() {}
    
        Enum(const std::string& name, const EnumValueMap& enumValues)
            : Descriptor(name)
            , enumValues_(enumValues) {}
    
        // Getters
        const EnumValueMap& getEnumValues() const { return enumValues_; }
    
        // Modifiers
        void addEnumValue(const std::string& name, uint64_t value) {
            enumValues_[name] = value;
        }
    
        void clear() { enumValues_.clear(); }
    
        bool contains(const std::string& name) const {
            return enumValues_.find(name) != enumValues_.end();
        }
    
        size_t size() const { return enumValues_.size(); }
    
        // Comparison operators (by enum name, alphabetical order)
        bool operator<(const Enum& other) const { return getName() < other.getName(); }
        bool operator<=(const Enum& other) const { return getName() <= other.getName(); }
        bool operator>(const Enum& other) const { return getName() > other.getName(); }
        bool operator>=(const Enum& other) const { return getName() >= other.getName(); }
        bool operator==(const Enum& other) const { return getName() == other.getName(); }
        bool operator!=(const Enum& other) const { return getName() != other.getName(); }
    
        std::string toSvEnum(std::string enum_name="") const {
            std::string enumAsString = "typedef enum logic [63:0] {\n";
            for(auto val : enumValues_) {
                if(enum_name == "") {
                    enumAsString += "\t\t" +  convert_to_uppercase(prefix_ + getName() + "_" + val.first) + " = 64'd" + std::to_string(val.second) + ",\n";
                } else {
                    enumAsString += "\t\t" +  convert_to_uppercase(enum_name + "_" + val.first) + " = 64'd" + std::to_string(val.second) + ",\n";
                }
            }
            if(enum_name == "") {
                enumAsString += "\t} " + prefix_ + getName() + "_e;\n";
                enumAsString += "\t" + prefix_ + getName() + "_e " + convert_to_lowercase(prefix_ + getName()) + "_var;\n";
            } else {
                enumAsString += "\t} " + enum_name + "_e;\n";
                enumAsString += "\t" + enum_name + "_e " + convert_to_lowercase(enum_name) + "_var;\n";
            }
            return enumAsString;
        }
    
        void setPrefix(const std::string& prefix) {
            prefix_ = prefix;
        }
    
        bool compareEnums(const Enum& other) const {
            if(enumValues_.size() != other.enumValues_.size()) {
                return false;
            }
            for(auto val : enumValues_) {
                if(other.enumValues_.find(val.first) == other.enumValues_.end()) {
                    return false;
                }
            }
            return true;
        }
    
    private:
        EnumValueMap enumValues_;
        std::string prefix_ = "";
    };

}
