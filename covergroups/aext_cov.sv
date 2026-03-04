`ifndef COVERAGE_UNSUPPORTED

import cp_pkg::*;

covergroup aext__cg with function sample(csr_cov_sample i_csr);
    option.per_instance = 1;
    option.name = "cg_aext";

    aext__general_cp_atomic_instr:          coverpoint instrenum_var{bins atomic_instrs[]           = aext_arr;}
    aext__general_cp_amo_instr:             coverpoint instrenum_var{bins atomic_instrs[1]          = aext_arr; ignore_bins lr_sc_intrs = lr_sc_instrs_arr;}
    aext__general_cp_lr_instr:              coverpoint instrenum_var{bins lr_instrs[1]              = {INSTRENUM_LR_D, INSTRENUM_LR_W};}
    aext__general_cp_sc_instr:              coverpoint instrenum_var{bins sc_instrs[1]              = {INSTRENUM_SC_D, INSTRENUM_SC_W};}
    aext__general_cp_amo_w_instr:           coverpoint instrenum_var{bins amo_w_instrs[1]           = amo_w_instrs_arr;}
    aext__general_cp_amo_d_instr:           coverpoint instrenum_var{bins amo_d_instrs[1]           = amo_d_instrs_arr;}
    aext__general_cp_amo_signed_w_instr:    coverpoint instrenum_var{bins amo_signed_w_instrs[1]    = amo_w_instrs_arr; ignore_bins amo_unsigned_w_instrs = {INSTRENUM_AMOMINU_W,INSTRENUM_AMOMINU_W};}
    aext__general_cp_amo_signed_d_instr:    coverpoint instrenum_var{bins amo_signed_d_instrs[1]    = amo_d_instrs_arr; ignore_bins amo_unsigned_d_instrs = {INSTRENUM_AMOMINU_D,INSTRENUM_AMOMINU_D};}
    aext__general_cp_amo_unsigned_w_instr:  coverpoint instrenum_var{bins amo_unsigned_w_instrs[1]  = {INSTRENUM_AMOMINU_W,INSTRENUM_AMOMINU_W};}
    aext__general_cp_amo_unsigned_d_instr:  coverpoint instrenum_var{bins amo_unsigned_d_instrs[1]  = {INSTRENUM_AMOMINU_D,INSTRENUM_AMOMINU_D};}

    aext__general_cp_privilege_modes: coverpoint privilegemode_var{
        bins priv_mode[] = {PRIVILEGEMODE_MACHINE, PRIVILEGEMODE_SUPERVISOR, PRIVILEGEMODE_USER};
    }

    aext__general_cr_amo_priv:   cross aext__general_cp_privilege_modes, aext__general_cp_atomic_instr;

    aext__general_cp_aq_bit: coverpoint Inst[26] {bins aq_bit[] = {0,1};}
    aext__general_cp_rl_bit: coverpoint Inst[25] {bins rl_bit[] = {0,1};}
    aext__general_cr_aqrl_bits_lr_sc_instr: cross aext__general_cp_atomic_instr, aext__general_cp_aq_bit, aext__general_cp_rl_bit;

    aext__resvloss_cp_reservation_loss_reason: coverpoint cancellrcause_var {
        bins reasons[] = cancel_lr_cause_arr  iff (reservation_valid_prev != reservation_valid_current);
        ignore_bins ignore_reasons = {CANCELLRCAUSE_INTERACTIVE, CANCELLRCAUSE_RESET, CANCELLRCAUSE_SERVER};
        ignore_bins debug = {CANCELLRCAUSE_ENTER_DEBUG, CANCELLRCAUSE_EXIT_DEBUG}; 
        ignore_bins zawrs = {CANCELLRCAUSE_WRS_NTO, CANCELLRCAUSE_WRS_STO}; 
        ignore_bins trap = {CANCELLRCAUSE_TRAP};           
    }

    aext__excp_cp_reservation_exception: coverpoint exception_var iff(match_excp==1){
        bins exceptions[] = atomics_exceptions_arr iff((reservation_valid_prev == 1 || reservation_valid_current == 1)) ;
        ignore_bins guest_faults = {EXCEPTION_LOAD_GUEST_PAGE_FAULT, EXCEPTION_STORE_GUEST_PAGE_FAULT, EXCEPTION_INST_GUEST_PAGE_FAULT};
    }

    // Sign Bits rs1, rs2
    aext__data_cp_rs1_sign_w_lr: coverpoint rd_val[31]  { bins minmax_rs1_sign_w[] = {0,1} iff(instrenum_var == INSTRENUM_LR_W);}
    aext__data_cp_rs1_sign_d_lr: coverpoint rd_val[63]  { bins minmax_rs1_sign_d[] = {0,1} iff(instrenum_var == INSTRENUM_LR_D);}
    aext__data_cp_rs1_sign_w_sc: coverpoint rs2_val[31] { bins minmax_rs2_sign_w[] = {0,1} iff(instrenum_var == INSTRENUM_SC_W);}
    aext__data_cp_rs1_sign_d_sc: coverpoint rs2_val[63] { bins minmax_rs2_sign_d[] = {0,1} iff(instrenum_var == INSTRENUM_SC_D);}

    aext__data_cp_rs1_sign_w: coverpoint rd_val[31]  { bins minmax_rs1_sign_w[] = {0,1};} 
    aext__data_cp_rs1_sign_d: coverpoint rd_val[63]  { bins minmax_rs1_sign_d[] = {0,1};}
    aext__data_cp_rs2_sign_w: coverpoint rs2_val[31] { bins minmax_rs2_sign_w[] = {0,1};}
    aext__data_cp_rs2_sign_d: coverpoint rs2_val[63] { bins minmax_rs2_sign_d[] = {0,1};}
    
    aext__data_cr_sign_w_instr: cross aext__data_cp_rs1_sign_w, aext__data_cp_rs2_sign_w, aext__general_cp_amo_signed_w_instr;
    aext__data_cr_sign_d_instr: cross aext__data_cp_rs1_sign_d, aext__data_cp_rs2_sign_d, aext__general_cp_amo_signed_d_instr;

    
    // Minmax rs1, rs2
    aext__data_cp_rs1_w_lr: coverpoint rd_val[31:0]  { bins minmax_rs1_w[] = {UMIN32, UMAX32, SMIN32, SMAX32} iff(instrenum_var == INSTRENUM_LR_W);}
    aext__data_cp_rs1_d_lr: coverpoint rd_val        { bins minmax_rs1_d[] = {UMIN64, UMAX64, SMIN64, SMAX64} iff(instrenum_var == INSTRENUM_LR_D);}
    aext__data_cp_rs1_w_sc: coverpoint rs2_val[31:0] { bins minmax_rs2_w[] = {UMIN32, UMAX32, SMIN32, SMAX32} iff(instrenum_var == INSTRENUM_SC_W);}
    aext__data_cp_rs1_d_sc: coverpoint rs2_val       { bins minmax_rs2_d[] = {UMIN64, UMAX64, SMIN64, SMAX64} iff(instrenum_var == INSTRENUM_SC_D);}
    
    aext__data_cp_rd_sc: coverpoint instrenum_var{
        bins sc_rd_val0[]        = {INSTRENUM_SC_D, INSTRENUM_SC_W} iff(rd_val  == 0);
        bins sc_rd_val1[]        = {INSTRENUM_SC_D, INSTRENUM_SC_W} iff(rd_val  == 1);
    }

    aext__data_cp_rs1_w: coverpoint rd_val[31:0]  {bins Uminmax_rs1_data_w[] = {UMIN32, UMAX32, SMIN32, SMAX32};}
    aext__data_cp_rs1_d: coverpoint rd_val        {bins Uminmax_rs1_data_d[] = {UMIN64, UMAX64, SMIN64, SMAX64};}
    aext__data_cp_rs2_w: coverpoint rs2_val[31:0] {bins Uminmax_rs2_val_w[]  = {UMIN32, UMAX32, SMIN32, SMAX32};}
    aext__data_cp_rs2_d: coverpoint rs2_val       {bins Uminmax_rs2_val_d[]  = {UMIN64, UMAX64, SMIN64, SMAX64};}

    aext__data_cr_rs1_w_instr: cross aext__data_cp_rs1_w, aext__general_cp_amo_signed_w_instr;
    aext__data_cr_rs2_w_instr: cross aext__data_cp_rs2_w, aext__general_cp_amo_signed_w_instr;
    aext__data_cr_rs1_d_instr: cross aext__data_cp_rs1_d, aext__general_cp_amo_signed_d_instr;
    aext__data_cr_rs2_d_instr: cross aext__data_cp_rs2_d, aext__general_cp_amo_signed_d_instr;

    aext__data_cp_unsigned_rs1_w: coverpoint rd_val[31:0]  {bins Uminmax_rs1_data_w[] = {UMIN32, UMAX32};}
    aext__data_cp_unsigned_rs1_d: coverpoint rd_val        {bins Uminmax_rs1_data_d[] = {UMIN64, UMAX64};}
    aext__data_cp_unsigned_rs2_w: coverpoint rs2_val[31:0] {bins Uminmax_rs2_val_w[]  = {UMIN32, UMAX32};}
    aext__data_cp_unsigned_rs2_d: coverpoint rs2_val       {bins Uminmax_rs2_val_d[]  = {UMIN64, UMAX64};}

    aext__data_cr_unsigned_rs1_w_instr: cross aext__data_cp_unsigned_rs1_w, aext__general_cp_amo_unsigned_w_instr;
    aext__data_cr_unsigned_rs2_w_instr: cross aext__data_cp_unsigned_rs2_w, aext__general_cp_amo_unsigned_w_instr;
    aext__data_cr_unsigned_rs1_d_instr: cross aext__data_cp_unsigned_rs1_d, aext__general_cp_amo_unsigned_d_instr;
    aext__data_cr_unsigned_rs2_d_instr: cross aext__data_cp_unsigned_rs2_d, aext__general_cp_amo_unsigned_d_instr;

    // Comparision rs1, rs2
    aext__data_cp_amo_comparision_rs1_equal_rs2:   coverpoint instrenum_var{bins amo_comparision_instrs[] = amo_comparision_instrs_arr iff(rd_val == rs2_val);}
    aext__data_cp_amo_comparision_rs1_greater_rs2: coverpoint instrenum_var{bins amo_comparision_instrs[] = amo_comparision_instrs_arr iff(rd_val >  rs2_val);}
    aext__data_cp_amo_comparision_rs1_less_rs2:    coverpoint instrenum_var{bins amo_comparision_instrs[] = amo_comparision_instrs_arr iff(rd_val <  rs2_val);}

    // Overflow AMOADD
    aext__data_cp_overflow: coverpoint instrenum_var{
        // conditions are based rs1_val, and rd_val which stores the result, rs1_val contains memory address, can't obtain data at the memory address.
        bins amoadd_w_overflow1[] = {INSTRENUM_AMOADD_W} iff(rd_val[31:0] < rs2_val[31:0] && rs2_val[31:0] > 0);
        bins amoadd_w_overflow2[] = {INSTRENUM_AMOADD_W} iff(rd_val[31:0] < UMAX32 && rs2_val[31:0] == UMAX32);
        bins amoadd_w_overflow3[] = {INSTRENUM_AMOADD_W} iff((rd_val[31]==0 && rd_val[30:0] < rs2_val[30:0]) && (rs2_val[31]==0 && rs2_val[30:0] > 0));
        bins amoadd_w_overflow4[] = {INSTRENUM_AMOADD_W} iff((rd_val[31]==0 && rd_val[30:0] < SMAX32) && (rs2_val[31]==0 && rs2_val[30:0] == SMAX32));

        bins amoadd_d_overflow1[] = {INSTRENUM_AMOADD_D} iff(rd_val < rs2_val && rs2_val > 0);
        bins amoadd_d_overflow2[] = {INSTRENUM_AMOADD_D} iff(rd_val < UMAX64 && rs2_val == UMAX64);
        bins amoadd_d_overflow3[] = {INSTRENUM_AMOADD_D} iff((rd_val[63]==0 && rd_val[62:0] < rs2_val) && (rs2_val[63]==0 && rs2_val[62:0] > 0));
        bins amoadd_d_overflow4[] = {INSTRENUM_AMOADD_D} iff(rd_val < SMAX64 && rs2_val == SMAX64);
    }

    // Underflow AMOADD
    aext__data_cp_underflow: coverpoint instrenum_var{
        bins amoadd_w_underflow2[] = {INSTRENUM_AMOADD_W} iff(rd_val[31] == 0 && rs2_val == SMIN32);
        bins amoadd_d_underflow4[] = {INSTRENUM_AMOADD_D} iff(rd_val[63] == 0 && rs2_val == SMIN64);
    }

    // Exceptions
    aext__excp_cp_store_faults: coverpoint exception_var iff(match_excp==1){ //sample only when exception occurs (match_excp)
        bins store_faults[] = {EXCEPTION_STORE_ACC_FAULT, EXCEPTION_STORE_PAGE_FAULT};
        ignore_bins guest_store_faults = {EXCEPTION_STORE_GUEST_PAGE_FAULT};
    }
    aext__excp_cp_load_faults: coverpoint exception_var iff(match_excp==1){ //sample only when exception occurs (match_excp)
        bins load_faults[] = {EXCEPTION_LOAD_ACC_FAULT, EXCEPTION_LOAD_PAGE_FAULT};
        ignore_bins guest_load_faults = {EXCEPTION_LOAD_GUEST_PAGE_FAULT};
    }
    aext__excp_cr_amo_exception: cross aext__general_cp_amo_instr, aext__excp_cp_store_faults;
    aext__excp_cr_lr_exception:  cross aext__general_cp_lr_instr,  aext__excp_cp_load_faults;
    aext__excp_cr_sc_exception:  cross aext__general_cp_sc_instr,  aext__excp_cp_store_faults;

    aext__excp_cp_atomic_address_misaligned: coverpoint instrenum_var{
        bins lr_sc_w[] = {INSTRENUM_LR_W, INSTRENUM_SC_W} iff(rs1_val[1:0] != 0);
        bins lr_sc_d[] = {INSTRENUM_LR_D, INSTRENUM_SC_D} iff(rs1_val[2:0] != 0);
        bins amo_w_instrs[1] = amo_w_instrs_arr iff(rs1_val[1:0] != 0);
        bins amo_d_instrs[1] = amo_d_instrs_arr iff(rs1_val[2:0] != 0);
    }

endgroup

`endif
