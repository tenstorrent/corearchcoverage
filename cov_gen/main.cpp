#include <iostream>
#include "Hart.hpp"
#include "HartConfig.hpp"
#include "Core.hpp"
#include "System.hpp"
#include "third_party/nlohmann/json.hpp"
#include "cov_gen.hpp"

using namespace WdRiscv;

// dummy function
void (*tracerExtension)(void*) = nullptr;

template<typename URV>
static
bool
staticDump(Hart<URV>& hart, std::string filename)
{
  CovGen<URV> cov_gen(hart, filename);
  cov_gen.generateCpPackage();
  return true;
}


// heavily copy from whisper.cpp main, everything should be in json configuration
template <typename URV>
static
bool
session(const HartConfig& config, const std::string& filename)
{
  // Collect primary configuration paramters.
  unsigned hartsPerCore = 1;
  unsigned coreCount = 1;
  size_t pageSize = 4*1024;
  size_t memorySize = size_t(1) << 31;

  // Create cores & harts.
  unsigned hartIdOffset = hartsPerCore;
  System<URV> system(coreCount, hartsPerCore, hartIdOffset, memorySize, pageSize);
  assert(system.hartCount() == coreCount*hartsPerCore);
  assert(system.hartCount() > 0);

  if (not config.hasCsrConfig("misa"))
    {
      std::cerr << "No MISA specified, must include in configuration\n";
      return false;
    }

  unsigned xlen;
  config.getXlen(xlen);

  std::string isa;
  if (not config.getIsa(isa))
    {
      std::cerr << "Must specify isa in configuration\n";
      return false;
    }

  if (not config.configHarts(system, false, false))
    return false;

  for (unsigned i = 0; i < system.hartCount(); ++i)
    {
      auto& hart = *system.ithHart(i);
      hart.configIsa(isa, false);
      hart.reset();
    }

  // Static analysis of ISA, do not run program
  return staticDump(*system.ithHart(0), filename);
}

int
main(int argc, char* argv[])
{
  // Load configuration file.
  if (argc < 3)
    {
      std::cerr << "Must include whisper configuration  as arguments\n";
      return 1;
    }

  std::string configFile = argv[1];
  HartConfig config;
  if (not config.loadConfigFile(configFile))
    return 1;

  unsigned regWidth;
  if (not config.getXlen(regWidth))
    {
      std::cerr << "User must specify XLEN in json configuration\n";
      return 1;
    }

  bool ok = true;

  try
    {
      if (regWidth == 32)
	ok = session<uint32_t>(config, argv[2]);
      else if (regWidth == 64)
	ok = session<uint64_t>(config, argv[2]);
      else
	{
	  std::cerr << "Invalid register width: " << regWidth;
	  std::cerr << " -- expecting 32 or 64\n";
	  ok = false;
	}
    }
  catch (std::exception& e)
    {
      std::cerr << e.what() << '\n';
      ok = false;
    }
  return ok? 0 : 1;
}
