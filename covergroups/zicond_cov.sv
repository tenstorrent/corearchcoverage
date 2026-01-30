//  SPDX-FileCopyrightText: © 2026 Tenstorrent AI ULC
//  SPDX-License-Identifier: Apache-2.0
`ifndef COVERAGE_UNSUPPORTED

import cp_pkg::*;

covergroup zicond__cg with function sample(csr_cov_sample i_csr);
    option.per_instance = 1;
    option.name         = "Zicond covergroup";
    option.comment      = "";

    zicond__gen__cp_op: coverpoint instrenum_var {
        bins zicond_czero_eqz = {INSTRENUM_CZERO_EQZ};
        bins zicond_czero_nez = {INSTRENUM_CZERO_NEZ};
    }

    zicond__gen__cp_rs1val : coverpoint rs1_val{
        bins val_0 = {0};
        bins val_x = {[1:$]};
    }

    zicond__gen__cp_rs2val : coverpoint rs2_val{
        bins val_0 = {0};
        bins val_x = {[1:$]};
    }
    
    zicond__gen_cr_rc: cross zicond__gen__cp_op,zicond__gen__cp_rs1val,zicond__gen__cp_rs2val;
    
endgroup : zicond__cg

`endif
