`ifndef COVERAGE_UNSUPPORTED
import cov_common::*;
import user_cov_common::*;
`endif

class arch_cov_sample;

  `ifndef COVERAGE_UNSUPPORTED

  //Map to maintain sampled coverpoints on a instruction boundary.
  cp_table table;

  attr_cov_sample     attr_cov;
  csr_cov_sample      csr_cov;
  enum_cov_sample     enum_cov;
  instr_cov_sample    instr_cov;
  user_cov_sample     user_cov;
  function new();
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
  
  int whisper_step = 1;

  function void sample_sv(input cp_pkt pkt);

    if($test$plusargs("debug"))
      $display("step %d rec cp and val %p",whisper_step,pkt);

    if(pkt.isLastPkt) begin
      table.insert_cp(pkt);
      sample_covergroups();
      table.clear_cp_q();
      whisper_step++;
    end else begin
      table.insert_cp(pkt);
    end
    
  endfunction
  `endif

endclass
