//  SPDX-FileCopyrightText: © 2026 Tenstorrent AI ULC
//  SPDX-License-Identifier: Apache-2.0
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
    cext__cg        cext_cg_var;
    dext__cg        dext_cg_var ;
    fext__cg        fext_cg_var;
    iext__cg        iext_cg_var;
    mext__cg        mext_cg_var;
    zfhext__cg      zfhext_cg_var;
    sstc__cg        sstc_cg_var;
    zicond__cg      zicond_cg_var;

    function new(csr_cov_sample csr_cov);
        csr_cov_local     = csr_cov;
        aext_cg_var       = new();
        cext_cg_var       = new();
        mext_cg_var       = new();
        iext_cg_var       = new();
        fext_cg_var       = new();
        dext_cg_var       = new();
        zfhext_cg_var     = new();
        sstc_cg_var       = new();
        zicond_cg_var     = new();
    endfunction
    
    function void sample_commmon(); 
        
        if(table.exists(POINT_OP0))    begin rd      = Inst[11:7];   end
        if(table.exists(POINT_OP1))    begin rs1     = Inst[19:15];  end
        if(table.exists(POINT_OP2))    begin rs2     = Inst[24:20];  end
        if(table.exists(POINT_OP3))    begin rs3     = Inst[31:27];  end
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
     
        if(table.exists(POINT_EXCEPTION)) begin match_excp = 1; in_excp_handler = 1; end

        if(table.exists(POINT_INTERRUPT)) begin 
            interrupt_taken = 1; 
            in_intr_handler = 1; 
        end

        if(instrenum_var inside {INSTRENUM_ECALL, INSTRENUM_MRET, INSTRENUM_SRET}) begin
            in_excp_handler = 0;
            in_trigger_handler = 0;
            in_intr_handler = 0;
        end
        
        reservation_valid_prev = reservation_valid_current;
        if (table.exists(POINT_VALIDLR)) begin
            $cast(reservation_valid_current, table.get_cp_val(POINT_VALIDLR));
        end

        if(rs2 == CSRENUM_TIME && instrenum_var inside {INSTRENUM_CSRRW,
                                                        INSTRENUM_CSRRWI,
                                                        INSTRENUM_CSRRC,
                                                        INSTRENUM_CSRRCI,
                                                        INSTRENUM_CSRRS,
                                                        INSTRENUM_CSRRSI}) begin
            time_val = rs2_val;
        end

        if(table.exists(POINT_TRIGGER)) begin 
            match_trigger = 1;
            in_trigger_handler = 1;
            $cast(Trigger, table.get_cp_val(POINT_TRIGGER));
        end

        if (table.exists(POINT_INST)) begin
            classify_csr_instruction(Inst);
        end

        if (instrenum_var inside {
                            INSTRENUM_LB,
                            INSTRENUM_LBU,
                            INSTRENUM_LD,
                            INSTRENUM_LH,
                            INSTRENUM_LHU,
                            INSTRENUM_LW,
                            INSTRENUM_LWU,
                            INSTRENUM_C_FLD,
                            INSTRENUM_C_LD,
                            INSTRENUM_C_LW,
                            INSTRENUM_C_FLDSP,
                            INSTRENUM_C_LDSP,
                            INSTRENUM_C_LWSP}) begin
            match_instr_load = 1;
        end 


        if (instrenum_var inside {
                            INSTRENUM_SB,
                            INSTRENUM_SD,
                            INSTRENUM_SH,
                            INSTRENUM_SW,
                            INSTRENUM_C_SW,
                            INSTRENUM_C_SD,
                            INSTRENUM_C_FSD,
                            INSTRENUM_C_SWSP,
                            INSTRENUM_C_SDSP,
                            INSTRENUM_C_FSDSP}) begin
            match_instr_store = 1;
        end

        if (instrenum_var inside {
            	INSTRENUM_AMOADD_W,
		        INSTRENUM_AMOAND_D,
		        INSTRENUM_AMOAND_W,
		        INSTRENUM_AMOMAX_D,
		        INSTRENUM_AMOMAX_W,
		        INSTRENUM_AMOMAXU_D,
		        INSTRENUM_AMOMAXU_W,
		        INSTRENUM_AMOMIN_D,
		        INSTRENUM_AMOMIN_W,
		        INSTRENUM_AMOMINU_D,
		        INSTRENUM_AMOMINU_W,
		        INSTRENUM_AMOOR_D,
		        INSTRENUM_AMOOR_W,
		        INSTRENUM_AMOSWAP_D,
		        INSTRENUM_AMOSWAP_W,
		        INSTRENUM_AMOXOR_D,
		        INSTRENUM_AMOXOR_W,
		        INSTRENUM_LR_D,
		        INSTRENUM_LR_W,
		        INSTRENUM_SC_D,
		        INSTRENUM_SC_W}) begin 
            match_aext = 1;
        end 

        if (instrenum_var inside {
                INSTRENUM_FENCE,
                INSTRENUM_FENCE_I,
                INSTRENUM_FENCE_TSO,
                INSTRENUM_SFENCE_VMA,
                INSTRENUM_SINVAL_VMA}) begin 
            match_mem_sync = 1;
        end  


        if (instrenum_var inside {
                INSTRENUM_HFENCE_GVMA,
                INSTRENUM_HFENCE_VVMA,
                INSTRENUM_HINVAL_GVMA,
                INSTRENUM_HINVAL_VVMA}) begin 
            match_hext_mem_sync = 1;
        end  

        if (instrenum_var inside {
                INSTRENUM_HLV_B,
                INSTRENUM_HLV_D,
                INSTRENUM_HLV_H,
                INSTRENUM_HLV_W,
                INSTRENUM_HLV_BU,
                INSTRENUM_HLV_HU,
                INSTRENUM_HLV_WU,
                INSTRENUM_HLVX_HU,
                INSTRENUM_HLVX_WU,
                INSTRENUM_HSV_B,
                INSTRENUM_HSV_H,
                INSTRENUM_HSV_W,
                INSTRENUM_HSV_D}) begin 
            match_hext_ld_st = 1;
        end  

        if (instrenum_var inside {
                INSTRENUM_CBO_ZERO}) begin 
            match_zicbozext = 1;
        end 

        if (instrenum_var inside {
                INSTRENUM_CBO_CLEAN,
                INSTRENUM_CBO_FLUSH,
                INSTRENUM_CBO_INVAL}) begin 
            match_zicbomext = 1;
        end 

        if($cast(dext_var, table.get_cp_val(POINT_INSTID))) begin 
            match_dext = 1;                       
        end

        if($cast(fext_var, table.get_cp_val(POINT_INSTID))) begin 
            match_fext = 1;                       
        end

        if($cast(vext_var, table.get_cp_val(POINT_INSTID))) begin 
            match_vext = 1;                       
        end

        // Determine the lowest and highest levels for FVPTE
        get_pte_level_range(table, '{POINT_FVPTE_LEVEL1, POINT_FVPTE_LEVEL2, POINT_FVPTE_LEVEL3, POINT_FVPTE_LEVEL4, POINT_FVPTE_LEVEL5}, FVPTE_LowestLevel, FVPTE_HighestLevel);
        
        // Set FVPTELeaf and FVPTENonLeaf
        get_leaf_nonleaf_ptes(FVPTE_Level1, FVPTE_Level2, FVPTE_Level3, FVPTE_Level4, FVPTE_Level5, FVPTE_LowestLevel, FVPTE_HighestLevel, FVPTELeaf, FVPTENonLeaf);

    endfunction

    function sample_csr_states();
        csrType temp_csr;
        
        prev_mstatus_csr = cur_mstatus_csr;
        temp_csr = table.get_csr(cp_pkg::CSRENUM_MSTATUS);
        if(temp_csr != null) begin
			cur_mstatus_csr     = temp_csr.value;
        end

        prev_sstatus_csr = cur_sstatus_csr;
        temp_csr = table.get_csr(cp_pkg::CSRENUM_SSTATUS);
        if(temp_csr != null) begin
			cur_sstatus_csr = temp_csr.value;
        end

        prev_hstatus_csr = cur_hstatus_csr;
        temp_csr = table.get_csr(cp_pkg::CSRENUM_HSTATUS);
        if(temp_csr != null) begin
			cur_hstatus_csr = temp_csr.value;
        end

        prev_vsstatus_csr = cur_vsstatus_csr;
        temp_csr = table.get_csr(cp_pkg::CSRENUM_VSSTATUS);
        if(temp_csr != null) begin
			cur_vsstatus_csr = temp_csr.value;
        end

        prev_medeleg_csr = cur_medeleg_csr;
        temp_csr = table.get_csr(cp_pkg::CSRENUM_MEDELEG);
        if(temp_csr != null) begin
			cur_medeleg_csr = temp_csr.value;
        end

        prev_hedeleg_csr = cur_hedeleg_csr;
        temp_csr = table.get_csr(cp_pkg::CSRENUM_HEDELEG);
        if(temp_csr != null) begin
			cur_hedeleg_csr = temp_csr.value;
        end

        prev_satp_csr = cur_satp_csr;
        temp_csr = table.get_csr(cp_pkg::CSRENUM_SATP);
        if(temp_csr != null) begin
			cur_satp_csr = temp_csr.value;
        end

        prev_vsatp_csr = cur_vsatp_csr;
        temp_csr = table.get_csr(cp_pkg::CSRENUM_VSATP);
        if(temp_csr != null) begin
			cur_vsatp_csr = temp_csr.value;
        end

        prev_hgatp_csr = cur_hgatp_csr;
        temp_csr = table.get_csr(cp_pkg::CSRENUM_HGATP);
        if(temp_csr != null) begin
			cur_hgatp_csr = temp_csr.value;
        end

    endfunction


    function void clear(); 
        br_taken   = 1;
        match_excp = 0;
        match_trigger = 0;
        interrupt_taken = 0;
        match_csr_r_instr = 0;
        match_csr_w_instr = 0;
        match_instr_load = 0;
        match_instr_store = 0;
        match_aext = 0;
        match_mem_sync = 0;
        match_hext_mem_sync = 0;
        match_hext_ld_st = 0;
        match_zicbozext = 0;
        match_zicbomext = 0; 
    endfunction
    
    function void sample_sv_user(cp_table user_table);
        table = user_table;
        sample_commmon();
        sample_csr_states();
        mext_cg_var.sample();
        iext_cg_var.sample();
        aext_cg_var.sample(csr_cov_local);
        fext_cg_var.sample(csr_cov_local);
        dext_cg_var.sample(csr_cov_local);
        zfhext_cg_var.sample(csr_cov_local);
        cext_cg_var.sample(csr_cov_local);
        sstc_cg_var.sample(csr_cov_local);
        zicond_cg_var.sample(csr_cov_local);
        clear();
    endfunction
endclass
`endif
`endif
