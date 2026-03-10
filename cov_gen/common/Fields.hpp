#pragma once

#include "Descriptor.hpp"
#include "Enum.hpp"
#include "Attribute.hpp"
#include <variant>
#include <string>
#include <cstdint>
#include <vector>
#include <bitset>

namespace ArchCov {

    /**
     * @brief Field descriptor that can contain either an Attribute or an Enum
     */
    class Field : public Descriptor
    {
    public:
        // Constructors
        Field() : Descriptor() {}

        Field(const std::string& name, const Attribute& attr)
            : Descriptor(name)
            , value_(attr) {}

        Field(const std::string& name, const Enum& enum_)
            : Descriptor(name)
            , value_(enum_) {}

        Field(const std::string& name, uint64_t width)
            : Descriptor(name)
            , value_(Attribute(name, width)) {}

        // Type checking
        bool isAttribute() const {
            return std::holds_alternative<Attribute>(value_);
        }

        bool isEnum() const {
            return std::holds_alternative<Enum>(value_);
        }

        // Accessors for Attribute
        Attribute& getAttribute() {
            return std::get<Attribute>(value_);
        }

        const Attribute& getAttribute() const {
            return std::get<Attribute>(value_);
        }

        // Accessors for Enum
        Enum& getEnum() {
            return std::get<Enum>(value_);
        }

        const Enum& getEnum() const {
            return std::get<Enum>(value_);
        }

        // Convenience methods
        uint64_t getWidth() const {
            if (isAttribute()) {
                return getAttribute().getWidth();
            }
            return 0; 
        }

        void setWidth(uint64_t width) {
            if (isAttribute()) {
                getAttribute().setWidth(width);
            } else {
                value_ = Attribute(getName(), width);
            }
        }

        // Get the underlying descriptor (for generic access)
        const std::variant<Attribute, Enum>& getValue() const {
            return value_;
        }

        std::variant<Attribute, Enum>& getValue() {
            return value_;
        }

        bool operator<(const Field& other) const { return getName() < other.getName(); }
        bool operator<=(const Field& other) const { return getName() <= other.getName(); }
        bool operator>(const Field& other) const { return getName() > other.getName(); }
        bool operator>=(const Field& other) const { return getName() >= other.getName(); }
        bool operator==(const Field& other) const { return getName() == other.getName(); }
        bool operator!=(const Field& other) const { return getName() != other.getName(); }


    private:
        std::variant<Attribute, Enum> value_;
    };

    class Fields {
    public:
        void addField(const Field& f) {
            fields_.push_back(f);
        }

        void clearFields() {
            fields_.clear();
        }
    
        std::vector<Field> fields_;
        std::string name_ = "";
        uint64_t totalWidth_ = 0;

        void setName(const std::string& name) {
            name_ = name;
        }

        const std::string& getName() const {
            return name_;
        }

        uint64_t getTotalWidth() const {
            return totalWidth_;
        }

        void setTotalWidth(uint64_t width) {
            totalWidth_ = width;
        }

        bool is_valid_field(const Field& field) const {
            return !(field.getName() == "zero"
                    ||  field.getName() == "res"
                    ||  field.getName() == "res0"
                    ||  field.getName() == "res1"
                    ||  field.getName() == "res2"
                    ||  field.getName() == "res3"
                    ||  field.getName() == "res4"
                    ||  field.getName() == "res5"
                    ||  field.getName() == "res6"
                    );
        }

        std::vector<std::pair<std::string,std::string>> calculate_bitmasks( std::vector<Field> fields) const{
            int shift_amt = 0;
            std::vector<std::pair<std::string,std::string>> bitmasks;
            for(auto field: fields) {
                if(is_valid_field(field)) {
                    uint64_t mask = 0;
                    uint64_t sizeInBits = sizeof(mask) * 8;
                    mask = (field.getWidth() >= sizeInBits ? -1 : (1lu << field.getWidth()) - 1);
                    mask = mask << shift_amt;
                    auto maskAsString = "'b" + std::bitset<64>(mask).to_string();
                    std::pair<std::string,std::string> p(field.getName(),maskAsString);
                    bitmasks.emplace_back(p);
                }
                shift_amt += field.getWidth();
            }
            return bitmasks;
        }

        std::vector<std::string> toSvFields() const {
            std::vector<std::string> fieldsAsString;
            for(auto field : fields_) {
                if(field.isAttribute()) {
                    if(field.getAttribute().getWidth() > 1) {
                        fieldsAsString.push_back("logic [" + std::to_string(field.getAttribute().getWidth() - 1) + ":0] " + name_ + "_" + field.getName() + ";");
                    } else {
                        fieldsAsString.push_back("logic " + name_ + "_" + field.getName() + ";");
                    }
                } else if(field.isEnum()) {
                    fieldsAsString.push_back(field.getEnum().toSvEnum());
                }

            }
            if(totalWidth_ > 1) { 
                fieldsAsString.push_back("logic [" + std::to_string(totalWidth_ - 1) + ":0] " + name_ + "_end;");
            } else {
                fieldsAsString.push_back("logic " + name_ + "_end;");
            }
            return fieldsAsString;
        }
    };
}
