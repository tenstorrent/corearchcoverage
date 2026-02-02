#include <bitset>
#include <fstream>
#include <iostream>
#include "magic_enum/magic_enum.hpp"
#include "Info.hpp"
#include "Points.hpp"
#include "cov_gen.hpp"
#include "Hart.hpp"
#include "regex"
#include "utils.hpp"
#include "vector.hpp"
#include "csrs.hpp"

using namespace ArchCov;
using namespace VectorCategories;
using namespace CsrCategories;

typedef std::pair<std::string, uint64_t> pair_t;
typedef std::vector<pair_t> vec_t;
typedef std::map<std::string, vec_t> map_t;

#define MAX_FIELD_WIDTH 5

//Constructor
template <typename URV>
CovGen<URV>::CovGen(WdRiscv::Hart<URV>& hart,std::string filename)
    :arch_info(hart),
     filename(filename)
{
    
    this->extractArchInfo();
    this->convertToArchInfoPointStrings();
    this->convertToEnumStrings();
    this->convertToAttributeStrings();
    this->convertToCsrStrings();
    this->convertToInstrStrings();

}

bool compareEnums(Enum e1, Enum e2) {
    for(auto it_m1 = e1.descriptor.cbegin(), end_m1 = e1.descriptor.cend(),
             it_m2 = e2.descriptor.cbegin(), end_m2 = e2.descriptor.cend();
             it_m1 != end_m1 || it_m2 != end_m2;) {
        if(it_m1->first != it_m2->first) 
            return false;
        ++it_m1;
        ++it_m2;
    }

    return true;
}

bool enumAlreadyExists(std::vector<Enum> uniqueEnums, Enum enumVal) {
    for(auto val: uniqueEnums){
        if(compareEnums(val,enumVal)){
            return true;
        } 
    }
    return false;
}

void gen_enum(std::string enumName,Enum enumVal, std::string& enumAsString) {
    //int max_bit_width = find_max_bit_width_for_enum(enumVal.descriptor);

    enumAsString = "typedef enum bit [63:0] {\n"; //" + std::to_string(max_bit_width) + ":0] {\n";
    int i = 0;
    //std::sort(enumVal.descriptor.begin(),enumVal.descriptor.end());
    for(auto val : enumVal.descriptor) {
        enumAsString =  enumAsString + "\t\t" +  convert_to_uppercase(enumName + "_" + val.first) + "=64'd" + std::to_string(val.second)  ;
        if(i != static_cast<int>(enumVal.descriptor.size() - 1)) {
            enumAsString += ",\n";
        }  else {
            enumAsString += "\n";
        }
        i += 1;
    }
    auto enumDeclName = enumName + "_e";
    enumAsString += "\t} " + enumDeclName + ";\n";
    enumAsString += "\t"   + enumDeclName + " " + convert_to_lowercase(enumName)+"_var;\n";
}

void gen_attribute(std::string attrName, Attribute attrVal, std::string& attrAsString) {
    std::string dtype_str = "";
    std::string name = attrName;
    if (name == "time")
        name = "time_";
    int size = attrVal.width;
    if(size-1>0) {
        dtype_str = "logic[" + std::to_string(size-1) + ":0] ";
    } else {
        dtype_str = "logic ";
    }
    attrAsString += dtype_str + name + ";";
}

std::vector<ArchCov::Csr::Field> convert_field_names_to_lowercase(std::vector<ArchCov::Csr::Field> fields) {
    std::vector<ArchCov::Csr::Field> formatted_fields;
    for(auto field : fields) {
        ArchCov::Csr::Field formatted_field;
        formatted_field = field;
        if (field.name == "INT"){
            formatted_field.name = "intr";
        } else {
            formatted_field.name = convert_to_lowercase(formatted_field.name);
        }
        formatted_fields.push_back(formatted_field);
    }
    return formatted_fields;
}

std::vector<std::pair<std::string,std::string>> calculate_bitmasks( std::vector<ArchCov::Csr::Field> fields) {
    int shift_amt = 0;
    std::vector<std::pair<std::string,std::string>> bitmasks;
    for(auto field: fields){
        if( !(field.name == "zero"
          ||  field.name == "res"
          ||  field.name == "res0"
          ||  field.name == "res1"
          ||  field.name == "res2"
          ||  field.name == "res3"
          ||  field.name == "res4"
          ||  field.name == "res5"
          ||  field.name == "res6"
          )) {
            uint64_t mask = 0;
            uint64_t sizeInBits = sizeof(mask) * 8;
            mask = (field.width >= sizeInBits ? -1 : (1lu << field.width) - 1);
            mask = mask << shift_amt;
            auto maskAsString = "'b" + std::bitset<64>(mask).to_string();
            std::pair<std::string,std::string> p(field.name,maskAsString);
            bitmasks.emplace_back(p);
        }
        shift_amt += field.width;
    }
    return bitmasks;
}

std::string find_bit_position(std::string bitmask) {
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

void create_mask_function(std::vector<std::pair<std::string,std::string>> bitmasks, std::string& maskFunctionAsString) {
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


template <typename URV>
void CovGen<URV>::create_bin(Bin bin, std::string& binAsString){
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

template <typename URV>
void CovGen<URV>::create_coverpoint(CoverPoint cp,bool isCsr, std::string qualifier, std::string& cpAsString){
    if(isCsr) {
        cpAsString = "\t\t\tcoverpoint " + cp.name + " iff (csrenum_var   == " + qualifier + ")";
    } else {
        cpAsString = "\t\t\tcoverpoint " + cp.name + " iff (instrenum_var == " + qualifier + ")";
    }
    if(cp.isEnum) {
        cpAsString += ";\n";
    } else {
        cpAsString += "\n\t\t\t{\n";
        for(auto bin: cp.bins) {
            std::string binAsString;
            create_bin(bin, binAsString);
            cpAsString += binAsString;
            }
        cpAsString += "\n\t\t\t}\n";
    }
}

template <typename URV>
void CovGen<URV>::create_covergroup(CoverGroup cg, bool isCsr, std::string& cgAsString){
    //if(isCsr) {
    //    cgAsString += "\t\tcovergroup cg_" + cg.name + ";\n";
    //} else {
        cgAsString += "\t\tcovergroup cg_" + cg.name + " with function sample (" + convert_vector_to_string(cg.inputs) + ");\n";
    //}
    cgAsString += "\t\t\toption.per_instance = 1;\n";
    cgAsString += "\t\t\toption.name = \"" + cg.name + "\";\n";
    for(auto cp: cg.cps) {
        std::string cpAsString;
        if (cp.name == "time")
            cp.name = "time_";
        create_coverpoint(cp, isCsr, cg.qualifier, cpAsString);
        cgAsString += cpAsString;
    }
    cgAsString += "\t\tendgroup\n";
}

template <typename URV>
void CovGen<URV>::create_class(CoverGroup cg, bool isCsr, std::vector<std::string> operands, std::string& classAsString){
    std::string cgAsString;
    if(isCsr) {
        classAsString += "class " + trim(cg.name) + "_csr;\n\n";
        classAsString += "\t\tlogic[63:0] value;\n";
    } else {
        classAsString += "class " + trim(cg.name) + "_instr;\n\n";
    }
    for(auto operand : operands) {
        classAsString += "\t\t" + operand + ";\n";
    }
    classAsString += "\n";
    classAsString += "\t\tfunction new();\n";
    classAsString += "\t\t\tcg_"+cg.name+" = new();\n";
    classAsString += "\t\tendfunction\n\n";
    create_covergroup(cg,isCsr, cgAsString);
    classAsString += cgAsString;
    classAsString += "\n";

    std::string maskFunctionAsString;
    if(isCsr) {
        create_mask_function(cg.bitmasks,maskFunctionAsString);
        classAsString += maskFunctionAsString;
        classAsString += "\n";
    }

    if(isCsr) {
        classAsString += "\tendclass : " + trim(cg.name) + "_csr\n\n";
    } else {
        classAsString += "\tendclass : " + trim(cg.name) + "_instr\n\n";
    }

}

//Converts entries of the enumsMap collected from Whisper to SystemVerilog Strings.
template <typename URV>
void CovGen<URV>::convertToEnumStrings()  {
    std::string enumAsString;
    for(auto enums : enumsMap) {
        enumAsString = "";
        gen_enum(enums.first, enums.second, enumAsString);
        //std::cout<<"DEBUG : ENUM FIRST " << enums.first << " ENUM STRING : " << enumAsString <<std::endl;
        enumStrings.push_back(enumAsString);
    }
}

// Converts entries of the attsMap collected from Whisper to SystemVerilog Strings.
template <typename URV>
void CovGen<URV>::convertToAttributeStrings() {
    std::string attrAsString;
    for(auto var: attsMap) {
        attrAsString = "";
        gen_attribute(std::get<0>(var), std::get<1>(var), attrAsString);
        attributeStrings.push_back(attrAsString);
    }
    for (auto var: fieldsMap) {
        Attribute a;
        attrAsString = "";
        auto string_ = std::get<0>(var);
        auto fields_ = std::get<1>(var);
        auto resolve = std::get<2>(var);
        for (auto f: fields_.fields) {
            if (resolve == Info<URV>::RESOLVE::NONE || resolve == Info<URV>::RESOLVE::SEPARATE) {
                a.width = f.width;
            } else if (resolve == Info<URV>::RESOLVE::COALESCE) {
                a.width += f.width;
            }
        }
        gen_attribute(string_, a, attrAsString);
        attributeStrings.push_back(attrAsString);
    }
    std::sort(attributeStrings.begin(),attributeStrings.end());
}

//Converts all the available ArchInfo Coverpoints to SystemVerilog Enums.
template <typename URV>
void CovGen<URV>::convertToArchInfoPointStrings() {
    auto archInfoPoints = magic_enum::enum_entries<Point>();
    int entry_count = 0;
    for(auto val : archInfoPoints){
        std::cout << "DEBUG : ENTRY COUNT : " << entry_count << " ARCH INFO POINT : " << std::string(val.second) << std::endl;
        archInfoPointsMap["POINT_" + std::string(val.second)] =  unsigned(val.first);
        entry_count += 1;
    }

}

template <typename URV>
void CovGen<URV>::convertToCsrStrings() {
    Enum csrEnum;
    std::vector<ArchCov::Csr::Field> formatted_fields;
    bool isCsr = 1;
    map_t categoryMap;

    for(auto csr : csrsMap){
        std::vector<std::string> csrFieldStrings;
        std::string classAsString;
        CoverGroup cg = CoverGroup();
        cg.name = csr.first;
        format_cg_name(cg.name);
        cg.qualifier =  "CSRENUM_"+convert_to_uppercase(cg.name);
        csrEnum.enu(cg.name,csr.second.num);
        formatted_fields = convert_field_names_to_lowercase(csr.second.fields);
        cg.bitmasks = calculate_bitmasks(formatted_fields);

        for (auto category : csr_categories) {
            auto csr_list = category.second;
            if (std::find(csr_list.begin(), csr_list.end(), csr.first) != csr_list.end()) {
                categoryMap[category.first].push_back(std::make_pair(cg.name,csr.second.num));
            }
        }

        for(auto field : formatted_fields) {
            if( !(field.name == "zero"
              ||  field.name == "res"
              ||  field.name == "res0"
              ||  field.name == "res1"
              ||  field.name == "res2"
              ||  field.name == "res3"
              ||  field.name == "res4"
              ||  field.name == "res5"
              ||  field.name == "res6"
              )) {
                CoverPoint cp  = CoverPoint();

                cp.name        = field.name;
                cp.isEnum      =  0;
                auto attVal = Attribute(field.width);
                std::string attAsString;

                gen_attribute(cp.name, attVal, attAsString);
                attAsString.pop_back();
                csrFieldStrings.push_back(attAsString);
                cg.inputs.push_back(attAsString);

                if(field.width > MAX_FIELD_WIDTH) {

                    //FIXME : Temporary hardcoding this value to avoid Array Bin Overflow VCS issue
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
        create_class(cg, isCsr, csrFieldStrings,classAsString);
        csrStrings.push_back(classAsString);
    }
        
    for(auto category : categoryMap) {
        std::string categoryString;
        Enum categoryEnum;
        for(auto instr : category.second) {
            categoryEnum.enu(instr.first,instr.second);
        }
        gen_enum(convert_to_lowercase(category.first),categoryEnum,categoryString);
        enumStrings.push_back(categoryString);
    }

    std::string csrEnumAsString;
    gen_enum("csrEnum",csrEnum,csrEnumAsString);
    enumStrings.push_back(csrEnumAsString);
}

template <typename URV>
void CovGen<URV>::convertToInstrStrings() {

    std::vector<std::string> csr_instrs = IMAExtCategoryMap["CSR_INSTRS"];
    std::vector<Enum> uniqueEnums;
    std::string operandAttr;
    std::string modeName;
    std::string typeName;
    std::string binName;

    map_t formatMap, extensionMap, categoryMap;

    Enum instrEnum;

    bool isCsr = 0;

    //Iterate over the instruction map
    for(auto inst : instsMap) {
        std::string classAsString;
        std::vector<std::string> operandStrings;
        CoverGroup cg = CoverGroup();

        cg.name       = inst.first;
        format_cg_name(cg.name);

        formatMap[inst.second.format].push_back(std::make_pair(cg.name,inst.second.id));
        extensionMap[inst.second.ext].push_back(std::make_pair(cg.name,inst.second.id));
        
        cg.qualifier = "INSTRENUM_"+convert_to_uppercase(cg.name);
        instrEnum.enu(cg.name, inst.second.id);

        if(inst.second.ext == "V"){
            for(auto category : vector_categories){
                auto instrList = category.second;
                if( std::find(instrList.begin(), instrList.end(), inst.first) != instrList.end()){
                    categoryMap[category.first].push_back(std::make_pair(cg.name,inst.second.id));
                }
            }
        }

        for(auto info : inst.second.extra) {
            if(info.first == ArchCov::Point::BrTaken) {
                CoverPoint cpBr;
                cpBr.name = std::string(magic_enum::enum_name(info.first));
                auto attVal = std::get<Attribute>(info.second);
                std::string attAsString;

                gen_attribute(cpBr.name,attVal,attAsString);
                attAsString.pop_back();
                operandStrings.push_back(attAsString);
                cg.inputs.push_back(attAsString);

                Bin bin = Bin();
                bin.name = "valid";
                bin.vals = "{0,1}";
                bin.isArray = 1;

                cpBr.bins.push_back(bin);
                cg.cps.push_back(cpBr);
            }
        }

        for(auto operand : inst.second.operands) {

            CoverPoint cp    = CoverPoint();
            cp.name      = std::string(magic_enum::enum_name(operand.pOperand));
            operandAttr  = std::string(magic_enum::enum_name(operand.mode));

            if(operandAttr == "Read") {
                modeName = "source";
            } else if (operandAttr == "Write") {
                modeName = "destination";
            } else if (operandAttr == "ReadWrite") {
                modeName = "csr";
            } else {
                modeName = "";
            }

            operandAttr  = std::string(magic_enum::enum_name(operand.type));
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
            // std::cout<<cg.name << " : " << binName<<std::endl;

            if (std::holds_alternative<Attribute>(operand.operand)) {
                if(typeName == "int" || typeName == "fp") {
                    std::string valString;
                    CoverPoint cpVal = CoverPoint();
                    if( operand.pValue == ArchCov::Point::Op0Val ||
                        operand.pValue == ArchCov::Point::Op1Val ||
                        operand.pValue == ArchCov::Point::Op2Val ||
                        operand.pValue == ArchCov::Point::Op3Val
                    ) {
                            cpVal.name = std::string(magic_enum::enum_name(operand.pValue));
                            gen_attribute(cpVal.name,operand.value,valString);
                            valString.pop_back();
                            cg.inputs.push_back(valString);
                            operandStrings.push_back(valString);

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
                auto attVal = std::get<Attribute>(operand.operand);
                std::string attAsString;
                if(typeName == "imm") {
                    int valWidth = operand.value.width;
                    cp.name = std::string(magic_enum::enum_name(operand.pValue));
                    gen_attribute(cp.name, operand.value, attAsString);
                    attAsString.pop_back();
                    cg.inputs.push_back(attAsString);
                    operandStrings.push_back(attAsString);
                    Bin bin_max        =  Bin();
                    bin_max.name       =  typeName + "_max_val";
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
                    Bin bin = Bin();
                    gen_attribute(cp.name, attVal, attAsString);
                    attAsString.pop_back();
                    cg.inputs.push_back(attAsString);
                    operandStrings.push_back(attAsString);
                    
                    int i = 0;
                    std::vector<std::string> binRanges;
                    if (attVal.width == 3) {
                        binRanges = {"0","[1:3]","[4:7]"};
                    } else if (attVal.width == 4) {
                        binRanges = {"0","[1:3]","[4:7]","[8:15]"};
                    } else {
                        binRanges = {"0","[1:7]","[8:15]","[16:31]"};
                    }
                    for(auto binRange : binRanges) {
                        bin.name   =  binName+"_"+std::to_string(i);
                        bin.vals   =  "{"+binRange+"}";//"[0:((2^^" + std::to_string(attVal.width) + ")-1)]";
                        cp.isEnum  =  0;
                        cp.bins.push_back(bin);
                        i++;
                    }
                }

            } else {
                Bin bin = Bin();
                auto enumVal = std::get<Enum>(operand.operand);
                std::string enumAsString;
                std::string enumDeclName; 

                if (std::find(csr_instrs.begin(), csr_instrs.end(), cg.name) != csr_instrs.end()) {
                    enumDeclName = "csr_" + cp.name;
                    if(!enumAlreadyExists(uniqueEnums,enumVal)){
                        uniqueEnums.push_back(enumVal);
                        gen_enum(enumDeclName,enumVal,enumAsString);
                        enumStrings.push_back(enumAsString);                        
                    }
                }

                if(inst.second.ext == "F" || inst.second.ext == "D" || inst.second.ext == "Zfh") {
                    enumDeclName = "fext_" + cp.name;
                    if(!enumAlreadyExists(uniqueEnums,enumVal)){
                        uniqueEnums.push_back(enumVal);
                        gen_enum(enumDeclName,enumVal,enumAsString);
                        enumStrings.push_back(enumAsString);
                    }
                }
                
                cp.name = enumDeclName + "_instr_var";
                cg.inputs.push_back("instrEnum_e " + enumDeclName + "_instr_var");
                operandStrings.push_back("instrEnum_e " + enumDeclName + "_instr_var");

                bin.name    = "valid";
                cp.isEnum   = 1;
                cp.bins.push_back(bin);
            }

            cg.cps.push_back(cp);
        }
        create_class(cg, isCsr, operandStrings,classAsString);
        instStrings.push_back(classAsString);
    }

    for(auto format : formatMap) {
        std::string instrFormatString;
        Enum instrFormatEnum;
        for(auto instr : format.second) {
            instrFormatEnum.enu(instr.first,instr.second);
        }
        gen_enum(format.first+"Format",instrFormatEnum,instrFormatString);
        enumStrings.push_back(instrFormatString);
    }

    for(auto extension : extensionMap) {
        std::string instrExtensionString;
        Enum instrExtensionEnum;
        for(auto instr : extension.second) {
            instrExtensionEnum.enu(instr.first,instr.second);
        }
        gen_enum(extension.first+"Ext",instrExtensionEnum,instrExtensionString);
        enumStrings.push_back(instrExtensionString);
    }
    
    for(auto category : categoryMap) {
        std::string categoryString;
        Enum categoryEnum;
        for(auto instr : category.second) {
            categoryEnum.enu(instr.first,instr.second);
        }
        gen_enum(convert_to_lowercase(category.first),categoryEnum,categoryString);
        enumStrings.push_back(categoryString);
    }

    std::string instrEnumAsString;
    gen_enum("instrEnum",instrEnum,instrEnumAsString);
    enumStrings.push_back(instrEnumAsString);
}


template <typename URV>
void CovGen<URV>::extractArchInfo() {
    arch_info.points(enumsMap, attsMap, fieldsMap, instsMap, csrsMap);
    sort_vector_pairs<Enum>     (enumsMap);
    // sort_vector_pairs<Attribute>(attsMap);
    sort_vector_pairs<Inst>     (instsMap);
    sort_vector_pairs<Csr>      (csrsMap);
    // sort_vector_pairs<Fields>   (fieldsMap);
}

template <typename URV>
void CovGen<URV>::printHeader(std::ofstream& CpFile) {

    CpFile << "`ifndef CP_PACKAGE_SV\n";
    CpFile << "`define CP_PACKAGE_SV\n";
    CpFile << "`ifndef COVERAGE_UNSUPPORTED\n";
    CpFile << "/*\n" << padding + "\n" << header + "\n" << padding + "\n" << "*/\n";
    CpFile << "package cp_pkg;\n";
}

template <typename URV>
void CovGen<URV>::printArchInfoPoints(std::ofstream& CpFile) {

    std::cout << "DEBUG : ARCH INFO POINTS MAP SIZE : " << archInfoPointsMap.size() << std::endl;
    int NumArchCoverPoints = archInfoPointsMap.size();
    CpFile << "\tparameter NUM_ARCH_COVER_POINTS = " << NumArchCoverPoints << ";\n\n";

    CpFile << "\t//ArchInfo CoverPoints\n";
    CpFile << "\ttypedef enum {\n";
    int i=0;

    std::vector<std::pair<std::string, unsigned>> pairs;
    for (auto itr = archInfoPointsMap.begin(); itr != archInfoPointsMap.end(); ++itr)
        pairs.push_back(*itr);
    sort(pairs.begin(), pairs.end(), [=](std::pair<std::string, unsigned>& a, std::pair<std::string, unsigned>& b)
    { return a.second < b.second;} );

    for(auto archInfoPoint : pairs) {
        CpFile << "\t\t" + convert_to_uppercase(std::string(archInfoPoint.first)) + "=" + std::to_string(archInfoPoint.second);
        if(i != static_cast<int>(archInfoPointsMap.size() - 1)) {
            CpFile << ",\n";
        }  else {
		    CpFile << "\n";
		}
           i += 1;
    }
    CpFile << "\t} archInfoPoints_e; \n";
}

template <typename URV>
void CovGen<URV>::printEnums(std::ofstream& CpFile) {

    CpFile << "\t//Whisper Equivalent SV Enums\n";
    CpFile << "\t//Enums {\n";
    for(auto enumString : enumStrings) {
        CpFile << "\t" + enumString + "\n";
    }
    CpFile << "\t//}\n";
}

template <typename URV>
void CovGen<URV>::printAttributes(std::ofstream& CpFile) {

    CpFile << "\t//Attribute variables\n";
    CpFile << "\t//Attributes {\n";
    for(auto attributeString : attributeStrings) {
        CpFile << "\t" + attributeString + "\n";
    }
    CpFile << "\t\n//}\n"; 
}

template <typename URV>
void CovGen<URV>::printCsrs(std::ofstream& CpFile) {

    CpFile << "\t//Csr Classes\n";
    CpFile << "\t//Csrs {\n";
    for(auto csrString : csrStrings) {
        CpFile << "\t" + csrString + "\n";
    }
    CpFile << "//}\n";

}

template <typename URV>
void CovGen<URV>::printInstrs(std::ofstream& CpFile) {

    CpFile << "\t//Instr classes\n";
    CpFile << "\t//Instrs {\n";
    for(auto instString : instStrings) {
        CpFile << "\t" + instString + "\n";
    }
    CpFile << "//}\n";
}

template<typename URV>
void CovGen<URV>::printFooter(std::ofstream& CpFile) {
    CpFile << "endpackage\n";
    CpFile << "`endif\n";
    CpFile << "`endif";
}


template <typename URV>
void CovGen<URV>::generateCpPackage() {

    std::ofstream CpFile(filename);
    printHeader(CpFile);
    CpFile << "\n";

    printArchInfoPoints(CpFile);
    CpFile << "\n";

    printEnums(CpFile);
    CpFile << "\n";

    printAttributes(CpFile);
    CpFile << "\n";

    printCsrs(CpFile);
    CpFile << "\n";

    printInstrs(CpFile);
    CpFile << "\n";

    printFooter(CpFile);
}

template class CovGen<uint32_t>;
template class CovGen<uint64_t>;
