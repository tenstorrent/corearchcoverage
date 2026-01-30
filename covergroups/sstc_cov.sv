//  SPDX-FileCopyrightText: © 2026 Tenstorrent AI ULC
//  SPDX-License-Identifier: Apache-2.0
`ifndef COVERAGE_UNSUPPORTED

import cp_pkg::*;

covergroup sstc__cg with function sample(csr_cov_sample i_csr);
    option.per_instance = 1;
    option.name = "cg_sstc";
    
    sstc__cp_stimecmp : coverpoint always_one {
        bins stimecmp_less_than_time    = {1} iff(i_csr.stimecmp_csr_inst.stimecmp < time_val);
        bins stimecmp_greater_than_time = {1} iff(i_csr.stimecmp_csr_inst.stimecmp > time_val);
        bins stimecmp_equal_to_time     = {1} iff(i_csr.stimecmp_csr_inst.stimecmp == time_val); 
    }

    sstc__cp_vstimecmp : coverpoint rs2 {
        bins vstimecmp_less_than_time    = {1} iff(i_csr.vstimecmp_csr_inst.stimecmp < time_val  + i_csr.htimedelta_csr_inst.htimedelta);
        bins vstimecmp_greater_than_time = {1} iff(i_csr.vstimecmp_csr_inst.stimecmp > time_val  + i_csr.htimedelta_csr_inst.htimedelta);
        bins vstimecmp_equal_to_time     = {1} iff(i_csr.vstimecmp_csr_inst.stimecmp == time_val + i_csr.htimedelta_csr_inst.htimedelta); 
    }

    sstc__cp_stce : coverpoint i_csr.menvcfg_csr_inst.stce;
    
    sstc__cp_stip_tkn : coverpoint interrupt_var {
        bins stip_tkn = {INTERRUPT_S_TIMER};
    }

    sstc__cp_stip_x_stce : cross sstc__cp_stce, sstc__cp_stip_tkn;

    sstc__cp_mcounteren_tm_timecmp : coverpoint instrenum_var {
        bins tm_set[1]      = {
           	INSTRENUM_CSRRC,
		    INSTRENUM_CSRRCI,
		    INSTRENUM_CSRRS,
		    INSTRENUM_CSRRSI,
		    INSTRENUM_CSRRW,
		    INSTRENUM_CSRRWI
        } iff(csr_op2_var == CSR_OP2_STIMECMP && i_csr.mcounteren_csr_inst.tm==0);

        bins tm_clear[1]    = {
       	    INSTRENUM_CSRRC,
		    INSTRENUM_CSRRCI,
		    INSTRENUM_CSRRS,
		    INSTRENUM_CSRRSI,
		    INSTRENUM_CSRRW,
		    INSTRENUM_CSRRWI
        } iff(csr_op2_var == CSR_OP2_STIMECMP && i_csr.mcounteren_csr_inst.tm==1);
    }

    sstc__cp_hcounteren_tm_timecmp : coverpoint instrenum_var {
        bins vs_tm_set[1]   = {
            INSTRENUM_CSRRC,
		    INSTRENUM_CSRRCI,
		    INSTRENUM_CSRRS,
		    INSTRENUM_CSRRSI,
		    INSTRENUM_CSRRW,
		    INSTRENUM_CSRRWI 
        } iff(csr_op2_var == 64'h24d && i_csr.hcounteren_csr_inst.tm == 0);

        bins vs_tm_clear[1] = {
            INSTRENUM_CSRRC,
		    INSTRENUM_CSRRCI,
		    INSTRENUM_CSRRS,
		    INSTRENUM_CSRRSI,
		    INSTRENUM_CSRRW,
		    INSTRENUM_CSRRWI  
        } iff(csr_op2_var == 64'h24d && i_csr.hcounteren_csr_inst.tm == 1);
    }
    
    sstc__cp_stce_timecmp : coverpoint instrenum_var {
        bins tm_set[1]      = {
            INSTRENUM_CSRRC,
		    INSTRENUM_CSRRCI,
		    INSTRENUM_CSRRS,
		    INSTRENUM_CSRRSI,
		    INSTRENUM_CSRRW,
		    INSTRENUM_CSRRWI   
        } iff(csr_op2_var == CSR_OP2_STIMECMP && i_csr.menvcfg_csr_inst.stce==0);

        bins tm_clear[1]    = {
            INSTRENUM_CSRRC,
		    INSTRENUM_CSRRCI,
		    INSTRENUM_CSRRS,
		    INSTRENUM_CSRRSI,
		    INSTRENUM_CSRRW,
		    INSTRENUM_CSRRWI    
        } iff(csr_op2_var == CSR_OP2_STIMECMP && i_csr.menvcfg_csr_inst.stce==1);
    }

    sstc__cp_vstce_timecmp : coverpoint instrenum_var {
        bins vs_tm_set[1]   = {
            INSTRENUM_CSRRC,
		    INSTRENUM_CSRRCI,
		    INSTRENUM_CSRRS,
		    INSTRENUM_CSRRSI,
		    INSTRENUM_CSRRW,
		    INSTRENUM_CSRRWI     
        } iff(csr_op2_var == 64'h24d && i_csr.henvcfg_csr_inst.vstce == 0);

        bins vs_tm_clear[1] = {
            INSTRENUM_CSRRC,
		    INSTRENUM_CSRRCI,
		    INSTRENUM_CSRRS,
		    INSTRENUM_CSRRSI,
		    INSTRENUM_CSRRW,
		    INSTRENUM_CSRRWI     
        } iff(csr_op2_var == 64'h24d && i_csr.henvcfg_csr_inst.vstce == 1);
    }

endgroup

`endif

