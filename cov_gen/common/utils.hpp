#pragma once
#include "types.hpp"
#include <string>
#include <vector>
#include <set>
#include <algorithm>
#include <iterator>
#include <sstream>
#include <unordered_map>
#include <bitset>

inline std::string convert_to_lowercase(std::string data) {
    std::transform(data.begin(), data.end(), data.begin(),
    [](unsigned char c){ return std::tolower(c); });
    return data;
}

inline std::string convert_to_uppercase(std::string data) {
    std::transform(data.begin(), data.end(), data.begin(),
    [](unsigned char c){ return std::toupper(c); });
    return data;
}

inline std::string convert_set_to_string(std::set<uint64_t> binVals) {
    std::ostringstream ss;
    std::vector<std::string> vals; 
    for(auto binVal : binVals) {
        vals.push_back("'b" + std::bitset<8>(binVal).to_string());
    }
    if (!vals.empty()) { 
        std::copy(vals.begin(), vals.end() - 1, std::ostream_iterator<std::string>(ss, ",")); ss << vals.back(); 
    }
    return ss.str();
}



inline std::string convert_vector_to_string(std::vector<std::string> binVals) {
    std::ostringstream ss;
    std::sort(binVals.begin(),binVals.end());
    if (!binVals.empty()) { 
        std::copy(binVals.begin(), binVals.end() - 1, std::ostream_iterator<std::string>(ss, ",")); ss << binVals.back(); 
    }
    return ss.str();
}


inline void format_cg_name (std::string& input) {
  std::replace( input.begin(), input.end(), '.', '_'); 
}

inline std::string trim(const std::string& str,
                 const std::string& whitespace = " \t")
{
    const auto strBegin = str.find_first_not_of(whitespace);
    if (strBegin == std::string::npos)
        return ""; 

    const auto strEnd = str.find_last_not_of(whitespace);
    const auto strRange = strEnd - strBegin + 1;

    return str.substr(strBegin, strRange);
}

//int find_max_bit_width_for_enum (uint64_map_t input) {
//
//    auto pr = std::max_element (
//        std::begin(input), std::end(input),
//            [] (const pair_t & p1, const pair_t & p2) {
//            return p1.second < p2.second;
//            }
//    );
//
//    uint64_t n = pr-> second;
//
//    n--;
//    n |= n >> 1;   // Divide by 2^k for consecutive doublings of k up to 32,
//    n |= n >> 2;   // and then or the results.
//    n |= n >> 4;
//    n |= n >> 8;
//    n |= n >> 16;
//    n |= n >> 32; 
//    n++;
//
//    return (log2(n)-1);
//
//}

template<typename T>
inline void sort_vector_pairs(std::vector<T>& vecData) {
    std::sort(vecData.begin(), vecData.end(), [](auto &left, auto &right) {
        return left < right;
    });
}

inline std::string format_name (std::string input, char replaceChar, char replaceWith) {
    std::replace( input.begin(), input.end(), replaceChar, replaceWith); 
    return input;
}
  