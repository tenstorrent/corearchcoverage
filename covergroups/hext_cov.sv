
//  SPDX-FileCopyrightText: © 2026 Tenstorrent AI ULC
//  SPDX-License-Identifier: Apache-2.0
`ifndef COVERAGE_UNSUPPORTED

import cp_pkg::*;
import user_cov_common::*;

covergroup hext__cg with function sample(
        csr_cov_sample i_csr_cov_sample
);

    option.per_instance = 1;
    option.name         = "cg__hext";
    option.comment      = "Covergroups for Hypervisor Exceptions & 2-Level Translations (Paging) TP";

    hext__gen__cp_curpriv : coverpoint privilegemode_var {
        bins mmode  = {PRIVILEGEMODE_MACHINE};
        bins hsmode = {PRIVILEGEMODE_SUPERVISOR} iff (VirtualMode == 0);
        bins umode  = {PRIVILEGEMODE_USER}       iff (VirtualMode == 0);
        bins vsmode = {PRIVILEGEMODE_SUPERVISOR} iff (VirtualMode == 1);
        bins vumode = {PRIVILEGEMODE_USER}       iff (VirtualMode == 1);
    }

    hext__gen__cp__vumode : coverpoint privilegemode_var {
        option.weight = 0;
        bins vumode = {PRIVILEGEMODE_USER} iff (VirtualMode == 1);
    }

    hext__gen__cp__humode : coverpoint privilegemode_var {
        bins umode = {PRIVILEGEMODE_USER} iff (VirtualMode == 0);
    }

    hext__gen__cp__vsmode : coverpoint privilegemode_var{
        bins vsmode = {PRIVILEGEMODE_SUPERVISOR} iff (VirtualMode == 1);
    }

    hext__gen__cp__hsmode : coverpoint privilegemode_var{
        bins vsmode = {PRIVILEGEMODE_SUPERVISOR} iff (VirtualMode == 0);
    }
    
    hext__gen__cp__mmode : coverpoint privilegemode_var{
        bins mmode = {PRIVILEGEMODE_MACHINE};
    }

    hext__gen__cp_nxtpriv : coverpoint nextprivilegemode_var {
        bins nxt_mmode  = {NEXTPRIVILEGEMODE_MACHINE};
        bins nxt_hsmode = {NEXTPRIVILEGEMODE_SUPERVISOR} iff (NextVirtualMode == 0);
        bins nxt_umode  = {NEXTPRIVILEGEMODE_USER}       iff (NextVirtualMode == 0);
        bins nxt_vsmode = {NEXTPRIVILEGEMODE_SUPERVISOR} iff (NextVirtualMode == 1);
        bins nxt_vumode = {NEXTPRIVILEGEMODE_USER}       iff (NextVirtualMode == 1);
    }

    hext__gen__cp_hext_instr : coverpoint instrenum_var {
        bins hfence_gvma        = {INSTRENUM_HFENCE_GVMA};
        bins hfence_vvma        = {INSTRENUM_HFENCE_VVMA};
        bins hinval_gvma        = {INSTRENUM_HINVAL_GVMA};
        bins hinval_vvma        = {INSTRENUM_HINVAL_VVMA};
        bins h_loads[1]         = {INSTRENUM_HLV_B,INSTRENUM_HLV_D, INSTRENUM_HLV_H, INSTRENUM_HLV_W};
        bins h_loads_unsign[1]  = {INSTRENUM_HLV_BU, INSTRENUM_HLV_HU, INSTRENUM_HLV_WU};
        bins h_loads_execute[1] = {INSTRENUM_HLVX_HU, INSTRENUM_HLVX_WU};
        bins h_stores[1]        = {INSTRENUM_HSV_B, INSTRENUM_HSV_D, INSTRENUM_HSV_H, INSTRENUM_HSV_W};
    }

    hext__traps__cp_excp_def : coverpoint exception_var iff (match_excp == 1){
        bins illegal_exception      = {EXCEPTION_ILLEGAL_INST};
        bins virt_inst_excp         = {EXCEPTION_VIRT_INST};
        bins page_flt_load          = {EXCEPTION_LOAD_PAGE_FAULT};
        bins page_flt_store         = {EXCEPTION_STORE_PAGE_FAULT};
        bins page_flt_instr         = {EXCEPTION_INST_PAGE_FAULT};
        bins guest_page_flt_load    = {EXCEPTION_LOAD_GUEST_PAGE_FAULT};
        bins guest_page_flt_store   = {EXCEPTION_STORE_GUEST_PAGE_FAULT};
        bins guest_page_flt_instr   = {EXCEPTION_INST_GUEST_PAGE_FAULT};
        bins acc_flt_load           = {EXCEPTION_LOAD_ACC_FAULT};
        bins acc_flt_store          = {EXCEPTION_STORE_ACC_FAULT};
        bins acc_flt_instr          = {EXCEPTION_INST_ACC_FAULT};
        bins m_ecall                = {EXCEPTION_M_ENV_CALL};
        bins s_ecall                = {EXCEPTION_S_ENV_CALL};
        bins u_vu_ecall             = {EXCEPTION_U_ENV_CALL};
        bins vs_ecall               = {EXCEPTION_VS_ENV_CALL};
    }

    hext__excp_misaligned_faults : coverpoint exception_var iff (match_excp==1) {
        bins ld_addr_misaligned = {EXCEPTION_LOAD_ACC_FAULT};
        bins st_addr_misaligned = {EXCEPTION_STORE_ACC_FAULT};
    }
    
    hext__deleg__cp_medeleg_virt_intr : coverpoint prev_medeleg_csr[VIRT_INSTR_EXCP] iff (exception_var == EXCEPTION_VIRT_INST) {
        bins non_delegation_mmode   = {0};
        bins delegation_hsmode      = {1};
    }
    
    hext__deleg__cp_medeleg_illegal : coverpoint prev_medeleg_csr[INSTR_ILLEGAL_EXCP] iff (exception_var == EXCEPTION_ILLEGAL_INST) {
        bins non_delegation_mmode   = {0};
        bins delegation_hsmode      = {1};
    }

    hext__deleg__cp_medeleg_instr_page_fault : coverpoint prev_medeleg_csr[INSTR_PAGE_FAULT_EXCP] iff(exception_var == EXCEPTION_INST_PAGE_FAULT) {
        bins non_delegation_mmode   = {0};
        bins delegation_hsmode       = {1};
    }

    hext__deleg__cp_medeleg_load_page_fault : coverpoint prev_medeleg_csr[LOAD_PAGE_FAULT_EXCP] iff(exception_var == EXCEPTION_LOAD_PAGE_FAULT) {
        bins non_delegation_mmode   = {0};
        bins delegation_hsmode       = {1};
    }

    hext__deleg__cp_medeleg_storeAMO_page_fault : coverpoint prev_medeleg_csr[STORE_PAGE_FAULT_EXCP] iff(exception_var == EXCEPTION_STORE_PAGE_FAULT) {
        bins non_delegation_mmode   = {0};
        bins delegation_hsmode       = {1};
    }

    hext__deleg__cp_medeleg_instr_guest_page_fault : coverpoint prev_medeleg_csr[INSTR_GUEST_PAGE_FAULT_EXCP] iff(exception_var == EXCEPTION_INST_GUEST_PAGE_FAULT) {
        bins non_delegation_mmode   = {0};
        bins delegation_hsmode       = {1};
    }

    hext__deleg__cp_medeleg_load_guest_page_fault : coverpoint prev_medeleg_csr[LOAD_GUEST_PAGE_FAULT_EXCP] iff(exception_var == EXCEPTION_LOAD_GUEST_PAGE_FAULT) {
        bins non_delegation_mmode   = {0};
        bins delegation_hsmode       = {1};
    }

    hext__deleg__cp_medeleg_storeAMO_guest_page_fault : coverpoint prev_medeleg_csr[STORE_GUEST_PAGE_FAULT_EXCP] iff(exception_var == EXCEPTION_STORE_GUEST_PAGE_FAULT) {
        bins non_delegation_mmode   = {0};
        bins delegation_hsmode       = {1};
    }

    hext__deleg__cp_hedeleg_illegal : coverpoint prev_hedeleg_csr[INSTR_ILLEGAL_EXCP] iff (exception_var == EXCEPTION_ILLEGAL_INST)  {
        bins non_delegation_hsmode   = {0};
        bins delegation_vsmode       = {1};
    }
    
    hext__deleg__cp_hedeleg_instr_page_fault : coverpoint prev_hedeleg_csr[INSTR_PAGE_FAULT_EXCP] iff(exception_var == EXCEPTION_INST_PAGE_FAULT)  {
        bins non_delegation_hsmode   = {0};
        bins delegation_vsmode       = {1};
    }

    hext__deleg__cp_hedeleg_load_page_fault : coverpoint prev_hedeleg_csr[LOAD_PAGE_FAULT_EXCP] iff(exception_var == EXCEPTION_LOAD_PAGE_FAULT) {
        bins non_delegation_hsmode   = {0};
        bins delegation_vsmode       = {1};
    }

    hext__deleg__cp_hedeleg_storeAMO_page_fault : coverpoint prev_hedeleg_csr[STORE_PAGE_FAULT_EXCP] iff(exception_var == EXCEPTION_STORE_PAGE_FAULT) {
        bins non_delegation_hsmode   = {0};
        bins delegation_vsmode       = {1};
    }

    hext__deleg__cp_hedeleg_load_addr_misaligned_fault : coverpoint prev_hedeleg_csr[LOAD_ADDR_MISALIGNED] iff(exception_var == EXCEPTION_LOAD_ADDR_MISAL) {
        bins non_delegation_hsmode   = {0};
        bins delegation_vsmode       = {1};
    }

    hext__deleg__cp_hedeleg_store_addr_misaligned_fault : coverpoint prev_hedeleg_csr[STORE_ADDR_MISALIGNED] iff(exception_var == EXCEPTION_STORE_ADDR_MISAL) {
        bins non_delegation_hsmode   = {0};
        bins delegation_vsmode       = {1};
    }

    hext__deleg__cr_all_illegal : cross hext__deleg__cp_medeleg_illegal, hext__deleg__cp_hedeleg_illegal;

    hext__deleg__cr_all_instr_page_fault: cross hext__deleg__cp_medeleg_instr_page_fault, hext__deleg__cp_hedeleg_instr_page_fault;

    hext__deleg__cr_all_load_page_fault: cross hext__deleg__cp_medeleg_load_page_fault, hext__deleg__cp_hedeleg_load_page_fault;

    hext__deleg__cr_all_storeAMO_page_fault: cross hext__deleg__cp_medeleg_storeAMO_page_fault, hext__deleg__cp_hedeleg_storeAMO_page_fault;

    // Cover the following mmode csrs with a csr read/write instruction
    hext__csr__cp_csr_mmode : coverpoint Inst[31:20] iff (match_csr_r_instr || match_csr_w_instr) {
        option.weight = 0;
        bins mstatus    = {12'd768};
        bins menvcfg    = {12'd778};
        bins mideleg    = {12'd771};
        bins medeleg    = {12'd770};
        bins mip        = {12'd836};
        bins mie        = {12'd772};
        bins mcause     = {12'd834};
        bins mepc       = {12'd833};
        bins mscratch   = {12'd832};
    }

    //Cover the following smode csrs with a csr read/write instruction
    hext__csr__cp_csr_smode : coverpoint Inst[31:20] iff (match_csr_r_instr || match_csr_w_instr) {
        option.weight = 0;
        bins sip        = {12'd324};
        bins sie        = {12'd260};
        bins scause     = {12'd322};
        bins sepc       = {12'd321};
        bins sscratch   = {12'd320};
    }

    //Cover the following hypervisor specific smode csrs with a csr read/write instruction
    hext__csr__cp_csr_hsmode : coverpoint Inst[31:20] iff (match_csr_r_instr || match_csr_w_instr){
        option.weight=0;
        bins hstatus    = {12'd1536};
        bins henvcfg    = {12'd1546};
        bins hip        = {12'd1604};
        bins hie        = {12'd1540};
    }

    //Cover the following vsmode csrs with a csr read/write instruction
    hext__csr__cp_csr_h_vsmode : coverpoint Inst[31:20] iff (match_csr_r_instr || match_csr_w_instr) {
        option.weight=0;
        bins vsstatus    = {12'd512};
        bins vsscratch   = {12'd576};
        bins vscause     = {12'd578};
        bins vsepc       = {12'd577};
        bins vsip        = {12'd580};
        bins vsie        = {12'd516};
    }
    
    hext__csr__cp_csr_umode_RO : coverpoint Inst[31:20] iff (match_csr_r_instr || match_csr_w_instr){
        bins cycle        = {12'hc00};
        bins timecsr      = {12'hc01};
        bins instret      = {12'hc02};
        bins hpmcounter3  = {12'hc03};
        bins hpmcounter4  = {12'hc04};
        bins hpmcounter5  = {12'hc05};
        bins hpmcounter6  = {12'hc06};
        bins hpmcounter7  = {12'hc07};  
        bins hpmcounter8  = {12'hc08};
    }


    //Cover the following vsmode read only CSR  
    hext__csr__cp_csr_h_vsmode_RO : coverpoint Inst[31:20] iff (match_csr_r_instr || match_csr_w_instr) {
        bins hgeip  = {12'he12};
        bins vstopi = {12'heb0};
    }
 
    //Accessing mmode csrs with csr read/write instructions in vsmode causes illegal instruction exception trap
    hext__virtinstr__cr_mcsr_priv_vsmode    : cross hext__csr__cp_csr_mmode,  hext__gen__cp__vsmode, hext__traps__cp_excp_def {
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.illegal_exception);
    }

    //Accessing mmode csrs with csr read/write instructions in vumode causes illegal instruction exception trap 
    hext__virtinstr__cr_mcsr_priv_vumode    : cross hext__csr__cp_csr_mmode, hext__gen__cp__vumode, hext__traps__cp_excp_def {
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.illegal_exception);
    }

    //Accessing vsmode csrs with csr read/write instructions in vsmode causes virtual instruction exception trap
    hext__virtinstr__cr_h_vscsr_priv_vsmode : cross hext__csr__cp_csr_h_vsmode, hext__gen__cp__vsmode, hext__traps__cp_excp_def {
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.virt_inst_excp); 
    }

    //Accessing vsmode csrs with csr read/write instructions in vumode causes virtual instruction exception trap
    hext__virtinstr__cr_h_vscsr_priv_vumode : cross hext__csr__cp_csr_h_vsmode, hext__gen__cp__vumode, hext__traps__cp_excp_def {
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.virt_inst_excp);  
    } 

    //Accessing hsmode csrs with csr read/write instructions in vsmode causes virtual instruction exception trap 
    hext__virtinstr__cr_hscsr_priv_vsmode   : cross hext__csr__cp_csr_hsmode,   hext__gen__cp__vsmode, hext__traps__cp_excp_def {
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.virt_inst_excp);   
    }

    //Accessing hsmode csrs with csr read/write instructions in vumode causes virtual instruction exception trap
    hext__virtinstr__cr_hscsr_priv_vumode   : cross hext__csr__cp_csr_hsmode,   hext__gen__cp__vumode, hext__traps__cp_excp_def {
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.virt_inst_excp);   
    }

    //Accessing smode csrs with csr read/write instructions in vumode causes virutal instruction exception trap
    hext__virtinstr__cr_scsr_priv_vumode    : cross hext__csr__cp_csr_smode,    hext__gen__cp__vumode, hext__traps__cp_excp_def {
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.virt_inst_excp);   
    }
    
    //Accessing CSRs with a read-only and write-only CSR access
    hext__csr__cp_csr_op_write: coverpoint instrenum_var {
        option.weight=0;
        bins csr_write_valid    = {INSTRENUM_CSRRC, INSTRENUM_CSRRCI, INSTRENUM_CSRRS, INSTRENUM_CSRRSI, INSTRENUM_CSRRW, INSTRENUM_CSRRWI} iff (rs1_val!=0);
        bins csr_write_negative = {INSTRENUM_CSRRC, INSTRENUM_CSRRCI, INSTRENUM_CSRRS, INSTRENUM_CSRRSI, INSTRENUM_CSRRW, INSTRENUM_CSRRWI} iff (rs1_val==0);
    }

    hext__illegal__cr_RO_h_vs_csr_priv_mmode    : cross hext__csr__cp_csr_h_vsmode_RO, hext__gen__cp__mmode, hext__csr__cp_csr_op_write; 
    hext__illegal__cr_RO_h_vs_csr_priv_hsmode   : cross hext__csr__cp_csr_h_vsmode_RO, hext__gen__cp__hsmode, hext__csr__cp_csr_op_write;     
    hext__virtinstr__cr_RO_u_csr_priv_vsmode    : cross hext__csr__cp_csr_umode_RO, hext__gen__cp__vsmode, hext__csr__cp_csr_op_write;
    hext__virtinstr__cr_RO_u_csr_priv_vumode    : cross hext__csr__cp_csr_umode_RO, hext__gen__cp__vumode, hext__csr__cp_csr_op_write;

    //Cover transitions of privilege modes supported by hypervisor enabled core. 
    hext__traps__cr_env_calls : cross hext__traps__cp_excp_def, hext__gen__cp_curpriv, hext__gen__cp_nxtpriv {
        option.cross_auto_bin_max   = 0;
        bins ecall_vs_to_m   = binsof(hext__traps__cp_excp_def.vs_ecall) && binsof(hext__gen__cp_curpriv.vsmode) && 
                                    binsof(hext__gen__cp_nxtpriv.nxt_mmode);    
        bins ecall_vs_to_hs  = binsof(hext__traps__cp_excp_def.vs_ecall) && binsof(hext__gen__cp_curpriv.vsmode) &&
                                    binsof(hext__gen__cp_nxtpriv.nxt_hsmode);
        bins ecall_vu_to_m   = binsof(hext__traps__cp_excp_def.u_vu_ecall) && binsof(hext__gen__cp_curpriv.vumode) && 
                                    binsof(hext__gen__cp_nxtpriv.nxt_mmode);
        bins ecall_vu_to_hs  = binsof(hext__traps__cp_excp_def.u_vu_ecall) && binsof(hext__gen__cp_curpriv.vumode) &&
                                    binsof(hext__gen__cp_nxtpriv.nxt_hsmode);
        bins ecall_vu_to_vs  = binsof(hext__traps__cp_excp_def.u_vu_ecall) && binsof(hext__gen__cp_curpriv.vumode) &&
                                    binsof(hext__gen__cp_nxtpriv.nxt_vsmode);    
    }

    hext__traps__cr_xret : cross hext__gen__cp_curpriv, hext__gen__cp_nxtpriv {
        option.cross_auto_bin_max   = 0;
        bins mret_m_to_vs   = binsof(hext__gen__cp_curpriv.mmode) && binsof(hext__gen__cp_nxtpriv.nxt_vsmode) iff(instrenum_var == INSTRENUM_MRET);
        bins mret_m_to_vu   = binsof(hext__gen__cp_curpriv.mmode) && binsof(hext__gen__cp_nxtpriv.nxt_vumode) iff(instrenum_var == INSTRENUM_MRET);
        bins sret_m_to_vs   = binsof(hext__gen__cp_curpriv.mmode) && binsof(hext__gen__cp_nxtpriv.nxt_vsmode) iff(instrenum_var == INSTRENUM_SRET);
        bins sret_m_to_vu   = binsof(hext__gen__cp_curpriv.mmode) && binsof(hext__gen__cp_nxtpriv.nxt_vumode) iff(instrenum_var == INSTRENUM_SRET);
        bins sret_hs_to_vs  = binsof(hext__gen__cp_curpriv.hsmode) && binsof(hext__gen__cp_nxtpriv.nxt_vsmode) iff(instrenum_var == INSTRENUM_SRET);
        bins sret_hs_to_vu  = binsof(hext__gen__cp_curpriv.hsmode) && binsof(hext__gen__cp_nxtpriv.nxt_vumode) iff(instrenum_var == INSTRENUM_SRET);
        bins sret_vs_to_vu  = binsof(hext__gen__cp_curpriv.vsmode) && binsof(hext__gen__cp_nxtpriv.nxt_vumode) iff(instrenum_var == INSTRENUM_SRET);  
    }

    hext__traps__cr_trap_handler_entry : cross hext__gen__cp_curpriv, hext__gen__cp_nxtpriv {
        option.cross_auto_bin_max = 0;
        
        bins vu_to_vs = binsof(hext__gen__cp_curpriv.vumode) && 
                        binsof(hext__gen__cp_nxtpriv.nxt_vsmode) 
                        iff (match_excp == 1 || interrupt_taken == 1);
        bins vs_to_vs = binsof(hext__gen__cp_curpriv.vsmode) && 
                        binsof(hext__gen__cp_nxtpriv.nxt_vsmode) 
                        iff (match_excp == 1 || interrupt_taken == 1);
        
        bins hu_to_hs = binsof(hext__gen__cp_curpriv.umode) && 
                        binsof(hext__gen__cp_nxtpriv.nxt_hsmode) 
                        iff (match_excp == 1 || interrupt_taken == 1);
        bins hs_to_hs = binsof(hext__gen__cp_curpriv.hsmode) && 
                        binsof(hext__gen__cp_nxtpriv.nxt_hsmode) 
                        iff (match_excp == 1 || interrupt_taken == 1);
        
        bins vu_to_hs = binsof(hext__gen__cp_curpriv.vumode) && 
                        binsof(hext__gen__cp_nxtpriv.nxt_hsmode) 
                        iff (match_excp == 1 || interrupt_taken == 1);
        bins vs_to_hs = binsof(hext__gen__cp_curpriv.vsmode) && 
                        binsof(hext__gen__cp_nxtpriv.nxt_hsmode) 
                        iff (match_excp == 1 || interrupt_taken == 1);
        
        bins hu_to_m = binsof(hext__gen__cp_curpriv.umode) && 
                       binsof(hext__gen__cp_nxtpriv.nxt_mmode) 
                       iff (match_excp == 1 || interrupt_taken == 1);
        bins hs_to_m = binsof(hext__gen__cp_curpriv.hsmode) && 
                       binsof(hext__gen__cp_nxtpriv.nxt_mmode) 
                       iff (match_excp == 1 || interrupt_taken == 1);
        bins m_to_m = binsof(hext__gen__cp_curpriv.mmode) && 
                      binsof(hext__gen__cp_nxtpriv.nxt_mmode) 
                      iff (match_excp == 1 || interrupt_taken == 1);
        
        bins vu_to_m = binsof(hext__gen__cp_curpriv.vumode) && 
                       binsof(hext__gen__cp_nxtpriv.nxt_mmode) 
                       iff (match_excp == 1 || interrupt_taken == 1);
        bins vs_to_m = binsof(hext__gen__cp_curpriv.vsmode) && 
                       binsof(hext__gen__cp_nxtpriv.nxt_mmode) 
                       iff (match_excp == 1 || interrupt_taken == 1);
    }

    hext__traps__cp_virt_instr_excp_01 : coverpoint instrenum_var iff ((VirtualMode == 1)) {
        bins sret_vs_mode_vtsr1     = {INSTRENUM_SRET} iff 
                                        ((privilegemode_var == PRIVILEGEMODE_SUPERVISOR) && 
                                        (prev_hstatus_csr[HSTATUS_VTSR] == 1));
        
        bins sret_vu_mode           = {INSTRENUM_SRET} iff 
                                        (privilegemode_var == PRIVILEGEMODE_USER);

        bins wfi_vs_mode_vtw1       = {INSTRENUM_WFI}  iff 
                                        ((privilegemode_var == PRIVILEGEMODE_SUPERVISOR) && 
                                        (prev_hstatus_csr[HSTATUS_VTW] == 1) && 
                                        (prev_mstatus_csr[MSTATUS_TW] == 0));

        bins wfi_vu_mode            = {INSTRENUM_WFI}  iff 
                                        ((privilegemode_var == PRIVILEGEMODE_USER) && 
                                        (prev_mstatus_csr[MSTATUS_TW] == 0));

        bins sfence_vs_mode_vtvm1[] = {INSTRENUM_SFENCE_INVAL_IR,INSTRENUM_SFENCE_VMA,INSTRENUM_SFENCE_W_INVAL} iff 
                                        ((privilegemode_var == PRIVILEGEMODE_SUPERVISOR) && 
                                        (prev_hstatus_csr[HSTATUS_VTVM] == 1));

        bins sinval_vs_mode_vtvm1   = {INSTRENUM_SINVAL_VMA} iff 
                                        ((privilegemode_var == PRIVILEGEMODE_SUPERVISOR) && 
                                        (prev_hstatus_csr[HSTATUS_VTVM] == 1));

        bins sfence_vu_mode[]       = {INSTRENUM_SFENCE_INVAL_IR, INSTRENUM_SFENCE_VMA,INSTRENUM_SFENCE_W_INVAL} iff 
                                        (privilegemode_var == PRIVILEGEMODE_USER);

        bins sinval_vu_mode         = {INSTRENUM_SINVAL_VMA} iff 
                                        (privilegemode_var == PRIVILEGEMODE_USER);

        bins hinval_vs_mode         = {INSTRENUM_HINVAL_VVMA} iff 
                                        (privilegemode_var == PRIVILEGEMODE_SUPERVISOR);
        
        bins hinval_vu_mode         = {INSTRENUM_HINVAL_VVMA} iff 
                                        (privilegemode_var == PRIVILEGEMODE_USER);
    }

    hext__traps__cp_virt_instr_excp_02 : coverpoint Inst[31:20] iff ((VirtualMode == 1) && 
                                                                    (privilegemode_var == PRIVILEGEMODE_SUPERVISOR)) {
        bins satp = {12'h180} iff ((prev_hstatus_csr[HSTATUS_VTVM] == 1) &&
                                    (match_csr_r_instr == 1 || match_csr_w_instr == 1));
    }
    
    hext__traps__cr_virt_instr_excp_01 : cross hext__traps__cp_virt_instr_excp_01, hext__deleg__cp_medeleg_virt_intr;
    hext__traps__cr_virt_instr_excp_02 : cross hext__traps__cp_virt_instr_excp_02, hext__deleg__cp_medeleg_virt_intr;
    hext__traps__cr_virt_instr_h_instr_vsmode : cross hext__gen__cp__vsmode,hext__gen__cp_hext_instr;
    hext__traps__cr_virt_instr_h_instr_vumode : cross hext__gen__cp__vumode,hext__gen__cp_hext_instr;
    
    hext__traps__cp_counter_csr_access : coverpoint Inst[31:20] iff ((VirtualMode == 1) && 
                                        (match_csr_r_instr == 1 || match_csr_w_instr == 1)) {
        bins lower_word_counter_csrs = {[CSR_COUNTER_LO:CSR_COUNTER_HI]};
        bins upper_word_counter_csrs = {[CSR_COUNTERH_LO:CSR_COUNTERH_HI]};
    }

    hext__csr__cp_mcounteren_accessed_counter_bit : coverpoint mcounteren_access_bit 
        iff ((VirtualMode == 1) && (counter_csr_access == 1)) {
        bins bit_enabled  = {1};
        bins bit_disabled = {0};
    }
    
    hext__csr__cp_hcounteren_accessed_counter_bit : coverpoint hcounteren_access_bit 
        iff ((VirtualMode == 1) && (counter_csr_access == 1)) {
        bins bit_enabled  = {1};
        bins bit_disabled = {0};
    }
    
    hext__csr__cp_scounteren_accessed_counter_bit : coverpoint scounteren_access_bit 
        iff ((VirtualMode == 1) && (counter_csr_access == 1)) {
        bins bit_enabled  = {1};
        bins bit_disabled = {0};
    }

    hext__traps__cr_virt_instr_counter_vs_m1h0 : cross hext__traps__cp_counter_csr_access, 
                                                        hext__gen__cp__vsmode, 
                                                       hext__csr__cp_mcounteren_accessed_counter_bit, hext__csr__cp_hcounteren_accessed_counter_bit, 
                                                       hext__traps__cp_excp_def {
        option.cross_auto_bin_max = 0;
        bins vs_counter_virt_instr = binsof(hext__gen__cp__vsmode.vsmode) &&
                                     binsof(hext__csr__cp_mcounteren_accessed_counter_bit.bit_enabled) &&
                                     binsof(hext__csr__cp_hcounteren_accessed_counter_bit.bit_disabled) &&
                                     binsof(hext__traps__cp_excp_def.virt_inst_excp);
    }

    hext__traps__cr_virt_instr_counter_vu_m1h0s0 : cross hext__traps__cp_counter_csr_access, hext__gen__cp__vumode,
                                                          hext__csr__cp_mcounteren_accessed_counter_bit, hext__csr__cp_hcounteren_accessed_counter_bit,
                                                          hext__csr__cp_scounteren_accessed_counter_bit, hext__traps__cp_excp_def {
        option.cross_auto_bin_max = 0;
        bins vu_counter_virt_instr_case1 = binsof(hext__gen__cp__vumode.vumode) &&
                                           binsof(hext__csr__cp_mcounteren_accessed_counter_bit.bit_enabled) &&
                                           binsof(hext__csr__cp_hcounteren_accessed_counter_bit.bit_disabled) &&
                                           binsof(hext__csr__cp_scounteren_accessed_counter_bit.bit_disabled) &&
                                           binsof(hext__traps__cp_excp_def.virt_inst_excp);
    }

    hext__traps__cr_virt_instr_counter_vu_m1h0s1 : cross hext__traps__cp_counter_csr_access, hext__gen__cp__vumode,
                                                          hext__csr__cp_mcounteren_accessed_counter_bit, hext__csr__cp_hcounteren_accessed_counter_bit,
                                                          hext__csr__cp_scounteren_accessed_counter_bit, hext__traps__cp_excp_def {
        option.cross_auto_bin_max = 0;
        bins vu_counter_virt_instr_case2 = binsof(hext__gen__cp__vumode.vumode) &&
                                           binsof(hext__csr__cp_mcounteren_accessed_counter_bit.bit_enabled) &&
                                           binsof(hext__csr__cp_hcounteren_accessed_counter_bit.bit_disabled) &&
                                           binsof(hext__csr__cp_scounteren_accessed_counter_bit.bit_enabled) &&
                                           binsof(hext__traps__cp_excp_def.virt_inst_excp);
    }

    hext__traps__cr_virt_instr_counter_vu_m1h1s0 : cross hext__traps__cp_counter_csr_access, hext__gen__cp__vumode,
                                                          hext__csr__cp_mcounteren_accessed_counter_bit, hext__csr__cp_hcounteren_accessed_counter_bit,
                                                          hext__csr__cp_scounteren_accessed_counter_bit, hext__traps__cp_excp_def {
        option.cross_auto_bin_max = 0;
        bins vu_counter_virt_instr_case3 = binsof(hext__gen__cp__vumode.vumode) &&
                                           binsof(hext__csr__cp_mcounteren_accessed_counter_bit.bit_enabled) &&
                                           binsof(hext__csr__cp_hcounteren_accessed_counter_bit.bit_enabled) &&
                                           binsof(hext__csr__cp_scounteren_accessed_counter_bit.bit_disabled) &&
                                           binsof(hext__traps__cp_excp_def.virt_inst_excp);
    }
    
    hext__traps__cp_high_half_csr_access : coverpoint Inst[31:20] iff ((VirtualMode == 1) && (match_csr_r_instr == 1 || match_csr_w_instr == 1)) {
        bins htimedeltah = {12'h615};  
        bins henvcfgh   = {12'h61a};   
        bins high_half_counters = {[CSR_COUNTERH_LO:CSR_COUNTERH_HI]}; 
    }
    
    hext__traps__cr_illegal_high_half_csr_vs : cross hext__traps__cp_high_half_csr_access, hext__gen__cp__vsmode, 
                                                     hext__deleg__cp_medeleg_illegal, hext__deleg__cp_hedeleg_illegal, 
                                                     hext__traps__cp_excp_def {
        option.cross_auto_bin_max = 0;
        bins vs_high_half_csr_illegal_no_deleg = binsof(hext__gen__cp__vsmode.vsmode) &&
                                                 binsof(hext__deleg__cp_medeleg_illegal.non_delegation_mmode) &&
                                                 binsof(hext__traps__cp_excp_def.illegal_exception);
        bins vs_high_half_csr_illegal_m_deleg_only = binsof(hext__gen__cp__vsmode.vsmode) &&
                                                     binsof(hext__deleg__cp_medeleg_illegal.delegation_hsmode) &&
                                                     binsof(hext__deleg__cp_hedeleg_illegal.non_delegation_hsmode) &&
                                                     binsof(hext__traps__cp_excp_def.illegal_exception);
        bins vs_high_half_csr_illegal_both_deleg = binsof(hext__gen__cp__vsmode.vsmode) &&
                                                   binsof(hext__deleg__cp_medeleg_illegal.delegation_hsmode) &&
                                                   binsof(hext__deleg__cp_hedeleg_illegal.delegation_vsmode) &&
                                                   binsof(hext__traps__cp_excp_def.illegal_exception);
    }

    hext__traps__cr_illegal_high_half_csr_vu : cross hext__traps__cp_high_half_csr_access, hext__gen__cp__vumode, 
                                                     hext__deleg__cp_medeleg_illegal, hext__deleg__cp_hedeleg_illegal, 
                                                     hext__traps__cp_excp_def {
        option.cross_auto_bin_max = 0;
        bins vu_high_half_csr_illegal_no_deleg = binsof(hext__gen__cp__vumode.vumode) &&
                                                 binsof(hext__deleg__cp_medeleg_illegal.non_delegation_mmode) &&
                                                 binsof(hext__traps__cp_excp_def.illegal_exception);
        bins vu_high_half_csr_illegal_m_deleg_only = binsof(hext__gen__cp__vumode.vumode) &&
                                                     binsof(hext__deleg__cp_medeleg_illegal.delegation_hsmode) &&
                                                     binsof(hext__deleg__cp_hedeleg_illegal.non_delegation_hsmode) &&
                                                     binsof(hext__traps__cp_excp_def.illegal_exception);
        bins vu_high_half_csr_illegal_both_deleg = binsof(hext__gen__cp__vumode.vumode) &&
                                                   binsof(hext__deleg__cp_medeleg_illegal.delegation_hsmode) &&
                                                   binsof(hext__deleg__cp_hedeleg_illegal.delegation_vsmode) &&
                                                   binsof(hext__traps__cp_excp_def.illegal_exception);
    }
    
    hext__traps__cp_illegal_instr_excp_mret : coverpoint instrenum_var iff ((VirtualMode == 1)) {
        bins mret_vs_mode           = {INSTRENUM_MRET} iff (privilegemode_var == PRIVILEGEMODE_SUPERVISOR);
        bins mret_vu_mode           = {INSTRENUM_MRET} iff (privilegemode_var == PRIVILEGEMODE_USER); 
    }
    
    hext__traps__cr_illegal_instr_excp_mret :cross hext__traps__cp_illegal_instr_excp_mret, hext__deleg__cp_medeleg_illegal,hext__traps__cp_excp_def{
        ignore_bins non_illegal = !binsof(hext__traps__cp_excp_def.illegal_exception);
    }

    hext__csr__cp_hstatus_hu_reset : coverpoint prev_hstatus_csr[9] {
        bins hu_reset = {0};
    } 
    hext__traps__cr_illegal_h_instr_umode : cross hext__gen__cp__humode, hext__gen__cp_hext_instr, hext__csr__cp_hstatus_hu_reset, hext__deleg__cp_medeleg_illegal;
    
    hext__traps__cp_illegal_hfence_hinval_cases : coverpoint instrenum_var {
        bins humode_hstatus_hu_set[] = {INSTRENUM_HFENCE_GVMA, INSTRENUM_HFENCE_VVMA,INSTRENUM_HINVAL_GVMA, INSTRENUM_HINVAL_VVMA} iff ((privilegemode_var == PRIVILEGEMODE_USER) && (VirtualMode == 0) && (prev_hstatus_csr[9] == 1));
        bins hsmode_mstatus_tvm_set[] = {INSTRENUM_HFENCE_GVMA, INSTRENUM_HINVAL_GVMA, INSTRENUM_SINVAL_VMA} iff ((privilegemode_var == PRIVILEGEMODE_SUPERVISOR) && (VirtualMode == 0) && (prev_mstatus_csr[20] == 1));
    }

    hext__traps__cp_illegal_hgatp_hsmode : coverpoint Inst[31:20] iff ((VirtualMode == 0) && (privilegemode_var == PRIVILEGEMODE_SUPERVISOR)) {
        bins hgatp = {12'd1664} iff (prev_mstatus_csr[20] == 1 && (match_csr_r_instr == 1 || match_csr_w_instr == 1));
    }
    hext__traps__cr_illegal_hgatp_hsmode : cross hext__traps__cp_illegal_hgatp_hsmode, hext__deleg__cp_medeleg_illegal;

    hext__csr__cp_vsstatus_fs : coverpoint prev_vsstatus_csr[14:13] {
        bins reset = {0};
        bins set   = {1};
    }
    hext__csr__cp_sstatus_fs : coverpoint prev_sstatus_csr[14:13] {
        bins reset = {0};
        bins set   = {1};
    }
    hext__csr__cp_floating_instr : coverpoint  privilegemode_var iff (VirtualMode == 1) {
        bins floating_point_vsmode = {PRIVILEGEMODE_SUPERVISOR} iff (match_fext == 1);
        bins double_floating_point_vsmode = {PRIVILEGEMODE_SUPERVISOR} iff (match_dext == 1);
        bins floating_point_vumode = {PRIVILEGEMODE_USER} iff (match_fext == 1);
        bins double_floating_point_vumode = {PRIVILEGEMODE_USER} iff (match_dext == 1);
    }
    hext__traps_cr_illegal_fext_xstatus_fs0 : cross hext__csr__cp_floating_instr, hext__csr__cp_vsstatus_fs, hext__csr__cp_sstatus_fs, hext__deleg__cp_medeleg_illegal, hext__deleg__cp_hedeleg_illegal {
        ignore_bins both_xstatus_fs_set =   binsof(hext__csr__cp_vsstatus_fs.set) && 
                                            binsof(hext__csr__cp_sstatus_fs.set);
        ignore_bins mmode_non_delegation =  binsof(hext__deleg__cp_medeleg_illegal.non_delegation_mmode) &&
                                            binsof(hext__deleg__cp_hedeleg_illegal.delegation_vsmode); 
    }

    hext__csr__cp_vsstatus_vs : coverpoint prev_vsstatus_csr[10:9] {
        bins reset = {0};
        bins set   = {1};
    }
    hext__csr__cp_sstatus_vs : coverpoint prev_sstatus_csr[10:9] {
        bins reset = {0};
        bins set   = {1};
    }
    hext__csr__cp_vector_instr : coverpoint  privilegemode_var iff (VirtualMode == 1) {
        bins vector_vsmode = {PRIVILEGEMODE_SUPERVISOR} iff (match_vext == 1);
        bins vector_vumode = {PRIVILEGEMODE_USER} iff (match_vext == 1);
    }
    hext__traps_cr_illegal_vext_xstatus_vs0 : cross hext__csr__cp_vector_instr, hext__csr__cp_vsstatus_vs, hext__csr__cp_sstatus_vs, hext__deleg__cp_medeleg_illegal, hext__deleg__cp_hedeleg_illegal {
        ignore_bins both_xstatus_vs_set =   binsof(hext__csr__cp_vsstatus_vs.set)  && 
                                            binsof(hext__csr__cp_sstatus_vs.set);
        ignore_bins mmode_non_delegation =  binsof(hext__deleg__cp_medeleg_illegal.non_delegation_mmode) &&
                                            binsof(hext__deleg__cp_hedeleg_illegal.delegation_vsmode);
    }

    hext__satp__cp_modes: coverpoint prev_satp_csr[63:60]{
        bins legal_satp_bare_mode           = {0};
        bins legal_satp_modes[]             = {[8:10]};
        bins bare_to_legal_nonbare_mode     = (0 => [8:10]);
        bins legal_nonbare_to_bare_mode     = ([8:10] => 0);
        bins legal_to_legal_mode            = ([8:9] => 10),([9:10] => 8),(8,10 => 9);
    }
    
    hext__satp__cp_asid: coverpoint prev_satp_csr[59:44]{
        bins asid_0x0_to_0xf        = {[16'b0000000000000000:16'b0000000000001111]};
        bins asid_0x10_to_0xff      = {[16'b0000000000010000:16'b0000000011111111]};
        bins asid_0x100_to_0xfff    = {[16'b0000000100000000:16'b0000111111111111]};
        bins asid_0x1000_to_0xffff  = {[16'b0001000000000000:16'b1111111111111111]};
    }
    
    hext__satp__cp_ppn: coverpoint prev_satp_csr[43:0]{
        bins ppn_0x0_0xff                     = {[44'b00000000000000000000000000000000000000000000:44'b00000000000000000000000000000000000011111111]};
        bins ppn_0x100_0xffff                 = {[44'b00000000000000000000000000000000000100000000:44'b00000000000000000000000000001111111111111111]};
        bins ppn_0x10000_0xffffff             = {[44'b00000000000000000000000000010000000000000000:44'b00000000000000000000111111111111111111111111]};
        bins ppn_0x1000000_0xffffffff         = {[44'b00000000000000000001000000000000000000000000:44'b00000000000011111111111111111111111111111111]};
        bins ppn_0x100000000_0xffffffffffff   = {[44'b00000000000100000000000000000000000000000000:44'b11111111111111111111111111111111111111111111]};
    }

    hext__vsatp__cp_modes: coverpoint prev_vsatp_csr[63:60]{
        bins legal_vsatp_bare_mode          = {0};
        bins legal_vsatp_modes[]            = {[8:10]};
        bins bare_to_legal_nonbare_mode     = (0 => [8:10]);
        bins legal_nonbare_to_bare_mode     = ([8:10] => 0);
        bins legal_to_legal_mode            = ([8:9] => 10),([9:10] => 8),(8,10 => 9);
    }

    hext__vsatp__cp_svmodes: coverpoint prev_vsatp_csr[63:60] {
        bins bare = {0};
        bins sv39 = {8};
        bins sv48 = {9};
        bins sv57 = {10};
    }

    hext__vsatp__cp_asid: coverpoint prev_vsatp_csr[59:44]{
        bins asid_0x0_to_0xf        = {[16'b0000000000000000:16'b0000000000001111]};
        bins asid_0x10_to_0xff      = {[16'b0000000000010000:16'b0000000011111111]};
        bins asid_0x100_to_0xfff    = {[16'b0000000100000000:16'b0000111111111111]};
        bins asid_0x1000_to_0xffff  = {[16'b0001000000000000:16'b1111111111111111]};
    }

    hext__vsatp__cp_asid_discoverability_asidlen_16: coverpoint i_csr_cov_sample.vsatp_csr_inst.asid iff (match_csr_w_instr && Inst[31:20] == 12'h280){
        bins asid_bit_0  = {1<<0};
        bins asid_bit_1  = {1<<1};
        bins asid_bit_2  = {1<<2};
        bins asid_bit_3  = {1<<3};
        bins asid_bit_4  = {1<<4};
        bins asid_bit_5  = {1<<5};
        bins asid_bit_6  = {1<<6};
        bins asid_bit_7  = {1<<7};
        bins asid_bit_8  = {1<<8};
        bins asid_bit_9  = {1<<9};
        bins asid_bit_10 = {1<<10};
        bins asid_bit_11 = {1<<11};
        bins asid_bit_12 = {1<<12};
        bins asid_bit_13 = {1<<13};
        bins asid_bit_14 = {1<<14};
        bins asid_bit_15 = {1<<15};
    }

    hext__vsatp__cp_ppn: coverpoint prev_vsatp_csr[43:0]{
        bins ppn_0x0_0xff                     = {[44'b00000000000000000000000000000000000000000000:44'b00000000000000000000000000000000000011111111]};
        bins ppn_0x100_0xffff                 = {[44'b00000000000000000000000000000000000100000000:44'b00000000000000000000000000001111111111111111]};
        bins ppn_0x10000_0xffffff             = {[44'b00000000000000000000000000010000000000000000:44'b00000000000000000000111111111111111111111111]};
        bins ppn_0x1000000_0xffffffff         = {[44'b00000000000000000001000000000000000000000000:44'b00000000000011111111111111111111111111111111]};
        bins ppn_0x100000000_0xffffffffffff   = {[44'b00000000000100000000000000000000000000000000:44'b11111111111111111111111111111111111111111111]};
    }

    hext__vsatp__cp_warl_illegal_mode_write: coverpoint rs1_val[63:60] iff (match_csr_w_instr && Inst[31:20] == 12'h280) {
        bins illegal_mode_values = {[1:7], [11:15]};
    }

    hext__hgatp__cp_modes: coverpoint prev_hgatp_csr[63:60]{
        bins legal_hgatp_bare_mode          = {0};
        bins legal_hgatp_modes[]            = {[8:10]};
        bins bare_to_legal_nonbare_mode     = (0 => [8:10]);
        bins legal_nonbare_to_bare_mode     = ([8:10] => 0);
        bins legal_to_legal_mode            = ([8:9] => 10),([9:10] => 8),(8,10 => 9);
    }

    hext__hgatp__cp_svmodes: coverpoint prev_hgatp_csr[63:60] {
        bins bare = {0};
        bins sv39 = {8};
        bins sv48 = {9};
        bins sv57 = {10};
    }
    
    hext__hgatp__cp_vmid: coverpoint prev_hgatp_csr[57:44]{
        bins vmid_0x0_to_0xf        = {[14'b00000000000000:14'b00000000001111]};
        bins vmid_0x10_to_0xff      = {[14'b00000000010000:14'b00000011111111]};
        bins vmid_0x100_to_0xfff    = {[14'b00000100000000:14'b00111111111111]};
        bins vmid_0x1000_to_0x3fff  = {[14'b01000000000000:14'b11111111111111]};
    }

    hext__hgatp__cp_vmid_discoverability_vmidlen_14: coverpoint i_csr_cov_sample.hgatp_csr_inst.vmid iff (match_csr_w_instr && Inst[31:20] == 12'h680){
        bins vmid_bit_0  = {1<<0};
        bins vmid_bit_1  = {1<<1};
        bins vmid_bit_2  = {1<<2};
        bins vmid_bit_3  = {1<<3};
        bins vmid_bit_4  = {1<<4};
        bins vmid_bit_5  = {1<<5};
        bins vmid_bit_6  = {1<<6};
        bins vmid_bit_7  = {1<<7};
        bins vmid_bit_8  = {1<<8};
        bins vmid_bit_9  = {1<<9};
        bins vmid_bit_10 = {1<<10};
        bins vmid_bit_11 = {1<<11};
        bins vmid_bit_12 = {1<<12};
        bins vmid_bit_13 = {1<<13};
    }

    hext__hgatp__cp_warl_illegal_mode_write: coverpoint rs1_val[63:60] iff (match_csr_w_instr && Inst[31:20] == 12'h680) {
        bins illegal_mode_values = {[1:7], [11:15]};
    }

    hext__hgatp__cp_ppn: coverpoint prev_hgatp_csr[43:0]{
        bins ppn_0x0_0xff                     = {[44'b00000000000000000000000000000000000000000000:44'b00000000000000000000000000000000000011111111]};
        bins ppn_0x100_0xffff                 = {[44'b00000000000000000000000000000000000100000000:44'b00000000000000000000000000001111111111111111]};
        bins ppn_0x10000_0xffffff             = {[44'b00000000000000000000000000010000000000000000:44'b00000000000000000000111111111111111111111111]};
        bins ppn_0x1000000_0xffffffff         = {[44'b00000000000000000001000000000000000000000000:44'b00000000000011111111111111111111111111111111]};
        bins ppn_0x100000000_0xffffffffffff   = {[44'b00000000000100000000000000000000000000000000:44'b11111111111111111111111111111111111111111111]};
    }
   
    hext__accesstype__cp_load: coverpoint instrenum_var {
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

    hext__accesstype__cp_store: coverpoint instrenum_var {
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

    hext__accesstype__cp_instr_2_lvl : coverpoint VirtualMode {
        bins loads              = {1} iff(match_instr_load == 1);
        bins stores             = {1} iff(match_instr_store == 1);
        bins atomics_amo        = {1} iff((match_aext == 1) && !(aext_var inside {AEXT_LR_D, AEXT_LR_W,  AEXT_SC_D, AEXT_SC_W}));
        bins atomics_lr         = {1} iff((match_aext == 1) &&  (aext_var inside {AEXT_LR_D, AEXT_LR_W}));
        bins atomics_sc         = {1} iff((match_aext == 1) &&  (aext_var inside {AEXT_SC_D, AEXT_SC_W}));
    }

    hext__accesstype__cp_instr_2_lvl_mprv : coverpoint VirtualMode iff (prev_mstatus_csr[17] == 1 || prev_mstatus_csr[39] == 1) {
        bins loads              = {0} iff(match_instr_load == 1);
        bins stores             = {0} iff(match_instr_store == 1);
        bins atomics_amo        = {0} iff((match_aext == 1) && !(aext_var inside {AEXT_LR_D, AEXT_LR_W, AEXT_SC_D, AEXT_SC_W}));
        bins atomics_lr         = {0} iff((match_aext == 1) &&  (aext_var inside {AEXT_LR_D, AEXT_LR_W}));
        bins atomics_sc         = {0} iff((match_aext == 1) &&  (aext_var inside {AEXT_LR_D, AEXT_LR_W}));
    }
    
    hext__accesstype__cp_h_instr_2_lvl : coverpoint instrenum_var {
        bins h_loads[1]   = {INSTRENUM_HLV_B,INSTRENUM_HLV_D, INSTRENUM_HLV_H, INSTRENUM_HLV_W, INSTRENUM_HLV_BU, INSTRENUM_HLV_HU, INSTRENUM_HLV_WU};
        bins h_loads_x[1] = {INSTRENUM_HLVX_HU, INSTRENUM_HLVX_WU}; // Cross with MXR as [0,0] in vsstatus, hsstatus
        bins h_stores[1]  = {INSTRENUM_HSV_B, INSTRENUM_HSV_D, INSTRENUM_HSV_H, INSTRENUM_HSV_W};
    }

    hext__ptw__dpte_leaf_ppn_lvl2_align: coverpoint DVPTELeaf[PTE_PPN0_HI:PTE_PPN0_LO] {
        bins aligned        = {9'b000000000};
        bins non_aligned    = {[9'b000000001:9'b111111111]};
    }
    hext__ptw__dpte_leaf_ppn_lvl3_align: coverpoint DVPTELeaf[PTE_PPN1_HI:PTE_PPN0_LO] {
        bins aligned        = {18'b000000000000000000};
        bins non_aligned    = {[18'b000000000000000001:18'b111111111111111111]};
    }
    hext__ptw__dpte_leaf_ppn_lvl4_align: coverpoint DVPTELeaf[PTE_PPN2_HI:PTE_PPN0_LO] {
        bins aligned        = {27'b000000000000000000000000000};
        bins non_aligned    = {[27'b000000000000000000000000001:27'b111111111111111111111111111]};
    }

    hext__ptw__ipte_leaf_ppn_lvl2_align: coverpoint FVPTELeaf[PTE_PPN0_HI:PTE_PPN0_LO] {
        bins aligned        = {9'b000000000};
        bins non_aligned    = {[9'b000000001:9'b111111111]};
    }
    hext__ptw__ipte_leaf_ppn_lvl3_align: coverpoint FVPTELeaf[PTE_PPN1_HI:PTE_PPN0_LO] {
        bins aligned        = {18'b000000000000000000};
        bins non_aligned    = {[18'b000000000000000001:18'b111111111111111111]};
    }
    hext__ptw__ipte_leaf_ppn_lvl4_align: coverpoint FVPTELeaf[PTE_PPN2_HI:PTE_PPN0_LO] {
        bins aligned        = {27'b000000000000000000000000000};
        bins non_aligned    = {[27'b000000000000000000000000001:27'b111111111111111111111111111]};
    }

    hext__pagesize__cp_iside_paginglevel :                     coverpoint fpagesize_var;
    hext__pagesize__cp_iside_vstage_paginglevel :              coverpoint fvpagesize_var;
    hext__pagesize__cp_iside_gstagelevel1_paginglevel :        coverpoint fpagesize_gstagelevel1_var;
    hext__pagesize__cp_iside_gstagelevel2_paginglevel :        coverpoint fpagesize_gstagelevel2_var;
    hext__pagesize__cp_iside_gstagelevel3_paginglevel :        coverpoint fpagesize_gstagelevel3_var;
    hext__pagesize__cp_iside_gstagelevel4_paginglevel :        coverpoint fpagesize_gstagelevel4_var;
    hext__pagesize__cp_iside_gstagelevel5_paginglevel :        coverpoint fpagesize_gstagelevel5_var;

    hext__pagesize__cp_dside_paginglevel :                     coverpoint dpagesize_var;
    hext__pagesize__cp_dside_vstage_paginglevel :              coverpoint dvpagesize_var;
    hext__pagesize__cp_dside_gstagelevel1_paginglevel :        coverpoint dpagesize_gstagelevel1_var;
    hext__pagesize__cp_dside_gstagelevel2_paginglevel :        coverpoint dpagesize_gstagelevel2_var;
    hext__pagesize__cp_dside_gstagelevel3_paginglevel :        coverpoint dpagesize_gstagelevel3_var;
    hext__pagesize__cp_dside_gstagelevel4_paginglevel :        coverpoint dpagesize_gstagelevel4_var;
    hext__pagesize__cp_dside_gstagelevel5_paginglevel :        coverpoint dpagesize_gstagelevel5_var;

    hext__pagesize__cp_iside_cross_paginglevel :  coverpoint fpagecrosssize_var;
    hext__pagesize__cp_dside_cross_paginglevel :  coverpoint dpagecrosssize_var;
    
    hext__ptw__cp_iside_leaf_ptw_read:        coverpoint FVPTELeaf[PTE_READ];
    hext__ptw__cp_iside_leaf_ptw_write:       coverpoint FVPTELeaf[PTE_WRITE];
    hext__ptw__cp_iside_leaf_ptw_exec:        coverpoint FVPTELeaf[PTE_EXECUTE];
    hext__ptw__cp_iside_leaf_ptw_global:      coverpoint FVPTELeaf[PTE_GLOBAL];
    hext__ptw__cp_iside_leaf_ptw_user:        coverpoint FVPTELeaf[PTE_USER];
    hext__ptw__cp_iside_leaf_ptw_valid:       coverpoint FVPTELeaf[PTE_VALID] {
        ignore_bins invalid_leaf = {0}; 
    }
    hext__ptw__cp_iside_leaf_ptw_access:      coverpoint FVPTELeaf[PTE_ACCESSED];
    hext__ptw__cp_iside_leaf_ptw_dirty:       coverpoint FVPTELeaf[PTE_DIRTY];

    hext__ptw__cp_iside_gstage_lvl1_leaf_ptw_read:        coverpoint FPTELeaf_GStageLevel1[PTE_READ];
    hext__ptw__cp_iside_gstage_lvl1_leaf_ptw_write:       coverpoint FPTELeaf_GStageLevel1[PTE_WRITE];
    hext__ptw__cp_iside_gstage_lvl1_leaf_ptw_exec:        coverpoint FPTELeaf_GStageLevel1[PTE_EXECUTE];
    hext__ptw__cp_iside_gstage_lvl1_leaf_ptw_global:      coverpoint FPTELeaf_GStageLevel1[PTE_GLOBAL];
    hext__ptw__cp_iside_gstage_lvl1_leaf_ptw_user:        coverpoint FPTELeaf_GStageLevel1[PTE_USER];
    hext__ptw__cp_iside_gstage_lvl1_leaf_ptw_valid:       coverpoint FPTELeaf_GStageLevel1[PTE_VALID] {
        ignore_bins invalid_leaf = {0}; 
    }
    hext__ptw__cp_iside_gstage_lvl1_leaf_ptw_access:      coverpoint FPTELeaf_GStageLevel1[PTE_ACCESSED];
    hext__ptw__cp_iside_gstage_lvl1_leaf_ptw_dirty:       coverpoint FPTELeaf_GStageLevel1[PTE_DIRTY];

    hext__ptw__cp_iside_gstage_lvl2_leaf_ptw_read:        coverpoint FPTELeaf_GStageLevel2[PTE_READ];
    hext__ptw__cp_iside_gstage_lvl2_leaf_ptw_write:       coverpoint FPTELeaf_GStageLevel2[PTE_WRITE];
    hext__ptw__cp_iside_gstage_lvl2_leaf_ptw_exec:        coverpoint FPTELeaf_GStageLevel2[PTE_EXECUTE];
    hext__ptw__cp_iside_gstage_lvl2_leaf_ptw_global:      coverpoint FPTELeaf_GStageLevel2[PTE_GLOBAL];
    hext__ptw__cp_iside_gstage_lvl2_leaf_ptw_user:        coverpoint FPTELeaf_GStageLevel2[PTE_USER];
    hext__ptw__cp_iside_gstage_lvl2_leaf_ptw_valid:       coverpoint FPTELeaf_GStageLevel2[PTE_VALID] {
        ignore_bins invalid_leaf = {0}; 
    }
    hext__ptw__cp_iside_gstage_lvl2_leaf_ptw_access:      coverpoint FPTELeaf_GStageLevel2[PTE_ACCESSED];
    hext__ptw__cp_iside_gstage_lvl2_leaf_ptw_dirty:       coverpoint FPTELeaf_GStageLevel2[PTE_DIRTY];

    hext__ptw__cp_iside_gstage_lvl3_leaf_ptw_read:        coverpoint FPTELeaf_GStageLevel3[PTE_READ];
    hext__ptw__cp_iside_gstage_lvl3_leaf_ptw_write:       coverpoint FPTELeaf_GStageLevel3[PTE_WRITE];
    hext__ptw__cp_iside_gstage_lvl3_leaf_ptw_exec:        coverpoint FPTELeaf_GStageLevel3[PTE_EXECUTE];
    hext__ptw__cp_iside_gstage_lvl3_leaf_ptw_global:      coverpoint FPTELeaf_GStageLevel3[PTE_GLOBAL];
    hext__ptw__cp_iside_gstage_lvl3_leaf_ptw_user:        coverpoint FPTELeaf_GStageLevel3[PTE_USER];
    hext__ptw__cp_iside_gstage_lvl3_leaf_ptw_valid:       coverpoint FPTELeaf_GStageLevel3[PTE_VALID] {
        ignore_bins invalid_leaf = {0}; 
    }
    hext__ptw__cp_iside_gstage_lvl3_leaf_ptw_access:      coverpoint FPTELeaf_GStageLevel3[PTE_ACCESSED];
    hext__ptw__cp_iside_gstage_lvl3_leaf_ptw_dirty:       coverpoint FPTELeaf_GStageLevel3[PTE_DIRTY];

    hext__ptw__cp_iside_gstage_lvl4_leaf_ptw_read:        coverpoint FPTELeaf_GStageLevel4[PTE_READ];
    hext__ptw__cp_iside_gstage_lvl4_leaf_ptw_write:       coverpoint FPTELeaf_GStageLevel4[PTE_WRITE];
    hext__ptw__cp_iside_gstage_lvl4_leaf_ptw_exec:        coverpoint FPTELeaf_GStageLevel4[PTE_EXECUTE];
    hext__ptw__cp_iside_gstage_lvl4_leaf_ptw_global:      coverpoint FPTELeaf_GStageLevel4[PTE_GLOBAL];
    hext__ptw__cp_iside_gstage_lvl4_leaf_ptw_user:        coverpoint FPTELeaf_GStageLevel4[PTE_USER];
    hext__ptw__cp_iside_gstage_lvl4_leaf_ptw_valid:       coverpoint FPTELeaf_GStageLevel4[PTE_VALID] {
        ignore_bins invalid_leaf = {0}; 
    }
    hext__ptw__cp_iside_gstage_lvl4_leaf_ptw_access:      coverpoint FPTELeaf_GStageLevel4[PTE_ACCESSED];
    hext__ptw__cp_iside_gstage_lvl4_leaf_ptw_dirty:       coverpoint FPTELeaf_GStageLevel4[PTE_DIRTY];

    hext__ptw__cp_iside_gstage_lvl5_leaf_ptw_read:        coverpoint FPTELeaf_GStageLevel5[PTE_READ];
    hext__ptw__cp_iside_gstage_lvl5_leaf_ptw_write:       coverpoint FPTELeaf_GStageLevel5[PTE_WRITE];
    hext__ptw__cp_iside_gstage_lvl5_leaf_ptw_exec:        coverpoint FPTELeaf_GStageLevel5[PTE_EXECUTE];
    hext__ptw__cp_iside_gstage_lvl5_leaf_ptw_global:      coverpoint FPTELeaf_GStageLevel5[PTE_GLOBAL];
    hext__ptw__cp_iside_gstage_lvl5_leaf_ptw_user:        coverpoint FPTELeaf_GStageLevel5[PTE_USER];
    hext__ptw__cp_iside_gstage_lvl5_leaf_ptw_valid:       coverpoint FPTELeaf_GStageLevel5[PTE_VALID] {
        ignore_bins invalid_leaf = {0}; 
    }
    hext__ptw__cp_iside_gstage_lvl5_leaf_ptw_access:      coverpoint FPTELeaf_GStageLevel5[PTE_ACCESSED];
    hext__ptw__cp_iside_gstage_lvl5_leaf_ptw_dirty:       coverpoint FPTELeaf_GStageLevel5[PTE_DIRTY];
    
    hext__ptw__cp_dside_leaf_ptw_read:        coverpoint DVPTELeaf[PTE_READ];
    hext__ptw__cp_dside_leaf_ptw_write:       coverpoint DVPTELeaf[PTE_WRITE];
    hext__ptw__cp_dside_leaf_ptw_exec:        coverpoint DVPTELeaf[PTE_EXECUTE];
    hext__ptw__cp_dside_leaf_ptw_global:      coverpoint DVPTELeaf[PTE_GLOBAL];
    hext__ptw__cp_dside_leaf_ptw_user:        coverpoint DVPTELeaf[PTE_USER];
    hext__ptw__cp_dside_leaf_ptw_valid:       coverpoint DVPTELeaf[PTE_VALID] {
        ignore_bins invalid_leaf = {0}; 
    }
    hext__ptw__cp_dside_leaf_ptw_access:      coverpoint DVPTELeaf[PTE_ACCESSED];
    hext__ptw__cp_dside_leaf_ptw_dirty:       coverpoint DVPTELeaf[PTE_DIRTY];

    hext__ptw__cp_dside_gstage_lvl1_leaf_ptw_read:        coverpoint DPTELeaf_GStageLevel1[PTE_READ];
    hext__ptw__cp_dside_gstage_lvl1_leaf_ptw_write:       coverpoint DPTELeaf_GStageLevel1[PTE_WRITE];
    hext__ptw__cp_dside_gstage_lvl1_leaf_ptw_exec:        coverpoint DPTELeaf_GStageLevel1[PTE_EXECUTE];
    hext__ptw__cp_dside_gstage_lvl1_leaf_ptw_global:      coverpoint DPTELeaf_GStageLevel1[PTE_GLOBAL];
    hext__ptw__cp_dside_gstage_lvl1_leaf_ptw_user:        coverpoint DPTELeaf_GStageLevel1[PTE_USER];
    hext__ptw__cp_dside_gstage_lvl1_leaf_ptw_valid:       coverpoint DPTELeaf_GStageLevel1[PTE_VALID] {
        ignore_bins invalid_leaf = {0}; 
    }
    hext__ptw__cp_dside_gstage_lvl1_leaf_ptw_access:      coverpoint DPTELeaf_GStageLevel1[PTE_ACCESSED];
    hext__ptw__cp_dside_gstage_lvl1_leaf_ptw_dirty:       coverpoint DPTELeaf_GStageLevel1[PTE_DIRTY];

    hext__ptw__cp_dside_gstage_lvl2_leaf_ptw_read:        coverpoint DPTELeaf_GStageLevel2[PTE_READ];
    hext__ptw__cp_dside_gstage_lvl2_leaf_ptw_write:       coverpoint DPTELeaf_GStageLevel2[PTE_WRITE];
    hext__ptw__cp_dside_gstage_lvl2_leaf_ptw_exec:        coverpoint DPTELeaf_GStageLevel2[PTE_EXECUTE];
    hext__ptw__cp_dside_gstage_lvl2_leaf_ptw_global:      coverpoint DPTELeaf_GStageLevel2[PTE_GLOBAL];
    hext__ptw__cp_dside_gstage_lvl2_leaf_ptw_user:        coverpoint DPTELeaf_GStageLevel2[PTE_USER];
    hext__ptw__cp_dside_gstage_lvl2_leaf_ptw_valid:       coverpoint DPTELeaf_GStageLevel2[PTE_VALID] {
        ignore_bins invalid_leaf = {0}; 
    }
    hext__ptw__cp_dside_gstage_lvl2_leaf_ptw_access:      coverpoint DPTELeaf_GStageLevel2[PTE_ACCESSED];
    hext__ptw__cp_dside_gstage_lvl2_leaf_ptw_dirty:       coverpoint DPTELeaf_GStageLevel2[PTE_DIRTY];

    hext__ptw__cp_dside_gstage_lvl3_leaf_ptw_read:        coverpoint DPTELeaf_GStageLevel3[PTE_READ];
    hext__ptw__cp_dside_gstage_lvl3_leaf_ptw_write:       coverpoint DPTELeaf_GStageLevel3[PTE_WRITE];
    hext__ptw__cp_dside_gstage_lvl3_leaf_ptw_exec:        coverpoint DPTELeaf_GStageLevel3[PTE_EXECUTE];
    hext__ptw__cp_dside_gstage_lvl3_leaf_ptw_global:      coverpoint DPTELeaf_GStageLevel3[PTE_GLOBAL];
    hext__ptw__cp_dside_gstage_lvl3_leaf_ptw_user:        coverpoint DPTELeaf_GStageLevel3[PTE_USER];
    hext__ptw__cp_dside_gstage_lvl3_leaf_ptw_valid:       coverpoint DPTELeaf_GStageLevel3[PTE_VALID] {
        ignore_bins invalid_leaf = {0}; 
    }
    hext__ptw__cp_dside_gstage_lvl3_leaf_ptw_access:      coverpoint DPTELeaf_GStageLevel3[PTE_ACCESSED];
    hext__ptw__cp_dside_gstage_lvl3_leaf_ptw_dirty:       coverpoint DPTELeaf_GStageLevel3[PTE_DIRTY];

    hext__ptw__cp_dside_gstage_lvl4_leaf_ptw_read:        coverpoint DPTELeaf_GStageLevel4[PTE_READ];
    hext__ptw__cp_dside_gstage_lvl4_leaf_ptw_write:       coverpoint DPTELeaf_GStageLevel4[PTE_WRITE];
    hext__ptw__cp_dside_gstage_lvl4_leaf_ptw_exec:        coverpoint DPTELeaf_GStageLevel4[PTE_EXECUTE];
    hext__ptw__cp_dside_gstage_lvl4_leaf_ptw_global:      coverpoint DPTELeaf_GStageLevel4[PTE_GLOBAL];
    hext__ptw__cp_dside_gstage_lvl4_leaf_ptw_user:        coverpoint DPTELeaf_GStageLevel4[PTE_USER];
    hext__ptw__cp_dside_gstage_lvl4_leaf_ptw_valid:       coverpoint DPTELeaf_GStageLevel4[PTE_VALID] {
        ignore_bins invalid_leaf = {0}; 
    }
    hext__ptw__cp_dside_gstage_lvl4_leaf_ptw_access:      coverpoint DPTELeaf_GStageLevel4[PTE_ACCESSED];
    hext__ptw__cp_dside_gstage_lvl4_leaf_ptw_dirty:       coverpoint DPTELeaf_GStageLevel4[PTE_DIRTY];

    hext__ptw__cp_dside_gstage_lvl5_leaf_ptw_read:        coverpoint DPTELeaf_GStageLevel5[PTE_READ];
    hext__ptw__cp_dside_gstage_lvl5_leaf_ptw_write:       coverpoint DPTELeaf_GStageLevel5[PTE_WRITE];
    hext__ptw__cp_dside_gstage_lvl5_leaf_ptw_exec:        coverpoint DPTELeaf_GStageLevel5[PTE_EXECUTE];
    hext__ptw__cp_dside_gstage_lvl5_leaf_ptw_global:      coverpoint DPTELeaf_GStageLevel5[PTE_GLOBAL];
    hext__ptw__cp_dside_gstage_lvl5_leaf_ptw_user:        coverpoint DPTELeaf_GStageLevel5[PTE_USER];
    hext__ptw__cp_dside_gstage_lvl5_leaf_ptw_valid:       coverpoint DPTELeaf_GStageLevel5[PTE_VALID] {
        ignore_bins invalid_leaf = {0};
    }
    hext__ptw__cp_dside_gstage_lvl5_leaf_ptw_access:      coverpoint DPTELeaf_GStageLevel5[PTE_ACCESSED];
    hext__ptw__cp_dside_gstage_lvl5_leaf_ptw_dirty:       coverpoint DPTELeaf_GStageLevel5[PTE_DIRTY];

    hext__ptw__cp_iside_nonleaf_ptw_global:   coverpoint FVPTENonLeaf[PTE_GLOBAL];
    hext__ptw__cp_iside_gstage_lvl1_nonleaf_ptw_global:   coverpoint FPTENonLeaf_GStageLevel1[PTE_GLOBAL];
    hext__ptw__cp_iside_gstage_lvl2_nonleaf_ptw_global:   coverpoint FPTENonLeaf_GStageLevel2[PTE_GLOBAL];  
    hext__ptw__cp_iside_gstage_lvl3_nonleaf_ptw_global:   coverpoint FPTENonLeaf_GStageLevel3[PTE_GLOBAL];
    hext__ptw__cp_iside_gstage_lvl4_nonleaf_ptw_global:   coverpoint FPTENonLeaf_GStageLevel4[PTE_GLOBAL];
    hext__ptw__cp_iside_gstage_lvl5_nonleaf_ptw_global:   coverpoint FPTENonLeaf_GStageLevel5[PTE_GLOBAL];
        
    hext__ptw__cp_dside_nonleaf_ptw_global:   coverpoint DVPTENonLeaf[PTE_GLOBAL];
    hext__ptw__cp_dside_gstage_lvl1_nonleaf_ptw_global:   coverpoint DPTENonLeaf_GStageLevel1[PTE_GLOBAL];
    hext__ptw__cp_dside_gstage_lvl2_nonleaf_ptw_global:   coverpoint DPTENonLeaf_GStageLevel2[PTE_GLOBAL];
    hext__ptw__cp_dside_gstage_lvl3_nonleaf_ptw_global:   coverpoint DPTENonLeaf_GStageLevel3[PTE_GLOBAL];
    hext__ptw__cp_dside_gstage_lvl4_nonleaf_ptw_global:   coverpoint DPTENonLeaf_GStageLevel4[PTE_GLOBAL];
    hext__ptw__cp_dside_gstage_lvl5_nonleaf_ptw_global:   coverpoint DPTENonLeaf_GStageLevel5[PTE_GLOBAL];
    
    hext__ptw__cp_iside_nonleaf_ptw_valid:    coverpoint FVPTENonLeaf[PTE_VALID];
    hext__ptw__cp_iside_gstage_lvl1_nonleaf_ptw_valid:    coverpoint FPTENonLeaf_GStageLevel1[PTE_VALID];
    hext__ptw__cp_iside_gstage_lvl2_nonleaf_ptw_valid:    coverpoint FPTENonLeaf_GStageLevel2[PTE_VALID];
    hext__ptw__cp_iside_gstage_lvl3_nonleaf_ptw_valid:    coverpoint FPTENonLeaf_GStageLevel3[PTE_VALID];
    hext__ptw__cp_iside_gstage_lvl4_nonleaf_ptw_valid:    coverpoint FPTENonLeaf_GStageLevel4[PTE_VALID];
    hext__ptw__cp_iside_gstage_lvl5_nonleaf_ptw_valid:    coverpoint FPTENonLeaf_GStageLevel5[PTE_VALID];
    
    hext__ptw__cp_dside_nonleaf_ptw_valid:    coverpoint DVPTENonLeaf[PTE_VALID];
    hext__ptw__cp_dside_gstage_lvl1_nonleaf_ptw_valid:    coverpoint DPTENonLeaf_GStageLevel1[PTE_VALID];
    hext__ptw__cp_dside_gstage_lvl2_nonleaf_ptw_valid:    coverpoint DPTENonLeaf_GStageLevel2[PTE_VALID];
    hext__ptw__cp_dside_gstage_lvl3_nonleaf_ptw_valid:    coverpoint DPTENonLeaf_GStageLevel3[PTE_VALID];
    hext__ptw__cp_dside_gstage_lvl4_nonleaf_ptw_valid:    coverpoint DPTENonLeaf_GStageLevel4[PTE_VALID];
    hext__ptw__cp_dside_gstage_lvl5_nonleaf_ptw_valid:    coverpoint DPTENonLeaf_GStageLevel5[PTE_VALID];

    hext__ptw__cp_dside_nonleaf_ptw_user:    coverpoint DVPTENonLeaf[PTE_USER];
    hext__ptw__cp_dside_gstage_lvl1_nonleaf_ptw_user:    coverpoint DPTENonLeaf_GStageLevel1[PTE_USER];
    hext__ptw__cp_dside_gstage_lvl2_nonleaf_ptw_user:    coverpoint DPTENonLeaf_GStageLevel2[PTE_USER];
    hext__ptw__cp_dside_gstage_lvl3_nonleaf_ptw_user:    coverpoint DPTENonLeaf_GStageLevel3[PTE_USER];
    hext__ptw__cp_dside_gstage_lvl4_nonleaf_ptw_user:    coverpoint DPTENonLeaf_GStageLevel4[PTE_USER];
    hext__ptw__cp_dside_gstage_lvl5_nonleaf_ptw_user:    coverpoint DPTENonLeaf_GStageLevel5[PTE_USER];

    hext__ptw__cp_dside_nonleaf_ptw_access:    coverpoint DVPTENonLeaf[PTE_ACCESSED];
    hext__ptw__cp_dside_gstage_lvl1_nonleaf_ptw_access:    coverpoint DPTENonLeaf_GStageLevel1[PTE_ACCESSED];
    hext__ptw__cp_dside_gstage_lvl2_nonleaf_ptw_access:    coverpoint DPTENonLeaf_GStageLevel2[PTE_ACCESSED];
    hext__ptw__cp_dside_gstage_lvl3_nonleaf_ptw_access:    coverpoint DPTENonLeaf_GStageLevel3[PTE_ACCESSED];
    hext__ptw__cp_dside_gstage_lvl4_nonleaf_ptw_access:    coverpoint DPTENonLeaf_GStageLevel4[PTE_ACCESSED];
    hext__ptw__cp_dside_gstage_lvl5_nonleaf_ptw_access:    coverpoint DPTENonLeaf_GStageLevel5[PTE_ACCESSED];
    
    hext__ptw__cp_dside_nonleaf_ptw_dirty:    coverpoint DVPTENonLeaf[PTE_DIRTY];
    hext__ptw__cp_dside_gstage_lvl1_nonleaf_ptw_dirty:    coverpoint DPTENonLeaf_GStageLevel1[PTE_DIRTY];
    hext__ptw__cp_dside_gstage_lvl2_nonleaf_ptw_dirty:    coverpoint DPTENonLeaf_GStageLevel2[PTE_DIRTY];
    hext__ptw__cp_dside_gstage_lvl3_nonleaf_ptw_dirty:    coverpoint DPTENonLeaf_GStageLevel3[PTE_DIRTY];
    hext__ptw__cp_dside_gstage_lvl4_nonleaf_ptw_dirty:    coverpoint DPTENonLeaf_GStageLevel4[PTE_DIRTY];
    hext__ptw__cp_dside_gstage_lvl5_nonleaf_ptw_dirty:    coverpoint DPTENonLeaf_GStageLevel5[PTE_DIRTY];

    hext__ptw__cp_iside_leaf_rsw: coverpoint FVPTELeaf[PTE_RSW_HI:PTE_RSW_LO] {
        bins rsw_i_leaf_nonzero         = {[1:$]};
    }
    hext__ptw__cp_iside_gstage_lvl1_leaf_rsw: coverpoint FPTELeaf_GStageLevel1[PTE_RSW_HI:PTE_RSW_LO] {
        bins rsw_i_leaf_nonzero         = {[1:$]};
    }
    hext__ptw__cp_iside_gstage_lvl2_leaf_rsw: coverpoint FPTELeaf_GStageLevel2[PTE_RSW_HI:PTE_RSW_LO] {
        bins rsw_i_leaf_nonzero         = {[1:$]};
    }
    hext__ptw__cp_iside_gstage_lvl3_leaf_rsw: coverpoint FPTELeaf_GStageLevel3[PTE_RSW_HI:PTE_RSW_LO] {
        bins rsw_i_leaf_nonzero         = {[1:$]};
    }
    hext__ptw__cp_iside_gstage_lvl4_leaf_rsw: coverpoint FPTELeaf_GStageLevel4[PTE_RSW_HI:PTE_RSW_LO] {
        bins rsw_i_leaf_nonzero         = {[1:$]};
    }
    hext__ptw__cp_iside_gstage_lvl5_leaf_rsw: coverpoint FPTELeaf_GStageLevel5[PTE_RSW_HI:PTE_RSW_LO] {
        bins rsw_i_leaf_nonzero         = {[1:$]};
    }
    
    hext__ptw__cp_iside_nonleaf_rsw: coverpoint FVPTENonLeaf[PTE_RSW_HI:PTE_RSW_LO] {
        bins rsw_i_nonleaf_nonzero         = {[1:$]};
    }
    hext__ptw__cp_iside_gstage_lvl1_nonleaf_rsw: coverpoint FPTENonLeaf_GStageLevel1[PTE_RSW_HI:PTE_RSW_LO] {
        bins rsw_i_nonleaf_nonzero         = {[1:$]};
    }
    hext__ptw__cp_iside_gstage_lvl2_nonleaf_rsw: coverpoint FPTENonLeaf_GStageLevel2[PTE_RSW_HI:PTE_RSW_LO] {
        bins rsw_i_nonleaf_nonzero         = {[1:$]};
    }
    hext__ptw__cp_iside_gstage_lvl3_nonleaf_rsw: coverpoint FPTENonLeaf_GStageLevel3[PTE_RSW_HI:PTE_RSW_LO] {
        bins rsw_i_nonleaf_nonzero         = {[1:$]};
    }
    hext__ptw__cp_iside_gstage_lvl4_nonleaf_rsw: coverpoint FPTENonLeaf_GStageLevel4[PTE_RSW_HI:PTE_RSW_LO] {
        bins rsw_i_nonleaf_nonzero         = {[1:$]};
    }
    hext__ptw__cp_iside_gstage_lvl5_nonleaf_rsw: coverpoint FPTENonLeaf_GStageLevel5[PTE_RSW_HI:PTE_RSW_LO] {
        bins rsw_i_nonleaf_nonzero         = {[1:$]};
    }

    hext__ptw__cp_dside_leaf_rsw: coverpoint DVPTELeaf[PTE_RSW_HI:PTE_RSW_LO] {
        bins rsw_d_leaf_nonzero         = {[1:$]};
    }
    hext__ptw__cp_dside_gstage_lvl1_leaf_rsw: coverpoint DPTELeaf_GStageLevel1[PTE_RSW_HI:PTE_RSW_LO] {
        bins rsw_d_leaf_nonzero         = {[1:$]};
    }
    hext__ptw__cp_dside_gstage_lvl2_leaf_rsw: coverpoint DPTELeaf_GStageLevel2[PTE_RSW_HI:PTE_RSW_LO] {
        bins rsw_d_leaf_nonzero         = {[1:$]};
    }
    hext__ptw__cp_dside_gstage_lvl3_leaf_rsw: coverpoint DPTELeaf_GStageLevel3[PTE_RSW_HI:PTE_RSW_LO] {
        bins rsw_d_leaf_nonzero         = {[1:$]};
    }
    hext__ptw__cp_dside_gstage_lvl4_leaf_rsw: coverpoint DPTELeaf_GStageLevel4[PTE_RSW_HI:PTE_RSW_LO] {
        bins rsw_d_leaf_nonzero         = {[1:$]};
    }
    hext__ptw__cp_dside_gstage_lvl5_leaf_rsw: coverpoint DPTELeaf_GStageLevel5[PTE_RSW_HI:PTE_RSW_LO] {
        bins rsw_d_leaf_nonzero         = {[1:$]};
    }
    
    hext__ptw__cp_dside_nonleaf_rsw: coverpoint DVPTENonLeaf[PTE_RSW_HI:PTE_RSW_LO] {
        bins rsw_d_nonleaf_nonzero         = {[1:$]};
    }
    hext__ptw__cp_dside_gstage_lvl1_nonleaf_rsw: coverpoint DPTENonLeaf_GStageLevel1[PTE_RSW_HI:PTE_RSW_LO] {
        bins rsw_d_nonleaf_nonzero         = {[1:$]};
    }
    hext__ptw__cp_dside_gstage_lvl2_nonleaf_rsw: coverpoint DPTENonLeaf_GStageLevel2[PTE_RSW_HI:PTE_RSW_LO] {
        bins rsw_d_nonleaf_nonzero         = {[1:$]};
    }
    hext__ptw__cp_dside_gstage_lvl3_nonleaf_rsw: coverpoint DPTENonLeaf_GStageLevel3[PTE_RSW_HI:PTE_RSW_LO] {
        bins rsw_d_nonleaf_nonzero         = {[1:$]};
    }
    hext__ptw__cp_dside_gstage_lvl4_nonleaf_rsw: coverpoint DPTENonLeaf_GStageLevel4[PTE_RSW_HI:PTE_RSW_LO] {
        bins rsw_d_nonleaf_nonzero         = {[1:$]};
    }
    hext__ptw__cp_dside_gstage_lvl5_nonleaf_rsw: coverpoint DPTENonLeaf_GStageLevel5[PTE_RSW_HI:PTE_RSW_LO] {
        bins rsw_d_nonleaf_nonzero         = {[1:$]};
    }
    
    hext__ptw__cp_iside_leaf_res: coverpoint FVPTELeaf[PTE_RES_HI:PTE_RES_LO] {
        bins res_i_leaf_nonzero         = {[1:$]};
    }
    hext__ptw__cp_iside_gstage_lvl1_leaf_res: coverpoint FPTELeaf_GStageLevel1[PTE_RES_HI:PTE_RES_LO] {
        bins res_i_leaf_nonzero         = {[1:$]};
    }
    hext__ptw__cp_iside_gstage_lvl2_leaf_res: coverpoint FPTELeaf_GStageLevel2[PTE_RES_HI:PTE_RES_LO] {
        bins res_i_leaf_nonzero         = {[1:$]};
    }
    hext__ptw__cp_iside_gstage_lvl3_leaf_res: coverpoint FPTELeaf_GStageLevel3[PTE_RES_HI:PTE_RES_LO] {
        bins res_i_leaf_nonzero         = {[1:$]};
    }
    hext__ptw__cp_iside_gstage_lvl4_leaf_res: coverpoint FPTELeaf_GStageLevel4[PTE_RES_HI:PTE_RES_LO] {
        bins res_i_leaf_nonzero         = {[1:$]};
    }
    hext__ptw__cp_iside_gstage_lvl5_leaf_res: coverpoint FPTELeaf_GStageLevel5[PTE_RES_HI:PTE_RES_LO] {
        bins res_i_leaf_nonzero         = {[1:$]};
    }

    hext__ptw__cp_iside_nonleaf_res: coverpoint FVPTENonLeaf[PTE_RES_HI:PTE_RES_LO] {
        bins res_i_nonleaf_nonzero         = {[1:$]};
    }
    hext__ptw__cp_iside_gstage_lvl1_nonleaf_res: coverpoint FPTENonLeaf_GStageLevel1[PTE_RES_HI:PTE_RES_LO] {
        bins res_i_nonleaf_nonzero         = {[1:$]};
    }
    hext__ptw__cp_iside_gstage_lvl2_nonleaf_res: coverpoint FPTENonLeaf_GStageLevel2[PTE_RES_HI:PTE_RES_LO] {
        bins res_i_nonleaf_nonzero         = {[1:$]};
    }
    hext__ptw__cp_iside_gstage_lvl3_nonleaf_res: coverpoint FPTENonLeaf_GStageLevel3[PTE_RES_HI:PTE_RES_LO] {
        bins res_i_nonleaf_nonzero         = {[1:$]};
    }
    hext__ptw__cp_iside_gstage_lvl4_nonleaf_res: coverpoint FPTENonLeaf_GStageLevel4[PTE_RES_HI:PTE_RES_LO] {
        bins res_i_nonleaf_nonzero         = {[1:$]};
    }
    hext__ptw__cp_iside_gstage_lvl5_nonleaf_res: coverpoint FPTENonLeaf_GStageLevel5[PTE_RES_HI:PTE_RES_LO] {
        bins res_i_nonleaf_nonzero         = {[1:$]};
    }

    hext__ptw__cp_dside_leaf_res: coverpoint DVPTELeaf[PTE_RES_HI:PTE_RES_LO] {
        bins res_d_leaf_nonzero         = {[1:$]};
    }
    hext__ptw__cp_dside_gstage_lvl1_leaf_res: coverpoint DPTELeaf_GStageLevel1[PTE_RES_HI:PTE_RES_LO] {
        bins res_d_leaf_nonzero         = {[1:$]};
    }
    hext__ptw__cp_dside_gstage_lvl2_leaf_res: coverpoint DPTELeaf_GStageLevel2[PTE_RES_HI:PTE_RES_LO] {
        bins res_d_leaf_nonzero         = {[1:$]};
    }
    hext__ptw__cp_dside_gstage_lvl3_leaf_res: coverpoint DPTELeaf_GStageLevel3[PTE_RES_HI:PTE_RES_LO] {
        bins res_d_leaf_nonzero         = {[1:$]};
    }
    hext__ptw__cp_dside_gstage_lvl4_leaf_res: coverpoint DPTELeaf_GStageLevel4[PTE_RES_HI:PTE_RES_LO] {
        bins res_d_leaf_nonzero         = {[1:$]};
    }
    hext__ptw__cp_dside_gstage_lvl5_leaf_res: coverpoint DPTELeaf_GStageLevel5[PTE_RES_HI:PTE_RES_LO] {
        bins res_d_leaf_nonzero         = {[1:$]};
    }

    hext__ptw__cp_dside_nonleaf_res: coverpoint DVPTENonLeaf[PTE_RES_HI:PTE_RES_LO] {
        bins res_d_nonleaf_nonzero         = {[1:$]};
    }
    hext__ptw__cp_dside_gstage_lvl1_nonleaf_res: coverpoint DPTENonLeaf_GStageLevel1[PTE_RES_HI:PTE_RES_LO] {
        bins res_d_nonleaf_nonzero         = {[1:$]};
    }
    hext__ptw__cp_dside_gstage_lvl2_nonleaf_res: coverpoint DPTENonLeaf_GStageLevel2[PTE_RES_HI:PTE_RES_LO] {
        bins res_d_nonleaf_nonzero         = {[1:$]};
    }
    hext__ptw__cp_dside_gstage_lvl3_nonleaf_res: coverpoint DPTENonLeaf_GStageLevel3[PTE_RES_HI:PTE_RES_LO] {
        bins res_d_nonleaf_nonzero         = {[1:$]};
    }
    hext__ptw__cp_dside_gstage_lvl4_nonleaf_res: coverpoint DPTENonLeaf_GStageLevel4[PTE_RES_HI:PTE_RES_LO] {
        bins res_d_nonleaf_nonzero         = {[1:$]};
    }
    hext__ptw__cp_dside_gstage_lvl5_nonleaf_res: coverpoint DPTENonLeaf_GStageLevel5[PTE_RES_HI:PTE_RES_LO] {
        bins res_d_nonleaf_nonzero         = {[1:$]};
    }
   
    hext__ptw__cp_iside_leaf_pbmt: coverpoint FVPTELeaf[PTE_PBMT_HI:PTE_PBMT_LO] {
        bins pbmt_i_leaf_reserved         = {2'b11};
    }
    hext__ptw__cp_iside_gstage_lvl1_leaf_pbmt: coverpoint FPTELeaf_GStageLevel1[PTE_PBMT_HI:PTE_PBMT_LO] {
        bins pbmt_i_leaf_reserved         = {2'b11};
    }
    hext__ptw__cp_iside_gstage_lvl2_leaf_pbmt: coverpoint FPTELeaf_GStageLevel2[PTE_PBMT_HI:PTE_PBMT_LO] {
        bins pbmt_i_leaf_reserved         = {2'b11};
    }
    hext__ptw__cp_iside_gstage_lvl3_leaf_pbmt: coverpoint FPTELeaf_GStageLevel3[PTE_PBMT_HI:PTE_PBMT_LO] {
        bins pbmt_i_leaf_reserved         = {2'b11};
    }
    hext__ptw__cp_iside_gstage_lvl4_leaf_pbmt: coverpoint FPTELeaf_GStageLevel4[PTE_PBMT_HI:PTE_PBMT_LO] {
        bins pbmt_i_leaf_reserved         = {2'b11};
    }
    hext__ptw__cp_iside_gstage_lvl5_leaf_pbmt: coverpoint FPTELeaf_GStageLevel5[PTE_PBMT_HI:PTE_PBMT_LO] {
        bins pbmt_i_leaf_reserved         = {2'b11};
    }

    hext__ptw__cp_iside_nonleaf_pbmt: coverpoint FVPTENonLeaf[PTE_PBMT_HI:PTE_PBMT_LO] {
        bins pbmt_i_nonleaf_reserved         = {[2'b01:2'b11]};
    }
    hext__ptw__cp_iside_gstage_lvl1_nonleaf_pbmt: coverpoint FPTENonLeaf_GStageLevel1[PTE_PBMT_HI:PTE_PBMT_LO] {
        bins pbmt_i_nonleaf_reserved         = {[2'b01:2'b11]};
    }
    hext__ptw__cp_iside_gstage_lvl2_nonleaf_pbmt: coverpoint FPTENonLeaf_GStageLevel2[PTE_PBMT_HI:PTE_PBMT_LO] {
        bins pbmt_i_nonleaf_reserved         = {[2'b01:2'b11]};
    }
    hext__ptw__cp_iside_gstage_lvl3_nonleaf_pbmt: coverpoint FPTENonLeaf_GStageLevel3[PTE_PBMT_HI:PTE_PBMT_LO] {
        bins pbmt_i_nonleaf_reserved         = {[2'b01:2'b11]};
    }
    hext__ptw__cp_iside_gstage_lvl4_nonleaf_pbmt: coverpoint FPTENonLeaf_GStageLevel4[PTE_PBMT_HI:PTE_PBMT_LO] {
        bins pbmt_i_nonleaf_reserved         = {[2'b01:2'b11]};
    }
    hext__ptw__cp_iside_gstage_lvl5_nonleaf_pbmt: coverpoint FPTENonLeaf_GStageLevel5[PTE_PBMT_HI:PTE_PBMT_LO] {
        bins pbmt_i_nonleaf_reserved         = {[2'b01:2'b11]};
    }

    hext__ptw__cp_dside_leaf_pbmt: coverpoint DVPTELeaf[PTE_PBMT_HI:PTE_PBMT_LO] {
        bins pbmt_d_leaf_reserved         = {2'b11};
    }
    hext__ptw__cp_dside_gstage_lvl1_leaf_pbmt: coverpoint DPTELeaf_GStageLevel1[PTE_PBMT_HI:PTE_PBMT_LO] {
        bins pbmt_d_leaf_reserved         = {2'b11};
    }
    hext__ptw__cp_dside_gstage_lvl2_leaf_pbmt: coverpoint DPTELeaf_GStageLevel2[PTE_PBMT_HI:PTE_PBMT_LO] {
        bins pbmt_d_leaf_reserved         = {2'b11};
    }
    hext__ptw__cp_dside_gstage_lvl3_leaf_pbmt: coverpoint DPTELeaf_GStageLevel3[PTE_PBMT_HI:PTE_PBMT_LO] {
        bins pbmt_d_leaf_reserved         = {2'b11};
    }
    hext__ptw__cp_dside_gstage_lvl4_leaf_pbmt: coverpoint DPTELeaf_GStageLevel4[PTE_PBMT_HI:PTE_PBMT_LO] {
        bins pbmt_d_leaf_reserved         = {2'b11};
    }
    hext__ptw__cp_dside_gstage_lvl5_leaf_pbmt: coverpoint DPTELeaf_GStageLevel5[PTE_PBMT_HI:PTE_PBMT_LO] {
        bins pbmt_d_leaf_reserved         = {2'b11};
    }

    hext__ptw__cp_dside_nonleaf_pbmt: coverpoint DVPTENonLeaf[PTE_PBMT_HI:PTE_PBMT_LO] {
        bins pbmt_d_nonleaf_reserved         = {[2'b01:2'b11]};
    }
    hext__ptw__cp_dside_gstage_lvl1_nonleaf_pbmt: coverpoint DPTENonLeaf_GStageLevel1[PTE_PBMT_HI:PTE_PBMT_LO] {
        bins pbmt_d_nonleaf_reserved         = {[2'b01:2'b11]};
    }
    hext__ptw__cp_dside_gstage_lvl2_nonleaf_pbmt: coverpoint DPTENonLeaf_GStageLevel2[PTE_PBMT_HI:PTE_PBMT_LO] {
        bins pbmt_d_nonleaf_reserved         = {[2'b01:2'b11]};
    }
    hext__ptw__cp_dside_gstage_lvl3_nonleaf_pbmt: coverpoint DPTENonLeaf_GStageLevel3[PTE_PBMT_HI:PTE_PBMT_LO] {
        bins pbmt_d_nonleaf_reserved         = {[2'b01:2'b11]};
    }
    hext__ptw__cp_dside_gstage_lvl4_nonleaf_pbmt: coverpoint DPTENonLeaf_GStageLevel4[PTE_PBMT_HI:PTE_PBMT_LO] {
        bins pbmt_d_nonleaf_reserved         = {[2'b01:2'b11]};
    }
    hext__ptw__cp_dside_gstage_lvl5_nonleaf_pbmt: coverpoint DPTENonLeaf_GStageLevel5[PTE_PBMT_HI:PTE_PBMT_LO] {
        bins pbmt_d_nonleaf_reserved         = {[2'b01:2'b11]};
    }
    
    hext__ptw__cp_iside_leaf_ptw_napot:   coverpoint FVPTELeaf[PTE_NAPOT];
    hext__ptw__cp_iside_gstage_lvl1_leaf_ptw_napot:   coverpoint FPTELeaf_GStageLevel1[PTE_NAPOT];
    hext__ptw__cp_iside_gstage_lvl2_leaf_ptw_napot:   coverpoint FPTELeaf_GStageLevel2[PTE_NAPOT];  
    hext__ptw__cp_iside_gstage_lvl3_leaf_ptw_napot:   coverpoint FPTELeaf_GStageLevel3[PTE_NAPOT];
    hext__ptw__cp_iside_gstage_lvl4_leaf_ptw_napot:   coverpoint FPTELeaf_GStageLevel4[PTE_NAPOT];
    hext__ptw__cp_iside_gstage_lvl5_leaf_ptw_napot:   coverpoint FPTELeaf_GStageLevel5[PTE_NAPOT];
        
    hext__ptw__cp_dside_leaf_ptw_napot:   coverpoint DVPTELeaf[PTE_NAPOT];
    hext__ptw__cp_dside_gstage_lvl1_leaf_ptw_napot:   coverpoint DPTELeaf_GStageLevel1[PTE_NAPOT];
    hext__ptw__cp_dside_gstage_lvl2_leaf_ptw_napot:   coverpoint DPTELeaf_GStageLevel2[PTE_NAPOT];
    hext__ptw__cp_dside_gstage_lvl3_leaf_ptw_napot:   coverpoint DPTELeaf_GStageLevel3[PTE_NAPOT];
    hext__ptw__cp_dside_gstage_lvl4_leaf_ptw_napot:   coverpoint DPTELeaf_GStageLevel4[PTE_NAPOT];
    hext__ptw__cp_dside_gstage_lvl5_leaf_ptw_napot:   coverpoint DPTELeaf_GStageLevel5[PTE_NAPOT];

    hext__ptw__cp_virtual_pc: coverpoint VirtPc {
        bins virtualpc_bit_0_to_31                  = {[64'b00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000:64'b00000000_00000000_00000000_00000000_01111111_11111111_11111111_11111111]};
        bins virtualpc_bit_32_to_52                 = {[64'b00000000_00000000_00000000_00000000_10000000_00000000_00000000_00000000:64'b00000000_00001111_11111111_11111111_11111111_11111111_11111111_11111111]};
        bins virtualpc_bit_53_to_57                 = {[64'b00000000_00010000_00000000_00000000_00000000_00000000_00000000_00000000:64'b00000001_11111111_11111111_11111111_11111111_11111111_11111111_11111111]};
        bins virtualpc_bit_58_to_64                 = {[64'b00000010_00000000_00000000_00000000_00000000_00000000_00000000_00000000:64'b11111111_11111111_11111111_11111111_11111111_11111111_11111111_11111111]};
    } 

    hext__ptw__cp_illegal_virtualpc_in_machinemode_bit: coverpoint VirtPc iff(privilegemode_var==PRIVILEGEMODE_MACHINE) {
        bins illegal_virtualpc_in_machinemode_bit   = {[64'b00000000_00010000_00000000_00000000_00000000_00000000_00000000_00000000:64'b11111111_11111111_11111111_11111111_11111111_11111111_11111111_11111111]};
    } 

    hext__ptw__cp_virtual_pc_bitsel_38: coverpoint VirtPc[38];
    hext__ptw__cp_virtual_pc_bitsel_47: coverpoint VirtPc[47];
    hext__ptw__cp_virtual_pc_bitsel_56: coverpoint VirtPc[56];
    hext__ptw__cp_virtual_pc_bitsel_signextbits_sv39: coverpoint VirtPc[63:39]{
        option.auto_bin_max     = 1;
        ignore_bins legal_pc    = {0,25'b1_1111_1111_1111_1111_1111_1111};
    }
    hext__ptw__cp_virtual_pc_bitsel_signextbits_sv48: coverpoint VirtPc[63:48]{
        option.auto_bin_max     = 1;
        ignore_bins legal_pc    = {0,16'b1111_1111_1111_1111};
    }
    hext__ptw__cp_virtual_pc_bitsel_signextbits_sv57: coverpoint VirtPc[63:57]{
        option.auto_bin_max     = 1;
        ignore_bins legal_pc    = {0,7'b111_1111};
    }
    hext__ptw__cp_virtual_pc_bitsel_signextbits_baremode: coverpoint VirtPc[63:56]{
        option.auto_bin_max     = 1;
        ignore_bins legal_pc    = {0};
    }

    hext__ptw__cp_iside_guest_phy_addr: coverpoint FGPA{
        bins iside_gpa_0_to_33                   = {[64'b00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000:64'b00000000_00000000_00000000_00000001_11111111_11111111_11111111_11111111]};
        bins iside_gpa_34_to_40                  = {[64'b00000000_00000000_00000000_00000010_00000000_00000000_00000000_00000000:64'b00000000_00000000_00000000_11111111_11111111_11111111_11111111_11111111]};
        bins iside_gpa_41_to_49                  = {[64'b00000000_00000000_00000001_00000000_00000000_00000000_00000000_00000000:64'b00000000_00000001_11111111_11111111_11111111_11111111_11111111_11111111]};
        bins iside_gpa_50_to_58                  = {[64'b00000000_00000010_00000000_00000000_00000000_00000000_00000000_00000000:64'b00000111_11111111_11111111_11111111_11111111_11111111_11111111_11111111]};
        bins iside_gpa_illegal_max_addrbits      = {[64'b00000000_00011111_11111111_11111111_11111111_11111111_11111111_11111111:64'b11111111_11101111_11111111_11111111_11111111_11111111_11111111_11111111]};
    }

    hext__ptw__cp_iside_guest_phy_bitsel_40: coverpoint FGPA[40];
    hext__ptw__cp_iside_guest_phy_bitsel_49: coverpoint FGPA[49];
    hext__ptw__cp_iside_guest_phy_bitsel_58: coverpoint FGPA[58];
    
    hext__ptw__cp_iside_guest_phy_bitsel_zeroextbits_sv39: coverpoint VirtPc[63:41] iff (VirtualMode == 1 && prev_hgatp_csr[63:60] == 8 && prev_vsatp_csr[63:60] == 0){
        option.auto_bin_max     = 1;
        ignore_bins legal_addr  = {0};
    }
    hext__ptw__cp_iside_guest_phy_bitsel_zeroextbits_sv48: coverpoint VirtPc[63:50] iff (VirtualMode == 1 && prev_hgatp_csr[63:60] == 9 && prev_vsatp_csr[63:60] == 0){
        option.auto_bin_max     = 1;
        ignore_bins legal_addr  = {0};
    }
    hext__ptw__cp_iside_guest_phy_bitsel_zeroextbits_sv57: coverpoint VirtPc[63:59] iff (VirtualMode == 1 && prev_hgatp_csr[63:60] == 10 && prev_vsatp_csr[63:60] == 0){
        option.auto_bin_max     = 1;
        ignore_bins legal_addr  = {0};
    }
    hext__ptw__cp_iside_guest_phy_bitsel_zeroextbits_baremode: coverpoint VirtPc[63:56] iff (VirtualMode == 1 && prev_hgatp_csr[63:60] == 0 && prev_vsatp_csr[63:60] == 0) {
        option.auto_bin_max   = 1;
        ignore_bins legal = {0};
    }

    hext__ptw__cp_iside_gpa_vpn_bit_58_to_48_sv57: coverpoint FGPA[58:48]{
        bins min_vpn        = {0};
        bins max_vpn        = {11'b11111111111};
        bins generic_vpn    = {[1:11'b11111111110]};
    }
    hext__ptw__cp_iside_gpa_vpn_bit_49_to_39_sv48: coverpoint FGPA[49:39]{
        bins min_vpn        = {0};
        bins max_vpn        = {11'b11111111111};
        bins generic_vpn    = {[1:11'b11111111110]};
    }
    hext__ptw__cp_iside_gpa_vpn_bit_40_to_30_sv39: coverpoint FGPA[40:30]{
        bins min_vpn        = {0};
        bins max_vpn        = {11'b11111111111};
        bins generic_vpn    = {[1:11'b11111111110]};
    }
    
    hext__ptw__cp_iside_gpa_vpn_bit_47_to_39: coverpoint FGPA[47:39]{
        bins min_vpn        = {0};
        bins max_vpn        = {9'b111111111};
        bins generic_vpn    = {[1:9'b111111110]};
    }
    hext__ptw__cp_iside_gpa_vpn_bit_38_to_30: coverpoint FGPA[38:30]{
        bins min_vpn        = {0};
        bins max_vpn        = {9'b111111111};
        bins generic_vpn    = {[1:9'b111111110]};
    }
    hext__ptw__cp_iside_gpa_vpn_bit_29_to_21: coverpoint FGPA[29:21]{
        bins min_vpn        = {0};
        bins max_vpn        = {9'b111111111};
        bins generic_vpn    = {[1:9'b111111110]};
    }
    hext__ptw__cp_iside_gpa_vpn_bit_20_to_12: coverpoint FGPA[20:12]{
        bins min_vpn        = {0};
        bins max_vpn        = {9'b111111111};
        bins generic_vpn    = {[1:9'b111111110]};
    }

    hext__ptw__cp_virtual_ldst_addr: coverpoint VirtLdStAddr{
        bins virtual_ldst_addrbit_0_to_31                   = {[64'b00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000:64'b00000000_00000000_00000000_00000000_01111111_11111111_11111111_11111111]};
        bins virtual_ldst_addrbit_32_to_52                  = {[64'b00000000_00000000_00000000_00000000_10000000_00000000_00000000_00000000:64'b00000000_00001111_11111111_11111111_11111111_11111111_11111111_11111111]};
        bins virtual_ldst_addrbit_53_to_57                  = {[64'b00000000_00010000_00000000_00000000_00000000_00000000_00000000_00000000:64'b00000001_11111111_11111111_11111111_11111111_11111111_11111111_11111111]};
        bins virtual_ldst_addrbit_58_to_64                  = {[64'b00000010_00000000_00000000_00000000_00000000_00000000_00000000_00000000:64'b11111111_11111111_11111111_11111111_11111111_11111111_11111111_11111111]};
        bins virtual_ldst_illegal_max_addrbits              = {[64'b00000000_00011111_11111111_11111111_11111111_11111111_11111111_11111111:64'b11111111_11101111_11111111_11111111_11111111_11111111_11111111_11111111]};
    }

    hext__ptw__cp_virtual_ldst_bitsel_38: coverpoint VirtLdStAddr[38];
    hext__ptw__cp_virtual_ldst_bitsel_47: coverpoint VirtLdStAddr[47];
    hext__ptw__cp_virtual_ldst_bitsel_56: coverpoint VirtLdStAddr[56];
    hext__ptw__cp_virtual_ldst_bitsel_signextbits_sv39: coverpoint VirtLdStAddr[63:39]{
        option.auto_bin_max     = 1;
        ignore_bins legal_addr  = {0,25'b1_1111_1111_1111_1111_1111_1111};  
    }
    hext__ptw__cp_virtual_ldst_bitsel_signextbits_sv48: coverpoint VirtLdStAddr[63:48]{
        option.auto_bin_max     = 1;
        ignore_bins legal_addr  = {0,16'b1111_1111_1111_1111};
    }
    hext__ptw__cp_virtual_ldst_bitsel_signextbits_sv57: coverpoint VirtLdStAddr[63:57]{
        option.auto_bin_max     = 1;
        ignore_bins legal_addr  = {0,7'b111_1111};
    }
    hext__ptw__cp_virtual_ldst_bitsel_signextbits_baremode: coverpoint VirtLdStAddr[63:56]{
        option.auto_bin_max     = 1;
        ignore_bins legal_pc    = {0};
    }
    hext__ptw__cp_vpn_bit_56_to_48: coverpoint VirtLdStAddr[56:48]{
        bins min_vpn        = {0};
        bins max_vpn        = {9'b111111111};
        bins generic_vpn    = {[1:9'b111111110]};
    }
    hext__ptw__cp_vpn_bit_47_to_39: coverpoint VirtLdStAddr[47:39]{
        bins min_vpn        = {0};
        bins max_vpn        = {9'b111111111};
        bins generic_vpn    = {[1:9'b111111110]};
    }
    hext__ptw__cp_vpn_bit_38_to_30: coverpoint VirtLdStAddr[38:30]{
        bins min_vpn        = {0};
        bins max_vpn        = {9'b111111111};
        bins generic_vpn    = {[1:9'b111111110]};
    }
    hext__ptw__cp_vpn_bit_29_to_21: coverpoint VirtLdStAddr[29:21]{
        bins min_vpn        = {0};
        bins max_vpn        = {9'b111111111};
        bins generic_vpn    = {[1:9'b111111110]};
    }
    hext__ptw__cp_vpn_bit_20_to_12: coverpoint VirtLdStAddr[20:12]{
        bins min_vpn        = {0};
        bins max_vpn        = {9'b111111111};
        bins generic_vpn    = {[1:9'b111111110]};
    }

    hext__ptw__cp_dside_guest_phy_addr: coverpoint DGPA{
        bins dside_gpa_0_to_33                   = {[64'b00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000:64'b00000000_00000000_00000000_00000001_11111111_11111111_11111111_11111111]};
        bins dside_gpa_34_to_40                  = {[64'b00000000_00000000_00000000_00000010_00000000_00000000_00000000_00000000:64'b00000000_00000000_00000000_11111111_11111111_11111111_11111111_11111111]};
        bins dside_gpa_41_to_49                  = {[64'b00000000_00000000_00000001_00000000_00000000_00000000_00000000_00000000:64'b00000000_00000001_11111111_11111111_11111111_11111111_11111111_11111111]};
        bins dside_gpa_50_to_58                  = {[64'b00000000_00000010_00000000_00000000_00000000_00000000_00000000_00000000:64'b00000111_11111111_11111111_11111111_11111111_11111111_11111111_11111111]};
        bins dside_gpa_illegal_max_addrbits      = {[64'b00000000_00011111_11111111_11111111_11111111_11111111_11111111_11111111:64'b11111111_11101111_11111111_11111111_11111111_11111111_11111111_11111111]};
    }

    hext__ptw__cp_dside_guest_phy_bitsel_40: coverpoint DGPA[40];
    hext__ptw__cp_dside_guest_phy_bitsel_49: coverpoint DGPA[49];
    hext__ptw__cp_dside_guest_phy_bitsel_58: coverpoint DGPA[58];

    hext__ptw__cp_dside_guest_phy_bitsel_zeroextbits_sv39: coverpoint VirtLdStAddr[63:41] iff (VirtualMode == 1 && prev_hgatp_csr[63:60] == 8 && prev_vsatp_csr[63:60] == 0){
        option.auto_bin_max     = 1;
        ignore_bins legal_addr  = {0};
    }
    hext__ptw__cp_dside_guest_phy_bitsel_zeroextbits_sv48: coverpoint VirtLdStAddr[63:50] iff (VirtualMode == 1 && prev_hgatp_csr[63:60] == 9 && prev_vsatp_csr[63:60] == 0){
        option.auto_bin_max     = 1;
        ignore_bins legal_addr  = {0};
    }
    hext__ptw__cp_dside_guest_phy_bitsel_zeroextbits_sv57: coverpoint VirtLdStAddr[63:59] iff (VirtualMode == 1 && prev_hgatp_csr[63:60] == 10 && prev_vsatp_csr[63:60] == 0){
        option.auto_bin_max     = 1;
        ignore_bins legal_addr  = {0};
    }
    hext__ptw__cp_dside_guest_phy_bitsel_zeroextbits_baremode: coverpoint VirtLdStAddr[63:56] iff (VirtualMode == 1 && prev_hgatp_csr[63:60] == 0 && prev_vsatp_csr[63:60] == 0) {
        option.auto_bin_max   = 1;
        ignore_bins legal = {0};
    }

    hext__ptw__cp_dside_gpa_vpn_bit_58_to_48_sv57: coverpoint DGPA[58:48]{
        bins min_vpn        = {0};
        bins max_vpn        = {11'b11111111111};
        bins generic_vpn    = {[1:11'b11111111110]};
    }
    hext__ptw__cp_dside_gpa_vpn_bit_49_to_39_sv48: coverpoint DGPA[49:39]{
        bins min_vpn        = {0};
        bins max_vpn        = {11'b11111111111};
        bins generic_vpn    = {[1:11'b11111111110]};
    }
    hext__ptw__cp_dside_gpa_vpn_bit_40_to_30_sv39: coverpoint DGPA[40:30]{
        bins min_vpn        = {0};
        bins max_vpn        = {11'b11111111111};
        bins generic_vpn    = {[1:11'b11111111110]};
    }
    
    hext__ptw__cp_dside_gpa_vpn_bit_47_to_39: coverpoint DGPA[47:39]{
        bins min_vpn        = {0};
        bins max_vpn        = {9'b111111111};
        bins generic_vpn    = {[1:9'b111111110]};
    }
    hext__ptw__cp_dside_gpa_vpn_bit_38_to_30: coverpoint DGPA[38:30]{
        bins min_vpn        = {0};
        bins max_vpn        = {9'b111111111};
        bins generic_vpn    = {[1:9'b111111110]};
    }
    hext__ptw__cp_dside_gpa_vpn_bit_29_to_21: coverpoint DGPA[29:21]{
        bins min_vpn        = {0};
        bins max_vpn        = {9'b111111111};
        bins generic_vpn    = {[1:9'b111111110]};
    }
    hext__ptw__cp_dside_gpa_vpn_bit_20_to_12: coverpoint DGPA[20:12]{
        bins min_vpn        = {0};
        bins max_vpn        = {9'b111111111};
        bins generic_vpn    = {[1:9'b111111110]};
    }

    hext__csr__cp_mstatus_mprv : coverpoint prev_mstatus_csr[17]{
        bins mprv_high          = {1};
        bins mprv_low           = {0};
    }
    hext__csr__cp_mstatus_mpv : coverpoint prev_mstatus_csr[39]{
        bins mpv_high          = {1};
        bins mpv_low           = {0};
    }
    hext__csr__cp_mstatus_mpp : coverpoint prev_mstatus_csr[12:11]{
        bins mpp_machine        = {3};
        bins mpp_supervisor     = {1};
        bins mpp_user           = {0};
    }
    hext__csr__cp_mstatus_sum : coverpoint prev_mstatus_csr[18]{
        bins sum_high           = {1};
        bins sum_low            = {0};
    }
    hext__csr__cp_mstatus_mxr : coverpoint prev_mstatus_csr[19]{
        bins mxr_high           = {1};
        bins mxr_low            = {0};
    }
    
    hext__csr__cp_sstatus_spp : coverpoint prev_sstatus_csr[8]{
        bins spp_supervisor     = {1};
        bins spp_user           = {0};
    }
    hext__csr__cp_sstatus_sum : coverpoint prev_sstatus_csr[18]{
        bins sum_high           = {1};
        bins sum_low            = {0};
    }
    hext__csr__cp_sstatus_mxr : coverpoint prev_sstatus_csr[19]{
        bins mxr_high           = {1};
        bins mxr_low            = {0};
    }
    
    hext__csr__cp_hstatus_spv : coverpoint prev_hstatus_csr[7]{
        bins spv_high           = {1};
        bins spv_low            = {0};
    }
    hext__csr__cp_hstatus_spvp : coverpoint prev_hstatus_csr[8]{
        bins spvp_high           = {1};
        bins spvp_low            = {0};
    }
    hext__csr__cp_hstatus_hu : coverpoint prev_hstatus_csr[9]{
        bins hu_high           = {1};
        bins hu_low            = {0};
    }

    hext__csr__cp_vsstatus_spp : coverpoint prev_vsstatus_csr[8]{
        bins spp_supervisor     = {1};
        bins spp_user           = {0};
    }
    hext__csr__cp_vsstatus_sum : coverpoint prev_vsstatus_csr[18]{
        bins sum_high           = {1};
        bins sum_low            = {0};
    }
    hext__csr__cp_vsstatus_mxr : coverpoint prev_vsstatus_csr[19]{
        bins mxr_high           = {1};
        bins mxr_low            = {0};
    }
    
    hext__csr__cp_satp_access: coverpoint Inst[31:20] iff (match_csr_r_instr || match_csr_w_instr) {
                bins satp = {64'd384}; 
    }
    hext__csr__cp_vsatp_access: coverpoint Inst[31:20] iff (match_csr_r_instr || match_csr_w_instr) {
                bins vsatp = {64'd640};
    }
    hext__csr__cp_hgatp_access: coverpoint Inst[31:20] iff (match_csr_r_instr || match_csr_w_instr) {
                bins hgatp = {64'd1664};
    }

    hext__satp__cr_satp_accessibilty_in_privmodes: cross hext__csr__cp_satp_access, hext__gen__cp_curpriv {
        option.cross_auto_bin_max   = 0;
        bins legal_access_vsmode = binsof(hext__gen__cp_curpriv.vsmode) &&
                                     binsof(hext__csr__cp_satp_access.satp);
    }
    hext__vsatp__cr_vsatp_accessibilty_in_privmodes: cross hext__csr__cp_vsatp_access, hext__gen__cp_curpriv {
        option.cross_auto_bin_max   = 0;
        bins legal_access_mmode = binsof(hext__gen__cp_curpriv.mmode) &&
                                     binsof(hext__csr__cp_vsatp_access.vsatp);
        bins legal_access_smode = binsof(hext__gen__cp_curpriv.hsmode) &&
                                     binsof(hext__csr__cp_vsatp_access.vsatp);
    }
    hext__hgatp__cr_hgatp_accessibilty_in_privmodes: cross hext__csr__cp_hgatp_access, hext__gen__cp_curpriv {
        option.cross_auto_bin_max   = 0;
        bins legal_access_mmode = binsof(hext__gen__cp_curpriv.mmode) &&
                                     binsof(hext__csr__cp_hgatp_access.hgatp);
        bins legal_access_smode = binsof(hext__gen__cp_curpriv.hsmode) &&
                                     binsof(hext__csr__cp_hgatp_access.hgatp);
    }

    hext__vsatp__cr_vsatp_in_bare_mode: cross hext__csr__cp_vsatp_access, hext__vsatp__cp_asid, hext__vsatp__cp_modes, hext__vsatp__cp_ppn {
        option.cross_auto_bin_max   = 0;
        bins vsatp_access_in_baremode_with_ppnandasid_bothzero = binsof(hext__csr__cp_vsatp_access.vsatp)&&
                                                           binsof(hext__vsatp__cp_modes) intersect {0} &&
                                                           binsof(hext__vsatp__cp_asid) intersect {0} && 
                                                           binsof(hext__vsatp__cp_ppn) intersect {0};
        bins vsatp_access_in_baremode_with_ppnzero_asidnonzero = binsof(hext__csr__cp_vsatp_access.vsatp)&&
                                                           binsof(hext__vsatp__cp_modes) intersect {0} &&
                                                           binsof(hext__vsatp__cp_asid) intersect {[1:$]} && 
                                                           binsof(hext__vsatp__cp_ppn) intersect {0} ;
        bins vsatp_access_in_baremode_with_ppnnonzero_asidzero = binsof(hext__csr__cp_vsatp_access.vsatp)&&
                                                           binsof(hext__vsatp__cp_modes) intersect {0} &&
                                                           binsof(hext__vsatp__cp_asid) intersect {0} && 
                                                           binsof(hext__vsatp__cp_ppn)intersect {[1:$]};
        bins vsatp_access_in_baremode_with_ppnandasid_bothnonzero = binsof(hext__csr__cp_vsatp_access.vsatp)&&
                                                           binsof(hext__vsatp__cp_modes) intersect {0} &&
                                                           binsof(hext__vsatp__cp_asid) intersect {[1:$]} && 
                                                           binsof(hext__vsatp__cp_ppn) intersect {[1:$]};                                                           
    }
    hext__hgatp__cr_hgatp_in_bare_mode: cross hext__csr__cp_hgatp_access, hext__hgatp__cp_vmid, hext__hgatp__cp_modes, hext__hgatp__cp_ppn {
        option.cross_auto_bin_max   = 0;
        bins hgatp_access_in_baremode_with_ppnandvmid_bothzero = binsof(hext__csr__cp_hgatp_access.hgatp)&&
                                                           binsof(hext__hgatp__cp_modes) intersect {0} &&
                                                           binsof(hext__hgatp__cp_vmid) intersect {0} && 
                                                           binsof(hext__hgatp__cp_ppn) intersect {0};
        bins hgatp_access_in_baremode_with_ppnzero_vmidnonzero = binsof(hext__csr__cp_hgatp_access.hgatp)&&
                                                           binsof(hext__hgatp__cp_modes) intersect {0} &&
                                                           binsof(hext__hgatp__cp_vmid) intersect {[1:$]} && 
                                                           binsof(hext__hgatp__cp_ppn)intersect {0};
        bins hgatp_access_in_baremode_with_ppnnonzero_vmidzero = binsof(hext__csr__cp_hgatp_access.hgatp)&&
                                                           binsof(hext__hgatp__cp_modes) intersect {0} &&
                                                           binsof(hext__hgatp__cp_vmid) intersect {0} && 
                                                           binsof(hext__hgatp__cp_ppn)intersect {[1:$]};
        bins hgatp_access_in_baremode_with_ppnandvmid_bothnonzero = binsof(hext__csr__cp_hgatp_access.hgatp)&&
                                                           binsof(hext__hgatp__cp_modes) intersect {0} &&
                                                           binsof(hext__hgatp__cp_vmid) intersect {[1:$]} && 
                                                           binsof(hext__hgatp__cp_ppn) intersect {[1:$]};
    }

    hext__ptw__cr_hgatp_vsatp_svmodes_with_all_page_sizes_leaf: cross hext__vsatp__cp_svmodes, hext__pagesize__cp_dside_vstage_paginglevel, hext__hgatp__cp_svmodes, hext__pagesize__cp_dside_paginglevel {
       ignore_bins large_pages_in_sv39_hgatp_mode   =  binsof(hext__hgatp__cp_svmodes.sv39) &&
                                                       binsof(hext__pagesize__cp_dside_paginglevel) intersect {DPAGESIZE_256T, DPAGESIZE_512G} ;
       ignore_bins large_pages_in_sv48_hgatp_mode   =  binsof(hext__hgatp__cp_svmodes.sv48) &&
                                                    binsof(hext__pagesize__cp_dside_paginglevel) intersect {DPAGESIZE_256T} ; 
       ignore_bins large_pages_in_sv39_vsatp_mode   =  binsof(hext__vsatp__cp_svmodes.sv39) &&
                                                    binsof(hext__pagesize__cp_dside_vstage_paginglevel) intersect {DVPAGESIZE_256T, DVPAGESIZE_512G};
       ignore_bins large_pages_in_sv48_vsatp_mode   =  binsof(hext__vsatp__cp_svmodes.sv48) &&
                                                    binsof(hext__pagesize__cp_dside_vstage_paginglevel) intersect {DVPAGESIZE_256T};
       ignore_bins vsatp_bare_mode                  = binsof(hext__vsatp__cp_svmodes.bare);
       ignore_bins hgatp_bare_mode                  = binsof(hext__hgatp__cp_svmodes.bare);                                                    
    }

    hext__ptw__cr_hgatp_vsatp_svmodes_with_all_page_sizes_lvl1: cross hext__vsatp__cp_svmodes, hext__pagesize__cp_dside_vstage_paginglevel, hext__hgatp__cp_svmodes, hext__pagesize__cp_dside_gstagelevel1_paginglevel {
       ignore_bins large_pages_in_sv39_hgatp_mode   =  binsof(hext__hgatp__cp_svmodes.sv39) &&
                                                    binsof(hext__pagesize__cp_dside_gstagelevel1_paginglevel) intersect {DPAGESIZE_GSTAGELEVEL1_256T, DPAGESIZE_GSTAGELEVEL1_512G} ;
       ignore_bins large_pages_in_sv48_hgatp_mode   =  binsof(hext__hgatp__cp_svmodes.sv48) &&
                                                    binsof(hext__pagesize__cp_dside_gstagelevel1_paginglevel) intersect {DPAGESIZE_GSTAGELEVEL1_256T} ;
       ignore_bins large_pages_in_sv39_vsatp_mode   =  binsof(hext__vsatp__cp_svmodes.sv39) &&
                                                    binsof(hext__pagesize__cp_dside_vstage_paginglevel) intersect {DVPAGESIZE_256T, DVPAGESIZE_512G};
       ignore_bins large_pages_in_sv48_vsatp_mode   =  binsof(hext__vsatp__cp_svmodes.sv48) &&
                                                    binsof(hext__pagesize__cp_dside_vstage_paginglevel) intersect {DVPAGESIZE_256T};
       ignore_bins no_gstage_lvl1_walk_vstage_2m_plus = binsof(hext__pagesize__cp_dside_vstage_paginglevel) intersect {DVPAGESIZE_2M, DVPAGESIZE_1G, DVPAGESIZE_512G, DVPAGESIZE_256T};
       ignore_bins vsatp_bare_mode                  = binsof(hext__vsatp__cp_svmodes.bare);
       ignore_bins hgatp_bare_mode                  = binsof(hext__hgatp__cp_svmodes.bare);                                                    
     }

    hext__ptw__cr_hgatp_vsatp_svmodes_with_all_page_sizes_lvl2: cross hext__vsatp__cp_svmodes, hext__pagesize__cp_dside_vstage_paginglevel, hext__hgatp__cp_svmodes, hext__pagesize__cp_dside_gstagelevel2_paginglevel { 
       ignore_bins large_pages_in_sv39_hgatp_mode   =  binsof(hext__hgatp__cp_svmodes.sv39) &&
                                                    binsof(hext__pagesize__cp_dside_gstagelevel2_paginglevel) intersect {DPAGESIZE_GSTAGELEVEL2_256T, DPAGESIZE_GSTAGELEVEL2_512G} ;
       ignore_bins large_pages_in_sv48_hgatp_mode   =  binsof(hext__hgatp__cp_svmodes.sv48) &&
                                                    binsof(hext__pagesize__cp_dside_gstagelevel2_paginglevel) intersect {DPAGESIZE_GSTAGELEVEL2_256T} ;
       ignore_bins large_pages_in_sv39_vsatp_mode   =  binsof(hext__vsatp__cp_svmodes.sv39) &&
                                                    binsof(hext__pagesize__cp_dside_vstage_paginglevel) intersect {DVPAGESIZE_256T, DVPAGESIZE_512G, DVPAGESIZE_1G};
       ignore_bins large_pages_in_sv48_vsatp_mode   =  binsof(hext__vsatp__cp_svmodes.sv48) &&
                                                    binsof(hext__pagesize__cp_dside_vstage_paginglevel) intersect {DVPAGESIZE_256T, DVPAGESIZE_512G};
       ignore_bins large_pages_in_sv57_vsatp_mode   =  binsof(hext__vsatp__cp_svmodes.sv57) &&
                                                    binsof(hext__pagesize__cp_dside_vstage_paginglevel) intersect {DVPAGESIZE_256T};                  
       ignore_bins no_gstage_lvl2_walk_vstage_1g_plus = binsof(hext__pagesize__cp_dside_vstage_paginglevel) intersect {DVPAGESIZE_1G, DVPAGESIZE_512G, DVPAGESIZE_256T};
       ignore_bins vsatp_bare_mode                  = binsof(hext__vsatp__cp_svmodes.bare);
       ignore_bins hgatp_bare_mode                  = binsof(hext__hgatp__cp_svmodes.bare);                                                                   
   }

    hext__ptw__cr_hgatp_vsatp_svmodes_with_all_page_sizes_lvl3: cross hext__vsatp__cp_svmodes, hext__pagesize__cp_dside_vstage_paginglevel, hext__hgatp__cp_svmodes, hext__pagesize__cp_dside_gstagelevel3_paginglevel {
       ignore_bins large_pages_in_sv39_hgatp_mode   =  binsof(hext__hgatp__cp_svmodes.sv39) &&
                                                    binsof(hext__pagesize__cp_dside_gstagelevel3_paginglevel) intersect {DPAGESIZE_GSTAGELEVEL3_256T, DPAGESIZE_GSTAGELEVEL3_512G} ;
       ignore_bins large_pages_in_sv48_hgatp_mode   =  binsof(hext__hgatp__cp_svmodes.sv48) &&
                                                    binsof(hext__pagesize__cp_dside_gstagelevel3_paginglevel) intersect {DPAGESIZE_GSTAGELEVEL3_256T} ;
       ignore_bins large_pages_in_sv39_vsatp_mode   =  binsof(hext__vsatp__cp_svmodes.sv39) &&
                                                    binsof(hext__pagesize__cp_dside_vstage_paginglevel) intersect {DVPAGESIZE_256T, DVPAGESIZE_512G, DVPAGESIZE_1G, DVPAGESIZE_2M};
       ignore_bins large_pages_in_sv48_vsatp_mode   =  binsof(hext__vsatp__cp_svmodes.sv48) &&
                                                    binsof(hext__pagesize__cp_dside_vstage_paginglevel) intersect {DVPAGESIZE_256T, DVPAGESIZE_512G, DVPAGESIZE_1G};
       ignore_bins large_pages_in_sv57_vsatp_mode   =  binsof(hext__vsatp__cp_svmodes.sv57) &&
                                                    binsof(hext__pagesize__cp_dside_vstage_paginglevel) intersect { DVPAGESIZE_256T, DVPAGESIZE_512G};    
       ignore_bins no_gstage_lvl3_walk_vstage_512g_plus = binsof(hext__pagesize__cp_dside_vstage_paginglevel) intersect {DVPAGESIZE_512G, DVPAGESIZE_256T};
       ignore_bins vsatp_bare_mode                  = binsof(hext__vsatp__cp_svmodes.bare);
       ignore_bins hgatp_bare_mode                  = binsof(hext__hgatp__cp_svmodes.bare);                                                      
    }
    hext__ptw__cr_hgatp_vsatp_svmodes_with_all_page_sizes_lvl4: cross hext__vsatp__cp_svmodes, hext__pagesize__cp_dside_vstage_paginglevel, hext__hgatp__cp_svmodes, hext__pagesize__cp_dside_gstagelevel4_paginglevel {
       ignore_bins large_pages_in_sv39_hgatp_mode   =  binsof(hext__hgatp__cp_svmodes.sv39) &&
                                                    binsof(hext__pagesize__cp_dside_gstagelevel4_paginglevel) intersect {DPAGESIZE_GSTAGELEVEL4_256T, DPAGESIZE_GSTAGELEVEL4_512G} ;
       ignore_bins large_pages_in_sv48_hgatp_mode   =  binsof(hext__hgatp__cp_svmodes.sv48) &&
                                                    binsof(hext__pagesize__cp_dside_gstagelevel4_paginglevel) intersect {DPAGESIZE_GSTAGELEVEL4_256T} ;
       ignore_bins vsatp_sv39_mode                  =  binsof(hext__vsatp__cp_svmodes.sv39);
       ignore_bins vsatp_bare_mode                  = binsof(hext__vsatp__cp_svmodes.bare);
       ignore_bins hgatp_bare_mode                  = binsof(hext__hgatp__cp_svmodes.bare);       
       ignore_bins large_pages_in_sv48_vsatp_mode   =  binsof(hext__vsatp__cp_svmodes.sv48) &&
                                                    binsof(hext__pagesize__cp_dside_vstage_paginglevel) intersect {DVPAGESIZE_256T, DVPAGESIZE_512G, DVPAGESIZE_1G, DVPAGESIZE_2M};
       ignore_bins large_pages_in_sv57_vsatp_mode   =  binsof(hext__vsatp__cp_svmodes.sv57) &&
                                                    binsof(hext__pagesize__cp_dside_vstage_paginglevel) intersect { DVPAGESIZE_256T, DVPAGESIZE_512G, DVPAGESIZE_1G}; 
       ignore_bins no_gstage_lvl4_walk_vstage_256t = binsof(hext__pagesize__cp_dside_vstage_paginglevel) intersect {DVPAGESIZE_256T};
    }
    hext__ptw__cr_hgatp_vsatp_svmodes_with_all_page_sizes_lvl5: cross hext__vsatp__cp_svmodes, hext__pagesize__cp_dside_vstage_paginglevel, hext__hgatp__cp_svmodes, hext__pagesize__cp_dside_gstagelevel5_paginglevel {
       ignore_bins large_pages_in_sv39_hgatp_mode   =  binsof(hext__hgatp__cp_svmodes.sv39) &&
                                                    binsof(hext__pagesize__cp_dside_gstagelevel5_paginglevel) intersect {DPAGESIZE_GSTAGELEVEL5_256T, DPAGESIZE_GSTAGELEVEL5_512G} ;
       ignore_bins large_pages_in_sv48_hgatp_mode   =  binsof(hext__hgatp__cp_svmodes.sv48) &&
                                                    binsof(hext__pagesize__cp_dside_gstagelevel5_paginglevel) intersect {DPAGESIZE_GSTAGELEVEL5_256T} ;
       ignore_bins vsatp_sv39_mode                  = binsof(hext__vsatp__cp_svmodes.sv39);
       ignore_bins vsatp_sv48_mode                  = binsof(hext__vsatp__cp_svmodes.sv48);
       ignore_bins vsatp_bare_mode                  = binsof(hext__vsatp__cp_svmodes.bare);
       ignore_bins hgatp_bare_mode                  = binsof(hext__hgatp__cp_svmodes.bare);
       ignore_bins large_pages_in_sv57_vsatp_mode   = binsof(hext__vsatp__cp_svmodes.sv57) &&
                                                    binsof(hext__pagesize__cp_dside_vstage_paginglevel) intersect {DVPAGESIZE_256T, DVPAGESIZE_512G, DVPAGESIZE_1G, DVPAGESIZE_2M}; 
    }

    hext__ptw__cr_hgatp_vsatp_svmodes_with_all_page_sizes_leaf_instr : cross hext__ptw__cr_hgatp_vsatp_svmodes_with_all_page_sizes_leaf, hext__accesstype__cp_instr_2_lvl;
    hext__ptw__cr_hgatp_vsatp_svmodes_with_all_page_sizes_leaf_h_instr : cross hext__ptw__cr_hgatp_vsatp_svmodes_with_all_page_sizes_leaf, hext__accesstype__cp_h_instr_2_lvl;
    hext__ptw__cr_hgatp_vsatp_svmodes_with_all_page_sizes_lvl1_instr : cross hext__ptw__cr_hgatp_vsatp_svmodes_with_all_page_sizes_lvl1, hext__accesstype__cp_instr_2_lvl;
    hext__ptw__cr_hgatp_vsatp_svmodes_with_all_page_sizes_lvl1_h_instr : cross hext__ptw__cr_hgatp_vsatp_svmodes_with_all_page_sizes_lvl1, hext__accesstype__cp_h_instr_2_lvl;
    hext__ptw__cr_hgatp_vsatp_svmodes_with_all_page_sizes_lvl2_instr : cross hext__ptw__cr_hgatp_vsatp_svmodes_with_all_page_sizes_lvl2, hext__accesstype__cp_instr_2_lvl;
    hext__ptw__cr_hgatp_vsatp_svmodes_with_all_page_sizes_lvl2_h_instr : cross hext__ptw__cr_hgatp_vsatp_svmodes_with_all_page_sizes_lvl2, hext__accesstype__cp_h_instr_2_lvl;
    hext__ptw__cr_hgatp_vsatp_svmodes_with_all_page_sizes_lvl3_instr : cross hext__ptw__cr_hgatp_vsatp_svmodes_with_all_page_sizes_lvl3, hext__accesstype__cp_instr_2_lvl;
    hext__ptw__cr_hgatp_vsatp_svmodes_with_all_page_sizes_lvl3_h_instr : cross hext__ptw__cr_hgatp_vsatp_svmodes_with_all_page_sizes_lvl3, hext__accesstype__cp_h_instr_2_lvl;
    hext__ptw__cr_hgatp_vsatp_svmodes_with_all_page_sizes_lvl4_instr : cross hext__ptw__cr_hgatp_vsatp_svmodes_with_all_page_sizes_lvl4, hext__accesstype__cp_instr_2_lvl;
    hext__ptw__cr_hgatp_vsatp_svmodes_with_all_page_sizes_lvl4_h_instr : cross hext__ptw__cr_hgatp_vsatp_svmodes_with_all_page_sizes_lvl4, hext__accesstype__cp_h_instr_2_lvl;
    hext__ptw__cr_hgatp_vsatp_svmodes_with_all_page_sizes_lvl5_instr : cross hext__ptw__cr_hgatp_vsatp_svmodes_with_all_page_sizes_lvl5, hext__accesstype__cp_instr_2_lvl;
    hext__ptw__cr_hgatp_vsatp_svmodes_with_all_page_sizes_lvl5_h_instr : cross hext__ptw__cr_hgatp_vsatp_svmodes_with_all_page_sizes_lvl5, hext__accesstype__cp_h_instr_2_lvl;
    
    hext__privilege__cp_dside_eff_privilege_mode: cross hext__gen__cp_curpriv, hext__csr__cp_mstatus_mprv, hext__csr__cp_mstatus_mpp, hext__csr__cp_mstatus_mpv {
        option.cross_auto_bin_max                               = 0;
        bins effective_priv_machine                             = binsof(hext__gen__cp_curpriv.mmode) && 
                                                                binsof(hext__csr__cp_mstatus_mprv.mprv_low);
        bins effective_priv_machine_due_to_mprv                 = binsof(hext__gen__cp_curpriv.mmode) && 
                                                                binsof(hext__csr__cp_mstatus_mpp.mpp_machine) &&
                                                                binsof(hext__csr__cp_mstatus_mprv.mprv_high);
        bins effective_priv_hyper_supervisor                    = binsof(hext__gen__cp_curpriv.hsmode);
        bins effective_priv_hyper_supervisor_due_to_mprv        = binsof(hext__gen__cp_curpriv.mmode) &&
                                                                binsof(hext__csr__cp_mstatus_mpp.mpp_supervisor) &&
                                                                binsof(hext__csr__cp_mstatus_mprv.mprv_high) &&
                                                                binsof(hext__csr__cp_mstatus_mpv.mpv_low);
        bins effective_priv_user                                = binsof(hext__gen__cp_curpriv.umode);
        bins effective_priv_user_due_to_mprv                    = binsof(hext__gen__cp_curpriv.mmode) &&
                                                                binsof(hext__csr__cp_mstatus_mpp.mpp_user) &&
                                                                binsof(hext__csr__cp_mstatus_mprv.mprv_high) &&
                                                                binsof(hext__csr__cp_mstatus_mpv.mpv_low);
        bins effective_priv_virtual_supervisor                  = binsof(hext__gen__cp_curpriv.vsmode);
        bins effective_priv_virtual_supervisor_due_to_mprv      = binsof(hext__gen__cp_curpriv.mmode) &&
                                                                binsof(hext__csr__cp_mstatus_mpp.mpp_supervisor) &&
                                                                binsof(hext__csr__cp_mstatus_mprv.mprv_high) &&
                                                                binsof(hext__csr__cp_mstatus_mpv.mpv_high);
        bins effective_priv_virtual_user                        = binsof(hext__gen__cp_curpriv.vumode);
        bins effective_priv_virtual_user_due_to_mprv            = binsof(hext__gen__cp_curpriv.mmode) &&
                                                                binsof(hext__csr__cp_mstatus_mpp.mpp_user) &&
                                                                binsof(hext__csr__cp_mstatus_mprv.mprv_high) &&
                                                                binsof(hext__csr__cp_mstatus_mpv.mpv_high);                                                              
    }
    
    hext__privilege__cp_dside_eff_privilege_mode_hext_instr: cross hext__gen__cp_curpriv, hext__csr__cp_hstatus_spvp, hext__csr__cp_hstatus_hu {
        option.cross_auto_bin_max                               = 0;
        bins effective_priv_virtual_supervisor_due_to_spvp_m    = binsof(hext__gen__cp_curpriv.mmode) &&
                                                                binsof(hext__csr__cp_hstatus_spvp.spvp_high);
        bins effective_priv_virtual_supervisor_due_to_spvp_hs   = binsof(hext__gen__cp_curpriv.hsmode) &&
                                                                binsof(hext__csr__cp_hstatus_spvp.spvp_high);
        bins effective_priv_virtual_supervisor_due_to_spvp_u    = binsof(hext__gen__cp_curpriv.umode) &&
                                                                binsof(hext__csr__cp_hstatus_spvp.spvp_high) &&
                                                                binsof(hext__csr__cp_hstatus_hu.hu_high);
        bins effective_priv_virtual_user_due_to_spvp_m          = binsof(hext__gen__cp_curpriv.mmode) &&
                                                                binsof(hext__csr__cp_hstatus_spvp.spvp_low);
        bins effective_priv_virtual_user_due_to_spvp_hs         = binsof(hext__gen__cp_curpriv.hsmode) &&
                                                                binsof(hext__csr__cp_hstatus_spvp.spvp_low);
        bins effective_priv_virtual_user_due_to_spvp_u          = binsof(hext__gen__cp_curpriv.umode) &&
                                                                binsof(hext__csr__cp_hstatus_spvp.spvp_low) &&
                                                                binsof(hext__csr__cp_hstatus_hu.hu_high);
    }

    hext__ptw__cr_all_priv_modes_with_instr_v_one: cross hext__vsatp__cp_svmodes, hext__hgatp__cp_svmodes, hext__privilege__cp_dside_eff_privilege_mode, hext__accesstype__cp_instr_2_lvl {
        ignore_bins m_mode          =  binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_machine);
        ignore_bins m_mode_mprv     =  binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_machine_due_to_mprv);
        ignore_bins hs_mode         =  binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_hyper_supervisor);
        ignore_bins hs_mode_mprv    =  binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_hyper_supervisor_due_to_mprv);
        ignore_bins hu_mode         =  binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_user);
        ignore_bins hu_mode_mprv    =  binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_user_due_to_mprv);
        ignore_bins vs_mode_mprv    =  binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_supervisor_due_to_mprv);
        ignore_bins vu_mode_mprv    =  binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_user_due_to_mprv);
    }

    hext__ptw__cr_all_priv_modes_with_instr_mprv: cross hext__vsatp__cp_svmodes, hext__hgatp__cp_svmodes, hext__privilege__cp_dside_eff_privilege_mode, hext__accesstype__cp_instr_2_lvl_mprv {
        ignore_bins m_mode          =  binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_machine);
        ignore_bins m_mode_mprv     =  binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_machine_due_to_mprv);
        ignore_bins hs_mode         =  binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_hyper_supervisor);
        ignore_bins hs_mode_mprv    =  binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_hyper_supervisor_due_to_mprv);
        ignore_bins hu_mode         =  binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_user);
        ignore_bins hu_mode_mprv    =  binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_user_due_to_mprv);
        ignore_bins vs_mode         =  binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_supervisor);
        ignore_bins vu_mode         =  binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_user);
    }

    hext__ptw__cr_all_eff_priv_modes_with_hext_instr : cross  hext__vsatp__cp_svmodes, hext__hgatp__cp_svmodes, hext__privilege__cp_dside_eff_privilege_mode_hext_instr, hext__accesstype__cp_h_instr_2_lvl, hext__csr__cp_sstatus_mxr, hext__csr__cp_vsstatus_mxr  {
        ignore_bins hlvx_instr_both_mxr_1    = binsof(hext__accesstype__cp_h_instr_2_lvl.h_loads_x) &&
                                        binsof(hext__csr__cp_sstatus_mxr.mxr_high) &&
                                        binsof(hext__csr__cp_vsstatus_mxr.mxr_high);
        ignore_bins hlvx_instr_sstatus_mxr_1    = binsof(hext__accesstype__cp_h_instr_2_lvl.h_loads_x) &&
                                        binsof(hext__csr__cp_sstatus_mxr.mxr_high) &&
                                        binsof(hext__csr__cp_vsstatus_mxr.mxr_low);
        ignore_bins hlvx_instr_vsstatus_mxr_1    = binsof(hext__accesstype__cp_h_instr_2_lvl.h_loads_x) &&
                                        binsof(hext__csr__cp_sstatus_mxr.mxr_low) &&
                                        binsof(hext__csr__cp_vsstatus_mxr.mxr_high);
        ignore_bins hload_instr_both_mxr_0    = binsof(hext__accesstype__cp_h_instr_2_lvl.h_loads) &&
                                        binsof(hext__csr__cp_sstatus_mxr.mxr_low) &&
                                        binsof(hext__csr__cp_vsstatus_mxr.mxr_low);
        ignore_bins hstore_instr_both_mxr_0    = binsof(hext__accesstype__cp_h_instr_2_lvl.h_stores) &&
                                        binsof(hext__csr__cp_sstatus_mxr.mxr_low) &&
                                        binsof(hext__csr__cp_vsstatus_mxr.mxr_low);
    }

    hext__ptw__cr_vpn4: cross hext__ptw__cp_vpn_bit_56_to_48, hext__pagesize__cp_dside_vstage_paginglevel;
    hext__ptw__cr_vpn3: cross hext__ptw__cp_vpn_bit_47_to_39, hext__pagesize__cp_dside_vstage_paginglevel {
        ignore_bins invalid_large_page_size_vpn3 = binsof(hext__pagesize__cp_dside_vstage_paginglevel) intersect {DVPAGESIZE_256T};
    }
    hext__ptw__cr_vpn2: cross hext__ptw__cp_vpn_bit_38_to_30, hext__pagesize__cp_dside_vstage_paginglevel {
        ignore_bins invalid_large_page_size_vpn2 = binsof(hext__pagesize__cp_dside_vstage_paginglevel) intersect {DVPAGESIZE_256T, DVPAGESIZE_512G};
    }
    hext__ptw__cr_vpn1: cross hext__ptw__cp_vpn_bit_29_to_21, hext__pagesize__cp_dside_vstage_paginglevel {
        ignore_bins invalid_large_page_size_vpn1 = binsof(hext__pagesize__cp_dside_vstage_paginglevel) intersect {DVPAGESIZE_256T, DVPAGESIZE_512G, DVPAGESIZE_1G};
    }
    hext__ptw__cr_vpn0: cross hext__ptw__cp_vpn_bit_20_to_12, hext__pagesize__cp_dside_vstage_paginglevel {
        ignore_bins invalid_large_page_size_vpn0 = binsof(hext__pagesize__cp_dside_vstage_paginglevel) intersect {DVPAGESIZE_256T, DVPAGESIZE_512G, DVPAGESIZE_1G, DVPAGESIZE_2M};
    }

    hext__ptw__cr_gpa_vpn4_sv57: cross hext__ptw__cp_dside_gpa_vpn_bit_58_to_48_sv57, hext__pagesize__cp_dside_paginglevel;
    hext__ptw__cr_gpa_vpn3_sv48: cross hext__ptw__cp_dside_gpa_vpn_bit_49_to_39_sv48, hext__pagesize__cp_dside_paginglevel{
       ignore_bins invalid_large_page_size_vpn3 = binsof(hext__pagesize__cp_dside_paginglevel) intersect {DPAGESIZE_256T};
    }
    hext__ptw__cr_gpa_vpn2_sv39: cross hext__ptw__cp_dside_gpa_vpn_bit_40_to_30_sv39, hext__pagesize__cp_dside_paginglevel{
        ignore_bins invalid_large_page_size_vpn2 = binsof(hext__pagesize__cp_dside_paginglevel) intersect {DPAGESIZE_256T, DPAGESIZE_512G};
    }
    hext__ptw__cr_gpa_vpn3: cross hext__ptw__cp_dside_gpa_vpn_bit_47_to_39, hext__pagesize__cp_dside_paginglevel{
       ignore_bins invalid_large_page_size_vpn3 = binsof(hext__pagesize__cp_dside_paginglevel) intersect {DPAGESIZE_256T};
    }
    hext__ptw__cr_gpa_vpn2: cross hext__ptw__cp_dside_gpa_vpn_bit_38_to_30, hext__pagesize__cp_dside_paginglevel{
       ignore_bins invalid_large_page_size_vpn2 = binsof(hext__pagesize__cp_dside_paginglevel) intersect {DPAGESIZE_256T, DPAGESIZE_512G};
    }
    hext__ptw__cr_gpa_vpn1: cross hext__ptw__cp_dside_gpa_vpn_bit_29_to_21, hext__pagesize__cp_dside_paginglevel{
       ignore_bins invalid_large_page_size_vpn1 = binsof(hext__pagesize__cp_dside_paginglevel) intersect {DPAGESIZE_256T, DPAGESIZE_512G, DPAGESIZE_1G};
    }
    hext__ptw__cr_gpa_vpn0: cross hext__ptw__cp_dside_gpa_vpn_bit_20_to_12, hext__pagesize__cp_dside_paginglevel{
       ignore_bins invalid_large_page_size_vpn0 = binsof(hext__pagesize__cp_dside_paginglevel) intersect {DPAGESIZE_256T, DPAGESIZE_512G, DPAGESIZE_1G, DPAGESIZE_2M};
    }

    hext__ptw__cr_d_pagecrosser_pagesize: cross hext__pagesize__cp_dside_paginglevel, hext__pagesize__cp_dside_cross_paginglevel {
         option.cross_auto_bin_max   = 0;
         bins hext_pgcr_4k_4k       = binsof(hext__pagesize__cp_dside_paginglevel) intersect {DPAGESIZE_4K} &&
                                    binsof(hext__pagesize__cp_dside_cross_paginglevel) intersect {DPAGECROSSSIZE_4K};
         bins hext_pgcr_2M_2M       = binsof(hext__pagesize__cp_dside_paginglevel) intersect {DPAGESIZE_2M} &&
                                    binsof(hext__pagesize__cp_dside_cross_paginglevel) intersect {DPAGECROSSSIZE_2M};
         bins hext_pgcr_1G_1G       = binsof(hext__pagesize__cp_dside_paginglevel) intersect {DPAGESIZE_1G} &&
                                    binsof(hext__pagesize__cp_dside_cross_paginglevel) intersect {DPAGECROSSSIZE_1G};
         bins hext_pgcr_512G_512G   = binsof(hext__pagesize__cp_dside_paginglevel) intersect {DPAGESIZE_512G} &&
                                    binsof(hext__pagesize__cp_dside_cross_paginglevel) intersect {DPAGECROSSSIZE_512G};
         bins hext_pgcr_256T_256T   = binsof(hext__pagesize__cp_dside_paginglevel) intersect {DPAGESIZE_256T} &&
                                    binsof(hext__pagesize__cp_dside_cross_paginglevel) intersect {DPAGECROSSSIZE_256T};
         bins hext_pgcr_4k_any      = binsof(hext__pagesize__cp_dside_paginglevel) intersect {DPAGESIZE_4K} &&
                                    binsof(hext__pagesize__cp_dside_cross_paginglevel) 
                                    intersect {DPAGECROSSSIZE_4K,DPAGECROSSSIZE_1G,DPAGECROSSSIZE_512G,DPAGECROSSSIZE_256T};
         bins hext_pgcr_2M_any      = binsof(hext__pagesize__cp_dside_paginglevel) intersect {DPAGESIZE_2M} &&
                                    binsof(hext__pagesize__cp_dside_cross_paginglevel) 
                                    intersect {DPAGECROSSSIZE_4K,DPAGECROSSSIZE_1G,DPAGECROSSSIZE_512G,DPAGECROSSSIZE_256T};
         bins hext_pgcr_1G_any      = binsof(hext__pagesize__cp_dside_paginglevel) intersect {DPAGESIZE_1G} &&
                                    binsof(hext__pagesize__cp_dside_cross_paginglevel) 
                                    intersect {DPAGECROSSSIZE_4K,DPAGECROSSSIZE_2M,DPAGECROSSSIZE_512G,DPAGECROSSSIZE_256T};
         bins hext_pgcr_512G_any    = binsof(hext__pagesize__cp_dside_paginglevel) intersect {DPAGESIZE_512G} &&
                                    binsof(hext__pagesize__cp_dside_cross_paginglevel) 
                                    intersect {DPAGECROSSSIZE_4K,DPAGECROSSSIZE_2M,DPAGECROSSSIZE_1G,DPAGECROSSSIZE_256T};
         bins hext_pgcr_256T_any    = binsof(hext__pagesize__cp_dside_paginglevel) intersect {DPAGESIZE_256T} &&
                                    binsof(hext__pagesize__cp_dside_cross_paginglevel) 
                                    intersect {DPAGECROSSSIZE_4K, DPAGECROSSSIZE_2M,DPAGECROSSSIZE_1G,DPAGECROSSSIZE_512G};
    }
    hext__ptw__cr_i_pagecrosser_pagesize: cross hext__pagesize__cp_iside_paginglevel, hext__pagesize__cp_iside_cross_paginglevel {
         option.cross_auto_bin_max   = 0;
         bins hext_pgcr_4k_4k       = binsof(hext__pagesize__cp_iside_paginglevel) intersect {FPAGESIZE_4K} &&
                                    binsof(hext__pagesize__cp_iside_cross_paginglevel) intersect {FPAGECROSSSIZE_4K};
         bins hext_pgcr_2M_2M       = binsof(hext__pagesize__cp_iside_paginglevel) intersect {FPAGESIZE_2M} &&
                                    binsof(hext__pagesize__cp_iside_cross_paginglevel) intersect {FPAGECROSSSIZE_2M};
         bins hext_pgcr_1G_1G       = binsof(hext__pagesize__cp_iside_paginglevel) intersect {FPAGESIZE_1G} &&
                                    binsof(hext__pagesize__cp_iside_cross_paginglevel) intersect {FPAGECROSSSIZE_1G};
         bins hext_pgcr_512G_512G   = binsof(hext__pagesize__cp_iside_paginglevel) intersect {FPAGESIZE_512G} &&
                                    binsof(hext__pagesize__cp_iside_cross_paginglevel) intersect {FPAGECROSSSIZE_512G};
         bins hext_pgcr_256T_256T   = binsof(hext__pagesize__cp_iside_paginglevel) intersect {FPAGESIZE_256T} &&
                                    binsof(hext__pagesize__cp_iside_cross_paginglevel) intersect {FPAGECROSSSIZE_256T};
         bins hext_pgcr_4k_any      = binsof(hext__pagesize__cp_iside_paginglevel) intersect {FPAGESIZE_4K} &&
                                    binsof(hext__pagesize__cp_iside_cross_paginglevel) 
                                    intersect {FPAGECROSSSIZE_4K,FPAGECROSSSIZE_1G,FPAGECROSSSIZE_512G,FPAGECROSSSIZE_256T};
         bins hext_pgcr_2M_any      = binsof(hext__pagesize__cp_iside_paginglevel) intersect {FPAGESIZE_2M} &&
                                    binsof(hext__pagesize__cp_iside_cross_paginglevel) 
                                    intersect {FPAGECROSSSIZE_4K,FPAGECROSSSIZE_1G,FPAGECROSSSIZE_512G,FPAGECROSSSIZE_256T};
         bins hext_pgcr_1G_any      = binsof(hext__pagesize__cp_iside_paginglevel) intersect {FPAGESIZE_1G} &&
                                    binsof(hext__pagesize__cp_iside_cross_paginglevel) 
                                    intersect {FPAGECROSSSIZE_4K,FPAGECROSSSIZE_2M,FPAGECROSSSIZE_512G,FPAGECROSSSIZE_256T};
         bins hext_pgcr_512G_any    = binsof(hext__pagesize__cp_iside_paginglevel) intersect {FPAGESIZE_512G} &&
                                    binsof(hext__pagesize__cp_iside_cross_paginglevel) 
                                    intersect {FPAGECROSSSIZE_4K,FPAGECROSSSIZE_2M,FPAGECROSSSIZE_1G,FPAGECROSSSIZE_256T};
         bins hext_pgcr_256T_any    = binsof(hext__pagesize__cp_iside_paginglevel) intersect {FPAGESIZE_256T} &&
                                    binsof(hext__pagesize__cp_iside_cross_paginglevel) 
                                    intersect {FPAGECROSSSIZE_4K, FPAGECROSSSIZE_2M,FPAGECROSSSIZE_1G,FPAGECROSSSIZE_512G};
    }

    hext__ptw__cp_misaligned_ldst: coverpoint LdStMisal;

    hext__pagefault__cr_i_sv39_va_maxbits: cross hext__vsatp__cp_modes, hext__ptw__cp_virtual_pc_bitsel_38 {
        option.cross_auto_bin_max   = 0;
        bins iside_sv39_vamax_bit_0     = binsof(hext__vsatp__cp_modes) intersect {8} &&
                                        binsof(hext__ptw__cp_virtual_pc_bitsel_38)intersect {0} iff (VirtPc[63:39] != 25'b0_0000_0000_0000_0000_0000_0000);
        bins iside_sv39_vamax_bit_1     = binsof(hext__vsatp__cp_modes) intersect {8} &&
                                        binsof(hext__ptw__cp_virtual_pc_bitsel_38)intersect {1} iff (VirtPc[63:39] != 25'b1_1111_1111_1111_1111_1111_1111 );      
    }
    hext__pagefault__cr_i_sv48_va_maxbits: cross hext__vsatp__cp_modes, hext__ptw__cp_virtual_pc_bitsel_47 {
        option.cross_auto_bin_max   = 0;
        bins iside_sv48_vamax_bit_0     = binsof(hext__vsatp__cp_modes) intersect {9} &&
                                        binsof(hext__ptw__cp_virtual_pc_bitsel_47)intersect {0} iff (VirtPc[63:48] != 16'b0000_0000_0000_0000);
        bins iside_sv48_vamax_bit_1     = binsof(hext__vsatp__cp_modes) intersect {9} &&
                                        binsof(hext__ptw__cp_virtual_pc_bitsel_47)intersect {1} iff (VirtPc[63:48] != 16'b1111_1111_1111_1111);     
    }
    hext__pagefault__cr_i_sv57_va_maxbits: cross hext__vsatp__cp_modes, hext__ptw__cp_virtual_pc_bitsel_56 {
        option.cross_auto_bin_max   = 0;
        bins iside_sv57_vamax_bit_0     = binsof(hext__vsatp__cp_modes) intersect {10} &&
                                        binsof(hext__ptw__cp_virtual_pc_bitsel_56)intersect {0} iff (VirtPc[63:57] != 7'b000_0000);
        bins iside_sv57_vamax_bit_1     = binsof(hext__vsatp__cp_modes) intersect {10} &&
                                        binsof(hext__ptw__cp_virtual_pc_bitsel_56)intersect {1} iff (VirtPc[63:57] != 7'b111_1111);
    }
    hext__pagefault__cr_d_sv39_va_maxbits: cross hext__vsatp__cp_modes, hext__ptw__cp_virtual_ldst_bitsel_38 {
        option.cross_auto_bin_max   = 0;
        bins dside_sv39_vamax_bit_0 = binsof(hext__vsatp__cp_modes) intersect {8} &&
                            binsof(hext__ptw__cp_virtual_ldst_bitsel_38)intersect {0} iff (VirtLdStAddr[63:39] != 25'b0_0000_0000_0000_0000_0000_0000);
        bins dside_sv39_vamax_bit_1 = binsof(hext__vsatp__cp_modes) intersect {8} &&
                            binsof(hext__ptw__cp_virtual_ldst_bitsel_38)intersect {1} iff (VirtLdStAddr[63:39] != 25'b1_1111_1111_1111_1111_1111_1111 );        
    }
    hext__pagefault__cr_d_sv48_va_maxbits: cross hext__vsatp__cp_modes, hext__ptw__cp_virtual_ldst_bitsel_47 {
        option.cross_auto_bin_max   = 0;
        bins dside_sv48_vamax_bit_0 = binsof(hext__vsatp__cp_modes) intersect {9} &&
                            binsof( hext__ptw__cp_virtual_ldst_bitsel_47)intersect {0} iff (VirtLdStAddr[63:48] != 16'b0000_0000_0000_0000);
        bins dside_sv48_vamax_bit_1 = binsof(hext__vsatp__cp_modes) intersect {9} &&
                            binsof( hext__ptw__cp_virtual_ldst_bitsel_47)intersect {1} iff (VirtLdStAddr[63:48] != 16'b1111_1111_1111_1111);      
    }
    hext__pagefault__cr_d_sv57_va_maxbits: cross hext__vsatp__cp_modes, hext__ptw__cp_virtual_ldst_bitsel_56 {
        option.cross_auto_bin_max   = 0;
        bins dside_sv57_vamax_bit_0 = binsof(hext__vsatp__cp_modes) intersect {10} &&
                            binsof(hext__ptw__cp_virtual_ldst_bitsel_56)intersect {0} iff (VirtLdStAddr[63:57] != 7'b000_0000);
        bins dside_sv57_vamax_bit_1 = binsof(hext__vsatp__cp_modes) intersect {10} &&
                            binsof(hext__ptw__cp_virtual_ldst_bitsel_56)intersect {1} iff (VirtLdStAddr[63:57] != 7'b111_1111);
    }

    hext__ptw__cr_d_ptwppn_2m_align: cross hext__pagesize__cp_dside_vstage_paginglevel, hext__ptw__dpte_leaf_ppn_lvl2_align {
        option.cross_auto_bin_max   = 0;
        bins aligned        = binsof(hext__pagesize__cp_dside_vstage_paginglevel) intersect {DPAGESIZE_2M} &&
                              binsof(hext__ptw__dpte_leaf_ppn_lvl2_align.aligned);
        bins non_aligned    = binsof(hext__pagesize__cp_dside_vstage_paginglevel) intersect {DPAGESIZE_2M} &&
                              binsof(hext__ptw__dpte_leaf_ppn_lvl2_align.non_aligned);
    }
    hext__ptw__cr_d_ptwppn_1g_align: cross hext__pagesize__cp_dside_vstage_paginglevel, hext__ptw__dpte_leaf_ppn_lvl3_align {
        option.cross_auto_bin_max   = 0;
        bins aligned        = binsof(hext__pagesize__cp_dside_vstage_paginglevel) intersect {DPAGESIZE_1G} &&
                              binsof(hext__ptw__dpte_leaf_ppn_lvl3_align.aligned);
        bins non_aligned    = binsof(hext__pagesize__cp_dside_vstage_paginglevel) intersect {DPAGESIZE_1G} &&
                              binsof(hext__ptw__dpte_leaf_ppn_lvl3_align.non_aligned);
    }
    hext__ptw__cr_d_ptwppn_512g_align: cross hext__pagesize__cp_dside_vstage_paginglevel, hext__ptw__dpte_leaf_ppn_lvl4_align {
        option.cross_auto_bin_max   = 0;
        bins aligned        = binsof(hext__pagesize__cp_dside_vstage_paginglevel) intersect {DPAGESIZE_512G} &&
                              binsof(hext__ptw__dpte_leaf_ppn_lvl4_align.aligned);
        bins non_aligned    = binsof(hext__pagesize__cp_dside_vstage_paginglevel) intersect {DPAGESIZE_512G} &&
                              binsof(hext__ptw__dpte_leaf_ppn_lvl4_align.non_aligned);
    }

    hext__ptw__cr_i_ptwppn_2m_align: cross hext__pagesize__cp_iside_vstage_paginglevel, hext__ptw__ipte_leaf_ppn_lvl2_align {
        option.cross_auto_bin_max   = 0;
        bins aligned        = binsof(hext__pagesize__cp_iside_vstage_paginglevel) intersect {FPAGESIZE_2M} &&
                              binsof(hext__ptw__ipte_leaf_ppn_lvl2_align.aligned);
        bins non_aligned    = binsof(hext__pagesize__cp_iside_vstage_paginglevel) intersect {FPAGESIZE_2M} &&
                              binsof(hext__ptw__ipte_leaf_ppn_lvl2_align.non_aligned);
    }
    hext__ptw__cr_i_ptwppn_1g_align: cross hext__pagesize__cp_iside_vstage_paginglevel, hext__ptw__ipte_leaf_ppn_lvl3_align {
        option.cross_auto_bin_max   = 0;
        bins aligned        = binsof(hext__pagesize__cp_iside_vstage_paginglevel) intersect {FPAGESIZE_1G} &&
                              binsof(hext__ptw__ipte_leaf_ppn_lvl3_align.aligned);
        bins non_aligned    = binsof(hext__pagesize__cp_iside_vstage_paginglevel) intersect {FPAGESIZE_1G} &&
                              binsof(hext__ptw__ipte_leaf_ppn_lvl3_align.non_aligned);
    }
    hext__ptw__cr_i_ptwppn_512g_align: cross hext__pagesize__cp_iside_vstage_paginglevel, hext__ptw__ipte_leaf_ppn_lvl4_align {
        option.cross_auto_bin_max   = 0;
        bins aligned        = binsof(hext__pagesize__cp_iside_vstage_paginglevel) intersect {FPAGESIZE_512G} &&
                              binsof(hext__ptw__ipte_leaf_ppn_lvl4_align.aligned);
        bins non_aligned    = binsof(hext__pagesize__cp_iside_vstage_paginglevel) intersect {FPAGESIZE_512G} &&
                              binsof(hext__ptw__ipte_leaf_ppn_lvl4_align.non_aligned);
    }

    hext__ptw__dpte_gstage_lvl1_leaf_ppn_2m_align: coverpoint DPTELeaf_GStageLevel1[PTE_PPN0_HI:PTE_PPN0_LO] {
        bins non_aligned    = {[9'b000000001:9'b111111111]};
    }
    hext__ptw__dpte_gstage_lvl2_leaf_ppn_2m_align: coverpoint DPTELeaf_GStageLevel2[PTE_PPN0_HI:PTE_PPN0_LO] {
        bins non_aligned    = {[9'b000000001:9'b111111111]};
    }
    hext__ptw__dpte_gstage_lvl3_leaf_ppn_2m_align: coverpoint DPTELeaf_GStageLevel3[PTE_PPN0_HI:PTE_PPN0_LO] {
        bins non_aligned    = {[9'b000000001:9'b111111111]};
    }
    hext__ptw__dpte_gstage_lvl4_leaf_ppn_2m_align: coverpoint DPTELeaf_GStageLevel4[PTE_PPN0_HI:PTE_PPN0_LO] {
        bins non_aligned    = {[9'b000000001:9'b111111111]};
    }

    hext__ptw__ipte_gstage_lvl1_leaf_ppn_2m_align: coverpoint FPTELeaf_GStageLevel1[PTE_PPN0_HI:PTE_PPN0_LO] {
        bins non_aligned    = {[9'b000000001:9'b111111111]};
    }
    hext__ptw__ipte_gstage_lvl2_leaf_ppn_2m_align: coverpoint FPTELeaf_GStageLevel2[PTE_PPN0_HI:PTE_PPN0_LO] {
        bins non_aligned    = {[9'b000000001:9'b111111111]};
    }
    hext__ptw__ipte_gstage_lvl3_leaf_ppn_2m_align: coverpoint FPTELeaf_GStageLevel3[PTE_PPN0_HI:PTE_PPN0_LO] {
        bins non_aligned    = {[9'b000000001:9'b111111111]};
    }
    hext__ptw__ipte_gstage_lvl4_leaf_ppn_2m_align: coverpoint FPTELeaf_GStageLevel4[PTE_PPN0_HI:PTE_PPN0_LO] {
        bins non_aligned    = {[9'b000000001:9'b111111111]};
    }

    hext__ptw__dpte_gstage_lvl1_leaf_ppn_1g_align: coverpoint DPTELeaf_GStageLevel1[PTE_PPN1_HI:PTE_PPN0_LO] {
        bins non_aligned    = {[18'b000000000000000001:18'b111111111111111111]};
    }
    hext__ptw__dpte_gstage_lvl2_leaf_ppn_1g_align: coverpoint DPTELeaf_GStageLevel2[PTE_PPN1_HI:PTE_PPN0_LO] {
        bins non_aligned    = {[18'b000000000000000001:18'b111111111111111111]};
    }
    hext__ptw__dpte_gstage_lvl3_leaf_ppn_1g_align: coverpoint DPTELeaf_GStageLevel3[PTE_PPN1_HI:PTE_PPN0_LO] {
        bins non_aligned    = {[18'b000000000000000001:18'b111111111111111111]};
    }
    hext__ptw__dpte_gstage_lvl4_leaf_ppn_1g_align: coverpoint DPTELeaf_GStageLevel4[PTE_PPN1_HI:PTE_PPN0_LO] {
        bins non_aligned    = {[18'b000000000000000001:18'b111111111111111111]};
    }

    hext__ptw__ipte_gstage_lvl1_leaf_ppn_1g_align: coverpoint FPTELeaf_GStageLevel1[PTE_PPN1_HI:PTE_PPN0_LO] {
        bins non_aligned    = {[18'b000000000000000001:18'b111111111111111111]};
    }
    hext__ptw__ipte_gstage_lvl2_leaf_ppn_1g_align: coverpoint FPTELeaf_GStageLevel2[PTE_PPN1_HI:PTE_PPN0_LO] {
        bins non_aligned    = {[18'b000000000000000001:18'b111111111111111111]};
    }
    hext__ptw__ipte_gstage_lvl3_leaf_ppn_1g_align: coverpoint FPTELeaf_GStageLevel3[PTE_PPN1_HI:PTE_PPN0_LO] {
        bins non_aligned    = {[18'b000000000000000001:18'b111111111111111111]};
    }
    hext__ptw__ipte_gstage_lvl4_leaf_ppn_1g_align: coverpoint FPTELeaf_GStageLevel4[PTE_PPN1_HI:PTE_PPN0_LO] {
        bins non_aligned    = {[18'b000000000000000001:18'b111111111111111111]};
    }

    hext__ptw__dpte_gstage_lvl1_leaf_ppn_512g_align: coverpoint DPTELeaf_GStageLevel1[PTE_PPN2_HI:PTE_PPN0_LO] {
        bins non_aligned    = {[27'b000000000000000000000000001:27'b111111111111111111111111111]};
    }
    hext__ptw__dpte_gstage_lvl2_leaf_ppn_512g_align: coverpoint DPTELeaf_GStageLevel2[PTE_PPN2_HI:PTE_PPN0_LO] {
        bins non_aligned    = {[27'b000000000000000000000000001:27'b111111111111111111111111111]};
    }
    hext__ptw__dpte_gstage_lvl3_leaf_ppn_512g_align: coverpoint DPTELeaf_GStageLevel3[PTE_PPN2_HI:PTE_PPN0_LO] {
        bins non_aligned    = {[27'b000000000000000000000000001:27'b111111111111111111111111111]};
    }
    hext__ptw__dpte_gstage_lvl4_leaf_ppn_512g_align: coverpoint DPTELeaf_GStageLevel4[PTE_PPN2_HI:PTE_PPN0_LO] {
        bins non_aligned    = {[27'b000000000000000000000000001:27'b111111111111111111111111111]};
    }

    hext__ptw__ipte_gstage_lvl1_leaf_ppn_512g_align: coverpoint FPTELeaf_GStageLevel1[PTE_PPN2_HI:PTE_PPN0_LO] {
        bins non_aligned    = {[27'b000000000000000000000000001:27'b111111111111111111111111111]};
    }
    hext__ptw__ipte_gstage_lvl2_leaf_ppn_512g_align: coverpoint FPTELeaf_GStageLevel2[PTE_PPN2_HI:PTE_PPN0_LO] {
        bins non_aligned    = {[27'b000000000000000000000000001:27'b111111111111111111111111111]};
    }
    hext__ptw__ipte_gstage_lvl3_leaf_ppn_512g_align: coverpoint FPTELeaf_GStageLevel3[PTE_PPN2_HI:PTE_PPN0_LO] {
        bins non_aligned    = {[27'b000000000000000000000000001:27'b111111111111111111111111111]};
    }
    hext__ptw__ipte_gstage_lvl4_leaf_ppn_512g_align: coverpoint FPTELeaf_GStageLevel4[PTE_PPN2_HI:PTE_PPN0_LO] {
        bins non_aligned    = {[27'b000000000000000000000000001:27'b111111111111111111111111111]};
    }

    hext__ptw__dpte_gstage_lvl1_leaf_ppn_256t_align: coverpoint DPTELeaf_GStageLevel1[PTE_PPN3_HI:PTE_PPN0_LO] {
        bins non_aligned    = {[36'b000000000000000000000000000000000001:36'b111111111111111111111111111111111111]};
    }
    hext__ptw__dpte_gstage_lvl2_leaf_ppn_256t_align: coverpoint DPTELeaf_GStageLevel2[PTE_PPN3_HI:PTE_PPN0_LO] {
        bins non_aligned    = {[36'b000000000000000000000000000000000001:36'b111111111111111111111111111111111111]};
    }
    hext__ptw__dpte_gstage_lvl3_leaf_ppn_256t_align: coverpoint DPTELeaf_GStageLevel3[PTE_PPN3_HI:PTE_PPN0_LO] {
        bins non_aligned    = {[36'b000000000000000000000000000000000001:36'b111111111111111111111111111111111111]};
    }
    hext__ptw__dpte_gstage_lvl4_leaf_ppn_256t_align: coverpoint DPTELeaf_GStageLevel4[PTE_PPN3_HI:PTE_PPN0_LO] {
        bins non_aligned    = {[36'b000000000000000000000000000000000001:36'b111111111111111111111111111111111111]};
    }
    hext__ptw__dpte_gstage_lvl5_leaf_ppn_256t_align: coverpoint DPTELeaf_GStageLevel5[PTE_PPN3_HI:PTE_PPN0_LO] {
        bins non_aligned    = {[36'b000000000000000000000000000000000001:36'b111111111111111111111111111111111111]};
    }

    hext__ptw__ipte_gstage_lvl1_leaf_ppn_256t_align: coverpoint FPTELeaf_GStageLevel1[PTE_PPN3_HI:PTE_PPN0_LO] {
        bins non_aligned    = {[36'b000000000000000000000000000000000001:36'b111111111111111111111111111111111111]};
    }
    hext__ptw__ipte_gstage_lvl2_leaf_ppn_256t_align: coverpoint FPTELeaf_GStageLevel2[PTE_PPN3_HI:PTE_PPN0_LO] {
        bins non_aligned    = {[36'b000000000000000000000000000000000001:36'b111111111111111111111111111111111111]};
    }
    hext__ptw__ipte_gstage_lvl3_leaf_ppn_256t_align: coverpoint FPTELeaf_GStageLevel3[PTE_PPN3_HI:PTE_PPN0_LO] {
        bins non_aligned    = {[36'b000000000000000000000000000000000001:36'b111111111111111111111111111111111111]};
    }
    hext__ptw__ipte_gstage_lvl4_leaf_ppn_256t_align: coverpoint FPTELeaf_GStageLevel4[PTE_PPN3_HI:PTE_PPN0_LO] {
        bins non_aligned    = {[36'b000000000000000000000000000000000001:36'b111111111111111111111111111111111111]};
    }
    hext__ptw__ipte_gstage_lvl5_leaf_ppn_256t_align: coverpoint FPTELeaf_GStageLevel5[PTE_PPN3_HI:PTE_PPN0_LO] {
        bins non_aligned    = {[36'b000000000000000000000000000000000001:36'b111111111111111111111111111111111111]};
    }

    hext__guestpagefault__cr_d_gstage_lvl1_pte_2m_align: cross hext__pagesize__cp_dside_gstagelevel1_paginglevel, hext__ptw__dpte_gstage_lvl1_leaf_ppn_2m_align, hext__traps__cp_excp_def {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_load) && !binsof(hext__traps__cp_excp_def.guest_page_flt_store);
        bins non_aligned    = binsof(hext__pagesize__cp_dside_gstagelevel1_paginglevel) intersect {DPAGESIZE_GSTAGELEVEL1_2M} &&
                             binsof(hext__ptw__dpte_gstage_lvl1_leaf_ppn_2m_align.non_aligned);
    }

    hext__guestpagefault__cr_d_gstage_lvl2_pte_2m_align: cross hext__pagesize__cp_dside_gstagelevel2_paginglevel, hext__ptw__dpte_gstage_lvl2_leaf_ppn_2m_align, hext__traps__cp_excp_def {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_load) && !binsof(hext__traps__cp_excp_def.guest_page_flt_store);
        bins non_aligned    = binsof(hext__pagesize__cp_dside_gstagelevel2_paginglevel) intersect {DPAGESIZE_GSTAGELEVEL2_2M} &&
                             binsof(hext__ptw__dpte_gstage_lvl2_leaf_ppn_2m_align.non_aligned);
    }

    hext__guestpagefault__cr_d_gstage_lvl3_pte_2m_align: cross hext__pagesize__cp_dside_gstagelevel3_paginglevel, hext__ptw__dpte_gstage_lvl3_leaf_ppn_2m_align, hext__traps__cp_excp_def {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_load) && !binsof(hext__traps__cp_excp_def.guest_page_flt_store);
        bins non_aligned    = binsof(hext__pagesize__cp_dside_gstagelevel3_paginglevel) intersect {DPAGESIZE_GSTAGELEVEL3_2M} &&
                             binsof(hext__ptw__dpte_gstage_lvl3_leaf_ppn_2m_align.non_aligned);
    }

    hext__guestpagefault__cr_d_gstage_lvl4_pte_2m_align: cross hext__pagesize__cp_dside_gstagelevel4_paginglevel, hext__ptw__dpte_gstage_lvl4_leaf_ppn_2m_align, hext__traps__cp_excp_def {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_load) && !binsof(hext__traps__cp_excp_def.guest_page_flt_store);
        bins non_aligned    = binsof(hext__pagesize__cp_dside_gstagelevel4_paginglevel) intersect {DPAGESIZE_GSTAGELEVEL4_2M} &&
                             binsof(hext__ptw__dpte_gstage_lvl4_leaf_ppn_2m_align.non_aligned);
    }

    hext__guestpagefault__cr_i_gstage_lvl1_pte_2m_align: cross hext__pagesize__cp_iside_gstagelevel1_paginglevel, hext__ptw__ipte_gstage_lvl1_leaf_ppn_2m_align, hext__traps__cp_excp_def {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_instr);
        bins non_aligned    = binsof(hext__pagesize__cp_iside_gstagelevel1_paginglevel) intersect {FPAGESIZE_GSTAGELEVEL1_2M} &&
                             binsof(hext__ptw__ipte_gstage_lvl1_leaf_ppn_2m_align.non_aligned);
    }

    hext__guestpagefault__cr_i_gstage_lvl2_pte_2m_align: cross hext__pagesize__cp_iside_gstagelevel2_paginglevel, hext__ptw__ipte_gstage_lvl2_leaf_ppn_2m_align, hext__traps__cp_excp_def {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_instr);
        bins non_aligned    = binsof(hext__pagesize__cp_iside_gstagelevel2_paginglevel) intersect {FPAGESIZE_GSTAGELEVEL2_2M} &&
                             binsof(hext__ptw__ipte_gstage_lvl2_leaf_ppn_2m_align.non_aligned);
    }

    hext__guestpagefault__cr_i_gstage_lvl3_pte_2m_align: cross hext__pagesize__cp_iside_gstagelevel3_paginglevel, hext__ptw__ipte_gstage_lvl3_leaf_ppn_2m_align, hext__traps__cp_excp_def {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_instr);
        bins non_aligned    = binsof(hext__pagesize__cp_iside_gstagelevel3_paginglevel) intersect {FPAGESIZE_GSTAGELEVEL3_2M} &&
                             binsof(hext__ptw__ipte_gstage_lvl3_leaf_ppn_2m_align.non_aligned);
    }

    hext__guestpagefault__cr_i_gstage_lvl4_pte_2m_align: cross hext__pagesize__cp_iside_gstagelevel4_paginglevel, hext__ptw__ipte_gstage_lvl4_leaf_ppn_2m_align, hext__traps__cp_excp_def {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_instr);
        bins non_aligned    = binsof(hext__pagesize__cp_iside_gstagelevel4_paginglevel) intersect {FPAGESIZE_GSTAGELEVEL4_2M} &&
                             binsof(hext__ptw__ipte_gstage_lvl4_leaf_ppn_2m_align.non_aligned);
    }

    hext__guestpagefault__cr_d_gstage_lvl1_pte_1g_align: cross hext__pagesize__cp_dside_gstagelevel1_paginglevel, hext__ptw__dpte_gstage_lvl1_leaf_ppn_1g_align, hext__traps__cp_excp_def {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_load) && !binsof(hext__traps__cp_excp_def.guest_page_flt_store);
        bins non_aligned    = binsof(hext__pagesize__cp_dside_gstagelevel1_paginglevel) intersect {DPAGESIZE_GSTAGELEVEL1_1G} &&
                             binsof(hext__ptw__dpte_gstage_lvl1_leaf_ppn_1g_align.non_aligned);
    }

    hext__guestpagefault__cr_d_gstage_lvl2_pte_1g_align: cross hext__pagesize__cp_dside_gstagelevel2_paginglevel, hext__ptw__dpte_gstage_lvl2_leaf_ppn_1g_align, hext__traps__cp_excp_def {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_load) && !binsof(hext__traps__cp_excp_def.guest_page_flt_store);
        bins non_aligned    = binsof(hext__pagesize__cp_dside_gstagelevel2_paginglevel) intersect {DPAGESIZE_GSTAGELEVEL2_1G} &&
                             binsof(hext__ptw__dpte_gstage_lvl2_leaf_ppn_1g_align.non_aligned);
    }

    hext__guestpagefault__cr_d_gstage_lvl3_pte_1g_align: cross hext__pagesize__cp_dside_gstagelevel3_paginglevel, hext__ptw__dpte_gstage_lvl3_leaf_ppn_1g_align, hext__traps__cp_excp_def {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_load) && !binsof(hext__traps__cp_excp_def.guest_page_flt_store);
        bins non_aligned    = binsof(hext__pagesize__cp_dside_gstagelevel3_paginglevel) intersect {DPAGESIZE_GSTAGELEVEL3_1G} &&
                             binsof(hext__ptw__dpte_gstage_lvl3_leaf_ppn_1g_align.non_aligned);
    }

    hext__guestpagefault__cr_d_gstage_lvl4_pte_1g_align: cross hext__pagesize__cp_dside_gstagelevel4_paginglevel, hext__ptw__dpte_gstage_lvl4_leaf_ppn_1g_align, hext__traps__cp_excp_def {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_load) && !binsof(hext__traps__cp_excp_def.guest_page_flt_store);
        bins non_aligned    = binsof(hext__pagesize__cp_dside_gstagelevel4_paginglevel) intersect {DPAGESIZE_GSTAGELEVEL4_1G} &&
                             binsof(hext__ptw__dpte_gstage_lvl4_leaf_ppn_1g_align.non_aligned);
    }

    hext__guestpagefault__cr_i_gstage_lvl1_pte_1g_align: cross hext__pagesize__cp_iside_gstagelevel1_paginglevel, hext__ptw__ipte_gstage_lvl1_leaf_ppn_1g_align, hext__traps__cp_excp_def {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_instr);
        bins non_aligned    = binsof(hext__pagesize__cp_iside_gstagelevel1_paginglevel) intersect {FPAGESIZE_GSTAGELEVEL1_1G} &&
                             binsof(hext__ptw__ipte_gstage_lvl1_leaf_ppn_1g_align.non_aligned);
    }

    hext__guestpagefault__cr_i_gstage_lvl2_pte_1g_align: cross hext__pagesize__cp_iside_gstagelevel2_paginglevel, hext__ptw__ipte_gstage_lvl2_leaf_ppn_1g_align, hext__traps__cp_excp_def {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_instr);
        bins non_aligned    = binsof(hext__pagesize__cp_iside_gstagelevel2_paginglevel) intersect {FPAGESIZE_GSTAGELEVEL2_1G} &&
                             binsof(hext__ptw__ipte_gstage_lvl2_leaf_ppn_1g_align.non_aligned);
    }

    hext__guestpagefault__cr_i_gstage_lvl3_pte_1g_align: cross hext__pagesize__cp_iside_gstagelevel3_paginglevel, hext__ptw__ipte_gstage_lvl3_leaf_ppn_1g_align, hext__traps__cp_excp_def {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_instr);
        bins non_aligned    = binsof(hext__pagesize__cp_iside_gstagelevel3_paginglevel) intersect {FPAGESIZE_GSTAGELEVEL3_1G} &&
                             binsof(hext__ptw__ipte_gstage_lvl3_leaf_ppn_1g_align.non_aligned);
    }

    hext__guestpagefault__cr_i_gstage_lvl4_pte_1g_align: cross hext__pagesize__cp_iside_gstagelevel4_paginglevel, hext__ptw__ipte_gstage_lvl4_leaf_ppn_1g_align, hext__traps__cp_excp_def {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_instr);
        bins non_aligned    = binsof(hext__pagesize__cp_iside_gstagelevel4_paginglevel) intersect {FPAGESIZE_GSTAGELEVEL4_1G} &&
                             binsof(hext__ptw__ipte_gstage_lvl4_leaf_ppn_1g_align.non_aligned);
    }

    hext__guestpagefault__cr_d_gstage_lvl1_pte_512g_align: cross hext__pagesize__cp_dside_gstagelevel1_paginglevel, hext__ptw__dpte_gstage_lvl1_leaf_ppn_512g_align, hext__traps__cp_excp_def {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_load) && !binsof(hext__traps__cp_excp_def.guest_page_flt_store);
        bins non_aligned    = binsof(hext__pagesize__cp_dside_gstagelevel1_paginglevel) intersect {DPAGESIZE_GSTAGELEVEL1_512G} &&
                             binsof(hext__ptw__dpte_gstage_lvl1_leaf_ppn_512g_align.non_aligned);
    }

    hext__guestpagefault__cr_d_gstage_lvl2_pte_512g_align: cross hext__pagesize__cp_dside_gstagelevel2_paginglevel, hext__ptw__dpte_gstage_lvl2_leaf_ppn_512g_align, hext__traps__cp_excp_def {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_load) && !binsof(hext__traps__cp_excp_def.guest_page_flt_store);
        bins non_aligned    = binsof(hext__pagesize__cp_dside_gstagelevel2_paginglevel) intersect {DPAGESIZE_GSTAGELEVEL2_512G} &&
                             binsof(hext__ptw__dpte_gstage_lvl2_leaf_ppn_512g_align.non_aligned);
    }

    hext__guestpagefault__cr_d_gstage_lvl3_pte_512g_align: cross hext__pagesize__cp_dside_gstagelevel3_paginglevel, hext__ptw__dpte_gstage_lvl3_leaf_ppn_512g_align, hext__traps__cp_excp_def {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_load) && !binsof(hext__traps__cp_excp_def.guest_page_flt_store);
        bins non_aligned    = binsof(hext__pagesize__cp_dside_gstagelevel3_paginglevel) intersect {DPAGESIZE_GSTAGELEVEL3_512G} &&
                             binsof(hext__ptw__dpte_gstage_lvl3_leaf_ppn_512g_align.non_aligned);
    }

    hext__guestpagefault__cr_d_gstage_lvl4_pte_512g_align: cross hext__pagesize__cp_dside_gstagelevel4_paginglevel, hext__ptw__dpte_gstage_lvl4_leaf_ppn_512g_align, hext__traps__cp_excp_def {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_load) && !binsof(hext__traps__cp_excp_def.guest_page_flt_store);
        bins non_aligned    = binsof(hext__pagesize__cp_dside_gstagelevel4_paginglevel) intersect {DPAGESIZE_GSTAGELEVEL4_512G} &&
                             binsof(hext__ptw__dpte_gstage_lvl4_leaf_ppn_512g_align.non_aligned);
    }

    hext__guestpagefault__cr_i_gstage_lvl1_pte_512g_align: cross hext__pagesize__cp_iside_gstagelevel1_paginglevel, hext__ptw__ipte_gstage_lvl1_leaf_ppn_512g_align, hext__traps__cp_excp_def {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_instr);
        bins non_aligned    = binsof(hext__pagesize__cp_iside_gstagelevel1_paginglevel) intersect {FPAGESIZE_GSTAGELEVEL1_512G} &&
                             binsof(hext__ptw__ipte_gstage_lvl1_leaf_ppn_512g_align.non_aligned);
    }

    hext__guestpagefault__cr_i_gstage_lvl2_pte_512g_align: cross hext__pagesize__cp_iside_gstagelevel2_paginglevel, hext__ptw__ipte_gstage_lvl2_leaf_ppn_512g_align, hext__traps__cp_excp_def {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_instr);
        bins non_aligned    = binsof(hext__pagesize__cp_iside_gstagelevel2_paginglevel) intersect {FPAGESIZE_GSTAGELEVEL2_512G} &&
                             binsof(hext__ptw__ipte_gstage_lvl2_leaf_ppn_512g_align.non_aligned);
    }

    hext__guestpagefault__cr_i_gstage_lvl3_pte_512g_align: cross hext__pagesize__cp_iside_gstagelevel3_paginglevel, hext__ptw__ipte_gstage_lvl3_leaf_ppn_512g_align, hext__traps__cp_excp_def {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_instr);
        bins non_aligned    = binsof(hext__pagesize__cp_iside_gstagelevel3_paginglevel) intersect {FPAGESIZE_GSTAGELEVEL3_512G} &&
                             binsof(hext__ptw__ipte_gstage_lvl3_leaf_ppn_512g_align.non_aligned);
    }

    hext__guestpagefault__cr_i_gstage_lvl4_pte_512g_align: cross hext__pagesize__cp_iside_gstagelevel4_paginglevel, hext__ptw__ipte_gstage_lvl4_leaf_ppn_512g_align, hext__traps__cp_excp_def {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_instr);
        bins non_aligned    = binsof(hext__pagesize__cp_iside_gstagelevel4_paginglevel) intersect {FPAGESIZE_GSTAGELEVEL4_512G} &&
                             binsof(hext__ptw__ipte_gstage_lvl4_leaf_ppn_512g_align.non_aligned);
    }

    hext__guestpagefault__cr_d_gstage_lvl1_pte_256t_align: cross hext__pagesize__cp_dside_gstagelevel1_paginglevel, hext__ptw__dpte_gstage_lvl1_leaf_ppn_256t_align, hext__traps__cp_excp_def {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_load) && !binsof(hext__traps__cp_excp_def.guest_page_flt_store);
        bins non_aligned    = binsof(hext__pagesize__cp_dside_gstagelevel1_paginglevel) intersect {DPAGESIZE_GSTAGELEVEL1_256T} &&
                             binsof(hext__ptw__dpte_gstage_lvl1_leaf_ppn_256t_align.non_aligned);
    }

    hext__guestpagefault__cr_d_gstage_lvl2_pte_256t_align: cross hext__pagesize__cp_dside_gstagelevel2_paginglevel, hext__ptw__dpte_gstage_lvl2_leaf_ppn_256t_align, hext__traps__cp_excp_def {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_load) && !binsof(hext__traps__cp_excp_def.guest_page_flt_store);
        bins non_aligned    = binsof(hext__pagesize__cp_dside_gstagelevel2_paginglevel) intersect {DPAGESIZE_GSTAGELEVEL2_256T} &&
                             binsof(hext__ptw__dpte_gstage_lvl2_leaf_ppn_256t_align.non_aligned);
    }

    hext__guestpagefault__cr_d_gstage_lvl3_pte_256t_align: cross hext__pagesize__cp_dside_gstagelevel3_paginglevel, hext__ptw__dpte_gstage_lvl3_leaf_ppn_256t_align, hext__traps__cp_excp_def {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_load) && !binsof(hext__traps__cp_excp_def.guest_page_flt_store);
        bins non_aligned    = binsof(hext__pagesize__cp_dside_gstagelevel3_paginglevel) intersect {DPAGESIZE_GSTAGELEVEL3_256T} &&
                             binsof(hext__ptw__dpte_gstage_lvl3_leaf_ppn_256t_align.non_aligned);
    }

    hext__guestpagefault__cr_d_gstage_lvl4_pte_256t_align: cross hext__pagesize__cp_dside_gstagelevel4_paginglevel, hext__ptw__dpte_gstage_lvl4_leaf_ppn_256t_align, hext__traps__cp_excp_def {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_load) && !binsof(hext__traps__cp_excp_def.guest_page_flt_store);
        bins non_aligned    = binsof(hext__pagesize__cp_dside_gstagelevel4_paginglevel) intersect {DPAGESIZE_GSTAGELEVEL4_256T} &&
                             binsof(hext__ptw__dpte_gstage_lvl4_leaf_ppn_256t_align.non_aligned);
    }

    hext__guestpagefault__cr_i_gstage_lvl1_pte_256t_align: cross hext__pagesize__cp_iside_gstagelevel1_paginglevel, hext__ptw__ipte_gstage_lvl1_leaf_ppn_256t_align, hext__traps__cp_excp_def {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_instr);
        bins non_aligned    = binsof(hext__pagesize__cp_iside_gstagelevel1_paginglevel) intersect {FPAGESIZE_GSTAGELEVEL1_256T} &&
                             binsof(hext__ptw__ipte_gstage_lvl1_leaf_ppn_256t_align.non_aligned);
    }

    hext__guestpagefault__cr_i_gstage_lvl2_pte_256t_align: cross hext__pagesize__cp_iside_gstagelevel2_paginglevel, hext__ptw__ipte_gstage_lvl2_leaf_ppn_256t_align, hext__traps__cp_excp_def {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_instr);
        bins non_aligned    = binsof(hext__pagesize__cp_iside_gstagelevel2_paginglevel) intersect {FPAGESIZE_GSTAGELEVEL2_256T} &&
                             binsof(hext__ptw__ipte_gstage_lvl2_leaf_ppn_256t_align.non_aligned);
    }

    hext__guestpagefault__cr_i_gstage_lvl3_pte_256t_align: cross hext__pagesize__cp_iside_gstagelevel3_paginglevel, hext__ptw__ipte_gstage_lvl3_leaf_ppn_256t_align, hext__traps__cp_excp_def {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_instr);
        bins non_aligned    = binsof(hext__pagesize__cp_iside_gstagelevel3_paginglevel) intersect {FPAGESIZE_GSTAGELEVEL3_256T} &&
                             binsof(hext__ptw__ipte_gstage_lvl3_leaf_ppn_256t_align.non_aligned);
    }

    hext__guestpagefault__cr_i_gstage_lvl4_pte_256t_align: cross hext__pagesize__cp_iside_gstagelevel4_paginglevel, hext__ptw__ipte_gstage_lvl4_leaf_ppn_256t_align, hext__traps__cp_excp_def {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_instr);
        bins non_aligned    = binsof(hext__pagesize__cp_iside_gstagelevel4_paginglevel) intersect {FPAGESIZE_GSTAGELEVEL4_256T} &&
                             binsof(hext__ptw__ipte_gstage_lvl4_leaf_ppn_256t_align.non_aligned);
    }

    hext__guestpagefault__cr_d_gstage_lvl1_pte_2m_align_modes: cross hext__guestpagefault__cr_d_gstage_lvl1_pte_2m_align, hext__vsatp__cp_modes, hext__hgatp__cp_modes, hext__accesstype__cp_instr_2_lvl {
        ignore_bins illegal_vsatp_modes = !binsof(hext__vsatp__cp_modes.legal_vsatp_modes);
        ignore_bins illegal_hgatp_modes = !binsof(hext__hgatp__cp_modes.legal_hgatp_modes);
    }

    hext__guestpagefault__cr_d_gstage_lvl2_pte_2m_align_modes: cross hext__guestpagefault__cr_d_gstage_lvl2_pte_2m_align, hext__vsatp__cp_modes, hext__hgatp__cp_modes, hext__accesstype__cp_instr_2_lvl {
        ignore_bins illegal_vsatp_modes = !binsof(hext__vsatp__cp_modes.legal_vsatp_modes);
        ignore_bins illegal_hgatp_modes = !binsof(hext__hgatp__cp_modes.legal_hgatp_modes);
    }

    hext__guestpagefault__cr_d_gstage_lvl3_pte_2m_align_modes: cross hext__guestpagefault__cr_d_gstage_lvl3_pte_2m_align, hext__vsatp__cp_modes, hext__hgatp__cp_modes, hext__accesstype__cp_instr_2_lvl {
        ignore_bins illegal_vsatp_modes = !binsof(hext__vsatp__cp_modes.legal_vsatp_modes);
        ignore_bins illegal_hgatp_modes = !binsof(hext__hgatp__cp_modes.legal_hgatp_modes);
        ignore_bins vstage_sv39_gstage_lvl3 = binsof(hext__vsatp__cp_modes.legal_vsatp_modes) intersect {8};
    }

    hext__guestpagefault__cr_d_gstage_lvl4_pte_2m_align_modes: cross hext__guestpagefault__cr_d_gstage_lvl4_pte_2m_align, hext__vsatp__cp_modes, hext__hgatp__cp_modes, hext__accesstype__cp_instr_2_lvl {
        ignore_bins illegal_vsatp_modes = !binsof(hext__vsatp__cp_modes.legal_vsatp_modes);
        ignore_bins illegal_hgatp_modes = !binsof(hext__hgatp__cp_modes.legal_hgatp_modes);
        ignore_bins vstage_sv39_gstage_lvl4 = binsof(hext__vsatp__cp_modes.legal_vsatp_modes) intersect {8};
        ignore_bins vstage_sv48_gstage_lvl4 = binsof(hext__vsatp__cp_modes.legal_vsatp_modes) intersect {9};
    }

    hext__guestpagefault__cr_i_gstage_lvl1_pte_2m_align_modes: cross hext__guestpagefault__cr_i_gstage_lvl1_pte_2m_align, hext__vsatp__cp_modes, hext__hgatp__cp_modes {
        ignore_bins illegal_vsatp_modes = !binsof(hext__vsatp__cp_modes.legal_vsatp_modes);
        ignore_bins illegal_hgatp_modes = !binsof(hext__hgatp__cp_modes.legal_hgatp_modes);
    }

    hext__guestpagefault__cr_i_gstage_lvl2_pte_2m_align_modes: cross hext__guestpagefault__cr_i_gstage_lvl2_pte_2m_align, hext__vsatp__cp_modes, hext__hgatp__cp_modes {
        ignore_bins illegal_vsatp_modes = !binsof(hext__vsatp__cp_modes.legal_vsatp_modes);
        ignore_bins illegal_hgatp_modes = !binsof(hext__hgatp__cp_modes.legal_hgatp_modes);
    }

    hext__guestpagefault__cr_i_gstage_lvl3_pte_2m_align_modes: cross hext__guestpagefault__cr_i_gstage_lvl3_pte_2m_align, hext__vsatp__cp_modes, hext__hgatp__cp_modes {
        ignore_bins illegal_vsatp_modes = !binsof(hext__vsatp__cp_modes.legal_vsatp_modes);
        ignore_bins illegal_hgatp_modes = !binsof(hext__hgatp__cp_modes.legal_hgatp_modes);
        ignore_bins vstage_sv39_gstage_lvl3 = binsof(hext__vsatp__cp_modes.legal_vsatp_modes) intersect {8};
    }

    hext__guestpagefault__cr_i_gstage_lvl4_pte_2m_align_modes: cross hext__guestpagefault__cr_i_gstage_lvl4_pte_2m_align, hext__vsatp__cp_modes, hext__hgatp__cp_modes {
        ignore_bins illegal_vsatp_modes = !binsof(hext__vsatp__cp_modes.legal_vsatp_modes);
        ignore_bins illegal_hgatp_modes = !binsof(hext__hgatp__cp_modes.legal_hgatp_modes);
        ignore_bins vstage_sv39_gstage_lvl4 = binsof(hext__vsatp__cp_modes.legal_vsatp_modes) intersect {8};
        ignore_bins vstage_sv48_gstage_lvl4 = binsof(hext__vsatp__cp_modes.legal_vsatp_modes) intersect {9};
    }

    hext__guestpagefault__cr_d_gstage_lvl1_pte_1g_align_modes: cross hext__guestpagefault__cr_d_gstage_lvl1_pte_1g_align, hext__vsatp__cp_modes, hext__hgatp__cp_modes, hext__accesstype__cp_instr_2_lvl {
        ignore_bins illegal_vsatp_modes = !binsof(hext__vsatp__cp_modes.legal_vsatp_modes);
        ignore_bins illegal_hgatp_modes = !binsof(hext__hgatp__cp_modes.legal_hgatp_modes);
    }

    hext__guestpagefault__cr_d_gstage_lvl2_pte_1g_align_modes: cross hext__guestpagefault__cr_d_gstage_lvl2_pte_1g_align, hext__vsatp__cp_modes, hext__hgatp__cp_modes, hext__accesstype__cp_instr_2_lvl {
        ignore_bins illegal_vsatp_modes = !binsof(hext__vsatp__cp_modes.legal_vsatp_modes);
        ignore_bins illegal_hgatp_modes = !binsof(hext__hgatp__cp_modes.legal_hgatp_modes);
    }

    hext__guestpagefault__cr_d_gstage_lvl3_pte_1g_align_modes: cross hext__guestpagefault__cr_d_gstage_lvl3_pte_1g_align, hext__vsatp__cp_modes, hext__hgatp__cp_modes, hext__accesstype__cp_instr_2_lvl {
        ignore_bins illegal_vsatp_modes = !binsof(hext__vsatp__cp_modes.legal_vsatp_modes);
        ignore_bins illegal_hgatp_modes = !binsof(hext__hgatp__cp_modes.legal_hgatp_modes);
        ignore_bins vstage_sv39_gstage_lvl3 = binsof(hext__vsatp__cp_modes.legal_vsatp_modes) intersect {8};
    }

    hext__guestpagefault__cr_d_gstage_lvl4_pte_1g_align_modes: cross hext__guestpagefault__cr_d_gstage_lvl4_pte_1g_align, hext__vsatp__cp_modes, hext__hgatp__cp_modes, hext__accesstype__cp_instr_2_lvl {
        ignore_bins illegal_vsatp_modes = !binsof(hext__vsatp__cp_modes.legal_vsatp_modes);
        ignore_bins illegal_hgatp_modes = !binsof(hext__hgatp__cp_modes.legal_hgatp_modes);
        ignore_bins vstage_sv39_gstage_lvl4 = binsof(hext__vsatp__cp_modes.legal_vsatp_modes) intersect {8};
        ignore_bins vstage_sv48_gstage_lvl4 = binsof(hext__vsatp__cp_modes.legal_vsatp_modes) intersect {9};
    }

    hext__guestpagefault__cr_i_gstage_lvl1_pte_1g_align_modes: cross hext__guestpagefault__cr_i_gstage_lvl1_pte_1g_align, hext__vsatp__cp_modes, hext__hgatp__cp_modes {
        ignore_bins illegal_vsatp_modes = !binsof(hext__vsatp__cp_modes.legal_vsatp_modes);
        ignore_bins illegal_hgatp_modes = !binsof(hext__hgatp__cp_modes.legal_hgatp_modes);
    }

    hext__guestpagefault__cr_i_gstage_lvl2_pte_1g_align_modes: cross hext__guestpagefault__cr_i_gstage_lvl2_pte_1g_align, hext__vsatp__cp_modes, hext__hgatp__cp_modes {
        ignore_bins illegal_vsatp_modes = !binsof(hext__vsatp__cp_modes.legal_vsatp_modes);
        ignore_bins illegal_hgatp_modes = !binsof(hext__hgatp__cp_modes.legal_hgatp_modes);
    }

    hext__guestpagefault__cr_i_gstage_lvl3_pte_1g_align_modes: cross hext__guestpagefault__cr_i_gstage_lvl3_pte_1g_align, hext__vsatp__cp_modes, hext__hgatp__cp_modes {
        ignore_bins illegal_vsatp_modes = !binsof(hext__vsatp__cp_modes.legal_vsatp_modes);
        ignore_bins illegal_hgatp_modes = !binsof(hext__hgatp__cp_modes.legal_hgatp_modes);
        ignore_bins vstage_sv39_gstage_lvl3 = binsof(hext__vsatp__cp_modes.legal_vsatp_modes) intersect {8};
    }

    hext__guestpagefault__cr_i_gstage_lvl4_pte_1g_align_modes: cross hext__guestpagefault__cr_i_gstage_lvl4_pte_1g_align, hext__vsatp__cp_modes, hext__hgatp__cp_modes {
        ignore_bins illegal_vsatp_modes = !binsof(hext__vsatp__cp_modes.legal_vsatp_modes);
        ignore_bins illegal_hgatp_modes = !binsof(hext__hgatp__cp_modes.legal_hgatp_modes);
        ignore_bins vstage_sv39_gstage_lvl4 = binsof(hext__vsatp__cp_modes.legal_vsatp_modes) intersect {8};
        ignore_bins vstage_sv48_gstage_lvl4 = binsof(hext__vsatp__cp_modes.legal_vsatp_modes) intersect {9};
    }

    hext__guestpagefault__cr_d_gstage_lvl1_pte_512g_align_modes: cross hext__guestpagefault__cr_d_gstage_lvl1_pte_512g_align, hext__vsatp__cp_modes, hext__hgatp__cp_modes, hext__accesstype__cp_instr_2_lvl {
        ignore_bins illegal_vsatp_modes = !binsof(hext__vsatp__cp_modes.legal_vsatp_modes);
        ignore_bins illegal_hgatp_modes = !binsof(hext__hgatp__cp_modes.legal_hgatp_modes);
        ignore_bins gstage_sv39_512g_pagesize = binsof(hext__hgatp__cp_modes.legal_hgatp_modes) intersect {8};
    }

    hext__guestpagefault__cr_d_gstage_lvl2_pte_512g_align_modes: cross hext__guestpagefault__cr_d_gstage_lvl2_pte_512g_align, hext__vsatp__cp_modes, hext__hgatp__cp_modes, hext__accesstype__cp_instr_2_lvl {
        ignore_bins illegal_vsatp_modes = !binsof(hext__vsatp__cp_modes.legal_vsatp_modes);
        ignore_bins illegal_hgatp_modes = !binsof(hext__hgatp__cp_modes.legal_hgatp_modes);
        ignore_bins gstage_sv39_512g_pagesize = binsof(hext__hgatp__cp_modes.legal_hgatp_modes) intersect {8};
    }

    hext__guestpagefault__cr_d_gstage_lvl3_pte_512g_align_modes: cross hext__guestpagefault__cr_d_gstage_lvl3_pte_512g_align, hext__vsatp__cp_modes, hext__hgatp__cp_modes, hext__accesstype__cp_instr_2_lvl {
        ignore_bins illegal_vsatp_modes = !binsof(hext__vsatp__cp_modes.legal_vsatp_modes);
        ignore_bins illegal_hgatp_modes = !binsof(hext__hgatp__cp_modes.legal_hgatp_modes);
        ignore_bins vstage_sv39_gstage_lvl3 = binsof(hext__vsatp__cp_modes.legal_vsatp_modes) intersect {8};
        ignore_bins gstage_sv39_512g_pagesize = binsof(hext__hgatp__cp_modes.legal_hgatp_modes) intersect {8};
    }

    hext__guestpagefault__cr_d_gstage_lvl4_pte_512g_align_modes: cross hext__guestpagefault__cr_d_gstage_lvl4_pte_512g_align, hext__vsatp__cp_modes, hext__hgatp__cp_modes, hext__accesstype__cp_instr_2_lvl {
        ignore_bins illegal_vsatp_modes = !binsof(hext__vsatp__cp_modes.legal_vsatp_modes);
        ignore_bins illegal_hgatp_modes = !binsof(hext__hgatp__cp_modes.legal_hgatp_modes);
        ignore_bins vstage_sv39_gstage_lvl4 = binsof(hext__vsatp__cp_modes.legal_vsatp_modes) intersect {8};
        ignore_bins vstage_sv48_gstage_lvl4 = binsof(hext__vsatp__cp_modes.legal_vsatp_modes) intersect {9};
        ignore_bins gstage_sv39_512g_pagesize = binsof(hext__hgatp__cp_modes.legal_hgatp_modes) intersect {8};
    }

    hext__guestpagefault__cr_i_gstage_lvl1_pte_512g_align_modes: cross hext__guestpagefault__cr_i_gstage_lvl1_pte_512g_align, hext__vsatp__cp_modes, hext__hgatp__cp_modes {
        ignore_bins illegal_vsatp_modes = !binsof(hext__vsatp__cp_modes.legal_vsatp_modes);
        ignore_bins illegal_hgatp_modes = !binsof(hext__hgatp__cp_modes.legal_hgatp_modes);
        ignore_bins gstage_sv39_512g_pagesize = binsof(hext__hgatp__cp_modes.legal_hgatp_modes) intersect {8};
    }

    hext__guestpagefault__cr_i_gstage_lvl2_pte_512g_align_modes: cross hext__guestpagefault__cr_i_gstage_lvl2_pte_512g_align, hext__vsatp__cp_modes, hext__hgatp__cp_modes {
        ignore_bins illegal_vsatp_modes = !binsof(hext__vsatp__cp_modes.legal_vsatp_modes);
        ignore_bins illegal_hgatp_modes = !binsof(hext__hgatp__cp_modes.legal_hgatp_modes);
        ignore_bins gstage_sv39_512g_pagesize = binsof(hext__hgatp__cp_modes.legal_hgatp_modes) intersect {8};
    }

    hext__guestpagefault__cr_i_gstage_lvl3_pte_512g_align_modes: cross hext__guestpagefault__cr_i_gstage_lvl3_pte_512g_align, hext__vsatp__cp_modes, hext__hgatp__cp_modes {
        ignore_bins illegal_vsatp_modes = !binsof(hext__vsatp__cp_modes.legal_vsatp_modes);
        ignore_bins illegal_hgatp_modes = !binsof(hext__hgatp__cp_modes.legal_hgatp_modes);
        ignore_bins vstage_sv39_gstage_lvl3 = binsof(hext__vsatp__cp_modes.legal_vsatp_modes) intersect {8};
        ignore_bins gstage_sv39_512g_pagesize = binsof(hext__hgatp__cp_modes.legal_hgatp_modes) intersect {8};
    }

    hext__guestpagefault__cr_i_gstage_lvl4_pte_512g_align_modes: cross hext__guestpagefault__cr_i_gstage_lvl4_pte_512g_align, hext__vsatp__cp_modes, hext__hgatp__cp_modes {
        ignore_bins illegal_vsatp_modes = !binsof(hext__vsatp__cp_modes.legal_vsatp_modes);
        ignore_bins illegal_hgatp_modes = !binsof(hext__hgatp__cp_modes.legal_hgatp_modes);
        ignore_bins vstage_sv39_gstage_lvl4 = binsof(hext__vsatp__cp_modes.legal_vsatp_modes) intersect {8};
        ignore_bins vstage_sv48_gstage_lvl4 = binsof(hext__vsatp__cp_modes.legal_vsatp_modes) intersect {9};
        ignore_bins gstage_sv39_512g_pagesize = binsof(hext__hgatp__cp_modes.legal_hgatp_modes) intersect {8};
    }

    hext__guestpagefault__cr_d_gstage_lvl1_pte_256t_align_modes: cross hext__guestpagefault__cr_d_gstage_lvl1_pte_256t_align, hext__vsatp__cp_modes, hext__hgatp__cp_modes, hext__accesstype__cp_instr_2_lvl {
        ignore_bins illegal_vsatp_modes = !binsof(hext__vsatp__cp_modes.legal_vsatp_modes);
        ignore_bins illegal_hgatp_modes = !binsof(hext__hgatp__cp_modes.legal_hgatp_modes);
        ignore_bins gstage_sv39_256t_pagesize = binsof(hext__hgatp__cp_modes.legal_hgatp_modes) intersect {8};
        ignore_bins gstage_sv48_256t_pagesize = binsof(hext__hgatp__cp_modes.legal_hgatp_modes) intersect {9};
    }

    hext__guestpagefault__cr_d_gstage_lvl2_pte_256t_align_modes: cross hext__guestpagefault__cr_d_gstage_lvl2_pte_256t_align, hext__vsatp__cp_modes, hext__hgatp__cp_modes, hext__accesstype__cp_instr_2_lvl {
        ignore_bins illegal_vsatp_modes = !binsof(hext__vsatp__cp_modes.legal_vsatp_modes);
        ignore_bins illegal_hgatp_modes = !binsof(hext__hgatp__cp_modes.legal_hgatp_modes);
        ignore_bins gstage_sv39_256t_pagesize = binsof(hext__hgatp__cp_modes.legal_hgatp_modes) intersect {8};
        ignore_bins gstage_sv48_256t_pagesize = binsof(hext__hgatp__cp_modes.legal_hgatp_modes) intersect {9};
    }

    hext__guestpagefault__cr_d_gstage_lvl3_pte_256t_align_modes: cross hext__guestpagefault__cr_d_gstage_lvl3_pte_256t_align, hext__vsatp__cp_modes, hext__hgatp__cp_modes, hext__accesstype__cp_instr_2_lvl {
        ignore_bins illegal_vsatp_modes = !binsof(hext__vsatp__cp_modes.legal_vsatp_modes);
        ignore_bins illegal_hgatp_modes = !binsof(hext__hgatp__cp_modes.legal_hgatp_modes);
        ignore_bins vstage_sv39_gstage_lvl3 = binsof(hext__vsatp__cp_modes.legal_vsatp_modes) intersect {8};
        ignore_bins gstage_sv39_256t_pagesize = binsof(hext__hgatp__cp_modes.legal_hgatp_modes) intersect {8};
        ignore_bins gstage_sv48_256t_pagesize = binsof(hext__hgatp__cp_modes.legal_hgatp_modes) intersect {9};
    }

    hext__guestpagefault__cr_d_gstage_lvl4_pte_256t_align_modes: cross hext__guestpagefault__cr_d_gstage_lvl4_pte_256t_align, hext__vsatp__cp_modes, hext__hgatp__cp_modes, hext__accesstype__cp_instr_2_lvl {
        ignore_bins illegal_vsatp_modes = !binsof(hext__vsatp__cp_modes.legal_vsatp_modes);
        ignore_bins illegal_hgatp_modes = !binsof(hext__hgatp__cp_modes.legal_hgatp_modes);
        ignore_bins vstage_sv39_gstage_lvl4 = binsof(hext__vsatp__cp_modes.legal_vsatp_modes) intersect {8};
        ignore_bins vstage_sv48_gstage_lvl4 = binsof(hext__vsatp__cp_modes.legal_vsatp_modes) intersect {9};
        ignore_bins gstage_sv39_256t_pagesize = binsof(hext__hgatp__cp_modes.legal_hgatp_modes) intersect {8};
        ignore_bins gstage_sv48_256t_pagesize = binsof(hext__hgatp__cp_modes.legal_hgatp_modes) intersect {9};
    }

    hext__guestpagefault__cr_i_gstage_lvl1_pte_256t_align_modes: cross hext__guestpagefault__cr_i_gstage_lvl1_pte_256t_align, hext__vsatp__cp_modes, hext__hgatp__cp_modes {
        ignore_bins illegal_vsatp_modes = !binsof(hext__vsatp__cp_modes.legal_vsatp_modes);
        ignore_bins illegal_hgatp_modes = !binsof(hext__hgatp__cp_modes.legal_hgatp_modes);
        ignore_bins gstage_sv39_256t_pagesize = binsof(hext__hgatp__cp_modes.legal_hgatp_modes) intersect {8};
        ignore_bins gstage_sv48_256t_pagesize = binsof(hext__hgatp__cp_modes.legal_hgatp_modes) intersect {9};
    }

    hext__guestpagefault__cr_i_gstage_lvl2_pte_256t_align_modes: cross hext__guestpagefault__cr_i_gstage_lvl2_pte_256t_align, hext__vsatp__cp_modes, hext__hgatp__cp_modes {
        ignore_bins illegal_vsatp_modes = !binsof(hext__vsatp__cp_modes.legal_vsatp_modes);
        ignore_bins illegal_hgatp_modes = !binsof(hext__hgatp__cp_modes.legal_hgatp_modes);
        ignore_bins gstage_sv39_256t_pagesize = binsof(hext__hgatp__cp_modes.legal_hgatp_modes) intersect {8};
        ignore_bins gstage_sv48_256t_pagesize = binsof(hext__hgatp__cp_modes.legal_hgatp_modes) intersect {9};
    }

    hext__guestpagefault__cr_i_gstage_lvl3_pte_256t_align_modes: cross hext__guestpagefault__cr_i_gstage_lvl3_pte_256t_align, hext__vsatp__cp_modes, hext__hgatp__cp_modes {
        ignore_bins illegal_vsatp_modes = !binsof(hext__vsatp__cp_modes.legal_vsatp_modes);
        ignore_bins illegal_hgatp_modes = !binsof(hext__hgatp__cp_modes.legal_hgatp_modes);
        ignore_bins vstage_sv39_gstage_lvl3 = binsof(hext__vsatp__cp_modes.legal_vsatp_modes) intersect {8};
        ignore_bins gstage_sv39_256t_pagesize = binsof(hext__hgatp__cp_modes.legal_hgatp_modes) intersect {8};
        ignore_bins gstage_sv48_256t_pagesize = binsof(hext__hgatp__cp_modes.legal_hgatp_modes) intersect {9};
    }

    hext__guestpagefault__cr_i_gstage_lvl4_pte_256t_align_modes: cross hext__guestpagefault__cr_i_gstage_lvl4_pte_256t_align, hext__vsatp__cp_modes, hext__hgatp__cp_modes {
        ignore_bins illegal_vsatp_modes = !binsof(hext__vsatp__cp_modes.legal_vsatp_modes);
        ignore_bins illegal_hgatp_modes = !binsof(hext__hgatp__cp_modes.legal_hgatp_modes);
        ignore_bins vstage_sv39_gstage_lvl4 = binsof(hext__vsatp__cp_modes.legal_vsatp_modes) intersect {8};
        ignore_bins vstage_sv48_gstage_lvl4 = binsof(hext__vsatp__cp_modes.legal_vsatp_modes) intersect {9};
        ignore_bins gstage_sv39_256t_pagesize = binsof(hext__hgatp__cp_modes.legal_hgatp_modes) intersect {8};
        ignore_bins gstage_sv48_256t_pagesize = binsof(hext__hgatp__cp_modes.legal_hgatp_modes) intersect {9};
    }

    hext__guestpagefault__cr_instrn_gpa_upperbits_nonzero: cross hext__hgatp__cp_modes, hext__deleg__cp_medeleg_instr_guest_page_fault {
        option.cross_auto_bin_max   = 0;
        bins dside_sv39x4_gpa55to41_nonzero  = binsof(hext__hgatp__cp_modes) intersect {8} iff ((FVPTE_Level3[53:39] != 15'b000_0000_0000_0000) || 
                                                                                                (FVPTE_Level2[53:39] != 15'b000_0000_0000_0000) ||
                                                                                                (FVPTE_Level1[53:39] != 15'b000_0000_0000_0000));

        bins dside_sv48x4_gpa55to50_nonzero  = binsof(hext__hgatp__cp_modes) intersect {9} iff ((FVPTE_Level4[53:48] != 6'b00_0000) || 
                                                                                                (FVPTE_Level3[53:48] != 6'b00_0000) ||
                                                                                                (FVPTE_Level2[53:48] != 6'b00_0000) ||
                                                                                                (FVPTE_Level1[53:48] != 6'b00_0000));
    }   
    hext__guestpagefault__cr_load_gpa_upperbits_nonzero: cross hext__hgatp__cp_modes, hext__deleg__cp_medeleg_load_guest_page_fault {
        option.cross_auto_bin_max   = 0;
        bins dside_sv39x4_gpa55to41_nonzero  = binsof(hext__hgatp__cp_modes) intersect {8} iff ((DVPTE_Level3[53:39] != 15'b000_0000_0000_0000) || 
                                                                                                (DVPTE_Level2[53:39] != 15'b000_0000_0000_0000) ||
                                                                                                (DVPTE_Level1[53:39] != 15'b000_0000_0000_0000));

        bins dside_sv48x4_gpa55to50_nonzero  = binsof(hext__hgatp__cp_modes) intersect {9} iff ((DVPTE_Level4[53:48] != 6'b00_0000) || 
                                                                                                (DVPTE_Level3[53:48] != 6'b00_0000) ||
                                                                                                (DVPTE_Level2[53:48] != 6'b00_0000) ||
                                                                                                (DVPTE_Level1[53:48] != 6'b00_0000));
    }
    hext__guestpagefault__cr_storeAMO_gpa_upperbits_nonzero: cross hext__hgatp__cp_modes, hext__deleg__cp_medeleg_storeAMO_guest_page_fault {
        option.cross_auto_bin_max   = 0;
        bins dside_sv39x4_gpa55to41_nonzero  = binsof(hext__hgatp__cp_modes) intersect {8} iff ((DVPTE_Level3[53:39] != 15'b000_0000_0000_0000) || 
                                                                                                (DVPTE_Level2[53:39] != 15'b000_0000_0000_0000) ||
                                                                                                (DVPTE_Level1[53:39] != 15'b000_0000_0000_0000));

        bins dside_sv48x4_gpa55to50_nonzero  = binsof(hext__hgatp__cp_modes) intersect {9} iff ((DVPTE_Level4[53:48] != 6'b00_0000) || 
                                                                                                (DVPTE_Level3[53:48] != 6'b00_0000) ||
                                                                                                (DVPTE_Level2[53:48] != 6'b00_0000) ||
                                                                                                (DVPTE_Level1[53:48] != 6'b00_0000));
    }

    hext__guestpagefault__cr_iside_zeroextbits_sv39: cross hext__ptw__cp_iside_guest_phy_bitsel_zeroextbits_sv39, hext__traps__cp_excp_def {
        option.cross_auto_bin_max   = 1;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_instr);
    }

    hext__guestpagefault__cr_iside_zeroextbits_sv48: cross hext__ptw__cp_iside_guest_phy_bitsel_zeroextbits_sv48, hext__traps__cp_excp_def {
        option.cross_auto_bin_max   = 1;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_instr);
    }

    hext__guestpagefault__cr_iside_zeroextbits_sv57: cross hext__ptw__cp_iside_guest_phy_bitsel_zeroextbits_sv57, hext__traps__cp_excp_def {
        option.cross_auto_bin_max   = 1;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_instr);
    }

    hext__accessfault__cr_iside_zeroextbits_baremode: cross hext__ptw__cp_iside_guest_phy_bitsel_zeroextbits_baremode, hext__traps__cp_excp_def {
        option.cross_auto_bin_max   = 1;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.acc_flt_instr);
    }

    hext__guestpagefault__cr_dside_zeroextbits_sv39: cross hext__ptw__cp_dside_guest_phy_bitsel_zeroextbits_sv39, hext__traps__cp_excp_def {
        option.cross_auto_bin_max   = 0;
        bins dside_sv39_zeroext_guestpagefault = binsof(hext__traps__cp_excp_def.guest_page_flt_load) || binsof(hext__traps__cp_excp_def.guest_page_flt_store);
    }

    hext__guestpagefault__cr_dside_zeroextbits_sv48: cross hext__ptw__cp_dside_guest_phy_bitsel_zeroextbits_sv48, hext__traps__cp_excp_def {
        option.cross_auto_bin_max   = 0;
        bins dside_sv48_zeroext_guestpagefault = binsof(hext__traps__cp_excp_def.guest_page_flt_load) || binsof(hext__traps__cp_excp_def.guest_page_flt_store);
    }

    hext__guestpagefault__cr_dside_zeroextbits_sv57: cross hext__ptw__cp_dside_guest_phy_bitsel_zeroextbits_sv57, hext__traps__cp_excp_def {
        option.cross_auto_bin_max   = 0;
        bins dside_sv57_zeroext_guestpagefault = binsof(hext__traps__cp_excp_def.guest_page_flt_load) || binsof(hext__traps__cp_excp_def.guest_page_flt_store);
    }

    hext__accessfault__cr_dside_zeroextbits_baremode: cross hext__ptw__cp_dside_guest_phy_bitsel_zeroextbits_baremode, hext__traps__cp_excp_def {
        option.cross_auto_bin_max   = 0;
        bins dside_bare_zeroext_accessfault = binsof(hext__traps__cp_excp_def.acc_flt_load) || binsof(hext__traps__cp_excp_def.acc_flt_store);
    }

    hext__traps__cr_instruction_pagefault_basic: cross hext__ptw__cp_iside_leaf_ptw_valid, hext__ptw__cp_iside_leaf_ptw_access, hext__ptw__cp_iside_leaf_ptw_exec, hext__traps__cp_excp_def iff (VirtualMode == 1) {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.page_flt_instr);
        bins i_leaf_pagefault_without_access            = binsof(hext__ptw__cp_iside_leaf_ptw_valid) intersect {1} &&
                                                          binsof(hext__ptw__cp_iside_leaf_ptw_access) intersect {0};
        bins i_leaf_pagefault_without_execute           = binsof(hext__ptw__cp_iside_leaf_ptw_valid) intersect {1} &&
                                                        binsof(hext__ptw__cp_iside_leaf_ptw_exec) intersect {0};
    }

    hext__traps__cr_instruction_pagefault_priv: cross hext__ptw__cp_iside_leaf_ptw_valid, hext__ptw__cp_iside_leaf_ptw_exec, 
                                                       hext__ptw__cp_iside_leaf_ptw_user, hext__gen__cp_curpriv, hext__traps__cp_excp_def iff (VirtualMode == 1) {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.page_flt_instr);
        bins i_virtualsupervisoraccess_with_pte_u_one   = binsof(hext__ptw__cp_iside_leaf_ptw_valid) intersect {1} &&
                                                        binsof(hext__ptw__cp_iside_leaf_ptw_exec) intersect {1} &&
                                                        binsof(hext__ptw__cp_iside_leaf_ptw_user) intersect {1} &&
                                                        binsof(hext__gen__cp_curpriv.vsmode);
        bins i_virtualuseraccess_with_pte_u_zero        = binsof(hext__ptw__cp_iside_leaf_ptw_valid) intersect {1} &&
                                                        binsof(hext__ptw__cp_iside_leaf_ptw_exec) intersect {1} &&
                                                        binsof(hext__ptw__cp_iside_leaf_ptw_user) intersect {0} &&
                                                        binsof(hext__gen__cp_curpriv.vumode);
    }

    hext__traps__cr_instruction_pagefault_leaf_res: cross hext__ptw__cp_iside_leaf_ptw_valid, hext__ptw__cp_iside_leaf_res, hext__traps__cp_excp_def iff (VirtualMode == 1) {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.page_flt_instr);
        bins i_pagefault_due_to_leaf_res_60_54          = binsof(hext__ptw__cp_iside_leaf_ptw_valid) intersect {1} &&
                                                        binsof(hext__ptw__cp_iside_leaf_res.res_i_leaf_nonzero);
    }

    hext__traps__cr_instruction_pagefault_nonleaf_res: cross hext__ptw__cp_iside_nonleaf_ptw_valid, hext__ptw__cp_iside_nonleaf_res, hext__traps__cp_excp_def iff (VirtualMode == 1) {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.page_flt_instr);
        bins i_pagefault_due_to_nonleaf_res_60_54       = binsof(hext__ptw__cp_iside_nonleaf_ptw_valid) intersect {1} &&
                                                        binsof(hext__ptw__cp_iside_nonleaf_res.res_i_nonleaf_nonzero);
    }

    hext__traps__cr_instruction_pagefault_leaf_pbmt: cross hext__ptw__cp_iside_leaf_ptw_valid, hext__ptw__cp_iside_leaf_pbmt, hext__traps__cp_excp_def iff (VirtualMode == 1) {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.page_flt_instr);
        bins i_pagefault_due_to_leaf_pbmt               = binsof(hext__ptw__cp_iside_leaf_ptw_valid) intersect {1} && 
                                                        binsof(hext__ptw__cp_iside_leaf_pbmt.pbmt_i_leaf_reserved);
    }

    hext__traps__cr_instruction_pagefault_nonleaf_pbmt: cross hext__ptw__cp_iside_nonleaf_ptw_valid, hext__ptw__cp_iside_nonleaf_pbmt, hext__traps__cp_excp_def iff (VirtualMode == 1) {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.page_flt_instr);
        bins i_pagefault_due_to_nonleaf_pbmt            = binsof(hext__ptw__cp_iside_nonleaf_ptw_valid) intersect {1} && 
                                                        binsof(hext__ptw__cp_iside_nonleaf_pbmt.pbmt_i_nonleaf_reserved);
    }

    hext__traps__cr_instruction_guestpagefault_lvl1_access: cross hext__ptw__cp_iside_gstage_lvl1_leaf_ptw_valid, hext__ptw__cp_iside_gstage_lvl1_leaf_ptw_access, hext__traps__cp_excp_def {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_instr);
        bins i_leaf_guestpagefault_without_access       = binsof(hext__ptw__cp_iside_gstage_lvl1_leaf_ptw_valid) intersect {1} &&
                                                        binsof(hext__ptw__cp_iside_gstage_lvl1_leaf_ptw_access) intersect {0};
    }

    hext__traps__cr_instruction_guestpagefault_lvl1_user: cross hext__ptw__cp_iside_gstage_lvl1_leaf_ptw_valid, hext__ptw__cp_iside_gstage_lvl1_leaf_ptw_exec, 
                                                              hext__ptw__cp_iside_gstage_lvl1_leaf_ptw_user, hext__gen__cp_curpriv, hext__traps__cp_excp_def {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_instr);
        bins i_virtualsupervisoraccess_with_pte_u_zero  = binsof(hext__ptw__cp_iside_gstage_lvl1_leaf_ptw_valid) intersect {1} &&
                                                        binsof(hext__ptw__cp_iside_gstage_lvl1_leaf_ptw_exec) intersect {1} &&
                                                        binsof(hext__ptw__cp_iside_gstage_lvl1_leaf_ptw_user) intersect {0} &&
                                                        binsof(hext__gen__cp_curpriv.vsmode);
        bins i_virtualuseraccess_with_pte_u_zero        = binsof(hext__ptw__cp_iside_gstage_lvl1_leaf_ptw_valid) intersect {1} &&
                                                        binsof(hext__ptw__cp_iside_gstage_lvl1_leaf_ptw_exec) intersect {1} &&
                                                        binsof(hext__ptw__cp_iside_gstage_lvl1_leaf_ptw_user) intersect {0} &&
                                                        binsof(hext__gen__cp_curpriv.vumode);
    }

    hext__traps__cr_instruction_guestpagefault_lvl1_leaf_pbmt: cross hext__ptw__cp_iside_gstage_lvl1_leaf_ptw_valid, hext__ptw__cp_iside_gstage_lvl1_leaf_pbmt, hext__traps__cp_excp_def {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_instr);
        bins i_guestpagefault_due_to_leaf_pbmt          = binsof(hext__ptw__cp_iside_gstage_lvl1_leaf_ptw_valid) intersect {1} && 
                                                        binsof(hext__ptw__cp_iside_gstage_lvl1_leaf_pbmt.pbmt_i_leaf_reserved);
    }

    hext__traps__cr_instruction_guestpagefault_lvl2_access: cross hext__ptw__cp_iside_gstage_lvl2_leaf_ptw_valid, hext__ptw__cp_iside_gstage_lvl2_leaf_ptw_access, hext__traps__cp_excp_def {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_instr);
        bins i_leaf_guestpagefault_without_access       = binsof(hext__ptw__cp_iside_gstage_lvl2_leaf_ptw_valid) intersect {1} &&
                                                        binsof(hext__ptw__cp_iside_gstage_lvl2_leaf_ptw_access) intersect {0};
    }

    hext__traps__cr_instruction_guestpagefault_lvl2_user: cross hext__ptw__cp_iside_gstage_lvl2_leaf_ptw_valid, hext__ptw__cp_iside_gstage_lvl2_leaf_ptw_exec, 
                                                              hext__ptw__cp_iside_gstage_lvl2_leaf_ptw_user, hext__gen__cp_curpriv, hext__traps__cp_excp_def {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_instr);
        bins i_virtualsupervisoraccess_with_pte_u_zero  = binsof(hext__ptw__cp_iside_gstage_lvl2_leaf_ptw_valid) intersect {1} &&
                                                        binsof(hext__ptw__cp_iside_gstage_lvl2_leaf_ptw_exec) intersect {1} &&
                                                        binsof(hext__ptw__cp_iside_gstage_lvl2_leaf_ptw_user) intersect {0} &&
                                                        binsof(hext__gen__cp_curpriv.vsmode);
        bins i_virtualuseraccess_with_pte_u_zero        = binsof(hext__ptw__cp_iside_gstage_lvl2_leaf_ptw_valid) intersect {1} &&
                                                        binsof(hext__ptw__cp_iside_gstage_lvl2_leaf_ptw_exec) intersect {1} &&
                                                        binsof(hext__ptw__cp_iside_gstage_lvl2_leaf_ptw_user) intersect {0} &&
                                                        binsof(hext__gen__cp_curpriv.vumode);
    }

    hext__traps__cr_instruction_guestpagefault_lvl2_leaf_pbmt: cross hext__ptw__cp_iside_gstage_lvl2_leaf_ptw_valid, hext__ptw__cp_iside_gstage_lvl2_leaf_pbmt, hext__traps__cp_excp_def {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_instr);
        bins i_guestpagefault_due_to_leaf_pbmt          = binsof(hext__ptw__cp_iside_gstage_lvl2_leaf_ptw_valid) intersect {1} && 
                                                        binsof(hext__ptw__cp_iside_gstage_lvl2_leaf_pbmt.pbmt_i_leaf_reserved);
    }

    hext__traps__cr_instruction_guestpagefault_lvl3_access: cross hext__ptw__cp_iside_gstage_lvl3_leaf_ptw_valid, hext__ptw__cp_iside_gstage_lvl3_leaf_ptw_access, hext__traps__cp_excp_def {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_instr);
        bins i_leaf_guestpagefault_without_access       = binsof(hext__ptw__cp_iside_gstage_lvl3_leaf_ptw_valid) intersect {1} &&
                                                        binsof(hext__ptw__cp_iside_gstage_lvl3_leaf_ptw_access) intersect {0};
    }

    hext__traps__cr_instruction_guestpagefault_lvl3_user: cross hext__ptw__cp_iside_gstage_lvl3_leaf_ptw_valid, hext__ptw__cp_iside_gstage_lvl3_leaf_ptw_exec, 
                                                              hext__ptw__cp_iside_gstage_lvl3_leaf_ptw_user, hext__gen__cp_curpriv, hext__traps__cp_excp_def {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_instr);
        bins i_virtualsupervisoraccess_with_pte_u_zero  = binsof(hext__ptw__cp_iside_gstage_lvl3_leaf_ptw_valid) intersect {1} &&
                                                        binsof(hext__ptw__cp_iside_gstage_lvl3_leaf_ptw_exec) intersect {1} &&
                                                        binsof(hext__ptw__cp_iside_gstage_lvl3_leaf_ptw_user) intersect {0} &&
                                                        binsof(hext__gen__cp_curpriv.vsmode);
        bins i_virtualuseraccess_with_pte_u_zero        = binsof(hext__ptw__cp_iside_gstage_lvl3_leaf_ptw_valid) intersect {1} &&
                                                        binsof(hext__ptw__cp_iside_gstage_lvl3_leaf_ptw_exec) intersect {1} &&
                                                        binsof(hext__ptw__cp_iside_gstage_lvl3_leaf_ptw_user) intersect {0} &&
                                                        binsof(hext__gen__cp_curpriv.vumode);
    }

    hext__traps__cr_instruction_guestpagefault_lvl3_leaf_pbmt: cross hext__ptw__cp_iside_gstage_lvl3_leaf_ptw_valid, hext__ptw__cp_iside_gstage_lvl3_leaf_pbmt, hext__traps__cp_excp_def
    {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_instr);
        bins i_guestpagefault_due_to_leaf_pbmt          = binsof(hext__ptw__cp_iside_gstage_lvl3_leaf_ptw_valid) intersect {1} && 
                                                        binsof(hext__ptw__cp_iside_gstage_lvl3_leaf_pbmt.pbmt_i_leaf_reserved);
    }

    hext__traps__cr_instruction_guestpagefault_lvl4_access: cross hext__ptw__cp_iside_gstage_lvl4_leaf_ptw_valid, hext__ptw__cp_iside_gstage_lvl4_leaf_ptw_access, hext__traps__cp_excp_def
    {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_instr);
        bins i_leaf_guestpagefault_without_access       = binsof(hext__ptw__cp_iside_gstage_lvl4_leaf_ptw_valid) intersect {1} &&
                                                        binsof(hext__ptw__cp_iside_gstage_lvl4_leaf_ptw_access) intersect {0};
    }

    hext__traps__cr_instruction_guestpagefault_lvl4_user: cross hext__ptw__cp_iside_gstage_lvl4_leaf_ptw_valid, hext__ptw__cp_iside_gstage_lvl4_leaf_ptw_exec, 
                                                              hext__ptw__cp_iside_gstage_lvl4_leaf_ptw_user, hext__gen__cp_curpriv, hext__traps__cp_excp_def
    {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_instr);
        // Guest-stage always treats privilege as U-mode, so U=0 pages cause faults in both VS and VU modes
        bins i_virtualsupervisoraccess_with_pte_u_zero  = binsof(hext__ptw__cp_iside_gstage_lvl4_leaf_ptw_valid) intersect {1} &&
                                                        binsof(hext__ptw__cp_iside_gstage_lvl4_leaf_ptw_exec) intersect {1} &&
                                                        binsof(hext__ptw__cp_iside_gstage_lvl4_leaf_ptw_user) intersect {0} &&
                                                        binsof(hext__gen__cp_curpriv.vsmode);
        bins i_virtualuseraccess_with_pte_u_zero        = binsof(hext__ptw__cp_iside_gstage_lvl4_leaf_ptw_valid) intersect {1} &&
                                                        binsof(hext__ptw__cp_iside_gstage_lvl4_leaf_ptw_exec) intersect {1} &&
                                                        binsof(hext__ptw__cp_iside_gstage_lvl4_leaf_ptw_user) intersect {0} &&
                                                        binsof(hext__gen__cp_curpriv.vumode);
    }

    hext__traps__cr_instruction_guestpagefault_lvl4_leaf_pbmt: cross hext__ptw__cp_iside_gstage_lvl4_leaf_ptw_valid, hext__ptw__cp_iside_gstage_lvl4_leaf_pbmt, hext__traps__cp_excp_def
    {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_instr);
        bins i_guestpagefault_due_to_leaf_pbmt          = binsof(hext__ptw__cp_iside_gstage_lvl4_leaf_ptw_valid) intersect {1} && 
                                                        binsof(hext__ptw__cp_iside_gstage_lvl4_leaf_pbmt.pbmt_i_leaf_reserved);
    }

    hext__traps__cr_instruction_guestpagefault_lvl5_access: cross hext__ptw__cp_iside_gstage_lvl5_leaf_ptw_valid, hext__ptw__cp_iside_gstage_lvl5_leaf_ptw_access, hext__traps__cp_excp_def
    {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_instr);
        bins i_leaf_guestpagefault_without_access       = binsof(hext__ptw__cp_iside_gstage_lvl5_leaf_ptw_valid) intersect {1} && 
                                                        binsof(hext__ptw__cp_iside_gstage_lvl5_leaf_ptw_access) intersect {0};
    }

    hext__traps__cr_instruction_guestpagefault_lvl5_user: cross hext__ptw__cp_iside_gstage_lvl5_leaf_ptw_valid, hext__ptw__cp_iside_gstage_lvl5_leaf_ptw_exec, 
                                                              hext__ptw__cp_iside_gstage_lvl5_leaf_ptw_user, hext__gen__cp_curpriv, hext__traps__cp_excp_def
    {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_instr);
        bins i_virtualsupervisoraccess_with_pte_u_zero  = binsof(hext__ptw__cp_iside_gstage_lvl5_leaf_ptw_valid) intersect {1} &&
                                                        binsof(hext__ptw__cp_iside_gstage_lvl5_leaf_ptw_exec) intersect {1} &&
                                                        binsof(hext__ptw__cp_iside_gstage_lvl5_leaf_ptw_user) intersect {0} &&
                                                        binsof(hext__gen__cp_curpriv.vsmode);
        bins i_virtualuseraccess_with_pte_u_zero        = binsof(hext__ptw__cp_iside_gstage_lvl5_leaf_ptw_valid) intersect {1} &&
                                                        binsof(hext__ptw__cp_iside_gstage_lvl5_leaf_ptw_exec) intersect {1} &&
                                                        binsof(hext__ptw__cp_iside_gstage_lvl5_leaf_ptw_user) intersect {0} &&
                                                        binsof(hext__gen__cp_curpriv.vumode);
    }

    hext__traps__cr_instruction_guestpagefault_lvl5_leaf_pbmt: cross hext__ptw__cp_iside_gstage_lvl5_leaf_ptw_valid, hext__ptw__cp_iside_gstage_lvl5_leaf_pbmt, hext__traps__cp_excp_def
    {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_instr);
        bins i_guestpagefault_due_to_leaf_pbmt          = binsof(hext__ptw__cp_iside_gstage_lvl5_leaf_ptw_valid) intersect {1} && 
                                                        binsof(hext__ptw__cp_iside_gstage_lvl5_leaf_pbmt.pbmt_i_leaf_reserved);
    }

    hext__traps__cr_data_pagefault_store: cross hext__ptw__cp_dside_leaf_ptw_valid, hext__accesstype__cp_instr_2_lvl, hext__ptw__cp_dside_leaf_ptw_write, hext__traps__cp_excp_def iff (VirtualMode == 1) {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.page_flt_load) && !binsof(hext__traps__cp_excp_def.page_flt_store);
        bins d_leaf_pagefault_store_with_pte_w_zero         = binsof(hext__ptw__cp_dside_leaf_ptw_valid) intersect {1} &&
                                                            binsof(hext__accesstype__cp_instr_2_lvl.stores) &&
                                                            binsof(hext__ptw__cp_dside_leaf_ptw_write) intersect {0};                                                      
        bins d_leaf_pagefault_sc_with_pte_w_zero            = binsof(hext__ptw__cp_dside_leaf_ptw_valid) intersect {1} &&
                                                            binsof(hext__accesstype__cp_instr_2_lvl.atomics_sc) &&
                                                            binsof(hext__ptw__cp_dside_leaf_ptw_write) intersect {0};
        bins d_leaf_pagefault_amo_with_pte_w_zero           = binsof(hext__ptw__cp_dside_leaf_ptw_valid) intersect {1} &&
                                                            binsof(hext__accesstype__cp_instr_2_lvl.atomics_amo) &&
                                                            binsof(hext__ptw__cp_dside_leaf_ptw_write) intersect {0};
    }

    hext__traps__cr_data_pagefault_load: cross hext__ptw__cp_dside_leaf_ptw_valid, hext__accesstype__cp_instr_2_lvl, 
                                              hext__ptw__cp_dside_leaf_ptw_read, hext__ptw__cp_dside_leaf_ptw_write, 
                                              hext__ptw__cp_dside_leaf_ptw_exec, hext__csr__cp_vsstatus_mxr, hext__csr__cp_sstatus_mxr, hext__traps__cp_excp_def iff (VirtualMode == 1) {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.page_flt_load) && !binsof(hext__traps__cp_excp_def.page_flt_store);
        bins d_leaf_pagefault_load_with_pte_r_zero_wr_zero  = binsof(hext__ptw__cp_dside_leaf_ptw_valid) intersect {1} &&
                                                            binsof(hext__accesstype__cp_instr_2_lvl.loads) &&
                                                            binsof(hext__ptw__cp_dside_leaf_ptw_read) intersect {0} && 
                                                            binsof(hext__ptw__cp_dside_leaf_ptw_write) intersect {0};
        bins d_leaf_pagefault_load_with_pte_r_zero_wr_1     = binsof(hext__ptw__cp_dside_leaf_ptw_valid) intersect {1} &&
                                                            binsof(hext__accesstype__cp_instr_2_lvl.loads) &&
                                                            binsof(hext__ptw__cp_dside_leaf_ptw_read) intersect {0} && 
                                                            binsof(hext__ptw__cp_dside_leaf_ptw_write) intersect {1};       
        bins d_leaf_pagefault_lr_with_pte_r_zero            = binsof(hext__ptw__cp_dside_leaf_ptw_valid) intersect {1} &&
                                                            binsof(hext__accesstype__cp_instr_2_lvl.atomics_lr) &&
                                                            binsof(hext__ptw__cp_dside_leaf_ptw_read) intersect {0};
        bins d_leaf_pagefault_amo_with_pte_r_zero           = binsof(hext__ptw__cp_dside_leaf_ptw_valid) intersect {1} &&
                                                            binsof(hext__accesstype__cp_instr_2_lvl.atomics_amo) &&
                                                            binsof(hext__ptw__cp_dside_leaf_ptw_read) intersect {0};
    }

    hext__traps__cr_data_pagefault_h_instr: cross hext__ptw__cp_dside_leaf_ptw_valid, hext__accesstype__cp_h_instr_2_lvl, 
                                                 hext__ptw__cp_dside_leaf_ptw_write, hext__ptw__cp_dside_leaf_ptw_read, 
                                                 hext__ptw__cp_dside_leaf_ptw_exec, hext__csr__cp_vsstatus_mxr, hext__csr__cp_sstatus_mxr, hext__traps__cp_excp_def {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.page_flt_load) && !binsof(hext__traps__cp_excp_def.page_flt_store);
        bins d_leaf_pagefault_h_store_with_pte_w_zero       = binsof(hext__ptw__cp_dside_leaf_ptw_valid) intersect {1} &&
                                                            binsof(hext__accesstype__cp_h_instr_2_lvl.h_stores) &&
                                                            binsof(hext__ptw__cp_dside_leaf_ptw_write) intersect {0} ; 
        bins d_leaf_pagefault_h_load_with_pte_r_zero_wr_zero= binsof(hext__ptw__cp_dside_leaf_ptw_valid) intersect {1} &&
                                                            binsof(hext__accesstype__cp_h_instr_2_lvl.h_loads) &&
                                                            binsof(hext__ptw__cp_dside_leaf_ptw_read) intersect {0} && 
                                                            binsof(hext__ptw__cp_dside_leaf_ptw_write) intersect {0} ;
        bins d_leaf_pagefault_h_load_with_pte_r_zero_wr_1   = binsof(hext__ptw__cp_dside_leaf_ptw_valid) intersect {1} &&
                                                            binsof(hext__accesstype__cp_h_instr_2_lvl.h_loads) &&
                                                            binsof(hext__ptw__cp_dside_leaf_ptw_read) intersect {0} && 
                                                            binsof(hext__ptw__cp_dside_leaf_ptw_write) intersect {1};
        bins d_pagefault_h_loadx_with_pte_x_zero            = binsof(hext__ptw__cp_dside_leaf_ptw_valid) intersect {1} &&
                                                            binsof(hext__ptw__cp_dside_leaf_ptw_exec) intersect {0} &&
                                                            binsof(hext__accesstype__cp_h_instr_2_lvl.h_loads_x);  
    }

    hext__traps__cr_data_pagefault_access: cross hext__ptw__cp_dside_leaf_ptw_valid, hext__accesstype__cp_instr_2_lvl, 
                                                  hext__ptw__cp_dside_leaf_ptw_read, hext__ptw__cp_dside_leaf_ptw_access, hext__traps__cp_excp_def iff (VirtualMode == 1) {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.page_flt_load) && !binsof(hext__traps__cp_excp_def.page_flt_store);
        bins d_pagefault_load_with_access_bit_zero          = binsof(hext__ptw__cp_dside_leaf_ptw_valid) intersect {1} &&
                                                            binsof(hext__accesstype__cp_instr_2_lvl.loads) &&
                                                            binsof(hext__ptw__cp_dside_leaf_ptw_read) intersect {1} &&
                                                            binsof(hext__ptw__cp_dside_leaf_ptw_access) intersect {0};
    }

    hext__traps__cr_data_pagefault_h_access: cross hext__ptw__cp_dside_leaf_ptw_valid, hext__accesstype__cp_h_instr_2_lvl, 
                                                    hext__ptw__cp_dside_leaf_ptw_read, hext__ptw__cp_dside_leaf_ptw_exec,
                                                    hext__ptw__cp_dside_leaf_ptw_access, hext__traps__cp_excp_def
    {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.page_flt_load) && !binsof(hext__traps__cp_excp_def.page_flt_store);
        bins d_pagefault_h_load_with_access_bit_zero        = binsof(hext__ptw__cp_dside_leaf_ptw_valid) intersect {1} &&
                                                            binsof(hext__accesstype__cp_h_instr_2_lvl.h_loads) &&
                                                            binsof(hext__ptw__cp_dside_leaf_ptw_read) intersect {1} &&
                                                            binsof(hext__ptw__cp_dside_leaf_ptw_access) intersect {0};
        bins d_pagefault_h_loadx_with_access_bit_zero       = binsof(hext__ptw__cp_dside_leaf_ptw_valid) intersect {1} &&
                                                            binsof(hext__accesstype__cp_h_instr_2_lvl.h_loads_x) &&
                                                            binsof(hext__ptw__cp_dside_leaf_ptw_exec) intersect {1} &&
                                                            binsof(hext__ptw__cp_dside_leaf_ptw_access) intersect {0};
    }

    hext__traps__cr_data_pagefault_dirty: cross hext__ptw__cp_dside_leaf_ptw_valid, hext__accesstype__cp_instr_2_lvl, 
                                                  hext__ptw__cp_dside_leaf_ptw_write, hext__ptw__cp_dside_leaf_ptw_dirty, hext__traps__cp_excp_def iff (VirtualMode == 1)
    {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.page_flt_load) && !binsof(hext__traps__cp_excp_def.page_flt_store);
        bins d_pagefault_store_with_dirty_bit_zero          = binsof(hext__ptw__cp_dside_leaf_ptw_valid) intersect {1} &&
                                                            binsof(hext__accesstype__cp_instr_2_lvl.stores) &&
                                                            binsof(hext__ptw__cp_dside_leaf_ptw_write) intersect {1} &&
                                                            binsof(hext__ptw__cp_dside_leaf_ptw_dirty) intersect {0};
    }

    hext__traps__cr_data_pagefault_h_dirty: cross hext__ptw__cp_dside_leaf_ptw_valid, hext__accesstype__cp_h_instr_2_lvl, 
                                                     hext__ptw__cp_dside_leaf_ptw_write, hext__ptw__cp_dside_leaf_ptw_dirty, hext__traps__cp_excp_def
    {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.page_flt_load) && !binsof(hext__traps__cp_excp_def.page_flt_store);
        bins d_pagefault_h_store_with_dirty_bit_zero        = binsof(hext__ptw__cp_dside_leaf_ptw_valid) intersect {1} &&
                                                            binsof(hext__accesstype__cp_h_instr_2_lvl.h_stores) &&
                                                            binsof(hext__ptw__cp_dside_leaf_ptw_write) intersect {1} &&
                                                            binsof(hext__ptw__cp_dside_leaf_ptw_dirty) intersect {0};                                                     
    }

    hext__traps__cr_data_pagefault_priv: cross hext__ptw__cp_dside_leaf_ptw_valid, hext__ptw__cp_dside_leaf_ptw_user, 
                                                hext__privilege__cp_dside_eff_privilege_mode, hext__csr__cp_vsstatus_sum, hext__traps__cp_excp_def
    {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.page_flt_load) && !binsof(hext__traps__cp_excp_def.page_flt_store);
        bins d_pagefault_in_v_user_mode_with_pte_u_bit_zero = binsof(hext__ptw__cp_dside_leaf_ptw_valid) intersect {1} &&
                                                            binsof(hext__ptw__cp_dside_leaf_ptw_user) intersect {0} &&
                                                            binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_user);
        bins d_pagefault_in_v_user_mode_with_pte_u1_bit_zero= binsof(hext__ptw__cp_dside_leaf_ptw_valid) intersect {1} &&
                                                            binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_user_due_to_mprv) && binsof(hext__ptw__cp_dside_leaf_ptw_user) intersect {0};
        bins d_pagefault_in_v_super_mode_with_pte_u_bit_one = binsof(hext__ptw__cp_dside_leaf_ptw_valid) intersect {1} &&
                                                            binsof(hext__ptw__cp_dside_leaf_ptw_user) intersect {1} &&
                                                            binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_supervisor) &&
                                                            binsof(hext__csr__cp_vsstatus_sum.sum_low);
        bins d_pagefault_in_v_super_mode_with_pte_u1_bit_one= binsof(hext__ptw__cp_dside_leaf_ptw_valid) intersect {1} &&
                                                            binsof(hext__ptw__cp_dside_leaf_ptw_user) intersect {1} &&
                                                            binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_supervisor_due_to_mprv) &&
                                                            binsof(hext__csr__cp_vsstatus_sum.sum_low);
    }

    hext__traps__cr_data_pagefault_leaf_pbmt: cross hext__ptw__cp_dside_leaf_ptw_valid, hext__ptw__cp_dside_leaf_pbmt, hext__traps__cp_excp_def iff (VirtualMode == 1)
    {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.page_flt_load) && !binsof(hext__traps__cp_excp_def.page_flt_store);
        bins d_pagefault_due_to_leaf_pbmt                   = binsof(hext__ptw__cp_dside_leaf_ptw_valid) intersect {1} && 
                                                            binsof(hext__ptw__cp_dside_leaf_pbmt.pbmt_d_leaf_reserved);
    }

    hext__traps__cr_data_pagefault_nonleaf_pbmt: cross hext__ptw__cp_dside_nonleaf_ptw_valid, hext__ptw__cp_dside_nonleaf_pbmt, hext__traps__cp_excp_def iff (VirtualMode == 1)
    {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.page_flt_load) && !binsof(hext__traps__cp_excp_def.page_flt_store);
        bins d_pagefault_due_to_nonleaf_pbmt                = binsof(hext__ptw__cp_dside_nonleaf_ptw_valid) intersect {1} && 
                                                            binsof(hext__ptw__cp_dside_nonleaf_pbmt.pbmt_d_nonleaf_reserved);
    }

    hext__traps__cr_data_pagefault_leaf_res: cross hext__ptw__cp_dside_leaf_ptw_valid, hext__ptw__cp_dside_leaf_res, hext__traps__cp_excp_def iff (VirtualMode == 1)
    {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.page_flt_load) && !binsof(hext__traps__cp_excp_def.page_flt_store);
        bins d_pagefault_due_to_leaf_res_60_54              = binsof(hext__ptw__cp_dside_leaf_ptw_valid) intersect {1} &&
                                                            binsof(hext__ptw__cp_dside_leaf_res.res_d_leaf_nonzero);
    }

    hext__traps__cr_data_pagefault_nonleaf_res: cross hext__ptw__cp_dside_nonleaf_ptw_valid, hext__ptw__cp_dside_nonleaf_res, hext__traps__cp_excp_def iff (VirtualMode == 1)
    {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.page_flt_load) && !binsof(hext__traps__cp_excp_def.page_flt_store);
        bins d_pagefault_due_to_nonleaf_res_60_54           = binsof(hext__ptw__cp_dside_nonleaf_ptw_valid) intersect {1} &&
                                                            binsof(hext__ptw__cp_dside_nonleaf_res.res_d_nonleaf_nonzero);
    }

    hext__traps__cr_data_pagefault_nonleaf_dau: cross hext__ptw__cp_dside_nonleaf_ptw_valid, hext__ptw__cp_dside_nonleaf_ptw_access,
                                                       hext__ptw__cp_dside_nonleaf_ptw_dirty, hext__ptw__cp_dside_nonleaf_ptw_user, hext__traps__cp_excp_def iff (VirtualMode == 1)
    {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.page_flt_load) && !binsof(hext__traps__cp_excp_def.page_flt_store);
        bins d_pagefault_nonleaf_without_DAU                = binsof(hext__ptw__cp_dside_nonleaf_ptw_valid) intersect {1} && 
                                                            (binsof(hext__ptw__cp_dside_nonleaf_ptw_access) intersect {1} || 
                                                            binsof(hext__ptw__cp_dside_nonleaf_ptw_dirty) intersect {1} || 
                                                            binsof(hext__ptw__cp_dside_nonleaf_ptw_user) intersect {1});
    }

    hext__traps__cr_data_guestpagefault_lvl1_read: cross hext__ptw__cp_dside_gstage_lvl1_leaf_ptw_valid, hext__ptw__cp_dside_gstage_lvl1_leaf_ptw_read, hext__traps__cp_excp_def
    {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_load) && !binsof(hext__traps__cp_excp_def.guest_page_flt_store);
        bins d_leaf_guestpagefault_with_pte_r_zero = binsof(hext__ptw__cp_dside_gstage_lvl1_leaf_ptw_valid) intersect {1} &&
                                                     binsof(hext__ptw__cp_dside_gstage_lvl1_leaf_ptw_read) intersect {0};
    }

    hext__traps__cr_data_guestpagefault_lvl1_access: cross hext__ptw__cp_dside_gstage_lvl1_leaf_ptw_valid, hext__accesstype__cp_instr_2_lvl, 
                                                            hext__ptw__cp_dside_gstage_lvl1_leaf_ptw_read, hext__ptw__cp_dside_gstage_lvl1_leaf_ptw_access, hext__traps__cp_excp_def
    {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_load) && !binsof(hext__traps__cp_excp_def.guest_page_flt_store);
        bins d_guestpagefault_load_with_access_bit_zero         = binsof(hext__ptw__cp_dside_gstage_lvl1_leaf_ptw_valid) intersect {1} &&
                                                                binsof(hext__accesstype__cp_instr_2_lvl.loads) &&
                                                                binsof(hext__ptw__cp_dside_gstage_lvl1_leaf_ptw_read) intersect {1} &&
                                                                binsof(hext__ptw__cp_dside_gstage_lvl1_leaf_ptw_access) intersect {0};
    }

    hext__traps__cr_data_guestpagefault_lvl1_h_access: cross hext__ptw__cp_dside_gstage_lvl1_leaf_ptw_valid, hext__accesstype__cp_h_instr_2_lvl, 
                                                              hext__ptw__cp_dside_gstage_lvl1_leaf_ptw_read, hext__ptw__cp_dside_gstage_lvl1_leaf_ptw_exec,
                                                              hext__ptw__cp_dside_gstage_lvl1_leaf_ptw_access, hext__traps__cp_excp_def
    {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_load) && !binsof(hext__traps__cp_excp_def.guest_page_flt_store);
        bins d_guestpagefault_h_load_with_access_bit_zero       = binsof(hext__ptw__cp_dside_gstage_lvl1_leaf_ptw_valid) intersect {1} &&
                                                                binsof(hext__accesstype__cp_h_instr_2_lvl.h_loads) &&
                                                                binsof(hext__ptw__cp_dside_gstage_lvl1_leaf_ptw_read) intersect {1} &&
                                                                binsof(hext__ptw__cp_dside_gstage_lvl1_leaf_ptw_access) intersect {0};
        bins d_guestpagefault_h_loadx_with_access_bit_zero      = binsof(hext__ptw__cp_dside_gstage_lvl1_leaf_ptw_valid) intersect {1} &&
                                                                binsof(hext__accesstype__cp_h_instr_2_lvl.h_loads_x) &&
                                                                binsof(hext__ptw__cp_dside_gstage_lvl1_leaf_ptw_exec) intersect {1} &&
                                                                binsof(hext__ptw__cp_dside_gstage_lvl1_leaf_ptw_access) intersect {0};
    }

    hext__traps__cr_data_guestpagefault_lvl1_user: cross hext__ptw__cp_dside_gstage_lvl1_leaf_ptw_valid, hext__ptw__cp_dside_gstage_lvl1_leaf_ptw_user, 
                                                          hext__privilege__cp_dside_eff_privilege_mode, hext__csr__cp_vsstatus_sum, hext__traps__cp_excp_def
    {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_load) && !binsof(hext__traps__cp_excp_def.guest_page_flt_store);
        // Guest-stage always treats privilege as U-mode, so U=0 pages cause faults in all virtual modes
        bins d_guestpagefault_in_v_user_mode_with_pte_u_bit_zero= binsof(hext__ptw__cp_dside_gstage_lvl1_leaf_ptw_valid) intersect {1} &&
                                                                binsof(hext__ptw__cp_dside_gstage_lvl1_leaf_ptw_user) intersect {0} &&
                                                                binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_user);
        bins d_guestpagefault_in_v_user_mode_with_pte_u1_bit_zero= binsof(hext__ptw__cp_dside_gstage_lvl1_leaf_ptw_valid) intersect {1} &&
                                                                binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_user_due_to_mprv) &&
                                                                binsof(hext__ptw__cp_dside_gstage_lvl1_leaf_ptw_user) intersect {0};
        bins d_guestpagefault_in_v_super_mode_with_pte_u_bit_zero= binsof(hext__ptw__cp_dside_gstage_lvl1_leaf_ptw_valid) intersect {1} &&
                                                                binsof(hext__ptw__cp_dside_gstage_lvl1_leaf_ptw_user) intersect {0} &&
                                                                binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_supervisor);
        bins d_guestpagefault_in_v_super_mode_with_pte_u1_bit_zero= binsof(hext__ptw__cp_dside_gstage_lvl1_leaf_ptw_valid) intersect {1} &&
                                                                binsof(hext__ptw__cp_dside_gstage_lvl1_leaf_ptw_user) intersect {0} &&
                                                                binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_supervisor_due_to_mprv);
    }

    hext__traps__cr_data_guestpagefault_lvl1_leaf_pbmt: cross hext__ptw__cp_dside_gstage_lvl1_leaf_ptw_valid, hext__ptw__cp_dside_gstage_lvl1_leaf_pbmt, hext__traps__cp_excp_def
    {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_load) && !binsof(hext__traps__cp_excp_def.guest_page_flt_store);
        bins d_guestpagefault_due_to_leaf_pbmt                  = binsof(hext__ptw__cp_dside_gstage_lvl1_leaf_ptw_valid) intersect {1} && 
                                                                binsof(hext__ptw__cp_dside_gstage_lvl1_leaf_pbmt.pbmt_d_leaf_reserved);
    }

    hext__traps__cr_data_guestpagefault_lvl1_nonleaf_pbmt: cross hext__ptw__cp_dside_gstage_lvl1_nonleaf_ptw_valid, hext__ptw__cp_dside_gstage_lvl1_nonleaf_pbmt, hext__traps__cp_excp_def
    {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_load) && !binsof(hext__traps__cp_excp_def.guest_page_flt_store);
        bins d_guestpagefault_due_to_nonleaf_pbmt               = binsof(hext__ptw__cp_dside_gstage_lvl1_nonleaf_ptw_valid) intersect {1} && 
                                                                binsof(hext__ptw__cp_dside_gstage_lvl1_nonleaf_pbmt.pbmt_d_nonleaf_reserved);
    }

    hext__traps__cr_data_guestpagefault_lvl1_nonleaf_access: cross hext__ptw__cp_dside_gstage_lvl1_nonleaf_ptw_valid, hext__ptw__cp_dside_gstage_lvl1_nonleaf_ptw_access, hext__traps__cp_excp_def
    {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_load) && !binsof(hext__traps__cp_excp_def.guest_page_flt_store);
        bins d_guestpagefault_nonleaf_with_access            = binsof(hext__ptw__cp_dside_gstage_lvl1_nonleaf_ptw_valid) intersect {1} && 
                                                                binsof(hext__ptw__cp_dside_gstage_lvl1_nonleaf_ptw_access) intersect {1};
    }

    hext__traps__cr_data_guestpagefault_lvl1_nonleaf_dirty: cross hext__ptw__cp_dside_gstage_lvl1_nonleaf_ptw_valid, hext__ptw__cp_dside_gstage_lvl1_nonleaf_ptw_dirty, hext__traps__cp_excp_def
    {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_load) && !binsof(hext__traps__cp_excp_def.guest_page_flt_store);
        bins d_guestpagefault_nonleaf_with_dirty             = binsof(hext__ptw__cp_dside_gstage_lvl1_nonleaf_ptw_valid) intersect {1} && 
                                                                binsof(hext__ptw__cp_dside_gstage_lvl1_nonleaf_ptw_dirty) intersect {1};
    }

    hext__traps__cr_data_guestpagefault_lvl1_nonleaf_user: cross hext__ptw__cp_dside_gstage_lvl1_nonleaf_ptw_valid, hext__ptw__cp_dside_gstage_lvl1_nonleaf_ptw_user, hext__traps__cp_excp_def
    {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_load) && !binsof(hext__traps__cp_excp_def.guest_page_flt_store);
        bins d_guestpagefault_nonleaf_with_user              = binsof(hext__ptw__cp_dside_gstage_lvl1_nonleaf_ptw_valid) intersect {1} && 
                                                                binsof(hext__ptw__cp_dside_gstage_lvl1_nonleaf_ptw_user) intersect {1};
    }

    hext__traps__cr_data_guestpagefault_lvl2_read: cross hext__ptw__cp_dside_gstage_lvl2_leaf_ptw_valid, hext__ptw__cp_dside_gstage_lvl2_leaf_ptw_read, hext__traps__cp_excp_def
    {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_load) && !binsof(hext__traps__cp_excp_def.guest_page_flt_store);
        bins d_leaf_guestpagefault_with_pte_r_zero = binsof(hext__ptw__cp_dside_gstage_lvl2_leaf_ptw_valid) intersect {1} &&
                                                     binsof(hext__ptw__cp_dside_gstage_lvl2_leaf_ptw_read) intersect {0};
    }

    hext__traps__cr_data_guestpagefault_lvl2_access: cross hext__ptw__cp_dside_gstage_lvl2_leaf_ptw_valid, hext__accesstype__cp_instr_2_lvl, 
                                                            hext__ptw__cp_dside_gstage_lvl2_leaf_ptw_read, hext__ptw__cp_dside_gstage_lvl2_leaf_ptw_access, hext__traps__cp_excp_def
    {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_load) && !binsof(hext__traps__cp_excp_def.guest_page_flt_store);
        bins d_guestpagefault_load_with_access_bit_zero         = binsof(hext__ptw__cp_dside_gstage_lvl2_leaf_ptw_valid) intersect {1} &&
                                                                binsof(hext__accesstype__cp_instr_2_lvl.loads) &&
                                                                binsof(hext__ptw__cp_dside_gstage_lvl2_leaf_ptw_read) intersect {1} &&
                                                                binsof(hext__ptw__cp_dside_gstage_lvl2_leaf_ptw_access) intersect {0};
    }

    hext__traps__cr_data_guestpagefault_lvl2_h_access: cross hext__ptw__cp_dside_gstage_lvl2_leaf_ptw_valid, hext__accesstype__cp_h_instr_2_lvl, 
                                                              hext__ptw__cp_dside_gstage_lvl2_leaf_ptw_read, hext__ptw__cp_dside_gstage_lvl2_leaf_ptw_exec,
                                                              hext__ptw__cp_dside_gstage_lvl2_leaf_ptw_access, hext__traps__cp_excp_def
    {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_load) && !binsof(hext__traps__cp_excp_def.guest_page_flt_store);
        bins d_guestpagefault_h_load_with_access_bit_zero       = binsof(hext__ptw__cp_dside_gstage_lvl2_leaf_ptw_valid) intersect {1} &&
                                                                binsof(hext__accesstype__cp_h_instr_2_lvl.h_loads) &&
                                                                binsof(hext__ptw__cp_dside_gstage_lvl2_leaf_ptw_read) intersect {1} &&
                                                                binsof(hext__ptw__cp_dside_gstage_lvl2_leaf_ptw_access) intersect {0};
        bins d_guestpagefault_h_loadx_with_access_bit_zero      = binsof(hext__ptw__cp_dside_gstage_lvl2_leaf_ptw_valid) intersect {1} &&
                                                                binsof(hext__accesstype__cp_h_instr_2_lvl.h_loads_x) &&
                                                                binsof(hext__ptw__cp_dside_gstage_lvl2_leaf_ptw_exec) intersect {1} &&
                                                                binsof(hext__ptw__cp_dside_gstage_lvl2_leaf_ptw_access) intersect {0};
    }

    hext__traps__cr_data_guestpagefault_lvl2_user: cross hext__ptw__cp_dside_gstage_lvl2_leaf_ptw_valid, hext__ptw__cp_dside_gstage_lvl2_leaf_ptw_user, 
                                                          hext__privilege__cp_dside_eff_privilege_mode, hext__csr__cp_vsstatus_sum, hext__traps__cp_excp_def
    {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_load) && !binsof(hext__traps__cp_excp_def.guest_page_flt_store);
        bins d_guestpagefault_in_v_user_mode_with_pte_u_bit_zero= binsof(hext__ptw__cp_dside_gstage_lvl2_leaf_ptw_valid) intersect {1} &&
                                                               binsof(hext__ptw__cp_dside_gstage_lvl2_leaf_ptw_user) intersect {0} &&
                                                               binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_user);
        bins d_guestpagefault_in_v_user_mode_with_pte_u2_bit_zero= binsof(hext__ptw__cp_dside_gstage_lvl2_leaf_ptw_valid) intersect {1} &&
                                                               binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_user_due_to_mprv) &&
                                                               binsof(hext__ptw__cp_dside_gstage_lvl2_leaf_ptw_user) intersect {0};
        bins d_guestpagefault_in_v_super_mode_with_pte_u_bit_zero= binsof(hext__ptw__cp_dside_gstage_lvl2_leaf_ptw_valid) intersect {1} &&
                                                               binsof(hext__ptw__cp_dside_gstage_lvl2_leaf_ptw_user) intersect {0} &&
                                                               binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_supervisor);
        bins d_guestpagefault_in_v_super_mode_with_pte_u2_bit_zero= binsof(hext__ptw__cp_dside_gstage_lvl2_leaf_ptw_valid) intersect {1} &&
                                                               binsof(hext__ptw__cp_dside_gstage_lvl2_leaf_ptw_user) intersect {0} &&
                                                               binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_supervisor_due_to_mprv);
    }

    hext__traps__cr_data_guestpagefault_lvl2_leaf_pbmt: cross hext__ptw__cp_dside_gstage_lvl2_leaf_ptw_valid, hext__ptw__cp_dside_gstage_lvl2_leaf_pbmt, hext__traps__cp_excp_def
    {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_load) && !binsof(hext__traps__cp_excp_def.guest_page_flt_store);
        bins d_guestpagefault_due_to_leaf_pbmt                  = binsof(hext__ptw__cp_dside_gstage_lvl2_leaf_ptw_valid) intersect {1} && 
                                                                binsof(hext__ptw__cp_dside_gstage_lvl2_leaf_pbmt.pbmt_d_leaf_reserved);
    }

    hext__traps__cr_data_guestpagefault_lvl2_nonleaf_pbmt: cross hext__ptw__cp_dside_gstage_lvl2_nonleaf_ptw_valid, hext__ptw__cp_dside_gstage_lvl2_nonleaf_pbmt, hext__traps__cp_excp_def
    {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_load) && !binsof(hext__traps__cp_excp_def.guest_page_flt_store);
        bins d_guestpagefault_due_to_nonleaf_pbmt               = binsof(hext__ptw__cp_dside_gstage_lvl2_nonleaf_ptw_valid) intersect {1} && 
                                                                binsof(hext__ptw__cp_dside_gstage_lvl2_nonleaf_pbmt.pbmt_d_nonleaf_reserved);
    }

    hext__traps__cr_data_guestpagefault_lvl2_nonleaf_access: cross hext__ptw__cp_dside_gstage_lvl2_nonleaf_ptw_valid, hext__ptw__cp_dside_gstage_lvl2_nonleaf_ptw_access, hext__traps__cp_excp_def
    {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_load) && !binsof(hext__traps__cp_excp_def.guest_page_flt_store);
        bins d_guestpagefault_nonleaf_with_access            = binsof(hext__ptw__cp_dside_gstage_lvl2_nonleaf_ptw_valid) intersect {1} && 
                                                                binsof(hext__ptw__cp_dside_gstage_lvl2_nonleaf_ptw_access) intersect {1};
    }

    hext__traps__cr_data_guestpagefault_lvl2_nonleaf_dirty: cross hext__ptw__cp_dside_gstage_lvl2_nonleaf_ptw_valid, hext__ptw__cp_dside_gstage_lvl2_nonleaf_ptw_dirty, hext__traps__cp_excp_def
    {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_load) && !binsof(hext__traps__cp_excp_def.guest_page_flt_store);
        bins d_guestpagefault_nonleaf_with_dirty             = binsof(hext__ptw__cp_dside_gstage_lvl2_nonleaf_ptw_valid) intersect {1} && 
                                                                binsof(hext__ptw__cp_dside_gstage_lvl2_nonleaf_ptw_dirty) intersect {1};
    }

    hext__traps__cr_data_guestpagefault_lvl2_nonleaf_user: cross hext__ptw__cp_dside_gstage_lvl2_nonleaf_ptw_valid, hext__ptw__cp_dside_gstage_lvl2_nonleaf_ptw_user, hext__traps__cp_excp_def
    {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_load) && !binsof(hext__traps__cp_excp_def.guest_page_flt_store);
        bins d_guestpagefault_nonleaf_with_user              = binsof(hext__ptw__cp_dside_gstage_lvl2_nonleaf_ptw_valid) intersect {1} && 
                                                                binsof(hext__ptw__cp_dside_gstage_lvl2_nonleaf_ptw_user) intersect {1};
    }

    hext__traps__cr_data_guestpagefault_lvl3_read: cross hext__ptw__cp_dside_gstage_lvl3_leaf_ptw_valid, hext__ptw__cp_dside_gstage_lvl3_leaf_ptw_read, hext__traps__cp_excp_def
    {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_load) && !binsof(hext__traps__cp_excp_def.guest_page_flt_store);
        bins d_leaf_guestpagefault_with_pte_r_zero = binsof(hext__ptw__cp_dside_gstage_lvl3_leaf_ptw_valid) intersect {1} &&
                                                     binsof(hext__ptw__cp_dside_gstage_lvl3_leaf_ptw_read) intersect {0};
    }

    hext__traps__cr_data_guestpagefault_lvl3_access: cross hext__ptw__cp_dside_gstage_lvl3_leaf_ptw_valid, hext__accesstype__cp_instr_2_lvl, 
                                                            hext__ptw__cp_dside_gstage_lvl3_leaf_ptw_read, hext__ptw__cp_dside_gstage_lvl3_leaf_ptw_access, hext__traps__cp_excp_def
    {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_load) && !binsof(hext__traps__cp_excp_def.guest_page_flt_store);
        bins d_guestpagefault_load_with_access_bit_zero         = binsof(hext__ptw__cp_dside_gstage_lvl3_leaf_ptw_valid) intersect {1} &&
                                                                binsof(hext__accesstype__cp_instr_2_lvl.loads) &&
                                                                binsof(hext__ptw__cp_dside_gstage_lvl3_leaf_ptw_read) intersect {1} &&
                                                                binsof(hext__ptw__cp_dside_gstage_lvl3_leaf_ptw_access) intersect {0};
    }

    hext__traps__cr_data_guestpagefault_lvl3_h_access: cross hext__ptw__cp_dside_gstage_lvl3_leaf_ptw_valid, hext__accesstype__cp_h_instr_2_lvl, 
                                                              hext__ptw__cp_dside_gstage_lvl3_leaf_ptw_read, hext__ptw__cp_dside_gstage_lvl3_leaf_ptw_exec,
                                                              hext__ptw__cp_dside_gstage_lvl3_leaf_ptw_access, hext__traps__cp_excp_def
    {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_load) && !binsof(hext__traps__cp_excp_def.guest_page_flt_store);
        bins d_guestpagefault_h_load_with_access_bit_zero       = binsof(hext__ptw__cp_dside_gstage_lvl3_leaf_ptw_valid) intersect {1} &&
                                                                binsof(hext__accesstype__cp_h_instr_2_lvl.h_loads) &&
                                                                binsof(hext__ptw__cp_dside_gstage_lvl3_leaf_ptw_read) intersect {1} &&
                                                                binsof(hext__ptw__cp_dside_gstage_lvl3_leaf_ptw_access) intersect {0};
        bins d_guestpagefault_h_loadx_with_access_bit_zero      = binsof(hext__ptw__cp_dside_gstage_lvl3_leaf_ptw_valid) intersect {1} &&
                                                                binsof(hext__accesstype__cp_h_instr_2_lvl.h_loads_x) &&
                                                                binsof(hext__ptw__cp_dside_gstage_lvl3_leaf_ptw_exec) intersect {1} &&
                                                                binsof(hext__ptw__cp_dside_gstage_lvl3_leaf_ptw_access) intersect {0};
    }

    hext__traps__cr_data_guestpagefault_lvl3_user: cross hext__ptw__cp_dside_gstage_lvl3_leaf_ptw_valid, hext__ptw__cp_dside_gstage_lvl3_leaf_ptw_user, 
                                                          hext__privilege__cp_dside_eff_privilege_mode, hext__csr__cp_vsstatus_sum, hext__traps__cp_excp_def
    {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_load) && !binsof(hext__traps__cp_excp_def.guest_page_flt_store);
        bins d_guestpagefault_in_v_user_mode_with_pte_u_bit_zero= binsof(hext__ptw__cp_dside_gstage_lvl3_leaf_ptw_valid) intersect {1} &&
                                                               binsof(hext__ptw__cp_dside_gstage_lvl3_leaf_ptw_user) intersect {0} &&
                                                               binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_user);
        bins d_guestpagefault_in_v_user_mode_with_pte_u3_bit_zero= binsof(hext__ptw__cp_dside_gstage_lvl3_leaf_ptw_valid) intersect {1} &&
                                                               binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_user_due_to_mprv) &&
                                                               binsof(hext__ptw__cp_dside_gstage_lvl3_leaf_ptw_user) intersect {0};
        bins d_guestpagefault_in_v_super_mode_with_pte_u_bit_zero= binsof(hext__ptw__cp_dside_gstage_lvl3_leaf_ptw_valid) intersect {1} &&
                                                               binsof(hext__ptw__cp_dside_gstage_lvl3_leaf_ptw_user) intersect {0} &&
                                                               binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_supervisor);
        bins d_guestpagefault_in_v_super_mode_with_pte_u3_bit_zero= binsof(hext__ptw__cp_dside_gstage_lvl3_leaf_ptw_valid) intersect {1} &&
                                                               binsof(hext__ptw__cp_dside_gstage_lvl3_leaf_ptw_user) intersect {0} &&
                                                               binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_supervisor_due_to_mprv);
    }

    hext__traps__cr_data_guestpagefault_lvl3_leaf_pbmt: cross hext__ptw__cp_dside_gstage_lvl3_leaf_ptw_valid, hext__ptw__cp_dside_gstage_lvl3_leaf_pbmt, hext__traps__cp_excp_def
    {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_load) && !binsof(hext__traps__cp_excp_def.guest_page_flt_store);
        bins d_guestpagefault_due_to_leaf_pbmt                  = binsof(hext__ptw__cp_dside_gstage_lvl3_leaf_ptw_valid) intersect {1} && 
                                                                binsof(hext__ptw__cp_dside_gstage_lvl3_leaf_pbmt.pbmt_d_leaf_reserved);
    }

    hext__traps__cr_data_guestpagefault_lvl3_nonleaf_pbmt: cross hext__ptw__cp_dside_gstage_lvl3_nonleaf_ptw_valid, hext__ptw__cp_dside_gstage_lvl3_nonleaf_pbmt, hext__traps__cp_excp_def
    {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_load) && !binsof(hext__traps__cp_excp_def.guest_page_flt_store);
        bins d_guestpagefault_due_to_nonleaf_pbmt               = binsof(hext__ptw__cp_dside_gstage_lvl3_nonleaf_ptw_valid) intersect {1} && 
                                                                binsof(hext__ptw__cp_dside_gstage_lvl3_nonleaf_pbmt.pbmt_d_nonleaf_reserved);
    }

    hext__traps__cr_data_guestpagefault_lvl3_nonleaf_access: cross hext__ptw__cp_dside_gstage_lvl3_nonleaf_ptw_valid, hext__ptw__cp_dside_gstage_lvl3_nonleaf_ptw_access, hext__traps__cp_excp_def
    {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_load) && !binsof(hext__traps__cp_excp_def.guest_page_flt_store);
        bins d_guestpagefault_nonleaf_with_access            = binsof(hext__ptw__cp_dside_gstage_lvl3_nonleaf_ptw_valid) intersect {1} && 
                                                                binsof(hext__ptw__cp_dside_gstage_lvl3_nonleaf_ptw_access) intersect {1};
    }

    hext__traps__cr_data_guestpagefault_lvl3_nonleaf_dirty: cross hext__ptw__cp_dside_gstage_lvl3_nonleaf_ptw_valid, hext__ptw__cp_dside_gstage_lvl3_nonleaf_ptw_dirty, hext__traps__cp_excp_def
    {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_load) && !binsof(hext__traps__cp_excp_def.guest_page_flt_store);
        bins d_guestpagefault_nonleaf_with_dirty             = binsof(hext__ptw__cp_dside_gstage_lvl3_nonleaf_ptw_valid) intersect {1} && 
                                                                binsof(hext__ptw__cp_dside_gstage_lvl3_nonleaf_ptw_dirty) intersect {1};
    }

    hext__traps__cr_data_guestpagefault_lvl3_nonleaf_user: cross hext__ptw__cp_dside_gstage_lvl3_nonleaf_ptw_valid, hext__ptw__cp_dside_gstage_lvl3_nonleaf_ptw_user, hext__traps__cp_excp_def
    {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_load) && !binsof(hext__traps__cp_excp_def.guest_page_flt_store);
        bins d_guestpagefault_nonleaf_with_user              = binsof(hext__ptw__cp_dside_gstage_lvl3_nonleaf_ptw_valid) intersect {1} && 
                                                                binsof(hext__ptw__cp_dside_gstage_lvl3_nonleaf_ptw_user) intersect {1};
    }

    hext__traps__cr_data_guestpagefault_lvl4_read: cross hext__ptw__cp_dside_gstage_lvl4_leaf_ptw_valid, hext__ptw__cp_dside_gstage_lvl4_leaf_ptw_read, hext__traps__cp_excp_def
    {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_load) && !binsof(hext__traps__cp_excp_def.guest_page_flt_store);
        bins d_leaf_guestpagefault_with_pte_r_zero = binsof(hext__ptw__cp_dside_gstage_lvl4_leaf_ptw_valid) intersect {1} &&
                                                     binsof(hext__ptw__cp_dside_gstage_lvl4_leaf_ptw_read) intersect {0};
    }

    hext__traps__cr_data_guestpagefault_lvl4_access: cross hext__ptw__cp_dside_gstage_lvl4_leaf_ptw_valid, hext__accesstype__cp_instr_2_lvl, 
                                                            hext__ptw__cp_dside_gstage_lvl4_leaf_ptw_read, hext__ptw__cp_dside_gstage_lvl4_leaf_ptw_access, hext__traps__cp_excp_def
    {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_load) && !binsof(hext__traps__cp_excp_def.guest_page_flt_store);
        bins d_guestpagefault_load_with_access_bit_zero         = binsof(hext__ptw__cp_dside_gstage_lvl4_leaf_ptw_valid) intersect {1} &&
                                                                binsof(hext__accesstype__cp_instr_2_lvl.loads) &&
                                                                binsof(hext__ptw__cp_dside_gstage_lvl4_leaf_ptw_read) intersect {1} &&
                                                                binsof(hext__ptw__cp_dside_gstage_lvl4_leaf_ptw_access) intersect {0};
    }

    hext__traps__cr_data_guestpagefault_lvl4_h_access: cross hext__ptw__cp_dside_gstage_lvl4_leaf_ptw_valid, hext__accesstype__cp_h_instr_2_lvl, 
                                                              hext__ptw__cp_dside_gstage_lvl4_leaf_ptw_read, hext__ptw__cp_dside_gstage_lvl4_leaf_ptw_exec,
                                                              hext__ptw__cp_dside_gstage_lvl4_leaf_ptw_access, hext__traps__cp_excp_def
    {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_load) && !binsof(hext__traps__cp_excp_def.guest_page_flt_store);
        bins d_guestpagefault_h_load_with_access_bit_zero       = binsof(hext__ptw__cp_dside_gstage_lvl4_leaf_ptw_valid) intersect {1} &&
                                                                binsof(hext__accesstype__cp_h_instr_2_lvl.h_loads) &&
                                                                binsof(hext__ptw__cp_dside_gstage_lvl4_leaf_ptw_read) intersect {1} &&
                                                                binsof(hext__ptw__cp_dside_gstage_lvl4_leaf_ptw_access) intersect {0};
        bins d_guestpagefault_h_loadx_with_access_bit_zero      = binsof(hext__ptw__cp_dside_gstage_lvl4_leaf_ptw_valid) intersect {1} &&
                                                                binsof(hext__accesstype__cp_h_instr_2_lvl.h_loads_x) &&
                                                                binsof(hext__ptw__cp_dside_gstage_lvl4_leaf_ptw_exec) intersect {1} &&
                                                                binsof(hext__ptw__cp_dside_gstage_lvl4_leaf_ptw_access) intersect {0};
    }

    hext__traps__cr_data_guestpagefault_lvl4_user: cross hext__ptw__cp_dside_gstage_lvl4_leaf_ptw_valid, hext__ptw__cp_dside_gstage_lvl4_leaf_ptw_user, 
                                                          hext__privilege__cp_dside_eff_privilege_mode, hext__csr__cp_vsstatus_sum, hext__traps__cp_excp_def
    {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_load) && !binsof(hext__traps__cp_excp_def.guest_page_flt_store);
        bins d_guestpagefault_in_v_user_mode_with_pte_u_bit_zero= binsof(hext__ptw__cp_dside_gstage_lvl4_leaf_ptw_valid) intersect {1} &&
                                                               binsof(hext__ptw__cp_dside_gstage_lvl4_leaf_ptw_user) intersect {0} &&
                                                               binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_user);
        bins d_guestpagefault_in_v_user_mode_with_pte_u4_bit_zero= binsof(hext__ptw__cp_dside_gstage_lvl4_leaf_ptw_valid) intersect {1} &&
                                                               binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_user_due_to_mprv) &&
                                                               binsof(hext__ptw__cp_dside_gstage_lvl4_leaf_ptw_user) intersect {0};
        bins d_guestpagefault_in_v_super_mode_with_pte_u_bit_zero= binsof(hext__ptw__cp_dside_gstage_lvl4_leaf_ptw_valid) intersect {1} &&
                                                               binsof(hext__ptw__cp_dside_gstage_lvl4_leaf_ptw_user) intersect {0} &&
                                                               binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_supervisor);
        bins d_guestpagefault_in_v_super_mode_with_pte_u4_bit_zero= binsof(hext__ptw__cp_dside_gstage_lvl4_leaf_ptw_valid) intersect {1} &&
                                                               binsof(hext__ptw__cp_dside_gstage_lvl4_leaf_ptw_user) intersect {0} &&
                                                               binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_supervisor_due_to_mprv);
    }

    hext__traps__cr_data_guestpagefault_lvl4_leaf_pbmt: cross hext__ptw__cp_dside_gstage_lvl4_leaf_ptw_valid, hext__ptw__cp_dside_gstage_lvl4_leaf_pbmt, hext__traps__cp_excp_def
    {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_load) && !binsof(hext__traps__cp_excp_def.guest_page_flt_store);
        bins d_guestpagefault_due_to_leaf_pbmt                  = binsof(hext__ptw__cp_dside_gstage_lvl4_leaf_ptw_valid) intersect {1} && 
                                                                binsof(hext__ptw__cp_dside_gstage_lvl4_leaf_pbmt.pbmt_d_leaf_reserved);
    }

    hext__traps__cr_data_guestpagefault_lvl4_nonleaf_pbmt: cross hext__ptw__cp_dside_gstage_lvl4_nonleaf_ptw_valid, hext__ptw__cp_dside_gstage_lvl4_nonleaf_pbmt, hext__traps__cp_excp_def
    {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_load) && !binsof(hext__traps__cp_excp_def.guest_page_flt_store);
        bins d_guestpagefault_due_to_nonleaf_pbmt               = binsof(hext__ptw__cp_dside_gstage_lvl4_nonleaf_ptw_valid) intersect {1} && 
                                                                binsof(hext__ptw__cp_dside_gstage_lvl4_nonleaf_pbmt.pbmt_d_nonleaf_reserved);
    }

    hext__traps__cr_data_guestpagefault_lvl4_nonleaf_access: cross hext__ptw__cp_dside_gstage_lvl4_nonleaf_ptw_valid, hext__ptw__cp_dside_gstage_lvl4_nonleaf_ptw_access, hext__traps__cp_excp_def
    {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_load) && !binsof(hext__traps__cp_excp_def.guest_page_flt_store);
        bins d_guestpagefault_nonleaf_with_access            = binsof(hext__ptw__cp_dside_gstage_lvl4_nonleaf_ptw_valid) intersect {1} && 
                                                                binsof(hext__ptw__cp_dside_gstage_lvl4_nonleaf_ptw_access) intersect {1};
    }

    hext__traps__cr_data_guestpagefault_lvl4_nonleaf_dirty: cross hext__ptw__cp_dside_gstage_lvl4_nonleaf_ptw_valid, hext__ptw__cp_dside_gstage_lvl4_nonleaf_ptw_dirty, hext__traps__cp_excp_def
    {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_load) && !binsof(hext__traps__cp_excp_def.guest_page_flt_store);
        bins d_guestpagefault_nonleaf_with_dirty             = binsof(hext__ptw__cp_dside_gstage_lvl4_nonleaf_ptw_valid) intersect {1} && 
                                                                binsof(hext__ptw__cp_dside_gstage_lvl4_nonleaf_ptw_dirty) intersect {1};
    }

    hext__traps__cr_data_guestpagefault_lvl4_nonleaf_user: cross hext__ptw__cp_dside_gstage_lvl4_nonleaf_ptw_valid, hext__ptw__cp_dside_gstage_lvl4_nonleaf_ptw_user, hext__traps__cp_excp_def
    {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_load) && !binsof(hext__traps__cp_excp_def.guest_page_flt_store);
        bins d_guestpagefault_nonleaf_with_user              = binsof(hext__ptw__cp_dside_gstage_lvl4_nonleaf_ptw_valid) intersect {1} && 
                                                                binsof(hext__ptw__cp_dside_gstage_lvl4_nonleaf_ptw_user) intersect {1};
    }

    hext__traps__cr_data_guestpagefault_lvl5_read: cross hext__ptw__cp_dside_gstage_lvl5_leaf_ptw_valid, hext__ptw__cp_dside_gstage_lvl5_leaf_ptw_read, hext__traps__cp_excp_def
    {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_load) && !binsof(hext__traps__cp_excp_def.guest_page_flt_store);
        bins d_leaf_guestpagefault_with_pte_r_zero = binsof(hext__ptw__cp_dside_gstage_lvl5_leaf_ptw_valid) intersect {1} &&
                                                     binsof(hext__ptw__cp_dside_gstage_lvl5_leaf_ptw_read) intersect {0};
    }

    hext__traps__cr_data_guestpagefault_lvl5_h_access: cross hext__ptw__cp_dside_gstage_lvl5_leaf_ptw_valid, hext__accesstype__cp_h_instr_2_lvl, 
                                                              hext__ptw__cp_dside_gstage_lvl5_leaf_ptw_read, hext__ptw__cp_dside_gstage_lvl5_leaf_ptw_exec,
                                                              hext__ptw__cp_dside_gstage_lvl5_leaf_ptw_access, hext__traps__cp_excp_def
    {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_load) && !binsof(hext__traps__cp_excp_def.guest_page_flt_store);
        bins d_guestpagefault_h_load_with_access_bit_zero       = binsof(hext__ptw__cp_dside_gstage_lvl5_leaf_ptw_valid) intersect {1} &&
                                                                binsof(hext__accesstype__cp_h_instr_2_lvl.h_loads) &&
                                                                binsof(hext__ptw__cp_dside_gstage_lvl5_leaf_ptw_read) intersect {1} &&
                                                                binsof(hext__ptw__cp_dside_gstage_lvl5_leaf_ptw_access) intersect {0};
        bins d_guestpagefault_h_loadx_with_access_bit_zero      = binsof(hext__ptw__cp_dside_gstage_lvl5_leaf_ptw_valid) intersect {1} &&
                                                                binsof(hext__accesstype__cp_h_instr_2_lvl.h_loads_x) &&
                                                                binsof(hext__ptw__cp_dside_gstage_lvl5_leaf_ptw_exec) intersect {1} &&
                                                                binsof(hext__ptw__cp_dside_gstage_lvl5_leaf_ptw_access) intersect {0};
    }

    hext__traps__cr_data_guestpagefault_lvl5_user: cross hext__ptw__cp_dside_gstage_lvl5_leaf_ptw_valid, hext__ptw__cp_dside_gstage_lvl5_leaf_ptw_user, 
                                                          hext__privilege__cp_dside_eff_privilege_mode, hext__csr__cp_vsstatus_sum, hext__traps__cp_excp_def
    {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_load) && !binsof(hext__traps__cp_excp_def.guest_page_flt_store);
        bins d_guestpagefault_in_v_user_mode_with_pte_u5_bit_zero= binsof(hext__ptw__cp_dside_gstage_lvl5_leaf_ptw_valid) intersect {1} &&
                                                               binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_user_due_to_mprv) &&
                                                               binsof(hext__ptw__cp_dside_gstage_lvl5_leaf_ptw_user) intersect {0};
        bins d_guestpagefault_in_v_super_mode_with_pte_u5_bit_zero= binsof(hext__ptw__cp_dside_gstage_lvl5_leaf_ptw_valid) intersect {1} &&
                                                               binsof(hext__ptw__cp_dside_gstage_lvl5_leaf_ptw_user) intersect {0} &&
                                                               binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_supervisor_due_to_mprv);
    }

    hext__traps__cr_data_guestpagefault_lvl5_leaf_pbmt: cross hext__ptw__cp_dside_gstage_lvl5_leaf_ptw_valid, hext__ptw__cp_dside_gstage_lvl5_leaf_pbmt, hext__traps__cp_excp_def
    {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_load) && !binsof(hext__traps__cp_excp_def.guest_page_flt_store);
        bins d_guestpagefault_due_to_leaf_pbmt                  = binsof(hext__ptw__cp_dside_gstage_lvl5_leaf_ptw_valid) intersect {1} && 
                                                                binsof(hext__ptw__cp_dside_gstage_lvl5_leaf_pbmt.pbmt_d_leaf_reserved);
    }

    hext__traps__cr_data_guestpagefault_lvl5_nonleaf_pbmt: cross hext__ptw__cp_dside_gstage_lvl5_nonleaf_ptw_valid, hext__ptw__cp_dside_gstage_lvl5_nonleaf_pbmt, hext__traps__cp_excp_def
    {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_load) && !binsof(hext__traps__cp_excp_def.guest_page_flt_store);
        bins d_guestpagefault_due_to_nonleaf_pbmt               = binsof(hext__ptw__cp_dside_gstage_lvl5_nonleaf_ptw_valid) intersect {1} && 
                                                                binsof(hext__ptw__cp_dside_gstage_lvl5_nonleaf_pbmt.pbmt_d_nonleaf_reserved);
    }

    hext__traps__cr_data_guestpagefault_lvl5_nonleaf_access: cross hext__ptw__cp_dside_gstage_lvl5_nonleaf_ptw_valid, hext__ptw__cp_dside_gstage_lvl5_nonleaf_ptw_access, hext__traps__cp_excp_def
    {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_load) && !binsof(hext__traps__cp_excp_def.guest_page_flt_store);
        bins d_guestpagefault_nonleaf_with_access            = binsof(hext__ptw__cp_dside_gstage_lvl5_nonleaf_ptw_valid) intersect {1} && 
                                                                binsof(hext__ptw__cp_dside_gstage_lvl5_nonleaf_ptw_access) intersect {1};
    }

    hext__traps__cr_data_guestpagefault_lvl5_nonleaf_dirty: cross hext__ptw__cp_dside_gstage_lvl5_nonleaf_ptw_valid, hext__ptw__cp_dside_gstage_lvl5_nonleaf_ptw_dirty, hext__traps__cp_excp_def
    {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_load) && !binsof(hext__traps__cp_excp_def.guest_page_flt_store);
        bins d_guestpagefault_nonleaf_with_dirty             = binsof(hext__ptw__cp_dside_gstage_lvl5_nonleaf_ptw_valid) intersect {1} && 
                                                                binsof(hext__ptw__cp_dside_gstage_lvl5_nonleaf_ptw_dirty) intersect {1};
    }

    hext__traps__cr_data_guestpagefault_lvl5_nonleaf_user: cross hext__ptw__cp_dside_gstage_lvl5_nonleaf_ptw_valid, hext__ptw__cp_dside_gstage_lvl5_nonleaf_ptw_user, hext__traps__cp_excp_def
    {
        option.cross_auto_bin_max   = 0;
        ignore_bins invalid = !binsof(hext__traps__cp_excp_def.guest_page_flt_load) && !binsof(hext__traps__cp_excp_def.guest_page_flt_store);
        bins d_guestpagefault_nonleaf_with_user              = binsof(hext__ptw__cp_dside_gstage_lvl5_nonleaf_ptw_valid) intersect {1} && 
                                                                binsof(hext__ptw__cp_dside_gstage_lvl5_nonleaf_ptw_user) intersect {1};
    }

    hext__pteattributes__cr_d_rwxu_leaf:  cross hext__ptw__cp_dside_leaf_ptw_read, hext__ptw__cp_dside_leaf_ptw_write, hext__ptw__cp_dside_leaf_ptw_exec, hext__ptw__cp_dside_leaf_ptw_user {
        ignore_bins invalid = binsof(hext__ptw__cp_dside_leaf_ptw_read) intersect {0} && binsof(hext__ptw__cp_dside_leaf_ptw_exec) intersect {0};
    }
    hext__pteattributes__cr_i_xu_leaf:    cross hext__ptw__cp_iside_leaf_ptw_exec, hext__ptw__cp_iside_leaf_ptw_user;
 
    hext__gpteattributes__cr_d_rwxu_leaf_gstage_lvl1:  cross hext__ptw__cp_dside_gstage_lvl1_leaf_ptw_read, hext__ptw__cp_dside_gstage_lvl1_leaf_ptw_write, hext__ptw__cp_dside_gstage_lvl1_leaf_ptw_exec, hext__ptw__cp_dside_gstage_lvl1_leaf_ptw_user {
        ignore_bins invalid = binsof(hext__ptw__cp_dside_gstage_lvl1_leaf_ptw_read) intersect {0} && binsof(hext__ptw__cp_dside_gstage_lvl1_leaf_ptw_exec) intersect {0};
    }
    hext__gpteattributes__cr_i_xu_leaf_gstage_lvl1:  cross hext__ptw__cp_iside_gstage_lvl1_leaf_ptw_exec, hext__ptw__cp_iside_gstage_lvl1_leaf_ptw_user;
    
    hext__gpteattributes__cr_d_rwxu_leaf_gstage_lvl2:  cross hext__ptw__cp_dside_gstage_lvl2_leaf_ptw_read, hext__ptw__cp_dside_gstage_lvl2_leaf_ptw_write, hext__ptw__cp_dside_gstage_lvl2_leaf_ptw_exec, hext__ptw__cp_dside_gstage_lvl2_leaf_ptw_user {
        ignore_bins invalid = binsof(hext__ptw__cp_dside_gstage_lvl2_leaf_ptw_read) intersect {0} && binsof(hext__ptw__cp_dside_gstage_lvl2_leaf_ptw_exec) intersect {0};
    }
    hext__gpteattributes__cr_i_xu_leaf_gstage_lvl2:  cross hext__ptw__cp_iside_gstage_lvl2_leaf_ptw_exec, hext__ptw__cp_iside_gstage_lvl2_leaf_ptw_user;
    
    hext__gpteattributes__cr_d_rwxu_leaf_gstage_lvl3:  cross hext__ptw__cp_dside_gstage_lvl3_leaf_ptw_read, hext__ptw__cp_dside_gstage_lvl3_leaf_ptw_write, hext__ptw__cp_dside_gstage_lvl3_leaf_ptw_exec, hext__ptw__cp_dside_gstage_lvl3_leaf_ptw_user {
        ignore_bins invalid = binsof(hext__ptw__cp_dside_gstage_lvl3_leaf_ptw_read) intersect {0} && binsof(hext__ptw__cp_dside_gstage_lvl3_leaf_ptw_exec) intersect {0};
    }
    hext__gpteattributes__cr_i_xu_leaf_gstage_lvl3:  cross hext__ptw__cp_iside_gstage_lvl3_leaf_ptw_exec, hext__ptw__cp_iside_gstage_lvl3_leaf_ptw_user;
    
    hext__gpteattributes__cr_d_rwxu_leaf_gstage_lvl4:  cross hext__ptw__cp_dside_gstage_lvl4_leaf_ptw_read, hext__ptw__cp_dside_gstage_lvl4_leaf_ptw_write, hext__ptw__cp_dside_gstage_lvl4_leaf_ptw_exec, hext__ptw__cp_dside_gstage_lvl4_leaf_ptw_user {
        ignore_bins invalid = binsof(hext__ptw__cp_dside_gstage_lvl4_leaf_ptw_read) intersect {0} && binsof(hext__ptw__cp_dside_gstage_lvl4_leaf_ptw_exec) intersect {0};
    }
    hext__gpteattributes__cr_i_xu_leaf_gstage_lvl4:  cross hext__ptw__cp_iside_gstage_lvl4_leaf_ptw_exec, hext__ptw__cp_iside_gstage_lvl4_leaf_ptw_user;
    
    hext__gpteattributes__cr_d_rwxu_leaf_gstage_lvl5:  cross hext__ptw__cp_dside_gstage_lvl5_leaf_ptw_read, hext__ptw__cp_dside_gstage_lvl5_leaf_ptw_write, hext__ptw__cp_dside_gstage_lvl5_leaf_ptw_exec, hext__ptw__cp_dside_gstage_lvl5_leaf_ptw_user {
        ignore_bins invalid = binsof(hext__ptw__cp_dside_gstage_lvl5_leaf_ptw_read) intersect {0} && binsof(hext__ptw__cp_dside_gstage_lvl5_leaf_ptw_exec) intersect {0};
    }
    hext__gpteattributes__cr_i_xu_leaf_gstage_lvl5:  cross hext__ptw__cp_iside_gstage_lvl5_leaf_ptw_exec, hext__ptw__cp_iside_gstage_lvl5_leaf_ptw_user;
    
    hext__ptw__cr_d_vsstatus_sum__bit_effect: cross hext__csr__cp_vsstatus_sum, hext__csr__cp_sstatus_sum, hext__csr__cp_mstatus_sum, 
                                                    hext__privilege__cp_dside_eff_privilege_mode, hext__ptw__cp_dside_leaf_ptw_user {
        option.cross_auto_bin_max   = 0;
        bins sum_effective_vsmode               = binsof(hext__csr__cp_vsstatus_sum) intersect {1} &&
                                                binsof(hext__csr__cp_sstatus_sum) intersect {0} &&
                                                binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_supervisor) &&
                                                binsof(hext__ptw__cp_dside_leaf_ptw_user) intersect {1};
        bins sum_non_effective_vsmode           = binsof(hext__csr__cp_vsstatus_sum) intersect {0} &&
                                                binsof(hext__csr__cp_sstatus_sum) intersect {0} &&
                                                binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_supervisor) &&
                                                binsof(hext__ptw__cp_dside_leaf_ptw_user) intersect {1};
        bins sum_effective_vsmode_mprv          = binsof(hext__csr__cp_vsstatus_sum) intersect {1} &&
                                                binsof(hext__csr__cp_mstatus_sum) intersect {0} &&
                                                binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_supervisor_due_to_mprv) &&
                                                binsof(hext__ptw__cp_dside_leaf_ptw_user) intersect {1};
        bins sum_non_effective_vsmode_mprv      = binsof(hext__csr__cp_vsstatus_sum) intersect {0} &&
                                                binsof(hext__csr__cp_mstatus_sum) intersect {0} &&
                                                binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_supervisor_due_to_mprv) &&
                                                binsof(hext__ptw__cp_dside_leaf_ptw_user) intersect {1};
    }

    hext__ptw__cr_d_vsstatus_mxr__bit_effect_vstage: cross hext__csr__cp_vsstatus_mxr, hext__csr__cp_sstatus_mxr, hext__csr__cp_mstatus_mxr,
                                                    hext__privilege__cp_dside_eff_privilege_mode, 
                                                    hext__ptw__cp_dside_leaf_ptw_read, hext__ptw__cp_dside_leaf_ptw_exec {
        option.cross_auto_bin_max   = 0;
        bins mxr_effective_virt                 = binsof(hext__csr__cp_vsstatus_mxr) intersect {1}  && 
                                                binsof(hext__csr__cp_sstatus_mxr) intersect {0} &&
                                                binsof(hext__ptw__cp_dside_leaf_ptw_read) intersect {0} &&
                                                binsof(hext__ptw__cp_dside_leaf_ptw_exec) intersect {1} &&
                                                (binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_supervisor) || 
                                                binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_user));
        bins mxr_effective_virt_mprv            = binsof(hext__csr__cp_vsstatus_mxr) intersect {1}  && 
                                                binsof(hext__csr__cp_mstatus_mxr) intersect {0} &&
                                                binsof(hext__ptw__cp_dside_leaf_ptw_read) intersect {0} &&
                                                binsof(hext__ptw__cp_dside_leaf_ptw_exec) intersect {1} &&
                                                (binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_supervisor_due_to_mprv) || 
                                                binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_user_due_to_mprv));
        bins mxr_non_effective_virt             = binsof(hext__csr__cp_vsstatus_mxr) intersect {0}  && 
                                                binsof(hext__csr__cp_sstatus_mxr) intersect {0} &&
                                                binsof(hext__ptw__cp_dside_leaf_ptw_read) intersect {0} &&
                                                binsof(hext__ptw__cp_dside_leaf_ptw_exec) intersect {1} &&
                                                (binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_supervisor) || 
                                                binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_user));
        bins mxr_non_effective_virt_mprv        = binsof(hext__csr__cp_vsstatus_mxr) intersect {0}  && 
                                                binsof(hext__csr__cp_mstatus_mxr) intersect {0} &&
                                                binsof(hext__ptw__cp_dside_leaf_ptw_read) intersect {0} &&
                                                binsof(hext__ptw__cp_dside_leaf_ptw_exec) intersect {1} &&
                                                (binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_supervisor_due_to_mprv) || 
                                                binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_user_due_to_mprv)); 
    }

    hext__ptw__cr_d_vsstatus_mxr__bit_effect_lvl1: cross hext__csr__cp_vsstatus_mxr, hext__csr__cp_sstatus_mxr, hext__csr__cp_mstatus_mxr,
                                                    hext__privilege__cp_dside_eff_privilege_mode, 
                                                    hext__ptw__cp_dside_gstage_lvl1_leaf_ptw_read, hext__ptw__cp_dside_gstage_lvl1_leaf_ptw_exec {
        option.cross_auto_bin_max   = 0;
        bins vs_mxr_effective_virt_lvl1         = binsof(hext__csr__cp_vsstatus_mxr) intersect {1}  && 
                                                binsof(hext__csr__cp_sstatus_mxr) intersect {0} &&
                                                binsof(hext__ptw__cp_dside_gstage_lvl1_leaf_ptw_read) intersect {0} &&
                                                binsof(hext__ptw__cp_dside_gstage_lvl1_leaf_ptw_exec) intersect {1} &&
                                                (binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_supervisor) || 
                                                binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_user));
        bins hs_mxr_effective_virt_lvl1         = binsof(hext__csr__cp_vsstatus_mxr) intersect {0}  && 
                                                binsof(hext__csr__cp_sstatus_mxr) intersect {1} &&
                                                binsof(hext__ptw__cp_dside_gstage_lvl1_leaf_ptw_read) intersect {0} &&
                                                binsof(hext__ptw__cp_dside_gstage_lvl1_leaf_ptw_exec) intersect {1} &&
                                                (binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_supervisor) || 
                                                binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_user));
        bins vs_mxr_effective_virt_mprv_lvl1    = binsof(hext__csr__cp_vsstatus_mxr) intersect {1}  && 
                                                binsof(hext__csr__cp_mstatus_mxr) intersect {0} &&
                                                binsof(hext__ptw__cp_dside_gstage_lvl1_leaf_ptw_read) intersect {0} &&
                                                binsof(hext__ptw__cp_dside_gstage_lvl1_leaf_ptw_exec) intersect {1} &&
                                                (binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_supervisor_due_to_mprv) || 
                                                binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_user_due_to_mprv));
        bins hs_mxr_effective_virt_mprv_lvl1    = binsof(hext__csr__cp_vsstatus_mxr) intersect {0}  && 
                                                binsof(hext__csr__cp_mstatus_mxr) intersect {1} &&
                                                binsof(hext__ptw__cp_dside_gstage_lvl1_leaf_ptw_read) intersect {0} &&
                                                binsof(hext__ptw__cp_dside_gstage_lvl1_leaf_ptw_exec) intersect {1} &&
                                                (binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_supervisor_due_to_mprv) || 
                                                binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_user_due_to_mprv));
        bins mxr_non_effective_virt_lvl1        = binsof(hext__csr__cp_vsstatus_mxr) intersect {0}  && 
                                                binsof(hext__csr__cp_sstatus_mxr) intersect {0} &&
                                                binsof(hext__ptw__cp_dside_gstage_lvl1_leaf_ptw_read) intersect {0} &&
                                                binsof(hext__ptw__cp_dside_gstage_lvl1_leaf_ptw_exec) intersect {1} &&
                                                (binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_supervisor) || 
                                                binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_user));
        bins mxr_non_effective_virt_mprv_lvl1   = binsof(hext__csr__cp_vsstatus_mxr) intersect {0}  && 
                                                binsof(hext__csr__cp_mstatus_mxr) intersect {0} &&
                                                binsof(hext__ptw__cp_dside_gstage_lvl1_leaf_ptw_read) intersect {0} &&
                                                binsof(hext__ptw__cp_dside_gstage_lvl1_leaf_ptw_exec) intersect {1} &&
                                                (binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_supervisor_due_to_mprv) || 
                                                binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_user_due_to_mprv));
    }

    hext__ptw__cr_d_vsstatus_mxr__bit_effect_lvl2: cross hext__csr__cp_vsstatus_mxr, hext__csr__cp_sstatus_mxr, hext__csr__cp_mstatus_mxr,
                                                    hext__privilege__cp_dside_eff_privilege_mode, 
                                                    hext__ptw__cp_dside_gstage_lvl2_leaf_ptw_read, hext__ptw__cp_dside_gstage_lvl2_leaf_ptw_exec {
        option.cross_auto_bin_max   = 0;
        bins vs_mxr_effective_virt_lvl2         = binsof(hext__csr__cp_vsstatus_mxr) intersect {1}  && 
                                                binsof(hext__csr__cp_sstatus_mxr) intersect {0} &&
                                                binsof(hext__ptw__cp_dside_gstage_lvl2_leaf_ptw_read) intersect {0} &&
                                                binsof(hext__ptw__cp_dside_gstage_lvl2_leaf_ptw_exec) intersect {1} &&
                                                (binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_supervisor) || 
                                                binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_user));
        bins hs_mxr_effective_virt_lvl2         = binsof(hext__csr__cp_vsstatus_mxr) intersect {0}  && 
                                                binsof(hext__csr__cp_sstatus_mxr) intersect {1} &&
                                                binsof(hext__ptw__cp_dside_gstage_lvl2_leaf_ptw_read) intersect {0} &&
                                                binsof(hext__ptw__cp_dside_gstage_lvl2_leaf_ptw_exec) intersect {1} &&
                                                (binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_supervisor) || 
                                                binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_user));
        bins vs_mxr_effective_virt_mprv_lvl2    = binsof(hext__csr__cp_vsstatus_mxr) intersect {1}  && 
                                                binsof(hext__csr__cp_mstatus_mxr) intersect {0} &&
                                                binsof(hext__ptw__cp_dside_gstage_lvl2_leaf_ptw_read) intersect {0} &&
                                                binsof(hext__ptw__cp_dside_gstage_lvl2_leaf_ptw_exec) intersect {1} &&
                                                (binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_supervisor_due_to_mprv) || 
                                                binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_user_due_to_mprv));
        bins hs_mxr_effective_virt_mprv_lvl2    = binsof(hext__csr__cp_vsstatus_mxr) intersect {0}  && 
                                                binsof(hext__csr__cp_mstatus_mxr) intersect {1} &&
                                                binsof(hext__ptw__cp_dside_gstage_lvl2_leaf_ptw_read) intersect {0} &&
                                                binsof(hext__ptw__cp_dside_gstage_lvl2_leaf_ptw_exec) intersect {1} &&
                                                (binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_supervisor_due_to_mprv) || 
                                                binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_user_due_to_mprv));
        bins mxr_non_effective_virt_lvl2        = binsof(hext__csr__cp_vsstatus_mxr) intersect {0}  && 
                                                binsof(hext__csr__cp_sstatus_mxr) intersect {0} &&
                                                binsof(hext__ptw__cp_dside_gstage_lvl2_leaf_ptw_read) intersect {0} &&
                                                binsof(hext__ptw__cp_dside_gstage_lvl2_leaf_ptw_exec) intersect {1} &&
                                                (binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_supervisor) || 
                                                binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_user));
        bins mxr_non_effective_virt_mprv_lvl2   = binsof(hext__csr__cp_vsstatus_mxr) intersect {0}  && 
                                                binsof(hext__csr__cp_mstatus_mxr) intersect {0} &&
                                                binsof(hext__ptw__cp_dside_gstage_lvl2_leaf_ptw_read) intersect {0} &&
                                                binsof(hext__ptw__cp_dside_gstage_lvl2_leaf_ptw_exec) intersect {1} &&
                                                (binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_supervisor_due_to_mprv) || 
                                                binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_user_due_to_mprv));
    }

    hext__ptw__cr_d_vsstatus_mxr__bit_effect_lvl3: cross hext__csr__cp_vsstatus_mxr, hext__csr__cp_sstatus_mxr, hext__csr__cp_mstatus_mxr,
                                                    hext__privilege__cp_dside_eff_privilege_mode, 
                                                    hext__ptw__cp_dside_gstage_lvl3_leaf_ptw_read, hext__ptw__cp_dside_gstage_lvl3_leaf_ptw_exec {
        option.cross_auto_bin_max   = 0;
        bins vs_mxr_effective_virt_lvl3         = binsof(hext__csr__cp_vsstatus_mxr) intersect {1}  && 
                                                binsof(hext__csr__cp_sstatus_mxr) intersect {0} &&
                                                binsof(hext__ptw__cp_dside_gstage_lvl3_leaf_ptw_read) intersect {0} &&
                                                binsof(hext__ptw__cp_dside_gstage_lvl3_leaf_ptw_exec) intersect {1} &&
                                                (binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_supervisor) || 
                                                binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_user));
        bins hs_mxr_effective_virt_lvl3         = binsof(hext__csr__cp_vsstatus_mxr) intersect {0}  && 
                                                binsof(hext__csr__cp_sstatus_mxr) intersect {1} &&
                                                binsof(hext__ptw__cp_dside_gstage_lvl3_leaf_ptw_read) intersect {0} &&
                                                binsof(hext__ptw__cp_dside_gstage_lvl3_leaf_ptw_exec) intersect {1} &&
                                                (binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_supervisor) || 
                                                binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_user));
        bins vs_mxr_effective_virt_mprv_lvl3    = binsof(hext__csr__cp_vsstatus_mxr) intersect {1}  && 
                                                binsof(hext__csr__cp_mstatus_mxr) intersect {0} &&
                                                binsof(hext__ptw__cp_dside_gstage_lvl3_leaf_ptw_read) intersect {0} &&
                                                binsof(hext__ptw__cp_dside_gstage_lvl3_leaf_ptw_exec) intersect {1} &&
                                                (binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_supervisor_due_to_mprv) || 
                                                binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_user_due_to_mprv));
        bins hs_mxr_effective_virt_mprv_lvl3    = binsof(hext__csr__cp_vsstatus_mxr) intersect {0}  && 
                                                binsof(hext__csr__cp_mstatus_mxr) intersect {1} &&
                                                binsof(hext__ptw__cp_dside_gstage_lvl3_leaf_ptw_read) intersect {0} &&
                                                binsof(hext__ptw__cp_dside_gstage_lvl3_leaf_ptw_exec) intersect {1} &&
                                                (binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_supervisor_due_to_mprv) || 
                                                binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_user_due_to_mprv));
        bins mxr_non_effective_virt_lvl3        = binsof(hext__csr__cp_vsstatus_mxr) intersect {0}  && 
                                                binsof(hext__csr__cp_sstatus_mxr) intersect {0} &&
                                                binsof(hext__ptw__cp_dside_gstage_lvl3_leaf_ptw_read) intersect {0} &&
                                                binsof(hext__ptw__cp_dside_gstage_lvl3_leaf_ptw_exec) intersect {1} &&
                                                (binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_supervisor) || 
                                                binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_user));
        bins mxr_non_effective_virt_mprv_lvl3   = binsof(hext__csr__cp_vsstatus_mxr) intersect {0}  && 
                                                binsof(hext__csr__cp_mstatus_mxr) intersect {0} &&
                                                binsof(hext__ptw__cp_dside_gstage_lvl3_leaf_ptw_read) intersect {0} &&
                                                binsof(hext__ptw__cp_dside_gstage_lvl3_leaf_ptw_exec) intersect {1} &&
                                                (binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_supervisor_due_to_mprv) || 
                                                binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_user_due_to_mprv));
    }

    hext__ptw__cr_d_vsstatus_mxr__bit_effect_lvl4: cross hext__csr__cp_vsstatus_mxr, hext__csr__cp_sstatus_mxr, hext__csr__cp_mstatus_mxr,
                                                    hext__privilege__cp_dside_eff_privilege_mode, 
                                                    hext__ptw__cp_dside_gstage_lvl4_leaf_ptw_read, hext__ptw__cp_dside_gstage_lvl4_leaf_ptw_exec {
        option.cross_auto_bin_max   = 0;
        bins vs_mxr_effective_virt_lvl4         = binsof(hext__csr__cp_vsstatus_mxr) intersect {1}  && 
                                                binsof(hext__csr__cp_sstatus_mxr) intersect {0} &&
                                                binsof(hext__ptw__cp_dside_gstage_lvl4_leaf_ptw_read) intersect {0} &&
                                                binsof(hext__ptw__cp_dside_gstage_lvl4_leaf_ptw_exec) intersect {1} &&
                                                (binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_supervisor) || 
                                                binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_user));
        bins hs_mxr_effective_virt_lvl4         = binsof(hext__csr__cp_vsstatus_mxr) intersect {0}  && 
                                                binsof(hext__csr__cp_sstatus_mxr) intersect {1} &&
                                                binsof(hext__ptw__cp_dside_gstage_lvl4_leaf_ptw_read) intersect {0} &&
                                                binsof(hext__ptw__cp_dside_gstage_lvl4_leaf_ptw_exec) intersect {1} &&
                                                (binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_supervisor) || 
                                                binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_user));
        bins vs_mxr_effective_virt_mprv_lvl4    = binsof(hext__csr__cp_vsstatus_mxr) intersect {1}  && 
                                                binsof(hext__csr__cp_mstatus_mxr) intersect {0} &&
                                                binsof(hext__ptw__cp_dside_gstage_lvl4_leaf_ptw_read) intersect {0} &&
                                                binsof(hext__ptw__cp_dside_gstage_lvl4_leaf_ptw_exec) intersect {1} &&
                                                (binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_supervisor_due_to_mprv) || 
                                                binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_user_due_to_mprv));
        bins hs_mxr_effective_virt_mprv_lvl4    = binsof(hext__csr__cp_vsstatus_mxr) intersect {0}  && 
                                                binsof(hext__csr__cp_mstatus_mxr) intersect {1} &&
                                                binsof(hext__ptw__cp_dside_gstage_lvl4_leaf_ptw_read) intersect {0} &&
                                                binsof(hext__ptw__cp_dside_gstage_lvl4_leaf_ptw_exec) intersect {1} &&
                                                (binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_supervisor_due_to_mprv) || 
                                                binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_user_due_to_mprv));
        bins mxr_non_effective_virt_lvl4        = binsof(hext__csr__cp_vsstatus_mxr) intersect {0}  && 
                                                binsof(hext__csr__cp_sstatus_mxr) intersect {0} &&
                                                binsof(hext__ptw__cp_dside_gstage_lvl4_leaf_ptw_read) intersect {0} &&
                                                binsof(hext__ptw__cp_dside_gstage_lvl4_leaf_ptw_exec) intersect {1} &&
                                                (binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_supervisor) || 
                                                binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_user));
        bins mxr_non_effective_virt_mprv_lvl4   = binsof(hext__csr__cp_vsstatus_mxr) intersect {0}  && 
                                                binsof(hext__csr__cp_mstatus_mxr) intersect {0} &&
                                                binsof(hext__ptw__cp_dside_gstage_lvl4_leaf_ptw_read) intersect {0} &&
                                                binsof(hext__ptw__cp_dside_gstage_lvl4_leaf_ptw_exec) intersect {1} &&
                                                (binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_supervisor_due_to_mprv) || 
                                                binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_user_due_to_mprv));
    }

    hext__ptw__cr_d_vsstatus_mxr__bit_effect_lvl5: cross hext__csr__cp_vsstatus_mxr, hext__csr__cp_sstatus_mxr, hext__csr__cp_mstatus_mxr,
                                                    hext__privilege__cp_dside_eff_privilege_mode, 
                                                    hext__ptw__cp_dside_gstage_lvl5_leaf_ptw_read, hext__ptw__cp_dside_gstage_lvl5_leaf_ptw_exec {
        option.cross_auto_bin_max   = 0;
        ignore_bins vs_mxr_effective_virt_lvl5         = binsof(hext__csr__cp_vsstatus_mxr) intersect {1}  && 
                                                binsof(hext__csr__cp_sstatus_mxr) intersect {0} &&
                                                binsof(hext__ptw__cp_dside_gstage_lvl5_leaf_ptw_read) intersect {0} &&
                                                binsof(hext__ptw__cp_dside_gstage_lvl5_leaf_ptw_exec) intersect {1} &&
                                                (binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_supervisor) || 
                                                binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_user));
        ignore_bins hs_mxr_effective_virt_lvl5         = binsof(hext__csr__cp_vsstatus_mxr) intersect {0}  && 
                                                binsof(hext__csr__cp_sstatus_mxr) intersect {1} &&
                                                binsof(hext__ptw__cp_dside_gstage_lvl5_leaf_ptw_read) intersect {0} &&
                                                binsof(hext__ptw__cp_dside_gstage_lvl5_leaf_ptw_exec) intersect {1} &&
                                                (binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_supervisor) || 
                                                binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_user));
        bins vs_mxr_effective_virt_mprv_lvl5    = binsof(hext__csr__cp_vsstatus_mxr) intersect {1}  && 
                                                binsof(hext__csr__cp_mstatus_mxr) intersect {0} &&
                                                binsof(hext__ptw__cp_dside_gstage_lvl5_leaf_ptw_read) intersect {0} &&
                                                binsof(hext__ptw__cp_dside_gstage_lvl5_leaf_ptw_exec) intersect {1} &&
                                                (binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_supervisor_due_to_mprv) || 
                                                binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_user_due_to_mprv));
        bins hs_mxr_effective_virt_mprv_lvl5    = binsof(hext__csr__cp_vsstatus_mxr) intersect {0}  && 
                                                binsof(hext__csr__cp_mstatus_mxr) intersect {1} &&
                                                binsof(hext__ptw__cp_dside_gstage_lvl5_leaf_ptw_read) intersect {0} &&
                                                binsof(hext__ptw__cp_dside_gstage_lvl5_leaf_ptw_exec) intersect {1} &&
                                                (binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_supervisor_due_to_mprv) || 
                                                binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_user_due_to_mprv));
        ignore_bins mxr_non_effective_virt_lvl5        = binsof(hext__csr__cp_vsstatus_mxr) intersect {0}  && 
                                                binsof(hext__csr__cp_sstatus_mxr) intersect {0} &&
                                                binsof(hext__ptw__cp_dside_gstage_lvl5_leaf_ptw_read) intersect {0} &&
                                                binsof(hext__ptw__cp_dside_gstage_lvl5_leaf_ptw_exec) intersect {1} &&
                                                (binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_supervisor) || 
                                                binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_user));
        bins mxr_non_effective_virt_mprv_lvl5   = binsof(hext__csr__cp_vsstatus_mxr) intersect {0}  && 
                                                binsof(hext__csr__cp_mstatus_mxr) intersect {0} &&
                                                binsof(hext__ptw__cp_dside_gstage_lvl5_leaf_ptw_read) intersect {0} &&
                                                binsof(hext__ptw__cp_dside_gstage_lvl5_leaf_ptw_exec) intersect {1} &&
                                                (binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_supervisor_due_to_mprv) || 
                                                binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_user_due_to_mprv));
    }

    hext__ptw__cr_i_leaf_nonglobal_nonleaf_global: cross hext__gen__cp_curpriv, hext__ptw__cp_iside_leaf_ptw_global, hext__ptw__cp_iside_nonleaf_ptw_global {
        option.cross_auto_bin_max   = 0;
        bins leaf_nonglobal_and_nonleaf_global = binsof(hext__ptw__cp_iside_leaf_ptw_global) intersect {0} &&
                                                binsof(hext__ptw__cp_iside_nonleaf_ptw_global) intersect {1} &&
                                                (binsof(hext__gen__cp_curpriv.vsmode) || binsof(hext__gen__cp_curpriv.vumode));
        bins leaf_nonglobal_and_nonleaf_nonglobal = binsof(hext__ptw__cp_iside_leaf_ptw_global) intersect {0} &&
                                                binsof(hext__ptw__cp_iside_nonleaf_ptw_global) intersect {0} &&
                                                (binsof(hext__gen__cp_curpriv.vsmode) || binsof(hext__gen__cp_curpriv.vumode));
        bins leaf_global_and_nonleaf_any        = binsof(hext__ptw__cp_iside_leaf_ptw_global) intersect {1} &&
                                                binsof(hext__ptw__cp_iside_nonleaf_ptw_global) &&
                                                (binsof(hext__gen__cp_curpriv.vsmode) || binsof(hext__gen__cp_curpriv.vumode));                                                                 
    }

    hext__ptw__cr_d_leaf_nonglobal_nonleaf_global: cross hext__gen__cp_curpriv, hext__ptw__cp_dside_leaf_ptw_global, hext__ptw__cp_dside_nonleaf_ptw_global {
        option.cross_auto_bin_max   = 0;
        bins leaf_nonglobal_and_nonleaf_global = binsof(hext__ptw__cp_dside_leaf_ptw_global) intersect {0} &&
                                                binsof(hext__ptw__cp_dside_nonleaf_ptw_global) intersect {1} &&
                                                (binsof(hext__gen__cp_curpriv.vsmode) || binsof(hext__gen__cp_curpriv.vumode));
        bins leaf_nonglobal_and_nonleaf_nonglobal = binsof(hext__ptw__cp_dside_leaf_ptw_global) intersect {0} &&
                                                binsof(hext__ptw__cp_dside_nonleaf_ptw_global) intersect {0} &&
                                                (binsof(hext__gen__cp_curpriv.vsmode) || binsof(hext__gen__cp_curpriv.vumode));
        bins leaf_global_and_nonleaf_any        = binsof(hext__ptw__cp_dside_leaf_ptw_global) intersect {1} &&
                                                binsof(hext__ptw__cp_dside_nonleaf_ptw_global) &&
                                                (binsof(hext__gen__cp_curpriv.vsmode) || binsof(hext__gen__cp_curpriv.vumode));                                                                 
    }

    hext__ptw__cr_illegal_pc_bare: cross  hext__ptw__cp_virtual_pc_bitsel_signextbits_baremode, hext__vsatp__cp_modes {
        option.cross_auto_bin_max   = 0;
        bins illegal_pc_baremode = binsof(hext__ptw__cp_virtual_pc_bitsel_signextbits_baremode) && 
                                   binsof(hext__vsatp__cp_modes.legal_vsatp_bare_mode);
    } 
    hext__ptw__cr_illegal_pc_sv39: cross  hext__ptw__cp_virtual_pc_bitsel_signextbits_sv39, hext__vsatp__cp_modes {
        option.cross_auto_bin_max   = 0;
        bins illegal_pc_non_baremode = binsof(hext__ptw__cp_virtual_pc_bitsel_signextbits_sv39) && 
                                       binsof(hext__vsatp__cp_modes.legal_vsatp_modes) intersect {8};
    }
    hext__ptw__cr_illegal_pc_sv48: cross  hext__ptw__cp_virtual_pc_bitsel_signextbits_sv48, hext__vsatp__cp_modes {
        option.cross_auto_bin_max   = 0;
        bins illegal_pc_non_baremode = binsof(hext__ptw__cp_virtual_pc_bitsel_signextbits_sv48) && 
                                       binsof(hext__vsatp__cp_modes.legal_vsatp_modes) intersect {9};
    }
    hext__ptw__cr_illegal_pc_sv57: cross  hext__ptw__cp_virtual_pc_bitsel_signextbits_sv57, hext__vsatp__cp_modes {
        option.cross_auto_bin_max   = 0;
        bins illegal_pc_non_baremode = binsof(hext__ptw__cp_virtual_pc_bitsel_signextbits_sv57) && 
                                       binsof(hext__vsatp__cp_modes.legal_vsatp_modes) intersect {10};
    }

    hext__ptw__cr_illegal_ldstaddr_bare: cross  hext__ptw__cp_virtual_ldst_bitsel_signextbits_baremode, hext__vsatp__cp_modes {
        option.cross_auto_bin_max   = 0;
        bins illegal_pc_non_baremode = binsof(hext__ptw__cp_virtual_ldst_bitsel_signextbits_baremode) && 
                                       binsof(hext__vsatp__cp_modes.legal_vsatp_bare_mode);
    }
    hext__ptw__cr_illegal_ldstaddr_sv39: cross  hext__ptw__cp_virtual_ldst_bitsel_signextbits_sv39, hext__vsatp__cp_modes {
        option.cross_auto_bin_max   = 0;
        bins illegal_pc_non_baremode = binsof(hext__ptw__cp_virtual_ldst_bitsel_signextbits_sv39) && 
                                       binsof(hext__vsatp__cp_modes.legal_vsatp_modes) intersect {8};
    }
    hext__ptw__cr_illegal_ldstaddr_sv48: cross   hext__ptw__cp_virtual_ldst_bitsel_signextbits_sv48, hext__vsatp__cp_modes {
        option.cross_auto_bin_max   = 0;
        bins illegal_pc_non_baremode = binsof( hext__ptw__cp_virtual_ldst_bitsel_signextbits_sv48) && 
                                       binsof(hext__vsatp__cp_modes.legal_vsatp_modes) intersect {9};
    }
    hext__ptw__cr_illegal_ldstaddr_sv57: cross   hext__ptw__cp_virtual_ldst_bitsel_signextbits_sv57, hext__vsatp__cp_modes {
        option.cross_auto_bin_max   = 0;
        bins illegal_pc_non_baremode = binsof( hext__ptw__cp_virtual_ldst_bitsel_signextbits_sv57) && 
                                       binsof(hext__vsatp__cp_modes.legal_vsatp_modes) intersect {10};
    }

    hext__tlbinvl__cp_sfence_instr: coverpoint instrenum_var iff ((privilegemode_var == PRIVILEGEMODE_SUPERVISOR) && (VirtualMode == 1) && (prev_hstatus_csr[20] == 0)){ 
        bins sfence_instr          = {INSTRENUM_SFENCE_VMA, INSTRENUM_SINVAL_VMA}; 
    }
    
    hext__tlbinvl__cp_hfence_vvma_instr: coverpoint instrenum_var { 
        bins hfence_vvma_instr_m         = {INSTRENUM_HFENCE_VVMA, INSTRENUM_HINVAL_VVMA} iff (privilegemode_var == PRIVILEGEMODE_MACHINE); 
        bins hfence_vvma_instr_hs        = {INSTRENUM_HFENCE_VVMA, INSTRENUM_HINVAL_VVMA} iff ((privilegemode_var == PRIVILEGEMODE_SUPERVISOR) && (VirtualMode == 0)); 
    }

    hext__tlbinvl__cp_hfence_gvma_instr: coverpoint instrenum_var { 
        bins hfence_gvma_instr_m         = {INSTRENUM_HFENCE_GVMA, INSTRENUM_HINVAL_GVMA} iff (privilegemode_var == PRIVILEGEMODE_MACHINE); 
        bins hfence_gvma_instr_hs        = {INSTRENUM_HFENCE_GVMA, INSTRENUM_HINVAL_GVMA} iff ((privilegemode_var == PRIVILEGEMODE_SUPERVISOR) && (VirtualMode == 0) && (prev_mstatus_csr[20] == 0)); 
    }

    hext__tlbinvl__cp_xfence_rs1: coverpoint rd {
		bins int_source_bin_x0 = {0};
		bins int_source_bin_not_x0 = {[1:31]};
	}
	hext__tlbinvl__cp_xfence_rs2: coverpoint rs1 {
		bins int_source_bin_x0 = {0};
		bins int_source_bin_not_x0 = {[1:31]};
	}

    hext__tlbinvl__cr_sfence_in_all_page_modes: cross  hext__tlbinvl__cp_sfence_instr, hext__vsatp__cp_modes {
        option.cross_auto_bin_max   = 0;
        bins sfence_in_bare_mode = binsof(hext__vsatp__cp_modes) intersect {0};
        bins sfence_in_sv39_mode = binsof(hext__vsatp__cp_modes) intersect {8};
        bins sfence_in_sv48_mode = binsof(hext__vsatp__cp_modes) intersect {9};
        bins sfence_in_sv57_mode = binsof(hext__vsatp__cp_modes) intersect {10};  
    }

    hext__tlbinvl__cr_sfence_all_types: cross hext__tlbinvl__cp_xfence_rs1, hext__tlbinvl__cp_xfence_rs2, hext__tlbinvl__cp_sfence_instr;
    hext__tlbinvl__cr_sfence_all_types_same_vsatp_asid: cross hext__tlbinvl__cp_xfence_rs2, hext__tlbinvl__cp_sfence_instr iff (rs1_val == prev_vsatp_csr[59:44]) {
        ignore_bins ignore_rs2_x0 = binsof(hext__tlbinvl__cp_xfence_rs2.int_source_bin_x0);
    }
    hext__tlbinvl__cr_sfence_all_types_diff_vsatp_asid: cross hext__tlbinvl__cp_xfence_rs2, hext__tlbinvl__cp_sfence_instr iff (rs1_val != prev_vsatp_csr[59:44]) {
        ignore_bins ignore_rs2_x0 = binsof(hext__tlbinvl__cp_xfence_rs2.int_source_bin_x0);
    }

    hext__tlbinvl__cr_hfence_vvma_in_all_page_modes: cross  hext__tlbinvl__cp_hfence_vvma_instr, hext__vsatp__cp_modes {
        option.cross_auto_bin_max   = 0;
        bins hfence_vvma_in_bare_mode = binsof(hext__vsatp__cp_modes) intersect {0};
        bins hfence_vvma_in_sv39_mode = binsof(hext__vsatp__cp_modes) intersect {8};
        bins hfence_vvma_in_sv48_mode = binsof(hext__vsatp__cp_modes) intersect {9};
        bins hfence_vvma_in_sv57_mode = binsof(hext__vsatp__cp_modes) intersect {10};  
    }

    hext__tlbinvl__cr_hfence_gvma_in_all_page_modes: cross  hext__tlbinvl__cp_hfence_gvma_instr, hext__hgatp__cp_modes {
        option.cross_auto_bin_max   = 0;
        bins hfence_gvma_in_bare_mode = binsof(hext__hgatp__cp_modes) intersect {0};
        bins hfence_gvma_in_sv39_mode = binsof(hext__hgatp__cp_modes) intersect {8};
        bins hfence_gvma_in_sv48_mode = binsof(hext__hgatp__cp_modes) intersect {9};
        bins hfence_gvma_in_sv57_mode = binsof(hext__hgatp__cp_modes) intersect {10};  
    }

    hext__tlbinvl__cr_hfence_vvma_all_types: cross hext__tlbinvl__cp_xfence_rs1, hext__tlbinvl__cp_xfence_rs2, hext__tlbinvl__cp_hfence_vvma_instr;
    hext__tlbinvl__cr_hfence_vvma_same_vsatp_asid: cross hext__tlbinvl__cp_xfence_rs2, hext__tlbinvl__cp_hfence_vvma_instr iff (rs1_val == prev_vsatp_csr[59:44]) {
        ignore_bins ignore_rs2_x0 = binsof(hext__tlbinvl__cp_xfence_rs2.int_source_bin_x0);
    }
    hext__tlbinvl__cr_hfence_vvma_diff_vsatp_asid: cross hext__tlbinvl__cp_xfence_rs2, hext__tlbinvl__cp_hfence_vvma_instr iff (rs1_val != prev_vsatp_csr[59:44]) {
        ignore_bins ignore_rs2_x0 = binsof(hext__tlbinvl__cp_xfence_rs2.int_source_bin_x0);
    }

    
    hext__tlbinvl__cr_hfence_gvma_all_types: cross hext__tlbinvl__cp_xfence_rs1, hext__tlbinvl__cp_xfence_rs2, hext__tlbinvl__cp_hfence_gvma_instr;
    hext__tlbinvl__cr_hfence_gvma_same_hgatp_vmid: cross hext__tlbinvl__cp_xfence_rs2, hext__tlbinvl__cp_hfence_gvma_instr iff (rs1_val == prev_hgatp_csr[57:44]) {
        ignore_bins ignore_rs2_x0 = binsof(hext__tlbinvl__cp_xfence_rs2.int_source_bin_x0);
    }
    hext__tlbinvl__cr_hfence_gvma_diff_hgatp_vmid: cross hext__tlbinvl__cp_xfence_rs2, hext__tlbinvl__cp_hfence_gvma_instr iff (rs1_val != prev_hgatp_csr[57:44]) {
        ignore_bins ignore_rs2_x0 = binsof(hext__tlbinvl__cp_xfence_rs2.int_source_bin_x0);
    }

    hext__paging__cp_adupdate_gstage_lvl5_dpte: coverpoint DPTE_LeafADUpdate_GStageLevel5{     
        bins ad00        = {0};
        bins ad11        = {3};
    }
    hext__paging__cp_adupdate_gstage_lvl4_dpte: coverpoint DPTE_LeafADUpdate_GStageLevel4{   
        bins ad00        = {0};
        bins ad11        = {3};
    }
    hext__paging__cp_adupdate_gstage_lvl3_dpte: coverpoint DPTE_LeafADUpdate_GStageLevel3{      
        bins ad00        = {0};
        bins ad11        = {3};
    }
    hext__paging__cp_adupdate_gstage_lvl2_dpte: coverpoint DPTE_LeafADUpdate_GStageLevel2{      
        bins ad00        = {0};
        bins ad11        = {3};
    }
    hext__paging__cp_adupdate_gstage_lvl1_dpte: coverpoint DPTE_LeafADUpdate_GStageLevel1{      
        bins ad00        = {0};
        bins ad11        = {3};
    }

    hext__privilege__cp_dside_eff_privilege_mode_hext_instr_ad: cross hext__gen__cp_curpriv, hext__csr__cp_hstatus_spvp, hext__csr__cp_hstatus_hu {
        option.cross_auto_bin_max                               = 0;
        bins eff_vs = binsof(hext__csr__cp_hstatus_spvp.spvp_high) && (binsof(hext__gen__cp_curpriv.mmode) || binsof(hext__gen__cp_curpriv.hsmode) || (binsof(hext__gen__cp_curpriv.umode) && binsof(hext__csr__cp_hstatus_hu.hu_high)));
        bins eff_vu = binsof(hext__csr__cp_hstatus_spvp.spvp_low) && (binsof(hext__gen__cp_curpriv.mmode) || binsof(hext__gen__cp_curpriv.hsmode) || (binsof(hext__gen__cp_curpriv.umode) && binsof(hext__csr__cp_hstatus_hu.hu_high)));
    }

    hext__paging__cr_dside_gstage_lvl5_leaf_ptw_adupdate       : cross hext__privilege__cp_dside_eff_privilege_mode_hext_instr_ad, hext__paging__cp_adupdate_gstage_lvl5_dpte,hext__pagesize__cp_dside_gstagelevel5_paginglevel;

    hext__paging__cr_dside_gstage_lvl4_leaf_ptw_adupdate       : cross hext__privilege__cp_dside_eff_privilege_mode, hext__paging__cp_adupdate_gstage_lvl4_dpte,hext__pagesize__cp_dside_gstagelevel4_paginglevel{
        ignore_bins non_virt_mode =   !binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_supervisor)  &&  !binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_supervisor_due_to_mprv) &&
                                      !binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_user) && !binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_user_due_to_mprv);
    }
    hext__paging__cr_dside_gstage_lvl3_leaf_ptw_adupdate       : cross hext__privilege__cp_dside_eff_privilege_mode, hext__paging__cp_adupdate_gstage_lvl3_dpte,hext__pagesize__cp_dside_gstagelevel3_paginglevel{
        ignore_bins non_virt_mode =   !binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_supervisor)  &&  !binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_supervisor_due_to_mprv) &&
                                      !binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_user) && !binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_user_due_to_mprv);
    }
    hext__paging__cr_dside_gstage_lvl2_leaf_ptw_adupdate       : cross hext__privilege__cp_dside_eff_privilege_mode, hext__paging__cp_adupdate_gstage_lvl2_dpte,hext__pagesize__cp_dside_gstagelevel2_paginglevel{
        ignore_bins non_virt_mode =   !binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_supervisor)  &&  !binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_supervisor_due_to_mprv) &&
                                      !binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_user) && !binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_user_due_to_mprv);
    }
    hext__paging__cr_dside_gstage_lvl1_leaf_ptw_adupdate       : cross hext__privilege__cp_dside_eff_privilege_mode, hext__paging__cp_adupdate_gstage_lvl1_dpte,hext__pagesize__cp_dside_gstagelevel1_paginglevel{
        ignore_bins non_virt_mode =   !binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_supervisor)  &&  !binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_supervisor_due_to_mprv) &&
                                      !binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_user) && !binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_user_due_to_mprv);
    }
    
    hext__paging__cp_adupdate_vstage_lvl5_dvpte: coverpoint DVPTE_ADUpdate_Level5 iff (dvpagesize_var == DVPAGESIZE_256T){
        bins ad00        = {0};
        bins ad01        = {1};
        bins ad10        = {2};
        bins ad11        = {3};
    }
    hext__paging__cp_adupdate_vstage_lvl4_dvpte: coverpoint DVPTE_ADUpdate_Level4 iff (dvpagesize_var == DVPAGESIZE_512G){
        bins ad00        = {0};
        bins ad01        = {1};
        bins ad10        = {2};
        bins ad11        = {3};
    }
    hext__paging__cp_adupdate_vstage_lvl3_dvpte: coverpoint DVPTE_ADUpdate_Level3 iff (dvpagesize_var == DVPAGESIZE_1G){
        bins ad00        = {0};
        bins ad01        = {1};
        bins ad10        = {2};
        bins ad11        = {3};
    }
    hext__paging__cp_adupdate_vstage_lvl2_dvpte: coverpoint DVPTE_ADUpdate_Level2 iff (dvpagesize_var == DVPAGESIZE_2M){
        bins ad00        = {0};
        bins ad01        = {1};
        bins ad10        = {2};
        bins ad11        = {3};
    }
    hext__paging__cp_adupdate_vstage_lvl1_dvpte: coverpoint DVPTE_ADUpdate_Level1 iff (dvpagesize_var == DVPAGESIZE_4K){
        bins ad00        = {0};
        bins ad01        = {1};
        bins ad10        = {2};
        bins ad11        = {3};
    }

    hext__paging__cr_dside_vstage_lvl5_leaf_ptw_adupdate       : cross hext__privilege__cp_dside_eff_privilege_mode, hext__paging__cp_adupdate_vstage_lvl5_dvpte{
        ignore_bins non_virt_mode =   !binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_supervisor)  &&  !binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_supervisor_due_to_mprv) &&
                                      !binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_user) && !binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_user_due_to_mprv);
    }
    hext__paging__cr_dside_vstage_lvl4_leaf_ptw_adupdate       : cross hext__privilege__cp_dside_eff_privilege_mode, hext__paging__cp_adupdate_vstage_lvl4_dvpte{
        ignore_bins non_virt_mode =   !binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_supervisor)  &&  !binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_supervisor_due_to_mprv) &&
                                      !binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_user) && !binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_user_due_to_mprv);
    }
    hext__paging__cr_dside_vstage_lvl3_leaf_ptw_adupdate       : cross hext__privilege__cp_dside_eff_privilege_mode, hext__paging__cp_adupdate_vstage_lvl3_dvpte{
        ignore_bins non_virt_mode =   !binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_supervisor)  &&  !binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_supervisor_due_to_mprv) &&
                                      !binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_user) && !binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_user_due_to_mprv);
    }
    hext__paging__cr_dside_vstage_lvl2_leaf_ptw_adupdate       : cross hext__privilege__cp_dside_eff_privilege_mode, hext__paging__cp_adupdate_vstage_lvl2_dvpte{
        ignore_bins non_virt_mode =   !binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_supervisor)  &&  !binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_supervisor_due_to_mprv) &&
                                      !binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_user) && !binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_user_due_to_mprv);
    }
    hext__paging__cr_dside_vstage_lvl1_leaf_ptw_adupdate       : cross hext__privilege__cp_dside_eff_privilege_mode, hext__paging__cp_adupdate_vstage_lvl1_dvpte{
        ignore_bins non_virt_mode =   !binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_supervisor)  &&  !binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_supervisor_due_to_mprv) &&
                                      !binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_user) && !binsof(hext__privilege__cp_dside_eff_privilege_mode.effective_priv_virtual_user_due_to_mprv);
    }

    hext__paging__cp_adupdate_vstage_lvl5_fvpte: coverpoint FVPTE_ADUpdate_Level5 iff (fvpagesize_var == FVPAGESIZE_256T){
        bins ad00        = {0};
        bins ad10        = {2};
    }
    hext__paging__cp_adupdate_vstage_lvl4_fvpte: coverpoint FVPTE_ADUpdate_Level4 iff (fvpagesize_var == FVPAGESIZE_512G){
        bins ad00        = {0};
        bins ad10        = {2};
    }
    hext__paging__cp_adupdate_vstage_lvl3_fvpte: coverpoint FVPTE_ADUpdate_Level3 iff (fvpagesize_var == FVPAGESIZE_1G){
        bins ad00        = {0};
        bins ad10        = {2};
    }
    hext__paging__cp_adupdate_vstage_lvl2_fvpte: coverpoint FVPTE_ADUpdate_Level2 iff (fvpagesize_var == FVPAGESIZE_2M){
        bins ad00        = {0};
        bins ad10        = {2};
    }
    hext__paging__cp_adupdate_vstage_lvl1_fvpte: coverpoint FVPTE_ADUpdate_Level1 iff (fvpagesize_var == FVPAGESIZE_4K){
        bins ad00        = {0};
        bins ad10        = {2};
    }

    hext__paging__cr_iside_vstage_lvl5_leaf_ptw_adupdate       : cross hext__gen__cp_curpriv, hext__paging__cp_adupdate_vstage_lvl5_fvpte{
        ignore_bins non_virt_mode = !binsof(hext__gen__cp_curpriv.vsmode) && !binsof(hext__gen__cp_curpriv.vumode);
    }
    hext__paging__cr_iside_vstage_lvl4_leaf_ptw_adupdate       : cross hext__gen__cp_curpriv, hext__paging__cp_adupdate_vstage_lvl4_fvpte{
        ignore_bins non_virt_mode = !binsof(hext__gen__cp_curpriv.vsmode) && !binsof(hext__gen__cp_curpriv.vumode);
    }
    hext__paging__cr_iside_vstage_lvl3_leaf_ptw_adupdate       : cross hext__gen__cp_curpriv, hext__paging__cp_adupdate_vstage_lvl3_fvpte{
        ignore_bins non_virt_mode = !binsof(hext__gen__cp_curpriv.vsmode) && !binsof(hext__gen__cp_curpriv.vumode);
    }
    hext__paging__cr_iside_vstage_lvl2_leaf_ptw_adupdate       : cross hext__gen__cp_curpriv, hext__paging__cp_adupdate_vstage_lvl2_fvpte{
        ignore_bins non_virt_mode = !binsof(hext__gen__cp_curpriv.vsmode) && !binsof(hext__gen__cp_curpriv.vumode);
    }
    hext__paging__cr_iside_vstage_lvl1_leaf_ptw_adupdate       : cross hext__gen__cp_curpriv, hext__paging__cp_adupdate_vstage_lvl1_fvpte{
        ignore_bins non_virt_mode = !binsof(hext__gen__cp_curpriv.vsmode) && !binsof(hext__gen__cp_curpriv.vumode);
    }

    hext__excp__cr_ls_misaligned                : cross hext__accesstype__cp_instr_2_lvl, hext__gen__cp_curpriv, hext__excp_misaligned_faults {
        option.cross_auto_bin_max   = 0;        
        bins loads_misaligned_addr_in_vsmode    = binsof(hext__accesstype__cp_instr_2_lvl.loads) &&
                                                  binsof(hext__gen__cp_curpriv.vsmode) &&
                                                  binsof(hext__excp_misaligned_faults.ld_addr_misaligned);
        bins loads_misaligned_addr_in_vumode    = binsof(hext__accesstype__cp_instr_2_lvl.loads) &&
                                                  binsof(hext__gen__cp_curpriv.vumode) && 
                                                  binsof(hext__excp_misaligned_faults.ld_addr_misaligned);
        bins stores_misaligned_addr_in_vsmode   = binsof(hext__accesstype__cp_instr_2_lvl.stores) &&
                                                  binsof(hext__gen__cp_curpriv.vsmode) &&
                                                  binsof(hext__excp_misaligned_faults.st_addr_misaligned);
        bins stores_misaligned_addr_in_vumode   = binsof(hext__accesstype__cp_instr_2_lvl.stores) &&
                                                  binsof(hext__gen__cp_curpriv.vumode) && 
                                                  binsof(hext__excp_misaligned_faults.st_addr_misaligned);

    }

    hext__excp__cr_load_misaligned_deleg          : cross hext__excp__cr_ls_misaligned, hext__deleg__cp_hedeleg_load_addr_misaligned_fault {
        option.cross_auto_bin_max   = 0;
        bins loads_misaligned_addr_in_vsmode_deleg = binsof(hext__excp__cr_ls_misaligned.loads_misaligned_addr_in_vsmode) &&
                                                     binsof(hext__deleg__cp_hedeleg_load_addr_misaligned_fault.delegation_vsmode);
        bins loads_misaligned_addr_in_hsmode_deleg = binsof(hext__excp__cr_ls_misaligned.loads_misaligned_addr_in_vsmode) &&
                                                     binsof(hext__deleg__cp_hedeleg_load_addr_misaligned_fault.non_delegation_hsmode);
    }
    hext__excp__cr_store_misaligned_deleg         : cross hext__excp__cr_ls_misaligned, hext__deleg__cp_hedeleg_store_addr_misaligned_fault {
        option.cross_auto_bin_max   = 0;
        bins stores_misaligned_addr_in_vsmode_deleg = binsof(hext__excp__cr_ls_misaligned.stores_misaligned_addr_in_vsmode) &&
                                                      binsof(hext__deleg__cp_hedeleg_store_addr_misaligned_fault.delegation_vsmode);
        bins stores_misaligned_addr_in_hsmode_deleg = binsof(hext__excp__cr_ls_misaligned.stores_misaligned_addr_in_vsmode) &&
                                                      binsof(hext__deleg__cp_hedeleg_store_addr_misaligned_fault.non_delegation_hsmode);
    }

    lr_sc_amo_instrs : coverpoint instrenum_var {
        bins lr_ops[] = {INSTRENUM_LR_W,INSTRENUM_LR_D};
        bins sc_ops[] = {INSTRENUM_SC_W,INSTRENUM_SC_D};
        bins amo_ops[] = {    INSTRENUM_AMOADD_D,
		                    INSTRENUM_AMOADD_W,
		                    INSTRENUM_AMOAND_D,
		                    INSTRENUM_AMOAND_W,
		                    INSTRENUM_AMOMAX_D,
		                    INSTRENUM_AMOMAX_W,
		                    INSTRENUM_AMOMAXU_D,
		                    INSTRENUM_AMOMAXU_W,
		                    INSTRENUM_AMOMIN_D,
		                    INSTRENUM_AMOMIN_W,
		                    INSTRENUM_AMOMINU_D,
		                    INSTRENUM_AMOMINU_W,
		                    INSTRENUM_AMOOR_D,
		                    INSTRENUM_AMOOR_W,
		                    INSTRENUM_AMOSWAP_D,
		                    INSTRENUM_AMOSWAP_W,
		                    INSTRENUM_AMOXOR_D,
		                    INSTRENUM_AMOXOR_W
                        };
    }

    guest_faults : coverpoint exception_var iff(match_excp==1){
        bins load_faults  = { EXCEPTION_LOAD_GUEST_PAGE_FAULT };
        bins store_amo_faults = { EXCEPTION_STORE_GUEST_PAGE_FAULT}; 
        bins fetch_faults = { EXCEPTION_INST_GUEST_PAGE_FAULT };      
    }
    
    hext__lr_sc_with_guest_faults : cross hext__gen__cp_curpriv, lr_sc_amo_instrs, guest_faults {
        option.cross_auto_bin_max   = 0;
        bins lr_in_vsmode_with_faults = binsof(hext__gen__cp_curpriv.vsmode) && 
                                        binsof(lr_sc_amo_instrs.lr_ops) && 
                                        binsof(guest_faults.load_faults);
        bins lr_in_vu_mode_with_faults = binsof(hext__gen__cp_curpriv.vumode) &&
                                        binsof(lr_sc_amo_instrs.lr_ops) && 
                                        binsof(guest_faults.load_faults);
        bins sc_in_vsmode_with_faults = binsof(hext__gen__cp_curpriv.vsmode) && 
                                        binsof(lr_sc_amo_instrs.sc_ops) && 
                                        binsof(guest_faults.store_amo_faults);
        bins sc_in_vumode_with_faults = binsof(hext__gen__cp_curpriv.vumode) &&
                                        binsof(lr_sc_amo_instrs.sc_ops) && 
                                        binsof(guest_faults.store_amo_faults);
        bins amo_in_vsmode_with_faults = binsof(hext__gen__cp_curpriv.vsmode) && 
                                        binsof(lr_sc_amo_instrs.amo_ops) && 
                                        binsof(guest_faults.store_amo_faults);
        bins amo_in_vumode_with_faults = binsof(hext__gen__cp_curpriv.vumode) && 
                                        binsof(lr_sc_amo_instrs.amo_ops) &&
                                        binsof(guest_faults.store_amo_faults);
    }
endgroup

`endif
