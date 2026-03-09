#pragma once

#include <cstdint>
#include <map>
#include <string>
#include <variant>
#include <vector>
#include "utils.hpp"
#include "magic_enum/magic_enum.hpp"

// Forward declarations for types used in Operand class
// These will be fully defined when types.hpp is included after Points.hpp and InstEntry.hpp
namespace ArchCov {
    enum class Point;
}

namespace WdRiscv {
    enum class OperandType;
    enum class OperandMode;
}

namespace ArchCov {

    // Type aliases
    using EnumValueMap = std::map<std::string, uint64_t>;

    class Bin {
        public:
            Bin() {
               isArray = 0;
               isSpecialBin = 0;
               arrSize = "";
            }
            bool isArray;
            bool isSpecialBin;

            std::string arrSize;
            std::string name;
            std::string vals;
            std::string content;

    };

    class CoverPoint {
        public:
            std::string name;
            std::vector<Bin> bins;
            bool isEnum;
    };

    class CoverGroup {
        public:
            std::string name;
            std::vector<std::pair<std::string,std::string>> bitmasks;
            std::string qualifier;
            std::vector<std::string> inputs;
            std::vector<CoverPoint>  cps;
    };
    
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
            return 0; // Enum doesn't have width
        }

        void setWidth(uint64_t width) {
            if (isAttribute()) {
                getAttribute().setWidth(width);
            } else {
                // Convert to Attribute if currently an Enum
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
        void printFields() const {
            for(auto field : fields_) {
                std::cout<<"DEBUG : FIELD : " << field.getName() << " WIDTH : " << field.getAttribute().getWidth() << std::endl;
            }
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

    class Csr : public Fields {
      public:
        uint64_t num;

        uint64_t getNum() const {
            return num;
        }

        void setNum(uint64_t num) {
            this->num = num;
        }

        std::vector<Field> convert_field_names_to_lowercase(std::vector<Field> fields) const {
            std::vector<Field> formatted_fields;
            for(auto field : fields) {
                Field formatted_field;
                formatted_field = field;
                if (field.getName() == "INT"){
                    formatted_field.setName("intr");
                } else {
                    formatted_field.setName(convert_to_lowercase(field.getName()));
                }
                formatted_fields.push_back(formatted_field);
            }
            return formatted_fields;
        }

        std::string find_bit_position(const std::string& bitmask) const {
            int start_pos = 0;
            int end_pos   = 0;
            int pos       = 0;
            bool foundStart = false;
            int maskLength = bitmask.length()-1;
            for(auto &ch : bitmask) {
                if(ch == '1') {
                    if(!foundStart) {
                        start_pos = pos;
                        end_pos   = pos;
                        foundStart = true;
                    } else {
                        end_pos++;
                    }
                }
                pos++;
            }
            if(start_pos == end_pos){
                return "[" + std::to_string(maskLength - start_pos) + "]";
            } else {
                return "[" + std::to_string(maskLength - start_pos) + ":" + std::to_string(maskLength - end_pos) + "]";
            }
        }

        void create_mask_function(const std::vector<std::pair<std::string,std::string>>& bitmasks, std::string& maskFunctionAsString) const {
            maskFunctionAsString += "\t\tfunction void bit_slice_csr_fields(logic[63:0] CsrVal);\n";
            maskFunctionAsString += "\t\t\tlogic [63:0] maskedVal;\n";
            maskFunctionAsString += "\t\t\tvalue = CsrVal;\n";
            for(auto bitmask : bitmasks) {
                if (bitmask.first == "time")
                    bitmask.first = "time_";
                std::string bitslice = find_bit_position(bitmask.second);
                maskFunctionAsString += "\t\t\tmaskedVal =  CsrVal  & " + bitmask.second +  " ; \n";
                maskFunctionAsString += "\t\t\t" + bitmask.first + " = maskedVal " + bitslice + " ; \n";
            }
            maskFunctionAsString += "\t\tendfunction\n";
        
        }


        void create_bin(Bin& bin, std::string& binAsString) const {
            if(bin.isSpecialBin) {
                binAsString = bin.content;
            } else {
                binAsString +=  "\t\t\t\tbins " + bin.name;
                if(bin.isArray) {
                    binAsString += "["+bin.arrSize+"] ";
                }
                binAsString += " = " + bin.vals + ";\n";
            }
        }

        void create_coverpoint(CoverPoint& cp, std::string qualifier, std::string& cpAsString) const {
            cpAsString = "\t\t\tcoverpoint " + cp.name + " iff (csrenum_var   == " + qualifier + ")";
            cpAsString += "\n\t\t\t{\n";
            for(auto bin: cp.bins) {
                std::string binAsString;
                create_bin(bin, binAsString);
                cpAsString += binAsString;
                }
            cpAsString += "\n\t\t\t}\n";
        }

        void create_covergroup(CoverGroup& cg, std::string& cgAsString) const {
            cgAsString += "\t\tcovergroup cg_" + cg.name + " with function sample (" + convert_vector_to_string(cg.inputs) + ");\n";
            cgAsString += "\t\t\toption.per_instance = 1;\n";
            cgAsString += "\t\t\toption.name = \"" + cg.name + "\";\n";
            for(auto cp: cg.cps) {
                std::string cpAsString;
                if (cp.name == "time")
                    cp.name = "time_";
                create_coverpoint(cp, cg.qualifier, cpAsString);
                cgAsString += cpAsString;
            }
            cgAsString += "\t\tendgroup\n";
        }    

        void create_class(CoverGroup& cg, std::vector<std::string>& csrFieldStrings, std::string& classAsString) const {

            std::string cgAsString;
            classAsString += "class " + trim(cg.name) + "_csr;\n\n";
            classAsString += "\t\tlogic[63:0] value;\n";
            for(auto fieldString : csrFieldStrings) {
                classAsString += "\t\t" + fieldString + ";\n";
            }
            classAsString += "\n";
            classAsString += "\t\tfunction new();\n";
            classAsString += "\t\t\tcg_"+cg.name+" = new();\n";
            classAsString += "\t\tendfunction\n\n";
            create_covergroup(cg, cgAsString);
            classAsString += cgAsString;
            classAsString += "\n";

            std::string maskFunctionAsString;
            create_mask_function(cg.bitmasks,maskFunctionAsString);
            classAsString += maskFunctionAsString;
            classAsString += "\n";

            classAsString += "\tendclass : " + trim(cg.name) + "_csr\n\n";
        }

        std::string toSvCsr() const {

            std::vector<std::string> csrFieldStrings;
            std::string classAsString = "";

            const auto formatted_fields = convert_field_names_to_lowercase(fields_);

            CoverGroup cg = CoverGroup();
            cg.name       = getName();
            cg.qualifier  = "CSRENUM_" + convert_to_uppercase(format_name(cg.name,'.','_'));
            cg.bitmasks   = calculate_bitmasks(formatted_fields);

            for(auto field : formatted_fields) {
                if(is_valid_field(field)) {
                    CoverPoint cp = CoverPoint();
                    cp.name       = field.getName();
                    cp.isEnum     = field.isEnum();
                
                    if(field.isAttribute()) {

                        csrFieldStrings.push_back(field.getAttribute().toSvAttribute());
                        cg.inputs.push_back(field.getAttribute().toSvAttribute());
                    
                        if(field.getAttribute().getWidth() > 5) {

                            Bin bin_zeroes        = Bin();
                            bin_zeroes.name       =  "zeroes";
                            bin_zeroes.vals       =  "{0}";
                            bin_zeroes.isArray    =  0;
                            bin_zeroes.arrSize    =  "";
                            cp.bins.push_back(bin_zeroes);

                            Bin bin_ones          = Bin();
                            bin_ones.name         =  "ones";
                            bin_ones.vals         =  "{'1}";
                            bin_ones.isArray      =  0;
                            bin_ones.arrSize      =  "";
                            cp.bins.push_back(bin_ones);

                        } else {

                            Bin bin         = Bin();
                            bin.name        =  "valid";
                            bin.vals        =  "{[0:$]}";
                            bin.isArray     =  1;
                            bin.arrSize     = "";
                            cp.bins.push_back(bin);

                        }

                        cg.cps.push_back(cp);
                    }
                }
            }
            create_class(cg, csrFieldStrings,classAsString);
            return classAsString;
        }
    };

    /**
     * @brief Operand descriptor with two pairs: operand (Point + variant) and value (Point + variant)
     */
    class Operand {
    public:
        // Constructors
        Operand() = default;

        Operand(Point pOperand, const std::variant<Attribute, Enum>& operand,
                Point pValue, const std::variant<Attribute, Enum>& value,
                WdRiscv::OperandType type, WdRiscv::OperandMode mode)
            : pOperand_(pOperand)
            , operand_(operand)
            , pValue_(pValue)
            , value_(value)
            , type_(type)
            , mode_(mode) {}

        void setpOperand(Point p) {
            pOperand_ = p;
            std::cout<<"DEBUG:  pOperand_ :" << std::string(magic_enum::enum_name(p)) << std::endl;
        }

        Point getpOperand() const {
            return pOperand_;
        }
        
        std::string getpOperandAsString() const {
            return std::string(magic_enum::enum_name(pOperand_));
        }

        void setpValue(Point p) {
            pValue_ = p;
        }

        Point getpValue() const {
            return pValue_;
        }

        std::string getpValueAsString() const {
            return std::string(magic_enum::enum_name(pValue_));
        }

        WdRiscv::OperandType getType() const {
            return type_;
        }

        void setType(WdRiscv::OperandType type) {
            type_ = type;
        }

        std::string getTypeAsString() const {
            return std::string(magic_enum::enum_name(type_));
        }

        WdRiscv::OperandMode getMode() const {
            return mode_;
        }

        void setMode(WdRiscv::OperandMode mode) {
            mode_ = mode;
        }

        std::string getModeAsString() const {
            return std::string(magic_enum::enum_name(mode_));
        }

        const std::variant<Attribute, Enum>& getOperand() const {
            return operand_;
        }

        void setOperand(const std::variant<Attribute, Enum>& operand) {
            operand_ = operand;
            if (std::holds_alternative<Attribute>(operand)) {
                std::cout<<"DEBUG:  operand_ :" << std::get<Attribute>(operand).getWidth() << std::endl;
            } 
        }

        std::string getOperandAsString() const {
            if(isOperandAttribute()) {
                return std::get<Attribute>(operand_).toSvAttribute(getpOperandAsString());
            } else if(isOperandEnum()) {
                return std::get<Enum>(operand_).toSvEnum(getpOperandAsString());
            }
            return "";
        }

        const std::variant<Attribute, Enum>& getValue() const {
            return value_;
        }
        void setValue(const Attribute& value) {
            value_ = value;
        }

        std::string getValueAsString() const {
            if(isValueAttribute()) {
                return std::get<Attribute>(value_).toSvAttribute(getpValueAsString());
            } else if(isValueEnum()) {
                return std::get<Enum>(value_).toSvEnum(getpValueAsString());
            }
            return "";
        }
        // Helper methods for operand variant
        bool isOperandAttribute() const {
            return std::holds_alternative<Attribute>(operand_);
        }

        bool isOperandEnum() const {
            return std::holds_alternative<Enum>(operand_);
        }

         // Helper methods for value variant
        bool isValueAttribute() const {
            return std::holds_alternative<Attribute>(value_);
        }

        bool isValueEnum() const {
            return std::holds_alternative<Enum>(value_);
        }

        Attribute& getValueAttribute() {
            return std::get<Attribute>(value_);
        }

        const Attribute& getValueAttribute() const {
            return std::get<Attribute>(value_);
        }

        Enum& getValueEnum() {
            return std::get<Enum>(value_);
        }

        const Enum& getValueEnum() const {
            return std::get<Enum>(value_);
        }

        std::string toSvOperand() const {
            std::string operandAsString = "";
            if(isOperandAttribute()) {
                operandAsString = std::get<Attribute>(operand_).toSvAttribute();
            } else if(isOperandEnum()) {
                operandAsString = std::get<Enum>(operand_).toSvEnum();
            }
            return operandAsString;
        }
        // Operand pair: Point + variant<Attribute, Enum>
        Point pOperand_;
        std::variant<Attribute, Enum> operand_;

        // Value pair: Point + variant<Attribute, Enum>
        Point pValue_;
        std::variant<Attribute, Enum> value_;

        // Type and mode from WdRiscv namespace
        WdRiscv::OperandType type_;
        WdRiscv::OperandMode mode_;
    };

    /**
     * @brief Instruction descriptor with id, format, extension, operands, and extra points
     */
    class Inst {
    public:
        // Constructors
        Inst() = default;

        Inst(std::string name, uint64_t id, const std::string& format, const std::string& ext)
            : name_(name)
            , id_(id)
            , format_(format)
            , ext_(ext) {}

        // Name accessors
        const std::string& getName() const { return name_; }
        void setName(const std::string& name) { name_ = name; }

        // ID accessors
        uint64_t getId() const { return id_; }
        void setId(uint64_t id) { id_ = id; }

        // Format accessors
        const std::string& getFormat() const { return format_; }
        void setFormat(const std::string& format) { format_ = format; }

        // Extension accessors
        const std::string& getExt() const { return ext_; }
        void setExt(const std::string& ext) { ext_ = ext; }

        // Operands accessors
        const std::vector<Operand>& getOperands() const { return operands_; }
        std::vector<Operand>& getOperands() { return operands_; }

        void addOperand(const Operand& operand) {
            operands_.push_back(operand);
        }

        void clearOperands() {
            operands_.clear();
        }

        size_t getOperandCount() const {
            return operands_.size();
        }

        // Extra points accessors
        const std::vector<std::pair<Point, std::variant<Attribute, Enum>>>& getExtra() const {
            return extra_;
        }

        std::vector<std::pair<Point, std::variant<Attribute, Enum>>>& getExtra() {
            return extra_;
        }

        void addExtra(Point point, const std::variant<Attribute, Enum>& value) {
            extra_.emplace_back(point, value);
        }

        void addExtra(Point point, const Attribute& attr) {
            extra_.emplace_back(point, std::variant<Attribute, Enum>(attr));
        }

        void addExtra(Point point, const Enum& enum_) {
            extra_.emplace_back(point, std::variant<Attribute, Enum>(enum_));
        }

        void clearExtra() {
            extra_.clear();
        }

        size_t getExtraCount() const {
            return extra_.size();
        }

        // Helper methods for extra variant access
        bool isExtraAttribute(size_t index) const {
            if (index >= extra_.size()) return false;
            return std::holds_alternative<Attribute>(extra_[index].second);
        }

        bool isExtraEnum(size_t index) const {
            if (index >= extra_.size()) return false;
            return std::holds_alternative<Enum>(extra_[index].second);
        }

        Attribute& getExtraAttribute(size_t index) {
            return std::get<Attribute>(extra_[index].second);
        }

        const Attribute& getExtraAttribute(size_t index) const {
            return std::get<Attribute>(extra_[index].second);
        }

        Enum& getExtraEnum(size_t index) {
            return std::get<Enum>(extra_[index].second);
        }

        const Enum& getExtraEnum(size_t index) const {
            return std::get<Enum>(extra_[index].second);
        }

        Point getExtraPoint(size_t index) const {
            if (index >= extra_.size()) {
                // Return a default or throw - for now return first Point value
                return Point::HartIndex;
            }
            return extra_[index].first;
        }

        void setExtraPoint(size_t index, Point point) {
            if (index < extra_.size()) {
                extra_[index].first = point;
            }
        }

        void create_bin(Bin& bin, std::string& binAsString) const {
            if(bin.isSpecialBin) {
                binAsString = bin.content;
            } else {
                binAsString +=  "\t\t\t\tbins " + bin.name;
                if(bin.isArray) {
                    binAsString += "["+bin.arrSize+"] ";
                }
                binAsString += " = " + bin.vals + ";\n";
            }
        }

        void create_coverpoint(CoverPoint& cp, std::string qualifier, std::string& cpAsString) const {
            cpAsString = "\t\t\tcoverpoint " + cp.name + " iff (instrenum_var == " + qualifier + ")";
            cpAsString += "\n\t\t\t{\n";
            for(auto bin: cp.bins) {
                std::string binAsString;
                create_bin(bin, binAsString);
                cpAsString += binAsString;
                }
            cpAsString += "\n\t\t\t}\n";
        }

        void create_covergroup(CoverGroup& cg, std::string& cgAsString) const {
            cgAsString += "\t\tcovergroup cg_" + cg.name + " with function sample (" + convert_vector_to_string(cg.inputs) + ");\n";
            cgAsString += "\t\t\toption.per_instance = 1;\n";
            cgAsString += "\t\t\toption.name = \"" + cg.name + "\";\n";
            for(auto cp: cg.cps) {
                std::string cpAsString;
                if (cp.name == "time")
                    cp.name = "time_";
                create_coverpoint(cp, cg.qualifier, cpAsString);
                cgAsString += cpAsString;
            }
            cgAsString += "\t\tendgroup\n";
        }    

        void create_class(CoverGroup& cg, std::vector<std::string>& operandStrings, std::string& classAsString) const {

            std::string cgAsString;
            classAsString += "class " + trim(cg.name) + "_instr;\n\n";
            classAsString += "\t\tlogic[63:0] value;\n";
            for(auto operandString : operandStrings) {
                classAsString += "\t\t" + operandString + ";\n";
            }
            classAsString += "\n";
            classAsString += "\t\tfunction new();\n";
            classAsString += "\t\t\tcg_"+cg.name+" = new();\n";
            classAsString += "\t\tendfunction\n\n";
            create_covergroup(cg, cgAsString);
            classAsString += cgAsString;
            classAsString += "\n";

            classAsString += "\tendclass : " + trim(cg.name) + "_instr\n\n";
        }
        
        std::string toSvInst() const {

            std::string classAsString;
            std::vector<std::string> operandStrings;
            std::vector<Enum> uniqueEnums;
            std::string modeName;
            std::string typeName;
            std::string binName;
            std::string operandAttr;

            CoverGroup cg = CoverGroup();
            cg.name = format_name(getName(),'.','_');
            cg.qualifier = "INSTRENUM_" + convert_to_uppercase(cg.name);

            for(auto info : extra_) {
                if(info.first == ArchCov::Point::BrTaken) {
                    CoverPoint cpBr;
                    cpBr.name = std::string(magic_enum::enum_name(info.first));
                    auto attVal = std::get<Attribute>(info.second);
                    std::cout<<"attVal: "<<attVal.toSvAttribute()<<std::endl;
                    operandStrings.push_back(attVal.toSvAttribute());
                    cg.inputs.push_back(attVal.toSvAttribute());

                    Bin bin = Bin();
                    bin.name = "valid";
                    bin.vals = "{0,1}";
                    bin.isArray = 1;
    
                    cpBr.bins.push_back(bin);
                    cg.cps.push_back(cpBr);
                }
            }

            for(auto operand : operands_) {

                
                CoverPoint cp    = CoverPoint();
                cp.name      = std::string(magic_enum::enum_name(operand.getpOperand()));

                operandAttr  = std::string(magic_enum::enum_name(operand.getMode()));
                if(operandAttr == "Read") {
                    modeName = "source";
                } else if (operandAttr == "Write") {
                    modeName = "destination";
                } else if (operandAttr == "ReadWrite") {
                    modeName = "csr";
                } else {
                    modeName = "";
                }

                operandAttr  = std::string(magic_enum::enum_name(operand.getType()));
                if(operandAttr == "IntReg") {
                    typeName    = "int";
                } else if (operandAttr == "FpReg") {
                    typeName = "fp";
                } else if (operandAttr == "VecReg") {
                    typeName = "vec";
                } else if (operandAttr == "CsReg") {
                    typeName = "csr";
                } else if (operandAttr == "Imm") {
                    typeName = "imm";
                } else {
                    typeName = "";
                }
                
                binName = typeName + "_" + modeName + "_" + "bin";

                if (operand.isOperandAttribute()) {

                    //For an integer or FP register, create a coverpoint for the value ranges
                    if(typeName == "int" || typeName == "fp") {
                        CoverPoint cpVal = CoverPoint();
                        if( operand.getpValue() == ArchCov::Point::Op0Val ||
                            operand.getpValue() == ArchCov::Point::Op1Val ||
                            operand.getpValue() == ArchCov::Point::Op2Val ||
                            operand.getpValue() == ArchCov::Point::Op3Val
                        ) {
                            cpVal.name = operand.getpValueAsString();
                            cg.inputs.push_back(format_name(operand.getValueAsString(),';',' '));
                            operandStrings.push_back(format_name(operand.getValueAsString(),';',' '));

                            Bin bin_max        =  Bin();
                            bin_max.name       =  binName + "_max_val";
                            bin_max.vals       =  "{'1}";
                            cpVal.bins.push_back(bin_max);


                            Bin bin_min        =  Bin();
                            bin_min.name       =  binName + "_min_val";
                            bin_min.vals       =  "{0}";
                            cpVal.bins.push_back(bin_min);

                            cg.cps.push_back(cpVal);
                        }
                    }

                    //For an immediate value, create a coverpoint for the min/max values. 
                    if(typeName == "imm") {
                        int valWidth = operand.getValueAttribute().getWidth();

                        cp.name = std::string(magic_enum::enum_name(operand.getpValue()));
                        cg.inputs.push_back(operand.getValueAsString());
                        operandStrings.push_back(operand.getValueAsString());

                        Bin bin_max        =  Bin();
                        bin_max.name       =  binName + "_max_val";
                        bin_max.vals       =  "{'1}";
                        cp.bins.push_back(bin_max);

                        Bin bin_min        =  Bin();
                        bin_min.name       =  typeName + "_min_val";
                        bin_min.vals       =  "{'0}";
                        cp.bins.push_back(bin_min);

                        int base = 1;
                        for(int powof2=0; powof2<valWidth; powof2++) {
                            Bin bin_each_bit_set          =  Bin();
                            bin_each_bit_set.name         =  typeName + "_bit_" + std::to_string(powof2);
                            bin_each_bit_set.isSpecialBin = 1;
                            bin_each_bit_set.content      =  "\t\t\t\tbins " + bin_each_bit_set.name + " = { 'b" + std::bitset<12>(base).to_string() + "};\n";
                            base = base * 2;
                            cp.bins.push_back(bin_each_bit_set);
                        }

                    } else {
                        
                        if(operand.getpOperand() == ArchCov::Point::Op0 ||
                           operand.getpOperand() == ArchCov::Point::Op1||
                           operand.getpOperand() == ArchCov::Point::Op2||
                           operand.getpOperand() == ArchCov::Point::Op3
                        ) {
                            cg.inputs.push_back(format_name(operand.getOperandAsString(),';',' '));
                            operandStrings.push_back(format_name(operand.getOperandAsString(),';',' '));
                            int i = 0;
                            std::vector<std::string> binRanges;
                            if (operand.getValueAttribute().getWidth() == 3) {
                                binRanges = {"0","[1:3]","[4:7]"};
                            } else if (operand.getValueAttribute().getWidth() == 4) {
                                binRanges = {"0","[1:3]","[4:7]","[8:15]"};
                            } else {
                                binRanges = {"0","[1:7]","[8:15]","[16:31]"};
                            }
                            for(auto binRange : binRanges) {
                                Bin bin = Bin();
                                bin.name   =  binName+"_"+std::to_string(i);
                                bin.vals   =  "{"+binRange+"}";
                                cp.isEnum  =  0;
                                cp.bins.push_back(bin);
                                i++;
                            }
                        }
                    }
                } else {
                    Bin bin = Bin();
                    auto enumVal = std::get<Enum>(operand.getOperand());
                    std::string enumDeclName; 
    
                    if (std::find(csr_instrs.begin(), csr_instrs.end(), cg.name) != csr_instrs.end()) {
                        enumDeclName = "csr_Op2_e csr_op2_var";
           
                    }
    
                    if(ext_ == "F" || ext_ == "D" || ext_ == "Zfh") {
                        enumDeclName = "fext_Rm_e fext_rm_var";
                    }
                    
                    operandStrings.push_back(enumDeclName);
                    cg.inputs.push_back(enumDeclName);
                    bin.name    = "valid";
                    cp.isEnum   = 1;
                    bin.content = "\t\t\t\tbins valid = [0:$];\n";
                    cp.bins.push_back(bin);
    
                }

                cg.cps.push_back(cp);
            }
            create_class(cg, operandStrings,classAsString);
            return classAsString;
        }
        public:
        std::vector<std::string> csr_instrs = {"csrrc","csrrci","csrrs","csrrsi","csrrw","csrrwi"};
        private:
        std::string name_ = "";
        uint64_t id_ = 0;
        std::string format_ = "";
        std::string ext_ = "";
        std::vector<Operand> operands_;
        std::vector<std::pair<Point, std::variant<Attribute, Enum>>> extra_;
    };

} // namespace ArchCov