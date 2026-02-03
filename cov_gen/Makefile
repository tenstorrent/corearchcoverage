# Compiler and flags
CXX = /opt/rh/gcc-toolset-11/root/bin/g++
CXXFLAGS = -Wall -Wextra -std=c++20 -O3 -DMAGIC_ENUM_RANGE_MAX=1024 -DMAGIC_ENUM_RANGE_MIN=-1024
LDFLAGS =

# Directories
SRCDIR = .
COMMON_DIR = ./common

WHISPER_DIR = ../whisper
WHISPER_BUILD_DIR = $(WHISPER_DIR)/build-$(shell uname -s)
WHISPER_LIB = rvcore

MAGIC_ENUM_DIR = ../magic_enum/include

# Boost library configuration
# BOOST_DIR can be set from command line: make BOOST_DIR=/path/to/boost
BOOST_DIR  = /tools_vendor/FOSS/boost/1.78
BOOST_INC  = $(BOOST_DIR)/include
BOOST_LIB_DIR = $(BOOST_DIR)/lib
BOOST_LIBS = boost_program_options

SOFTFLOAT_DIR = ../whisper/third_party/softfloat/build/RISCV-GCC
SOFTFLOAT_LIB = softfloat.a

VIRTUAL_MEM_DIR = ../whisper/virtual_memory
VIRTUAL_MEM_LIB = libvirtual_memory.a

PCI_DIR = ../whisper/pci
PCI_LIB = libpci.a

# Third-party includes
THIRD_PARTY_DIR := $(WHISPER_DIR)/third_party

# Additional libraries
EXTRA_LIBS := -lpthread -lm -lz -ldl -lrt -lutil

# Project name and output
PROJECT := cov_gen
BUILD_DIR := build
TARGET := $(BUILD_DIR)/$(PROJECT)

# Main source
MAIN_SRC := main.cpp
MAIN_OBJ := $(BUILD_DIR)/main.o

# Source files in cov_gen directory
COV_GEN_SRCS := cov_gen.cpp csrs.cpp vector.cpp Info.cpp
COV_GEN_OBJS := $(COV_GEN_SRCS:%.cpp=$(BUILD_DIR)/%.o)

# Include paths
INCLUDES = -I$(SRCDIR) \
	   -I$(COMMON_DIR) \
	   -I$(WHISPER_DIR) \
	   -I$(MAGIC_ENUM_DIR) \
	   -I$(BOOST_INC) \
	   -I$(THIRD_PARTY_DIR)

# Library paths and libraries
LIBDIRS = -L$(BOOST_LIB_DIR) \
		  -L$(WHISPER_BUILD_DIR) \
		  -L$(SOFTFLOAT_DIR)

LIBS = -l$(BOOST_LIBS) $(EXTRA_LIBS) -l$(WHISPER_LIB) 

#==============================================================================
# Main targets
#==============================================================================
all: $(TARGET)

# Create build directory
$(BUILD_DIR):
	@mkdir -p $(BUILD_DIR)

# Compile main.cpp
$(MAIN_OBJ): $(MAIN_SRC) | $(BUILD_DIR)
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) $(INCLUDES) -c $< -o $@

# Compile cov_gen source files
$(BUILD_DIR)/%.o: %.cpp | $(BUILD_DIR)
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) $(INCLUDES) -c $< -o $@

# Link the executable
$(TARGET): $(MAIN_OBJ) $(COV_GEN_OBJS) 
	$(CXX) $(CXXFLAGS) -Wl,-rpath=$(BOOST_LIB_DIR) -o $@ $^ $(LIBDIRS) $(LIBS) $(SOFTFLOAT_DIR)/$(SOFTFLOAT_LIB) $(VIRTUAL_MEM_DIR)/$(VIRTUAL_MEM_LIB) $(PCI_DIR)/$(PCI_LIB) 

#==============================================================================
# Clean
#==============================================================================

clean:
	rm -rf $(BUILD_DIR)

# Print variables for debugging
print-vars:
	@echo "CXX: $(CXX)"
	@echo "CXXFLAGS: $(CXXFLAGS)"
	@echo "CPPFLAGS: $(CPPFLAGS)"
	@echo "INCLUDES: $(INCLUDES)"
	@echo "LIB_DIRS: $(LIBDIRS)"
	@echo "LIBS: $(LIBS)"
	@echo "COV_GEN_SRCS: $(COV_GEN_SRCS)"
	@echo "COV_GEN_OBJS: $(COV_GEN_OBJS)"
	@echo "WHISPER_LIB: $(WHISPER_LIB)"
