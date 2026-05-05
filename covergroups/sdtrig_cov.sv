//  SPDX-FileCopyrightText: © 2026 Tenstorrent AI ULC
//  SPDX-License-Identifier: Apache-2.0
`ifndef COVERAGE_UNSUPPORTED

import cp_pkg::*;

covergroup sdtrig__cg with function sample(csr_cov_sample i_csr);

    option.per_instance = 1;
    option.name         = "SdTrig covergroup";

    sdtrig__trig_cp_trigger: coverpoint match_trigger {
        bins tripped1 = {1};
        bins tripped0 = {0};
    }

    sdtrig__gen_cp_valid_priv : coverpoint privilegemode_var {
        option.weight=0;
        ignore_bins rsvd_mode = {PRIVILEGEMODE_RESERVED};
        bins m_mode = {PRIVILEGEMODE_MACHINE};
        bins hs_mode = {PRIVILEGEMODE_SUPERVISOR} iff (VirtualMode == 0);
        bins u_mode = {PRIVILEGEMODE_USER} iff (VirtualMode == 0);
        bins vs_mode = {PRIVILEGEMODE_SUPERVISOR} iff (VirtualMode == 1);
        bins vu_mode = {PRIVILEGEMODE_USER} iff (VirtualMode == 1);
    }

    sdtrig__priv__cp_trig_dest : coverpoint nextprivilegemode_var{
        option.weight=0;
        ignore_bins rsvd = {NEXTPRIVILEGEMODE_USER,NEXTPRIVILEGEMODE_RESERVED};
    }
    
    sdtrig__gen_cr_all_priv : cross sdtrig__gen_cp_valid_priv,sdtrig__trig_cp_trigger; 
    sdtrig__gen_cr_dest_priv : cross sdtrig__priv__cp_trig_dest,sdtrig__trig_cp_trigger; 

    sdtrig__deleg__cp_medeleg_toggle : coverpoint i_csr.medeleg_csr_inst.medeleg[3] 
    iff (exception_var == EXCEPTION_BREAKP ) {
        bins disabled   = {0};
        bins enabled    = {1};
    }

    sdtrig__deleg__cp_hedeleg_toggle : coverpoint i_csr.hedeleg_csr_inst.hedeleg[3] 
    iff (exception_var == EXCEPTION_BREAKP ) {
        bins disabled   = {0};
        bins enabled    = {1};
    }

    sdtrig__csr_cp_access_csr : coverpoint csr_accessed iff (match_csr_w_instr || match_csr_r_instr ){
        bins sdtrig_csrs[] = {
            CSRENUM_TSELECT,
            CSRENUM_TDATA1,
            CSRENUM_TDATA2,
            CSRENUM_TINFO
        };
    }

    sdtrig__csr_cr_trigger_on_csr : cross sdtrig__csr_cp_access_csr,sdtrig__trig_cp_trigger;

    sdtrig__tselect_cp_data : coverpoint i_csr.tselect_csr_inst.select{
        bins fetch_triggers = {[0:3]};
        bins load_store_triggers = {[4:7]};
        bins icount = {8};
    }

    sdtrig__tinfo_cp_info : coverpoint i_csr.tinfo_csr_inst.info{
        bins tinfo = {'h8040};
    }

    sdtrig__tinfo_cp_version : coverpoint i_csr.tinfo_csr_inst.version{
        bins version = {1};
    }

    sdtrig__tdata1_cp_type : coverpoint i_csr.tdata1_csr_inst.ttype {
        bins mcontrol6 = {6};
        bins disabled= {4'hf};
        bins icount= {3};
    }

    sdtrig__tdata1_cp_dmode : coverpoint i_csr.tdata1_csr_inst.dmode {
        bins disabled = {0};
        bins enabled = {1};
    }

    sdtrig__tdata1_cp_uncertain : coverpoint i_csr.tdata1_csr_inst.data[26] 
    iff (i_csr.tdata1_csr_inst.ttype==6){
        bins disabled = {0};
        illegal_bins enabled = {1};
    }

    sdtrig__tdata1_cp_hit1 : coverpoint i_csr.tdata1_csr_inst.data[25] 
    iff (i_csr.tdata1_csr_inst.ttype==6){
        bins disabled = {0};
        illegal_bins enabled = {1};
    }

    sdtrig__tdata1_cp_vs : coverpoint i_csr.tdata1_csr_inst.data[24] 
    iff (i_csr.tdata1_csr_inst.ttype==6){
        bins disabled = {0};
        bins enabled = {1} ;
    }

    sdtrig__tdata1_cp_vu : coverpoint i_csr.tdata1_csr_inst.data[23] 
    iff (i_csr.tdata1_csr_inst.ttype==6){
        bins disabled = {0};
        bins enabled = {1} ;
    } 

    sdtrig__tdata1_cp_hit0 : coverpoint i_csr.tdata1_csr_inst.data[22] 
    iff (i_csr.tdata1_csr_inst.ttype==6){
        bins disabled = {0};
        bins enabled = {1};
    }

    sdtrig__tdata1_cp_select : coverpoint i_csr.tdata1_csr_inst.data[21] 
    iff (i_csr.tdata1_csr_inst.ttype==6){
        bins disabled = {0};
        illegal_bins enabled = {1};
    }

    sdtrig__tdata1_cp_size : coverpoint i_csr.tdata1_csr_inst.data[18:16] 
    iff (i_csr.tdata1_csr_inst.ttype==6){
        bins disabled = {0};
        illegal_bins enabled = {1};
    }

    sdtrig__tdata1_cp_action : coverpoint i_csr.tdata1_csr_inst.data[15:12] 
    iff (i_csr.tdata1_csr_inst.ttype==6){
        bins trigger_bkpt = {0};
    }

    sdtrig__tdata1_cp_chain : coverpoint i_csr.tdata1_csr_inst.data[11] 
    iff (i_csr.tdata1_csr_inst.ttype==6){
        bins disabled = {0};
    }

    sdtrig__tdata1_cp_match : coverpoint i_csr.tdata1_csr_inst.data[10:7] 
    iff (i_csr.tdata1_csr_inst.ttype==6){
        bins equal = {0};
        bins napot = {1};
        bins ge = {2};
        bins lt = {3};
        bins mask_low = {4};
        bins mask_high = {5};
        bins not_equal = {8};
        bins not_napot = {9};
        bins not_mask_low = {12};
        bins not_mask_high = {13};
    }

    sdtrig__tdata1_cp_m : coverpoint i_csr.tdata1_csr_inst.data[6] 
    iff (i_csr.tdata1_csr_inst.ttype==6){
        bins disabled = {0};
        bins enabled = {1};
    }

    sdtrig__tdata1_cp_uncertainen : coverpoint i_csr.tdata1_csr_inst.data[5] 
    iff (i_csr.tdata1_csr_inst.ttype==6){
        bins disabled = {0};
        illegal_bins enabled = {1};
    }

    sdtrig__tdata1_cp_s : coverpoint i_csr.tdata1_csr_inst.data[4] 
    iff (i_csr.tdata1_csr_inst.ttype==6){
        bins disabled = {0};
        bins enabled = {1};
    }

    sdtrig__tdata1_cp_u : coverpoint i_csr.tdata1_csr_inst.data[3] 
    iff (i_csr.tdata1_csr_inst.ttype==6){
        bins disabled = {0};
        bins enabled = {1};
    }

    sdtrig__tdata1_cp_execute : coverpoint i_csr.tdata1_csr_inst.data[2] 
    iff (i_csr.tdata1_csr_inst.ttype==6){
        bins disabled = {0};
        bins enabled = {1};
    }

    sdtrig__tdata1_cp_store : coverpoint i_csr.tdata1_csr_inst.data[1] 
    iff (i_csr.tdata1_csr_inst.ttype==6){
        bins disabled = {0};
        bins enabled = {1};
    }

    sdtrig__tdata1_cp_load : coverpoint i_csr.tdata1_csr_inst.data[0] 
    iff (i_csr.tdata1_csr_inst.ttype==6){
        bins disabled = {0};
        bins enabled = {1};
    }

    sdtrig__tdata2_cp_data : coverpoint i_csr.tdata2_csr_inst.data{
        bins zero = {0};
        bins all_values = default;
    } 
    
    sdtrig__ro_cp_type : cross match_csr_w_instr, sdtrig__tdata1_cp_type
    iff (Inst[31:20] == 'h7a1 && rs1_val[63:60]!=0){ 
        bins csr_write = binsof(sdtrig__tdata1_cp_type) iff (match_csr_w_instr);
    }

    sdtrig__ro_cp_dmode : cross match_csr_w_instr, sdtrig__tdata1_cp_dmode
    iff (Inst[31:20] == 'h7a1 && rs1_val[59]!=0){ 
        bins csr_write = binsof(sdtrig__tdata1_cp_dmode) iff (match_csr_w_instr);
    }

    sdtrig__ro_cp_uncertain : cross match_csr_w_instr, sdtrig__tdata1_cp_uncertain
    iff (Inst[31:20] == 'h7a1 && rs1_val[26]!=0 ){ 
        bins csr_write = binsof(sdtrig__tdata1_cp_uncertain) iff (match_csr_w_instr);
    }

    sdtrig__ro_cp_hit1 : cross match_csr_w_instr, sdtrig__tdata1_cp_hit1
    iff (Inst[31:20] == 'h7a1 && rs1_val[25]!=0){ 
        bins csr_write = binsof(sdtrig__tdata1_cp_hit1) iff (match_csr_w_instr);
    }

    sdtrig__cp_misa_h_disabled : coverpoint i_csr.misa_csr_inst.ext[7]{
        bins disabled = {0};
        bins enabled  = {1};
        option.weight=0;
    }

    sdtrig__ro_cp_vs : cross match_csr_w_instr, sdtrig__tdata1_cp_vs
    iff (Inst[31:20] == 'h7a1   && rs1_val[24]!=0 ){ 
        bins csr_write = binsof(sdtrig__tdata1_cp_vs) iff (match_csr_w_instr && i_csr.misa_csr_inst.ext[7]==0);
    }
    
    sdtrig__ro_cp_vu : cross match_csr_w_instr, sdtrig__tdata1_cp_vu
    iff (Inst[31:20] == 'h7a1   && rs1_val[23]!=0 ){ 
        bins csr_write = binsof(sdtrig__tdata1_cp_vu) iff (match_csr_w_instr && i_csr.misa_csr_inst.ext[7]==0);
    }

    sdtrig__ro_cp_select : cross match_csr_w_instr, sdtrig__tdata1_cp_select
    iff (Inst[31:20] == 'h7a1 && rs1_val[21]!=0){ 
        bins csr_write = binsof(sdtrig__tdata1_cp_select) iff (match_csr_w_instr);
    }

    sdtrig__ro_cp_size : cross match_csr_w_instr, sdtrig__tdata1_cp_size
    iff (Inst[31:20] == 'h7a1  && rs1_val[18:16]!=0){ 
        bins csr_write = binsof(sdtrig__tdata1_cp_size) iff (match_csr_w_instr);
    }

    sdtrig__ro_cp_action : cross match_csr_w_instr, sdtrig__tdata1_cp_action
    iff (Inst[31:20] == 'h7a1 && rs1_val[15:12]!=0){ 
        bins csr_write = binsof(sdtrig__tdata1_cp_action) iff (match_csr_w_instr);
    }

    sdtrig__ro_cp_chain : cross match_csr_w_instr, sdtrig__tdata1_cp_chain
    iff (Inst[31:20] == 'h7a1 && rs1_val[11]!=0){ 
        bins csr_write = binsof(sdtrig__tdata1_cp_chain) iff (match_csr_w_instr);
    }

    sdtrig__ro_cp_uncertainen : cross match_csr_w_instr, sdtrig__tdata1_cp_uncertainen
    iff (Inst[31:20] == 'h7a1 && rs1_val[5]!=0){ 
        bins csr_write = binsof(sdtrig__tdata1_cp_uncertainen) iff (match_csr_w_instr);
    }

    sdtrig__warl_cp_flavour : coverpoint i_csr.tdata1_csr_inst.data[2:0]{
        bins Execute = {4};
        bins Store = {2};
        bins Load = {1};
        bins disabled = {0};
        bins illegal = default;
    }

    sdtrig__ro_cp_tselect : cross match_csr_w_instr, sdtrig__tselect_cp_data
    iff (Inst[31:20] == 'h7a0 && rs1_val[4:0]!=0){ 
        bins csr_write = binsof(sdtrig__tselect_cp_data) iff (match_csr_w_instr);
    }

    sdtrig__ro_cp_info : cross match_csr_w_instr, sdtrig__tinfo_cp_info
    iff (Inst[31:20] == 'h7a0 && rs1_val[4:0]!=0){ 
        bins csr_write = binsof(sdtrig__tinfo_cp_info) iff (match_csr_w_instr);
    }

    sdtrig__ro_cp_version : cross match_csr_w_instr, sdtrig__tinfo_cp_info
    iff (Inst[31:20] == 'h7a0 && rs1_val[4:0]!=0){ 
        bins csr_write = binsof(sdtrig__tinfo_cp_info) iff (match_csr_w_instr);
    }

    sdtrig__gen__cp_arithmetic_instrs : coverpoint instrenum_var {
        bins vals[] = {
            INSTRENUM_ADD,      INSTRENUM_ADDI,
            INSTRENUM_ADDIW,    INSTRENUM_ADDW,
            INSTRENUM_AND,      INSTRENUM_ANDI,
            INSTRENUM_AUIPC,    INSTRENUM_LUI,
            INSTRENUM_OR,       INSTRENUM_ORI, 
            INSTRENUM_SLL,      INSTRENUM_SLLI,
            INSTRENUM_SLLIW,    INSTRENUM_SLLW,
            INSTRENUM_SLT,      INSTRENUM_SLTI,
            INSTRENUM_SLTU,     INSTRENUM_SLTIU,
            INSTRENUM_SRA,      INSTRENUM_SRAI,
            INSTRENUM_SRAIW,    INSTRENUM_SRAW,
            INSTRENUM_SRL,      INSTRENUM_SRLI,
            INSTRENUM_SRLIW,    INSTRENUM_SRLW,
            INSTRENUM_SUB,      INSTRENUM_SUBW,
            INSTRENUM_XOR,      INSTRENUM_XORI
        };
    }

    sdtrig__gen__cp_aext_instrs : coverpoint aext_var {
        ignore_bins ignore_vals = {
            AEXT_LR_D,
		    AEXT_LR_W,
		    AEXT_SC_D, 
		    AEXT_SC_W 
        };
    }

    sdtrig__gen__cp_cext_instrs : coverpoint cext_var;
    sdtrig__gen__cp_fext_instrs : coverpoint fext_var;
    sdtrig__gen__cp_vext_instrs : coverpoint vext_var;
    sdtrig__gen__cp_hext_instrs : coverpoint hext_var;
    sdtrig__gen__cp_conditional_branch_instrs : coverpoint instrenum_var {
        bins vals[] = {
            INSTRENUM_BEQ,
            INSTRENUM_BGE,
            INSTRENUM_BGEU,
            INSTRENUM_BLT,
            INSTRENUM_BLTU,
            INSTRENUM_BNE      
        };
    }

    sdtrig__gen__cp_unconditional_branch_instrs : coverpoint instrenum_var {
        bins vals[] = {
            INSTRENUM_JAL,
            INSTRENUM_JALR
        };
    }

    sdtrig__gen__cp_csr_instrs : coverpoint zicsrext_var;
    sdtrig__gen__cp_debug_instrs : coverpoint instrenum_var {
        bins vals[] = {
            INSTRENUM_DRET, 
            INSTRENUM_EBREAK
        };
    }

    sdtrig__gen__cp_fence_instrs : coverpoint instrenum_var {
        bins vals[] = {
            INSTRENUM_FENCE,
            INSTRENUM_FENCE_I,
            INSTRENUM_FENCE_TSO
        };
    }

    sdtrig__gen__cp_system_instrs : coverpoint instrenum_var {
        bins vals[] = {
            INSTRENUM_ECALL,
            INSTRENUM_MRET,
            INSTRENUM_SRET
        };
    }

    sdtrig__gen__cp_illegal_instrs : coverpoint instrenum_var {
        bins vals[] = {
            INSTRENUM_ILLEGAL
        };
    }

    sdtrig__gen__cp_load_instrs : coverpoint instrenum_var {
        bins vals[] = {
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
            INSTRENUM_C_LWSP
        };
    }

    sdtrig__gen__cp_store_instrs : coverpoint instrenum_var {
        bins vals[] = {
            INSTRENUM_SB,
            INSTRENUM_SD,
            INSTRENUM_SH,
            INSTRENUM_SW,
            INSTRENUM_C_SW,
            INSTRENUM_C_SD,
            INSTRENUM_C_FSD,
            INSTRENUM_C_SWSP,
            INSTRENUM_C_SDSP,
            INSTRENUM_C_FSDSP 
        };
    }

    sdtrig__gen__cp_wfi_instrs : coverpoint instrenum_var {
        bins vals[] = {
            INSTRENUM_WFI
        };
    }

    sdtrig__gen__cp_pause_instrs : coverpoint instrenum_var {
        bins vals[] = { 
            INSTRENUM_PAUSE
        };
    }

    sdtrig__gen__cp_cbo_instrs : coverpoint instrenum_var {
        bins vals[] = {
            INSTRENUM_PREFETCH_I,
		    INSTRENUM_PREFETCH_R,
		    INSTRENUM_PREFETCH_W
        };
    }
    sdtrig__gen__cp_cbo_zero_instrs : coverpoint instrenum_var {
        bins vals[] = {
            INSTRENUM_CBO_ZERO
        };
    }

    sdtrig__gen__cp_lr_sc_instrs : coverpoint instrenum_var {
        bins vals[] = {
            INSTRENUM_LR_D,
            INSTRENUM_LR_W,
            INSTRENUM_SC_D,
            INSTRENUM_SC_W
        };
    }

    sdtrig__gen__cp_ret_instrs : coverpoint instrenum_var {
        bins vals[] = {
            INSTRENUM_SRET,
            INSTRENUM_MRET
        };
    }

    sdtrig__gen_cr_arithmetic_instr_trigger     : cross sdtrig__trig_cp_trigger, sdtrig__gen__cp_arithmetic_instrs;
    sdtrig__gen_cr_aext_instr_trigger           : cross sdtrig__trig_cp_trigger, sdtrig__gen__cp_aext_instrs;
    sdtrig__gen_cr_cext_instr_trigger           : cross sdtrig__trig_cp_trigger, sdtrig__gen__cp_cext_instrs;
    sdtrig__gen_cr_fext_instr_trigger           : cross sdtrig__trig_cp_trigger, sdtrig__gen__cp_fext_instrs;
    sdtrig__gen_cr_vext_instr_trigger           : cross sdtrig__trig_cp_trigger, sdtrig__gen__cp_vext_instrs;
    sdtrig__gen_cr_hext_instr_trigger           : cross sdtrig__trig_cp_trigger, sdtrig__gen__cp_hext_instrs;
    sdtrig__gen_cr_cond_branch_instr_trigger    : cross sdtrig__trig_cp_trigger, sdtrig__gen__cp_conditional_branch_instrs;
    sdtrig__gen_cr_uncond_branch_instr_trigger  : cross sdtrig__trig_cp_trigger, sdtrig__gen__cp_unconditional_branch_instrs;
    sdtrig__gen_cr_csr_instr_trigger            : cross sdtrig__trig_cp_trigger, sdtrig__gen__cp_csr_instrs;
    sdtrig__gen_cr_debug_instr_trigger          : cross sdtrig__trig_cp_trigger, sdtrig__gen__cp_debug_instrs;
    sdtrig__gen_cr_fence_instr_trigger          : cross sdtrig__trig_cp_trigger, sdtrig__gen__cp_fence_instrs;
    sdtrig__gen_cr_system_instr_trigger         : cross sdtrig__trig_cp_trigger, sdtrig__gen__cp_system_instrs;
    sdtrig__gen_cr_illegal_instr_trigger        : cross sdtrig__trig_cp_trigger, sdtrig__gen__cp_illegal_instrs;
    sdtrig__gen_cr_load_instr_trigger           : cross sdtrig__trig_cp_trigger, sdtrig__gen__cp_load_instrs;
    sdtrig__gen_cr_store_instr_trigger          : cross sdtrig__trig_cp_trigger, sdtrig__gen__cp_store_instrs;
    sdtrig__gen_cr_wfi_instr_trigger            : cross sdtrig__trig_cp_trigger, sdtrig__gen__cp_wfi_instrs;
    sdtrig__gen_cr_pause_instr_trigger          : cross sdtrig__trig_cp_trigger, sdtrig__gen__cp_pause_instrs;
    sdtrig__gen_cr_cbo_instr_trigger            : cross sdtrig__trig_cp_trigger, sdtrig__gen__cp_cbo_instrs;
    sdtrig__gen_cr_cbo_zero_instr_trigger       : cross sdtrig__trig_cp_trigger, sdtrig__gen__cp_cbo_zero_instrs;
    sdtrig__gen_cr_lr_sc_instr_trigger          : cross sdtrig__trig_cp_trigger, sdtrig__gen__cp_lr_sc_instrs;
    sdtrig__gen_cr_ret_instr_trigger            : cross sdtrig__trig_cp_trigger, sdtrig__gen__cp_ret_instrs;
    
    sdtrig__misaligned_ldst: coverpoint exception_var 
    iff (match_excp==1 && rs1_val[1:0] != 0){
        bins trigger_misaligned_ldst = {EXCEPTION_BREAKP};
    }
    sdtrig__misaligned_inst: coverpoint exception_var 
    iff (match_excp==1 && VirtPc[1:0] != 2'b00){
        bins trigger_misaligned_inst = {EXCEPTION_BREAKP};
    }

    sdtrig__range_ldst_8B : coverpoint instrenum_var  
    iff( (i_csr.tdata2_csr_inst.data[63:4] == rs1_val[63:4]) && i_csr.tdata1_csr_inst.data[10:7]==0 ) {
        bins dw_ld = {INSTRENUM_LD};
        bins dw_sd = {INSTRENUM_SD};
    }

    sdtrig__range_ldst_4B : coverpoint instrenum_var  
    iff( (i_csr.tdata2_csr_inst.data[63:3] == rs1_val[63:3]) && i_csr.tdata1_csr_inst.data[10:7]==0 ) {
        bins w_ld = {INSTRENUM_LW,INSTRENUM_LWU};
        bins w_sd = {INSTRENUM_SW};
    }

    sdtrig__range_ldst_2B : coverpoint instrenum_var  
    iff( (i_csr.tdata2_csr_inst.data[63:2] == rs1_val[63:2]) && i_csr.tdata1_csr_inst.data[10:7]==0 ) {
        bins h_ld = {INSTRENUM_LH,INSTRENUM_LHU};
        bins h_sd = {INSTRENUM_SH};
    }

    sdtrig__range_ldst_1B : coverpoint instrenum_var  
    iff(( i_csr.tdata2_csr_inst.data[63:1] == rs1_val[63:1]) && i_csr.tdata1_csr_inst.data[10:7]==0 ) {
        bins b_ld = {INSTRENUM_LB,INSTRENUM_LBU};
        bins b_sd = {INSTRENUM_SB};
    }

    sdtrig__trig_cr_trig_type : cross sdtrig__trig_cp_trigger,sdtrig__tdata1_cp_type{
        ignore_bins ignore_disabled_values= binsof(sdtrig__tdata1_cp_type.disabled);
    }

    sdtrig__trig_cr_trig_flavour : cross sdtrig__trig_cp_trigger,sdtrig__tdata1_cp_execute,sdtrig__tdata1_cp_store,sdtrig__tdata1_cp_load{
        option.cross_auto_bin_max   = 0;
        bins exec_trig = binsof(sdtrig__tdata1_cp_execute.enabled) && 
                         binsof(sdtrig__tdata1_cp_store.disabled) && 
                         binsof(sdtrig__tdata1_cp_load.disabled);
        bins store_trig = binsof(sdtrig__tdata1_cp_execute.disabled) && 
                         binsof(sdtrig__tdata1_cp_store.enabled) && 
                         binsof(sdtrig__tdata1_cp_load.disabled);
        bins load_trig = binsof(sdtrig__tdata1_cp_execute.disabled) && 
                         binsof(sdtrig__tdata1_cp_store.disabled) && 
                         binsof(sdtrig__tdata1_cp_load.enabled);
        ignore_bins inv= binsof(sdtrig__tdata1_cp_execute.disabled) && 
                         binsof(sdtrig__tdata1_cp_store.disabled) && 
                         binsof(sdtrig__tdata1_cp_load.disabled);
    }

    sdtrig__gen_cr_u_priv : cross sdtrig__tdata1_cp_u,sdtrig__trig_cp_trigger 
    iff (privilegemode_var==PRIVILEGEMODE_USER && VirtualMode == 0){
        ignore_bins umode0_tripped1 = binsof(sdtrig__tdata1_cp_u.disabled) && binsof(sdtrig__trig_cp_trigger.tripped1);
    }

    sdtrig__gen_cr_s_priv : cross sdtrig__tdata1_cp_s,sdtrig__trig_cp_trigger 
    iff (privilegemode_var==PRIVILEGEMODE_SUPERVISOR && VirtualMode == 0){
        ignore_bins smode0_tripped1 = binsof(sdtrig__tdata1_cp_s.disabled) && binsof(sdtrig__trig_cp_trigger.tripped1);
    }

    sdtrig__gen_cr_m_priv : cross sdtrig__tdata1_cp_m,sdtrig__trig_cp_trigger 
    iff (privilegemode_var==PRIVILEGEMODE_MACHINE){
        ignore_bins mmode0_tripped1 = binsof(sdtrig__tdata1_cp_m.disabled) && binsof(sdtrig__trig_cp_trigger.tripped1);
    }

    sdtrig__gen_cr_vs_priv : cross sdtrig__tdata1_cp_vs,sdtrig__trig_cp_trigger 
    iff (privilegemode_var==PRIVILEGEMODE_SUPERVISOR && VirtualMode == 1){
        ignore_bins vsmode0_tripped1 = binsof(sdtrig__tdata1_cp_vs.disabled) && binsof(sdtrig__trig_cp_trigger.tripped1);
    }

    sdtrig__gen_cr_vu_priv : cross sdtrig__tdata1_cp_vu,sdtrig__trig_cp_trigger 
    iff (privilegemode_var==PRIVILEGEMODE_USER && VirtualMode == 1){
        ignore_bins vumode0_tripped1 = binsof(sdtrig__tdata1_cp_vu.disabled) && binsof(sdtrig__trig_cp_trigger.tripped1);
    }

    sdtrig__trig_cr_trig_match : cross sdtrig__trig_cp_trigger, sdtrig__tdata1_cp_match; 
    sdtrig__trig_cr_trig_size : cross sdtrig__trig_cp_trigger, sdtrig__tdata1_cp_size;

    sdtrig__csr_mstatus_mpie : coverpoint i_csr.mstatus_csr_inst.mpie;
    sdtrig__cr_reentrancy_mmode : cross sdtrig__trig_cp_trigger,sdtrig__csr_mstatus_mpie,sdtrig__tdata1_cp_action 
    iff (privilegemode_var==PRIVILEGEMODE_MACHINE){
        illegal_bins reentrancy_fault = binsof(sdtrig__csr_mstatus_mpie) intersect {0} && binsof(sdtrig__trig_cp_trigger.tripped1) && binsof(sdtrig__tdata1_cp_action.trigger_bkpt);
    }

    sdtrig__csr_medeleg3 : coverpoint i_csr.medeleg_csr_inst.medeleg[3]{
        bins enabled = {1};
        bins disabled= {0};
    }

    sdtrig__csr_sstatus_spie : coverpoint i_csr.sstatus_csr_inst.spie;
    sdtrig__cr_reentrancy_smode : cross sdtrig__trig_cp_trigger,sdtrig__csr_sstatus_spie,sdtrig__tdata1_cp_action,sdtrig__csr_medeleg3 
    iff (privilegemode_var==PRIVILEGEMODE_SUPERVISOR && VirtualMode == 0){
        illegal_bins reentrancy_fault = binsof(sdtrig__csr_sstatus_spie) intersect {0} && binsof(sdtrig__csr_medeleg3.enabled) && binsof(sdtrig__trig_cp_trigger.tripped1) && binsof(sdtrig__tdata1_cp_action.trigger_bkpt);
    }

    sdtrig__csr_hedeleg3 : coverpoint i_csr.hedeleg_csr_inst.hedeleg[3]{
        bins enabled = {1};
        bins disabled= {0};
    }

    sdtrig__csr_vsstatus_spie : coverpoint i_csr.vsstatus_csr_inst.spie;
    sdtrig__cr_reentrancy_vsmode : cross sdtrig__trig_cp_trigger,sdtrig__csr_vsstatus_spie,sdtrig__tdata1_cp_action,sdtrig__csr_hedeleg3,sdtrig__csr_medeleg3 
    iff (privilegemode_var==PRIVILEGEMODE_SUPERVISOR && VirtualMode == 1){
        illegal_bins reentrancy_fault = binsof(sdtrig__csr_vsstatus_spie) intersect {0} && binsof(sdtrig__csr_medeleg3.enabled) && binsof(sdtrig__csr_hedeleg3.enabled) && binsof(sdtrig__trig_cp_trigger.tripped1) && binsof(sdtrig__tdata1_cp_action.trigger_bkpt);
    }
    
    sdtrig__cr_trig_ehandler : cross sdtrig__trig_cp_trigger,sdtrig__gen_cp_valid_priv 
    iff (in_excp_handler){
        ignore_bins u_mode_handler = binsof(sdtrig__gen_cp_valid_priv.u_mode);
        ignore_bins vu_mode_handler = binsof(sdtrig__gen_cp_valid_priv.vu_mode);
    } 

    sdtrig__cp_tdata1_type : coverpoint i_csr.tdata1_csr_inst.ttype
    {
      bins disabled = {'hf};  
    } 

    sdtrig__pagesize__cp_iside_cross_paginglevel :  coverpoint fpagecrosssize_var;
    sdtrig__pagesize__cp_dside_cross_paginglevel :  coverpoint dpagecrosssize_var;

    sdtrig__pagesize__cp_iside_paginglevel :        coverpoint fpagesize_var;
    sdtrig__pagesize__cp_dside_paginglevel :        coverpoint dpagesize_var;

    sdtrig__cp_dside_pg_cross : cross sdtrig__trig_cp_trigger,sdtrig__pagesize__cp_dside_cross_paginglevel,sdtrig__pagesize__cp_dside_paginglevel{
        bins trigger_pg1_4K_pg2_any_other      = 
        binsof(sdtrig__pagesize__cp_dside_paginglevel) intersect {DPAGESIZE_4K};
        bins trigger_pg1_2M_pg2_any_other      = 
        binsof(sdtrig__pagesize__cp_dside_paginglevel) intersect {DPAGESIZE_2M};
        bins trigger_pg1_1G_pg2_any_other      = 
        binsof(sdtrig__pagesize__cp_dside_paginglevel) intersect {DPAGESIZE_1G};
        bins trigger_pg1_512G_pg2_any_other      = 
        binsof(sdtrig__pagesize__cp_dside_paginglevel) intersect {DPAGESIZE_512G};
        bins trigger_pg1_256T_pg2_any_other      = 
        binsof(sdtrig__pagesize__cp_dside_paginglevel) intersect {DPAGESIZE_256T};
    }

    sdtrig__cp_iside_pg_cross : cross sdtrig__trig_cp_trigger,sdtrig__pagesize__cp_iside_cross_paginglevel,sdtrig__pagesize__cp_iside_paginglevel{
        bins trigger_pg1_4K_pg2_any_other      = 
        binsof(sdtrig__pagesize__cp_iside_paginglevel) intersect {DPAGESIZE_4K};
        bins trigger_pg1_2M_pg2_any_other      = 
        binsof(sdtrig__pagesize__cp_iside_paginglevel) intersect {DPAGESIZE_2M};
        bins trigger_pg1_1G_pg2_any_other      = 
        binsof(sdtrig__pagesize__cp_iside_paginglevel) intersect {DPAGESIZE_1G};
        bins trigger_pg1_512G_pg2_any_other      = 
        binsof(sdtrig__pagesize__cp_iside_paginglevel) intersect {DPAGESIZE_512G};
        bins trigger_pg1_256T_pg2_any_other      = 
        binsof(sdtrig__pagesize__cp_iside_paginglevel) intersect {DPAGESIZE_256T};
    }

    sdtrig__cp_mstatus_gva : coverpoint i_csr.mstatus_csr_inst.gva
    iff (match_trigger == 1) {
        bins disabled   = {0};
        bins enabled    = {1};
    }

    sdtrig__cp_mstatus_gva_virt : coverpoint i_csr.mstatus_csr_inst.gva {
        bins vsmode    = {1} iff (privilegemode_var==PRIVILEGEMODE_SUPERVISOR && VirtualMode == 1 && match_trigger == 1);
        bins vumode    = {1} iff (privilegemode_var==PRIVILEGEMODE_USER && VirtualMode == 1 && match_trigger == 1);
    }

    sdtrig__cr_mstatus_gva_h_instr : cross sdtrig__cp_mstatus_gva, sdtrig__gen__cp_hext_instrs iff (VirtualMode == 0);

    sdtrig__icount_trig_cp_trigger : coverpoint match_trigger
    iff (i_csr.tdata1_csr_inst.ttype==3 && i_csr.tselect_csr_inst.select==8){
        bins tripped1 = {1};
        bins tripped0 = {0};
    }

    sdtrig__icount_tdata1_cp_action : coverpoint i_csr.tdata1_csr_inst.data[5:0]
    iff (i_csr.tdata1_csr_inst.ttype==3 && i_csr.tselect_csr_inst.select==8){
        bins action_breakpoint = {0};
        bins action_debug_mode = {1};
        bins action_trace_on = {2};
        bins action_trace_off = {3};
        bins action_trace_notify = {4};
        illegal_bins action_illegal = {[5:63]};
    }

    sdtrig__icount_tdata1_cp_hit : coverpoint i_csr.tdata1_csr_inst.data[24]
    iff (i_csr.tdata1_csr_inst.ttype==3 && i_csr.tselect_csr_inst.select==8){
        bins hit_clear = {0};
        bins hit_set = {1};
    }

    sdtrig__icount_tdata1_cp_count : coverpoint i_csr.tdata1_csr_inst.data[23:10]
    iff (i_csr.tdata1_csr_inst.ttype==3 && i_csr.tselect_csr_inst.select==8){
        bins count_zero = {0};
        bins count_one = {1};
        bins count_small = {[2:10]};
        bins count_medium = {[11:100]};
        bins count_large = {[101:16382]};
        bins count_max = {14'h3fff};
    }

    sdtrig__icount_cp_count_compact : coverpoint i_csr.tdata1_csr_inst.data[23:10]
    iff (i_csr.tdata1_csr_inst.ttype==3 && i_csr.tselect_csr_inst.select==8){
        option.weight = 0;
        bins count_small  = {[0:5]};
        bins count_medium = {[6:255]};
    }

    sdtrig__icount_tdata1_cp_pending : coverpoint i_csr.tdata1_csr_inst.data[8]
    iff (i_csr.tdata1_csr_inst.ttype==3 && i_csr.tselect_csr_inst.select==8){
        bins pending_clear = {0};
        bins pending_set = {1};
    }

    sdtrig__icount_tdata1_cp_m : coverpoint i_csr.tdata1_csr_inst.data[9]
    iff (i_csr.tdata1_csr_inst.ttype==3 && i_csr.tselect_csr_inst.select==8){
        bins m_disabled = {0};
        bins m_enabled = {1};
    }

    sdtrig__icount_tdata1_cp_s : coverpoint i_csr.tdata1_csr_inst.data[7]
    iff (i_csr.tdata1_csr_inst.ttype==3 && i_csr.tselect_csr_inst.select==8){
        bins s_disabled = {0};
        bins s_enabled = {1};
    }

    sdtrig__icount_tdata1_cp_u : coverpoint i_csr.tdata1_csr_inst.data[6]
    iff (i_csr.tdata1_csr_inst.ttype==3 && i_csr.tselect_csr_inst.select==8){
        bins u_disabled = {0};
        bins u_enabled = {1};
    }

    sdtrig__icount_tdata1_cp_vs : coverpoint i_csr.tdata1_csr_inst.data[26]
    iff (i_csr.tdata1_csr_inst.ttype==3 && i_csr.tselect_csr_inst.select==8){
        bins vs_disabled = {0};
        bins vs_enabled = {1};
    }

    sdtrig__icount_tdata1_cp_vu : coverpoint i_csr.tdata1_csr_inst.data[25]
    iff (i_csr.tdata1_csr_inst.ttype==3 && i_csr.tselect_csr_inst.select==8){
        bins vu_disabled = {0};
        bins vu_enabled = {1};
    }

    sdtrig__icount_tdata1_cp_dmode : coverpoint i_csr.tdata1_csr_inst.dmode
    iff (i_csr.tdata1_csr_inst.ttype==3 && i_csr.tselect_csr_inst.select==8){
        bins dmode_disabled = {0};
        bins dmode_enabled = {1};
    }

    sdtrig__icount_cp_fault_type : coverpoint exception_var
    iff (i_csr.tdata1_csr_inst.ttype==3 && i_csr.tselect_csr_inst.select==8 && match_excp==1){
        bins fault_types[] = {
            EXCEPTION_INST_ADDR_MISAL,
	        EXCEPTION_LOAD_ADDR_MISAL,
	        EXCEPTION_STORE_ADDR_MISAL, 
            EXCEPTION_LOAD_PAGE_FAULT,
            EXCEPTION_STORE_PAGE_FAULT,
            EXCEPTION_INST_PAGE_FAULT,
            EXCEPTION_LOAD_ACC_FAULT,
            EXCEPTION_STORE_ACC_FAULT,
            EXCEPTION_INST_ACC_FAULT,
            EXCEPTION_M_ENV_CALL,
            EXCEPTION_S_ENV_CALL,
            EXCEPTION_U_ENV_CALL,
            EXCEPTION_ILLEGAL_INST
        };
    }

    sdtrig__icount_cp_wfi_wrs_instr : coverpoint instrenum_var
    iff (i_csr.tdata1_csr_inst.ttype==3 && i_csr.tselect_csr_inst.select==8
         && match_trigger==1){
        bins ICOUNT_WFI     = {INSTRENUM_WFI};
        bins ICOUNT_WRS_STO = {INSTRENUM_WRS_STO};
        bins ICOUNT_WRS_NTO = {INSTRENUM_WRS_NTO};
    }

    sdtrig__icount_cp_trace_action_type : coverpoint i_csr.tdata1_csr_inst.data[5:0]
    iff (i_csr.tdata1_csr_inst.ttype==3 && i_csr.tselect_csr_inst.select==8
         && match_trigger==1){
        bins trace_on_fired     = {2};
        bins trace_off_fired    = {3};
        bins trace_notify_fired = {4};
    }

    sdtrig__icount_warl_cp_type : coverpoint i_csr.tdata1_csr_inst.ttype
    iff (i_csr.tselect_csr_inst.select==8){
        bins valid_icount = {3};
        bins invalid_other = {15};
        ignore_bins invalid_type = {[0:2], [4:14]};
    }

    sdtrig__icount_warl_cp_dmode : coverpoint i_csr.tdata1_csr_inst.dmode
    iff (i_csr.tdata1_csr_inst.ttype==3 && i_csr.tselect_csr_inst.select==8 && match_csr_w_instr){
        bins dmode_write = {1};
    }

    sdtrig__icount_warl_cp_vs_misa_h : cross sdtrig__icount_tdata1_cp_vs, sdtrig__cp_misa_h_disabled
    iff (i_csr.tdata1_csr_inst.ttype==3 && i_csr.tselect_csr_inst.select==8){
        option.cross_auto_bin_max = 0;
        bins vs_set_h_enabled   = binsof(sdtrig__icount_tdata1_cp_vs.vs_enabled)  && binsof(sdtrig__cp_misa_h_disabled.enabled);
        bins vs_clear_h_enabled = binsof(sdtrig__icount_tdata1_cp_vs.vs_disabled) && binsof(sdtrig__cp_misa_h_disabled.enabled);
        bins vs_clear_h_disabled= binsof(sdtrig__icount_tdata1_cp_vs.vs_disabled) && binsof(sdtrig__cp_misa_h_disabled.disabled);
        illegal_bins vs_set_no_h = binsof(sdtrig__icount_tdata1_cp_vs.vs_enabled) && binsof(sdtrig__cp_misa_h_disabled.disabled);
    }

    sdtrig__icount_warl_cp_vu_misa_h : cross sdtrig__icount_tdata1_cp_vu, sdtrig__cp_misa_h_disabled
    iff (i_csr.tdata1_csr_inst.ttype==3 && i_csr.tselect_csr_inst.select==8){
        option.cross_auto_bin_max = 0;
        bins vu_set_h_enabled   = binsof(sdtrig__icount_tdata1_cp_vu.vu_enabled)  && binsof(sdtrig__cp_misa_h_disabled.enabled);
        bins vu_clear_h_enabled = binsof(sdtrig__icount_tdata1_cp_vu.vu_disabled) && binsof(sdtrig__cp_misa_h_disabled.enabled);
        bins vu_clear_h_disabled= binsof(sdtrig__icount_tdata1_cp_vu.vu_disabled) && binsof(sdtrig__cp_misa_h_disabled.disabled);
        illegal_bins vu_set_no_h = binsof(sdtrig__icount_tdata1_cp_vu.vu_enabled) && binsof(sdtrig__cp_misa_h_disabled.disabled);
    }

    sdtrig__icount_warl_cp_vs_type15 : coverpoint i_csr.tdata1_csr_inst.data[26]
    iff (i_csr.tdata1_csr_inst.ttype==15 && i_csr.tselect_csr_inst.select==8){
        bins vs_zero = {0};
        illegal_bins vs_nonzero = {1};
    }

    sdtrig__icount_warl_cp_vu_type15 : coverpoint i_csr.tdata1_csr_inst.data[25]
    iff (i_csr.tdata1_csr_inst.ttype==15 && i_csr.tselect_csr_inst.select==8){
        bins vu_zero = {0};
        illegal_bins vu_nonzero = {1};
    }

    sdtrig__icount_warl_cr_vs_vu_individual : cross sdtrig__icount_tdata1_cp_vs, sdtrig__icount_tdata1_cp_vu
    iff (i_csr.tdata1_csr_inst.ttype==3 && i_csr.tselect_csr_inst.select==8
         && i_csr.misa_csr_inst.ext[7]==1){
        option.cross_auto_bin_max = 0;
        bins vs_only = binsof(sdtrig__icount_tdata1_cp_vs.vs_enabled) && binsof(sdtrig__icount_tdata1_cp_vu.vu_disabled);
        bins vu_only = binsof(sdtrig__icount_tdata1_cp_vs.vs_disabled) && binsof(sdtrig__icount_tdata1_cp_vu.vu_enabled);
        bins both    = binsof(sdtrig__icount_tdata1_cp_vs.vs_enabled) && binsof(sdtrig__icount_tdata1_cp_vu.vu_enabled);
        bins neither = binsof(sdtrig__icount_tdata1_cp_vs.vs_disabled) && binsof(sdtrig__icount_tdata1_cp_vu.vu_disabled);
    }

    sdtrig__icount_warl_cp_action : coverpoint i_csr.tdata1_csr_inst.data[5:0]
    iff (i_csr.tdata1_csr_inst.ttype==3 && i_csr.tselect_csr_inst.select==8){
        bins action_breakpoint    = {0};
        bins action_debug_mode    = {1};
        bins action_trace_on      = {2};
        bins action_trace_off     = {3};
        bins action_trace_notify  = {4};
        ignore_bins invalid_actions = {[5:63]};
    }

    sdtrig__icount_cr_trigger_action : cross sdtrig__icount_trig_cp_trigger, sdtrig__icount_tdata1_cp_action;

    sdtrig__icount_cr_trace_hit_count : cross sdtrig__icount_tdata1_cp_hit, sdtrig__icount_tdata1_cp_count, sdtrig__icount_cp_trace_action_type
    iff (i_csr.tdata1_csr_inst.ttype==3 && i_csr.tselect_csr_inst.select==8){
        option.cross_auto_bin_max = 0;
        bins trace_hit_count_zero = binsof(sdtrig__icount_tdata1_cp_hit.hit_set) &&
                                    binsof(sdtrig__icount_tdata1_cp_count.count_zero);
    }

    sdtrig__icount_warl_cp_hit : coverpoint i_csr.tdata1_csr_inst.data[24]
    iff (i_csr.tdata1_csr_inst.ttype==3 && i_csr.tselect_csr_inst.select==8 && match_csr_w_instr){
        bins sw_write_hit_0 = {0};
        bins sw_write_hit_1 = {1};
    }

    sdtrig__icount_cp_hit_on_fire : coverpoint i_csr.tdata1_csr_inst.data[24]
    iff (i_csr.tdata1_csr_inst.ttype==3 && i_csr.tselect_csr_inst.select==8 && match_trigger==1){
        bins hw_hit_set = {1};
    }

    sdtrig__icount_warl_cp_count : coverpoint i_csr.tdata1_csr_inst.data[23:10]
    iff (i_csr.tdata1_csr_inst.ttype==3 && i_csr.tselect_csr_inst.select==8 && match_csr_w_instr){
        bins write_zero = {0};
        bins write_one = {1};
        bins write_small = {[2:31]};
        bins write_max = {14'h3fff};
    }

    sdtrig__icount_cp_pending_transition : coverpoint i_csr.tdata1_csr_inst.data[8]
    iff (i_csr.tdata1_csr_inst.ttype==3 && i_csr.tselect_csr_inst.select==8){
        bins pending_clear = {0};
        bins pending_set = {1};
    }

    sdtrig__icount_cr_multi_mode : cross sdtrig__icount_tdata1_cp_m, sdtrig__icount_tdata1_cp_s, sdtrig__icount_tdata1_cp_u
    iff (i_csr.tdata1_csr_inst.ttype==3 && i_csr.tselect_csr_inst.select==8){
        option.cross_auto_bin_max = 0;
        bins m_only = binsof(sdtrig__icount_tdata1_cp_m.m_enabled) &&
                      binsof(sdtrig__icount_tdata1_cp_s.s_disabled) &&
                      binsof(sdtrig__icount_tdata1_cp_u.u_disabled);
        bins s_only = binsof(sdtrig__icount_tdata1_cp_m.m_disabled) &&
                      binsof(sdtrig__icount_tdata1_cp_s.s_enabled) &&
                      binsof(sdtrig__icount_tdata1_cp_u.u_disabled);
        bins u_only = binsof(sdtrig__icount_tdata1_cp_m.m_disabled) &&
                      binsof(sdtrig__icount_tdata1_cp_s.s_disabled) &&
                      binsof(sdtrig__icount_tdata1_cp_u.u_enabled);
        bins m_s = binsof(sdtrig__icount_tdata1_cp_m.m_enabled) &&
                   binsof(sdtrig__icount_tdata1_cp_s.s_enabled) &&
                   binsof(sdtrig__icount_tdata1_cp_u.u_disabled);
        bins m_u = binsof(sdtrig__icount_tdata1_cp_m.m_enabled) &&
                   binsof(sdtrig__icount_tdata1_cp_s.s_disabled) &&
                   binsof(sdtrig__icount_tdata1_cp_u.u_enabled);
        bins s_u = binsof(sdtrig__icount_tdata1_cp_m.m_disabled) &&
                   binsof(sdtrig__icount_tdata1_cp_s.s_enabled) &&
                   binsof(sdtrig__icount_tdata1_cp_u.u_enabled);
        bins m_s_u = binsof(sdtrig__icount_tdata1_cp_m.m_enabled) &&
                     binsof(sdtrig__icount_tdata1_cp_s.s_enabled) &&
                     binsof(sdtrig__icount_tdata1_cp_u.u_enabled);
    }

    sdtrig__icount_cr_m_priv : cross sdtrig__icount_tdata1_cp_m, sdtrig__icount_trig_cp_trigger
    iff (privilegemode_var==PRIVILEGEMODE_MACHINE && i_csr.tdata1_csr_inst.ttype==3 && i_csr.tselect_csr_inst.select==8){
        illegal_bins mmode0_tripped1 = binsof(sdtrig__icount_tdata1_cp_m.m_disabled) && binsof(sdtrig__icount_trig_cp_trigger.tripped1);
    }

    sdtrig__icount_cr_s_priv : cross sdtrig__icount_tdata1_cp_s, sdtrig__icount_trig_cp_trigger
    iff (privilegemode_var==PRIVILEGEMODE_SUPERVISOR && VirtualMode == 0 && i_csr.tdata1_csr_inst.ttype==3 && i_csr.tselect_csr_inst.select==8){
        illegal_bins smode0_tripped1 = binsof(sdtrig__icount_tdata1_cp_s.s_disabled) && binsof(sdtrig__icount_trig_cp_trigger.tripped1);
    }

    sdtrig__icount_cr_u_priv : cross sdtrig__icount_tdata1_cp_u, sdtrig__icount_trig_cp_trigger
    iff (privilegemode_var==PRIVILEGEMODE_USER && VirtualMode == 0 && i_csr.tdata1_csr_inst.ttype==3 && i_csr.tselect_csr_inst.select==8){
        illegal_bins umode0_tripped1 = binsof(sdtrig__icount_tdata1_cp_u.u_disabled) && binsof(sdtrig__icount_trig_cp_trigger.tripped1);
    }

    sdtrig__icount_cr_vs_priv : cross sdtrig__icount_tdata1_cp_vs, sdtrig__icount_trig_cp_trigger
    iff (privilegemode_var==PRIVILEGEMODE_SUPERVISOR && VirtualMode == 1 && i_csr.tdata1_csr_inst.ttype==3 && i_csr.tselect_csr_inst.select==8){
        illegal_bins vsmode0_tripped1 = binsof(sdtrig__icount_tdata1_cp_vs.vs_disabled) && binsof(sdtrig__icount_trig_cp_trigger.tripped1);
    }

    sdtrig__icount_cr_vu_priv : cross sdtrig__icount_tdata1_cp_vu, sdtrig__icount_trig_cp_trigger
    iff (privilegemode_var==PRIVILEGEMODE_USER && VirtualMode == 1 && i_csr.tdata1_csr_inst.ttype==3 && i_csr.tselect_csr_inst.select==8){
        illegal_bins vumode0_tripped1 = binsof(sdtrig__icount_tdata1_cp_vu.vu_disabled) && binsof(sdtrig__icount_trig_cp_trigger.tripped1);
    }

    sdtrig__icount_cp_mie : coverpoint i_csr.mstatus_csr_inst.mie
    iff (i_csr.tdata1_csr_inst.ttype==3 && i_csr.tselect_csr_inst.select==8
         && i_csr.tdata1_csr_inst.data[5:0]==0 && i_csr.tdata1_csr_inst.data[9]==1
         && privilegemode_var==PRIVILEGEMODE_MACHINE && match_trigger==1){
        bins mie_disabled = {0};
        bins mie_enabled = {1};
    }

    sdtrig__icount_cp_sie : coverpoint i_csr.sstatus_csr_inst.sie
    iff (i_csr.tdata1_csr_inst.ttype==3 && i_csr.tselect_csr_inst.select==8
         && i_csr.tdata1_csr_inst.data[5:0]==0 && i_csr.tdata1_csr_inst.data[7]==1
         && privilegemode_var==PRIVILEGEMODE_SUPERVISOR && VirtualMode==0 && match_trigger==1){
        bins sie_disabled = {0};
        bins sie_enabled = {1};
    }

    sdtrig__icount_cp_vsstatus_sie : coverpoint i_csr.vsstatus_csr_inst.sie
    iff (i_csr.tdata1_csr_inst.ttype==3 && i_csr.tselect_csr_inst.select==8
         && i_csr.tdata1_csr_inst.data[5:0]==0 && i_csr.tdata1_csr_inst.data[26]==1
         && privilegemode_var==PRIVILEGEMODE_SUPERVISOR && VirtualMode==1 && match_trigger==1){
        bins vssie_disabled = {0};
        bins vssie_enabled = {1};
    }

    sdtrig__icount_cp_mie_action_nonzero : coverpoint i_csr.mstatus_csr_inst.mie
    iff (i_csr.tdata1_csr_inst.ttype==3 && i_csr.tselect_csr_inst.select==8
         && i_csr.tdata1_csr_inst.data[5:0]!=0
         && i_csr.tdata1_csr_inst.data[9]==1
         && privilegemode_var==PRIVILEGEMODE_MACHINE && match_trigger==1){
        bins mie_disabled = {0};
        bins mie_enabled = {1};
    }

    sdtrig__icount_cr_ret_trigger : cross sdtrig__icount_trig_cp_trigger, sdtrig__gen__cp_ret_instrs iff (i_csr.tdata1_csr_inst.ttype==3 && i_csr.tselect_csr_inst.select==8){
        option.cross_auto_bin_max = 0;
        ignore_bins ignore_vals = !binsof(sdtrig__icount_trig_cp_trigger.tripped1);
    }

    sdtrig__icount_cr_ret_priv : cross sdtrig__icount_trig_cp_trigger, sdtrig__gen_cp_valid_priv
    iff (i_csr.tdata1_csr_inst.ttype==3 && i_csr.tselect_csr_inst.select==8
         && (instrenum_var == INSTRENUM_MRET || instrenum_var == INSTRENUM_SRET)){
        option.cross_auto_bin_max = 0;
        bins mret_m = binsof(sdtrig__gen_cp_valid_priv.m_mode) && binsof(sdtrig__icount_trig_cp_trigger.tripped1);
        bins sret_hs = binsof(sdtrig__gen_cp_valid_priv.hs_mode) && binsof(sdtrig__icount_trig_cp_trigger.tripped1);
        bins sret_vs = binsof(sdtrig__gen_cp_valid_priv.vs_mode) && binsof(sdtrig__icount_trig_cp_trigger.tripped1);
    }

    sdtrig__icount_cp_pending_active : coverpoint i_csr.tdata1_csr_inst.data[8]
    iff (i_csr.tdata1_csr_inst.ttype==3 && i_csr.tselect_csr_inst.select==8){
        bins pending_clear = {0};
        bins pending_set = {1};
    }

    sdtrig__icount_cr_fault_count : cross sdtrig__icount_cp_fault_type, sdtrig__icount_cp_count_compact
    iff (i_csr.tdata1_csr_inst.ttype==3 && i_csr.tselect_csr_inst.select==8
         && i_csr.tdata1_csr_inst.data[5:0]==0);

    sdtrig__icount_cp_non_debug_action : coverpoint i_csr.tdata1_csr_inst.data[5:0]
    iff (i_csr.tdata1_csr_inst.ttype==3 && i_csr.tselect_csr_inst.select==8){
        option.weight = 0;
        bins action_breakpoint    = {0};
        bins action_trace_on      = {2};
        bins action_trace_off     = {3};
        bins action_trace_notify  = {4};
    }

    sdtrig__icount_cr_wfi_wrs_action : cross sdtrig__icount_cp_wfi_wrs_instr, sdtrig__icount_cp_non_debug_action
    iff (i_csr.tdata1_csr_inst.ttype==3 && i_csr.tselect_csr_inst.select==8
         && i_csr.tdata1_csr_inst.data[5:0]!=1);

    sdtrig__icount_cp_interrupt_pending_at_trigger : coverpoint match_trigger
    iff (i_csr.tdata1_csr_inst.ttype==3 && i_csr.tselect_csr_inst.select==8
         && match_trigger==1){
        bins collision = {1} iff (
            (i_csr.mie_csr_inst.meie == 1 && i_csr.mip_csr_inst.meip == 1) ||
            (i_csr.mie_csr_inst.mtie == 1 && i_csr.mip_csr_inst.mtip == 1) ||
            (i_csr.mie_csr_inst.msie == 1 && i_csr.mip_csr_inst.msip == 1) ||
            (i_csr.mie_csr_inst.seie == 1 && i_csr.mip_csr_inst.seip == 1) ||
            (i_csr.mie_csr_inst.stie == 1 && i_csr.mip_csr_inst.stip == 1) ||
            (i_csr.mie_csr_inst.ssie == 1 && i_csr.mip_csr_inst.ssip == 1) ||
            (i_csr.mie_csr_inst.lcofie == 1 && i_csr.mip_csr_inst.lcofip == 1) ||
            (i_csr.hie_csr_inst.vseie == 1 && i_csr.hip_csr_inst.vseip == 1) ||
            (i_csr.hie_csr_inst.vstie == 1 && i_csr.hip_csr_inst.vstip == 1) ||
            (i_csr.hie_csr_inst.vssie == 1 && i_csr.hip_csr_inst.vssip == 1));
        bins no_collision = {1} iff (
            !(i_csr.mie_csr_inst.meie == 1 && i_csr.mip_csr_inst.meip == 1) &&
            !(i_csr.mie_csr_inst.mtie == 1 && i_csr.mip_csr_inst.mtip == 1) &&
            !(i_csr.mie_csr_inst.msie == 1 && i_csr.mip_csr_inst.msip == 1) &&
            !(i_csr.mie_csr_inst.seie == 1 && i_csr.mip_csr_inst.seip == 1) &&
            !(i_csr.mie_csr_inst.stie == 1 && i_csr.mip_csr_inst.stip == 1) &&
            !(i_csr.mie_csr_inst.ssie == 1 && i_csr.mip_csr_inst.ssip == 1) &&
            !(i_csr.mie_csr_inst.lcofie == 1 && i_csr.mip_csr_inst.lcofip == 1) &&
            !(i_csr.hie_csr_inst.vseie == 1 && i_csr.hip_csr_inst.vseip == 1) &&
            !(i_csr.hie_csr_inst.vstie == 1 && i_csr.hip_csr_inst.vstip == 1) &&
            !(i_csr.hie_csr_inst.vssie == 1 && i_csr.hip_csr_inst.vssip == 1));
    }

    sdtrig__icount_cr_intr_collision_action : cross sdtrig__icount_cp_interrupt_pending_at_trigger, sdtrig__icount_tdata1_cp_action
    iff (i_csr.tdata1_csr_inst.ttype==3 && i_csr.tselect_csr_inst.select==8);

    sdtrig__icount_deleg__cp_medeleg_toggle : coverpoint i_csr.medeleg_csr_inst.medeleg[3]
    iff (exception_var == EXCEPTION_BREAKP && i_csr.tdata1_csr_inst.ttype==3 && i_csr.tselect_csr_inst.select==8 && match_trigger==1){
        bins disabled = {0};
        bins enabled = {1};
    }

    sdtrig__icount_deleg__cp_hedeleg_toggle : coverpoint i_csr.hedeleg_csr_inst.hedeleg[3]
    iff (exception_var == EXCEPTION_BREAKP && i_csr.tdata1_csr_inst.ttype==3 && i_csr.tselect_csr_inst.select==8 && match_trigger==1){
        bins disabled = {0};
        bins enabled = {1};
    }

    sdtrig__icount_cr_reentrancy_mmode : cross sdtrig__icount_trig_cp_trigger, sdtrig__csr_mstatus_mpie
    iff (privilegemode_var==PRIVILEGEMODE_MACHINE && i_csr.tdata1_csr_inst.ttype==3 && i_csr.tselect_csr_inst.select==8
         && i_csr.tdata1_csr_inst.data[5:0]==0){
        illegal_bins reentrancy_fault = binsof(sdtrig__csr_mstatus_mpie) intersect {0} && binsof(sdtrig__icount_trig_cp_trigger.tripped1);
    }

    sdtrig__icount_cr_reentrancy_smode : cross sdtrig__icount_trig_cp_trigger, sdtrig__csr_sstatus_spie, sdtrig__csr_medeleg3
    iff (privilegemode_var==PRIVILEGEMODE_SUPERVISOR && VirtualMode == 0 && i_csr.tdata1_csr_inst.ttype==3 && i_csr.tselect_csr_inst.select==8
         && i_csr.tdata1_csr_inst.data[5:0]==0){
        illegal_bins reentrancy_fault = binsof(sdtrig__csr_sstatus_spie) intersect {0} && binsof(sdtrig__csr_medeleg3.enabled) && binsof(sdtrig__icount_trig_cp_trigger.tripped1);
    }

    sdtrig__icount_cr_reentrancy_vsmode : cross sdtrig__icount_trig_cp_trigger, sdtrig__csr_vsstatus_spie, sdtrig__csr_hedeleg3, sdtrig__csr_medeleg3
    iff (privilegemode_var==PRIVILEGEMODE_SUPERVISOR && VirtualMode == 1 && i_csr.tdata1_csr_inst.ttype==3 && i_csr.tselect_csr_inst.select==8
         && i_csr.tdata1_csr_inst.data[5:0]==0){
        illegal_bins reentrancy_fault = binsof(sdtrig__csr_vsstatus_spie) intersect {0} && binsof(sdtrig__csr_medeleg3.enabled) && binsof(sdtrig__csr_hedeleg3.enabled) && binsof(sdtrig__icount_trig_cp_trigger.tripped1);
    }

    sdtrig__icount_cr_priv_trigger : cross sdtrig__gen_cp_valid_priv, sdtrig__icount_trig_cp_trigger
    iff (i_csr.tdata1_csr_inst.ttype==3 && i_csr.tselect_csr_inst.select==8);

    sdtrig__icount_cp_armed_pending_immediate : coverpoint {i_csr.tdata1_csr_inst.data[8], i_csr.tdata1_csr_inst.data[23:10]}
    iff (i_csr.tdata1_csr_inst.ttype==3 && i_csr.tselect_csr_inst.select==8 && match_csr_w_instr){
        bins pending1_count1 = {15'b1_00000000000001};
        bins pending0_count1 = {15'b0_00000000000001};
        bins pending0_count_gt1 = default iff (i_csr.tdata1_csr_inst.data[8]==0 && i_csr.tdata1_csr_inst.data[23:10]>1);
    }

    sdtrig__icount_cp_action0_x_nmi : coverpoint i_csr.mncause_csr_inst.intr
    iff (i_csr.tdata1_csr_inst.ttype==3 && i_csr.tselect_csr_inst.select==8
         && i_csr.tdata1_csr_inst.data[5:0]==0 && match_trigger==1
         && i_csr.mnstatus_csr_inst.nmie == 1
         && i_csr.mncause_csr_inst.code == 2){
        bins breakpoint_nmi_taken = {1};
    }

    sdtrig__icount_cp_action1_x_nmi : coverpoint i_csr.dcsr_csr_inst.nmip
    iff (i_csr.tdata1_csr_inst.ttype==3 && i_csr.tselect_csr_inst.select==8
         && i_csr.tdata1_csr_inst.data[5:0]==1 && i_csr.tdata1_csr_inst.data[24]==1
         && i_csr.mnstatus_csr_inst.nmie == 1){
        bins ICOUNT_DM_NMI_PEND = {1};
    }

    sdtrig__icount_cp_trace_x_nmi : coverpoint i_csr.mncause_csr_inst.intr
    iff (i_csr.tdata1_csr_inst.ttype==3 && i_csr.tselect_csr_inst.select==8
         && i_csr.tdata1_csr_inst.data[5:0]>=2 && i_csr.tdata1_csr_inst.data[5:0]<=4
         && match_trigger==1 && interrupt_taken==1
         && i_csr.mncause_csr_inst.code == 2){
        bins trace_nmi_taken = {1};
    }

    sdtrig__icount_cp_action1_excp_collision : coverpoint match_excp
    iff (i_csr.tdata1_csr_inst.ttype==3 && i_csr.tselect_csr_inst.select==8
         && i_csr.tdata1_csr_inst.data[5:0]==1){
        bins dm_excp_present = {1};
    }

    sdtrig__icount_cp_trace_excp_collision : coverpoint match_excp
    iff (i_csr.tdata1_csr_inst.ttype==3 && i_csr.tselect_csr_inst.select==8
         && i_csr.tdata1_csr_inst.data[5:0]>=2 && i_csr.tdata1_csr_inst.data[5:0]<=4
         && match_trigger==1){
        bins trace_excp_present = {1};
    }

    sdtrig__icount_cp_action1_in_ihandler : coverpoint in_intr_handler
    iff (i_csr.tdata1_csr_inst.ttype==3 && i_csr.tselect_csr_inst.select==8
         && i_csr.tdata1_csr_inst.data[5:0]==1 && i_csr.tdata1_csr_inst.data[24]==1){
        bins dm_in_isr = {1};
    }

    sdtrig__icount_cp_trace_in_ihandler : coverpoint in_intr_handler
    iff (i_csr.tdata1_csr_inst.ttype==3 && i_csr.tselect_csr_inst.select==8
         && i_csr.tdata1_csr_inst.data[5:0]>=2 && i_csr.tdata1_csr_inst.data[5:0]<=4
         && match_trigger==1){
        bins trace_in_isr = {1};
    }

    sdtrig__icount_cp_action1_in_ehandler : coverpoint in_excp_handler
    iff (i_csr.tdata1_csr_inst.ttype==3 && i_csr.tselect_csr_inst.select==8
         && i_csr.tdata1_csr_inst.data[5:0]==1 && i_csr.tdata1_csr_inst.data[24]==1){
        bins dm_in_exc_handler = {1};
    }

    sdtrig__icount_cp_trace_in_ehandler : coverpoint in_excp_handler
    iff (i_csr.tdata1_csr_inst.ttype==3 && i_csr.tselect_csr_inst.select==8
         && i_csr.tdata1_csr_inst.data[5:0]>=2 && i_csr.tdata1_csr_inst.data[5:0]<=4
         && match_trigger==1){
        bins trace_in_exc_handler = {1};
    }

    sdtrig__icount_cp_action1_dmode : coverpoint i_csr.tdata1_csr_inst.dmode
    iff (i_csr.tdata1_csr_inst.ttype==3 && i_csr.tselect_csr_inst.select==8
         && i_csr.tdata1_csr_inst.data[5:0]==1 && i_csr.tdata1_csr_inst.data[24]==1){
        bins dmode_set = {1};
    }

    sdtrig__icount_cp_action1_x_step : coverpoint i_csr.tdata1_csr_inst.data[8]
    iff (i_csr.tdata1_csr_inst.ttype==3 && i_csr.tselect_csr_inst.select==8
         && i_csr.tdata1_csr_inst.data[5:0]==1 && i_csr.dcsr_csr_inst.step == 1
         && privilegemode_var == PRIVILEGEMODE_MACHINE){
        bins ICOUNT_DM_STEP_PENDING = {1};
    }

    sdtrig__icount_cp_step_intr_collision : coverpoint i_csr.tdata1_csr_inst.data[8]
    iff (i_csr.tdata1_csr_inst.ttype==3 && i_csr.tselect_csr_inst.select==8
         && i_csr.tdata1_csr_inst.data[5:0]==1 && i_csr.dcsr_csr_inst.step == 1
         && ((i_csr.mie_csr_inst.meie == 1 && i_csr.mip_csr_inst.meip == 1) ||
             (i_csr.mie_csr_inst.mtie == 1 && i_csr.mip_csr_inst.mtip == 1) ||
             (i_csr.mie_csr_inst.msie == 1 && i_csr.mip_csr_inst.msip == 1) ||
             (i_csr.mie_csr_inst.seie == 1 && i_csr.mip_csr_inst.seip == 1) ||
             (i_csr.mie_csr_inst.stie == 1 && i_csr.mip_csr_inst.stip == 1) ||
             (i_csr.mie_csr_inst.ssie == 1 && i_csr.mip_csr_inst.ssip == 1))){
        bins step_intr_icount_pending = {1};
    }

endgroup : sdtrig__cg

`endif