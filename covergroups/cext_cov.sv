`ifndef COVERAGE_UNSUPPORTED

import cp_pkg::*;

covergroup cext__cg with function sample(
    csr_cov_sample i_csr
);
    
    option.per_instance = 1;
    option.name = "cg_cext";

    cext__general_cp_cext_instr: coverpoint cext_var {
        ignore_bins ignore_vals =   {
            CEXT_C_FLW,
            CEXT_C_FLWSP,
            CEXT_C_FSW,
            CEXT_C_FSWSP,
            CEXT_C_JAL,     
            CEXT_C_LQ,
            CEXT_C_SLLI64,
            CEXT_C_SQ,
            CEXT_C_SRAI64,
            CEXT_C_SRLI64
        };  
    }
    
    cext__general_cp_privilege_modes: coverpoint privilegemode_var {
        bins vals[]     =   {
            PRIVILEGEMODE_MACHINE, 
            PRIVILEGEMODE_SUPERVISOR, 
            PRIVILEGEMODE_USER
        };
    }
    
    cext__general_cr_all_priv: cross cext__general_cp_cext_instr, cext__general_cp_privilege_modes;

    cext__general_cp_misa_d_dis_dcInstr: coverpoint cext_var iff ((i_csr.misa_csr_inst.ext[3] == 0) || (i_csr.misa_csr_inst.ext[5] == 0)) {
        bins vals   =   {   
            CEXT_C_FLDSP, 
            CEXT_C_FSDSP, 
            CEXT_C_FLD, 
            CEXT_C_FSD
        };
    }

    cext__general_cp_imm_jump_instr: coverpoint instrenum_var {
        bins vals=   {
            INSTRENUM_C_J,
            INSTRENUM_C_BEQZ,
            INSTRENUM_C_BNEZ,
            INSTRENUM_JAL,
            INSTRENUM_BEQ,
            INSTRENUM_BNE,
            INSTRENUM_BLT,
            INSTRENUM_BLTU,
            INSTRENUM_BGE,
            INSTRENUM_BGEU
        };
    }
    
    cext__general_cp_reg_jump_instr: coverpoint cext_var {
        bins vals =   {
            CEXT_C_JR,
            CEXT_C_JALR
        };
    }

    cext__contran_cp_cj_max_min_jump: coverpoint rs1_val[10:0]{
        bins vals[] = {
            SMIN11,
            SMAX11
        } iff(instrenum_var == INSTRENUM_C_J);
    }

    cext__contran_cp_cbranch_max_min_jump: coverpoint rs2_val[7:0]{
        bins vals[] = {
            SMIN8,
            SMAX8
        } iff(instrenum_var == (INSTRENUM_C_BEQZ || INSTRENUM_C_BNEZ));
    }

    cext__contran_cp_branch_compare_equal:   coverpoint instrenum_var { 
        bins vals[] = {
            INSTRENUM_C_BEQZ,
            INSTRENUM_C_BNEZ
        } iff (rd_val == 0);
    }

    cext__contran_cp_branch_compare_unequal: coverpoint instrenum_var { 
        bins vals[] = {
            INSTRENUM_C_BEQZ,
            INSTRENUM_C_BNEZ
        } iff(rd_val != 0 );
    }

    cext__contran_cp_jump_2byte: coverpoint NextVirtPc[1:0]{
        bins vals[] = {
            2'b10
        } iff (br_taken == 1);
    }

    cext__contran_cp_jalr_2byte_jump: coverpoint instrenum_var{
        bins jalr_2byte_jump[] = {
            INSTRENUM_JALR
        } iff (((rs1_val+rs2_val & 2'b11) == 2'b10) && (br_taken == 1));
    }

    cext__contran_cp_imm_2byte_jump: cross cext__contran_cp_jump_2byte, cext__general_cp_imm_jump_instr;
    cext__contran_cp_reg_2byte_jump: cross cext__contran_cp_jump_2byte, cext__general_cp_reg_jump_instr;

    cext__contran_cp_jump_1byte: coverpoint rd_val[0]{
        bins jump_2byte[] = {
            1'b1
        } iff (br_taken == 1);
    }
    
    cext__contran_cp_reg_1byte_jump: cross cext__contran_cp_jump_1byte, cext__general_cp_reg_jump_instr;
    cext__contran_cp_jalr_1byte_jump: coverpoint instrenum_var{
        bins jalr_1byte_jump[] = {
            INSTRENUM_JALR
        } iff (((rs1_val+rs2_val & 1'b1) == 1) && (br_taken == 1));
    }
    
    cext__intcomp_cp_cli_max_min_imm: coverpoint rs2_val[5:0] iff(rd!=0){
        bins imm_cli_maxmin[] = {  
            SMIN6,
            SMAX6
        } iff (instrenum_var == INSTRENUM_C_LI);
    }

    cext__intcomp_cp_clui_max_min_imm: coverpoint rs1_val[5:0] iff( (rd!=0) || (rd!=2) ){
        bins imm_clui_maxmin[] = {
            SMIN6,
            SMAX6
        } iff (instrenum_var == INSTRENUM_C_LUI);
    }

    cext__intcomp_cp_caddi_max_min_imm: coverpoint rs2_val[5:0] iff(rd!=0){
        bins imm_caddi_maxmin[] = {
            SMIN6,
            SMAX6,
            UMAX6
        } iff (instrenum_var == INSTRENUM_C_ADDI);
    }

    cext__intcomp_cp_caddiw_max_min_imm: coverpoint rs2_val[5:0] iff(rd!=0){
        bins imm_caddiw_maxmin[] = {
            SMIN6,
            SMAX6,
            UMIN6,
            UMAX6
        } iff (instrenum_var == INSTRENUM_C_ADDIW);
    }
    
    cext__intcomp_cp_caddi16sp_max_min_imm: coverpoint rs2_val[5:0]{
        bins imm_caddi16sp_maxmin[] = {
            SMIN6,
            SMAX6,
            UMAX6
        } iff (instrenum_var == INSTRENUM_C_ADDI16SP); 
    }
    
    cext__intcomp_cp_caddi4spn_max_min_imm: coverpoint rs2_val[7:0]{
        bins imm_caddi4spn_maxmin[] = {
            SMIN8,
            SMAX8,
            UMAX8
        } iff (instrenum_var == INSTRENUM_C_ADDI4SPN); 
    }

    cext__intcomp_cp_cslli_max_min_imm: coverpoint rs2_val[5:0] iff (rd!=0){
        bins imm_cslli_maxmin[] = {
            SMIN6,
            SMAX6,
            UMAX6
        } iff (instrenum_var == INSTRENUM_C_SLLI); 
    }
    
    cext__intcomp_cp_csrli_max_min_imm: coverpoint rs2_val[4:0] iff (rs2_val[5]!=1'b1){
        bins imm_csrli_maxmin[] = {
            SMIN5,
            SMAX5,
            UMAX5
        } iff (instrenum_var == INSTRENUM_C_SRLI);
    }

    cext__intcomp_cp_csrai_max_min_imm: coverpoint rs2_val[4:0] iff (rs2_val[5]!=1'b1){
        bins imm_csrai_maxmin[] = {
            SMIN5,
            SMAX5,
            UMAX5
        } iff (instrenum_var == INSTRENUM_C_SRAI);
    }
    cext__intcomp_cp_candi_max_min_imm: coverpoint rs2_val[5:0] iff(rd != 0){
        bins imm_candi_maxmin[] = {
            SMIN6,
            SMAX6,
            UMAX6,
            UMIN6
        } iff (instrenum_var == INSTRENUM_C_ANDI);
    }

    cext__in_cp_nop_instr: coverpoint Inst{
        bins nop_instr[] = {16'h0001} ;
    }
    cext__in_cp_ill_instr: coverpoint Inst{
        bins ill_instr[] = {16'h0000} ;
    }

    cext__spl_cp_enc: coverpoint Inst[15:0]{
        wildcard bins cmv_enc_cjr[5]        = {16'b1000_xxxx_x000_0010} ; 
        bins caddi_enc_cnop[]               = {16'b0000_0000_0000_0001}; 
        bins cjalr_enc_cbreak[]             = {16'b1001_0000_0000_0010};
        wildcard bins clui_enc_caddi16sp[6] = {16'b011x_0001_0xxx_xx01};
    }

    cext__resv_cp: coverpoint Inst[15:0]{
        bins resv_rd_0_clwsp[]      = {16'h4002};
        bins resv_rd_0_cswsp[]      = {16'h6002};
        bins resv_imm_0_caddiw[]    = {16'h2001};
        bins resv_imm_0_clui[]      = {16'h6401};
        bins resv_imm_0_caddi16sp[] = {16'h6101};
        bins resv_imm_0_caddi4spn[] = {16'h0000};
        bins resv_rs1_0_ccjr[]      = {16'h8002};
    }
    
    cext__spl_cp_hint_nop: coverpoint Inst[15:0]{
        wildcard bins hint_cnop[5]  = {16'b0000_0000_0xxx_xx01};  
        ignore_bins ignore_cnop     = {16'b0000_0000_0000_0001}; 
    } 
    cext__spl_cp_hint_caddi: coverpoint Inst[15:0]{
        wildcard bins hint_caddi[5]  = {16'b0000_xxxx_x000_0001}; 
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
        bins hint_cssli[] = {
            INSTRENUM_C_SLLI,
            INSTRENUM_C_SRLI,
            INSTRENUM_C_SRAI
        } iff (rs2_val==0); 
    }
endgroup

`endif 