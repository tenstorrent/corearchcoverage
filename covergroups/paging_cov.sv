//  SPDX-FileCopyrightText: © 2026 Tenstorrent AI ULC
//  SPDX-License-Identifier: Apache-2.0
`ifndef COVERAGE_UNSUPPORTED

import cp_pkg::*;
import user_cov_common::*;

covergroup paging__cg with function sample(
        csr_cov_sample csr_access
);

    option.per_instance = 1;
    option.name         = "cg__paging";
    option.comment      = "Covergroups for Paging TP";

    paging__accesstype__cp_load: coverpoint instrenum_var {
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
    paging__accesstype__cp_store: coverpoint instrenum_var {
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

    paging__accesstype__cp_atomics: coverpoint aext_var{
        bins amo = {AEXT_AMOADD_D,AEXT_AMOADD_W,AEXT_AMOAND_D,AEXT_AMOAND_W,AEXT_AMOMAX_D,AEXT_AMOMAX_W,AEXT_AMOMAXU_D,AEXT_AMOMAXU_W,AEXT_AMOMIN_D,AEXT_AMOMIN_W,AEXT_AMOMINU_D,AEXT_AMOMINU_W,AEXT_AMOOR_D,AEXT_AMOOR_W,AEXT_AMOSWAP_D,AEXT_AMOSWAP_W,AEXT_AMOXOR_D,AEXT_AMOXOR_W};
        bins lr  = {AEXT_LR_D,AEXT_LR_W};
        bins sc  = {AEXT_SC_D,AEXT_SC_W};
    }

    paging__satp__cp_modes: coverpoint csr_access.satp_csr_inst.mode{
        bins legal_satp_bare_mode           = {0};
        bins legal_satp_modes[]             = {[8:10]};
        bins bare_to_legal_nonbare_mode     = (0 => [8:10]);
        bins legal_nonbare_to_bare_mode     = ([8:10] => 0);
        bins legal_to_legal_mode            = ([8:9] => 10),([9:10] => 8),(8,10 => 9);
    }
    paging__satp__cp_asid: coverpoint csr_access.satp_csr_inst.asid{
        bins asid_0x0_to_0xf        = {[16'b0000000000000000:16'b0000000000001111]};
        bins asid_0x10_to_0xff      = {[16'b0000000000010000:16'b0000000011111111]};
        bins asid_0x100_to_0xfff    = {[16'b0000000100000000:16'b0000111111111111]};
        bins asid_0x1000_to_0xffff  = {[16'b0001000000000000:16'b1111111111111111]};
    }  
    paging__satp__cp_ppn: coverpoint csr_access.satp_csr_inst.ppn{
        bins ppn_0x0_0xffff                   = {[44'b00000000000000000000000000000000000000000000:44'b00000000000000000000000000001111111111111111]};
        bins ppn_0x10000_0xffffff             = {[44'b00000000000000000000000000010000000000000000:44'b00000000000000000000111111111111111111111111]};
        bins ppn_0x1000000_0xffffffff         = {[44'b00000000000000000001000000000000000000000000:44'b00000000000011111111111111111111111111111111]};
        bins ppn_0x100000000_0xffffffffffff   = {[44'b00000000000100000000000000000000000000000000:44'b11111111111111111111111111111111111111111111]};
    }
    paging__satp_cr_baremode_nonzero_ppnandasid: coverpoint csr_access.satp_csr_inst.mode iff( (csr_access.satp_csr_inst.asid != '0) || (csr_access.satp_csr_inst.ppn != '0)) {
        bins baremode_nonzero_ppnandasid = {0};
    }

    paging__ptw__dpte_leaf_ppn_lvl2_align: coverpoint DPTE_LeafPpn[8:0] {
        bins aligned        = {9'b000000000};
        bins non_aligned    = {[9'b000000001:9'b111111111]};
    }
    paging__ptw__dpte_leaf_ppn_lvl3_align: coverpoint DPTE_LeafPpn[17:0] {
        bins aligned        = {18'b000000000000000000};
        bins non_aligned    = {[18'b000000000000000001:18'b111111111111111111]};
    }
    paging__ptw__dpte_leaf_ppn_lvl4_align: coverpoint DPTE_LeafPpn[26:0] {
        bins aligned        = {27'b000000000000000000000000000};
        bins non_aligned    = {[27'b000000000000000000000000001:27'b111111111111111111111111111]};
    }
    paging__ptw__dpte_leaf_ppn_lvl5_align: coverpoint DPTE_LeafPpn[35:0]{
        bins aligned        = {36'b000000000000000000000000000000000000};
        bins non_aligned    = {[36'b000000000000000000000000000000000001:36'b111111111111111111111111111111111111]};
    }

    paging__ptw__ipte_leaf_ppn_lvl2_align: coverpoint FPTE_LeafPpn[8:0] {
        bins aligned        = {9'b000000000};
        bins non_aligned    = {[9'b000000001:9'b111111111]};
    }
    paging__ptw__ipte_leaf_ppn_lvl3_align: coverpoint FPTE_LeafPpn[17:0] {
        bins aligned        = {18'b000000000000000000};
        bins non_aligned    = {[18'b000000000000000001:18'b111111111111111111]};
    }
    paging__ptw__ipte_leaf_ppn_lvl4_align: coverpoint FPTE_LeafPpn[26:0] {
        bins aligned        = {27'b000000000000000000000000000};
        bins non_aligned    = {[27'b000000000000000000000000001:27'b111111111111111111111111111]};
    }
    paging__ptw__ipte_leaf_ppn_lvl5_align: coverpoint FPTE_LeafPpn[35:0]{
        bins aligned        = {36'b000000000000000000000000000000000000};
        bins non_aligned    = {[36'b000000000000000000000000000000000001:36'b111111111111111111111111111111111111]};
    }    

    paging__pagesize__cp_iside_paginglevel :        coverpoint fpagesize_var;
    paging__pagesize__cp_dside_paginglevel :        coverpoint dpagesize_var;
    paging__pagesize__cp_iside_cross_paginglevel :  coverpoint fpagecrosssize_var;
    paging__pagesize__cp_dside_cross_paginglevel :  coverpoint dpagecrosssize_var;
    
    paging__ptw__cp_iside_leaf_ptw_read:        coverpoint FPTE_LeafR;
    paging__ptw__cp_iside_leaf_ptw_write:       coverpoint FPTE_LeafW;
    paging__ptw__cp_iside_leaf_ptw_exec:        coverpoint FPTE_LeafX;
    paging__ptw__cp_iside_leaf_ptw_global:      coverpoint FPTE_LeafG;
    paging__ptw__cp_iside_leaf_ptw_user:        coverpoint FPTE_LeafU;
    paging__ptw__cp_iside_leaf_ptw_valid:       coverpoint FPTE_LeafV;
    paging__ptw__cp_iside_leaf_ptw_access:      coverpoint FPTE_LeafA;
    paging__ptw__cp_iside_leaf_ptw_dirty:       coverpoint FPTE_LeafD;

    paging__ptw__cp_dside_leaf_ptw_read:        coverpoint DPTE_LeafR;
    paging__ptw__cp_dside_leaf_ptw_write:       coverpoint DPTE_LeafW;
    paging__ptw__cp_dside_leaf_ptw_exec:        coverpoint DPTE_LeafX;
    paging__ptw__cp_dside_leaf_ptw_global:      coverpoint DPTE_LeafG;
    paging__ptw__cp_dside_leaf_ptw_user:        coverpoint DPTE_LeafU;
    paging__ptw__cp_dside_leaf_ptw_valid:       coverpoint DPTE_LeafV;
    paging__ptw__cp_dside_leaf_ptw_access:      coverpoint DPTE_LeafA;
    paging__ptw__cp_dside_leaf_ptw_dirty:       coverpoint DPTE_LeafD;

    paging__ptw__cp_iside_nonleaf_ptw_global:   coverpoint FPTE_NonLeafG;
    paging__ptw__cp_iside_nonleaf_ptw_valid:    coverpoint FPTE_NonLeafV;

    paging__ptw__cp_dside_nonleaf_ptw_global:   coverpoint DPTE_NonLeafG;
    paging__ptw__cp_dside_nonleaf_ptw_valid:    coverpoint DPTE_NonLeafV;

    paging__ptw__cp_iside_leaf_rsw: coverpoint FPTE_LeafRsw {
        bins rsw_i_leaf_nonzero         = {[1:$]};
    }
    paging__ptw__cp_iside_nonleaf_rsw: coverpoint FPTE_NonLeafRsw {
        bins rsw_i_nonleaf_nonzero      = {[1:$]};
    }
    paging__ptw__cp_iside_leaf_res: coverpoint FPTE_LeafRes {
        bins res_i_leaf_nonzero         = {[1:$]};
    }
    paging__ptw__cp_iside_nonleaf_res: coverpoint FPTE_NonLeafRes {
        bins res_i_nonleaf_nonzero      = {[1:$]};
    }
    paging__ptw__cp_iside_leaf_pbmt: coverpoint FPTE_LeafPbmt {
        bins pbmt_i_leaf_reserved       = {2'b11};
    }
    paging__ptw__cp_iside_nonleaf_pbmt: coverpoint FPTE_NonLeafPbmt{
        bins pbmt_i_nonleaf_reserved    = {[2'b01:2'b11]};
    }

    paging__ptw__cp_dside_leaf_rsw: coverpoint DPTE_LeafRsw {
        bins rsw_d_leaf_nonzero         = {[1:$]};
    }
    paging__ptw__cp_dside_nonleaf_rsw: coverpoint DPTE_NonLeafRsw {
        bins rsw_d_nonleaf_nonzero      = {[1:$]};
    }
    paging__ptw__cp_dside_leaf_res: coverpoint DPTE_LeafRes {
        bins res_d_leaf_nonzero         = {[1:$]};
    }
    paging__ptw__cp_dside_nonleaf_res: coverpoint DPTE_NonLeafRes {
        bins res_d_nonleaf_nonzero      = {[1:$]};
    }
    paging__ptw__cp_dside_leaf_pbmt: coverpoint DPTE_LeafPbmt {
        bins pbmt_d_leaf_reserved       = {2'b11};
    }
    paging__ptw__cp_dside_nonleaf_pbmt: coverpoint DPTE_NonLeafPbmt{
        bins pbmt_d_nonleaf_reserved    = {[2'b01:2'b11]};
    }

    paging__ptw__cp_virtual_pc: coverpoint VirtPc {
        bins virtualpc_bit_0_to_31                  = {[64'b00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000:64'b00000000_00000000_00000000_00000000_01111111_11111111_11111111_11111111]};
        bins virtualpc_bit_32_to_52                 = {[64'b00000000_00000000_00000000_00000000_10000000_00000000_00000000_00000000:64'b00000000_00001111_11111111_11111111_11111111_11111111_11111111_11111111]};
        bins virtualpc_bit_53_to_57                 = {[64'b00000000_00010000_00000000_00000000_00000000_00000000_00000000_00000000:64'b00000001_11111111_11111111_11111111_11111111_11111111_11111111_11111111]};
        bins virtualpc_bit_58_to_64                 = {[64'b00000010_00000000_00000000_00000000_00000000_00000000_00000000_00000000:64'b11111111_11111111_11111111_11111111_11111111_11111111_11111111_11111111]};
    } 

    paging__ptw__cp_illegal_virtualpc_in_machinemode_bit: coverpoint VirtPc iff(privilegemode_var==PRIVILEGEMODE_MACHINE) {
        bins illegal_virtualpc_in_machinemode_bit   = {[64'b00000000_00010000_00000000_00000000_00000000_00000000_00000000_00000000:64'b11111111_11111111_11111111_11111111_11111111_11111111_11111111_11111111]};
    } 

    paging__ptw__cp_virtual_pc_bitsel_38: coverpoint VirtPc[38];
    paging__ptw__cp_virtual_pc_bitsel_47: coverpoint VirtPc[47];
    paging__ptw__cp_virtual_pc_bitsel_56: coverpoint VirtPc[56];
    paging__ptw__cp_virtual_pc_bitsel_signextbits_sv39: coverpoint VirtPc[63:39]{
        option.auto_bin_max     = 1;
        ignore_bins legal_pc    = {0,25'b1_1111_1111_1111_1111_1111_1111};
    }
    paging__ptw__cp_virtual_pc_bitsel_signextbits_sv48: coverpoint VirtPc[63:48]{
        option.auto_bin_max     = 1;
        ignore_bins legal_pc    = {0,16'b1111_1111_1111_1111};
    }
    paging__ptw__cp_virtual_pc_bitsel_signextbits_sv57: coverpoint VirtPc[63:57]{
        option.auto_bin_max     = 1;
        ignore_bins legal_pc    = {0,7'b111_1111};
    }
    paging__ptw__cp_virtual_pc_bitsel_signextbits_baremode: coverpoint VirtPc[63:56]{
        option.auto_bin_max     = 1;
        ignore_bins legal_pc    = {0};
    }

    paging__ptw__cp_virtual_ldst_addr: coverpoint VirtLdStAddr{
        bins virtual_ldst_addrbit_0_to_31                   = {[64'b00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000:64'b00000000_00000000_00000000_00000000_01111111_11111111_11111111_11111111]};
        bins virtual_ldst_addrbit_32_to_52                  = {[64'b00000000_00000000_00000000_00000000_10000000_00000000_00000000_00000000:64'b00000000_00001111_11111111_11111111_11111111_11111111_11111111_11111111]};
        bins virtual_ldst_addrbit_53_to_57                  = {[64'b00000000_00010000_00000000_00000000_00000000_00000000_00000000_00000000:64'b00000001_11111111_11111111_11111111_11111111_11111111_11111111_11111111]};
        bins virtual_ldst_addrbit_58_to_64                  = {[64'b00000010_00000000_00000000_00000000_00000000_00000000_00000000_00000000:64'b11111111_11111111_11111111_11111111_11111111_11111111_11111111_11111111]};
        bins virtual_ldst_illegal_max_addrbits              = {[64'b00000000_00011111_11111111_11111111_11111111_11111111_11111111_11111111:64'b11111111_11101111_11111111_11111111_11111111_11111111_11111111_11111111]};
    }

    paging__ptw__cp_virtual_ldst_bitsel_38: coverpoint VirtLdStAddr[38];
    paging__ptw__cp_virtual_ldst_bitsel_47: coverpoint VirtLdStAddr[47];
    paging__ptw__cp_virtual_ldst_bitsel_56: coverpoint VirtLdStAddr[56];
    paging__ptw__cp_virtual_ldst_bitsel_signextbits_sv39: coverpoint VirtLdStAddr[63:39]{
        ignore_bins legal_addr  = {0,25'b1_1111_1111_1111_1111_1111_1111};
        option.auto_bin_max     = 1;
    }
    paging__ptw__cp_virtual_ldst_bitsel_signextbits_sv48: coverpoint VirtLdStAddr[63:48]{
        ignore_bins legal_addr  = {0,16'b1111_1111_1111_1111};
        option.auto_bin_max     = 1;
    }
    paging__ptw__cp_virtual_ldst_bitsel_signextbits_sv57: coverpoint VirtLdStAddr[63:57]{
        ignore_bins legal_addr  = {0,7'b111_1111};
        option.auto_bin_max     = 1;
    }
    paging__ptw__cp_virtual_ldst_bitsel_signextbits_baremode: coverpoint VirtLdStAddr[63:56]{
        option.auto_bin_max     = 1;
        ignore_bins legal_pc    = {0};
    }

    paging__ptw__cp_misaligned_ldst: coverpoint LdStMisal;

    paging__csr__cp_mstatus_mprv : coverpoint csr_access.mstatus_csr_inst.mprv{
        bins mprv_high          = {1};
        bins mprv_low           = {0};
    }
    paging__csr__cp_mstatus_mpp : coverpoint csr_access.mstatus_csr_inst.mpp{
        bins mpp_machine        = {3};
        bins mpp_supervisor     = {1};
        bins mpp_user           = {0};
    }
    paging__csr__cp_mstatus_sum : coverpoint csr_access.mstatus_csr_inst.sum{
        bins sum_high           = {1};
        bins sum_low            = {0};
    }
    paging__csr__cp_mstatus_mxr : coverpoint csr_access.mstatus_csr_inst.mxr{
        bins mxr_high           = {1};
        bins mxr_low            = {0};
    }
    paging__csr__cp_sstatus_sum : coverpoint csr_access.sstatus_csr_inst.sum{
        bins sum_high           = {1};
        bins sum_low            = {0};
    }
    paging__csr__cp_sstatus_mxr : coverpoint csr_access.sstatus_csr_inst.mxr{
        bins mxr_high           = {1};
        bins mxr_low            = {0};
    }

    paging__csr__cp_satp_access: coverpoint rs2 {
                bins satp = {CSR_OP2_SATP};
    }

    paging__csr__cp_mstatus_tvm: coverpoint csr_access.mstatus_csr_inst.tvm{
        bins csr_mstatus_tvm_value_1    = {1};
    }

    paging__invalidation__cp_sfence_instr: coverpoint instrenum_var{ 
        bins sfence_instr               = {INSTRENUM_SFENCE_VMA}; 
    }

    paging__privilege__cp_iside_privilege_mode: coverpoint privilegemode_var{
        ignore_bins reserved_priv       = {PRIVILEGEMODE_RESERVED};
    }  

    paging__privilege__cp_dside_eff_privilege_mode: cross paging__privilege__cp_iside_privilege_mode, paging__csr__cp_mstatus_mprv, paging__csr__cp_mstatus_mpp {
        option.cross_auto_bin_max                               = 0;
        bins effective_privilegemode_machine                    = binsof(paging__privilege__cp_iside_privilege_mode) intersect {PRIVILEGEMODE_MACHINE} &&
                                                                binsof(paging__csr__cp_mstatus_mprv.mprv_low);
        bins effective_privilegemode_machine_due_to_mprv     = binsof(paging__privilege__cp_iside_privilege_mode) intersect {PRIVILEGEMODE_MACHINE} &&
                                                                binsof(paging__csr__cp_mstatus_mpp.mpp_machine) &&
                                                                binsof(paging__csr__cp_mstatus_mprv.mprv_high);
        bins effective_privilegemode_supervisor                 = binsof(paging__privilege__cp_iside_privilege_mode) intersect {PRIVILEGEMODE_SUPERVISOR} &&
                                                                binsof(paging__csr__cp_mstatus_mpp) &&
                                                                binsof(paging__csr__cp_mstatus_mprv);
        bins effective_privilegemode_supervisor_due_to_mprv     = binsof(paging__privilege__cp_iside_privilege_mode) intersect {PRIVILEGEMODE_MACHINE} &&
                                                                binsof(paging__csr__cp_mstatus_mpp.mpp_supervisor) &&
                                                                binsof(paging__csr__cp_mstatus_mprv.mprv_high);
        bins effective_privilegemode_user                       = binsof(paging__privilege__cp_iside_privilege_mode) intersect {PRIVILEGEMODE_USER} &&
                                                                binsof(paging__csr__cp_mstatus_mpp) &&
                                                                binsof(paging__csr__cp_mstatus_mprv);
        bins effective_privilegemode_user_due_to_mprv           = binsof(paging__privilege__cp_iside_privilege_mode) intersect {PRIVILEGEMODE_MACHINE} &&
                                                                binsof(paging__csr__cp_mstatus_mpp.mpp_user) &&
                                                                binsof(paging__csr__cp_mstatus_mprv.mprv_high);
    }  

    paging__exceptions__cp_excp_types: coverpoint exception_var{
        bins faults[] = {
        EXCEPTION_ILLEGAL_INST,
		EXCEPTION_INST_ACC_FAULT,
		EXCEPTION_INST_PAGE_FAULT,
		EXCEPTION_LOAD_ACC_FAULT,
		EXCEPTION_LOAD_PAGE_FAULT,
		EXCEPTION_STORE_ACC_FAULT,
		EXCEPTION_STORE_PAGE_FAULT    
        };
    }

    paging__ptw__cp_vpn_bit_48_to_56: coverpoint VirtLdStAddr[56:48]{
        bins min_vpn        = {0};
        bins max_vpn        = {9'b111111111};
        bins generic_vpn    = {[1:9'b111111110]};
    }
    paging__ptw__cp_vpn_bit_47_to_39: coverpoint VirtLdStAddr[47:39]{
        bins min_vpn        = {0};
        bins max_vpn        = {9'b111111111};
        bins generic_vpn    = {[1:9'b111111110]};
    }
    paging__ptw__cp_vpn_bit_38_to_30: coverpoint VirtLdStAddr[38:30]{
        bins min_vpn        = {0};
        bins max_vpn        = {9'b111111111};
        bins generic_vpn    = {[1:9'b111111110]};
    }
    paging__ptw__cp_vpn_bit_29_to_21: coverpoint VirtLdStAddr[29:21]{
        bins min_vpn        = {0};
        bins max_vpn        = {9'b111111111};
        bins generic_vpn    = {[1:9'b111111110]};
    }
    paging__ptw__cp_vpn_bit_20_to_12: coverpoint VirtLdStAddr[20:12]{
        bins min_vpn        = {0};
        bins max_vpn        = {9'b111111111};
        bins generic_vpn    = {[1:9'b111111110]};
    }

    paging__ptw__cr_all_svmodes_with_loads: cross paging__satp__cp_modes, paging__pagesize__cp_dside_paginglevel iff(match_instr_load == 1){
       ignore_bins large_pages_in_sv39_mode         =  binsof(paging__satp__cp_modes) intersect {8} &&
                                                    binsof(paging__pagesize__cp_dside_paginglevel) intersect {DPAGESIZE_256T, DPAGESIZE_512G};
       ignore_bins large_pages_in_sv48_mode         =   binsof(paging__satp__cp_modes) intersect {9} &&
                                                    binsof(paging__pagesize__cp_dside_paginglevel) intersect {DPAGESIZE_256T};                                         
       ignore_bins transition_modes_bare_to_nonbare = binsof(paging__satp__cp_modes.bare_to_legal_nonbare_mode) &&
                                                    binsof(paging__pagesize__cp_dside_paginglevel);
       ignore_bins transition_modes_nonbare_to_bare = binsof(paging__satp__cp_modes.legal_nonbare_to_bare_mode) &&
                                                    binsof(paging__pagesize__cp_dside_paginglevel); 
       ignore_bins transition_modes_legal_to_legal = binsof(paging__satp__cp_modes.legal_to_legal_mode) &&
                                                    binsof(paging__pagesize__cp_dside_paginglevel);
       ignore_bins baremode                         = binsof(paging__satp__cp_modes.legal_satp_bare_mode) &&
                                                    binsof(paging__pagesize__cp_dside_paginglevel);                           
    }
    paging__ptw__cr_all_svmodes_with_stores: cross paging__satp__cp_modes, paging__pagesize__cp_dside_paginglevel iff(match_instr_store == 1){
       ignore_bins large_pages_in_sv39_mode         =  binsof(paging__satp__cp_modes) intersect {8} &&
                                                    binsof(paging__pagesize__cp_dside_paginglevel) intersect {DPAGESIZE_256T, DPAGESIZE_512G};
       ignore_bins large_pages_in_sv48_mode         =   binsof(paging__satp__cp_modes) intersect {9} &&
                                                    binsof(paging__pagesize__cp_dside_paginglevel) intersect {DPAGESIZE_256T}; 
       ignore_bins transition_modes_bare_to_nonbare = binsof(paging__satp__cp_modes.bare_to_legal_nonbare_mode) &&
                                                    binsof(paging__pagesize__cp_dside_paginglevel);
       ignore_bins transition_modes_nonbare_to_bare = binsof(paging__satp__cp_modes.legal_nonbare_to_bare_mode) &&
                                                    binsof(paging__pagesize__cp_dside_paginglevel);  
       ignore_bins transition_modes_legal_to_legal = binsof(paging__satp__cp_modes.legal_to_legal_mode) &&
                                                    binsof(paging__pagesize__cp_dside_paginglevel);
       ignore_bins baremode                         = binsof(paging__satp__cp_modes.legal_satp_bare_mode) &&
                                                    binsof(paging__pagesize__cp_dside_paginglevel);        
    }
    paging__ptw__cr_all_svmodes_with_atomics: cross paging__satp__cp_modes, paging__pagesize__cp_dside_paginglevel iff(match_aext == 1){
       ignore_bins large_pages_in_sv39_mode         =  binsof(paging__satp__cp_modes) intersect {8} &&
                                                    binsof(paging__pagesize__cp_dside_paginglevel) intersect {DPAGESIZE_256T, DPAGESIZE_512G};
       ignore_bins large_pages_in_sv48_mode         =   binsof(paging__satp__cp_modes) intersect {9} &&
                                                    binsof(paging__pagesize__cp_dside_paginglevel) intersect {DPAGESIZE_256T}; 
       ignore_bins transition_modes_bare_to_nonbare = binsof(paging__satp__cp_modes.bare_to_legal_nonbare_mode) &&
                                                    binsof(paging__pagesize__cp_dside_paginglevel);
       ignore_bins transition_modes_nonbare_to_bare = binsof(paging__satp__cp_modes.legal_nonbare_to_bare_mode) &&
                                                    binsof(paging__pagesize__cp_dside_paginglevel); 
       ignore_bins transition_modes_legal_to_legal = binsof(paging__satp__cp_modes.legal_to_legal_mode) &&
                                                    binsof(paging__pagesize__cp_dside_paginglevel);
       ignore_bins baremode                         = binsof(paging__satp__cp_modes.legal_satp_bare_mode) &&
                                                    binsof(paging__pagesize__cp_dside_paginglevel);
    }

    paging__ptw__cr_all_priv_modes_with_loads: cross paging__satp__cp_modes, paging__privilege__cp_dside_eff_privilege_mode iff(match_instr_load == 1)
    {
        ignore_bins transition_modes_bare_to_nonbare    = binsof(paging__satp__cp_modes.bare_to_legal_nonbare_mode) && 
                                                        binsof(paging__privilege__cp_dside_eff_privilege_mode);
        ignore_bins transition_modes_nonbare_to_bare    = binsof(paging__satp__cp_modes.legal_nonbare_to_bare_mode)&& 
                                                        binsof(paging__privilege__cp_dside_eff_privilege_mode);
        ignore_bins baremode                            = binsof(paging__satp__cp_modes.legal_satp_bare_mode) &&
                                                        binsof(paging__privilege__cp_dside_eff_privilege_mode);
        ignore_bins transition_modes_legal_to_legal     = binsof(paging__satp__cp_modes.legal_to_legal_mode) &&
                                                        binsof(paging__privilege__cp_dside_eff_privilege_mode);
    }
    paging__ptw__cr_all_priv_modes_with_stores: cross paging__satp__cp_modes, paging__privilege__cp_dside_eff_privilege_mode iff(match_instr_store == 1)
    {
        ignore_bins transition_modes_bare_to_nonbare    = binsof(paging__satp__cp_modes.bare_to_legal_nonbare_mode) && 
                                                        binsof(paging__privilege__cp_dside_eff_privilege_mode);
        ignore_bins transition_modes_nonbare_to_bare    = binsof(paging__satp__cp_modes.legal_nonbare_to_bare_mode)&& 
                                                        binsof(paging__privilege__cp_dside_eff_privilege_mode);
        ignore_bins baremode                            = binsof(paging__satp__cp_modes.legal_satp_bare_mode) &&
                                                        binsof(paging__privilege__cp_dside_eff_privilege_mode);
        ignore_bins transition_modes_legal_to_legal     = binsof(paging__satp__cp_modes.legal_to_legal_mode) &&
                                                        binsof(paging__privilege__cp_dside_eff_privilege_mode);
    }
    paging__ptw__cr_all_priv_modes_with_atomics: cross paging__satp__cp_modes, paging__privilege__cp_dside_eff_privilege_mode iff(match_aext == 1)
    {
        ignore_bins transition_modes_bare_to_nonbare    = binsof(paging__satp__cp_modes.bare_to_legal_nonbare_mode) && 
                                                        binsof(paging__privilege__cp_dside_eff_privilege_mode);
        ignore_bins transition_modes_nonbare_to_bare    = binsof(paging__satp__cp_modes.legal_nonbare_to_bare_mode)&& 
                                                        binsof(paging__privilege__cp_dside_eff_privilege_mode);
        ignore_bins baremode                            = binsof(paging__satp__cp_modes.legal_satp_bare_mode) &&
                                                        binsof(paging__privilege__cp_dside_eff_privilege_mode);
        ignore_bins transition_modes_legal_to_legal     = binsof(paging__satp__cp_modes.legal_to_legal_mode) &&
                                                        binsof(paging__privilege__cp_dside_eff_privilege_mode);
    }

    paging__ptw__cr_vpn4: cross paging__ptw__cp_vpn_bit_48_to_56, paging__pagesize__cp_dside_paginglevel {
        option.cross_auto_bin_max   = 0;
        bins pg_vpn4 = binsof(paging__pagesize__cp_dside_paginglevel) intersect {DPAGESIZE_256T,DPAGESIZE_512G,DPAGESIZE_1G,DPAGESIZE_2M,DPAGESIZE_4K};
    }
    paging__ptw__cr_vpn3: cross paging__ptw__cp_vpn_bit_47_to_39, paging__pagesize__cp_dside_paginglevel{
        option.cross_auto_bin_max   = 0;
        bins pg_vpn3 = binsof(paging__pagesize__cp_dside_paginglevel) intersect {DPAGESIZE_512G,DPAGESIZE_1G,DPAGESIZE_2M,DPAGESIZE_4K};
    }
    paging__ptw__cr_vpn2: cross paging__ptw__cp_vpn_bit_38_to_30, paging__pagesize__cp_dside_paginglevel{
        option.cross_auto_bin_max   = 0;
        bins pg_vpn2 = binsof(paging__pagesize__cp_dside_paginglevel) intersect {DPAGESIZE_1G,DPAGESIZE_2M,DPAGESIZE_4K};
    }
    paging__ptw__cr_vpn1: cross paging__ptw__cp_vpn_bit_29_to_21, paging__pagesize__cp_dside_paginglevel{
        option.cross_auto_bin_max   = 0;
        bins pg_vpn1 = binsof(paging__pagesize__cp_dside_paginglevel) intersect {DPAGESIZE_2M,DPAGESIZE_4K};
    }
    paging__ptw__cr_vpn0: cross paging__ptw__cp_vpn_bit_20_to_12, paging__pagesize__cp_dside_paginglevel{
        option.cross_auto_bin_max   = 0;
        bins pg_vpn0 = binsof(paging__pagesize__cp_dside_paginglevel) intersect {DPAGESIZE_4K};
    }
    
    paging__ptw__cr_d_ld_pagecrosser_pagesize: cross paging__accesstype__cp_load,paging__pagesize__cp_dside_paginglevel, paging__pagesize__cp_dside_cross_paginglevel {
         option.cross_auto_bin_max   = 0;
         bins pgcr_4k_4k = binsof(paging__accesstype__cp_load) &&
                           binsof(paging__pagesize__cp_dside_paginglevel) intersect {DPAGESIZE_4K} &&
                           binsof(paging__pagesize__cp_dside_cross_paginglevel) intersect {DPAGECROSSSIZE_4K};
         bins pgcr_2M_2M = binsof(paging__accesstype__cp_load) &&
                           binsof(paging__pagesize__cp_dside_paginglevel) intersect {DPAGESIZE_2M} &&
                           binsof(paging__pagesize__cp_dside_cross_paginglevel) intersect {DPAGECROSSSIZE_2M};
         bins pgcr_1G_1G = binsof(paging__accesstype__cp_load) &&
                           binsof(paging__pagesize__cp_dside_paginglevel) intersect {DPAGESIZE_1G} &&
                           binsof(paging__pagesize__cp_dside_cross_paginglevel) intersect {DPAGECROSSSIZE_1G};
         bins pgcr_512G_512G = binsof(paging__accesstype__cp_load) &&
                           binsof(paging__pagesize__cp_dside_paginglevel) intersect {DPAGESIZE_512G} &&
                           binsof(paging__pagesize__cp_dside_cross_paginglevel) intersect {DPAGECROSSSIZE_512G};
         bins pgcr_256T_256T = binsof(paging__accesstype__cp_load) &&
                           binsof(paging__pagesize__cp_dside_paginglevel) intersect {DPAGESIZE_256T} &&
                           binsof(paging__pagesize__cp_dside_cross_paginglevel) intersect {DPAGECROSSSIZE_256T};
         bins pgcr_4k_any = binsof(paging__accesstype__cp_load) &&
                           binsof(paging__pagesize__cp_dside_paginglevel) intersect {DPAGESIZE_4K} &&
                           binsof(paging__pagesize__cp_dside_cross_paginglevel) intersect {DPAGECROSSSIZE_4K,DPAGECROSSSIZE_1G,DPAGECROSSSIZE_512G,DPAGECROSSSIZE_256T};
         bins pgcr_2M_any = binsof(paging__accesstype__cp_load) &&
                           binsof(paging__pagesize__cp_dside_paginglevel) intersect {DPAGESIZE_2M} &&
                           binsof(paging__pagesize__cp_dside_cross_paginglevel) intersect {DPAGECROSSSIZE_4K,DPAGECROSSSIZE_1G,DPAGECROSSSIZE_512G,DPAGECROSSSIZE_256T};
         bins pgcr_1G_any = binsof(paging__accesstype__cp_load) &&
                           binsof(paging__pagesize__cp_dside_paginglevel) intersect {DPAGESIZE_1G} &&
                           binsof(paging__pagesize__cp_dside_cross_paginglevel) intersect {DPAGECROSSSIZE_4K,DPAGECROSSSIZE_2M,DPAGECROSSSIZE_512G,DPAGECROSSSIZE_256T};
         bins pgcr_512G_any = binsof(paging__accesstype__cp_load) &&
                           binsof(paging__pagesize__cp_dside_paginglevel) intersect {DPAGESIZE_512G} &&
                           binsof(paging__pagesize__cp_dside_cross_paginglevel) intersect {DPAGECROSSSIZE_4K,DPAGECROSSSIZE_2M,DPAGECROSSSIZE_1G,DPAGECROSSSIZE_256T};
         bins pgcr_256T_any = binsof(paging__accesstype__cp_load) &&
                           binsof(paging__pagesize__cp_dside_paginglevel) intersect {DPAGESIZE_256T} &&
                           binsof(paging__pagesize__cp_dside_cross_paginglevel) intersect {DPAGECROSSSIZE_4K, DPAGECROSSSIZE_2M,DPAGECROSSSIZE_1G,DPAGECROSSSIZE_512G};
    }
    paging__ptw__cr_d_st_pagecrosser_pagesize: cross paging__accesstype__cp_store,paging__pagesize__cp_dside_paginglevel, paging__pagesize__cp_dside_cross_paginglevel {
         option.cross_auto_bin_max   = 0;
         bins pgcr_4k_4k = binsof(paging__accesstype__cp_store) &&
                           binsof(paging__pagesize__cp_dside_paginglevel) intersect {DPAGESIZE_4K} &&
                           binsof(paging__pagesize__cp_dside_cross_paginglevel) intersect {DPAGECROSSSIZE_4K};
         bins pgcr_2M_2M = binsof(paging__accesstype__cp_store) &&
                           binsof(paging__pagesize__cp_dside_paginglevel) intersect {DPAGESIZE_2M} &&
                           binsof(paging__pagesize__cp_dside_cross_paginglevel) intersect {DPAGECROSSSIZE_2M};
         bins pgcr_1G_1G = binsof(paging__accesstype__cp_store) &&
                           binsof(paging__pagesize__cp_dside_paginglevel) intersect {DPAGESIZE_1G} &&
                           binsof(paging__pagesize__cp_dside_cross_paginglevel) intersect {DPAGECROSSSIZE_1G};
         bins pgcr_512G_512G = binsof(paging__accesstype__cp_store) &&
                           binsof(paging__pagesize__cp_dside_paginglevel) intersect {DPAGESIZE_512G} &&
                           binsof(paging__pagesize__cp_dside_cross_paginglevel) intersect {DPAGECROSSSIZE_512G};
         bins pgcr_256T_256T = binsof(paging__accesstype__cp_store) &&
                           binsof(paging__pagesize__cp_dside_paginglevel) intersect {DPAGESIZE_256T} &&
                           binsof(paging__pagesize__cp_dside_cross_paginglevel) intersect {DPAGECROSSSIZE_256T};
         bins pgcr_4k_any = binsof(paging__accesstype__cp_store) &&
                           binsof(paging__pagesize__cp_dside_paginglevel) intersect {DPAGESIZE_4K} &&
                           binsof(paging__pagesize__cp_dside_cross_paginglevel) intersect {DPAGECROSSSIZE_4K,DPAGECROSSSIZE_1G,DPAGECROSSSIZE_512G,DPAGECROSSSIZE_256T};
         bins pgcr_2M_any = binsof(paging__accesstype__cp_store) &&
                           binsof(paging__pagesize__cp_dside_paginglevel) intersect {DPAGESIZE_2M} &&
                           binsof(paging__pagesize__cp_dside_cross_paginglevel) intersect {DPAGECROSSSIZE_4K,DPAGECROSSSIZE_1G,DPAGECROSSSIZE_512G,DPAGECROSSSIZE_256T};
         bins pgcr_1G_any = binsof(paging__accesstype__cp_store) &&
                           binsof(paging__pagesize__cp_dside_paginglevel) intersect {DPAGESIZE_1G} &&
                           binsof(paging__pagesize__cp_dside_cross_paginglevel) intersect {DPAGECROSSSIZE_4K,DPAGECROSSSIZE_2M,DPAGECROSSSIZE_512G,DPAGECROSSSIZE_256T};
         bins pgcr_512G_any = binsof(paging__accesstype__cp_store) &&
                           binsof(paging__pagesize__cp_dside_paginglevel) intersect {DPAGESIZE_512G} &&
                           binsof(paging__pagesize__cp_dside_cross_paginglevel) intersect {DPAGECROSSSIZE_4K,DPAGECROSSSIZE_2M,DPAGECROSSSIZE_1G,DPAGECROSSSIZE_256T};
         bins pgcr_256T_any = binsof(paging__accesstype__cp_store) &&
                           binsof(paging__pagesize__cp_dside_paginglevel) intersect {DPAGESIZE_256T} &&
                           binsof(paging__pagesize__cp_dside_cross_paginglevel) intersect {DPAGECROSSSIZE_4K, DPAGECROSSSIZE_2M,DPAGECROSSSIZE_1G,DPAGECROSSSIZE_512G};
    }
    paging__ptw__cr_d_atomic_pagecrosser_pagesize: cross paging__accesstype__cp_atomics,paging__pagesize__cp_dside_paginglevel, paging__pagesize__cp_dside_cross_paginglevel {
         option.cross_auto_bin_max   = 0;
         bins pgcr_4k_4k = binsof(paging__accesstype__cp_atomics) &&
                           binsof(paging__pagesize__cp_dside_paginglevel) intersect {DPAGESIZE_4K} &&
                           binsof(paging__pagesize__cp_dside_cross_paginglevel) intersect {DPAGECROSSSIZE_4K};
         bins pgcr_2M_2M = binsof(paging__accesstype__cp_atomics) &&
                           binsof(paging__pagesize__cp_dside_paginglevel) intersect {DPAGESIZE_2M} &&
                           binsof(paging__pagesize__cp_dside_cross_paginglevel) intersect {DPAGECROSSSIZE_2M};
         bins pgcr_1G_1G = binsof(paging__accesstype__cp_atomics) &&
                           binsof(paging__pagesize__cp_dside_paginglevel) intersect {DPAGESIZE_1G} &&
                           binsof(paging__pagesize__cp_dside_cross_paginglevel) intersect {DPAGECROSSSIZE_1G};
         bins pgcr_512G_512G = binsof(paging__accesstype__cp_atomics) &&
                           binsof(paging__pagesize__cp_dside_paginglevel) intersect {DPAGESIZE_512G} &&
                           binsof(paging__pagesize__cp_dside_cross_paginglevel) intersect {DPAGECROSSSIZE_512G};
         bins pgcr_256T_256T = binsof(paging__accesstype__cp_atomics) &&
                           binsof(paging__pagesize__cp_dside_paginglevel) intersect {DPAGESIZE_256T} &&
                           binsof(paging__pagesize__cp_dside_cross_paginglevel) intersect {DPAGECROSSSIZE_256T};
         bins pgcr_4k_any = binsof(paging__accesstype__cp_atomics) &&
                           binsof(paging__pagesize__cp_dside_paginglevel) intersect {DPAGESIZE_4K} &&
                           binsof(paging__pagesize__cp_dside_cross_paginglevel) intersect {DPAGECROSSSIZE_4K,DPAGECROSSSIZE_1G,DPAGECROSSSIZE_512G,DPAGECROSSSIZE_256T};
         bins pgcr_2M_any = binsof(paging__accesstype__cp_atomics) &&
                           binsof(paging__pagesize__cp_dside_paginglevel) intersect {DPAGESIZE_2M} &&
                           binsof(paging__pagesize__cp_dside_cross_paginglevel) intersect {DPAGECROSSSIZE_4K,DPAGECROSSSIZE_1G,DPAGECROSSSIZE_512G,DPAGECROSSSIZE_256T};
         bins pgcr_1G_any = binsof(paging__accesstype__cp_atomics) &&
                           binsof(paging__pagesize__cp_dside_paginglevel) intersect {DPAGESIZE_1G} &&
                           binsof(paging__pagesize__cp_dside_cross_paginglevel) intersect {DPAGECROSSSIZE_4K,DPAGECROSSSIZE_2M,DPAGECROSSSIZE_512G,DPAGECROSSSIZE_256T};
         bins pgcr_512G_any = binsof(paging__accesstype__cp_atomics) &&
                           binsof(paging__pagesize__cp_dside_paginglevel) intersect {DPAGESIZE_512G} &&
                           binsof(paging__pagesize__cp_dside_cross_paginglevel) intersect {DPAGECROSSSIZE_4K,DPAGECROSSSIZE_2M,DPAGECROSSSIZE_1G,DPAGECROSSSIZE_256T};
         bins pgcr_256T_any = binsof(paging__accesstype__cp_atomics) &&
                           binsof(paging__pagesize__cp_dside_paginglevel) intersect {DPAGESIZE_256T} &&
                           binsof(paging__pagesize__cp_dside_cross_paginglevel) intersect {DPAGECROSSSIZE_4K, DPAGECROSSSIZE_2M,DPAGECROSSSIZE_1G,DPAGECROSSSIZE_512G};
    }

     paging__ptw__cr_i_sv39_va_maxbits: cross paging__satp__cp_modes, paging__ptw__cp_virtual_pc_bitsel_38
     {
        option.cross_auto_bin_max   = 0;
        bins iside_sv39_vamax_bit_0     = binsof(paging__satp__cp_modes) intersect {8} &&
                                        binsof(paging__ptw__cp_virtual_pc_bitsel_38)intersect {0} iff (VirtPc[63:39] != 0);
        bins iside_sv39_vamax_bit_1     = binsof(paging__satp__cp_modes) intersect {8} &&
                                        binsof(paging__ptw__cp_virtual_pc_bitsel_38)intersect {1} iff (VirtPc[63:39] != {25{1'b1}});      
     }
     paging__ptw__cr_i_sv48_va_maxbits: cross paging__satp__cp_modes, paging__ptw__cp_virtual_pc_bitsel_47
     {
        option.cross_auto_bin_max   = 0;
        bins iside_sv48_vamax_bit_0     = binsof(paging__satp__cp_modes) intersect {9} &&
                                        binsof(paging__ptw__cp_virtual_pc_bitsel_47)intersect {0} iff (VirtPc[63:48] != 0);
        bins iside_sv48_vamax_bit_1     = binsof(paging__satp__cp_modes) intersect {9} &&
                                        binsof(paging__ptw__cp_virtual_pc_bitsel_47)intersect {1} iff (VirtPc[63:48] != {16{1'b1}});     
     }
     paging__ptw__cr_i_sv57_va_maxbits: cross paging__satp__cp_modes, paging__ptw__cp_virtual_pc_bitsel_56
     {
        option.cross_auto_bin_max   = 0;
        bins iside_sv57_vamax_bit_0     = binsof(paging__satp__cp_modes) intersect {10} &&
                                        binsof(paging__ptw__cp_virtual_pc_bitsel_56)intersect {0} iff (VirtPc[63:57] != 0);
        bins iside_sv57_vamax_bit_1     = binsof(paging__satp__cp_modes) intersect {10} &&
                                        binsof(paging__ptw__cp_virtual_pc_bitsel_56)intersect {1} iff (VirtPc[63:57] != {7{1'b1}}); 
     }
     paging__ptw__cr_d_sv39_va_maxbits: cross paging__satp__cp_modes, paging__ptw__cp_virtual_ldst_bitsel_38
     {
        option.cross_auto_bin_max   = 0;
        bins dside_sv39_vamax_bit_0 = binsof(paging__satp__cp_modes) intersect {8} &&
                            binsof(paging__ptw__cp_virtual_ldst_bitsel_38)intersect {0} iff (VirtLdStAddr[63:39] != 0);
        bins dside_sv39_vamax_bit_1 = binsof(paging__satp__cp_modes) intersect {8} &&
                            binsof(paging__ptw__cp_virtual_ldst_bitsel_38)intersect {1} iff (VirtLdStAddr[63:39] != {25{1'b1}});
     }
     paging__ptw__cr_d_sv48_va_maxbits: cross paging__satp__cp_modes,  paging__ptw__cp_virtual_ldst_bitsel_47
     {
        option.cross_auto_bin_max   = 0;
        bins dside_sv48_vamax_bit_0 = binsof(paging__satp__cp_modes) intersect {9} &&
                            binsof( paging__ptw__cp_virtual_ldst_bitsel_47)intersect {0} iff (VirtLdStAddr[63:48] != 0);
        bins dside_sv48_vamax_bit_1 = binsof(paging__satp__cp_modes) intersect {9} &&
                            binsof( paging__ptw__cp_virtual_ldst_bitsel_47)intersect {1} iff (VirtLdStAddr[63:48] != {16{1'b1}});     
     }
     paging__ptw__cr_d_sv57_va_maxbits: cross paging__satp__cp_modes,paging__ptw__cp_virtual_ldst_bitsel_56
     {
        option.cross_auto_bin_max   = 0;
        bins dside_sv57_vamax_bit_0 = binsof(paging__satp__cp_modes) intersect {10} &&
                            binsof(paging__ptw__cp_virtual_ldst_bitsel_56)intersect {0} iff (VirtLdStAddr[63:57] != 0);
        bins dside_sv57_vamax_bit_1 = binsof(paging__satp__cp_modes) intersect {10} &&
                            binsof(paging__ptw__cp_virtual_ldst_bitsel_56)intersect {1} iff (VirtLdStAddr[63:57] != {7{1'b1}});
     }
    
    paging__ptw__cr_d_ptwppn_2m_align: cross paging__pagesize__cp_dside_paginglevel, paging__ptw__dpte_leaf_ppn_lvl2_align
    {
        option.cross_auto_bin_max   = 0;
        bins aligned        = binsof(paging__pagesize__cp_dside_paginglevel) intersect {DPAGESIZE_2M} &&
                                binsof(paging__ptw__dpte_leaf_ppn_lvl2_align.aligned);
        bins non_aligned    = binsof(paging__pagesize__cp_dside_paginglevel) intersect {DPAGESIZE_2M} &&
                                binsof(paging__ptw__dpte_leaf_ppn_lvl2_align.non_aligned);
    }
    paging__ptw__cr_d_ptwppn_1g_align: cross paging__pagesize__cp_dside_paginglevel, paging__ptw__dpte_leaf_ppn_lvl3_align
    {
        option.cross_auto_bin_max   = 0;
        bins aligned        = binsof(paging__pagesize__cp_dside_paginglevel) intersect {DPAGESIZE_1G} &&
                                binsof(paging__ptw__dpte_leaf_ppn_lvl3_align.aligned);
        bins non_aligned    = binsof(paging__pagesize__cp_dside_paginglevel) intersect {DPAGESIZE_1G} &&
                                binsof(paging__ptw__dpte_leaf_ppn_lvl3_align.non_aligned);
    }
    paging__ptw__cr_d_ptwppn_512g_align: cross paging__pagesize__cp_dside_paginglevel, paging__ptw__dpte_leaf_ppn_lvl4_align
    {
        option.cross_auto_bin_max   = 0;
        bins aligned        = binsof(paging__pagesize__cp_dside_paginglevel) intersect {DPAGESIZE_512G} &&
                                binsof(paging__ptw__dpte_leaf_ppn_lvl4_align.aligned);
        bins non_aligned    = binsof(paging__pagesize__cp_dside_paginglevel) intersect {DPAGESIZE_512G} &&
                                binsof(paging__ptw__dpte_leaf_ppn_lvl4_align.non_aligned);
    }
    paging__ptw__cr_d_ptwppn_256t_align: cross paging__pagesize__cp_dside_paginglevel, paging__ptw__dpte_leaf_ppn_lvl5_align
    {
        option.cross_auto_bin_max   = 0;
        bins aligned        = binsof(paging__pagesize__cp_dside_paginglevel) intersect {DPAGESIZE_256T} &&
                                binsof(paging__ptw__dpte_leaf_ppn_lvl5_align.aligned);
        bins non_aligned    = binsof(paging__pagesize__cp_dside_paginglevel) intersect {DPAGESIZE_256T} &&
                                binsof(paging__ptw__dpte_leaf_ppn_lvl5_align.non_aligned);
    }

    paging__ptw__cr_i_ptwppn_2m_align: cross paging__pagesize__cp_iside_paginglevel, paging__ptw__ipte_leaf_ppn_lvl2_align
    {
        option.cross_auto_bin_max   = 0;
        bins aligned        = binsof(paging__pagesize__cp_iside_paginglevel) intersect {FPAGESIZE_2M} &&
                                binsof(paging__ptw__ipte_leaf_ppn_lvl2_align.aligned);
        bins non_aligned    = binsof(paging__pagesize__cp_iside_paginglevel) intersect {FPAGESIZE_2M} &&
                                binsof(paging__ptw__ipte_leaf_ppn_lvl2_align.non_aligned);
    }
    paging__ptw__cr_i_ptwppn_1g_align: cross paging__pagesize__cp_iside_paginglevel, paging__ptw__ipte_leaf_ppn_lvl3_align
    {
        option.cross_auto_bin_max   = 0;
        bins aligned        = binsof(paging__pagesize__cp_iside_paginglevel) intersect {FPAGESIZE_1G} &&
                                binsof(paging__ptw__ipte_leaf_ppn_lvl3_align.aligned);
        bins non_aligned    = binsof(paging__pagesize__cp_iside_paginglevel) intersect {FPAGESIZE_1G} &&
                                binsof(paging__ptw__ipte_leaf_ppn_lvl3_align.non_aligned);
    }
    paging__ptw__cr_i_ptwppn_512g_align: cross paging__pagesize__cp_iside_paginglevel, paging__ptw__ipte_leaf_ppn_lvl4_align
    {
        option.cross_auto_bin_max   = 0;
        bins aligned        = binsof(paging__pagesize__cp_iside_paginglevel) intersect {FPAGESIZE_512G} &&
                                binsof(paging__ptw__ipte_leaf_ppn_lvl4_align.aligned);
        bins non_aligned    = binsof(paging__pagesize__cp_iside_paginglevel) intersect {FPAGESIZE_512G} &&
                                binsof(paging__ptw__ipte_leaf_ppn_lvl4_align.non_aligned);
    }
    paging__ptw__cr_i_ptwppn_256t_align: cross paging__pagesize__cp_iside_paginglevel, paging__ptw__ipte_leaf_ppn_lvl5_align
    {
        option.cross_auto_bin_max   = 0;
        bins aligned        = binsof(paging__pagesize__cp_iside_paginglevel) intersect {FPAGESIZE_256T} &&
                                binsof(paging__ptw__ipte_leaf_ppn_lvl5_align.aligned);
        bins non_aligned    = binsof(paging__pagesize__cp_iside_paginglevel) intersect {FPAGESIZE_256T} &&
                                binsof(paging__ptw__ipte_leaf_ppn_lvl5_align.non_aligned);
    }

    cr__paging__faults__d_pgXfaults: cross paging__pagesize__cp_dside_cross_paginglevel, paging__exceptions__cp_excp_types;

    paging__exceptions__cp_instruction_pagefault: cross paging__ptw__cp_iside_leaf_ptw_exec, paging__ptw__cp_iside_leaf_ptw_access, paging__ptw__cp_iside_nonleaf_ptw_valid, paging__ptw__cp_iside_leaf_ptw_valid, paging__ptw__cp_iside_leaf_ptw_user,  paging__privilege__cp_iside_privilege_mode {
        option.cross_auto_bin_max   = 0;
        bins i_leaf_pagefault_without_valid     = binsof(paging__ptw__cp_iside_leaf_ptw_valid) intersect {0};
        bins i_non_leaf_pagefault_without_valid = binsof(paging__ptw__cp_iside_nonleaf_ptw_valid) intersect {0};
        bins i_leaf_pagefault_without_access    = binsof(paging__ptw__cp_iside_leaf_ptw_access) intersect {0};
        bins i_leaf_pagefault_without_execute   = binsof(paging__ptw__cp_iside_leaf_ptw_valid) intersect {1} &&
                                                binsof(paging__ptw__cp_iside_leaf_ptw_exec) intersect {0};
        bins i_supervisoraccess_with_pte_u_one  = binsof(paging__ptw__cp_iside_leaf_ptw_valid) intersect {1} &&
                                                 binsof(paging__ptw__cp_iside_leaf_ptw_user) intersect {1} &&
                                                 binsof( paging__privilege__cp_iside_privilege_mode) intersect {PRIVILEGEMODE_SUPERVISOR};
        bins i_useraccess_with_pte_u_zero       = binsof(paging__ptw__cp_iside_leaf_ptw_valid) intersect {1} &&
                                                binsof(paging__ptw__cp_iside_leaf_ptw_user) intersect {0} &&
                                                binsof( paging__privilege__cp_iside_privilege_mode) intersect {PRIVILEGEMODE_USER};
        bins i_pagefault_due_to_reserved_bits = binsof(paging__ptw__cp_iside_leaf_ptw_valid) intersect {1} && 
                                                binsof(paging__ptw__cp_iside_leaf_ptw_exec) intersect {1} iff((FPTE_LeafRes!=0)||(FPTE_LeafPbmt!=2'b11)||(FPTE_NonLeafRes!=0)||(FPTE_NonLeafPbmt!=2'b11));
    }

    paging__exceptions__cp_data_pagefault_res:  coverpoint (DPTE_LeafV==1 && ((DPTE_LeafRes!=0)||(DPTE_LeafPbmt!=2'b11)||(DPTE_NonLeafRes!=0)||(DPTE_NonLeafPbmt!=2'b11)));

    paging__exceptions__cp_data_pagefault_store: cross paging__ptw__cp_dside_leaf_ptw_valid, paging__accesstype__cp_store, paging__ptw__cp_dside_leaf_ptw_write, paging__ptw__cp_dside_leaf_ptw_dirty {
        option.cross_auto_bin_max   = 0;
        bins d_leaf_pagefault_store_with_pte_w_zero = binsof(paging__ptw__cp_dside_leaf_ptw_valid) intersect {1} &&
                                                      binsof(paging__accesstype__cp_store) &&
                                                      binsof(paging__ptw__cp_dside_leaf_ptw_write) intersect {0};
        bins d_pagefualt_store_with_dirty_bit_zero = binsof(paging__ptw__cp_dside_leaf_ptw_valid) intersect {1} &&
                                                     binsof(paging__accesstype__cp_store) &&
                                                     binsof(paging__ptw__cp_dside_leaf_ptw_write) intersect {1} &&
                                                     binsof(paging__ptw__cp_dside_leaf_ptw_dirty) intersect {0};
    }

    paging__exceptions__cp_data_pagefault_load: cross paging__ptw__cp_dside_leaf_ptw_valid, paging__accesstype__cp_load, paging__ptw__cp_dside_leaf_ptw_read, paging__ptw__cp_dside_leaf_ptw_access {
        option.cross_auto_bin_max   = 0;
        bins d_leaf_pagefault_load_with_pte_r_zero = binsof(paging__ptw__cp_dside_leaf_ptw_valid) intersect {1} &&
                                                      binsof(paging__accesstype__cp_load) &&
                                                      binsof(paging__ptw__cp_dside_leaf_ptw_read) intersect {0};
        bins d_pagefualt_load_with_access_bit_zero = binsof(paging__ptw__cp_dside_leaf_ptw_valid) intersect {1} &&
                                                     binsof(paging__accesstype__cp_load) &&
                                                     binsof(paging__ptw__cp_dside_leaf_ptw_read) intersect {1} &&
                                                     binsof(paging__ptw__cp_dside_leaf_ptw_access) intersect {0};
    }

    paging__exceptions__cp_data_pagefault_sc: cross paging__ptw__cp_dside_leaf_ptw_valid, paging__accesstype__cp_atomics, paging__ptw__cp_dside_leaf_ptw_write, paging__ptw__cp_dside_leaf_ptw_dirty {
        option.cross_auto_bin_max   = 0;
        bins d_leaf_pagefault_sc_with_pte_w_zero = binsof(paging__ptw__cp_dside_leaf_ptw_valid) intersect {1} &&
                                                      binsof(paging__accesstype__cp_atomics.sc) &&
                                                      binsof(paging__ptw__cp_dside_leaf_ptw_write) intersect {0};
        bins d_pagefualt_sc_with_dirty_bit_zero = binsof(paging__ptw__cp_dside_leaf_ptw_valid) intersect {1} &&
                                                     binsof(paging__accesstype__cp_atomics.sc) &&
                                                     binsof(paging__ptw__cp_dside_leaf_ptw_write) intersect {1} &&
                                                     binsof(paging__ptw__cp_dside_leaf_ptw_dirty) intersect {0};
    }

    paging__exceptions__cp_data_pagefault_lr: cross paging__ptw__cp_dside_leaf_ptw_valid, paging__accesstype__cp_atomics, paging__ptw__cp_dside_leaf_ptw_read, paging__ptw__cp_dside_leaf_ptw_write, paging__ptw__cp_dside_leaf_ptw_access {
        option.cross_auto_bin_max   = 0;
        bins d_leaf_pagefault_lr_with_pte_r_zero = binsof(paging__ptw__cp_dside_leaf_ptw_valid) intersect {1} &&
                                                      binsof(paging__accesstype__cp_atomics.lr) &&
                                                      binsof(paging__ptw__cp_dside_leaf_ptw_read) intersect {0};
        bins d_leaf_pagefault_lr_with_pte_w_zero = binsof(paging__ptw__cp_dside_leaf_ptw_valid) intersect {1} &&
                                                      binsof(paging__accesstype__cp_atomics.lr) &&
                                                      binsof(paging__ptw__cp_dside_leaf_ptw_read) intersect {1} &&
                                                      binsof(paging__ptw__cp_dside_leaf_ptw_write) intersect {0};
        bins d_pagefault_lr_with_access_bit_zero = binsof(paging__ptw__cp_dside_leaf_ptw_valid) intersect {1} &&
                                                     binsof(paging__accesstype__cp_atomics.lr) &&
                                                     binsof(paging__ptw__cp_dside_leaf_ptw_read) intersect {1} &&
                                                     binsof(paging__ptw__cp_dside_leaf_ptw_access) intersect {0};
    }


    paging__exceptions__cp_data_pagefault_amo_rw_bit: cross paging__ptw__cp_dside_leaf_ptw_valid, paging__accesstype__cp_atomics, paging__ptw__cp_dside_leaf_ptw_write, paging__ptw__cp_dside_leaf_ptw_read{
        option.cross_auto_bin_max   = 0;
        bins d_leaf_pagefault_amo_with_pte_w_zero = binsof(paging__ptw__cp_dside_leaf_ptw_valid) intersect {1} &&
                                                      binsof(paging__accesstype__cp_atomics.amo) &&
                                                      binsof(paging__ptw__cp_dside_leaf_ptw_write) intersect {0};
        bins d_leaf_pagefault_amo_with_pte_r_zero = binsof(paging__ptw__cp_dside_leaf_ptw_valid) intersect {1} &&
                                                      binsof(paging__accesstype__cp_atomics.amo) &&
                                                      binsof(paging__ptw__cp_dside_leaf_ptw_read) intersect {0};
    }

    paging__exceptions__cp_data_pagefault_amo_ad_bits: cross paging__ptw__cp_dside_leaf_ptw_valid, paging__accesstype__cp_atomics, paging__ptw__cp_dside_leaf_ptw_write, paging__ptw__cp_dside_leaf_ptw_dirty, paging__ptw__cp_dside_leaf_ptw_access {
        option.cross_auto_bin_max   = 0;
        bins d_pagefualt_amo_with_dirty_bit_zero = binsof(paging__ptw__cp_dside_leaf_ptw_valid) intersect {1} &&
                                                     binsof(paging__accesstype__cp_atomics.amo) &&
                                                     binsof(paging__ptw__cp_dside_leaf_ptw_write) intersect {1} &&
                                                     binsof(paging__ptw__cp_dside_leaf_ptw_dirty) intersect {0};
        bins d_pagefualt_amo_with_access_bit_zero = binsof(paging__ptw__cp_dside_leaf_ptw_valid) intersect {1} &&
                                                     binsof(paging__accesstype__cp_atomics.amo) &&
                                                     binsof(paging__ptw__cp_dside_leaf_ptw_write) intersect {1} &&
                                                     binsof(paging__ptw__cp_dside_leaf_ptw_access) intersect {0};
    }
    
    cr__paging__d_pteattributes__rwxu:  cross paging__ptw__cp_dside_leaf_ptw_read, paging__ptw__cp_dside_leaf_ptw_write, paging__ptw__cp_dside_leaf_ptw_exec, paging__ptw__cp_dside_leaf_ptw_user;
    cr__paging__i_pteattributes__xu:    cross paging__ptw__cp_iside_leaf_ptw_exec, paging__ptw__cp_iside_leaf_ptw_user;

    paging__ptw__cr_d_sstatus_sum__bit_effect: cross paging__csr__cp_sstatus_sum, paging__privilege__cp_dside_eff_privilege_mode, paging__ptw__cp_dside_leaf_ptw_user {
        option.cross_auto_bin_max   = 0;
        bins sum_effective_smode        = binsof(paging__csr__cp_sstatus_sum) intersect {1} &&
                                        binsof(paging__privilege__cp_dside_eff_privilege_mode.effective_privilegemode_supervisor) &&
                                        binsof(paging__ptw__cp_dside_leaf_ptw_user) intersect {1};
        bins sum_non_effective_smode    = binsof(paging__csr__cp_sstatus_sum) intersect {0} &&
                                        binsof(paging__privilege__cp_dside_eff_privilege_mode.effective_privilegemode_supervisor) &&
                                        binsof(paging__ptw__cp_dside_leaf_ptw_user) intersect {1};
        bins sum_non_effective_mmode    = binsof(paging__csr__cp_sstatus_sum) &&
                                        binsof(paging__privilege__cp_dside_eff_privilege_mode.effective_privilegemode_machine) &&
                                        binsof(paging__ptw__cp_dside_leaf_ptw_user) intersect {1};
        bins sum_non_effective_umode    = binsof(paging__csr__cp_sstatus_sum) intersect {0} &&
                                        binsof(paging__privilege__cp_dside_eff_privilege_mode.effective_privilegemode_user) &&
                                        binsof(paging__ptw__cp_dside_leaf_ptw_user) intersect {1};
    }
    paging__ptw__cr_d_mstatus_sum__bit_effect: cross paging__csr__cp_mstatus_sum, paging__privilege__cp_dside_eff_privilege_mode, paging__ptw__cp_dside_leaf_ptw_user {
        option.cross_auto_bin_max   = 0;
        bins sum_effective_smode_dueto_mprv       = binsof(paging__csr__cp_mstatus_sum) intersect {1} &&
                                                    binsof(paging__privilege__cp_dside_eff_privilege_mode.effective_privilegemode_supervisor_due_to_mprv) &&
                                                    binsof(paging__ptw__cp_dside_leaf_ptw_user) intersect {1};
        bins sum_non_effective_smode_dueto_mprv   = binsof(paging__csr__cp_mstatus_sum) intersect {0} &&
                                                    binsof(paging__privilege__cp_dside_eff_privilege_mode.effective_privilegemode_supervisor_due_to_mprv) &&
                                                    binsof(paging__ptw__cp_dside_leaf_ptw_user) intersect {1};
        bins sum_non_effective_mmode              = binsof(paging__csr__cp_mstatus_sum) &&
                                                    binsof(paging__privilege__cp_dside_eff_privilege_mode.effective_privilegemode_machine);
        bins sum_non_effective_mmode_dueto_mprv   = binsof(paging__csr__cp_mstatus_sum) &&
                                                    binsof(paging__privilege__cp_dside_eff_privilege_mode.effective_privilegemode_machine_due_to_mprv);
        bins sum_non_effective_umode_dueto_mprv   = binsof(paging__csr__cp_mstatus_sum) intersect {0} &&
                                                    binsof(paging__privilege__cp_dside_eff_privilege_mode.effective_privilegemode_user_due_to_mprv) &&
                                                    binsof(paging__ptw__cp_dside_leaf_ptw_user) intersect {1};
    }
    paging__ptw__cr_i_sstatus_sum__bit_effect: cross paging__csr__cp_sstatus_sum, paging__privilege__cp_iside_privilege_mode, paging__ptw__cp_iside_leaf_ptw_user{
        option.cross_auto_bin_max   = 0;
        bins sum_effective_smode        = binsof(paging__csr__cp_sstatus_sum) intersect {1} &&
                                        binsof(paging__privilege__cp_iside_privilege_mode) intersect {PRIVILEGEMODE_SUPERVISOR} &&
                                        binsof(paging__ptw__cp_iside_leaf_ptw_user) intersect {1};
        bins sum_non_effective_smode    = binsof(paging__csr__cp_sstatus_sum) intersect {0} &&
                                        binsof(paging__privilege__cp_iside_privilege_mode) intersect {PRIVILEGEMODE_SUPERVISOR} &&
                                        binsof(paging__ptw__cp_iside_leaf_ptw_user) intersect {1};
        bins sum_non_effective_mmode    = binsof(paging__csr__cp_sstatus_sum) &&
                                        binsof(paging__privilege__cp_iside_privilege_mode) intersect {PRIVILEGEMODE_MACHINE} &&
                                        binsof(paging__ptw__cp_iside_leaf_ptw_user) intersect {1};
        bins sum_non_effective_umode    = binsof(paging__csr__cp_sstatus_sum) &&
                                        binsof(paging__privilege__cp_iside_privilege_mode) intersect {PRIVILEGEMODE_USER} &&
                                        binsof(paging__ptw__cp_iside_leaf_ptw_user) intersect {1};
    }
    paging__ptw__cr_d_sstatus_mxr__bit_effect: cross paging__privilege__cp_dside_eff_privilege_mode,paging__csr__cp_sstatus_mxr, paging__ptw__cp_dside_leaf_ptw_read, paging__ptw__cp_dside_leaf_ptw_exec{
        option.cross_auto_bin_max   = 0;
        bins mxr_effective_supervisor    = binsof(paging__csr__cp_sstatus_mxr) intersect {1} &&
                                        binsof(paging__ptw__cp_dside_leaf_ptw_read) intersect {0} &&
                                        binsof(paging__ptw__cp_dside_leaf_ptw_exec) intersect {1} &&
                                        binsof(paging__privilege__cp_dside_eff_privilege_mode.effective_privilegemode_supervisor);
        bins mxr_effective_user         = binsof(paging__csr__cp_sstatus_mxr) intersect {1} &&
                                        binsof(paging__ptw__cp_dside_leaf_ptw_read) intersect {0} &&
                                        binsof(paging__ptw__cp_dside_leaf_ptw_exec) intersect {1} &&
                                        binsof(paging__privilege__cp_dside_eff_privilege_mode.effective_privilegemode_user);
        bins mxr_non_effective_supervisor = binsof(paging__csr__cp_sstatus_mxr) intersect {0} &&
                                        binsof(paging__ptw__cp_dside_leaf_ptw_read) intersect {0} &&
                                        binsof(paging__ptw__cp_dside_leaf_ptw_exec) intersect {1} &&
                                        binsof(paging__privilege__cp_dside_eff_privilege_mode.effective_privilegemode_supervisor);
        bins mxr_non_effective_user     = binsof(paging__csr__cp_sstatus_mxr) intersect {0} &&
                                        binsof(paging__ptw__cp_dside_leaf_ptw_read) intersect {0} &&
                                        binsof(paging__ptw__cp_dside_leaf_ptw_exec) intersect {1} &&
                                        binsof(paging__privilege__cp_dside_eff_privilege_mode.effective_privilegemode_user);
    }
    paging__ptw__cr_d_mstatus_mxr__bit_effect: cross paging__privilege__cp_dside_eff_privilege_mode,paging__csr__cp_mstatus_mxr, paging__ptw__cp_dside_leaf_ptw_read, paging__ptw__cp_dside_leaf_ptw_exec{
        option.cross_auto_bin_max   = 0;
        bins mxr_effective_supervisor    = binsof(paging__csr__cp_mstatus_mxr) intersect {1} &&
                                        binsof(paging__ptw__cp_dside_leaf_ptw_read) intersect {0} &&
                                        binsof(paging__ptw__cp_dside_leaf_ptw_exec) intersect {1} &&
                                        binsof(paging__privilege__cp_dside_eff_privilege_mode.effective_privilegemode_supervisor_due_to_mprv);
        bins mxr_effective_user         = binsof(paging__csr__cp_mstatus_mxr) intersect {1} &&
                                        binsof(paging__ptw__cp_dside_leaf_ptw_read) intersect {0} &&
                                        binsof(paging__ptw__cp_dside_leaf_ptw_exec) intersect {1} &&
                                        binsof(paging__privilege__cp_dside_eff_privilege_mode.effective_privilegemode_user_due_to_mprv);
        bins mxr_non_effective_supervisor = binsof(paging__csr__cp_mstatus_mxr) intersect {0} &&
                                        binsof(paging__ptw__cp_dside_leaf_ptw_read) intersect {0} &&
                                        binsof(paging__ptw__cp_dside_leaf_ptw_exec) intersect {1} &&
                                        binsof(paging__privilege__cp_dside_eff_privilege_mode.effective_privilegemode_supervisor_due_to_mprv);
        bins mxr_non_effective_user = binsof(paging__csr__cp_mstatus_mxr) intersect {0} &&
                                        binsof(paging__ptw__cp_dside_leaf_ptw_read) intersect {0} &&
                                        binsof(paging__ptw__cp_dside_leaf_ptw_exec) intersect {1} &&
                                        binsof(paging__privilege__cp_dside_eff_privilege_mode.effective_privilegemode_user_due_to_mprv);
        bins mxr_non_effective_machine  = binsof(paging__csr__cp_mstatus_mxr) &&
                                        binsof(paging__privilege__cp_dside_eff_privilege_mode.effective_privilegemode_machine);
        bins mxr_non_effective_machine_dueto_mprv  = binsof(paging__csr__cp_mstatus_mxr) &&
                                        binsof(paging__privilege__cp_dside_eff_privilege_mode.effective_privilegemode_machine_due_to_mprv);
    }
    paging__ptw__cr_i_mstatus_mxr__bit_effect: cross paging__privilege__cp_iside_privilege_mode, paging__csr__cp_mstatus_mxr, paging__ptw__cp_iside_leaf_ptw_read, paging__ptw__cp_iside_leaf_ptw_exec{
        option.cross_auto_bin_max   = 0;
        bins mxr_effective = binsof(paging__csr__cp_mstatus_mxr) intersect {1} &&
                             binsof(paging__ptw__cp_iside_leaf_ptw_read) intersect {0} &&
                             binsof(paging__ptw__cp_iside_leaf_ptw_exec) intersect {1} &&
                             binsof(paging__privilege__cp_iside_privilege_mode);
        bins mxr_non_effective = binsof(paging__csr__cp_mstatus_mxr) intersect {0} &&
                             binsof(paging__ptw__cp_iside_leaf_ptw_read) intersect {0} &&
                             binsof(paging__ptw__cp_iside_leaf_ptw_exec) intersect {1}&&
                             binsof(paging__privilege__cp_iside_privilege_mode);
    }

     paging__ptw__cr_i_leaf_nonglobal_nonleaf_global: cross paging__privilege__cp_iside_privilege_mode, paging__ptw__cp_iside_leaf_ptw_global, paging__ptw__cp_iside_nonleaf_ptw_global
     {
        option.cross_auto_bin_max   = 0;
        bins leaf_nonglobal_and_nonleaf_global = binsof(paging__ptw__cp_iside_leaf_ptw_global) intersect {0} &&
                                                binsof(paging__ptw__cp_iside_nonleaf_ptw_global) intersect {1} &&
                                                binsof(paging__privilege__cp_iside_privilege_mode) intersect {PRIVILEGEMODE_SUPERVISOR,PRIVILEGEMODE_USER};
        bins leaf_nonglobal_and_nonleaf_nonglobal = binsof(paging__ptw__cp_iside_leaf_ptw_global) intersect {0} &&
                                                binsof(paging__ptw__cp_iside_nonleaf_ptw_global) intersect {0}&&
                                                binsof(paging__privilege__cp_iside_privilege_mode) intersect {PRIVILEGEMODE_SUPERVISOR,PRIVILEGEMODE_USER};
        bins leaf_global_and_nonleaf_any        = binsof(paging__ptw__cp_iside_leaf_ptw_global) intersect {1} &&
                                                binsof(paging__ptw__cp_iside_nonleaf_ptw_global)&&
                                                binsof(paging__privilege__cp_iside_privilege_mode) intersect {PRIVILEGEMODE_SUPERVISOR,PRIVILEGEMODE_USER};                                     
     }
     paging__ptw__cr_d_leaf_nonglobal_nonleaf_global: cross paging__privilege__cp_dside_eff_privilege_mode, paging__ptw__cp_dside_leaf_ptw_global, paging__ptw__cp_dside_nonleaf_ptw_global
     {
        option.cross_auto_bin_max   = 0;    
        bins leaf_nonglobal_and_nonleaf_global_smode = binsof(paging__ptw__cp_dside_leaf_ptw_global) intersect {0} &&
                                                binsof(paging__ptw__cp_dside_nonleaf_ptw_global) intersect {1} &&
                                                binsof(paging__privilege__cp_dside_eff_privilege_mode.effective_privilegemode_supervisor);
        bins leaf_nonglobal_and_nonleaf_nonglobal_smode = binsof(paging__ptw__cp_dside_leaf_ptw_global) intersect {0} &&
                                                binsof(paging__ptw__cp_dside_nonleaf_ptw_global) intersect {0}&&
                                                binsof(paging__privilege__cp_dside_eff_privilege_mode.effective_privilegemode_supervisor);
        bins leaf_global_and_nonleaf_any_smode = binsof(paging__ptw__cp_dside_leaf_ptw_global) intersect {1} &&
                                                binsof(paging__ptw__cp_dside_nonleaf_ptw_global)&&
                                                binsof(paging__privilege__cp_dside_eff_privilege_mode.effective_privilegemode_supervisor); 
        bins leaf_nonglobal_and_nonleaf_global_smode1 = binsof(paging__ptw__cp_dside_leaf_ptw_global) intersect {0} &&
                                                binsof(paging__ptw__cp_dside_nonleaf_ptw_global) intersect {1} &&
                                                binsof(paging__privilege__cp_dside_eff_privilege_mode.effective_privilegemode_supervisor_due_to_mprv);
        bins leaf_nonglobal_and_nonleaf_nonglobal_smode1 = binsof(paging__ptw__cp_dside_leaf_ptw_global) intersect {0} &&
                                                binsof(paging__ptw__cp_dside_nonleaf_ptw_global) intersect {0}&&
                                                binsof(paging__privilege__cp_dside_eff_privilege_mode.effective_privilegemode_supervisor_due_to_mprv);
        bins leaf_global_and_nonleaf_any_smode1 = binsof(paging__ptw__cp_dside_leaf_ptw_global) intersect {1} &&
                                                binsof(paging__ptw__cp_dside_nonleaf_ptw_global)&&
                                                binsof(paging__privilege__cp_dside_eff_privilege_mode.effective_privilegemode_supervisor_due_to_mprv); 
        bins leaf_nonglobal_and_nonleaf_global_umode = binsof(paging__ptw__cp_dside_leaf_ptw_global) intersect {0} &&
                                                binsof(paging__ptw__cp_dside_nonleaf_ptw_global) intersect {1} &&
                                                binsof(paging__privilege__cp_dside_eff_privilege_mode.effective_privilegemode_user);
        bins leaf_nonglobal_and_nonleaf_nonglobal_umode = binsof(paging__ptw__cp_dside_leaf_ptw_global) intersect {0} &&
                                                binsof(paging__ptw__cp_dside_nonleaf_ptw_global) intersect {0}&&
                                                binsof(paging__privilege__cp_dside_eff_privilege_mode.effective_privilegemode_user);
        bins leaf_global_and_nonleaf_any_umode = binsof(paging__ptw__cp_dside_leaf_ptw_global) intersect {1} &&
                                                binsof(paging__ptw__cp_dside_nonleaf_ptw_global)&&
                                                binsof(paging__privilege__cp_dside_eff_privilege_mode.effective_privilegemode_user);
        bins leaf_nonglobal_and_nonleaf_global_umode1 = binsof(paging__ptw__cp_dside_leaf_ptw_global) intersect {0} &&
                                                binsof(paging__ptw__cp_dside_nonleaf_ptw_global) intersect {1} &&
                                                binsof(paging__privilege__cp_dside_eff_privilege_mode.effective_privilegemode_user_due_to_mprv);
        bins leaf_nonglobal_and_nonleaf_nonglobal_umode1 = binsof(paging__ptw__cp_dside_leaf_ptw_global) intersect {0} &&
                                                binsof(paging__ptw__cp_dside_nonleaf_ptw_global) intersect {0}&&
                                                binsof(paging__privilege__cp_dside_eff_privilege_mode.effective_privilegemode_user_due_to_mprv);
        bins leaf_global_and_nonleaf_any_umode1 = binsof(paging__ptw__cp_dside_leaf_ptw_global) intersect {1} &&
                                                binsof(paging__ptw__cp_dside_nonleaf_ptw_global)&&
                                                binsof(paging__privilege__cp_dside_eff_privilege_mode.effective_privilegemode_user_due_to_mprv);                                                                     
     }

    paging__satp__cr_satp_in_bare_mode: cross paging__csr__cp_satp_access, paging__satp__cp_asid, paging__satp__cp_modes, paging__satp__cp_ppn {
        option.cross_auto_bin_max   = 0;
        bins satp_access_in_baremode_with_ppnandasidzero = binsof(paging__csr__cp_satp_access)&&
                                                           binsof(paging__satp__cp_modes) intersect {0} &&
                                                           binsof(paging__satp__cp_asid) intersect {0} && 
                                                           binsof(paging__satp__cp_ppn) intersect {0};
        bins satp_access_in_baremode_with_ppn_asidnonzero = binsof(paging__csr__cp_satp_access)&&
                                                           binsof(paging__satp__cp_modes) intersect {0} &&
                                                           binsof(paging__satp__cp_asid) intersect {[1:$]} && 
                                                           binsof(paging__satp__cp_ppn);
        bins satp_access_in_baremode_with_ppnnonzero_asidzero = binsof(paging__csr__cp_satp_access)&&
                                                           binsof(paging__satp__cp_modes) intersect {0} &&
                                                           binsof(paging__satp__cp_asid) intersect {0} && 
                                                           binsof(paging__satp__cp_ppn)intersect {[1:$]};
        bins satp_access_in_baremode_with_ppnnonzero_asidnonzero = binsof(paging__csr__cp_satp_access)&&
                                                           binsof(paging__satp__cp_modes) intersect {0} &&
                                                           binsof(paging__satp__cp_asid) intersect {[1:$]} && 
                                                           binsof(paging__satp__cp_ppn)intersect {[1:$]};
    }

    paging__satp__cr_satp_accessibilty_in_privmodes: cross paging__csr__cp_satp_access, paging__privilege__cp_iside_privilege_mode
    {
        option.cross_auto_bin_max   = 0;
        bins legal_access_smode = binsof(paging__privilege__cp_iside_privilege_mode) intersect {PRIVILEGEMODE_SUPERVISOR} &&
                                     binsof(paging__csr__cp_satp_access);
        bins legal_access_mmode = binsof(paging__privilege__cp_iside_privilege_mode) intersect {PRIVILEGEMODE_MACHINE} &&
                                     binsof(paging__csr__cp_satp_access);
    }

    paging__ptw__cr_illegal_pc_bare: cross  paging__ptw__cp_virtual_pc_bitsel_signextbits_baremode, paging__satp__cp_modes {
        option.cross_auto_bin_max   = 0;
        bins illegal_pc_baremode = binsof(paging__ptw__cp_virtual_pc_bitsel_signextbits_baremode) && 
                          binsof(paging__satp__cp_modes.legal_satp_bare_mode);
    } 
    paging__ptw__cr_illegal_pc_sv39: cross  paging__ptw__cp_virtual_pc_bitsel_signextbits_sv39, paging__satp__cp_modes {
        option.cross_auto_bin_max   = 0;
        bins illegal_pc_non_baremode = binsof(paging__ptw__cp_virtual_pc_bitsel_signextbits_sv39) && 
                          binsof(paging__satp__cp_modes.legal_satp_modes) intersect {8};
    }
    paging__ptw__cr_illegal_pc_sv48: cross  paging__ptw__cp_virtual_pc_bitsel_signextbits_sv48, paging__satp__cp_modes {
        option.cross_auto_bin_max   = 0;
        bins illegal_pc_non_baremode = binsof(paging__ptw__cp_virtual_pc_bitsel_signextbits_sv48) && 
                          binsof(paging__satp__cp_modes.legal_satp_modes) intersect {9};
    }
    paging__ptw__cr_illegal_pc_sv57: cross  paging__ptw__cp_virtual_pc_bitsel_signextbits_sv57, paging__satp__cp_modes {
        option.cross_auto_bin_max   = 0;
        bins illegal_pc_non_baremode = binsof(paging__ptw__cp_virtual_pc_bitsel_signextbits_sv57) && 
                          binsof(paging__satp__cp_modes.legal_satp_modes) intersect {10};
    }

    paging__ptw__cr_illegal_ldstaddr_bare: cross  paging__ptw__cp_virtual_ldst_bitsel_signextbits_baremode, paging__satp__cp_modes {
        option.cross_auto_bin_max   = 0;
        bins illegal_pc_non_baremode = binsof(paging__ptw__cp_virtual_ldst_bitsel_signextbits_baremode) && 
                          binsof(paging__satp__cp_modes.legal_satp_bare_mode);
    }
    paging__ptw__cr_illegal_ldstaddr_sv39: cross  paging__ptw__cp_virtual_ldst_bitsel_signextbits_sv39, paging__satp__cp_modes {
        option.cross_auto_bin_max   = 0;
        bins illegal_pc_non_baremode = binsof(paging__ptw__cp_virtual_ldst_bitsel_signextbits_sv39) && 
                          binsof(paging__satp__cp_modes.legal_satp_modes) intersect {8};
    }
    paging__ptw__cr_illegal_ldstaddr_sv48: cross   paging__ptw__cp_virtual_ldst_bitsel_signextbits_sv48, paging__satp__cp_modes {
        option.cross_auto_bin_max   = 0;
        bins illegal_pc_non_baremode = binsof( paging__ptw__cp_virtual_ldst_bitsel_signextbits_sv48) && 
                          binsof(paging__satp__cp_modes.legal_satp_modes) intersect {9};
    }
    paging__ptw__cr_illegal_ldstaddr_sv57: cross   paging__ptw__cp_virtual_ldst_bitsel_signextbits_sv57, paging__satp__cp_modes {
        option.cross_auto_bin_max   = 0;
        bins illegal_pc_non_baremode = binsof( paging__ptw__cp_virtual_ldst_bitsel_signextbits_sv57) && 
                          binsof(paging__satp__cp_modes.legal_satp_modes) intersect {10};
    }

    paging__satp__cr_satp_access_is_illegal: cross paging__privilege__cp_iside_privilege_mode, paging__csr__cp_mstatus_tvm, paging__csr__cp_satp_access {
        option.cross_auto_bin_max   = 0; 
        bins satp_fault_in_s_mode = binsof(paging__privilege__cp_iside_privilege_mode) intersect {PRIVILEGEMODE_SUPERVISOR} &&
                                    binsof(paging__csr__cp_mstatus_tvm) && binsof(paging__csr__cp_satp_access.satp);
    }
    paging__satp__cr_satp_access_is_illegal_umode: cross paging__privilege__cp_iside_privilege_mode, paging__csr__cp_satp_access {
        option.cross_auto_bin_max   = 0; 
        bins satp_fault_in_u_mode = binsof(paging__privilege__cp_iside_privilege_mode) intersect {PRIVILEGEMODE_USER} && binsof(paging__csr__cp_satp_access.satp);
    }
     
    paging__ptw__cr_instruction_fault_in_user_mode: cross paging__privilege__cp_iside_privilege_mode, paging__ptw__cp_iside_leaf_ptw_exec, paging__ptw__cp_iside_leaf_ptw_user {
        option.cross_auto_bin_max   = 0;
        bins instruction_access_fault_in_u_mode_pte_u_zero = binsof(paging__privilege__cp_iside_privilege_mode) intersect {PRIVILEGEMODE_USER} &&
                                                  binsof(paging__ptw__cp_iside_leaf_ptw_exec) intersect {1} &&
                                                  binsof(paging__ptw__cp_iside_leaf_ptw_user) intersect {0};
    }

    paging__invalidation__cr_sfence_exec_in_privmodes: cross paging__invalidation__cp_sfence_instr, paging__privilege__cp_iside_privilege_mode
    {
        option.cross_auto_bin_max   = 0;
        bins legal_access_smode = binsof(paging__privilege__cp_iside_privilege_mode) intersect {PRIVILEGEMODE_SUPERVISOR} &&
                                     binsof(paging__invalidation__cp_sfence_instr);
        bins legal_access_mmode = binsof(paging__privilege__cp_iside_privilege_mode) intersect {PRIVILEGEMODE_MACHINE} &&
                                     binsof(paging__invalidation__cp_sfence_instr);
    }

    paging__invalidation__cr_sfence_access_is_illegal: cross paging__invalidation__cp_sfence_instr, paging__privilege__cp_iside_privilege_mode, paging__csr__cp_mstatus_tvm{
        option.cross_auto_bin_max   = 0;
        bins sfence_fault_in_s_mode = binsof(paging__invalidation__cp_sfence_instr) && 
                                    binsof(paging__privilege__cp_iside_privilege_mode) intersect {PRIVILEGEMODE_SUPERVISOR} &&
                                    binsof(paging__csr__cp_mstatus_tvm);
        bins sfence_fault_in_u_mode = binsof(paging__invalidation__cp_sfence_instr) && 
                                    binsof(paging__privilege__cp_iside_privilege_mode) intersect {PRIVILEGEMODE_USER};
    }
    paging__invalidation__cr_sfence_in_all_page_modes: cross  paging__invalidation__cp_sfence_instr, paging__satp__cp_modes{
        option.cross_auto_bin_max   = 0;
        bins sfence_in_bare_mode = binsof(paging__satp__cp_modes) intersect {0};
        bins sfence_in_sv39_mode = binsof(paging__satp__cp_modes) intersect {8};
        bins sfence_in_sv48_mode = binsof(paging__satp__cp_modes) intersect {9};
        bins sfence_in_sv57_mode = binsof(paging__satp__cp_modes) intersect {10};  
    }
    paging__invalidation__cp_sfence_rs1: coverpoint rs1 iff (instrenum_var == INSTRENUM_SFENCE_VMA) {
		bins int_source_bin_x0 = {0};
		bins int_source_bin_not_x0 = {[1:31]};
	}
	paging__invalidation__cp_sfence_rs2: coverpoint rs2 iff (instrenum_var == INSTRENUM_SFENCE_VMA) {
		bins int_source_bin_x0 = {0};
		bins int_source_bin_not_x0 = {[1:31]};
	}
    paging__invalidation__cr_sfencevma_all_types: cross paging__invalidation__cp_sfence_rs1, paging__invalidation__cp_sfence_rs2 {
        option.cross_auto_bin_max                   = 0;
        bins rs1x0_rs2x0 = binsof(paging__invalidation__cp_sfence_rs1.int_source_bin_x0) &&
                              binsof(paging__invalidation__cp_sfence_rs2.int_source_bin_x0);
        bins rs1x0_rs2notx0 = binsof(paging__invalidation__cp_sfence_rs1.int_source_bin_x0) &&
                              binsof(paging__invalidation__cp_sfence_rs2.int_source_bin_not_x0);
        bins rs1notx0_rs2x0 = binsof(paging__invalidation__cp_sfence_rs1.int_source_bin_not_x0) &&
                              binsof(paging__invalidation__cp_sfence_rs2.int_source_bin_x0);
        bins rs1notx0_rs2notx0 = binsof(paging__invalidation__cp_sfence_rs1.int_source_bin_not_x0) &&
                              binsof(paging__invalidation__cp_sfence_rs2.int_source_bin_not_x0);
    }
    
    paging__ptw__cp_exec_in_supervisormode_with_userbit_one: coverpoint DPTE_LeafU iff (privilegemode_var == PRIVILEGEMODE_SUPERVISOR){
        bins exec_in_supervisormode_with_userbit_one = {1};
    }
        
    paging__accesstype__cp__compressed_load: coverpoint cext_var {
        bins sp_loads   = {CEXT_C_LWSP, CEXT_C_LDSP, CEXT_C_FLDSP};
        bins reg_loads  = {CEXT_C_LW,CEXT_C_LD,CEXT_C_FLD};
        bins sp_stores  = {CEXT_C_SWSP, CEXT_C_SDSP, CEXT_C_FSDSP};
        bins reg_stores = {CEXT_C_SW,CEXT_C_SD,CEXT_C_FSD};
    }

endgroup

`endif
