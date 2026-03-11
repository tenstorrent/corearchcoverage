#pragma once

#include "Points.hpp"
#include "Attribute.hpp"
#include "Enum.hpp"
#include "utils.hpp"
#include "magic_enum/magic_enum.hpp"
#include <variant>
#include <string>
#include <iostream>

namespace WdRiscv {
    enum class OperandType;
    enum class OperandMode;
}
namespace ArchCov {

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
}