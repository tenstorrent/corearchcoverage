#include <string> 
#include <vector> 
#include <set> 
#include <algorithm> 
#include <iterator>
#include <sstream>  
#include <bitset>
#include <iostream>
#include <unordered_map>
#include <bits/stdc++.h>

std::string convert_to_lowercase(std::string data) {
    std::transform(data.begin(), data.end(), data.begin(),
    [](unsigned char c){ return std::tolower(c); });
    return data;
}


std::string convert_to_uppercase(std::string data) {
    std::transform(data.begin(), data.end(), data.begin(),
    [](unsigned char c){ return std::toupper(c); });
    return data;
}

std::string convert_set_to_string(std::set<uint32_t> binVals) {
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

std::string convert_vector_to_string(std::vector<std::string> binVals) {
    std::ostringstream ss;
    std::sort(binVals.begin(),binVals.end());
    if (!binVals.empty()) { 
        std::copy(binVals.begin(), binVals.end() - 1, std::ostream_iterator<std::string>(ss, ",")); ss << binVals.back(); 
    }
    return ss.str();
}


void format_cg_name (std::string& input) {
  std::replace( input.begin(), input.end(), '.', '_'); 
}

std::string trim(const std::string& str,
                 const std::string& whitespace = " \t")
{
    const auto strBegin = str.find_first_not_of(whitespace);
    if (strBegin == std::string::npos)
        return ""; // no content

    const auto strEnd = str.find_last_not_of(whitespace);
    const auto strRange = strEnd - strBegin + 1;

    return str.substr(strBegin, strRange);
}

int find_max_bit_width_for_enum (std::unordered_map<std::string,unsigned> input) {

    //using pair_type = decltype(input)::value_type;

    auto pr = std::max_element (
        std::begin(input), std::end(input),
            [] (const std::pair<std::string,unsigned> & p1, const std::pair<std::string,unsigned> & p2) {
            return p1.second < p2.second;
            }
    );

    uint64_t n = pr-> second;

    n--;
    n |= n >> 1;   // Divide by 2^k for consecutive doublings of k up to 32,
    n |= n >> 2;   // and then or the results.
    n |= n >> 4;
    n |= n >> 8;
    n |= n >> 16;
    n |= n >> 32; 
    n++;

    return (log2(n)-1);

}