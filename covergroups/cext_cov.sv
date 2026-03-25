`ifndef COVERAGE_UNSUPPORTED

import cp_pkg::*;

covergroup cext__cg with function sample(
    csr_cov_sample i_csr
);
    
    option.per_instance = 1;
    option.name = "cg_cext";

    cext__general_cp_cext_instr: coverpoint instrenum_var{
        bins cext_instrs[] = cext_arr;
        ignore_bins illegal_instrs = {INSTRENUM_C_FLW,INSTRENUM_C_FLWSP,INSTRENUM_C_FSW,INSTRENUM_C_FSWSP,INSTRENUM_C_JAL,     //RV32only
                                    INSTRENUM_C_LQ,INSTRENUM_C_SLLI64,INSTRENUM_C_SQ,INSTRENUM_C_SRAI64,INSTRENUM_C_SRLI64};   //RV128only
    }
    //priviledge mode
    cext__general_cp_privilege_modes: coverpoint privilegemode_var{
        bins priv_mode[] = {PRIVILEGEMODE_MACHINE, PRIVILEGEMODE_SUPERVISOR, PRIVILEGEMODE_USER};
    }
    // all c_ext instruction crossed with privilege modes
    cext__general_cr_all_priv: cross cext__general_cp_cext_instr, cext__general_cp_privilege_modes;

    //rv64dc only instructions when misa_d is 0
    cext__general_cp_misa_d_dis_dcInstr: coverpoint instrenum_var iff ((i_csr.misa_csr_inst.ext[3] == 0) || (i_csr.misa_csr_inst.ext[5] == 0)) {
        bins excp_instr = {INSTRENUM_C_FLDSP, INSTRENUM_C_FSDSP, INSTRENUM_C_FLD, INSTRENUM_C_FSD};
    }

    // imm based jumps
    cext__general_cp_imm_jump_instr: coverpoint instrenum_var{
        bins imm_jump = {INSTRENUM_C_J, INSTRENUM_C_BEQZ, INSTRENUM_C_BNEZ, INSTRENUM_JAL, INSTRENUM_BEQ, INSTRENUM_BNE, INSTRENUM_BLT, INSTRENUM_BLTU, INSTRENUM_BGE, INSTRENUM_BGEU};
    }
    // reg based jumps
    cext__general_cp_reg_jump_instr: coverpoint instrenum_var{
        bins reg_jump = {INSTRENUM_C_JR, INSTRENUM_C_JALR};
    }

    /* ---Control Transfer Instruction--- */
    // max and min jump for C.J, C.BEQZ, C.BNEZ 
    cext__contran_cp_cj_max_min_jump: coverpoint rs1_val[10:0]{
        bins jump_cj_maxmin[] = {SMIN11,SMAX11} iff(instrenum_var == INSTRENUM_C_J);
    }
    cext__contran_cp_cbranch_max_min_jump: coverpoint rs2_val[7:0]{
        bins jump_cbranch_maxmin[] = {SMIN8,SMAX8} iff(instrenum_var == (INSTRENUM_C_BEQZ || INSTRENUM_C_BNEZ));
    }
    // branch taken and not taken cases for c.beqz and bnez 
    cext__contran_cp_branch_compare_equal:   coverpoint instrenum_var { bins conditional_branch_instrs[] = {INSTRENUM_C_BEQZ,INSTRENUM_C_BNEZ} iff(rd_val == 0);}
    cext__contran_cp_branch_compare_unequal: coverpoint instrenum_var { bins conditional_branch_instrs[] = {INSTRENUM_C_BEQZ,INSTRENUM_C_BNEZ} iff(rd_val != 0 );}
    //2-byte aligned jumps
    cext__contran_cp_jump_2byte: coverpoint NextVirtPc[1:0]{
        bins jump_2byte[] = {2'b10} iff (br_taken == 1);
    }
    cext__contran_cp_imm_2byte_jump: cross cext__contran_cp_jump_2byte, cext__general_cp_imm_jump_instr;
    cext__contran_cp_reg_2byte_jump: cross cext__contran_cp_jump_2byte, cext__general_cp_reg_jump_instr;
    cext__contran_cp_jalr_2byte_jump: coverpoint instrenum_var{
        bins jalr_2byte_jump[] = {INSTRENUM_JALR} iff (((rs1_val+rs2_val & 2'b11) == 2'b10) && (br_taken == 1));
    }
    //1-byte aligned jumps
    cext__contran_cp_jump_1byte: coverpoint rd_val[0]{
        bins jump_2byte[] = {1'b1} iff (br_taken == 1);
    }
    cext__contran_cp_reg_1byte_jump: cross cext__contran_cp_jump_1byte, cext__general_cp_reg_jump_instr;
    cext__contran_cp_jalr_1byte_jump: coverpoint instrenum_var{
        bins jalr_1byte_jump[] = {INSTRENUM_JALR} iff (((rs1_val+rs2_val & 1'b1) == 1) && (br_taken == 1));
    }
    
    /* ---Interger Computational Instruction--- */ 
    //checking max and min for all computation instr
    cext__intcomp_cp_cli_max_min_imm: coverpoint rs2_val[5:0] iff(rd!=0){
        bins imm_cli_maxmin[] = {SMIN6,SMAX6} iff (instrenum_var == INSTRENUM_C_LI);
    }
    cext__intcomp_cp_clui_max_min_imm: coverpoint rs1_val[5:0] iff( (rd!=0) || (rd!=2) ){
        bins imm_clui_maxmin[] = {SMIN6,SMAX6} iff (instrenum_var == INSTRENUM_C_LUI);
    }
    cext__intcomp_cp_caddi_max_min_imm: coverpoint rs2_val[5:0] iff(rd!=0){
        bins imm_caddi_maxmin[] = {SMIN6,SMAX6,UMAX6} iff (instrenum_var == INSTRENUM_C_ADDI); // if imm=UMIN6/'0' OP is not valid, covered seprately
    }
    cext__intcomp_cp_caddiw_max_min_imm: coverpoint rs2_val[5:0] iff(rd!=0){
        bins imm_caddiw_maxmin[] = {SMIN6,SMAX6,UMIN6,UMAX6} iff (instrenum_var == INSTRENUM_C_ADDIW);
    }
    cext__intcomp_cp_caddi16sp_max_min_imm: coverpoint rs2_val[5:0]{
        bins imm_caddi16sp_maxmin[] = {SMIN6,SMAX6,UMAX6} iff (instrenum_var == INSTRENUM_C_ADDI16SP); // if imm=UMIN6/'0' OP is not valid, covered seprately
    }
    cext__intcomp_cp_caddi4spn_max_min_imm: coverpoint rs2_val[7:0]{
        bins imm_caddi4spn_maxmin[] = {SMIN8,SMAX8,UMAX8} iff (instrenum_var == INSTRENUM_C_ADDI4SPN); // if imm=UMIN8/'0' OP is not valid, covered seprately
    }
    cext__intcomp_cp_cslli_max_min_imm: coverpoint rs2_val[5:0] iff (rd!=0){
        bins imm_cslli_maxmin[] = {SMIN6,SMAX6,UMAX6} iff (instrenum_var == INSTRENUM_C_SLLI); // if imm=UMIN6/'0' OP is not valid, covered seprately
    }
    cext__intcomp_cp_csrli_max_min_imm: coverpoint rs2_val[4:0] iff (rs2_val[5]!=1'b1){
        bins imm_csrli_maxmin[] = {SMIN5,SMAX5,UMAX5} iff (instrenum_var == INSTRENUM_C_SRLI); // if imm[5]=1 OP and imm=0 OP is not valid, covered seprately
    }
    cext__intcomp_cp_csrai_max_min_imm: coverpoint rs2_val[4:0] iff (rs2_val[5]!=1'b1){
        bins imm_csrai_maxmin[] = {SMIN5,SMAX5,UMAX5} iff (instrenum_var == INSTRENUM_C_SRAI); // if imm[5]=1 OP and imm=0 OP is not valid, covered seprately
    }
    cext__intcomp_cp_candi_max_min_imm: coverpoint rs2_val[5:0] iff(rd != 0){
        bins imm_candi_maxmin[] = {SMIN6,SMAX6,UMAX6,UMIN6} iff (instrenum_var == INSTRENUM_C_ANDI);
    }


    /* ---Interger Reg-Reg Instruction--- */ 
    //

    /* ---NOP and Illegal compressed Instruction--- */ 
    cext__in_cp_nop_instr: coverpoint Inst{
        bins nop_instr[] = {16'h0001} ;
    }
    cext__in_cp_ill_instr: coverpoint Inst{
        bins ill_instr[] = {16'h0000} ;
    }


    /* ---Special cases Instruction--- */ 
    // Instrcution encode to different instruction with specific constaraint 
    cext__spl_cp_enc: coverpoint Inst[15:0]{
        wildcard bins cmv_enc_cjr[5]        = {16'b1000_xxxx_x000_0010} ;  // C.MV rd, x0 == C.JR rd
        bins caddi_enc_cnop[]               = {16'b0000_0000_0000_0001};  // C.ADDI x0, imm == C.NOP
        bins cjalr_enc_cbreak[]             = {16'b1001_0000_0000_0010}; // C.JALR x0 == C.EBREAK
        wildcard bins clui_enc_caddi16sp[6] = {16'b011x_0001_0xxx_xx01}; // C.LUI x2, nzimm == C.ADDI16SP
    }
    
    /* ---Reserved and HINTs Instruction--- */ 
    // Instrcution is reserved for specific conditions
    cext__resv_cp: coverpoint Inst[15:0]{
        bins resv_rd_0_clwsp[]      = {16'h4002};
        bins resv_rd_0_cswsp[]      = {16'h6002};
        bins resv_imm_0_caddiw[]    = {16'h2001};
        bins resv_imm_0_clui[]      = {16'h6401};
        bins resv_imm_0_caddi16sp[] = {16'h6101};
        bins resv_imm_0_caddi4spn[] = {16'h0000};
        bins resv_rs1_0_ccjr[]      = {16'h8002};
    }
    //instructions decode to HINTs
    cext__spl_cp_hint_nop: coverpoint Inst[15:0]{
        wildcard bins hint_cnop[5]  = {16'b0000_0000_0xxx_xx01};  // C.NOP hints
        ignore_bins ignore_cnop     = {16'b0000_0000_0000_0001}; 
    } 
    cext__spl_cp_hint_caddi: coverpoint Inst[15:0]{
        wildcard bins hint_caddi[5]  = {16'b0000_xxxx_x000_0001};  //C.ADDI Hints
        ignore_bins ignore_cnop     = {16'b0000_0000_0000_0001};
    }
    cext__spl_cp_hint_comb: coverpoint rd {
        bins hint_cli[]     = {0} iff (instrenum_var == INSTRENUM_C_LI);
        bins hint_clui[]    = {0} iff ((instrenum_var == INSTRENUM_C_LUI) && (rs1_val!==0));
        bins hint_cmv[]     = {0} iff ((instrenum_var == INSTRENUM_C_MV) && (rs2!==0));  
        bins hint_ntl[]     = {0} iff ((instrenum_var == INSTRENUM_C_ADD) && (rs2!=0 && rs2!=2 && rs2!=3 && rs2!=4 && rs2!=5));
        bins hint_cssli[]   = {0} iff ((instrenum_var == INSTRENUM_C_SLLI) && (rs2_val!=0));
    }
    cext__spl_cp_hint_cs64: coverpoint instrenum_var{
        bins hint_cssli[] = {INSTRENUM_C_SLLI,INSTRENUM_C_SRLI,INSTRENUM_C_SRAI} iff (rs2_val==0); //SLLI64, SRLI64, SRAI64 are HINTs for RV64
    }
endgroup

`endif 