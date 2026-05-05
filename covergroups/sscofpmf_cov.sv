//  SPDX-FileCopyrightText: © 2026 Tenstorrent AI ULC
//  SPDX-License-Identifier: Apache-2.0
`ifndef COVERAGE_UNSUPPORTED

import cp_pkg::*;

covergroup sscofpmf__cg with function sample(csr_cov_sample i_csr_cov_sample);
    option.per_instance = 1;
    option.name = "cg_sscofpmf";
    
    sscofpmf__inh__cp_mcountinhibit_cy: coverpoint i_csr_cov_sample.mcountinhibit_csr_inst.cy;
    sscofpmf__inh__cp_mcountinhibit_ir: coverpoint i_csr_cov_sample.mcountinhibit_csr_inst.ir;
    sscofpmf__inh__cp_mcountinhibit_3:  coverpoint i_csr_cov_sample.mcountinhibit_csr_inst.hpm3;
    sscofpmf__inh__cp_mcountinhibit_4:  coverpoint i_csr_cov_sample.mcountinhibit_csr_inst.hpm4;
    sscofpmf__inh__cp_mcountinhibit_5:  coverpoint i_csr_cov_sample.mcountinhibit_csr_inst.hpm5;
    sscofpmf__inh__cp_mcountinhibit_6:  coverpoint i_csr_cov_sample.mcountinhibit_csr_inst.hpm6;
    sscofpmf__inh__cp_mcountinhibit_7:  coverpoint i_csr_cov_sample.mcountinhibit_csr_inst.hpm7;
    sscofpmf__inh__cp_mcountinhibit_8:  coverpoint i_csr_cov_sample.mcountinhibit_csr_inst.hpm8;
    sscofpmf__inh__cp_mcountinhibit_9:  coverpoint i_csr_cov_sample.mcountinhibit_csr_inst.hpm9;
    sscofpmf__inh__cp_mcountinhibit_10: coverpoint i_csr_cov_sample.mcountinhibit_csr_inst.hpm10;

    sscofpmf__inh__cp_mhpmevent3_eventid:  coverpoint  i_csr_cov_sample.mhpmevent3_csr_inst.mhpmevent3   iff(i_csr_cov_sample.mcountinhibit_csr_inst.hpm3  == 0) {bins eventid_not_zero[1] = {[1:$]};}
    sscofpmf__inh__cp_mhpmevent4_eventid:  coverpoint  i_csr_cov_sample.mhpmevent4_csr_inst.mhpmevent4   iff(i_csr_cov_sample.mcountinhibit_csr_inst.hpm4  == 0) {bins eventid_not_zero[1] = {[1:$]};}
    sscofpmf__inh__cp_mhpmevent5_eventid:  coverpoint  i_csr_cov_sample.mhpmevent5_csr_inst.mhpmevent5   iff(i_csr_cov_sample.mcountinhibit_csr_inst.hpm5  == 0) {bins eventid_not_zero[1] = {[1:$]};}
    sscofpmf__inh__cp_mhpmevent6_eventid:  coverpoint  i_csr_cov_sample.mhpmevent6_csr_inst.mhpmevent6   iff(i_csr_cov_sample.mcountinhibit_csr_inst.hpm6  == 0) {bins eventid_not_zero[1] = {[1:$]};}
    sscofpmf__inh__cp_mhpmevent7_eventid:  coverpoint  i_csr_cov_sample.mhpmevent7_csr_inst.mhpmevent7   iff(i_csr_cov_sample.mcountinhibit_csr_inst.hpm7  == 0) {bins eventid_not_zero[1] = {[1:$]};}
    sscofpmf__inh__cp_mhpmevent8_eventid:  coverpoint  i_csr_cov_sample.mhpmevent8_csr_inst.mhpmevent8   iff(i_csr_cov_sample.mcountinhibit_csr_inst.hpm8  == 0) {bins eventid_not_zero[1] = {[1:$]};}
    sscofpmf__inh__cp_mhpmevent9_eventid:  coverpoint  i_csr_cov_sample.mhpmevent9_csr_inst.mhpmevent9   iff(i_csr_cov_sample.mcountinhibit_csr_inst.hpm9  == 0) {bins eventid_not_zero[1] = {[1:$]};}
    sscofpmf__inh__cp_mhpmevent10_eventid: coverpoint  i_csr_cov_sample.mhpmevent10_csr_inst.mhpmevent10 iff(i_csr_cov_sample.mcountinhibit_csr_inst.hpm10 == 0) {bins eventid_not_zero[1] = {[1:$]};}

    sscofpmf__inh__cp_mhpmevent3_minh:  coverpoint  i_csr_cov_sample.mhpmevent3_csr_inst.minh  iff(i_csr_cov_sample.mcountinhibit_csr_inst.hpm3  == 0 && privilegemode_var == PRIVILEGEMODE_MACHINE);
    sscofpmf__inh__cp_mhpmevent4_minh:  coverpoint  i_csr_cov_sample.mhpmevent4_csr_inst.minh  iff(i_csr_cov_sample.mcountinhibit_csr_inst.hpm4  == 0 && privilegemode_var == PRIVILEGEMODE_MACHINE);
    sscofpmf__inh__cp_mhpmevent5_minh:  coverpoint  i_csr_cov_sample.mhpmevent5_csr_inst.minh  iff(i_csr_cov_sample.mcountinhibit_csr_inst.hpm5  == 0 && privilegemode_var == PRIVILEGEMODE_MACHINE);
    sscofpmf__inh__cp_mhpmevent6_minh:  coverpoint  i_csr_cov_sample.mhpmevent6_csr_inst.minh  iff(i_csr_cov_sample.mcountinhibit_csr_inst.hpm6  == 0 && privilegemode_var == PRIVILEGEMODE_MACHINE);
    sscofpmf__inh__cp_mhpmevent7_minh:  coverpoint  i_csr_cov_sample.mhpmevent7_csr_inst.minh  iff(i_csr_cov_sample.mcountinhibit_csr_inst.hpm7  == 0 && privilegemode_var == PRIVILEGEMODE_MACHINE);
    sscofpmf__inh__cp_mhpmevent8_minh:  coverpoint  i_csr_cov_sample.mhpmevent8_csr_inst.minh  iff(i_csr_cov_sample.mcountinhibit_csr_inst.hpm8  == 0 && privilegemode_var == PRIVILEGEMODE_MACHINE);
    sscofpmf__inh__cp_mhpmevent9_minh:  coverpoint  i_csr_cov_sample.mhpmevent9_csr_inst.minh  iff(i_csr_cov_sample.mcountinhibit_csr_inst.hpm9  == 0 && privilegemode_var == PRIVILEGEMODE_MACHINE);
    sscofpmf__inh__cp_mhpmevent10_minh: coverpoint i_csr_cov_sample.mhpmevent10_csr_inst.minh iff(i_csr_cov_sample.mcountinhibit_csr_inst.hpm10 == 0 && privilegemode_var == PRIVILEGEMODE_MACHINE);

    sscofpmf__inh__cp_mhpmevent3_sinh:  coverpoint i_csr_cov_sample.mhpmevent3_csr_inst.sinh  iff(i_csr_cov_sample.mcountinhibit_csr_inst.hpm3  == 0 && privilegemode_var == PRIVILEGEMODE_SUPERVISOR);
    sscofpmf__inh__cp_mhpmevent4_sinh:  coverpoint i_csr_cov_sample.mhpmevent4_csr_inst.sinh  iff(i_csr_cov_sample.mcountinhibit_csr_inst.hpm4  == 0 && privilegemode_var == PRIVILEGEMODE_SUPERVISOR);
    sscofpmf__inh__cp_mhpmevent5_sinh:  coverpoint i_csr_cov_sample.mhpmevent5_csr_inst.sinh  iff(i_csr_cov_sample.mcountinhibit_csr_inst.hpm5  == 0 && privilegemode_var == PRIVILEGEMODE_SUPERVISOR);
    sscofpmf__inh__cp_mhpmevent6_sinh:  coverpoint i_csr_cov_sample.mhpmevent6_csr_inst.sinh  iff(i_csr_cov_sample.mcountinhibit_csr_inst.hpm6  == 0 && privilegemode_var == PRIVILEGEMODE_SUPERVISOR);
    sscofpmf__inh__cp_mhpmevent7_sinh:  coverpoint i_csr_cov_sample.mhpmevent7_csr_inst.sinh  iff(i_csr_cov_sample.mcountinhibit_csr_inst.hpm7  == 0 && privilegemode_var == PRIVILEGEMODE_SUPERVISOR);
    sscofpmf__inh__cp_mhpmevent8_sinh:  coverpoint i_csr_cov_sample.mhpmevent8_csr_inst.sinh  iff(i_csr_cov_sample.mcountinhibit_csr_inst.hpm8  == 0 && privilegemode_var == PRIVILEGEMODE_SUPERVISOR);
    sscofpmf__inh__cp_mhpmevent9_sinh:  coverpoint i_csr_cov_sample.mhpmevent9_csr_inst.sinh  iff(i_csr_cov_sample.mcountinhibit_csr_inst.hpm9  == 0 && privilegemode_var == PRIVILEGEMODE_SUPERVISOR);
    sscofpmf__inh__cp_mhpmevent10_sinh: coverpoint i_csr_cov_sample.mhpmevent10_csr_inst.sinh iff(i_csr_cov_sample.mcountinhibit_csr_inst.hpm10 == 0 && privilegemode_var == PRIVILEGEMODE_SUPERVISOR);

    sscofpmf__inh__cp_mhpmevent3_uinh:  coverpoint i_csr_cov_sample.mhpmevent3_csr_inst.uinh  iff(i_csr_cov_sample.mcountinhibit_csr_inst.hpm3  == 0 && privilegemode_var == PRIVILEGEMODE_USER);
    sscofpmf__inh__cp_mhpmevent4_uinh:  coverpoint i_csr_cov_sample.mhpmevent4_csr_inst.uinh  iff(i_csr_cov_sample.mcountinhibit_csr_inst.hpm4  == 0 && privilegemode_var == PRIVILEGEMODE_USER);
    sscofpmf__inh__cp_mhpmevent5_uinh:  coverpoint i_csr_cov_sample.mhpmevent5_csr_inst.uinh  iff(i_csr_cov_sample.mcountinhibit_csr_inst.hpm5  == 0 && privilegemode_var == PRIVILEGEMODE_USER);
    sscofpmf__inh__cp_mhpmevent6_uinh:  coverpoint i_csr_cov_sample.mhpmevent6_csr_inst.uinh  iff(i_csr_cov_sample.mcountinhibit_csr_inst.hpm6  == 0 && privilegemode_var == PRIVILEGEMODE_USER);
    sscofpmf__inh__cp_mhpmevent7_uinh:  coverpoint i_csr_cov_sample.mhpmevent7_csr_inst.uinh  iff(i_csr_cov_sample.mcountinhibit_csr_inst.hpm7  == 0 && privilegemode_var == PRIVILEGEMODE_USER);
    sscofpmf__inh__cp_mhpmevent8_uinh:  coverpoint i_csr_cov_sample.mhpmevent8_csr_inst.uinh  iff(i_csr_cov_sample.mcountinhibit_csr_inst.hpm8  == 0 && privilegemode_var == PRIVILEGEMODE_USER);
    sscofpmf__inh__cp_mhpmevent9_uinh:  coverpoint i_csr_cov_sample.mhpmevent9_csr_inst.uinh  iff(i_csr_cov_sample.mcountinhibit_csr_inst.hpm9  == 0 && privilegemode_var == PRIVILEGEMODE_USER);
    sscofpmf__inh__cp_mhpmevent10_uinh: coverpoint i_csr_cov_sample.mhpmevent10_csr_inst.uinh iff(i_csr_cov_sample.mcountinhibit_csr_inst.hpm10 == 0 && privilegemode_var == PRIVILEGEMODE_USER);

    sscofpmf__inh__cp_mhpmevent3_vsinh:  coverpoint i_csr_cov_sample.mhpmevent3_csr_inst.vsinh  iff(i_csr_cov_sample.mcountinhibit_csr_inst.hpm3  == 0 && privilegemode_var == PRIVILEGEMODE_SUPERVISOR && VirtualMode == 1);
    sscofpmf__inh__cp_mhpmevent4_vsinh:  coverpoint i_csr_cov_sample.mhpmevent4_csr_inst.vsinh  iff(i_csr_cov_sample.mcountinhibit_csr_inst.hpm4  == 0 && privilegemode_var == PRIVILEGEMODE_SUPERVISOR && VirtualMode == 1);
    sscofpmf__inh__cp_mhpmevent5_vsinh:  coverpoint i_csr_cov_sample.mhpmevent5_csr_inst.vsinh  iff(i_csr_cov_sample.mcountinhibit_csr_inst.hpm5  == 0 && privilegemode_var == PRIVILEGEMODE_SUPERVISOR && VirtualMode == 1);
    sscofpmf__inh__cp_mhpmevent6_vsinh:  coverpoint i_csr_cov_sample.mhpmevent6_csr_inst.vsinh  iff(i_csr_cov_sample.mcountinhibit_csr_inst.hpm6  == 0 && privilegemode_var == PRIVILEGEMODE_SUPERVISOR && VirtualMode == 1);
    sscofpmf__inh__cp_mhpmevent7_vsinh:  coverpoint i_csr_cov_sample.mhpmevent7_csr_inst.vsinh  iff(i_csr_cov_sample.mcountinhibit_csr_inst.hpm7  == 0 && privilegemode_var == PRIVILEGEMODE_SUPERVISOR && VirtualMode == 1);
    sscofpmf__inh__cp_mhpmevent8_vsinh:  coverpoint i_csr_cov_sample.mhpmevent8_csr_inst.vsinh  iff(i_csr_cov_sample.mcountinhibit_csr_inst.hpm8  == 0 && privilegemode_var == PRIVILEGEMODE_SUPERVISOR && VirtualMode == 1);
    sscofpmf__inh__cp_mhpmevent9_vsinh:  coverpoint i_csr_cov_sample.mhpmevent9_csr_inst.vsinh  iff(i_csr_cov_sample.mcountinhibit_csr_inst.hpm9  == 0 && privilegemode_var == PRIVILEGEMODE_SUPERVISOR && VirtualMode == 1);
    sscofpmf__inh__cp_mhpmevent10_vsinh: coverpoint i_csr_cov_sample.mhpmevent10_csr_inst.vsinh iff(i_csr_cov_sample.mcountinhibit_csr_inst.hpm10 == 0 && privilegemode_var == PRIVILEGEMODE_SUPERVISOR && VirtualMode == 1);

    sscofpmf__inh__cp_mhpmevent3_vuinh:  coverpoint i_csr_cov_sample.mhpmevent3_csr_inst.vuinh  iff(i_csr_cov_sample.mcountinhibit_csr_inst.hpm3  == 0 && privilegemode_var == PRIVILEGEMODE_USER && VirtualMode == 1);
    sscofpmf__inh__cp_mhpmevent4_vuinh:  coverpoint i_csr_cov_sample.mhpmevent4_csr_inst.vuinh  iff(i_csr_cov_sample.mcountinhibit_csr_inst.hpm4  == 0 && privilegemode_var == PRIVILEGEMODE_USER && VirtualMode == 1);
    sscofpmf__inh__cp_mhpmevent5_vuinh:  coverpoint i_csr_cov_sample.mhpmevent5_csr_inst.vuinh  iff(i_csr_cov_sample.mcountinhibit_csr_inst.hpm5  == 0 && privilegemode_var == PRIVILEGEMODE_USER && VirtualMode == 1);
    sscofpmf__inh__cp_mhpmevent6_vuinh:  coverpoint i_csr_cov_sample.mhpmevent6_csr_inst.vuinh  iff(i_csr_cov_sample.mcountinhibit_csr_inst.hpm6  == 0 && privilegemode_var == PRIVILEGEMODE_USER && VirtualMode == 1);
    sscofpmf__inh__cp_mhpmevent7_vuinh:  coverpoint i_csr_cov_sample.mhpmevent7_csr_inst.vuinh  iff(i_csr_cov_sample.mcountinhibit_csr_inst.hpm7  == 0 && privilegemode_var == PRIVILEGEMODE_USER && VirtualMode == 1);
    sscofpmf__inh__cp_mhpmevent8_vuinh:  coverpoint i_csr_cov_sample.mhpmevent8_csr_inst.vuinh  iff(i_csr_cov_sample.mcountinhibit_csr_inst.hpm8  == 0 && privilegemode_var == PRIVILEGEMODE_USER && VirtualMode == 1);
    sscofpmf__inh__cp_mhpmevent9_vuinh:  coverpoint i_csr_cov_sample.mhpmevent9_csr_inst.vuinh  iff(i_csr_cov_sample.mcountinhibit_csr_inst.hpm9  == 0 && privilegemode_var == PRIVILEGEMODE_USER && VirtualMode == 1);
    sscofpmf__inh__cp_mhpmevent10_vuinh: coverpoint i_csr_cov_sample.mhpmevent10_csr_inst.vuinh iff(i_csr_cov_sample.mcountinhibit_csr_inst.hpm10 == 0 && privilegemode_var == PRIVILEGEMODE_USER && VirtualMode == 1);

    sscofpmf__of__cp_mhpmevent3_of_csr_wr:  coverpoint rs2_val[63] iff(rs2 == 64'h323 && rs1_val[63] == 1 && (instrenum_var == INSTRENUM_CSRRS || instrenum_var == INSTRENUM_CSRRW || instrenum_var == INSTRENUM_CSRRSI || instrenum_var == INSTRENUM_CSRRWI));
    sscofpmf__of__cp_mhpmevent4_of_csr_wr:  coverpoint rs2_val[63] iff(rs2 == 64'h324 && rs1_val[63] == 1 && (instrenum_var == INSTRENUM_CSRRS || instrenum_var == INSTRENUM_CSRRW || instrenum_var == INSTRENUM_CSRRSI || instrenum_var == INSTRENUM_CSRRWI));
    sscofpmf__of__cp_mhpmevent5_of_csr_wr:  coverpoint rs2_val[63] iff(rs2 == 64'h325 && rs1_val[63] == 1 && (instrenum_var == INSTRENUM_CSRRS || instrenum_var == INSTRENUM_CSRRW || instrenum_var == INSTRENUM_CSRRSI || instrenum_var == INSTRENUM_CSRRWI));
    sscofpmf__of__cp_mhpmevent6_of_csr_wr:  coverpoint rs2_val[63] iff(rs2 == 64'h326 && rs1_val[63] == 1 && (instrenum_var == INSTRENUM_CSRRS || instrenum_var == INSTRENUM_CSRRW || instrenum_var == INSTRENUM_CSRRSI || instrenum_var == INSTRENUM_CSRRWI));
    sscofpmf__of__cp_mhpmevent7_of_csr_wr:  coverpoint rs2_val[63] iff(rs2 == 64'h327 && rs1_val[63] == 1 && (instrenum_var == INSTRENUM_CSRRS || instrenum_var == INSTRENUM_CSRRW || instrenum_var == INSTRENUM_CSRRSI || instrenum_var == INSTRENUM_CSRRWI));
    sscofpmf__of__cp_mhpmevent8_of_csr_wr:  coverpoint rs2_val[63] iff(rs2 == 64'h328 && rs1_val[63] == 1 && (instrenum_var == INSTRENUM_CSRRS || instrenum_var == INSTRENUM_CSRRW || instrenum_var == INSTRENUM_CSRRSI || instrenum_var == INSTRENUM_CSRRWI));
    sscofpmf__of__cp_mhpmevent9_of_csr_wr:  coverpoint rs2_val[63] iff(rs2 == 64'h329 && rs1_val[63] == 1 && (instrenum_var == INSTRENUM_CSRRS || instrenum_var == INSTRENUM_CSRRW || instrenum_var == INSTRENUM_CSRRSI || instrenum_var == INSTRENUM_CSRRWI));
    sscofpmf__of__cp_mhpmevent10_of_csr_wr: coverpoint rs2_val[63] iff(rs2 == 64'h32a && rs1_val[63] == 1 && (instrenum_var == INSTRENUM_CSRRS || instrenum_var == INSTRENUM_CSRRW || instrenum_var == INSTRENUM_CSRRSI || instrenum_var == INSTRENUM_CSRRWI));

    sscofpmf__intr__cp_lcofip: coverpoint i_csr_cov_sample.mip_csr_inst.lcofip{
        bins lcofip_set_using_csr     = (0=>1) iff ((instrenum_var == INSTRENUM_CSRRS || instrenum_var == INSTRENUM_CSRRW || instrenum_var == INSTRENUM_CSRRSI || instrenum_var == INSTRENUM_CSRRWI) 
                                                     && (csr_op2_var == CSR_OP2_MIP || csr_op2_var == CSR_OP2_SIP) 
                                                     && (rs2_val[13] == 1));
        bins lcofip_set_using_of_bit  = (0=>1) iff ((instrenum_var != INSTRENUM_CSRRS || instrenum_var != INSTRENUM_CSRRW || instrenum_var != INSTRENUM_CSRRSI || instrenum_var != INSTRENUM_CSRRWI));
    }

    sscofpmf__of__cp_scountovf_hpm3: coverpoint rs2_val[3] iff(rs2 == CSRENUM_SCOUNTOVF);
    sscofpmf__of__cp_scountovf_hpm4: coverpoint rs2_val[4] iff(rs2 == CSRENUM_SCOUNTOVF);
    sscofpmf__of__cp_scountovf_hpm5: coverpoint rs2_val[5] iff(rs2 == CSRENUM_SCOUNTOVF);
    sscofpmf__of__cp_scountovf_hpm6: coverpoint rs2_val[6] iff(rs2 == CSRENUM_SCOUNTOVF);
    sscofpmf__of__cp_scountovf_hpm7: coverpoint rs2_val[7] iff(rs2 == CSRENUM_SCOUNTOVF);
    sscofpmf__of__cp_scountovf_hpm8: coverpoint rs2_val[8] iff(rs2 == CSRENUM_SCOUNTOVF);
    sscofpmf__of__cp_scountovf_hpm9: coverpoint rs2_val[9] iff(rs2 == CSRENUM_SCOUNTOVF);
    sscofpmf__of__cp_scountovf_hpm10: coverpoint rs2_val[10] iff(rs2 == CSRENUM_SCOUNTOVF);
    
    intr__gen__cp_intr_tkn: coverpoint interrupt_var iff(interrupt_taken && i_csr_cov_sample.mideleg_csr_inst.mideleg[13] == 1){
        bins LCOFI_S = {INTERRUPT_LCOF} iff(i_csr_cov_sample.mcounteren_csr_inst.hpm3  == 0 && i_csr_cov_sample.mhpmevent3_csr_inst.of  == 1 ||
                                            i_csr_cov_sample.mcounteren_csr_inst.hpm4  == 0 && i_csr_cov_sample.mhpmevent4_csr_inst.of  == 1 ||
                                            i_csr_cov_sample.mcounteren_csr_inst.hpm5  == 0 && i_csr_cov_sample.mhpmevent5_csr_inst.of  == 1 ||
                                            i_csr_cov_sample.mcounteren_csr_inst.hpm6  == 0 && i_csr_cov_sample.mhpmevent6_csr_inst.of  == 1 ||
                                            i_csr_cov_sample.mcounteren_csr_inst.hpm7  == 0 && i_csr_cov_sample.mhpmevent7_csr_inst.of  == 1 ||
                                            i_csr_cov_sample.mcounteren_csr_inst.hpm8  == 0 && i_csr_cov_sample.mhpmevent8_csr_inst.of  == 1 ||
                                            i_csr_cov_sample.mcounteren_csr_inst.hpm9  == 0 && i_csr_cov_sample.mhpmevent9_csr_inst.of  == 1 ||
                                            i_csr_cov_sample.mcounteren_csr_inst.hpm10 == 0 && i_csr_cov_sample.mhpmevent10_csr_inst.of == 1);
    }

endgroup

`endif
