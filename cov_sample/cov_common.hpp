#include <stdint.h>
#pragma once
namespace CovCommon { 
  typedef struct  {
    uint64_t cp;
    uint64_t val;
    uint64_t isLastPkt;
  } cp_pkt;

  //DPI functions : 
  //sample_sv : Exported function from SV to send an ordered array for sampled values to SV. 
  //run()     : Exported task from SV for running C program. This is a redundant function if whisper is driving the sim. 
  extern "C" { 
  	void sample_sv(const cp_pkt*);
  	int runC(const char* tracer_path);
  };
}