#pragma once

#include <cstdint>
#include <map>
#include <string>
#include <variant>
#include <vector>
#include "utils.hpp"

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

    std::string toSvAttribute() const {
        return "logic [" + std::to_string(width_ - 1) + ":0] " + getName() + ";";
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

    std::string toSvEnum() const {
        std::string enumAsString = "typedef enum logic [63:0] {\n";
        for(auto val : enumValues_) {
            enumAsString += "\t\t" +  convert_to_uppercase(getName() + "_" + val.first) + " = 64'd" + std::to_string(val.second) + ",\n";
        }
        enumAsString += "\t} " + getName() + "_e;\n";
        return enumAsString;
    }

private:
    EnumValueMap enumValues_;
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

    void setName(const std::string& name) {
        name_ = name;
    }

    const std::string& getName() const {
        return name_;
    }

    std::string toSvFields() const {
        std::string fieldsAsString = "";
        for(auto field : fields_) {
            if(field.isAttribute()) {
                fieldsAsString += field.getAttribute().toSvAttribute() + "\n";
            } else if(field.isEnum()) {
                fieldsAsString += field.getEnum().toSvEnum() + "\n";
            }
        }
        return fieldsAsString;
    }
};

class Csr : public Fields {
  public:
    uint64_t num;
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

    // Operand pair accessors
    Point getOperandPoint() const { return pOperand_; }
    void setOperandPoint(Point p) { pOperand_ = p; }
    
    const std::variant<Attribute, Enum>& getOperand() const { return operand_; }
    std::variant<Attribute, Enum>& getOperand() { return operand_; }
    
    // Value pair accessors
    Point getValuePoint() const { return pValue_; }
    void setValuePoint(Point p) { pValue_ = p; }
    
    const std::variant<Attribute, Enum>& getValue() const { return value_; }
    std::variant<Attribute, Enum>& getValue() { return value_; }
    
    // Type and mode accessors
    WdRiscv::OperandType getType() const { return type_; }
    void setType(WdRiscv::OperandType type) { type_ = type; }
    
    WdRiscv::OperandMode getMode() const { return mode_; }
    void setMode(WdRiscv::OperandMode mode) { mode_ = mode; }
    
    // Helper methods for operand variant
    bool isOperandAttribute() const {
        return std::holds_alternative<Attribute>(operand_);
    }
    
    bool isOperandEnum() const {
        return std::holds_alternative<Enum>(operand_);
    }
    
    Attribute& getOperandAttribute() {
        return std::get<Attribute>(operand_);
    }
    
    const Attribute& getOperandAttribute() const {
        return std::get<Attribute>(operand_);
    }
    
    Enum& getOperandEnum() {
        return std::get<Enum>(operand_);
    }
    
    const Enum& getOperandEnum() const {
        return std::get<Enum>(operand_);
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

private:
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
    
    Inst(uint64_t id, const std::string& format, const std::string& ext)
        : id_(id)
        , format_(format)
        , ext_(ext) {}

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

private:
    uint64_t id_ = 0;
    std::string format_ = "";
    std::string ext_ = "";
    std::vector<Operand> operands_;
    std::vector<std::pair<Point, std::variant<Attribute, Enum>>> extra_;
};

} // namespace ArchCov