#include "csrs.hpp"

/*

HOW TO ADD NEW CSR CATEGORIES:
1. If you want to re-use the existing categories, add the csr name to the cateogry and its done. 
For e.g if you want mie/mip as mmode_csrs, add it to mmode_csrs vector 
mmode_csrs = {
            "mstatus", 
            "mie", 
            "mip",}

2. If you want to add a new category, create a new vector. Add the vector to the csr_categories map.
For e.g if you want to add a new category called read_only_mmode_csrs, add it to the map as follows:
NOTE : Use "CSRS" at the beginning of a new category name in csr_categories map.
std::vector<std::string> read_only_mmode_csrs = {
            "medeleg",
            "mideleg"}
csr_categories = {
            ...
            {"CSRS_READ_ONLY_M_MODE", read_only_mmode_csrs}
}   

3. The cp_pkg.sv will contain the enum for the new category. 
You can use the enum for coverage by appending "_var" to the enum name in lowercase.
For e.g if the enum is called CSRS_READ_ONLY_M_MODE, you can use it for coverage by appending "_var" to it.
So the enum will be csr_read_only_mmode_var.

 */

namespace CsrCategories {

    template<typename T>
    std::vector<T> concatenateCsrCategories(const std::vector<std::vector<T>>& csr_categories) {
            std::vector<T> result;
            for (const auto& csr_category : csr_categories) {
                    result.insert(result.end(), csr_category.begin(), csr_category.end());
            }
            return result;
    }

    std::vector<std::string> mmode_csrs = {
            "mstatus",
            "menvcfg",
            "mideleg",
            "medeleg",
            "mip",
            "mie",
            "mcause",
            "mepc",
            "mscratch",
    },
    smode_csrs = {
            "sstatus",
            "sip",
            "sie",
            "scause",
            "sepc",
            "sscratch",
    },
    hsmode_csrs = {
            "hstatus",
            "henvcfg",
            "hip",
            "hie",
    },
    vsmode_csrs = {
            "vsstatus",
            "vsscratch",
            "vscause",
            "vsepc",
            "vsip",
            "vsie",
    };

    std::map<std::string, std::vector<std::string>> csr_categories = {
            {"CSRS_M_MODE", mmode_csrs},
            {"CSRS_S_MODE", smode_csrs},
            {"CSRS_HS_MODE", hsmode_csrs},
            {"CSRS_VS_MODE", vsmode_csrs}
    };

}
