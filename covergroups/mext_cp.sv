`ifndef COVERAGE_UNSUPPORTED

import cp_pkg::*;
import user_cov_common::*;

covergroup mext__cg with function sample();
    option.per_instance = 1;
    option.name = "cg_mul_priv";
    mext__general_cp_mext_instr: coverpoint mext_var; 
    
    mext__general_cp_div_instr:  coverpoint mext_var{
        bins div_instrs[] = {
		    MEXT_DIV,
		    MEXT_DIVU,
		    MEXT_DIVUW,
		    MEXT_DIVW
        };
    }

    mext__general_cp_mul_instr:  coverpoint instrenum_var{
        bins mul_instrs[] = {
            MEXT_MUL,
		    MEXT_MULH,
		    MEXT_MULHSU,
		    MEXT_MULHU,
		    MEXT_MULW
        };
    }

    mext__general_cp_rem_instr:  coverpoint instrenum_var{
        bins rem_instrs[] = {
		    MEXT_REM,
		    MEXT_REMU,
		    MEXT_REMUW,
		    MEXT_REMW
        };
    }

    mext__general_cp_privilege_modes : coverpoint privilegemode_var{
        bins priv_mode[] = {
            PRIVILEGEMODE_MACHINE, 
            PRIVILEGEMODE_SUPERVISOR, 
            PRIVILEGEMODE_USER
        };
    }
    
    mext__general_cr_div_priv : cross mext__general_cp_div_instr, mext__general_cp_privilege_modes;
    mext__general_cr_mul_priv : cross mext__general_cp_mul_instr, mext__general_cp_privilege_modes;
    mext__general_cr_rem_priv : cross mext__general_cp_rem_instr, mext__general_cp_privilege_modes;

    mext__general_cp_rd_x0: coverpoint rd iff(rs1 != 0 && rs2 != 0){
        bins rd_x0 = {0};
    }
    mext__general_cr_mext_rd_x0: cross mext__general_cp_mext_instr, mext__general_cp_rd_x0;

    mext__general_cp_mext_signed_instr: coverpoint mext_var {
        bins mext_signed_instr[] = {MEXT_MUL, MEXT_MULH, MEXT_DIV, MEXT_REM};
    }
    mext__general_cp_mext_signed_w_instr: coverpoint mext_var{
        bins mext_signed_w_instr[] = {MEXT_MULW, MEXT_DIVW, INSTRENUM_REMW};
    }
    
    mext__dataset_cp_rs1_sign_64bit : coverpoint rs1_val[63];
    mext__dataset_cp_rs2_sign_64bit : coverpoint rs2_val[63];
    mext__dataset_cp_rs1_sign_32bit : coverpoint rs1_val[31];
    mext__dataset_cp_rs2_sign_32bit : coverpoint rs2_val[31];

    mext__dataset_cr_mext_sign64bit : cross mext__dataset_cp_rs1_sign_64bit, mext__dataset_cp_rs2_sign_64bit, mext__general_cp_mext_signed_instr;
    mext__dataset_cr_mext_sign32bit : cross mext__dataset_cp_rs1_sign_32bit, mext__dataset_cp_rs2_sign_32bit, mext__general_cp_mext_signed_w_instr;

    mext__dataset_cp_rs1_u64_minmax : coverpoint rs1_val{

        bins mul[] = {
            UMIN64, 
            UMAX64
        } iff(  instrenum_var == INSTRENUM_MUL || 
                instrenum_var == INSTRENUM_MULH || 
                instrenum_var == INSTRENUM_MULHU || 
                instrenum_var == INSTRENUM_MULHSU
            );
        bins div[] = {
            UMIN64, 
            UMAX64
        } iff(  instrenum_var == INSTRENUM_DIV || 
                instrenum_var == INSTRENUM_DIVU
            );
        bins rem[] = {
            UMIN64, 
            UMAX64
        } iff(  instrenum_var == INSTRENUM_REM || 
                instrenum_var == INSTRENUM_REMU
            );
    }
    mext__dataset_cp_rs2_u64_minmax : coverpoint rs2_val{

        bins mul[] = {
            UMIN64,
            UMAX64
        } iff(  instrenum_var == INSTRENUM_MUL ||
                instrenum_var == INSTRENUM_MULH ||
                instrenum_var == INSTRENUM_MULHU ||
                instrenum_var == INSTRENUM_MULHSU
            );
        bins div[] = {
            UMIN64,
            UMAX64
        } iff(  instrenum_var == INSTRENUM_DIV ||
                instrenum_var == INSTRENUM_DIVU
            );
        bins rem[] = {
            UMIN64,
            UMAX64
        } iff(  instrenum_var == INSTRENUM_REM ||
                instrenum_var == INSTRENUM_REMU
            );
    }

    mext__dataset_cp_rs1_s64_minmax : coverpoint rs1_val{

        bins mul[] = {
            SMIN64,
            SMAX64
        } iff(  instrenum_var == INSTRENUM_MUL ||
                instrenum_var == INSTRENUM_MULH ||
                instrenum_var == INSTRENUM_MULHSU
            );
        bins div[] = {
            SMIN64,
            SMAX64
        } iff(instrenum_var == INSTRENUM_DIV);
        bins rem[] = {
            SMIN64,
            SMAX64
        } iff(instrenum_var == INSTRENUM_REM);
    }

    mext__dataset_cp_rs2_s64_minmax : coverpoint rs2_val{

        bins mul[] = {
            SMIN64,
            SMAX64
        } iff(  instrenum_var == INSTRENUM_MUL ||
                instrenum_var == INSTRENUM_MULH
            );
        bins div[] = {
            SMIN64,
            SMAX64
        } iff(instrenum_var == INSTRENUM_DIV);
        bins rem[] = {
            SMIN64,
            SMAX64
        } iff(instrenum_var == INSTRENUM_REM);
    }

    mext__dataset_cp_rs1_u32_max : coverpoint rs1_val[31:0]{

        bins mul[] = {UMAX32} iff(instrenum_var == INSTRENUM_MULW);
        bins div[] = {UMAX32} iff(  instrenum_var == INSTRENUM_DIVW ||
                instrenum_var == INSTRENUM_DIVUW
            );
        bins rem[] = {UMAX32} iff(  instrenum_var == INSTRENUM_REMW ||
                instrenum_var == INSTRENUM_REMUW
            );
    }

    mext__dataset_cp_rs2_u32_max : coverpoint rs2_val[31:0]{

        bins mul[] = {UMAX32} iff(instrenum_var == INSTRENUM_MULW);
        bins div[] = {UMAX32} iff(  instrenum_var == INSTRENUM_DIVW ||
                instrenum_var == INSTRENUM_DIVUW
            );
        bins rem[] = {UMAX32} iff(  instrenum_var == INSTRENUM_REMW ||
                instrenum_var == INSTRENUM_REMUW
            );
    }

    mext__dataset_cp_rs1_s32_minmax : coverpoint rs1_val[31:0]{

        bins mul[] = {
            SMIN32,
            SMAX32
        } iff(instrenum_var == INSTRENUM_MULW);
        bins div[] = {
            SMIN32,
            SMAX32
        } iff(instrenum_var == INSTRENUM_DIVW);
        bins rem[] = {
            SMIN32,
            SMAX32
        } iff(instrenum_var == INSTRENUM_REMW);
    }

    mext__dataset_cp_rs2_s32_minmax : coverpoint rs2_val[31:0]{

        bins mul[] = {
            SMIN32,
            SMAX32
        } iff(instrenum_var == INSTRENUM_MULW);
        bins div[] = {
            SMIN32,
            SMAX32
        } iff(instrenum_var == INSTRENUM_DIVW);
        bins rem[] = {
            SMIN32,
            SMAX32
        } iff(instrenum_var == INSTRENUM_REMW);
    }

    mext__dataset_cp_overflow : coverpoint instrenum_var{

        bins overflow_64[] = {
            INSTRENUM_MUL,
            INSTRENUM_DIV,
            INSTRENUM_REM
        } iff(rs1_val==64'h8000000000000000 && rs2_val==64'hffffffffffffffff);

        bins overflow_32[] = {
            INSTRENUM_MULW,
            INSTRENUM_DIVW,
            INSTRENUM_REMW
        } iff(rs1_val[31:0]==64'h80000000 && rs2_val[31:0]==64'hffffffff);
    }

    mext__dataset_cp_mul_overflow : coverpoint instrenum_var{

        bins overflow_64_rs1_rs2_min[] = {
            INSTRENUM_MUL,
            INSTRENUM_MULH,
            INSTRENUM_MULHU,
            INSTRENUM_MULHSU
        } iff(rs1_val>=64'h100000000 && rs2_val>=64'h100000000);

        bins overflow_64_rs1_max[] = {
            INSTRENUM_MUL,
            INSTRENUM_MULH,
            INSTRENUM_MULHU,
            INSTRENUM_MULHSU
        } iff(rs1_val==64'hffffffffffffffff && rs2_val>1);

        bins overflow_64_rs2_max[] = {
            INSTRENUM_MUL,
            INSTRENUM_MULH,
            INSTRENUM_MULHU,
            INSTRENUM_MULHSU
        } iff(rs1_val>1 && rs2_val==64'hffffffffffffffff);

        bins overflow_32_rs1_rs2_min[] = {INSTRENUM_MULW} iff(rs1_val[31:0]>=64'h10000 && rs2_val[31:0]>=64'h10000);

        bins overflow_32_rs1_max[] = {INSTRENUM_MULW} iff(rs1_val[31:0]==64'hffffffff && rs2_val[31:0]>1);

        bins overflow_32_rs2_max[] = {INSTRENUM_MULW} iff(rs1_val[31:0]>1 && rs2_val[31:0]==64'hffffffff);
    }

    mext__dataset_cp_rs2_zero: coverpoint mext_var iff(rs2_val == 'b0){
        bins mext_instrs[] = {
            MEXT_DIV,
		    MEXT_DIVU,
		    MEXT_DIVUW,
		    MEXT_DIVW,
            MEXT_MUL,
		    MEXT_MULH,
		    MEXT_MULHSU,
		    MEXT_MULHU,
		    MEXT_MULW,
           	MEXT_REM,
		    MEXT_REMU,
		    MEXT_REMUW,
		    MEXT_REMW 
        };
    }
    
    mext__dataset_cp_rs1_zero: coverpoint instrenum_var iff(rs1_val == 'b0){
        bins mext_instrs[] = {
            MEXT_DIV,
		    MEXT_DIVU,
		    MEXT_DIVUW,
		    MEXT_DIVW,
            MEXT_MUL,
		    MEXT_MULH,
		    MEXT_MULHSU,
		    MEXT_MULHU,
		    MEXT_MULW,
           	MEXT_REM,
		    MEXT_REMU,
		    MEXT_REMUW,
		    MEXT_REMW 
        };
    }

    mext__dataset_cp_indentity_operation : coverpoint rs2_val{
        bins pos_one = {64'h0000000000000001};
        bins neg_one = {64'hffffffffffffffff};
    }
    mext__dataset_cr_mext_identity_operation : cross mext__general_cp_mext_instr, mext__dataset_cp_indentity_operation;

endgroup

`endif
