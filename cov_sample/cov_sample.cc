//  SPDX-FileCopyrightText: © 2026 Tenstorrent AI ULC
//  SPDX-License-Identifier: Apache-2.0
#include <vector>
#include <thread>
#include <atomic>
#include <dlfcn.h>
#include <iostream>
#include "cov_sample_interface.hpp"
#include "cov_common.hpp"
#include "System.hpp"
#include "HartConfig.hpp"
#include "Hart.hpp"
#include "CsRegs.hpp"
#include "InstEntry.hpp"
#include "Sample.hpp"

using namespace std;
using namespace WdRiscv;
using namespace ArchCov;
using namespace CovCommon;

extern void (*__tracerExtension)(void*);
static covSampleInterface interface;

extern "C" void trace(arch_t& table) {
  interface.sample_packets(table);
}

std::string csrNumberToString(CsrNumber csrNum) {
  switch (csrNum) {
    case CsrNumber::MSTATUS: return "MSTATUS";
    case CsrNumber::MNSTATUS: return "MNSTATUS";
    case CsrNumber::MENVCFG: return "MENVCFG";
    case CsrNumber::MISA: return "MISA";
    case CsrNumber::MIE: return "MIE";
    case CsrNumber::MIP: return "MIP";
    case CsrNumber::MVIEN: return "MVIEN";
    case CsrNumber::MVIP: return "MVIP";
    case CsrNumber::MEDELEG: return "MEDELEG";
    case CsrNumber::MIDELEG: return "MIDELEG";
    case CsrNumber::MSECCFG: return "MSECCFG";
    case CsrNumber::SENVCFG: return "SENVCFG";
    case CsrNumber::SATP: return "SATP";
    case CsrNumber::SSTATUS: return "SSTATUS";
    case CsrNumber::SIE: return "SIE";
    case CsrNumber::SIP: return "SIP";
    case CsrNumber::HSTATUS: return "HSTATUS";
    case CsrNumber::HENVCFG: return "HENVCFG";
    case CsrNumber::HGATP: return "HGATP";
    case CsrNumber::HIE: return "HIE";
    case CsrNumber::HIP: return "HIP";
    case CsrNumber::HVIEN: return "HVIEN";
    case CsrNumber::HVIP: return "HVIP";
    case CsrNumber::HGEIE: return "HGEIE";
    case CsrNumber::HGEIP: return "HGEIP";
    case CsrNumber::HEDELEG: return "HEDELEG";
    case CsrNumber::HIDELEG: return "HIDELEG";
    case CsrNumber::HVICTL: return "HVICTL";
    case CsrNumber::VSSTATUS: return "VSSTATUS";
    case CsrNumber::VSATP: return "VSATP";
    case CsrNumber::VSIE: return "VSIE";
    case CsrNumber::VSIP: return "VSIP";
    default: return "UNKNOWN";
  }
}


template <typename URV>
void sampleResetState(Hart<URV>& hart, int printResetState = 0) {
  std::vector<CsrNumber> csr_list = {
    CsrNumber::MSTATUS,
    CsrNumber::MENVCFG,
    CsrNumber::MISA,
    CsrNumber::MIE,
    CsrNumber::MIP,
    CsrNumber::MVIEN,
    CsrNumber::MVIP,
    CsrNumber::MEDELEG,
    CsrNumber::MIDELEG,
    CsrNumber::MSECCFG,
    CsrNumber::SENVCFG,
    CsrNumber::SATP,
    CsrNumber::SSTATUS,
    CsrNumber::SIE,
    CsrNumber::SIP,
    CsrNumber::HSTATUS,
    CsrNumber::HENVCFG,
    CsrNumber::HGATP,
    CsrNumber::HIE,
    CsrNumber::HIP,
    CsrNumber::HVIEN,
    CsrNumber::HVIP,
    CsrNumber::HGEIE,
    CsrNumber::HGEIP,
    CsrNumber::HEDELEG,
    CsrNumber::HIDELEG,
    CsrNumber::HVICTL,
    CsrNumber::VSSTATUS,
    CsrNumber::VSATP,
    CsrNumber::VSIE,
    CsrNumber::VSIP,
  };
  URV value;
  arch_t table;
  for(auto csr : csr_list) {
    if(hart.peekCsr(csr, value)) {
      table.addEntry(Point::CsrNum, URV(csr));
      table.addEntry(Point::CsrValue, value);
    }
  }
  if(printResetState) {
    for(auto entry : table.entries_) {
      if(entry.first == uint32_t(Point::CsrNum)) {
        std::cout << "csr: " << csrNumberToString(CsrNumber(entry.second)) << std::endl;
      } else if(entry.first == uint32_t(Point::CsrValue)) {
        std::cout << " value: " << std::hex << entry.second << std::endl;
      }
    }
  }
  trace(table);
}


template <typename URV>
bool launch(char* json_path, char* tracer_path, char* bootrom, char* program, long long max_instr, int printResetState, int tlb_entries) {
  WdRiscv::HartConfig config;
  if (not config.loadConfigFile(json_path))
    return false;

  unsigned hartsPerCore = 1;
  unsigned coreCount = 1;
  unsigned hartIdOffset = hartsPerCore;
  size_t pageSize = 4*1024;
  size_t memorySize = size_t(1) << 31;
  std::string isa;
  config.getHartsPerCore(hartsPerCore);
  config.getCoreCount(coreCount);
  config.getHartIdOffset(hartIdOffset);
  config.getPageSize(pageSize);
  config.getMemorySize(memorySize);
  config.getIsa(isa);

  WdRiscv::System<URV> sys = WdRiscv::System<URV>(coreCount, hartsPerCore, hartIdOffset, memorySize, pageSize);

  std::vector<std::string> targets {};
  if (strcmp(bootrom, "") != 0)
    targets.push_back(bootrom);
  targets.push_back(program);
  if (not sys.loadElfFiles(targets, false, false))
    return false;

  if (not config.configHarts(sys, false, false))
    return false;

  if (not config.configMemory(sys, false))
    return false;

  for (unsigned i = 0; i < sys.hartCount(); ++i) {
    auto& hart = *(sys.ithHart(i));
    hart.enableNewlib(false);
    hart.enableLinux(false);
    hart.tracePtw(true);
    hart.redirectOutputDescriptor(STDOUT_FILENO, "/dev/null");
    hart.redirectOutputDescriptor(STDIN_FILENO, "/dev/null");
    if (not isa.empty())
      if (not hart.configIsa(isa, false))
        return false;
    if (strcmp(bootrom, "") != 0)
      hart.defineResetPc(0x10000);
    hart.reset();
    sampleResetState(hart, printResetState);
    config.applyImsicConfig(sys); 
    hart.tracePmp(true);
    hart.tracePma(true);
    hart.setInstructionCountLimit(max_instr);
    if (tlb_entries >= 0)
      hart.setTlbSize(tlb_entries);
  }

  auto soPtr = dlopen(tracer_path, RTLD_NOW);
  if (not soPtr) {
    std::cerr << "Error: Failed to load shared libarary " << dlerror() << '\n';
    return false;
  }

  std::string entry("tracerExtension");
  entry += sizeof(URV) == 4 ? "32" : "64";

  __tracerExtension = reinterpret_cast<void (*)(void*)>(dlsym(soPtr, entry.c_str()));
  if (not __tracerExtension) {
    std::cerr << "Error: Could not find symbol tracerExtension in " << std::string(tracer_path) << '\n';
    return false;
  }


  std::vector<std::thread> threadVec;

  std::atomic<bool> result = true;
  std::atomic<unsigned> finished = 0;  

  FILE* whisper_log = fopen("whisper.log", "w");

  auto threadFunc = [&result, &finished, whisper_log] (Hart<URV>* hart) {
                      bool r = hart->run(whisper_log);
                      result = result and r;
                      finished++;
                    };

  for (unsigned i = 0; i < sys.hartCount(); ++i) {
    Hart<URV>* hart = sys.ithHart(i).get();
    threadVec.emplace_back(std::thread(threadFunc, hart));
  }

  for (auto& t : threadVec)
    t.join();

  fclose(whisper_log);

  return true;
}

extern "C" {
  bool launch64(char* json_path, char* tracer_path, char* bootrom, char* program, long long max_instr, int printResetState, int tlb_entries) {
    return launch<uint64_t>(json_path, tracer_path, bootrom, program, max_instr, printResetState, tlb_entries);
  }

  bool launch32(char* json_path, char* tracer_path, char* bootrom, char* program, long long max_instr, int printResetState, int tlb_entries) {
    return launch<uint32_t>(json_path, tracer_path, bootrom, program, max_instr, printResetState, tlb_entries);
  }
}
