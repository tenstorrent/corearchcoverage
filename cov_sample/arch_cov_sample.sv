//  SPDX-FileCopyrightText: © 2026 Tenstorrent AI ULC
//  SPDX-License-Identifier: Apache-2.0
`ifndef COVERAGE_UNSUPPORTED

import cov_common::*;
import user_cov_common::*;

class arch_cov_sample;
  
  cp_table            table;
  attr_cov_sample     attr_cov;
  csr_cov_sample      csr_cov;
  enum_cov_sample     enum_cov;
  instr_cov_sample    instr_cov;
  user_cov_sample     user_cov;
  int whisper_step;
  
  function new();
    whisper_step = 1;
    table     = new();
    attr_cov  = new();
    csr_cov   = new();
    enum_cov  = new();
    instr_cov = new();
    user_cov  = new(csr_cov);
  endfunction

  function void sample_covergroups();
    instr_cov.sample_sv_instr(table);
    csr_cov.sample_sv_csr(table);
    attr_cov.sample(table);
    enum_cov.sample(table);
    user_cov.sample_sv_user(table);
  endfunction
  
  function void sample_sv(input cp_pkt pkt);

    int len;
    if($test$plusargs("debug"))
      $display("step %d rec cp and val %p",whisper_step,pkt);

    if(pkt.isLastPkt) begin
      table.insert_cp(pkt);
      len = table.cp_q_len();
      sample_covergroups();
      table.clear_cp_q();
      whisper_step++;
    end else begin
      table.insert_cp(pkt);
    end
    
  endfunction

endclass

`endif
