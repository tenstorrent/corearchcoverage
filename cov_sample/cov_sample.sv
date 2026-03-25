 `ifndef COVERAGE_UNSUPPORTED
 import cov_common::*;
 import user_cov_common::*;
  `endif

 module arch_sample;

    `ifndef COVERAGE_UNSUPPORTED
        arch_cov_sample cov_sample = new();
    `endif

    export "DPI-C" function sample_sv;

    `ifndef COVERAGE_UNSUPPORTED
    function void sample_sv(input cp_pkt pkt);
        cov_sample.sample_sv(pkt);
    endfunction
    `else
    function void sample_sv();
        $error("coverage unsupported");
    endfunction
    `endif

    `ifdef STANDALONE_COV
    import "DPI-C" context function bit launch64(string json_path, string tracer_path, string bootrom_path, string prog_path, int max_instr, int print_reset_state, int tlb_entries);
    initial begin
        string tracer_path, json_path, bootrom_path, prog_path;
        int max_instr, tlb_entries;
        int print_reset_state = 0;
        bit launch_return = 0;
        $value$plusargs("archsample_lib_path=%s", tracer_path);
        $value$plusargs("whisper_json_path=%s", json_path);
        $value$plusargs("bootrom_path=%s", bootrom_path);
        $value$plusargs("load=%s", prog_path);
        if (!$value$plusargs("whisper_tlb_size=%d", tlb_entries)) begin
            tlb_entries = -1;
        end
        
        if ($test$plusargs("print_reset_state")) begin 
            print_reset_state = 1;
        end

        if (!$value$plusargs("max_instr=%d", max_instr)) begin
            max_instr = 1000000;
        end;
        launch_return = launch64(json_path, tracer_path, bootrom_path, prog_path, max_instr, print_reset_state, tlb_entries);
        if (launch_return != 1 )
            $display("Error: coverage launch returned false");
        $display("[RVTESTER]: exiting gracefully");
        $finish;

    end
    `else
    import "DPI-C" context function void archcov_set_scope();
    initial begin
        archcov_set_scope();
    end
    `endif

  endmodule
