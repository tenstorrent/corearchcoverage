#pragma once

#include "Points.hpp"
#include "Attribute.hpp"
#include "Enum.hpp"
#include "utils.hpp"
#include "magic_enum/magic_enum.hpp"
#include <variant>
#include <string>
#include <iostream>
#include <vector>
#include "Operand.hpp"
#include "Coverage.hpp"

namespace ArchCov {
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
                        operandStrings.push_back("logic " + std::string(magic_enum::enum_name(info.first)));
                        cg.inputs.push_back("logic " + std::string(magic_enum::enum_name(info.first)));
    
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
    
                            cp.name = std::string(magic_enum::enum_name(operand.getpValue()));
                            cg.inputs.push_back(format_name(operand.getValueAsString(),';',' '));
                            operandStrings.push_back(format_name(operand.getValueAsString(),';',' '));
    
                            Bin bin_max        =  Bin();
                            bin_max.name       =  typeName + "_max_val";
                            bin_max.vals       =  "{'1}";
                            cp.bins.push_back(bin_max);
    
                            Bin bin_min        =  Bin();
                            bin_min.name       =  typeName + "_min_val";
                            bin_min.vals       =  "{'0}";
                            cp.bins.push_back(bin_min);
    
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
        
                        if(std::find(fp_extensions.begin(), fp_extensions.end(), ext_) != fp_extensions.end()) {
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
            std::vector<std::string> fp_extensions = {"F","D","Zfh","Zfa","Zvfbfwma","Zfbfmin","Zvfbfmin"};
            private:
            std::string name_ = "";
            uint64_t id_ = 0;
            std::string format_ = "";
            std::string ext_ = "";
            std::vector<Operand> operands_;
            std::vector<std::pair<Point, std::variant<Attribute, Enum>>> extra_;
    };
}
