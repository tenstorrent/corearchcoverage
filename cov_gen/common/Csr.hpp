#pragma once
#include <string>
#include <cstdint>
#include <vector>
#include "Fields.hpp"
#include "utils.hpp"
#include "Coverage.hpp"

namespace ArchCov {
    
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
                if(bitmask.first == "mode") {
                   std::cout << "HERE : bitmask.first: " << bitmask.first << std::endl;
                   std::cout << "HERE : bitmask.second: " << bitmask.second << std::endl;
                }
                std::string bitslice = find_bit_position(bitmask.second);
                maskFunctionAsString += "\t\t\tmaskedVal =  CsrVal  & " + bitmask.second +  " ; \n";
                if(bitmask.first == "time") {
                    bitmask.first = "time_";
                }
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
                    if (field.getName() == "time") {
                        cp.name       = "time_";
                        cp.isEnum     = field.isEnum();
                    } else {
                        cp.name       = field.getName();
                        cp.isEnum     = field.isEnum();
                    } 
                
                    if(field.isAttribute()) {
                        
                        if(field.getName() == "time") {
                            csrFieldStrings.push_back(format_name(field.getAttribute().toSvAttribute("time_"),';',' '));
                            cg.inputs.push_back(format_name(field.getAttribute().toSvAttribute("time_"),';',' '));
                        } else {
                            csrFieldStrings.push_back(format_name(field.getAttribute().toSvAttribute(field.getName()),';',' '));
                            cg.inputs.push_back(format_name(field.getAttribute().toSvAttribute(field.getName()),';',' '));
                        }
                    
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
}