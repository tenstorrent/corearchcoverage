//  SPDX-FileCopyrightText: © 2026 Tenstorrent AI ULC
//  SPDX-License-Identifier: Apache-2.0
`ifndef COVERAGE_UNSUPPORTED

import cp_pkg::*;

covergroup zjpm__cg with function sample(
        csr_cov_sample csr_access
);

    option.per_instance = 1;
    option.name         = "cg__zjpm";
    option.comment      = "Covergroups for ZJPM TP";

    zjpm__csr__cp_senvcfg_pmm_warl: coverpoint rs1_val[1:0] iff ((csr_op2_var==CSR_OP2_SENVCFG)) {
        bins res      = {1};
        bins pmlen16  = {3};
    }

    zjpm__csr__cp_henvcfg_pmm_warl: coverpoint rs1_val[1:0] iff ((csr_op2_var==CSR_OP2_HENVCFG)) {
        bins res      = {1};
        bins pmlen16  = {3};
    }

    zjpm__csr__cp_menvcfg_pmm_warl: coverpoint rs1_val[1:0] iff ((csr_op2_var==CSR_OP2_MENVCFG)) {
        bins res      = {1};
        bins pmlen16  = {3};
    }

    zjpm__csr__cp_mseccfg_pmm_warl: coverpoint rs1_val[1:0] iff ((csr_op2_var==CSR_OP2_MSECCFG)) {
        bins res      = {1};
        bins pmlen16  = {3};
    }

    zjpm__gen__cp_curpriv : coverpoint privilegemode_var {
        bins mmode  = {PRIVILEGEMODE_MACHINE};
        bins hsmode = {PRIVILEGEMODE_SUPERVISOR} iff (VirtualMode==0);
        bins umode  = {PRIVILEGEMODE_USER} iff (VirtualMode==0);
        bins vsmode = {PRIVILEGEMODE_SUPERVISOR} iff (VirtualMode==1);
        bins vumode = {PRIVILEGEMODE_USER} iff (VirtualMode==1);
    }
    zjpm__csr__cp_mstatus_mprv : coverpoint csr_access.mstatus_csr_inst.mprv{
        bins mprv_high          = {1};
        bins mprv_low           = {0};
    }
    zjpm__csr__cp_mstatus_mpv : coverpoint csr_access.mstatus_csr_inst.mpv{
        bins mpv_high          = {1};
        bins mpv_low           = {0};
    }
    zjpm__csr__cp_mstatus_mpp : coverpoint csr_access.mstatus_csr_inst.mpp{
        bins mpp_machine        = {3};
        bins mpp_supervisor     = {1};
        bins mpp_user           = {0};
    }
    zjpm__csr__cp_hstatus_spvp : coverpoint csr_access.hstatus_csr_inst.spvp{
        bins spvp_high           = {1};
        bins spvp_low            = {0};
    }
    zjpm__csr__cp_hstatus_hu : coverpoint csr_access.hstatus_csr_inst.hu{
        bins hu_high           = {1};
        bins hu_low            = {0};
    }
    
    zjpm__vsatp__cp_svmodes: coverpoint csr_access.vsatp_csr_inst.mode {
        bins bare = {0};
        bins svx = {8,9,10};
    }
    zjpm__satp__cp_svmodes: coverpoint csr_access.satp_csr_inst.mode {
        bins bare = {0};
        bins sv39 = {8};
        bins sv48 = {9};
        bins sv57 = {10};
    }
    zjpm__hgatp__cp_svmodes: coverpoint csr_access.hgatp_csr_inst.mode {
        bins bare = {0};
        bins sv39 = {8};
        bins sv48 = {9};
        bins sv57 = {10};
    }

    zjpm__privilege__cp_dside_eff_privilege_mode_vu: cross zjpm__gen__cp_curpriv, zjpm__csr__cp_mstatus_mprv, zjpm__csr__cp_mstatus_mpp, zjpm__csr__cp_mstatus_mpv {
        option.cross_auto_bin_max                               = 0;
        bins effective_priv_virtual_user                        = binsof(zjpm__gen__cp_curpriv.vumode);
        bins effective_priv_virtual_user_due_to_mprv            = binsof(zjpm__gen__cp_curpriv.mmode) &&
                                                                binsof(zjpm__csr__cp_mstatus_mpp.mpp_user) &&
                                                                binsof(zjpm__csr__cp_mstatus_mprv.mprv_high) &&
                                                                binsof(zjpm__csr__cp_mstatus_mpv.mpv_high);                                                         
    }

    zjpm__privilege__cp_dside_eff_privilege_mode_u: cross zjpm__gen__cp_curpriv, zjpm__csr__cp_mstatus_mprv, zjpm__csr__cp_mstatus_mpp, zjpm__csr__cp_mstatus_mpv {
        option.cross_auto_bin_max                               = 0;
        bins effective_priv_user                                = binsof(zjpm__gen__cp_curpriv.umode);
        bins effective_privilegemode_user_due_to_mprv           = binsof(zjpm__gen__cp_curpriv.mmode) &&
                                                                binsof(zjpm__csr__cp_mstatus_mpp.mpp_user) &&
                                                                binsof(zjpm__csr__cp_mstatus_mprv.mprv_high) &&
                                                                binsof(zjpm__csr__cp_mstatus_mpv.mpv_low);                                                            
    }

    zjpm__privilege__cp_dside_eff_privilege_mode_vs: cross zjpm__gen__cp_curpriv, zjpm__csr__cp_mstatus_mprv, zjpm__csr__cp_mstatus_mpp, zjpm__csr__cp_mstatus_mpv {
        option.cross_auto_bin_max                               = 0;
        bins effective_priv_virtual_supervisor                  = binsof(zjpm__gen__cp_curpriv.vsmode);
        bins effective_priv_virtual_supervisor_due_to_mprv      = binsof(zjpm__gen__cp_curpriv.mmode) &&
                                                                binsof(zjpm__csr__cp_mstatus_mpp.mpp_supervisor) &&
                                                                binsof(zjpm__csr__cp_mstatus_mprv.mprv_high) &&
                                                                binsof(zjpm__csr__cp_mstatus_mpv.mpv_high);                                                          
    }

    zjpm__privilege__cp_dside_eff_privilege_mode_hs: cross zjpm__gen__cp_curpriv, zjpm__csr__cp_mstatus_mprv, zjpm__csr__cp_mstatus_mpp, zjpm__csr__cp_mstatus_mpv {
        option.cross_auto_bin_max                               = 0;
        bins effective_priv_supervisor                  = binsof(zjpm__gen__cp_curpriv.hsmode);
        bins effective_priv_supervisor_due_to_mprv      = binsof(zjpm__gen__cp_curpriv.mmode) &&
                                                          binsof(zjpm__csr__cp_mstatus_mprv.mprv_high) &&
                                                          binsof(zjpm__csr__cp_mstatus_mpp.mpp_supervisor) &&
                                                          binsof(zjpm__csr__cp_mstatus_mpv.mpv_low);                                                             
    }

    zjpm__privilege__cp_dside_eff_privilege_mode_m: cross zjpm__gen__cp_curpriv, zjpm__csr__cp_mstatus_mprv, zjpm__csr__cp_mstatus_mpp {
        option.cross_auto_bin_max                               = 0;
        bins effective_priv_machine                     = binsof(zjpm__gen__cp_curpriv.mmode) &&
                                                          binsof(zjpm__csr__cp_mstatus_mprv.mprv_low);
        bins effective_priv_machine_due_to_mprv         = binsof(zjpm__gen__cp_curpriv.mmode) &&
                                                          binsof(zjpm__csr__cp_mstatus_mprv.mprv_high) &&
                                                          binsof(zjpm__csr__cp_mstatus_mpp.mpp_machine);                                                          
    }

    zjpm__csr__cp_senvcfg_pmm : coverpoint csr_access.senvcfg_csr_inst.pmm{
        bins pm_disabled                  = {0};
        bins pm_enabled_len_7             = {2};
    }
    
    zjpm__csr__cp_henvcfg_pmm : coverpoint csr_access.henvcfg_csr_inst.pmm{
        bins pm_disabled                  = {0};
        bins pm_enabled_len_7             = {2};
    }

    zjpm__csr__cp_menvcfg_pmm : coverpoint csr_access.menvcfg_csr_inst.pmm{
        bins pm_disabled                  = {0};
        bins pm_enabled_len_7             = {2};
    }

    zjpm__csr__cp_mseccfg_pmm : coverpoint csr_access.mseccfg_csr_inst.pmm{
        bins pm_disabled                  = {0};
        bins pm_enabled_len_7             = {2};
    }

    zjpm__ptw__cp_virtual_ldst_addr:  coverpoint VirtLdStAddr[63:57]{
        option.auto_bin_max = 1;
        bins vahi_1_126        = {[7'b1:7'b1111110]};
        bins vahi_0_127        = {7'b0,7'b1111111};
    }

    zjpm__ptw__nvbits_pa_bare: coverpoint PhysLdStAddr[56:52]{
        bins zero     = {5'b0};
        bins random   = {[5'b1:5'b11111]};
    }
    zjpm__ptw__nvbits_va_sv39: coverpoint VirtLdStAddr[56:38]{
        bins random       = {[19'b1:19'b1111111111111111110]};
        bins signext      = {19'b0,19'b111111111111111111};
    }
    zjpm__ptw__nvbits_va_sv48: coverpoint VirtLdStAddr[56:47]{
        bins random       = {[10'b1:10'b1111111110]};
        bins signext      = {10'b0,10'b1111111111};
    }

    zjpm__ptw__cp_virtual_ldst_addr_nvbits_satp: cross zjpm__satp__cp_svmodes, zjpm__ptw__nvbits_pa_bare, zjpm__ptw__nvbits_va_sv39, zjpm__ptw__nvbits_va_sv48 {
        option.cross_auto_bin_max                               = 0;   
        bins bare_nvbits_zero    = binsof(zjpm__satp__cp_svmodes.bare) && binsof(zjpm__ptw__nvbits_pa_bare.zero);
        bins bare_nvbits_nonzero = binsof(zjpm__satp__cp_svmodes.bare) && binsof(zjpm__ptw__nvbits_pa_bare.random);
        bins svx_random         = (binsof(zjpm__satp__cp_svmodes.sv48) && binsof(zjpm__ptw__nvbits_va_sv48.random)) || (binsof(zjpm__satp__cp_svmodes.sv39) && binsof(zjpm__ptw__nvbits_va_sv39.random));
        bins svx_signext        = (binsof(zjpm__satp__cp_svmodes.sv48) && binsof(zjpm__ptw__nvbits_va_sv48.signext)) || (binsof(zjpm__satp__cp_svmodes.sv39) && binsof(zjpm__ptw__nvbits_va_sv39.signext));

    }

    zjpm__ptw__cp_virtual_ldst_addr_nvbits_vsatp: cross zjpm__vsatp__cp_svmodes, zjpm__ptw__nvbits_pa_bare, zjpm__ptw__nvbits_va_sv39, zjpm__ptw__nvbits_va_sv48{
        option.cross_auto_bin_max                               = 0;    
        bins bare_nvbits_zero    = binsof(zjpm__vsatp__cp_svmodes.bare) && binsof(zjpm__ptw__nvbits_pa_bare.zero);
        bins bare_nvbits_nonzero = binsof(zjpm__vsatp__cp_svmodes.bare) && binsof(zjpm__ptw__nvbits_pa_bare.random);
        bins svx_random          = binsof(zjpm__vsatp__cp_svmodes.svx) && (binsof(zjpm__ptw__nvbits_va_sv39.random) || binsof(zjpm__ptw__nvbits_va_sv48.random));
        bins svx_signext         = binsof(zjpm__vsatp__cp_svmodes.svx) && (binsof(zjpm__ptw__nvbits_va_sv39.signext) || binsof(zjpm__ptw__nvbits_va_sv48.signext));
    }

    zjpm__ptw__cp_phys_ldst_addr_nvbits_satp_bare: cross zjpm__satp__cp_svmodes, zjpm__ptw__nvbits_pa_bare{
        option.cross_auto_bin_max                               = 0; 
        bins bare_nvbits_zero    = binsof(zjpm__satp__cp_svmodes.bare) && binsof(zjpm__ptw__nvbits_pa_bare.zero);
        bins bare_nvbits_nonzero = binsof(zjpm__satp__cp_svmodes.bare) && binsof(zjpm__ptw__nvbits_pa_bare.random);
    }

    zjpm__ptw__cp_physical_ldst_addr_pmlen:  coverpoint PhysLdStAddr[63:57]{
        option.auto_bin_max = 1;
        bins vahi_1_126        = {[7'b1:7'b1111110]};
        bins vahi_0_127        = {7'b0,7'b1111111};
    }

    zjpm__ptw__cp_physical_ldst_addr: coverpoint PhysLdStAddr{
        option.auto_bin_max = 1;
    }

    zjpm__gen__cp_hext_instr : coverpoint instrenum_var {
        bins h_inst         = {INSTRENUM_HLV_B,INSTRENUM_HLV_D, INSTRENUM_HLV_H, INSTRENUM_HLV_W, INSTRENUM_HLV_BU, INSTRENUM_HLV_HU, INSTRENUM_HLV_WU, INSTRENUM_HSV_B, INSTRENUM_HSV_D, INSTRENUM_HSV_H, INSTRENUM_HSV_W};
    }

    zjpm__csr__cp_pm_dis_vu_mode:  cross  zjpm__privilege__cp_dside_eff_privilege_mode_vu, zjpm__ptw__cp_virtual_ldst_addr iff(csr_access.senvcfg_csr_inst.pmm==2'b00)
    {
        ignore_bins eff_mode_due_to_mprv_vahi_random    = binsof(zjpm__privilege__cp_dside_eff_privilege_mode_vu.effective_priv_virtual_user_due_to_mprv) && 
                                                          binsof(zjpm__ptw__cp_virtual_ldst_addr.vahi_1_126);
    }

    zjpm__csr__cp_pm_dis_u_mode:   cross  zjpm__privilege__cp_dside_eff_privilege_mode_u,  zjpm__ptw__cp_virtual_ldst_addr iff(csr_access.senvcfg_csr_inst.pmm==2'b00)
    {
        ignore_bins eff_mode_due_to_mprv_vahi_random    = binsof(zjpm__privilege__cp_dside_eff_privilege_mode_u.effective_privilegemode_user_due_to_mprv) && 
                                                          binsof(zjpm__ptw__cp_virtual_ldst_addr.vahi_1_126);
    }   

    zjpm__csr__cp_pm_dis_vs_mode:  cross  zjpm__privilege__cp_dside_eff_privilege_mode_vs, zjpm__ptw__cp_virtual_ldst_addr iff(csr_access.henvcfg_csr_inst.pmm==2'b00)
    {
        ignore_bins eff_mode_due_to_mprv_vahi_random    = binsof(zjpm__privilege__cp_dside_eff_privilege_mode_vs.effective_priv_virtual_supervisor_due_to_mprv) && 
                                                          binsof(zjpm__ptw__cp_virtual_ldst_addr.vahi_1_126);
    }       

    zjpm__csr__cp_pm_dis_u_mode_hlv_hsv: cross zjpm__ptw__cp_virtual_ldst_addr, zjpm__gen__cp_hext_instr iff (privilegemode_var==PRIVILEGEMODE_USER && csr_access.hstatus_csr_inst.hupmm==2'b00) ;                                       

    zjpm__csr__cp_pm_dis_hlvx: coverpoint VirtLdStAddr[63:56] iff ((instrenum_var==INSTRENUM_HLVX_HU || instrenum_var==INSTRENUM_HLVX_WU) && (csr_access.menvcfg_csr_inst.pmm==2'b10 || csr_access.henvcfg_csr_inst.pmm==2'b10)){
        bins canonical_va = {8'b0,8'b11111111};
        bins non_canonical = {[8'b1:8'b11111110]};
    }

    zjpm__csr__cp_pm_dis_hs_mode:  cross  zjpm__privilege__cp_dside_eff_privilege_mode_hs, zjpm__ptw__cp_virtual_ldst_addr iff (csr_access.menvcfg_csr_inst.pmm==2'b00)
    {
        ignore_bins eff_mode_due_to_mprv_vahi_random    = binsof(zjpm__privilege__cp_dside_eff_privilege_mode_hs.effective_priv_supervisor_due_to_mprv) && 
                                                          binsof(zjpm__ptw__cp_virtual_ldst_addr.vahi_1_126);
    }          

    zjpm__csr__cp_pm_dis_m_mode:   cross  zjpm__privilege__cp_dside_eff_privilege_mode_m, zjpm__ptw__cp_physical_ldst_addr_pmlen iff (csr_access.mseccfg_csr_inst.pmm==2'b00);                                        

    zjpm__csr__cp_pm_dis_vu_mode_hlv_hsv_1: cross zjpm__ptw__cp_virtual_ldst_addr, zjpm__gen__cp_hext_instr iff (csr_access.hstatus_csr_inst.spvp==1'b0 && csr_access.senvcfg_csr_inst.pmm==2'b00 && (privilegemode_var==PRIVILEGEMODE_MACHINE || privilegemode_var==PRIVILEGEMODE_SUPERVISOR) && (VirtualMode==0));

    zjpm__csr__cp_pm_dis_vu_mode_hlv_hsv_2: cross zjpm__ptw__cp_virtual_ldst_addr, zjpm__gen__cp_hext_instr iff (privilegemode_var==PRIVILEGEMODE_USER && csr_access.hstatus_csr_inst.hupmm==2'b10 && csr_access.hstatus_csr_inst.spvp==1'b0 && (VirtualMode==0)) ;                              

    zjpm__csr__cp_pm_dis_vs_mode_hlv_hsv: cross zjpm__ptw__cp_virtual_ldst_addr, zjpm__gen__cp_hext_instr iff ((csr_access.hstatus_csr_inst.spvp==1'b1) && csr_access.henvcfg_csr_inst.pmm==2'b00  && (privilegemode_var==PRIVILEGEMODE_MACHINE || privilegemode_var==PRIVILEGEMODE_SUPERVISOR || privilegemode_var==PRIVILEGEMODE_USER) && (VirtualMode==0));
                                                                                       
    zjpm__csr__cp_pm_en_hs_mode: cross  zjpm__privilege__cp_dside_eff_privilege_mode_hs, zjpm__ptw__cp_virtual_ldst_addr, zjpm__satp__cp_svmodes iff(csr_access.menvcfg_csr_inst.pmm==2'b10);                                                   

    zjpm__csr__cp_pm_en_u_mode: cross  zjpm__privilege__cp_dside_eff_privilege_mode_u, zjpm__ptw__cp_virtual_ldst_addr, zjpm__satp__cp_svmodes iff(csr_access.senvcfg_csr_inst.pmm==2'b10);                                                        

    zjpm__csr__cp_pm_en_vs_mode:  cross  zjpm__privilege__cp_dside_eff_privilege_mode_vs, zjpm__hgatp__cp_svmodes, zjpm__ptw__cp_virtual_ldst_addr, zjpm__vsatp__cp_svmodes iff(csr_access.henvcfg_csr_inst.pmm==2'b10);                                            

    zjpm__csr__cp_pm_en_vs_mode_hlv_hsv_v1: cross zjpm__hgatp__cp_svmodes, zjpm__ptw__cp_virtual_ldst_addr, zjpm__gen__cp_hext_instr iff ((csr_access.hstatus_csr_inst.spvp==1'b1) && csr_access.henvcfg_csr_inst.pmm==2'b00  && (privilegemode_var==PRIVILEGEMODE_MACHINE || privilegemode_var==PRIVILEGEMODE_SUPERVISOR || privilegemode_var==PRIVILEGEMODE_USER) && (VirtualMode==0));

    zjpm__csr__cp_pm_en_vu_mode:  cross  zjpm__privilege__cp_dside_eff_privilege_mode_vu, zjpm__hgatp__cp_svmodes, zjpm__ptw__cp_virtual_ldst_addr, zjpm__vsatp__cp_svmodes iff(csr_access.senvcfg_csr_inst.pmm==2'b10) ;                                                        

    zjpm__csr__cp_pm_en_vu_mode_hlv_hsv_1: cross zjpm__hgatp__cp_svmodes, zjpm__ptw__cp_virtual_ldst_addr, zjpm__gen__cp_hext_instr, zjpm__vsatp__cp_svmodes iff (csr_access.hstatus_csr_inst.spvp==1'b0 && csr_access.senvcfg_csr_inst.pmm==2'b10 && (privilegemode_var==PRIVILEGEMODE_MACHINE || privilegemode_var==PRIVILEGEMODE_SUPERVISOR) && VirtualMode==0); 

    zjpm__csr__cp_pm_en_vu_mode_hlv_hsv_2: cross zjpm__hgatp__cp_svmodes, zjpm__ptw__cp_virtual_ldst_addr, zjpm__gen__cp_hext_instr, zjpm__vsatp__cp_svmodes iff (privilegemode_var==PRIVILEGEMODE_USER && csr_access.hstatus_csr_inst.hupmm==2'b10 && csr_access.hstatus_csr_inst.spvp==1'b0 && (VirtualMode==0)) ;                              

    zjpm__csr__cp_pm_en_m_mode:  cross  zjpm__privilege__cp_dside_eff_privilege_mode_m,  zjpm__ptw__cp_physical_ldst_addr_pmlen iff(csr_access.mseccfg_csr_inst.pmm==2'b10) ;                                                          

    zjpm__csr__cp_pm_en_dis_mprv_ssnpm_senvcfg: cross  zjpm__csr__cp_senvcfg_pmm, zjpm__csr__cp_mstatus_mpp, zjpm__csr__cp_mstatus_mpv iff ((privilegemode_var==PRIVILEGEMODE_MACHINE) && (csr_access.mstatus_csr_inst.mprv==1 ))  {                                                          
        option.cross_auto_bin_max                               = 0;
        bins mpv0_mpp_U_dis           = binsof(zjpm__csr__cp_mstatus_mpp.mpp_user) &&
                                        binsof(zjpm__csr__cp_mstatus_mpv.mpv_low) &&
                                        binsof(zjpm__csr__cp_senvcfg_pmm.pm_disabled);
        bins mpv0_mpp_U_en            = binsof(zjpm__csr__cp_mstatus_mpp.mpp_user) &&
                                        binsof(zjpm__csr__cp_mstatus_mpv.mpv_low) &&
                                        binsof(zjpm__csr__cp_senvcfg_pmm.pm_enabled_len_7);
        bins mpv1_mpp_U_dis           = binsof(zjpm__csr__cp_mstatus_mpp.mpp_user) &&
                                        binsof(zjpm__csr__cp_mstatus_mpv.mpv_high) &&
                                        binsof(zjpm__csr__cp_senvcfg_pmm.pm_disabled);
        bins mpv1_mpp_U_en            = binsof(zjpm__csr__cp_mstatus_mpp.mpp_user) &&
                                        binsof(zjpm__csr__cp_mstatus_mpv.mpv_high) &&
                                        binsof(zjpm__csr__cp_senvcfg_pmm.pm_enabled_len_7);
    }
    zjpm__csr__cp_pm_en_dis_mprv_ssnpm_henvcfg: cross  zjpm__csr__cp_henvcfg_pmm, zjpm__csr__cp_mstatus_mpp, zjpm__csr__cp_mstatus_mpv iff ((privilegemode_var==PRIVILEGEMODE_MACHINE) && (csr_access.mstatus_csr_inst.mprv==1 ))  {                                                          
        option.cross_auto_bin_max                               = 0;
        bins mpv1_mpp_S_dis           = binsof(zjpm__csr__cp_mstatus_mpp.mpp_supervisor) &&
                                        binsof(zjpm__csr__cp_mstatus_mpv.mpv_high) &&
                                        binsof(zjpm__csr__cp_henvcfg_pmm.pm_disabled);
        bins mpv1_mpp_S_en            = binsof(zjpm__csr__cp_mstatus_mpp.mpp_supervisor) &&
                                        binsof(zjpm__csr__cp_mstatus_mpv.mpv_high) &&
                                        binsof(zjpm__csr__cp_henvcfg_pmm.pm_enabled_len_7);
    }     

    zjpm__csr__cp_pm_en_dis_mprv_ssnpm: cross  zjpm__csr__cp_menvcfg_pmm, zjpm__csr__cp_mstatus_mpp, zjpm__csr__cp_mstatus_mpv iff ((privilegemode_var==PRIVILEGEMODE_MACHINE) && (csr_access.mstatus_csr_inst.mprv==1 ))  {                                                         
        option.cross_auto_bin_max                               = 0;
        bins mpv0_mpp_S_dis           = binsof(zjpm__csr__cp_mstatus_mpp.mpp_supervisor) &&
                                        binsof(zjpm__csr__cp_mstatus_mpv.mpv_low) &&
                                        binsof(zjpm__csr__cp_menvcfg_pmm.pm_disabled);
        bins mpv0_mpp_S_en            = binsof(zjpm__csr__cp_mstatus_mpp.mpp_supervisor) &&
                                        binsof(zjpm__csr__cp_mstatus_mpv.mpv_low) &&
                                        binsof(zjpm__csr__cp_menvcfg_pmm.pm_enabled_len_7);
    }                                              

    zjpm__csr__cp_pm_en_dis_mprv_smmpm: cross  zjpm__csr__cp_mseccfg_pmm, zjpm__csr__cp_mstatus_mpp, zjpm__csr__cp_mstatus_mpv iff ((privilegemode_var==PRIVILEGEMODE_MACHINE) && (csr_access.mstatus_csr_inst.mprv==1 ))  {                                                         
        option.cross_auto_bin_max                               = 0;
        bins mpv0_mpp_M_dis           = binsof(zjpm__csr__cp_mstatus_mpp.mpp_machine) &&
                                        binsof(zjpm__csr__cp_mstatus_mpv.mpv_low) &&
                                        binsof(zjpm__csr__cp_mseccfg_pmm.pm_disabled);
        bins mpv0_mpp_M_en            = binsof(zjpm__csr__cp_mstatus_mpp.mpp_machine) &&
                                        binsof(zjpm__csr__cp_mstatus_mpv.mpv_low) &&
                                        binsof(zjpm__csr__cp_mseccfg_pmm.pm_enabled_len_7);
    }      

    zjpm__ptw__cp_virtual_ldst_addr_nopm:  coverpoint VirtLdStAddr[63:57]{
        option.auto_bin_max = 1;
        bins vahi_0_127        = {7'b0,7'b1111111};
        bins vahi_1_126        = {[7'b1:7'b1111110]};
    }  

    zjpm__ptw__cp_phys_ldst_addr_nopm:  coverpoint PhysLdStAddr[63:57]{
        option.auto_bin_max = 1;
        bins pahi_0_127        = {7'b0,7'b1111111};
        bins pahi_1_126        = {[7'b1:7'b1111110]};
    }

    zjpm__csr__cp_pm_mstatus_mxr_mmode:   cross zjpm__privilege__cp_dside_eff_privilege_mode_m, zjpm__ptw__cp_phys_ldst_addr_nopm    iff (csr_access.mseccfg_csr_inst.pmm==2'b10 && csr_access.mstatus_csr_inst.mxr==1) ;

    zjpm__csr__cp_pm_mstatus_mxr_hsmode:  cross zjpm__privilege__cp_dside_eff_privilege_mode_hs, zjpm__ptw__cp_virtual_ldst_addr_nopm   iff (csr_access.menvcfg_csr_inst.pmm==2'b10 && csr_access.mstatus_csr_inst.mxr==1)
    {
        ignore_bins eff_mode_due_to_mprv_vahi_random    = binsof(zjpm__privilege__cp_dside_eff_privilege_mode_hs.effective_priv_supervisor_due_to_mprv) && 
                                                          binsof(zjpm__ptw__cp_virtual_ldst_addr_nopm.vahi_1_126);
    }    

    zjpm__csr__cp_pm_sstatus_mxr_umode:   cross zjpm__privilege__cp_dside_eff_privilege_mode_u, zjpm__ptw__cp_virtual_ldst_addr_nopm    iff (csr_access.senvcfg_csr_inst.pmm==2'b10 && csr_access.sstatus_csr_inst.mxr==1)
    {
        ignore_bins eff_mode_due_to_mprv_vahi_random    = binsof(zjpm__privilege__cp_dside_eff_privilege_mode_u.effective_privilegemode_user_due_to_mprv) && 
                                                          binsof(zjpm__ptw__cp_virtual_ldst_addr_nopm.vahi_1_126);
    }  

    zjpm__csr__cp_pm_vsstatus_mxr_vumode: cross zjpm__privilege__cp_dside_eff_privilege_mode_vu, zjpm__ptw__cp_virtual_ldst_addr_nopm   iff (csr_access.senvcfg_csr_inst.pmm==2'b10 && csr_access.vsstatus_csr_inst.mxr==1)
    {
        ignore_bins eff_mode_due_to_mprv_vahi_random    = binsof(zjpm__privilege__cp_dside_eff_privilege_mode_vu.effective_priv_virtual_user_due_to_mprv) && 
                                                          binsof(zjpm__ptw__cp_virtual_ldst_addr_nopm.vahi_1_126);
    }  

    zjpm__csr__cp_pm_vsstatus_mxr_vsmode: cross zjpm__privilege__cp_dside_eff_privilege_mode_vs, zjpm__ptw__cp_virtual_ldst_addr_nopm   iff (csr_access.henvcfg_csr_inst.pmm==2'b10 && csr_access.vsstatus_csr_inst.mxr==1)
    {
        ignore_bins eff_mode_due_to_mprv_vahi_random    = binsof(zjpm__privilege__cp_dside_eff_privilege_mode_vs.effective_priv_virtual_supervisor_due_to_mprv) && 
                                                          binsof(zjpm__ptw__cp_virtual_ldst_addr_nopm.vahi_1_126);
    }    

    zjpm__cp_dside_eff_priv_mode_due_to_mprv_prev:  coverpoint privilegemode_var {
        bins eff_priv_virtual_user_due_to_mprv            = {PRIVILEGEMODE_MACHINE} iff (prev_mstatus_csr[12:11]==2'b00 &&  prev_mstatus_csr[17]==1'b1 && prev_mstatus_csr[39]==1'b1);
        bins eff_privilegemode_user_due_to_mprv           = {PRIVILEGEMODE_MACHINE} iff (prev_mstatus_csr[12:11]==2'b00 &&  prev_mstatus_csr[17]==1'b1 && prev_mstatus_csr[39]==1'b0);
        bins eff_priv_virtual_supervisor_due_to_mprv      = {PRIVILEGEMODE_MACHINE} iff (prev_mstatus_csr[12:11]==2'b01 &&  prev_mstatus_csr[17]==1'b1 && prev_mstatus_csr[39]==1'b1);
        bins eff_priv_supervisor_due_to_mprv              = {PRIVILEGEMODE_MACHINE} iff (prev_mstatus_csr[12:11]==2'b01 &&  prev_mstatus_csr[17]==1'b1 && prev_mstatus_csr[39]==1'b0);
    }    

    zjpm__pm_dis_eff_mode_due_to_mprv_vahi_random: cross zjpm__cp_dside_eff_priv_mode_due_to_mprv_prev, zjpm__ptw__cp_virtual_ldst_addr_nopm {
        option.cross_auto_bin_max           = 0;
        bins pm_dis_vu_mode                 = binsof(zjpm__cp_dside_eff_priv_mode_due_to_mprv_prev.eff_priv_virtual_user_due_to_mprv) && binsof(zjpm__ptw__cp_virtual_ldst_addr_nopm.vahi_1_126) iff(csr_access.senvcfg_csr_inst.pmm==2'b00); 
        bins pm_dis_u_mode                  = binsof(zjpm__cp_dside_eff_priv_mode_due_to_mprv_prev.eff_privilegemode_user_due_to_mprv) && binsof(zjpm__ptw__cp_virtual_ldst_addr_nopm.vahi_1_126) iff(csr_access.senvcfg_csr_inst.pmm==2'b00);
        bins pm_dis_vs_mode                 = binsof(zjpm__cp_dside_eff_priv_mode_due_to_mprv_prev.eff_priv_virtual_supervisor_due_to_mprv) && binsof(zjpm__ptw__cp_virtual_ldst_addr_nopm.vahi_1_126) iff(csr_access.henvcfg_csr_inst.pmm==2'b00);
        bins pm_dis_s_mode                  = binsof(zjpm__cp_dside_eff_priv_mode_due_to_mprv_prev.eff_priv_supervisor_due_to_mprv) && binsof(zjpm__ptw__cp_virtual_ldst_addr_nopm.vahi_1_126) iff (csr_access.menvcfg_csr_inst.pmm==2'b00);
    }

    zjpm__pm_dis_MXR_eff_mode_due_to_mprv_vahi_random: cross zjpm__cp_dside_eff_priv_mode_due_to_mprv_prev, zjpm__ptw__cp_virtual_ldst_addr_nopm {
        option.cross_auto_bin_max           = 0;
        bins pm_dis_vu_mode                 = binsof(zjpm__cp_dside_eff_priv_mode_due_to_mprv_prev.eff_priv_virtual_user_due_to_mprv) && binsof(zjpm__ptw__cp_virtual_ldst_addr_nopm.vahi_1_126) iff (csr_access.senvcfg_csr_inst.pmm==2'b10 && csr_access.vsstatus_csr_inst.mxr==1); 
        bins pm_dis_u_mode                  = binsof(zjpm__cp_dside_eff_priv_mode_due_to_mprv_prev.eff_privilegemode_user_due_to_mprv) && binsof(zjpm__ptw__cp_virtual_ldst_addr_nopm.vahi_1_126) iff (csr_access.senvcfg_csr_inst.pmm==2'b10 && csr_access.sstatus_csr_inst.mxr==1) ;
        bins pm_dis_vs_mode                 = binsof(zjpm__cp_dside_eff_priv_mode_due_to_mprv_prev.eff_priv_virtual_supervisor_due_to_mprv) && binsof(zjpm__ptw__cp_virtual_ldst_addr_nopm.vahi_1_126) iff (csr_access.henvcfg_csr_inst.pmm==2'b10 && csr_access.vsstatus_csr_inst.mxr==1); 
        bins pm_dis_s_mode                  = binsof(zjpm__cp_dside_eff_priv_mode_due_to_mprv_prev.eff_priv_supervisor_due_to_mprv) && binsof(zjpm__ptw__cp_virtual_ldst_addr_nopm.vahi_1_126) iff (csr_access.menvcfg_csr_inst.pmm==2'b10 && csr_access.mstatus_csr_inst.mxr==1) ; 
    }
    
    zjpm__gen__cp_inval_fence_instr : coverpoint instrenum_var {
        bins xfence             = {INSTRENUM_HFENCE_GVMA,INSTRENUM_HFENCE_VVMA,INSTRENUM_SFENCE_INVAL_IR,INSTRENUM_SFENCE_VMA,INSTRENUM_SFENCE_W_INVAL};
        bins xinval             = {INSTRENUM_HINVAL_GVMA,INSTRENUM_HINVAL_VVMA, INSTRENUM_SINVAL_VMA};
    }

    zjpm__gen__rs2_val_sv39: coverpoint rs2_val[63:38]{
        bins signext      = {26'b0,26'b1111111111111111111111111};
    }
    zjpm__gen__rs2_val_bare: coverpoint rs2_val[63:52]{
        bins signext      = {12'b0,12'b111111111111};
    }
    zjpm__gen__rs2_val_sv48: coverpoint rs2_val[63:47]{
        bins signext      = {17'b0,17'b11111111111111111};
    }
    zjpm__gen__rs2_val_sv57: coverpoint rs2_val[63:56]{
        bins signext      = {8'b0,8'b11111111};
    }

    zjpm__gen__cp_rs2_val_inval_fence_satp: cross zjpm__satp__cp_svmodes, zjpm__gen__rs2_val_sv39, zjpm__gen__rs2_val_bare, zjpm__gen__rs2_val_sv48, zjpm__gen__rs2_val_sv57 {
        option.cross_auto_bin_max                               = 0;  
        bins bare_signext   = binsof(zjpm__satp__cp_svmodes.bare) && binsof(zjpm__gen__rs2_val_bare.signext);
        bins svx_signext   = (binsof(zjpm__satp__cp_svmodes.sv39) && binsof(zjpm__gen__rs2_val_sv39.signext)) || (binsof(zjpm__satp__cp_svmodes.sv48) && binsof(zjpm__gen__rs2_val_sv48.signext)) || (binsof(zjpm__satp__cp_svmodes.sv57) && binsof(zjpm__gen__rs2_val_sv57.signext)) ;
    }

    zjpm__gen__cp_rs2_val_inval_fence_vsatp: cross zjpm__vsatp__cp_svmodes, zjpm__gen__rs2_val_sv39, zjpm__gen__rs2_val_bare, zjpm__gen__rs2_val_sv48, zjpm__gen__rs2_val_sv57 {
        option.cross_auto_bin_max                               = 0;  
        bins bare_signext   = binsof(zjpm__vsatp__cp_svmodes.bare) && binsof(zjpm__gen__rs2_val_bare.signext);
        bins svx_signext    = binsof(zjpm__vsatp__cp_svmodes.svx) && (binsof(zjpm__gen__rs2_val_sv39.signext) || binsof(zjpm__gen__rs2_val_sv48.signext) || binsof(zjpm__gen__rs2_val_sv57.signext)) ;
    }

    zjpm__gen__access_inval_fence_m_hs: cross zjpm__gen__cp_inval_fence_instr, zjpm__gen__cp_rs2_val_inval_fence_satp iff (csr_access.mseccfg_csr_inst.pmm==2'b10 || csr_access.menvcfg_csr_inst.pmm==2'b10);
    zjpm__gen__access_inval_fence_vs: cross zjpm__gen__cp_inval_fence_instr, zjpm__gen__cp_rs2_val_inval_fence_vsatp, zjpm__hgatp__cp_svmodes iff (csr_access.henvcfg_csr_inst.pmm==2'b10);

    zjpm__instr__cp_instruction_set: coverpoint instrenum_var iff ((csr_access.mseccfg_csr_inst.pmm==2'b10 && privilegemode_var==PRIVILEGEMODE_MACHINE) || (csr_access.menvcfg_csr_inst.pmm==2'b10 && privilegemode_var==PRIVILEGEMODE_SUPERVISOR && (VirtualMode==0)) || (csr_access.henvcfg_csr_inst.pmm==2'b10 && privilegemode_var==PRIVILEGEMODE_SUPERVISOR && (VirtualMode==1)) || (csr_access.senvcfg_csr_inst.pmm==2'b10 && privilegemode_var==PRIVILEGEMODE_USER)) {
        option.auto_bin_max = 1;
        bins normal_ld_st           = {[0:$]}  iff (match_instr_load || match_instr_store);
        bins atomics                = {[0:$]}  iff (match_aext);
        bins mem_management         = {[0:$]}  iff (match_mem_sync==1);
        bins hext_mem_management    = {[0:$]}  iff (match_hext_mem_sync==1);
        bins hext_instr             = {[0:$]}  iff (match_hext_ld_st==1);
        bins zicboz_instr           = {[0:$]}  iff (match_zicbozext==1);
        bins zicbom_instr           = {[0:$]}  iff (match_zicbomext==1);
    }

    zjpm__ptw__cp_misaligned_access: coverpoint LdStMisal iff ((csr_access.mseccfg_csr_inst.pmm==2'b10 && privilegemode_var==PRIVILEGEMODE_MACHINE) || (csr_access.menvcfg_csr_inst.pmm==2'b10 && privilegemode_var==PRIVILEGEMODE_SUPERVISOR && (VirtualMode==0)) || (csr_access.henvcfg_csr_inst.pmm==2'b10 && privilegemode_var==PRIVILEGEMODE_SUPERVISOR && (VirtualMode==1)) || (csr_access.senvcfg_csr_inst.pmm==2'b10 && privilegemode_var==PRIVILEGEMODE_USER)) ;

    zjpm__gen__cp_implicit_access_instr : coverpoint instrenum_var {
        bins jump    = {INSTRENUM_JALR, INSTRENUM_JAL};
        bins branch  = {INSTRENUM_BEQ, INSTRENUM_BNE, INSTRENUM_BLT, INSTRENUM_BGE};
    }

    zjpm__gen__rs2_val_pmlen_bits: coverpoint rs2_val[63:57]{
        bins pmlen     = {7'b0,7'b1111111};
    }
                                                                                     
    zjpm__instr__implicit_access: cross zjpm__gen__cp_implicit_access_instr, zjpm__gen__rs2_val_pmlen_bits iff( ((csr_access.mseccfg_csr_inst.pmm==2'b10 && privilegemode_var==PRIVILEGEMODE_MACHINE) || (csr_access.menvcfg_csr_inst.pmm==2'b10 && privilegemode_var==PRIVILEGEMODE_SUPERVISOR && (VirtualMode==0)) || (csr_access.henvcfg_csr_inst.pmm==2'b10 && privilegemode_var==PRIVILEGEMODE_SUPERVISOR && (VirtualMode==1)) || (csr_access.senvcfg_csr_inst.pmm==2'b10 && privilegemode_var==PRIVILEGEMODE_USER)) );

    zjpm__csr__pm_en_faults_M_mode: coverpoint exception_var iff (csr_access.mseccfg_csr_inst.pmm==2'b10 && privilegemode_var==PRIVILEGEMODE_MACHINE && (PhysLdStAddr[63:57]!=7'b0 || PhysLdStAddr[63:57]!=7'b1111111))  {
        bins access_faults = {EXCEPTION_LOAD_ACC_FAULT, EXCEPTION_STORE_ACC_FAULT, EXCEPTION_INST_ACC_FAULT};
    }

    zjpm__csr__pm_en_faults_HS_mode: coverpoint exception_var iff (csr_access.menvcfg_csr_inst.pmm==2'b10 && privilegemode_var==PRIVILEGEMODE_SUPERVISOR && (VirtualMode==0) && (VirtLdStAddr[63:57]!=7'b0 || VirtLdStAddr[63:57]!=7'b1111111))  {
        bins access_faults = {EXCEPTION_LOAD_ACC_FAULT, EXCEPTION_STORE_ACC_FAULT, EXCEPTION_INST_ACC_FAULT};
        bins page_faults = {EXCEPTION_LOAD_PAGE_FAULT, EXCEPTION_STORE_PAGE_FAULT, EXCEPTION_INST_PAGE_FAULT};
    }

    zjpm__csr__pm_en_faults_VS_mode: coverpoint exception_var iff (csr_access.henvcfg_csr_inst.pmm==2'b10 && privilegemode_var==PRIVILEGEMODE_SUPERVISOR && (VirtualMode==1) && (VirtLdStAddr[63:57]!=7'b0 || VirtLdStAddr[63:57]!=7'b1111111))  {
        bins access_faults = {EXCEPTION_LOAD_ACC_FAULT, EXCEPTION_STORE_ACC_FAULT, EXCEPTION_INST_ACC_FAULT};
        bins page_faults = {EXCEPTION_LOAD_PAGE_FAULT, EXCEPTION_STORE_PAGE_FAULT, EXCEPTION_INST_PAGE_FAULT};
    }

    zjpm__csr__pm_en_faults_U_VU_mode: coverpoint exception_var iff (csr_access.senvcfg_csr_inst.pmm==2'b10 && privilegemode_var==PRIVILEGEMODE_USER && (VirtLdStAddr[63:57]!=7'b0 || VirtLdStAddr[63:57]!=7'b1111111))  {
        bins access_faults = {EXCEPTION_LOAD_ACC_FAULT, EXCEPTION_STORE_ACC_FAULT, EXCEPTION_INST_ACC_FAULT};
        bins page_faults = {EXCEPTION_LOAD_PAGE_FAULT, EXCEPTION_STORE_PAGE_FAULT, EXCEPTION_INST_PAGE_FAULT};
    }

    zjpm__csr__pm_xtvec: coverpoint match_excp iff ((csr_access.mseccfg_csr_inst.pmm==2'b10  && (csr_access.mtvec_csr_inst.base[61:55]!=7'b0 || csr_access.mtvec_csr_inst.base[61:55]!=7'b1111111)) ||(csr_access.menvcfg_csr_inst.pmm==2'b10  && (csr_access.stvec_csr_inst.base[61:55]!=7'b0 || csr_access.stvec_csr_inst.base[61:55]!=7'b1111111)));

    zjpm__csr__pm_spvp_mmode:  cross zjpm__csr__cp_hstatus_spvp, zjpm__csr__cp_mseccfg_pmm iff ((match_hext_ld_st==1) && (privilegemode_var==PRIVILEGEMODE_MACHINE)) ;
    zjpm__csr__pm_spvp_hsmode: cross zjpm__csr__cp_hstatus_spvp, zjpm__csr__cp_menvcfg_pmm iff ((match_hext_ld_st==1) && (privilegemode_var==PRIVILEGEMODE_SUPERVISOR)) ;
    zjpm__csr__pm_spvp_umode:  cross zjpm__csr__cp_hstatus_spvp, zjpm__csr__cp_senvcfg_pmm iff ((match_hext_ld_st==1) && (privilegemode_var==PRIVILEGEMODE_USER)) ;

    zjpm__gen__breakp_excp: coverpoint exception_var{
        bins BEAKPOINT= {EXCEPTION_BREAKP};
    }                                                                           
    zjpm__gen__pm_breakp_satp: cross zjpm__gen__breakp_excp, zjpm__satp__cp_svmodes iff (csr_access.menvcfg_csr_inst.pmm==2'b10);
    zjpm__gen__pm_breakp_vsatp: cross zjpm__gen__breakp_excp, zjpm__hgatp__cp_svmodes, zjpm__vsatp__cp_svmodes iff (csr_access.menvcfg_csr_inst.pmm==2'b10);
    


endgroup 

`endif
