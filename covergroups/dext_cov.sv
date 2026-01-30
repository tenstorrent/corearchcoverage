//  SPDX-FileCopyrightText: © 2026 Tenstorrent AI ULC
//  SPDX-License-Identifier: Apache-2.0
`ifndef COVERAGE_UNSUPPORTED

import cp_pkg::*;

covergroup dext__cg with function sample(csr_cov_sample i_csr);
    option.per_instance = 1;
    option.name = "cg_dext";

    dext__fcsr_rd_x0: coverpoint instrenum_var{
        bins frcsr_rd       = {INSTRENUM_CSRRS} iff((csrenum_var==CSRENUM_FCSR) && (rd==0) && (rs1==0));
        bins fscsr_rd_rs    = {INSTRENUM_CSRRW} iff((csrenum_var==CSRENUM_FCSR) && (rd==0));
        bins frrm_rd        = {INSTRENUM_CSRRS} iff((csrenum_var==CSRENUM_FRM)  && (rd==0) && (rs1==0));
        bins fsrm_rd_rs     = {INSTRENUM_CSRRW} iff((csrenum_var==CSRENUM_FRM)  && (rd==0));
        bins frflags_rd     = {INSTRENUM_CSRRS} iff((csrenum_var==CSRENUM_FFLAGS) && (rd==0) && (rs1==0));
        bins fsflags_rd_rs  = {INSTRENUM_CSRRW} iff((csrenum_var==CSRENUM_FFLAGS) && (rd==0));
    }

    dext__fcsr_rs1: coverpoint rs1_val[31:8]{
        bins rs1_all[]      = {24'h000001,24'hffffff}; 
        bins rs1_remaining  = {[24'h000002:24'hfffffe]};
    }

    dext__fcsr_fscsr_reserv: coverpoint instrenum_var{
        bins fscsr_rs_reserv    = {INSTRENUM_CSRRW} iff((csrenum_var==CSRENUM_FCSR) && (rd==0));
        bins fscsr_rd_rs_reserv = {INSTRENUM_CSRRW} iff(csrenum_var==CSRENUM_FCSR);
    }
    
    dext__fcsr_fscsr_reserved: cross dext__fcsr_rs1,dext__fcsr_fscsr_reserv;
    dext__fcsr_frm_bit_toggle_bit0: coverpoint i_csr.fcsr_csr_inst.frm[0];
    dext__fcsr_frm_bit_toggle_bit1: coverpoint i_csr.fcsr_csr_inst.frm[1]; 
    dext__fcsr_frm_bit_toggle_bit2: coverpoint i_csr.fcsr_csr_inst.frm[2];

    dext__fcsr_fflags_bit_toggle_NX: coverpoint i_csr.fcsr_csr_inst.fflags[0];
    dext__fcsr_fflags_bit_toggle_UF: coverpoint i_csr.fcsr_csr_inst.fflags[1];
    dext__fcsr_fflags_bit_toggle_OF: coverpoint i_csr.fcsr_csr_inst.fflags[2];
    dext__fcsr_fflags_bit_toggle_DZ: coverpoint i_csr.fcsr_csr_inst.fflags[3];
    dext__fcsr_fflags_bit_toggle_NV: coverpoint i_csr.fcsr_csr_inst.fflags[4];

    dext__fcsr_frcsr_fscsr: coverpoint instrenum_var{
        bins fscsr_rs       = {INSTRENUM_CSRRW} iff((csrenum_var==CSRENUM_FCSR) && (rd==0));
        bins fscsr_rd_rs    = {INSTRENUM_CSRRW} iff(csrenum_var==CSRENUM_FCSR);
        bins frcsr_rd       = {INSTRENUM_CSRRS} iff((csrenum_var==CSRENUM_FCSR) && (rs1==0));
    }

    dext__fcsr_frm_bit_toggle_bit0_cross:   cross dext__fcsr_frcsr_fscsr,dext__fcsr_frm_bit_toggle_bit0;
    dext__fcsr_frm_bit_toggle_bit1_cross:   cross dext__fcsr_frcsr_fscsr,dext__fcsr_frm_bit_toggle_bit1;
    dext__fcsr_frm_bit_toggle_bit2_cross:   cross dext__fcsr_frcsr_fscsr,dext__fcsr_frm_bit_toggle_bit2;
    dext__fcsr_fflags_bit_toggle_N_cross:   cross dext__fcsr_frcsr_fscsr,dext__fcsr_fflags_bit_toggle_NX;
    dext__fcsr_fflags_bit_toggle_UF_cross:  cross dext__fcsr_frcsr_fscsr,dext__fcsr_fflags_bit_toggle_UF;
    dext__fcsr_fflags_bit_toggle_OF_cross:  cross dext__fcsr_frcsr_fscsr,dext__fcsr_fflags_bit_toggle_OF;
    dext__fcsr_fflags_bit_toggle_DZ_cross:  cross dext__fcsr_frcsr_fscsr,dext__fcsr_fflags_bit_toggle_DZ;
    dext__fcsr_fflags_bit_toggle_NV_cross:  cross dext__fcsr_frcsr_fscsr,dext__fcsr_fflags_bit_toggle_NV;

    dext__frm_frrm_fsrm: coverpoint instrenum_var{
        bins fsrm_rs    = {INSTRENUM_CSRRW} iff((csrenum_var==CSRENUM_FRM) && (rd==0));
        bins fsrm_rd_rs = {INSTRENUM_CSRRW} iff(csrenum_var==CSRENUM_FRM);
        bins frrm_rd    = {INSTRENUM_CSRRS} iff((csrenum_var==CSRENUM_FRM) && (rs1==0));
    }

    dext__frm_frrm_fsrm1: coverpoint instrenum_var{
        option.weight=0;
        bins fsrm_rd_rs = {INSTRENUM_CSRRW} iff(csrenum_var==CSRENUM_FRM);
        bins frrm_rd    = {INSTRENUM_CSRRS} iff((csrenum_var==CSRENUM_FRM) && (rs1==0));
    }

    dext__frm_frrm_fsrm_trans: coverpoint rd_val{
        bins trans = ('1 => [32'h00000000:32'h0000008]);
    }

    dext__frm_frrm_fsrm_cross: cross dext__frm_frrm_fsrm1,dext__frm_frrm_fsrm_trans;

    dext__fflags_frflags_fsflags: coverpoint instrenum_var{
        bins fsrm_rs    = {INSTRENUM_CSRRW} iff((csrenum_var==CSRENUM_FFLAGS) && (rd==0));
        bins fsrm_rd_rs = {INSTRENUM_CSRRW} iff(csrenum_var==CSRENUM_FFLAGS);
        bins frrm_rd    = {INSTRENUM_CSRRS} iff((csrenum_var==CSRENUM_FFLAGS) && (rs1==0));
    }

    dext__fflags_frflags_fsflags1: coverpoint instrenum_var{
        option.weight=0;
        bins fsrm_rd_rs = {INSTRENUM_CSRRW} iff(csrenum_var==CSRENUM_FFLAGS);
        bins frrm_rd    = {INSTRENUM_CSRRS} iff((csrenum_var==CSRENUM_FFLAGS) && (rs1==0));
    }

    dext__fflags_frflags_fsflags_trans: coverpoint rd_val{
        bins trans = ('1 => [32'h00000000:32'h00000020]);
    }

    dext__fflags_frflags_fsflags_cross: cross dext__fflags_frflags_fsflags1,dext__fflags_frflags_fsflags_trans;

    dext__non_ls_instrs: coverpoint dext_var {
        ignore_bins ignore_vals = {
            DEXT_FLD,
            DEXT_FSD 
        };
    }

    dext__rounding_modes_dynamic_illegal: coverpoint Inst[14:12] {
        bins vals[] = {5,6,7};
    }   
    
    dext__rounding_modes_static_legal_rm : coverpoint Inst[14:12] {
        bins vals[] = {0,1,2,3,4};
    }
     
    dext__rounding_modes_illegal : cross dext__non_ls_instrs, dext__rounding_modes_dynamic_illegal;
    dext__rounding_modes_valid   : cross dext__non_ls_instrs, dext__rounding_modes_static_legal_rm;
 
    dext__rounding_modes_xminusx: coverpoint instrenum_var{
        bins fsub_xminusx ={INSTRENUM_FSUB_D} iff((rs1_val==rs2_val));

    } 
    dext__rounding_modes_xminusx_cross: cross dext__rounding_modes_xminusx, dext__rounding_modes_static_legal_rm;

    dext__rounding_modes_rounding: coverpoint i_csr.fcsr_csr_inst.frm{
        bins dynamic_mode[] = {3'd1,3'd2,3'd3,3'd0,3'd4};
    }

    dext__rounding_modes_edge_case: coverpoint instrenum_var{
        bins L_XLENx1plus   =   {
            INSTRENUM_FMUL_D
        } iff(((rs1_val==DEXT_LN) && (rs2_val==DEXT_ONE_PLUS)) || ((rs2_val==DEXT_LN) && (rs1_val==DEXT_ONE_PLUS)));

        bins negL_XLENxneg1plus =   {
            INSTRENUM_FMUL_D
        } iff(((rs1_val==DEXT_LN_NEG) && (rs2_val==DEXT_ONE_PLUS_NEG)) || ((rs2_val==DEXT_LN_NEG) && (rs1_val==DEXT_ONE_PLUS_NEG)));

        bins L_XLENxS_XLEN  =   {
            INSTRENUM_FADD_D
        } iff(((rs1_val==DEXT_LN) && (rs2_val==DEXT_SN)) || ((rs2_val==DEXT_LN) && (rs1_val==DEXT_SN)));
    
        bins negL_XLENxnegS_XLEN    =   {
            INSTRENUM_FADD_D
        } iff(((rs1_val==DEXT_LN_NEG) && (rs2_val==DEXT_SN_NEG)) || ((rs2_val==DEXT_LN_NEG) && (rs1_val==DEXT_SN_NEG))); 

        bins L_XLENx1neg = {
            INSTRENUM_FDIV_D
        } iff(((rs1_val==DEXT_LN) && (rs2_val==DEXT_ONE_MINUS)) || ((rs2_val==DEXT_LN) && (rs1_val==DEXT_ONE_MINUS)));

        bins negL_XLENxneg1neg  =   {
            INSTRENUM_FDIV_D
        } iff(((rs1_val==DEXT_LN_NEG) && (rs2_val==DEXT_ONE_MINUS_NEG)) || ((rs2_val==DEXT_LN_NEG) && (rs1_val==DEXT_ONE_MINUS_NEG)));
    }

    dext__rounding_modes_edge_case_cross: cross dext__rounding_modes_static_legal_rm, dext__rounding_modes_edge_case; 
  
    dext__NVflag_SNAN_feq: coverpoint instrenum_var{

        bins feq_flt_fle_rs1_posSNAN[] = {
            INSTRENUM_FLE_D, 
            INSTRENUM_FEQ_D, 
            INSTRENUM_FLT_D
        } iff((rs1_val[63:0]==DEXT_SNAN) || (rs2_val[63:0]==DEXT_SNAN));

        bins feq_flt_fle_rs1_negSNAN[]  =   {
            INSTRENUM_FLE_D, 
            INSTRENUM_FEQ_D, 
            INSTRENUM_FLT_D
        } iff((rs1_val[63:0]==DEXT_SNAN_NEG) || (rs2_val[63:0]==DEXT_SNAN_NEG));

        bins feq_flt_fle_rs1_rs2_SNAN[] =   {
            INSTRENUM_FLE_D, 
            INSTRENUM_FEQ_D, 
            INSTRENUM_FLT_D
        } iff(  (rs1_val[63:0]==DEXT_SNAN && rs2_val[63:0]==DEXT_SNAN)     || 
                (rs1_val[63:0]==DEXT_SNAN && rs2_val[63:0]==DEXT_SNAN_NEG) || 
                (rs1_val[63:0]==DEXT_SNAN_NEG && rs2_val[63:0]==DEXT_SNAN) || 
                (rs1_val[63:0]==DEXT_SNAN_NEG && rs2_val[63:0]==DEXT_SNAN_NEG)
            );
    }

    dext__NVflag_QNAN_flt: coverpoint instrenum_var{

        bins flt_fle_rs1_posQNAN[]  =   { 
            INSTRENUM_FEQ_D, 
            INSTRENUM_FLT_D
        } iff((rs1_val[63:0]==DEXT_QNAN) || (rs2_val[63:0]==DEXT_QNAN));

        bins flt_fle_rs1_negQNAN[]  =   {
            INSTRENUM_FEQ_D, 
            INSTRENUM_FLT_D
        } iff((rs1_val[63:0]==DEXT_QNAN_NEG) || (rs2_val[63:0]==DEXT_QNAN_NEG));
        
        bins flt_fle_rs1_rs2_QNAN[] =   {
            INSTRENUM_FEQ_D, 
            INSTRENUM_FLT_D
        } iff(  (rs1_val[63:0]==DEXT_QNAN && rs2_val[63:0]==DEXT_QNAN)      || 
                (rs1_val[63:0]==DEXT_QNAN && rs2_val[63:0]==DEXT_QNAN_NEG)  || 
                (rs1_val[63:0]==DEXT_QNAN_NEG && rs2_val[63:0]==DEXT_QNAN)  || 
                (rs1_val[63:0]==DEXT_QNAN_NEG && rs2_val[63:0]==DEXT_QNAN_NEG)
            );
    }

    dext__NVFLAG_fmadd_zero_infinity: coverpoint rs2_val{   
        bins zero_infinity[]    =   {
            DEXT_INFINITY,
            DEXT_INFINITY_NEG
        } iff(rs1_val == DEXT_ZERO);
    }

    dext__NVFLAG_fmadd_infinity_zero: coverpoint rs1_val{  
        bins infinity_zero[]    =   {
            DEXT_INFINITY,
            DEXT_INFINITY_NEG
        } iff(rs2_val == DEXT_ZERO);
    }

    dext__NVFLAG_fmadd_fmsub_fnmadd_fnmsub: coverpoint instrenum_var{
        bins ops[]  =   {
            INSTRENUM_FNMADD_D,
            INSTRENUM_FNMSUB_D,
            INSTRENUM_FMADD_D,
            INSTRENUM_FMSUB_D
        };
    }

    dext__NVFLAG_fmadd_infinity_zero_cross1: cross dext__NVFLAG_fmadd_fmsub_fnmadd_fnmsub,dext__NVFLAG_fmadd_zero_infinity;
    dext__NVFLAG_fmadd_infinity_zero_cross2: cross dext__NVFLAG_fmadd_fmsub_fnmadd_fnmsub,dext__NVFLAG_fmadd_infinity_zero;
    
    dext__NVflag_fused_mul: coverpoint rs3_val{
        bins qnan_rs3[] =   {
            DEXT_QNAN,
            DEXT_QNAN_NEG
        }; 
    }

    dext__NVflag_fused_mul_cross: cross dext__NVflag_fused_mul, dext__NVFLAG_fmadd_fmsub_fnmadd_fnmsub;

    dext__NAN_cp_fsqrt_neg: coverpoint instrenum_var{
        bins fsqrt_neg  =   {
            INSTRENUM_FSQRT_D
        }  iff(rs1_val[63]=='b1);
    }

    dext__NAN_cp_fsqrt_neg_zero: coverpoint instrenum_var{
        bins fsqrt_neg  =   {
            INSTRENUM_FSQRT_D
        }  iff(rs1_val[63:0]==DEXT_ZERO_NEG);
    }

    dext__NAN_cp_mul: coverpoint instrenum_var{

        bins fmul_pos0xposinfi  =   {
            INSTRENUM_FMUL_D
        } iff(  (rs1_val[63:0]=='b0 && rs2_val[63:0]==DEXT_INFINITY) || 
                (rs2_val[63:0]=='b0 && rs1_val[63:0]==DEXT_INFINITY)
            );  

        bins fmul_pos0xneginfi  =   {
            INSTRENUM_FMUL_D
        } iff(  (rs1_val[63:0]=='b0 && rs2_val[63:0]==DEXT_INFINITY_NEG) || 
                (rs2_val[63:0]=='b0 && rs1_val[63:0]==DEXT_INFINITY_NEG)
            );

        bins fmul_neg0xneginfi  =   {
            INSTRENUM_FMUL_D
        } iff(  (rs1_val[63:0]==DEXT_ZERO_NEG && rs2_val[63:0]==DEXT_INFINITY_NEG) || 
                (rs2_val[63:0]==DEXT_ZERO_NEG && rs1_val[63:0]==DEXT_INFINITY_NEG)
            );  

        bins fmul_neg0xposinfi  =   {
            INSTRENUM_FMUL_D
        } iff(  (rs1_val[63:0]==DEXT_ZERO_NEG && rs2_val[63:0]==DEXT_INFINITY) || 
                (rs2_val[63:0]==DEXT_ZERO_NEG && rs1_val[63:0]==DEXT_INFINITY)
            );
    }

    dext__NAN_cp_fdiv: coverpoint instrenum_var{

        bins fdiv_pos0bypos0    =   {
            INSTRENUM_FDIV_D
        } iff((rs1_val[63:0]=='b0) && (rs2_val[63:0]=='b0));

        bins fdiv_neg0byneg0    =   {
            INSTRENUM_FDIV_D
        } iff((rs1_val[63:0]==DEXT_ZERO_NEG) && (rs2_val[63:0]==DEXT_ZERO_NEG));
    }

    dext__NAN_cp_div_infbyinfi:coverpoint instrenum_var{
        
        bins fdiv_posinfibyposinfi  =   {
            INSTRENUM_FDIV_D
        } iff((rs1_val[63:0]==DEXT_INFINITY) && (rs2_val[63:0]==DEXT_INFINITY));

        bins fdiv_neginfibyneginfi  =   {
            INSTRENUM_FDIV_D
        } iff((rs1_val[63:0]==DEXT_INFINITY_NEG) && (rs2_val[63:0]==DEXT_INFINITY_NEG));
    }

    dext__NAN_cp_fsub_samesign: coverpoint instrenum_var{

        bins fsub_infmininf_ss  =   {
            INSTRENUM_FSUB_D
        } iff((rs1_val[63:0]==DEXT_INFINITY) && (rs2_val[63:0]==DEXT_INFINITY));

        bins fsub_infmininf_ss_0    =   {
            INSTRENUM_FSUB_D
        } iff((rs1_val[63:0]==DEXT_INFINITY_NEG) && (rs2_val[63:0]==DEXT_INFINITY_NEG));
    }

    dext__NAN_cp_fsub_notsamesign: coverpoint instrenum_var{
        
        bins fsub_infsubinf_10  =   {
            INSTRENUM_FSUB_D
        } iff((rs1_val[63:0]==DEXT_INFINITY) && (rs2_val[63:0]==DEXT_INFINITY_NEG));

        bins fsub_infsubinf_01  =   {
            INSTRENUM_FSUB_D
        } iff((rs1_val[63:0]==DEXT_INFINITY_NEG) && (rs2_val[63:0]==DEXT_INFINITY));
    }

    dext__DZflag_fdiv: coverpoint instrenum_var{

        bins fdiv_DZFLagset_pos0    =   {
            INSTRENUM_FDIV_D
        } iff(rs2_val[63:0]=='b0);

        bins fdiv_DZFLagset_neg0    =   {
            INSTRENUM_FDIV_D
        } iff(rs2_val[63:0]==DEXT_ZERO_NEG);
    }

    dext__OF_NXFLAG_fadd : coverpoint instrenum_var{

        bins fadd_LNpos_posno   =   {
            INSTRENUM_FADD_D
        } iff(  (rs1_val[63:0]==DEXT_LN && rs2_val[63]=='b0) || 
                (rs2_val[63:0]==DEXT_LN && rs1_val[63]=='b0)
            );

        bins fadd_LNneg_posno   =   {
            INSTRENUM_FADD_D
        } iff(  (rs1_val[63:0]==DEXT_LN_NEG && rs2_val[63]=='b0) || 
                (rs2_val[63:0]==DEXT_LN_NEG && rs1_val[63]=='b0)
            );
    }

    dext__OF_NXFLAG_fadd_roundmodes_cross: cross dext__rounding_modes_static_legal_rm, dext__OF_NXFLAG_fadd;
  
    dext__OF_NXflag_fmul : coverpoint instrenum_var{

        bins fmul_LNpos_1pluspos    =   {
            INSTRENUM_FMUL_D
        } iff(  (rs1_val[63:0]==DEXT_LN && rs2_val[63:0]==DEXT_ONE_PLUS) || 
                (rs2_val[63:0]==DEXT_LN && rs1_val[63:0]==DEXT_ONE_PLUS)
            );

        bins fmul_LNneg_1pluspos    =   {
            INSTRENUM_FMUL_D
        } iff(  (rs1_val[63:0]==DEXT_LN_NEG && rs2_val[63:0]==DEXT_ONE_PLUS) || 
                (rs2_val[63:0]==DEXT_LN_NEG && rs1_val[63:0]==DEXT_ONE_PLUS)
            );

        bins fmul_LNpos_1plusneg    =   {
            INSTRENUM_FMUL_D
        } iff(  (rs1_val[63:0]==DEXT_LN && rs2_val[63:0]==DEXT_ONE_PLUS_NEG) || 
                (rs2_val[63:0]==DEXT_LN && rs1_val[63:0]==DEXT_ONE_PLUS_NEG)
            );

        bins fmul_LNneg_1plusneg    =   {
            INSTRENUM_FMUL_D
        } iff(  (rs1_val[63:0]==DEXT_LN_NEG && rs2_val[63:0]==DEXT_ONE_PLUS_NEG) || 
                (rs2_val[63:0]==DEXT_LN_NEG && rs1_val[63:0]==DEXT_ONE_PLUS_NEG)
            );
    }

    dext__OF_NXflag_fmul_roundmodes_cross: cross dext__rounding_modes_static_legal_rm,dext__OF_NXflag_fmul;

    dext__UF_flag_fdiv : coverpoint instrenum_var{

        bins fdiv_SNby2 =   {
            INSTRENUM_FDIV_D
        } iff((rs1_val[63:0]==DEXT_SN) && (rs2_val[63:0]==DEXT_TWO));

        bins fdiv_SNby2_n   =   {
            INSTRENUM_FDIV_D
        } iff((rs1_val[63:0]==DEXT_SN_NEG) && (rs2_val[63:0]==DEXT_TWO_NEG));
    }
  
    dext__UF_fsub_SN_SN_plus: coverpoint instrenum_var{

        bins fsub_SN_SNplus =   {
            INSTRENUM_FSUB_D
        } iff((rs1_val[63:0]==DEXT_SN) && (rs2_val[63:0]==63'h0010000000000001));
    }

    dext__NXflag_fdiv: coverpoint instrenum_var{

        bins fdiv_one_by_three =   {
            INSTRENUM_FDIV_D
        } iff((rs1_val[63:0]==DEXT_ONE) && (rs2_val[63:0]==DEXT_THREE));
    }

    dext__NX_UFflag_fdiv_SSN_by_three: coverpoint instrenum_var{

        bins fdiv_SSN_by_three =   {
            INSTRENUM_FDIV_D
        } iff(  (rs1_val[63:0]==DEXT_SSN && rs2_val[63:0]==DEXT_THREE) ||
                (rs1_val[63:0]==DEXT_SSN_NEG && rs2_val[63:0]==DEXT_THREE)
            );
    }

    dext__NX_UFflag_fdiv_SSN_by_two: coverpoint instrenum_var{

        bins fdiv_SSN_by_two    =   {
            INSTRENUM_FDIV_D
        } iff(  (rs1_val[63:0]==DEXT_SSN && rs2_val[63:0]==DEXT_TWO) ||
                (rs1_val[63:0]==DEXT_SSN_NEG && rs2_val[63:0]==DEXT_TWO)
            );
    }

    dext__NX_UFflag_fdiv_SSN_by_two_cross_frm: cross dext__NX_UFflag_fdiv_SSN_by_two, dext__rounding_modes_static_legal_rm;

    dext__NAN_memory_operation_FLD: coverpoint instrenum_var{

        bins FLD_SNAN   =   {
            INSTRENUM_FLD
        } iff(rd_val[63:0]==DEXT_SNAN || rd_val[63:0]==DEXT_SNAN_NEG);
    }

    dext__NAN_memory_operation_FSD: coverpoint instrenum_var{

        bins FLD_SNAN   =   {
            INSTRENUM_FSD
        } iff(rd_val[63:0]==DEXT_SNAN || rd_val[63:0]==DEXT_SNAN_NEG);
    }

    dext__NAN_memory_operation_FLD_NCNAN: coverpoint instrenum_var{

        bins FLD_SNAN   =   {
            INSTRENUM_FLD
        } iff(  (rd_val[63:48]==16'h7ff8 && rd_val[47:0] != 0) ||
                (rd_val[63:48]==16'hfff8 && rd_val[47:0] != 0)
            );
    }

    dext__NAN_memory_operation_FSD_NCNAN: coverpoint instrenum_var{

        bins FLD_SNAN   =   {
            INSTRENUM_FSD
        } iff(  (rd_val[63:48]==16'h7ff8 && rd_val[47:0] != 0) ||
                (rd_val[63:48]==16'hfff8 && rd_val[47:0] != 0)
            );
    }

    dext_NAN_arithmetic_rs1: coverpoint rs1_val{
        bins pos_SNAN_rs1= {DEXT_SNAN};
        bins neg_SNAN_rs1={DEXT_SNAN_NEG};
        bins pos_QNAN_rs1={DEXT_QNAN};
        bins neg_QNAN_rs1={DEXT_QNAN_NEG};
        bins pos_NCNAN_rs1={[64'h7ff8000000000001:64'h7ff8ffffffffffff]};
        bins neg_NCNAN_rs1={[64'hfff8000000000001:64'hfff8ffffffffffff]}; 
    
    }
    dext_NAN_arithmetic_rs2: coverpoint rs2_val{
        bins pos_SNAN_rs2={DEXT_SNAN};
        bins neg_SNAN_rs2={DEXT_SNAN_NEG};
        bins pos_QNAN_rs2={DEXT_QNAN};
        bins neg_QNAN_rs2={DEXT_QNAN_NEG};
        bins pos_NCNAN_rs2={[64'h7ff8000000000001:64'h7ff8ffffffffffff]};
        bins neg_NCNAN_rs2={[64'hfff8000000000001:64'hfff8ffffffffffff]}; 
    }

    dext_NAN_arithmetic_feq_flt_fle: coverpoint instrenum_var{

        bins feq_flt_fle[]  =   {
            INSTRENUM_FLE_D, 
            INSTRENUM_FLT_D, 
            INSTRENUM_FEQ_D
        };
    }
    dext_NAN_arithmetic_feq_flt_fle_cross1: cross dext_NAN_arithmetic_feq_flt_fle,dext_NAN_arithmetic_rs1; 
    dext_NAN_arithmetic_feq_flt_fle_cross2: cross dext_NAN_arithmetic_feq_flt_fle,dext_NAN_arithmetic_rs2;  

    dext__NAN_arithmetic_fsub_fdiv: coverpoint instrenum_var{
        bins fdiv_fsub[]    =   {
            INSTRENUM_FSUB_D,
            INSTRENUM_FDIV_D
        };
    }
    dext__NAN_arithmetic_fsub_fdiv_cross1: cross dext__NAN_arithmetic_fsub_fdiv, dext_NAN_arithmetic_rs1;
    dext__NAN_arithmetic_fsub_fdiv_cross2: cross dext__NAN_arithmetic_fsub_fdiv, dext_NAN_arithmetic_rs2;

    dext__Generic_special_NAN_ZERO_rs1: coverpoint instrenum_var{
        option.weight=0;
        bins vals[]    =   {
            INSTRENUM_FADD_D,
            INSTRENUM_FMUL_D,
            INSTRENUM_FSUB_D,
            INSTRENUM_FDIV_D,
            INSTRENUM_FSQRT_D,
            INSTRENUM_FMIN_D,
            INSTRENUM_FMAX_D
        } iff(rs2_val == 0);
    }

    dext__Generic_special_NAN_ZERO_rs2: coverpoint instrenum_var{
        option.weight=0;
        bins vals[] =   {
            INSTRENUM_FADD_D,
            INSTRENUM_FMUL_D,
            INSTRENUM_FSUB_D,
            INSTRENUM_FDIV_D,
            INSTRENUM_FSQRT_D,
            INSTRENUM_FMIN_D,
            INSTRENUM_FMAX_D
        } iff(rs1_val == 0);
    }
    dext__Generic_special_cross_1: cross dext__Generic_special_NAN_ZERO_rs1, dext_NAN_arithmetic_rs1 ;
    dext__Generic_special_cross_2: cross dext__Generic_special_NAN_ZERO_rs2, dext_NAN_arithmetic_rs2;

    dext__Generic_special_Fmin_Fmax: coverpoint instrenum_var{
        option.weight=0;
        bins fmin_fmax_NAN[]    =   {
            INSTRENUM_FMIN_D,
            INSTRENUM_FMAX_D
        }; 
    }
    dext__Generic_special_Fmin_Fmax_cross_1: cross dext__Generic_special_Fmin_Fmax, dext_NAN_arithmetic_rs1;
    dext__Generic_special_Fmin_Fmax_cross_2: cross dext__Generic_special_Fmin_Fmax, dext_NAN_arithmetic_rs2;

    dext__Generic_special_case3_rs1_diffvalues: coverpoint rs1_val{
        option.weight=0;
        bins SNAN_rs1= {DEXT_SNAN};
        bins QNAN__rs1={DEXT_QNAN};
        bins NCNAN_rs1={[64'h7ff8000000000001:64'h7ff8ffffffffffff]};
        bins LN_rs1={DEXT_LN};
        bins SSN_rs1={DEXT_SSN};
        bins zero_rs1={DEXT_ZERO};
        bins infinity_rs1={DEXT_INFINITY};
    }
    dext__Generic_special_case3_rs2_diffvalues: coverpoint rs2_val{
        bins SNAN_rs2= {DEXT_SNAN};
        bins QNAN__rs2={DEXT_QNAN};
        bins NCNAN_rs2={[64'h7ff8000000000001:64'h7ff8ffffffffffff]};
        bins LN_rs2={DEXT_LN};
        bins SSN_rs2={DEXT_SSN};
        bins zero_rs2={DEXT_ZERO};
        bins infinity_rs2={DEXT_INFINITY};
    }
    dext__Generic_special_case3_ops: coverpoint instrenum_var{
        bins vals = {
            INSTRENUM_FADD_D,
            INSTRENUM_FMUL_D,
            INSTRENUM_FSUB_D,
            INSTRENUM_FDIV_D,
            INSTRENUM_FSQRT_D,
            INSTRENUM_FMIN_D,
            INSTRENUM_FMAX_D,
            INSTRENUM_FMADD_D, 
            INSTRENUM_FMSUB_D, 
            INSTRENUM_FNMADD_D, 
            INSTRENUM_FNMSUB_D};
    }

    dext__Generic_special_case3_cross:cross dext__Generic_special_case3_ops, dext__Generic_special_case3_rs2_diffvalues,dext__Generic_special_case3_rs1_diffvalues;

    dext__Computational_fmin_fmax_zero: coverpoint instrenum_var{

        bins fmin_fmax_case1_1[]    =   {
                INSTRENUM_FMIN_D,
                INSTRENUM_FMAX_D
            } iff((rs1_val[63:0]==63'h0000000000000000) && (rs2_val[63:0]==63'h0000000000000000)); 
        bins fmin_fmax_case1_2[]    =   {
                INSTRENUM_FMIN_D,
                INSTRENUM_FMAX_D
            } iff((rs1_val[63:0]==63'h0000000000000000) && (rs2_val[63:0]==DEXT_ZERO_NEG));
        bins fmin_fmax_case1_3[]    =   {
                INSTRENUM_FMIN_D,
                INSTRENUM_FMAX_D
            } iff((rs1_val[63:0]==DEXT_ZERO_NEG) && (rs2_val[63:0]==DEXT_ZERO_NEG));
        bins fmin_fmax_case1_4[]    =   {
                INSTRENUM_FMIN_D,
                INSTRENUM_FMAX_D
            } iff((rs1_val[63:0]==DEXT_ZERO_NEG) && (rs2_val[63:0]==63'h0000000000000000));
    }

    dext__Computational_fmin_fmax_NCNAN: coverpoint instrenum_var{
        bins fmin_fmax_case2[]={
            INSTRENUM_FMIN_D,
            INSTRENUM_FMAX_D
        } iff(  ((rs1_val[63:48]==16'h7ff8 && rs1_val[47:0] != 0) && (rs2_val[63:48]==16'h7ff8 && rs2_val[47:0] != 0)) || 
                ((rs1_val[63:48]==16'hfff8 && rs1_val[47:0] != 0) && (rs2_val[63:48]==16'hfff8 && rs2_val[47:0] != 0))
            );
    }

    dext__Computational_fmadd_fnmadd: coverpoint instrenum_var{
        bins fmadd_fmsub_fnmsub_fnmadd[]    =   {
            INSTRENUM_FMADD_D, 
            INSTRENUM_FMSUB_D, 
            INSTRENUM_FNMADD_D, 
            INSTRENUM_FNMSUB_D
        } iff(rs1_val == rs2_val);
    }

    dext__Conversion_move_fcvt: coverpoint instrenum_var{
        bins fcvt_diff_types_D[]    =   {
            INSTRENUM_FCVT_L_D, 
            INSTRENUM_FCVT_LU_D, 
            INSTRENUM_FCVT_D_L,
            INSTRENUM_FCVT_D_LU,
            INSTRENUM_FCVT_D_W,
            INSTRENUM_FCVT_D_WU,
            INSTRENUM_FCVT_W_D,
            INSTRENUM_FCVT_WU_D
        };
    }

    dext__Conversion_move_x0: coverpoint instrenum_var{
        bins fcvt_D_X[] =   {
            INSTRENUM_FCVT_D_W,
            INSTRENUM_FCVT_D_L,
            INSTRENUM_FCVT_D_LU,
            INSTRENUM_FCVT_D_WU
        } iff(rs1==0);
    }

    dext__cross_conversions: coverpoint instrenum_var{
        bins cross_d[]  =   {
            INSTRENUM_FCVT_D_S,
            INSTRENUM_FCVT_D_H
        };
    }

    dext__cross_extenstion_coversion: coverpoint instrenum_var{
        bins inject_instr_D[]   =       {
            INSTRENUM_FSGNJ_D,
            INSTRENUM_FSGNJN_D,
            INSTRENUM_FSGNJX_D
        };
    }

    dext__cross_extenstion_coversion_cross_rs1: cross dext__cross_extenstion_coversion,dext_NAN_arithmetic_rs1;
    dext__cross_extenstion_coversion_cross_rs2: cross dext__cross_extenstion_coversion,dext_NAN_arithmetic_rs2;

    dext__Softfloat_fdiv: coverpoint instrenum_var{
        bins fdiv_s[]   =   {
            INSTRENUM_FDIV_D,
            INSTRENUM_FSQRT_D
        };
    }
    dext__Softfloat_fdiv_cross_roundingmodes: cross dext__Softfloat_fdiv,dext__rounding_modes_static_legal_rm,dext__Generic_special_case3_rs1_diffvalues;

    dext__Softfloat_convert_cross_roundmodes: cross dext__Conversion_move_fcvt,dext__rounding_modes_static_legal_rm;
endgroup

`endif