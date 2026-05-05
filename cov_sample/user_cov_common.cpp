#include <algorithm>
#include <array>
#include <cstdint>
#include <stdexcept>
#include "virtual_memory/VirtMem.hpp"

using namespace WdRiscv;

extern "C" {
    // Returns the leaf PTE and non-leaf PTE as output parameters
    void get_leaf_nonleaf_ptes(
        uint64_t pte1, uint64_t pte2, uint64_t pte3, uint64_t pte4, uint64_t pte5,
        int start_level, int end_level, uint64_t *leaf_pte, uint64_t *nonleaf_pte
    ) {
        // If no levels are found (start_level == 0), return 0 for both
        if (start_level == 0 || end_level == 0) {
            *leaf_pte = 0;
            *nonleaf_pte = 0;
            return;
        }
        
        // Create array of Pte57 objects from the input parameters
        // For finding leaves, the paging mode doesn't matter, so for
        // simplicity we always use Pte57
        std::array<Pte57, 5> ptes = {pte1, pte2, pte3, pte4, pte5};
        
        // Lambda to validate and convert 1-based level to 0-based index
        auto validate_level = [](int level, const char* level_name) -> int {
            if (level < 1 || level > 5) {
                throw std::invalid_argument(std::string(level_name) + " must be between 1 and 5");
            }
            return level - 1;  // Convert to 0-based indexing
        };
        
        int start_idx = validate_level(start_level, "start_level");
        int end_idx = validate_level(end_level, "end_level");
        
        if (end_idx < start_idx) {
            throw std::invalid_argument("end_level must be >= start_level");
        }
        
        // Only search from start_level to end_level (inclusive)
        auto start_it = std::begin(ptes) + start_idx;
        auto end_it = std::begin(ptes) + end_idx + 1;  // +1 because end() is one past the last element
        
        if (start_it->leaf()) {
            // We found a leaf
            *leaf_pte = start_it->data_;
            // Non-leaf is the entry after the leaf if it exists, otherwise 0
            *nonleaf_pte = (start_it + 1) < end_it ? (start_it + 1)->data_ : 0;
            return;
        }

        // No leaf
        // The lowest level (first checked PTE) is the non-leaf
        *leaf_pte = 0;
        *nonleaf_pte = start_it->data_;
    }
} 
