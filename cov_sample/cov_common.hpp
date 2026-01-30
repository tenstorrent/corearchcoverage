//  SPDX-FileCopyrightText: © 2026 Tenstorrent AI ULC
//  SPDX-License-Identifier: Apache-2.0
#include <stdint.h>
#pragma once
namespace CovCommon { 
  typedef struct  {
    uint64_t cp;
    uint64_t val;
    uint64_t isLastPkt;
  } cp_pkt;

  extern "C" { 
  	void sample_sv(const cp_pkt*);
  	int runC(const char* tracer_path);
  };
}