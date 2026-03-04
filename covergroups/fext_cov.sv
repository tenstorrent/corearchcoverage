`ifndef COVERAGE_UNSUPPORTED

import cp_pkg::*;

covergroup fext__cg with function sample(csr_cov_sample i_csr);
    option.per_instance = 1;
    option.name = "cg_fext";

    fext__fcsr_rd_x0: coverpoint instrenum_var{
        bins frcsr_rd = {INSTRENUM_CSRRS} iff((csrenum_var==CSRENUM_FCSR) && (rd==0) && (rs1==0));
        bins fscsr_rd_rs = {INSTRENUM_CSRRW} iff((csrenum_var==CSRENUM_FCSR) && (rd==0));
        bins frrm_rd = {INSTRENUM_CSRRS} iff((csrenum_var==CSRENUM_FRM) && (rd==0) && (rs1==0));
        bins fsrm_rd_rs = {INSTRENUM_CSRRW} iff((csrenum_var==CSRENUM_FRM) && (rd==0));
        bins frflags_rd = {INSTRENUM_CSRRS} iff((csrenum_var==CSRENUM_FFLAGS) && (rd==0) && (rs1==0));
        bins fsflags_rd_rs = {INSTRENUM_CSRRW} iff((csrenum_var==CSRENUM_FFLAGS) && (rd==0));
    }

    fext__fcsr_rs1: coverpoint rs1_val[31:8]{
        bins rs1_all[] = {24'h000001,24'hffffff}; 
        bins rs1_remaining = {[24'h000002:24'hfffffe]};
    }
    fext__fcsr_fscsr_reserv: coverpoint instrenum_var{
        bins fscsr_rs_reserv = {INSTRENUM_CSRRW} iff((csrenum_var==CSRENUM_FCSR) && (rd==0));
        bins fscsr_rd_rs_reserv = {INSTRENUM_CSRRW} iff(csrenum_var==CSRENUM_FCSR);
    }
    fext__fcsr_fscsr_reserved: cross fext__fcsr_rs1,fext__fcsr_fscsr_reserv;

    fext__fcsr_frm_bit_toggle_bit0: coverpoint i_csr.fcsr_csr_inst.frm[0];
    fext__fcsr_frm_bit_toggle_bit1: coverpoint i_csr.fcsr_csr_inst.frm[1]; 
    fext__fcsr_frm_bit_toggle_bit2 : coverpoint i_csr.fcsr_csr_inst.frm[2];

    fext__fcsr_fflags_bit_toggle_NX: coverpoint i_csr.fcsr_csr_inst.fflags[0];
    fext__fcsr_fflags_bit_toggle_UF: coverpoint i_csr.fcsr_csr_inst.fflags[1];
    fext__fcsr_fflags_bit_toggle_OF: coverpoint i_csr.fcsr_csr_inst.fflags[2];
    fext__fcsr_fflags_bit_toggle_DZ: coverpoint i_csr.fcsr_csr_inst.fflags[3];
    fext__fcsr_fflags_bit_toggle_NV: coverpoint i_csr.fcsr_csr_inst.fflags[4];

    fext__fcsr_frcsr_fscsr: coverpoint instrenum_var{
        bins fscsr_rs = {INSTRENUM_CSRRW} iff((csrenum_var==CSRENUM_FCSR) && (rd==0));
        bins fscsr_rd_rs = {INSTRENUM_CSRRW} iff(csrenum_var==CSRENUM_FCSR);
        bins frcsr_rd = {INSTRENUM_CSRRS} iff((csrenum_var==CSRENUM_FCSR) && (rs1==0));

    }

    fext__fcsr_frm_bit_toggle_bit0_cross: cross fext__fcsr_frcsr_fscsr,fext__fcsr_frm_bit_toggle_bit0;
    fext__fcsr_frm_bit_toggle_bit1_cross: cross fext__fcsr_frcsr_fscsr,fext__fcsr_frm_bit_toggle_bit1;
    fext__fcsr_frm_bit_toggle_bit2_cross: cross fext__fcsr_frcsr_fscsr,fext__fcsr_frm_bit_toggle_bit2;
    fext__fcsr_fflags_bit_toggle_N_cross:cross fext__fcsr_frcsr_fscsr,fext__fcsr_fflags_bit_toggle_NX;
    fext__fcsr_fflags_bit_toggle_UF_cross:cross fext__fcsr_frcsr_fscsr,fext__fcsr_fflags_bit_toggle_UF;
    fext__fcsr_fflags_bit_toggle_OF_cross:cross fext__fcsr_frcsr_fscsr,fext__fcsr_fflags_bit_toggle_OF;
    fext__fcsr_fflags_bit_toggle_DZ_cross:cross fext__fcsr_frcsr_fscsr,fext__fcsr_fflags_bit_toggle_DZ;
    fext__fcsr_fflags_bit_toggle_NV_cross:cross fext__fcsr_frcsr_fscsr,fext__fcsr_fflags_bit_toggle_NV;

    fext__frm_frrm_fsrm: coverpoint instrenum_var{
        bins fsrm_rs = {INSTRENUM_CSRRW} iff((csrenum_var==CSRENUM_FRM) && (rd==0));
        bins fsrm_rd_rs = {INSTRENUM_CSRRW} iff(csrenum_var==CSRENUM_FRM);
        bins frrm_rd = {INSTRENUM_CSRRS} iff((csrenum_var==CSRENUM_FRM) && (rs1==0));

    }
    fext__frm_frrm_fsrm1: coverpoint instrenum_var{
        option.weight=0;
        bins fsrm_rd_rs = {INSTRENUM_CSRRW} iff(csrenum_var==CSRENUM_FRM);
        bins frrm_rd = {INSTRENUM_CSRRS} iff((csrenum_var==CSRENUM_FRM) && (rs1==0));

    }
    fext__frm_frrm_fsrm_trans: coverpoint rd_val{
        bins trans = ('1 => [32'h00000000:32'h00000008]);
    }
    fext__frm_frrm_fsrm_cross: cross fext__frm_frrm_fsrm1,fext__frm_frrm_fsrm_trans;

    fext__fflags_frflags_fsflags: coverpoint instrenum_var{
        bins fsrm_rs = {INSTRENUM_CSRRW} iff((csrenum_var==CSRENUM_FFLAGS) && (rd==0));
        bins fsrm_rd_rs = {INSTRENUM_CSRRW} iff(csrenum_var==CSRENUM_FFLAGS);
        bins frrm_rd = {INSTRENUM_CSRRS} iff((csrenum_var==CSRENUM_FFLAGS) && (rs1==0));

    }

    fext__fflags_frflags_fsflags1: coverpoint instrenum_var{
        option.weight=0;
        bins fsrm_rd_rs = {INSTRENUM_CSRRW} iff(csrenum_var==CSRENUM_FFLAGS);
        bins frrm_rd = {INSTRENUM_CSRRS} iff((csrenum_var==CSRENUM_FFLAGS) && (rs1==0));

    }
    fext__fflags_frflags_fsflags_trans: coverpoint rd_val{
        bins trans = ('1 => [32'h00000000:32'h00000020]);
    }
    fext__fflags_frflags_fsflags_cross: cross fext__fflags_frflags_fsflags1,fext__fflags_frflags_fsflags_trans;

    fext__rounding_modes_invalid_FRM: coverpoint Inst[14:12] {
        bins illegal_mode[] = {5,6} iff((match_fext==1) && ((instrenum_var != INSTRENUM_FLW) || (instrenum_var != INSTRENUM_FSW))); 
    }

    fext__rounding_modes_static_legal_rm : coverpoint Inst[14:12] {
        bins hit[] = {0,1,2,3,4} iff(match_fext==1);
    }
   
    fext__rounding_modes_dynamic_illegal: coverpoint i_csr.fcsr_csr_inst.frm{
        bins illegal_mode_2[] = {3'd5,3'd6,3'd7} iff((match_fext==1) && (Inst[14:12] == 3'b111) && ((instrenum_var != INSTRENUM_FLW) || (instrenum_var != INSTRENUM_FSW))); 
    }
 
    fext__rounding_modes_dynamic_legal: coverpoint i_csr.fcsr_csr_inst.frm{
        bins dynamic_mode[] = {3'd1,3'd2,3'd3,3'd0,3'd4} iff((match_fext==1) && (Inst[14:12] == 3'd7) && ((instrenum_var != INSTRENUM_FLW) || (instrenum_var != INSTRENUM_FSW)));
    }

    fext__rounding_modes_xminusx: coverpoint instrenum_var{
        bins fsub_xminusx ={INSTRENUM_FSUB_S} iff((rs1_val[31:0]==rs2_val[31:0])); 
    } 

    fext__rounding_modes_xminusx_cross: cross fext__rounding_modes_xminusx, fext__rounding_modes_static_legal_rm;

    fext__rounding_modes_rounding: coverpoint i_csr.fcsr_csr_inst.frm{
        bins dynamic_mode[] = {3'd1,3'd2,3'd3,3'd0,3'd4} ;
    }

    fext__rounding_modes_edge_case: coverpoint instrenum_var{
        bins L_XLENx1plus={INSTRENUM_FMUL_S} iff(((rs1_val[31:0]==FEXT_LN) && (rs2_val[31:0]==FEXT_ONE_PLUS)) || ((rs2_val[31:0]==FEXT_LN) && (rs1_val[31:0]==FEXT_ONE_PLUS)));
        bins negL_XLENxneg1plus={INSTRENUM_FMUL_S} iff(((rs1_val[31:0]==FEXT_LN_NEG) && (rs2_val[31:0]==FEXT_ONE_PLUS_NEG)) || ((rs2_val[31:0]==FEXT_LN_NEG) && (rs1_val[31:0]==FEXT_ONE_PLUS_NEG)));
        bins L_XLENxS_XLEN={INSTRENUM_FADD_S} iff(((rs1_val[31:0]==FEXT_LN) && (rs2_val[31:0]==FEXT_SN)) || ((rs2_val[31:0]==FEXT_LN) && (rs1_val[31:0]==FEXT_SN)));
        bins negL_XLENxnegS_XLEN={INSTRENUM_FADD_S} iff(((rs1_val[31:0]==FEXT_LN_NEG) && (rs2_val[31:0]==FEXT_SN_NEG)) || ((rs2_val[31:0]==FEXT_LN_NEG) && (rs1_val[31:0]==FEXT_SN_NEG))); 
        bins L_XLENx1neg={INSTRENUM_FDIV_S} iff(((rs1_val[31:0]==FEXT_LN) && (rs2_val[31:0]==FEXT_ONE_MINUS)) || ((rs2_val[31:0]==FEXT_LN) && (rs1_val[31:0]==FEXT_ONE_MINUS)));
        bins negL_XLENxneg1neg={INSTRENUM_FDIV_S} iff(((rs1_val[31:0]==FEXT_LN_NEG) && (rs2_val[31:0]==FEXT_ONE_MINUS_NEG)) || ((rs2_val[31:0]==FEXT_LN_NEG) && (rs1_val[31:0]==FEXT_ONE_MINUS_NEG)));
        
    }
    fext__rounding_modes_edge_case_cross: cross fext__rounding_modes_static_legal_rm, fext__rounding_modes_edge_case; 
  
    fext__NVflag_SNAN_feq: coverpoint instrenum_var{
        bins feq_flt_fle_rs1_posSNAN[]={INSTRENUM_FLE_S, INSTRENUM_FEQ_S, INSTRENUM_FLT_S} iff((rs1_val[31:0]==FEXT_SNAN) || (rs2_val[31:0]==FEXT_SNAN));
        bins feq_flt_fle_rs1_negSNAN[]={INSTRENUM_FLE_S, INSTRENUM_FEQ_S, INSTRENUM_FLT_S} iff((rs1_val[31:0]==FEXT_SNAN_NEG) || (rs2_val[31:0]==FEXT_SNAN_NEG));
        bins feq_flt_fle_rs1_rs2_SNAN[]={INSTRENUM_FLE_S, INSTRENUM_FEQ_S, INSTRENUM_FLT_S} iff((rs1_val[31:0]==FEXT_SNAN && rs2_val[31:0]==FEXT_SNAN) || (rs1_val[31:0]==FEXT_SNAN && rs2_val[31:0]==FEXT_SNAN_NEG) || (rs1_val[31:0]==FEXT_SNAN_NEG && rs2_val[31:0]==FEXT_SNAN) || (rs1_val[31:0]==FEXT_SNAN_NEG && rs2_val[31:0]==FEXT_SNAN_NEG));
    }

    fext__NVflag_QNAN_flt: coverpoint instrenum_var{
        bins flt_fle_rs1_posQNAN[]={ INSTRENUM_FEQ_S, INSTRENUM_FLT_S} iff((rs1_val[31:0]==FEXT_QNAN) || (rs2_val[31:0]==FEXT_QNAN));
        bins flt_fle_rs1_negQNAN[]={ INSTRENUM_FEQ_S, INSTRENUM_FLT_S} iff((rs1_val[31:0]==FEXT_QNAN_NEG) || (rs2_val[31:0]==FEXT_QNAN_NEG));
        bins flt_fle_rs1_rs2_QNAN[]={ INSTRENUM_FEQ_S, INSTRENUM_FLT_S} iff((rs1_val[31:0]==FEXT_QNAN && rs2_val[31:0]==FEXT_QNAN) || (rs1_val[31:0]==FEXT_QNAN && rs2_val[31:0]==FEXT_QNAN_NEG) || (rs1_val[31:0]==FEXT_QNAN_NEG && rs2_val[31:0]==FEXT_QNAN) || (rs1_val[31:0]==FEXT_QNAN_NEG && rs2_val[31:0]==FEXT_QNAN_NEG));
    }

    fext__NVFLAG_fmadd_zero_infinity: coverpoint rs2_val[31:0]{
        bins zero_infinity[]={FEXT_INFINITY,FEXT_INFINITY_NEG} iff(rs1_val[31:0] == FEXT_ZERO);
    }
    fext__NVFLAG_fmadd_infinity_zero: coverpoint rs1_val[31:0]{
        bins infinity_zero[]={FEXT_INFINITY,FEXT_INFINITY_NEG} iff(rs2_val[31:0] == FEXT_ZERO);
    }
    fext__NVFLAG_fmadd_fmsub_fnmadd_fnmsub: coverpoint instrenum_var{
        bins ops[]={INSTRENUM_FNMADD_S,INSTRENUM_FNMSUB_S,INSTRENUM_FMADD_S,INSTRENUM_FMSUB_S};
    }

    fext__NVFLAG_fmadd_infinity_zero_cross1: cross fext__NVFLAG_fmadd_fmsub_fnmadd_fnmsub,fext__NVFLAG_fmadd_zero_infinity;
    fext__NVFLAG_fmadd_infinity_zero_cross2: cross fext__NVFLAG_fmadd_fmsub_fnmadd_fnmsub,fext__NVFLAG_fmadd_infinity_zero;
    
    fext__NVflag_fused_mul: coverpoint rs3_val[31:0]{
        bins qnan_rs3[]={FEXT_QNAN,FEXT_QNAN_NEG}; 
    }
    fext__NVflag_fused_mul_cross: cross fext__NVflag_fused_mul, fext__NVFLAG_fmadd_fmsub_fnmadd_fnmsub;

    fext__NAN_cp_fsqrt_neg: coverpoint instrenum_var{
        bins fsqrt_neg={INSTRENUM_FSQRT_S}  iff(rs1_val[31]=='b1);
    }

    fext__NAN_cp_fsqrt_neg_zero: coverpoint instrenum_var{
        bins fsqrt_neg={INSTRENUM_FSQRT_S}  iff(rs1_val[31:0]==FEXT_ZERO_NEG);
    }

    fext__NAN_cp_mul: coverpoint instrenum_var{
        bins fmul_pos0xposinfi={INSTRENUM_FMUL_S} iff((rs1_val[31:0]=='b0 && rs2_val[31:0]==FEXT_INFINITY) || (rs2_val[31:0]=='b0 && rs1_val[31:0]==FEXT_INFINITY));  
        bins fmul_pos0xneginfi={INSTRENUM_FMUL_S} iff((rs1_val[31:0]=='b0 && rs2_val[31:0]==FEXT_INFINITY_NEG) || (rs2_val[31:0]=='b0 && rs1_val[31:0]==FEXT_INFINITY_NEG));
        bins fmul_neg0xneginfi={INSTRENUM_FMUL_S} iff((rs1_val[31:0]==FEXT_ZERO_NEG && rs2_val[31:0]==FEXT_INFINITY_NEG) || (rs2_val[31:0]==FEXT_ZERO_NEG && rs1_val[31:0]==FEXT_INFINITY_NEG));  
        bins fmul_neg0xposinfi={INSTRENUM_FMUL_S} iff((rs1_val[31:0]==FEXT_ZERO_NEG && rs2_val[31:0]==FEXT_INFINITY) || (rs2_val[31:0]==FEXT_ZERO_NEG && rs1_val[31:0]==FEXT_INFINITY));
    }

    fext__NAN_cp_fdiv: coverpoint instrenum_var{
        bins fdiv_pos0bypos0={INSTRENUM_FDIV_S} iff((rs1_val[31:0]=='b0) && (rs2_val[31:0]=='b0));
        bins fdiv_neg0byneg0={INSTRENUM_FDIV_S} iff((rs1_val[31:0]==FEXT_ZERO_NEG) && (rs2_val[31:0]==FEXT_ZERO_NEG));
    }

    fext__NAN_cp_div_infbyinfi:coverpoint instrenum_var{
        bins fdiv_posinfibyposinfi={INSTRENUM_FDIV_S} iff((rs1_val[31:0]==FEXT_INFINITY) && (rs2_val[31:0]==FEXT_INFINITY));
        bins fdiv_neginfibyneginfi={INSTRENUM_FDIV_S} iff((rs1_val[31:0]==FEXT_INFINITY_NEG) && (rs2_val[31:0]==FEXT_INFINITY_NEG));
    }

    fext__NAN_cp_fsub_samesign: coverpoint instrenum_var{
        bins fsub_infmininf_ss={INSTRENUM_FSUB_S} iff((rs1_val[31:0]==FEXT_INFINITY) && (rs2_val[31:0]==FEXT_INFINITY));
        bins fsub_infmininf_ss_0={INSTRENUM_FSUB_S} iff((rs1_val[31:0]==FEXT_INFINITY_NEG) && (rs2_val[31:0]==FEXT_INFINITY_NEG));
    }
    fext__NAN_cp_fsub_notsamesign: coverpoint instrenum_var{
        bins fsub_infsubinf_10={INSTRENUM_FSUB_S} iff((rs1_val[31:0]==FEXT_INFINITY) && (rs2_val[31:0]==FEXT_INFINITY_NEG));
        bins fsub_infsubinf_01={INSTRENUM_FSUB_S} iff((rs1_val[31:0]==FEXT_INFINITY_NEG) && (rs2_val[31:0]==FEXT_INFINITY));
    }

    fext__DZflag_fdiv: coverpoint instrenum_var{
        bins fdiv_DZFLagset_pos0={INSTRENUM_FDIV_S} iff(rs2_val[31:0]=='b0);
        bins fdiv_DZFLagset_neg0={INSTRENUM_FDIV_S} iff(rs2_val[31:0]==FEXT_ZERO_NEG);
    }

    fext__OF_NXFLAG_fadd : coverpoint instrenum_var{
        bins fadd_LNpos_posno ={INSTRENUM_FADD_S} iff((rs1_val[31:0]==FEXT_LN && rs2_val[31]=='b0) || (rs2_val[31:0]==FEXT_LN && rs1_val[31]=='b0));
        bins fadd_LNneg_posno ={INSTRENUM_FADD_S} iff((rs1_val[31:0]==FEXT_LN_NEG && rs2_val[31]=='b0) || (rs2_val[31:0]==FEXT_LN_NEG && rs1_val[31]=='b0));
        
    }

    fext__OF_NXFLAG_fadd_roundmodes_cross: cross fext__rounding_modes_static_legal_rm, fext__OF_NXFLAG_fadd;

    fext__OF_NXflag_fmul : coverpoint instrenum_var{
        bins fmul_LNpos_1pluspos={INSTRENUM_FMUL_S} iff((rs1_val[31:0]==FEXT_LN && rs2_val[31:0]==FEXT_ONE_PLUS) || (rs2_val[31:0]==FEXT_LN && rs1_val[31:0]==FEXT_ONE_PLUS));
        bins fmul_LNneg_1pluspos={INSTRENUM_FMUL_S} iff((rs1_val[31:0]==FEXT_LN_NEG && rs2_val[31:0]==FEXT_ONE_PLUS) || (rs2_val[31:0]==FEXT_LN_NEG && rs1_val[31:0]==FEXT_ONE_PLUS));
        bins fmul_LNpos_1plusneg={INSTRENUM_FMUL_S} iff((rs1_val[31:0]==FEXT_LN && rs2_val[31:0]==FEXT_ONE_PLUS_NEG) || (rs2_val[31:0]==FEXT_LN && rs1_val[31:0]==FEXT_ONE_PLUS_NEG));
        bins fmul_LNneg_1plusneg={INSTRENUM_FMUL_S} iff((rs1_val[31:0]==FEXT_LN_NEG && rs2_val[31:0]==FEXT_ONE_PLUS_NEG) || (rs2_val[31:0]==FEXT_LN_NEG && rs1_val[31:0]==FEXT_ONE_PLUS_NEG));
    }
    fext__OF_NXflag_fmul_roundmodes_cross: cross fext__rounding_modes_static_legal_rm,fext__OF_NXflag_fmul;

    fext__UF_flag_fdiv: coverpoint instrenum_var{
        bins fdiv_SNby2={INSTRENUM_FDIV_S} iff((rs1_val[31:0]==FEXT_SN) && (rs2_val[31:0]==FEXT_TWO));
        bins fdiv_SNby2_n={INSTRENUM_FDIV_S} iff((rs1_val[31:0]==FEXT_SN_NEG) && (rs2_val[31:0]==FEXT_TWO_NEG));
    }
    
    fext__UF_fsub_SN_SN_plus: coverpoint instrenum_var{
        bins fsub_SN_SNplus={INSTRENUM_FSUB_S} iff((rs1_val[31:0]==FEXT_SN) && (rs2_val[31:0]==32'h00800001));
       
    }

    fext__NXflag_fdiv: coverpoint instrenum_var{
        bins fdiv_one_by_three={INSTRENUM_FDIV_S} iff((rs1_val[31:0]==FEXT_ONE) && (rs2_val[31:0]==FEXT_THREE));
    }

    fext__NX_UFflag_fdiv_SSN_by_three: coverpoint instrenum_var{
        bins fdiv_SSN_by_three ={INSTRENUM_FDIV_S} iff((rs1_val[31:0]==FEXT_SSN && rs2_val[31:0]==FEXT_THREE) || (rs1_val[31:0]==FEXT_SSN_NEG && rs2_val[31:0]==FEXT_THREE)); 
    }
    fext__NX_UFflag_fdiv_SSN_by_two: coverpoint instrenum_var{
        bins fdiv_SSN_by_two ={INSTRENUM_FDIV_S} iff((rs1_val[31:0]==FEXT_SSN && rs2_val[31:0]==FEXT_TWO) || (rs1_val[31:0]==FEXT_SSN_NEG && rs2_val[31:0]==FEXT_TWO));
    }

    fext__NX_UFflag_fdiv_SSN_by_two_cross_frm: cross fext__NX_UFflag_fdiv_SSN_by_two, fext__rounding_modes_static_legal_rm;


    fext__NAN_memory_operation_FLW: coverpoint instrenum_var{
        bins flw_SNAN ={INSTRENUM_FLW} iff(rd_val[31:0]== FEXT_SNAN || rd_val[31:0]== FEXT_SNAN_NEG);
    }

    fext__NAN_memory_operation_FSW: coverpoint instrenum_var{
        bins flw_SNAN ={INSTRENUM_FSW} iff(rd_val[31:0]==FEXT_SNAN || rd_val[31:0]==FEXT_SNAN_NEG);
    }

    fext__NAN_memory_operation_FLW_NCNAN: coverpoint instrenum_var{
        bins flw_SNAN ={INSTRENUM_FLW} iff((rd_val[31:20]==12'h7fc && rd_val[19:0] != 0) || (rd_val[31:20]==12'hffc && rd_val[19:0] != 0));
    }

    fext__NAN_memory_operation_FSW_NCNAN: coverpoint instrenum_var{
        bins flw_SNAN ={INSTRENUM_FSW} iff((rd_val[31:20]==12'h7fc && rd_val[19:0] != 0) || (rd_val[31:20]==12'hffc && rd_val[19:0] != 0));
    }

    fext_NAN_arithmetic_rs1: coverpoint rs1_val[31:0]{
        bins pos_SNAN_rs1= {FEXT_SNAN};
        bins neg_SNAN_rs1={FEXT_SNAN_NEG};
        bins pos_QNAN_rs1={FEXT_QNAN};
        bins neg_QNAN_rs1={FEXT_QNAN_NEG};
        bins pos_NCNAN_rs1={[32'h7fc00001:32'h7fcfffff]};
        bins neg_NCNAN_rs1={[32'hffc00001:32'hffcfffff]}; 
    
    }
    fext_NAN_arithmetic_rs2: coverpoint rs2_val[31:0]{
        bins pos_SNAN_rs2={FEXT_SNAN};
        bins neg_SNAN_rs2={FEXT_SNAN_NEG};
        bins pos_QNAN_rs2={FEXT_QNAN};
        bins neg_QNAN_rs2={FEXT_QNAN_NEG};
        bins pos_NCNAN_rs2={[32'h7fc00001:32'h7fcfffff]};
        bins neg_NCNAN_rs2={[32'hffc00001:32'hffcfffff]}; 
    }
    fext_NAN_arithmetic_feq_flt_fle: coverpoint instrenum_var{
        bins feq_flt_fle[]={INSTRENUM_FLE_S, INSTRENUM_FLT_S, INSTRENUM_FEQ_S};
    }
    fext_NAN_arithmetic_feq_flt_fle_cross1: cross fext_NAN_arithmetic_feq_flt_fle,fext_NAN_arithmetic_rs1; 
    fext_NAN_arithmetic_feq_flt_fle_cross2: cross fext_NAN_arithmetic_feq_flt_fle,fext_NAN_arithmetic_rs2; // need to update this

    fext__NAN_arithmetic_fsub_fdiv: coverpoint instrenum_var{
        bins fdiv_fsub[]={INSTRENUM_FSUB_S,INSTRENUM_FDIV_S};
     }
    fext__NAN_arithmetic_fsub_fdiv_cross1: cross fext__NAN_arithmetic_fsub_fdiv, fext_NAN_arithmetic_rs1;
    fext__NAN_arithmetic_fsub_fdiv_cross2: cross fext__NAN_arithmetic_fsub_fdiv, fext_NAN_arithmetic_rs2;

    fext__Generic_special_NAN_ZERO_rs1: coverpoint instrenum_var{
        option.weight=0;
        bins scenario_13_1[]={INSTRENUM_FADD_S,INSTRENUM_FMUL_S,INSTRENUM_FSUB_S,INSTRENUM_FDIV_S,INSTRENUM_FSQRT_S,INSTRENUM_FMIN_S,INSTRENUM_FMAX_S} iff(rs2_val[31:0] == 0);
        
    }
    fext__Generic_special_NAN_ZERO_rs2: coverpoint instrenum_var{
        option.weight=0;
        bins scenario_13_1[]={INSTRENUM_FADD_S,INSTRENUM_FMUL_S,INSTRENUM_FSUB_S,INSTRENUM_FDIV_S,INSTRENUM_FSQRT_S,INSTRENUM_FMIN_S,INSTRENUM_FMAX_S} iff(rs1_val[31:0] == 0);
        
    }
    fext__Generic_special_cross_1: cross fext__Generic_special_NAN_ZERO_rs1, fext_NAN_arithmetic_rs1 ;
    fext__Generic_special_cross_2: cross fext__Generic_special_NAN_ZERO_rs2, fext_NAN_arithmetic_rs2;

    fext__Generic_special_Fmin_Fmax: coverpoint instrenum_var{
        option.weight=0;
        bins fmin_fmax_NAN[]={INSTRENUM_FMIN_S,INSTRENUM_FMAX_S}; 
    }
    fext__Generic_special_Fmin_Fmax_cross_1: cross fext__Generic_special_Fmin_Fmax, fext_NAN_arithmetic_rs1;
    fext__Generic_special_Fmin_Fmax_cross_2: cross fext__Generic_special_Fmin_Fmax, fext_NAN_arithmetic_rs2;

    fext__Generic_special_case3_rs1_diffvalues: coverpoint rs1_val[31:0]{
        option.weight=0;
        bins SNAN_rs1= {FEXT_SNAN};
        bins QNAN__rs1={FEXT_QNAN};
        bins NCNAN_rs1={[32'h7fc00001:32'h7fcfffff]};
        bins LN_rs1={FEXT_LN};
        bins SSN_rs1={FEXT_SSN};
        bins zero_rs1={FEXT_ZERO};
        bins infinity_rs1={FEXT_INFINITY};
    }
    fext__Generic_special_case3_rs2_diffvalues: coverpoint rs2_val[31:0]{

        option.weight=0;
        bins SNAN_rs2= {FEXT_SNAN};
        bins QNAN__rs2={FEXT_QNAN};
        bins NCNAN_rs2={[32'h7fc00001:32'h7fcfffff]};
        bins LN_rs2={FEXT_LN};
        bins SSN_rs2={FEXT_SSN};
        bins zero_rs2={FEXT_ZERO};
        bins infinity_rs2={FEXT_INFINITY};
    }
    fext__Generic_special_case3_ops: coverpoint instrenum_var{
        bins case3={INSTRENUM_FADD_S,INSTRENUM_FMUL_S,INSTRENUM_FSUB_S,INSTRENUM_FDIV_S,INSTRENUM_FSQRT_S,INSTRENUM_FMIN_S,INSTRENUM_FMAX_S,INSTRENUM_FMADD_S, INSTRENUM_FMSUB_S, INSTRENUM_FNMADD_S, INSTRENUM_FNMSUB_S}; // iff((rs1_val[31:0] || rs2_val[31:0]) == ((FEXT_SNAN) || (FEXT_SNAN_NEG) || (FEXT_QNAN) || (FEXT_QNAN_NEG) || (32'h7fcxxxxx) || (32'hffcxxxxx) || (FEXT_INFINITY) || (FEXT_INFINITY_NEG) || (32'h00000000) || (FEXT_ZERO_NEG) || (FEXT_LN) || (FEXT_LN_NEG) || (FEXT_SSN) || (FEXT_SSN_NEG)));
    }
   
    fext__Generic_special_case3_cross:cross fext__Generic_special_case3_ops, fext__Generic_special_case3_rs2_diffvalues,fext__Generic_special_case3_rs1_diffvalues;

     fext__Computational_fmin_fmax_zero: coverpoint instrenum_var{
        bins fmin_fmax_case1_1[]={INSTRENUM_FMIN_S,INSTRENUM_FMAX_S} iff((rs1_val[31:0]==32'h00000000) && (rs2_val[31:0]==32'h00000000)); 
        bins fmin_fmax_case1_2[]={INSTRENUM_FMIN_S,INSTRENUM_FMAX_S} iff((rs1_val[31:0]==32'h00000000) && (rs2_val[31:0]==FEXT_ZERO_NEG));
        bins fmin_fmax_case1_3[]={INSTRENUM_FMIN_S,INSTRENUM_FMAX_S} iff((rs1_val[31:0]==FEXT_ZERO_NEG) && (rs2_val[31:0]==FEXT_ZERO_NEG));
        bins fmin_fmax_case1_4[]={INSTRENUM_FMIN_S,INSTRENUM_FMAX_S} iff((rs1_val[31:0]==FEXT_ZERO_NEG) && (rs2_val[31:0]==32'h00000000));
     }

    fext__Computational_fmin_fmax_NCNAN: coverpoint instrenum_var{
        bins fmin_fmax_case2[]={INSTRENUM_FMIN_S,INSTRENUM_FMAX_S} iff(((rs1_val[31:20]==12'h7fc && rs1_val[19:0] != 0) && (rs2_val[31:20]==12'h7fc && rs2_val[19:0] != 0)) || ((rs1_val[31:20]==12'hffc && rs1_val[19:0] != 0) && (rs2_val[31:20]==12'hffc && rs2_val[19:0] != 0)));
  
    }

    fext__Computational_fmadd_fnmadd: coverpoint instrenum_var{
        bins fmadd_fmsub_fnmsub_fnmadd[]={INSTRENUM_FMADD_S, INSTRENUM_FMSUB_S, INSTRENUM_FNMADD_S, INSTRENUM_FNMSUB_S} iff(rs1_val[31:0] == rs2_val[31:0]);
    }


    fext__Conversion_move_fcvt: coverpoint instrenum_var{
        bins fcvt_diff_types_S[]={INSTRENUM_FCVT_L_S, INSTRENUM_FCVT_LU_S, INSTRENUM_FCVT_S_L,INSTRENUM_FCVT_S_LU,INSTRENUM_FCVT_S_W,INSTRENUM_FCVT_S_WU,INSTRENUM_FCVT_W_S,INSTRENUM_FCVT_WU_S};
    }

    fext__Conversion_move_x0: coverpoint instrenum_var{
        bins fcvt_S_X[]={INSTRENUM_FCVT_S_W,INSTRENUM_FCVT_S_L,INSTRENUM_FCVT_S_LU,INSTRENUM_FCVT_S_WU} iff(rs1==0);
    }

    fext__cross_conversions: coverpoint instrenum_var{
        bins cross_s[]={INSTRENUM_FCVT_D_S,INSTRENUM_FCVT_S_H};
    }

    fext__cross_extenstion_coversion: coverpoint instrenum_var{
        bins inject_instr_S[]={INSTRENUM_FSGNJ_S,INSTRENUM_FSGNJN_S,INSTRENUM_FSGNJX_S};

    }
    fext__cross_extenstion_coversion_cross_rs1: cross fext__cross_extenstion_coversion,fext_NAN_arithmetic_rs1;
    fext__cross_extenstion_coversion_cross_rs2: cross fext__cross_extenstion_coversion,fext_NAN_arithmetic_rs2;

    fext__Softfloat_fdiv: coverpoint instrenum_var{
        bins fdiv_s[]={INSTRENUM_FDIV_S,INSTRENUM_FSQRT_S};
    }
    fext__Softfloat_fdiv_cross_roundingmodes: cross fext__Softfloat_fdiv,fext__rounding_modes_static_legal_rm,fext__Generic_special_case3_rs1_diffvalues;

    fext__Softfloat_convert_cross_roundmodes: cross fext__Conversion_move_fcvt,fext__rounding_modes_static_legal_rm;
    fext__Softfloat_convert_cross_roundmodes_dyn: cross fext__Conversion_move_fcvt,fext__rounding_modes_dynamic_legal;
endgroup

`endif