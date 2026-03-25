`ifndef USER_COV_SAMPLE_SV
`define USER_COV_SAMPLE_SV
`ifndef COVERAGE_UNSUPPORTED
import cov_common::*;
import cp_pkg::*;
import user_cov_common::*;

class user_cov_sample;

    cp_table table;
    csr_cov_sample csr_cov_local ; 
    
    aext__cg        aext_cg_var;
    //cext__cg        cext_cg_var;
    //dext__cg        dext_cg_var ;
    //fext__cg        fext_cg_var;
    //iext__cg        iext_cg_var;
    //mext__cg        mext_cg_var;
    //zfhext__cg      zfhext_cg_var;

    function new(csr_cov_sample csr_cov);
        csr_cov_local     = csr_cov;
        aext_cg_var       = new();
        //mext_cg_var       = new();
        //iext_cg_var       = new();
        //fext_cg_var       = new();
        //dext_cg_var       = new();
        //zfhext_cg_var     = new();
        //cext_cg_var       = new();
    endfunction
    
    function void sample_commmon(); 
        
        if(table.exists(POINT_OP0))    begin rd      = table.get_cp_val(POINT_OP0);    end
        if(table.exists(POINT_OP1))    begin rs1     = table.get_cp_val(POINT_OP1);    end
        if(table.exists(POINT_OP2))    begin rs2     = table.get_cp_val(POINT_OP2);    end
        if(table.exists(POINT_OP3))    begin rs3     = table.get_cp_val(POINT_OP3);    end
        if(table.exists(POINT_OP0VAL)) begin rd_val  = table.get_cp_val(POINT_OP0VAL); end
        if(table.exists(POINT_OP1VAL)) begin rs1_val = table.get_cp_val(POINT_OP1VAL); end
        if(table.exists(POINT_OP2VAL)) begin rs2_val = table.get_cp_val(POINT_OP2VAL); end
        if(table.exists(POINT_OP3VAL)) begin rs3_val = table.get_cp_val(POINT_OP3VAL); end
        
        if(table.exists(POINT_BRTAKEN)) begin
            $cast(br_taken, table.get_cp_val(POINT_BRTAKEN));
        end

        if(table.exists(POINT_CSRVALUE)) begin 
            $cast(csr_val, table.get_cp_val(POINT_CSRVALUE));
        end
     
        if(table.exists(POINT_EXCEPTION)) begin match_excp = 1; end
        
        reservation_valid_prev = reservation_valid_current;
        if (table.exists(POINT_VALIDLR)) begin
            $cast(reservation_valid_current, table.get_cp_val(POINT_VALIDLR));
        end

    endfunction

    function void clear(); // clear value to avoid again and again match
        
        br_taken   = 1;
        match_excp = 0;
        
    endfunction
    
    function void sample_sv_user(cp_table user_table);
        table = user_table;
        sample_commmon();
        //mext_cg_var.sample();
        //iext_cg_var.sample();
        aext_cg_var.sample(csr_cov_local);
        //fext_cg_var.sample(csr_cov_local);
        //dext_cg_var.sample(csr_cov_local);
        //zfhext_cg_var.sample(csr_cov_local);
        //cext_cg_var.sample(csr_cov_local);
        clear();
    endfunction
endclass
`endif
`endif
