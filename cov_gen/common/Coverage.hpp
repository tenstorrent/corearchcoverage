#pragma once

#include <string>
#include <vector>

namespace ArchCov {

    class Bin {
        public:
            Bin() {
               isArray = 0;
               isSpecialBin = 0;
               arrSize = "";
            }
            bool isArray;
            bool isSpecialBin;

            std::string arrSize;
            std::string name;
            std::string vals;
            std::string content;

    };

    class CoverPoint {
        public:
            std::string name;
            std::vector<Bin> bins;
            bool isEnum;
    };

    class CoverGroup {
        public:
            std::string name;
            std::vector<std::pair<std::string,std::string>> bitmasks;
            std::string qualifier;
            std::vector<std::string> inputs;
            std::vector<CoverPoint>  cps;
    };
}
