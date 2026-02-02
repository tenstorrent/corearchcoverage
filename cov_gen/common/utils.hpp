
//Utility to convert a string to lowercase 
std::string convert_to_lowercase(std::string data);

//Utility to convert a string to uppercase
std::string convert_to_uppercase(std::string data);

//Converts a set to a comma seperated string. 
std::string convert_set_to_string(std::set<uint32_t> binVals);

//Converts a vector to a comma separated string.
std::string convert_vector_to_string(std::vector<std::string> binVals);

//Replaces and "." with "_" to comply with syntatical rules of SystemVerilog
void format_cg_name (std::string& input);

//Removes any leading whitespaces in the string
std::string trim(const std::string& str, const std::string& whitespace = " \t");

//Returns the bit width required to represent the value of an enum
int find_max_bit_width_for_enum (std::unordered_map<std::string,unsigned> input);

template<typename T>
void sort_vector_pairs(std::vector<std::pair<std::string,T>>& vecData) {
    std::sort(vecData.begin(), vecData.end(), [](auto &left, auto &right) {
        return left.first < right.first;
    });
}