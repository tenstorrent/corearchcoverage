//  SPDX-FileCopyrightText: © 2026 Tenstorrent AI ULC
//  SPDX-License-Identifier: Apache-2.0
`ifndef COVERAGE_UNSUPPORTED

import cp_pkg::*;

covergroup zfhext__cg with function sample(csr_cov_sample i_csr);
    option.per_instance = 1;
    option.name = "cg_zfhext";

    zfhext__fcsr_rd_x0: coverpoint instrenum_var{
        bins frcsr_rd       = {INSTRENUM_CSRRS} iff((csrenum_var==CSRENUM_FCSR) && (rd==0) && (rs1==0));
        bins fscsr_rd_rs    = {INSTRENUM_CSRRW} iff((csrenum_var==CSRENUM_FCSR) && (rd==0));
        bins frrm_rd        = {INSTRENUM_CSRRS} iff((csrenum_var==CSRENUM_FRM)  && (rd==0) && (rs1==0));
        bins fsrm_rd_rs     = {INSTRENUM_CSRRW} iff((csrenum_var==CSRENUM_FRM)  && (rd==0));
        bins frflags_rd     = {INSTRENUM_CSRRS} iff((csrenum_var==CSRENUM_FFLAGS) && (rd==0) && (rs1==0));
        bins fsflags_rd_rs  = {INSTRENUM_CSRRW} iff((csrenum_var==CSRENUM_FFLAGS) && (rd==0));
    }

    zfhext__fcsr_rs1: coverpoint rs1_val[31:8]{
        bins rs1_all[]      = {24'h000001,24'hffffff};
        bins rs1_remaining  = {[24'h000002:24'hfffffe]};
    }

    zfhext__fcsr_fscsr_reserv: coverpoint instrenum_var{
        bins fscsr_rs_reserv    = {INSTRENUM_CSRRW} iff((csrenum_var==CSRENUM_FCSR) && (rd==0));
        bins fscsr_rd_rs_reserv = {INSTRENUM_CSRRW} iff(csrenum_var==CSRENUM_FCSR);
    }

    zfhext__fcsr_fscsr_reserved: cross zfhext__fcsr_rs1,zfhext__fcsr_fscsr_reserv;

    zfhext__fcsr_frm_bit_toggle_bit0: coverpoint i_csr.fcsr_csr_inst.frm[0];
    zfhext__fcsr_frm_bit_toggle_bit1: coverpoint i_csr.fcsr_csr_inst.frm[1];
    zfhext__fcsr_frm_bit_toggle_bit2: coverpoint i_csr.fcsr_csr_inst.frm[2];

    zfhext__fcsr_fflags_bit_toggle_NX: coverpoint i_csr.fcsr_csr_inst.fflags[0];
    zfhext__fcsr_fflags_bit_toggle_UF: coverpoint i_csr.fcsr_csr_inst.fflags[1];
    zfhext__fcsr_fflags_bit_toggle_OF: coverpoint i_csr.fcsr_csr_inst.fflags[2];
    zfhext__fcsr_fflags_bit_toggle_DZ: coverpoint i_csr.fcsr_csr_inst.fflags[3];
    zfhext__fcsr_fflags_bit_toggle_NV: coverpoint i_csr.fcsr_csr_inst.fflags[4];

    zfhext__fcsr_frcsr_fscsr: coverpoint instrenum_var{
        bins fscsr_rs       = {INSTRENUM_CSRRW} iff((csrenum_var==CSRENUM_FCSR) && (rd==0));
        bins fscsr_rd_rs    = {INSTRENUM_CSRRW} iff(csrenum_var==CSRENUM_FCSR);
        bins frcsr_rd       = {INSTRENUM_CSRRS} iff((csrenum_var==CSRENUM_FCSR) && (rs1==0));
    }

    zfhext__fcsr_frm_bit_toggle_bit0_cross:   cross zfhext__fcsr_frcsr_fscsr,zfhext__fcsr_frm_bit_toggle_bit0;
    zfhext__fcsr_frm_bit_toggle_bit1_cross:   cross zfhext__fcsr_frcsr_fscsr,zfhext__fcsr_frm_bit_toggle_bit1;
    zfhext__fcsr_frm_bit_toggle_bit2_cross:   cross zfhext__fcsr_frcsr_fscsr,zfhext__fcsr_frm_bit_toggle_bit2;
    zfhext__fcsr_fflags_bit_toggle_N_cross:   cross zfhext__fcsr_frcsr_fscsr,zfhext__fcsr_fflags_bit_toggle_NX;
    zfhext__fcsr_fflags_bit_toggle_UF_cross:  cross zfhext__fcsr_frcsr_fscsr,zfhext__fcsr_fflags_bit_toggle_UF;
    zfhext__fcsr_fflags_bit_toggle_OF_cross:  cross zfhext__fcsr_frcsr_fscsr,zfhext__fcsr_fflags_bit_toggle_OF;
    zfhext__fcsr_fflags_bit_toggle_DZ_cross:  cross zfhext__fcsr_frcsr_fscsr,zfhext__fcsr_fflags_bit_toggle_DZ;
    zfhext__fcsr_fflags_bit_toggle_NV_cross:  cross zfhext__fcsr_frcsr_fscsr,zfhext__fcsr_fflags_bit_toggle_NV;

    zfhext__frm_frrm_fsrm: coverpoint instrenum_var{
        bins fsrm_rs    = {INSTRENUM_CSRRW} iff((csrenum_var==CSRENUM_FRM) && (rd==0));
        bins fsrm_rd_rs = {INSTRENUM_CSRRW} iff(csrenum_var==CSRENUM_FRM);
        bins frrm_rd    = {INSTRENUM_CSRRS} iff((csrenum_var==CSRENUM_FRM) && (rs1==0));
    }

    zfhext__frm_frrm_fsrm1: coverpoint instrenum_var{
        option.weight=0;
        bins fsrm_rd_rs = {INSTRENUM_CSRRW} iff(csrenum_var==CSRENUM_FRM);
        bins frrm_rd    = {INSTRENUM_CSRRS} iff((csrenum_var==CSRENUM_FRM) && (rs1==0));
    }

    zfhext__frm_frrm_fsrm_trans: coverpoint rd_val{
        bins trans = ('1 => [32'h00000000:32'h00000008]);
    }

    zfhext__frm_frrm_fsrm_cross: cross zfhext__frm_frrm_fsrm1,zfhext__frm_frrm_fsrm_trans;

    zfhext__fflags_frflags_fsflags: coverpoint instrenum_var{
        bins fsrm_rs    = {INSTRENUM_CSRRW} iff((csrenum_var==CSRENUM_FFLAGS) && (rd==0));
        bins fsrm_rd_rs = {INSTRENUM_CSRRW} iff(csrenum_var==CSRENUM_FFLAGS);
        bins frrm_rd    = {INSTRENUM_CSRRS} iff((csrenum_var==CSRENUM_FFLAGS) && (rs1==0));
    }

    zfhext__fflags_frflags_fsflags1: coverpoint instrenum_var{
        option.weight=0;
        bins fsrm_rd_rs = {INSTRENUM_CSRRW} iff(csrenum_var==CSRENUM_FFLAGS);
        bins frrm_rd    = {INSTRENUM_CSRRS} iff((csrenum_var==CSRENUM_FFLAGS) && (rs1==0));
    }

    zfhext__fflags_frflags_fsflags_trans: coverpoint rd_val{
        bins trans = ('1 => [32'h00000000:32'h00000020]);
    }

    zfhext__fflags_frflags_fsflags_cross: cross zfhext__fflags_frflags_fsflags1,zfhext__fflags_frflags_fsflags_trans;

    zfhext__non_ls_instrs: coverpoint  zfhext_var {
        ignore_bins ignore_vals = {
            ZFHEXT_FLH,
            ZFHEXT_FSH 
        };
    }

    zfhext__rounding_modes_dynamic_illegal: coverpoint Inst[14:12] {
        bins vals[] = {5,6,7};
    }   

    zfhext__rounding_modes_static_legal_rm : coverpoint Inst[14:12] {
        bins vals[] = {0,1,2,3,4};
    }
     
    zhfext__rounding_modes_illegal : cross zfhext__non_ls_instrs, zfhext__rounding_modes_dynamic_illegal;
    zfhext__rounding_modes_valid   : cross zfhext__non_ls_instrs, zfhext__rounding_modes_static_legal_rm;

    zfhext__rounding_modes_xminusx: coverpoint instrenum_var{
        bins fsub_xminusx ={INSTRENUM_FSUB_H} iff((rs1_val[15:0]==rs2_val[15:0]));
    }
    zfhext__rounding_modes_xminusx_cross: cross zfhext__rounding_modes_xminusx, zfhext__rounding_modes_static_legal_rm;

    zfhext__rounding_modes_rounding: coverpoint i_csr.fcsr_csr_inst.frm{
        bins dynamic_mode[] = {3'd1,3'd2,3'd3,3'd0,3'd4};
    }

    zfhext__rounding_modes_edge_case: coverpoint instrenum_var{
        bins L_XLENx1plus   =   {
            INSTRENUM_FMUL_H
        } iff(((rs1_val[15:0]==ZFHEXT_LN) && (rs2_val[15:0]==ZFHEXT_ONE_PLUS)) || ((rs2_val[15:0]==ZFHEXT_LN) && (rs1_val[15:0]==ZFHEXT_ONE_PLUS)));

        bins negL_XLENxneg1plus =   {
            INSTRENUM_FMUL_H
        } iff(((rs1_val[15:0]==ZFHEXT_LN_NEG) && (rs2_val[15:0]==ZFHEXT_ONE_PLUS_NEG)) || ((rs2_val[15:0]==ZFHEXT_LN_NEG) && (rs1_val[15:0]==ZFHEXT_ONE_PLUS_NEG)));

        bins L_XLENxS_XLEN  =   {
            INSTRENUM_FADD_H
        } iff(((rs1_val[15:0]==ZFHEXT_LN) && (rs2_val[15:0]==ZFHEXT_SN)) || ((rs2_val[15:0]==ZFHEXT_LN) && (rs1_val[15:0]==ZFHEXT_SN)));

        bins negL_XLENxnegS_XLEN    =   {
            INSTRENUM_FADD_H
        } iff(((rs1_val[15:0]==ZFHEXT_LN_NEG) && (rs2_val[15:0]==ZFHEXT_SN_NEG)) || ((rs2_val[15:0]==ZFHEXT_LN_NEG) && (rs1_val[15:0]==ZFHEXT_SN_NEG)));

        bins L_XLENx1neg = {
            INSTRENUM_FDIV_H
        } iff(((rs1_val[15:0]==ZFHEXT_LN) && (rs2_val[15:0]==ZFHEXT_ONE_MINUS)) || ((rs2_val[15:0]==ZFHEXT_LN) && (rs1_val[15:0]==ZFHEXT_ONE_MINUS)));

        bins negL_XLENxneg1neg  =   {
            INSTRENUM_FDIV_H
        } iff(((rs1_val[15:0]==ZFHEXT_LN_NEG) && (rs2_val[15:0]==ZFHEXT_ONE_MINUS_NEG)) || ((rs2_val[15:0]==ZFHEXT_LN_NEG) && (rs1_val[15:0]==ZFHEXT_ONE_MINUS_NEG)));
    }

    zfhext__rounding_modes_edge_case_cross: cross zfhext__rounding_modes_static_legal_rm, zfhext__rounding_modes_edge_case;

    zfhext__NVflag_SNAN_feq: coverpoint instrenum_var{

        bins feq_flt_fle_rs1_posSNAN[] = {
            INSTRENUM_FLE_H,
            INSTRENUM_FEQ_H,
            INSTRENUM_FLT_H
        } iff((rs1_val[15:0]==ZFHEXT_SNAN) || (rs2_val[15:0]==ZFHEXT_SNAN));

        bins feq_flt_fle_rs1_negSNAN[]  =   {
            INSTRENUM_FLE_H,
            INSTRENUM_FEQ_H,
            INSTRENUM_FLT_H
        } iff((rs1_val[15:0]==ZFHEXT_SNAN_NEG) || (rs2_val[15:0]==ZFHEXT_SNAN_NEG));

        bins feq_flt_fle_rs1_rs2_SNAN[] =   {
            INSTRENUM_FLE_H,
            INSTRENUM_FEQ_H,
            INSTRENUM_FLT_H
        } iff(  (rs1_val[15:0]==ZFHEXT_SNAN && rs2_val[15:0]==ZFHEXT_SNAN)     ||
                (rs1_val[15:0]==ZFHEXT_SNAN && rs2_val[15:0]==ZFHEXT_SNAN_NEG) ||
                (rs1_val[15:0]==ZFHEXT_SNAN_NEG && rs2_val[15:0]==ZFHEXT_SNAN) ||
                (rs1_val[15:0]==ZFHEXT_SNAN_NEG && rs2_val[15:0]==ZFHEXT_SNAN_NEG)
            );
    }

    zfhext__NVflag_QNAN_flt: coverpoint instrenum_var{

        bins flt_fle_rs1_posQNAN[]  =   {
            INSTRENUM_FEQ_H,
            INSTRENUM_FLT_H
        } iff((rs1_val[15:0]==ZFHEXT_QNAN) || (rs2_val[15:0]==ZFHEXT_QNAN));

        bins flt_fle_rs1_negQNAN[]  =   {
            INSTRENUM_FEQ_H,
            INSTRENUM_FLT_H
        } iff((rs1_val[15:0]==ZFHEXT_QNAN_NEG) || (rs2_val[15:0]==ZFHEXT_QNAN_NEG));

        bins flt_fle_rs1_rs2_QNAN[] =   {
            INSTRENUM_FEQ_H,
            INSTRENUM_FLT_H
        } iff(  (rs1_val[15:0]==ZFHEXT_QNAN && rs2_val[15:0]==ZFHEXT_QNAN)      ||
                (rs1_val[15:0]==ZFHEXT_QNAN && rs2_val[15:0]==ZFHEXT_QNAN_NEG)  ||
                (rs1_val[15:0]==ZFHEXT_QNAN_NEG && rs2_val[15:0]==ZFHEXT_QNAN)  ||
                (rs1_val[15:0]==ZFHEXT_QNAN_NEG && rs2_val[15:0]==ZFHEXT_QNAN_NEG)
            );
    }

    zfhext__NVFLAG_fmadd_zero_infinity: coverpoint rs2_val[15:0]{
        bins zero_infinity[]    =   {
            ZFHEXT_INFINITY,
            ZFHEXT_INFINITY_NEG
        } iff(rs1_val[15:0]==ZFHEXT_ZERO);
    }

    zfhext__NVFLAG_fmadd_infinity_zero: coverpoint rs1_val[15:0]{
        bins infinity_zero[]    =   {
            ZFHEXT_INFINITY,
            ZFHEXT_INFINITY_NEG
        } iff(rs2_val[15:0]==ZFHEXT_ZERO);
    }

    zfhext__NVFLAG_fmadd_fmsub_fnmadd_fnmsub: coverpoint instrenum_var{
        bins ops[]  =   {
            INSTRENUM_FNMADD_H,
            INSTRENUM_FNMSUB_H,
            INSTRENUM_FMADD_H,
            INSTRENUM_FMSUB_H
        };
    }

    zfhext__NVFLAG_fmadd_infinity_zero_cross1: cross zfhext__NVFLAG_fmadd_fmsub_fnmadd_fnmsub,zfhext__NVFLAG_fmadd_zero_infinity;
    zfhext__NVFLAG_fmadd_infinity_zero_cross2: cross zfhext__NVFLAG_fmadd_fmsub_fnmadd_fnmsub,zfhext__NVFLAG_fmadd_infinity_zero;

    zfhext__NVflag_fused_mul: coverpoint rs3_val[15:0]{
        bins qnan_rs3[] =   {
            ZFHEXT_QNAN,
            ZFHEXT_QNAN_NEG
        };
    }

    zfhext__NVflag_fused_mul_cross: cross zfhext__NVflag_fused_mul, zfhext__NVFLAG_fmadd_fmsub_fnmadd_fnmsub;

    zfhext__NAN_cp_fsqrt_neg: coverpoint instrenum_var{
        bins fsqrt_neg  =   {
            INSTRENUM_FSQRT_H
        }  iff(rs1_val[15]=='b1);
    }

    zfhext__NAN_cp_fsqrt_neg_zero: coverpoint instrenum_var{
        bins fsqrt_neg  =   {
            INSTRENUM_FSQRT_H
        }  iff(rs1_val[15:0]==ZFHEXT_ZERO_NEG);
    }

    zfhext__NAN_cp_mul: coverpoint instrenum_var{

        bins fmul_pos0xposinfi  =   {
            INSTRENUM_FMUL_H
        } iff(  (rs1_val[15:0]=='b0 && rs2_val[15:0]==ZFHEXT_INFINITY) ||
                (rs2_val[15:0]=='b0 && rs1_val[15:0]==ZFHEXT_INFINITY)
            );

        bins fmul_pos0xneginfi  =   {
            INSTRENUM_FMUL_H
        } iff(  (rs1_val[15:0]=='b0 && rs2_val[15:0]==ZFHEXT_INFINITY_NEG) ||
                (rs2_val[15:0]=='b0 && rs1_val[15:0]==ZFHEXT_INFINITY_NEG)
            );

        bins fmul_neg0xneginfi  =   {
            INSTRENUM_FMUL_H
        } iff(  (rs1_val[15:0]==ZFHEXT_ZERO_NEG && rs2_val[15:0]==ZFHEXT_INFINITY_NEG) ||
                (rs2_val[15:0]==ZFHEXT_ZERO_NEG && rs1_val[15:0]==ZFHEXT_INFINITY_NEG)
            );

        bins fmul_neg0xposinfi  =   {
            INSTRENUM_FMUL_H
        } iff(  (rs1_val[15:0]==ZFHEXT_ZERO_NEG && rs2_val[15:0]==ZFHEXT_INFINITY) ||
                (rs2_val[15:0]==ZFHEXT_ZERO_NEG && rs1_val[15:0]==ZFHEXT_INFINITY)
            );
    }

    zfhext__NAN_cp_fdiv: coverpoint instrenum_var{

        bins fdiv_pos0bypos0    =   {
            INSTRENUM_FDIV_H
        } iff((rs1_val[15:0]=='b0) && (rs2_val[15:0]=='b0));

        bins fdiv_neg0byneg0    =   {
            INSTRENUM_FDIV_H
        } iff((rs1_val[15:0]==ZFHEXT_ZERO_NEG) && (rs2_val[15:0]==ZFHEXT_ZERO_NEG));
    }

    zfhext__NAN_cp_div_infbyinfi:coverpoint instrenum_var{

        bins fdiv_posinfibyposinfi  =   {
            INSTRENUM_FDIV_H
        } iff((rs1_val[15:0]==ZFHEXT_INFINITY) && (rs2_val[15:0]==ZFHEXT_INFINITY));

        bins fdiv_neginfibyneginfi  =   {
            INSTRENUM_FDIV_H
        } iff((rs1_val[15:0]==ZFHEXT_INFINITY_NEG) && (rs2_val[15:0]==ZFHEXT_INFINITY_NEG));
    }

    zfhext__NAN_cp_fsub_samesign: coverpoint instrenum_var{

        bins fsub_infmininf_ss  =   {
            INSTRENUM_FSUB_H
        } iff((rs1_val[15:0]==ZFHEXT_INFINITY) && (rs2_val[15:0]==ZFHEXT_INFINITY));

        bins fsub_infmininf_ss_0    =   {
            INSTRENUM_FSUB_H
        } iff((rs1_val[15:0]==ZFHEXT_INFINITY_NEG) && (rs2_val[15:0]==ZFHEXT_INFINITY_NEG));
    }

    zfhext__NAN_cp_fsub_notsamesign: coverpoint instrenum_var{

        bins fsub_infsubinf_10  =   {
            INSTRENUM_FSUB_H
        } iff((rs1_val[15:0]==ZFHEXT_INFINITY) && (rs2_val[15:0]==ZFHEXT_INFINITY_NEG));

        bins fsub_infsubinf_01  =   {
            INSTRENUM_FSUB_H
        } iff((rs1_val[15:0]==ZFHEXT_INFINITY_NEG) && (rs2_val[15:0]==ZFHEXT_INFINITY));
    }

    zfhext__DZflag_fdiv: coverpoint instrenum_var{

        bins fdiv_DZFLagset_pos0    =   {
            INSTRENUM_FDIV_H
        } iff(rs2_val[15:0]=='b0);

        bins fdiv_DZFLagset_neg0    =   {
            INSTRENUM_FDIV_H
        } iff(rs2_val[15:0]==ZFHEXT_ZERO_NEG);
    }

    zfhext__OF_NXFLAG_fadd : coverpoint instrenum_var{

        bins fadd_LNpos_posno   =   {
            INSTRENUM_FADD_H
        } iff(  (rs1_val[15:0]==ZFHEXT_LN && rs2_val[15]=='b0) ||
                (rs2_val[15:0]==ZFHEXT_LN && rs1_val[15]=='b0)
            );

        bins fadd_LNneg_posno   =   {
            INSTRENUM_FADD_H
        } iff(  (rs1_val[15:0]==ZFHEXT_LN_NEG && rs2_val[15]=='b0) ||
                (rs2_val[15:0]==ZFHEXT_LN_NEG && rs1_val[15]=='b0)
            );
    }

    zfhext__OF_NXFLAG_fadd_roundmodes_cross: cross zfhext__rounding_modes_static_legal_rm, zfhext__OF_NXFLAG_fadd;

    zfhext__OF_NXflag_fmul : coverpoint instrenum_var{

        bins fmul_LNpos_1pluspos    =   {
            INSTRENUM_FMUL_H
        } iff(  (rs1_val[15:0]==ZFHEXT_LN && rs2_val[15:0]==ZFHEXT_ONE_PLUS) ||
                (rs2_val[15:0]==ZFHEXT_LN && rs1_val[15:0]==ZFHEXT_ONE_PLUS)
            );

        bins fmul_LNneg_1pluspos    =   {
            INSTRENUM_FMUL_H
        } iff(  (rs1_val[15:0]==ZFHEXT_LN_NEG && rs2_val[15:0]==ZFHEXT_ONE_PLUS) ||
                (rs2_val[15:0]==ZFHEXT_LN_NEG && rs1_val[15:0]==ZFHEXT_ONE_PLUS)
            );

        bins fmul_LNpos_1plusneg    =   {
            INSTRENUM_FMUL_H
        } iff(  (rs1_val[15:0]==ZFHEXT_LN && rs2_val[15:0]==ZFHEXT_ONE_PLUS_NEG) ||
                (rs2_val[15:0]==ZFHEXT_LN && rs1_val[15:0]==ZFHEXT_ONE_PLUS_NEG)
            );

        bins fmul_LNneg_1plusneg    =   {
            INSTRENUM_FMUL_H
        } iff(  (rs1_val[15:0]==ZFHEXT_LN_NEG && rs2_val[15:0]==ZFHEXT_ONE_PLUS_NEG) ||
                (rs2_val[15:0]==ZFHEXT_LN_NEG && rs1_val[15:0]==ZFHEXT_ONE_PLUS_NEG)
            );
    }

    zfhext__OF_NXflag_fmul_roundmodes_cross: cross zfhext__rounding_modes_static_legal_rm,zfhext__OF_NXflag_fmul;

    zfhext__UF_flag_fdiv : coverpoint instrenum_var{

        bins fdiv_SNby2 =   {
            INSTRENUM_FDIV_H
        } iff((rs1_val[15:0]==ZFHEXT_SN) && (rs2_val[15:0]==ZFHEXT_TWO));

        bins fdiv_SNby2_n   =   {
            INSTRENUM_FDIV_H
        } iff((rs1_val[15:0]==ZFHEXT_SN_NEG) && (rs2_val[15:0]==ZFHEXT_TWO_NEG));
    }

    zfhext__UF_fsub_SN_SN_plus: coverpoint instrenum_var{

        bins fsub_SN_SNplus =   {
            INSTRENUM_FSUB_H
        } iff((rs1_val[15:0]==ZFHEXT_SN) && (rs2_val[15:0]==16'h0401));
    }

    zfhext__NXflag_fdiv: coverpoint instrenum_var{

        bins fdiv_one_by_three =   {
            INSTRENUM_FDIV_H
        } iff((rs1_val[15:0]==ZFHEXT_ONE) && (rs2_val[15:0]==ZFHEXT_THREE));
    }

    zfhext__NX_UFflag_fdiv_SSN_by_three: coverpoint instrenum_var{

        bins fdiv_SSN_by_three =   {
            INSTRENUM_FDIV_H
        } iff(  (rs1_val[15:0]==ZFHEXT_SSN && rs2_val[15:0]==ZFHEXT_THREE) ||
                (rs1_val[15:0]==ZFHEXT_SSN_NEG && rs2_val[15:0]==ZFHEXT_THREE)
            );
    }

    zfhext__NX_UFflag_fdiv_SSN_by_two: coverpoint instrenum_var{

        bins fdiv_SSN_by_two    =   {
            INSTRENUM_FDIV_H
        } iff(  (rs1_val[15:0]==ZFHEXT_SSN && rs2_val[15:0]==ZFHEXT_TWO) ||
                (rs1_val[15:0]==ZFHEXT_SSN_NEG && rs2_val[15:0]==ZFHEXT_TWO)
            );
    }

    zfhext__NX_UFflag_fdiv_SSN_by_two_cross_frm: cross zfhext__NX_UFflag_fdiv_SSN_by_two, zfhext__rounding_modes_static_legal_rm;

    zfhext__NAN_memory_operation_FLH: coverpoint instrenum_var{

        bins FLH_SNAN   =   {
            INSTRENUM_FLH
        } iff(rd_val[15:0]==ZFHEXT_SNAN || rd_val[15:0]==ZFHEXT_SNAN_NEG);
    }

    zfhext__NAN_memory_operation_FSH: coverpoint instrenum_var{

        bins FLH_SNAN   =   {
            INSTRENUM_FSH
        } iff(rd_val[15:0]==ZFHEXT_SNAN || rd_val[15:0]==ZFHEXT_SNAN_NEG);
    }

    zfhext__NAN_memory_operation_FLH_NCNAN: coverpoint instrenum_var{

        bins FLH_SNAN   =   {
            INSTRENUM_FLH
        } iff(  (rd_val[15:8]==8'h7e && rd_val[7:0] != 0) ||
                (rd_val[15:8]==8'hfe && rd_val[7:0] != 0)
            );
    }

    zfhext__NAN_memory_operation_FSH_NCNAN: coverpoint instrenum_var{

        bins FLH_SNAN   =   {
            INSTRENUM_FSH
        } iff(  (rd_val[15:8]==8'h7e && rd_val[7:0] != 0) ||
                (rd_val[15:8]==8'hfe && rd_val[7:0] != 0)
            );
    }

    zfhext_NAN_arithmetic_rs1: coverpoint rs1_val[15:0]{
        bins pos_SNAN_rs1= {ZFHEXT_SNAN};
        bins neg_SNAN_rs1={ZFHEXT_SNAN_NEG};
        bins pos_QNAN_rs1={ZFHEXT_QNAN};
        bins neg_QNAN_rs1={ZFHEXT_QNAN_NEG};
        bins pos_NCNAN_rs1={[16'h7e01:16'h7eff]};
        bins neg_NCNAN_rs1={[16'hfe01:16'hfeff]};

    }
    zfhext_NAN_arithmetic_rs2: coverpoint rs2_val[15:0]{
        bins pos_SNAN_rs2={ZFHEXT_SNAN};
        bins neg_SNAN_rs2={ZFHEXT_SNAN_NEG};
        bins pos_QNAN_rs2={ZFHEXT_QNAN};
        bins neg_QNAN_rs2={ZFHEXT_QNAN_NEG};
        bins pos_NCNAN_rs2={[16'h7e01:16'h7eff]};
        bins neg_NCNAN_rs2={[16'hfe01:16'hfeff]};
    }
    zfhext_NAN_arithmetic_feq_flt_fle: coverpoint instrenum_var{

        bins feq_flt_fle[]  =   {
            INSTRENUM_FLE_H,
            INSTRENUM_FLT_H,
            INSTRENUM_FEQ_H
        };
    }
    zfhext_NAN_arithmetic_feq_flt_fle_cross1: cross zfhext_NAN_arithmetic_feq_flt_fle,zfhext_NAN_arithmetic_rs1;
    zfhext_NAN_arithmetic_feq_flt_fle_cross2: cross zfhext_NAN_arithmetic_feq_flt_fle,zfhext_NAN_arithmetic_rs2;

    zfhext__NAN_arithmetic_fsub_fdiv: coverpoint instrenum_var{
        bins fdiv_fsub[]    =   {
            INSTRENUM_FSUB_H,
            INSTRENUM_FDIV_H
        };
    }
    zfhext__NAN_arithmetic_fsub_fdiv_cross1: cross zfhext__NAN_arithmetic_fsub_fdiv, zfhext_NAN_arithmetic_rs1;
    zfhext__NAN_arithmetic_fsub_fdiv_cross2: cross zfhext__NAN_arithmetic_fsub_fdiv, zfhext_NAN_arithmetic_rs2;

    zfhext__Generic_special_NAN_ZERO_rs1: coverpoint instrenum_var{
        option.weight=0;
        bins vals[]    =   {
            INSTRENUM_FADD_H,
            INSTRENUM_FMUL_H,
            INSTRENUM_FSUB_H,
            INSTRENUM_FDIV_H,
            INSTRENUM_FSQRT_H,
            INSTRENUM_FMIN_H,
            INSTRENUM_FMAX_H
        } iff(rs2_val[15:0]==0);
    }

    zfhext__Generic_special_NAN_ZERO_rs2: coverpoint instrenum_var{
        option.weight=0;
        bins vals[] =   {
            INSTRENUM_FADD_H,
            INSTRENUM_FMUL_H,
            INSTRENUM_FSUB_H,
            INSTRENUM_FDIV_H,
            INSTRENUM_FSQRT_H,
            INSTRENUM_FMIN_H,
            INSTRENUM_FMAX_H
        } iff(rs1_val[15:0]==0);
    }
    zfhext__Generic_special_cross_1: cross zfhext__Generic_special_NAN_ZERO_rs1, zfhext_NAN_arithmetic_rs1 ;
    zfhext__Generic_special_cross_2: cross zfhext__Generic_special_NAN_ZERO_rs2, zfhext_NAN_arithmetic_rs2;

    zfhext__Generic_special_Fmin_Fmax: coverpoint instrenum_var{
        option.weight=0;
        bins fmin_fmax_NAN[]    =   {
            INSTRENUM_FMIN_H,
            INSTRENUM_FMAX_H
        };
    }
    zfhext__Generic_special_Fmin_Fmax_cross_1: cross zfhext__Generic_special_Fmin_Fmax, zfhext_NAN_arithmetic_rs1;
    zfhext__Generic_special_Fmin_Fmax_cross_2: cross zfhext__Generic_special_Fmin_Fmax, zfhext_NAN_arithmetic_rs2;


    zfhext__Generic_special_case3_rs1_diffvalues: coverpoint rs1_val[15:0]{
        option.weight=0;
        bins SNAN_rs1= {ZFHEXT_SNAN};
        bins QNAN__rs1={ZFHEXT_QNAN};
        bins NCNAN_rs1={[16'h7e01:16'h7eff]};
        bins LN_rs1={ZFHEXT_LN};
        bins SSN_rs1={ZFHEXT_SSN};
        bins zero_rs1={ZFHEXT_ZERO};
        bins infinity_rs1={ZFHEXT_INFINITY};
    }
    zfhext__Generic_special_case3_rs2_diffvalues: coverpoint rs2_val[15:0]{
        option.weight=0;
        bins SNAN_rs2= {ZFHEXT_SNAN};
        bins QNAN__rs2={ZFHEXT_QNAN};
        bins NCNAN_rs2={[16'h7e01:16'h7eff]};
        bins LN_rs2={ZFHEXT_LN};
        bins SSN_rs2={ZFHEXT_SSN};
        bins zero_rs2={ZFHEXT_ZERO};
        bins infinity_rs2={ZFHEXT_INFINITY};
    }
    zfhext__Generic_special_case3_ops: coverpoint instrenum_var{
        bins vals = {
            INSTRENUM_FADD_H,
            INSTRENUM_FMUL_H,
            INSTRENUM_FSUB_H,
            INSTRENUM_FDIV_H,
            INSTRENUM_FSQRT_H,
            INSTRENUM_FMIN_H,
            INSTRENUM_FMAX_H,
            INSTRENUM_FMADD_H,
            INSTRENUM_FMSUB_H,
            INSTRENUM_FNMADD_H,
            INSTRENUM_FNMSUB_H};
    }

    zfhext__Generic_special_case3_cross:cross zfhext__Generic_special_case3_ops, zfhext__Generic_special_case3_rs2_diffvalues,zfhext__Generic_special_case3_rs1_diffvalues;

    zfhext__Computational_fmin_fmax_zero: coverpoint instrenum_var{

        bins fmin_fmax_case1_1[]    =   {
                INSTRENUM_FMIN_H,
                INSTRENUM_FMAX_H
            } iff((rs1_val[15:0]==16'h0000) && (rs2_val[15:0]==16'h0000));
        bins fmin_fmax_case1_2[]    =   {
                INSTRENUM_FMIN_H,
                INSTRENUM_FMAX_H
            } iff((rs1_val[15:0]==16'h0000) && (rs2_val[15:0]==ZFHEXT_ZERO_NEG));
        bins fmin_fmax_case1_3[]    =   {
                INSTRENUM_FMIN_H,
                INSTRENUM_FMAX_H
            } iff((rs1_val[15:0]==ZFHEXT_ZERO_NEG) && (rs2_val[15:0]==ZFHEXT_ZERO_NEG));
        bins fmin_fmax_case1_4[]    =   {
                INSTRENUM_FMIN_H,
                INSTRENUM_FMAX_H
            } iff((rs1_val[15:0]==ZFHEXT_ZERO_NEG) && (rs2_val[15:0]==16'h0000));
    }

    zfhext__Computational_fmin_fmax_NCNAN: coverpoint instrenum_var{
        bins fmin_fmax_case2[]={
            INSTRENUM_FMIN_H,
            INSTRENUM_FMAX_H
        } iff(  ((rs1_val[15:8]==8'h7e && rs1_val[7:0] != 0) && (rs2_val[15:8]==8'h7e && rs2_val[7:0] != 0)) ||
                ((rs1_val[15:8]==8'hfe && rs1_val[7:0] != 0) && (rs2_val[15:8]==8'hfe && rs2_val[7:0] != 0))
            );
    }

    zfhext__Computational_fmadd_fnmadd: coverpoint instrenum_var{
        bins fmadd_fmsub_fnmsub_fnmadd[]    =   {
            INSTRENUM_FMADD_H,
            INSTRENUM_FMSUB_H,
            INSTRENUM_FNMADD_H,
            INSTRENUM_FNMSUB_H
        } iff(rs1_val[15:0]==rs2_val[15:0]);
    }

    zfhext__Conversion_move_fcvt: coverpoint instrenum_var{
        bins fcvt_diff_types_ZFH[]    =   {
            INSTRENUM_FCVT_L_H,
            INSTRENUM_FCVT_LU_H,
            INSTRENUM_FCVT_H_L,
            INSTRENUM_FCVT_H_LU,
            INSTRENUM_FCVT_H_W,
            INSTRENUM_FCVT_H_WU,
            INSTRENUM_FCVT_W_H,
            INSTRENUM_FCVT_WU_H
        };
    }

    zfhext__Conversion_move_x0: coverpoint instrenum_var{
        bins fcvt_ZFH_X[] =   {
            INSTRENUM_FCVT_H_W,
            INSTRENUM_FCVT_H_L,
            INSTRENUM_FCVT_H_LU,
            INSTRENUM_FCVT_H_WU
        } iff(rs1==0);
    }

    zfhext__cross_conversions: coverpoint instrenum_var{
        bins cross_zfh[]  =   {
            INSTRENUM_FCVT_S_H,
            INSTRENUM_FCVT_D_H
        };
    }

    zfhext__cross_extenstion_coversion: coverpoint instrenum_var{
        bins inject_instr_H[]   =       {
            INSTRENUM_FSGNJ_H,
            INSTRENUM_FSGNJN_H,
            INSTRENUM_FSGNJX_H
        };
    }
    zfhext__cross_extenstion_coversion_cross_rs1: cross zfhext__cross_extenstion_coversion,zfhext_NAN_arithmetic_rs1;
    zfhext__cross_extenstion_coversion_cross_rs2: cross zfhext__cross_extenstion_coversion,zfhext_NAN_arithmetic_rs2;

    zfhext__Softfloat_fdiv: coverpoint instrenum_var{
        bins fdiv_s[]   =   {
            INSTRENUM_FDIV_H,
            INSTRENUM_FSQRT_H
        };
    }
    zfhext__Softfloat_fdiv_cross_roundingmodes: cross zfhext__Softfloat_fdiv,zfhext__rounding_modes_static_legal_rm,zfhext__Generic_special_case3_rs1_diffvalues;

    zfhext__Softfloat_convert_cross_roundmodes: cross zfhext__Conversion_move_fcvt,zfhext__rounding_modes_static_legal_rm;

endgroup

`endif
