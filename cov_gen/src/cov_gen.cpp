// SPDX-FileCopyrightText: © 2026 Tenstorrent AI ULC
// SPDX-License-Identifier: Apache-2.0
#include <bitset>
#include <fstream>
#include <iostream>
#include "magic_enum/magic_enum.hpp"
#include "Info.hpp"
#include "common/Points.hpp"
#include "cov_gen.hpp"
#include "Hart.hpp"
#include "regex"
#include "common/utils.hpp"
#include "common/Operand.hpp"
#include "common/Coverage.hpp"
#include "common/Inst.hpp"
#include "common/Csr.hpp"
#include "common/Fields.hpp"
#include "common/Enum.hpp"
#include "common/Attribute.hpp"

using namespace ArchCov;

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

//Converts entries of the enumsMap collected from Whisper to SystemVerilog Strings.
template <typename URV>
void CovGen<URV>::convertToEnumStrings()  {
    std::string enumAsString;
    for(auto enums : enumsMap) {
        enumAsString = "";
        enumStrings.push_back(enums.toSvEnum());
    }
}

// Converts entries of the attsMap and fieldsMap collected from Whisper into
// SystemVerilog declaration Strings. PTE field decompositions produced by
// addPtes (e.g. FVPTE_Level1_ppn, DPTELeaf_v, ...) are emitted as plain
// attribute-style "logic [W-1:0] NAME;" declarations alongside the regular
// attributes so they all live in the same Attributes block of cp_pkg.sv.
template <typename URV>
void CovGen<URV>::convertToAttributeStrings() {
    std::string attrAsString = "";
    for(auto var: attsMap) {
        attrAsString = var.toSvAttribute();
        attributeStrings.push_back(attrAsString);
    }
    for(auto& fieldsEntry : fieldsMap) {
        for(auto& fieldDecl : fieldsEntry.toSvFields()) {
            attributeStrings.push_back(fieldDecl);
        }
    }
    std::sort(attributeStrings.begin(),attributeStrings.end());
}

//Converts all the available ArchInfo Coverpoints to SystemVerilog Enums.
template <typename URV>
void CovGen<URV>::convertToArchInfoPointStrings() {
    auto archInfoPoints = magic_enum::enum_entries<Point>();
    int entry_count = 0;
    for(auto val : archInfoPoints){
        archInfoPointsMap["POINT_" + std::string(val.second)] =  unsigned(val.first);
        entry_count += 1;
    }

}

template <typename URV>
void CovGen<URV>::convertToCsrStrings() {
    for(auto csr : csrsMap) {
        csrStrings.push_back(csr.toSvCsr());
    }
}

template <typename URV>
void CovGen<URV>::convertToInstrStrings() {

    for(auto inst : instsMap) {
            instStrings.push_back(inst.toSvInst());
    }
}

template <typename URV>
void CovGen<URV>::extractArchInfo() {
    arch_info.points(enumsMap, attsMap, fieldsMap, instsMap, csrsMap);// instsMap, csrsMap);
    sort_vector_pairs<Enum>     (enumsMap);
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
    CpFile << "//}\n"; 
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
