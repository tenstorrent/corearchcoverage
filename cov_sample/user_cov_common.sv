//  SPDX-FileCopyrightText: © 2026 Tenstorrent AI ULC
//  SPDX-License-Identifier: Apache-2.0
`ifndef COVERAGE_UNSUPPORTED
`ifndef USER_COV_COMMON_SV
`define USER_COV_COMMON_SV
package user_cov_common;
import cp_pkg::*;
import cov_common::*;

bit br_taken;
bit reservation_valid_prev = 0;
bit reservation_valid_current = 0;

logic[63:0] rs1, rs2, rs3, rd;
logic[63:0] rs1_val, rs2_val, rs3_val, rd_val;
logic[63:0] time_val;
bit         always_one = 1;
logic[63:0] csr_val;
bit         match_excp;

const bit[63:0] UMIN64 = 64'h0000000000000000;
const bit[63:0] UMAX64 = 64'hffffffffffffffff;
const bit[63:0] SMIN64 = 64'h8000000000000000;
const bit[63:0] SMAX64 = 64'h7fffffffffffffff;

const bit[31:0] UMIN32 = 32'h00000000;
const bit[31:0] UMAX32 = 32'hffffffff;
const bit[31:0] SMIN32 = 32'h80000000;
const bit[31:0] SMAX32 = 32'h7fffffff;

const bit[19:0] UMIN20 = 20'h00000;
const bit[19:0] UMAX20 = 20'hfffff;
const bit[19:0] SMIN20 = 20'h80000;
const bit[19:0] SMAX20 = 20'h7ffff;

const bit[15:0] UMIN16 = 16'h0000;
const bit[15:0] UMAX16 = 16'hffff;
const bit[15:0] SMIN16 = 16'h8000;
const bit[15:0] SMAX16 = 16'h7fff;

const bit[11:0] UMIN12 = 12'h000;
const bit[11:0] UMAX12 = 12'hfff;
const bit[11:0] SMIN12 = 12'h800;
const bit[11:0] SMAX12 = 12'h7ff;

const bit[10:0] UMIN11 = 11'b00000000000;
const bit[10:0] UMAX11 = 11'b11111111111;
const bit[10:0] SMIN11 = 11'b10000000000;
const bit[10:0] SMAX11 = 11'b01111111111;

const bit[7:0]  UMIN8 = 8'h00;
const bit[7:0]  UMAX8 = 8'hff;
const bit[7:0]  SMIN8 = 8'h80;
const bit[7:0]  SMAX8 = 8'h7f;

const bit[5:0]  UMIN6 = 6'b000000;
const bit[5:0]  UMAX6 = 6'b111111;
const bit[5:0]  SMIN6 = 6'b100000;
const bit[5:0]  SMAX6 = 6'b011111;

const bit[4:0]  UMIN5 = 5'b00000;
const bit[4:0]  UMAX5 = 5'b11111;
const bit[4:0]  SMIN5 = 5'b10000;
const bit[4:0]  SMAX5 = 5'b01111;

const bit[31:0] FEXT_SN            = 32'h00800000;
const bit[31:0] FEXT_SN_NEG        = 32'h80800000;
const bit[31:0] FEXT_LN            = 32'h7f7fffff;
const bit[31:0] FEXT_LN_NEG        = 32'hff7fffff;
const bit[31:0] FEXT_SSN           = 32'h00000001;
const bit[31:0] FEXT_SSN_NEG       = 32'h80000001;
const bit[31:0] FEXT_LSN           = 32'h007fffff;
const bit[31:0] FEXT_LSN_NEG       = 32'h807fffff;
const bit[31:0] FEXT_ONE           = 32'h3f800000;
const bit[31:0] FEXT_ONE_NEG       = 32'hbf800000;
const bit[31:0] FEXT_TWO           = 32'h40000000;
const bit[31:0] FEXT_TWO_NEG       = 32'hc0000000;
const bit[31:0] FEXT_THREE         = 32'h40400000;
const bit[31:0] FEXT_THREE_NEG     = 32'hc0400000;
const bit[31:0] FEXT_ONE_MINUS     = 32'h3f7fffff;
const bit[31:0] FEXT_ONE_MINUS_NEG = 32'hbf7fffff;
const bit[31:0] FEXT_ONE_PLUS      = 32'h3f800001;
const bit[31:0] FEXT_ONE_PLUS_NEG  = 32'hbf800001;
const bit[31:0] FEXT_ZERO          = 32'h00000000;
const bit[31:0] FEXT_ZERO_NEG      = 32'h80000000;
const bit[31:0] FEXT_INFINITY      = 32'h7f800000;
const bit[31:0] FEXT_INFINITY_NEG  = 32'hff800000;
const bit[31:0] FEXT_SNAN          = 32'h7f800001;
const bit[31:0] FEXT_SNAN_NEG      = 32'hff800001;
const bit[31:0] FEXT_QNAN          = 32'h7fc00000;
const bit[31:0] FEXT_QNAN_NEG      = 32'hffc00000;

const bit[63:0] DEXT_SN            = 64'h0010000000000000;
const bit[63:0] DEXT_SN_NEG        = 64'h8010000000000000;
const bit[63:0] DEXT_LN            = 64'h7fefffffffffffff;
const bit[63:0] DEXT_LN_NEG        = 64'hffefffffffffffff;
const bit[63:0] DEXT_SSN           = 64'h0000000000000001;
const bit[63:0] DEXT_SSN_NEG       = 64'h8000000000000001;
const bit[63:0] DEXT_LSN           = 64'h000fffffffffffff;
const bit[63:0] DEXT_LSN_NEG       = 64'h800fffffffffffff;
const bit[63:0] DEXT_ONE           = 64'h3ff0000000000000;
const bit[63:0] DEXT_ONE_NEG       = 64'hbff0000000000000;
const bit[63:0] DEXT_TWO           = 64'h4000000000000000;
const bit[63:0] DEXT_TWO_NEG       = 64'hc000000000000000;
const bit[63:0] DEXT_THREE         = 64'h4008000000000000;
const bit[63:0] DEXT_THREE_NEG     = 64'hc008000000000000;
const bit[63:0] DEXT_ONE_MINUS     = 64'h3fefffffffffffff;
const bit[63:0] DEXT_ONE_MINUS_NEG = 64'hbfefffffffffffff;
const bit[63:0] DEXT_ONE_PLUS      = 64'h3ff0000000000001;
const bit[63:0] DEXT_ONE_PLUS_NEG  = 64'hbff0000000000001;
const bit[63:0] DEXT_ZERO          = 64'h0000000000000000;
const bit[63:0] DEXT_ZERO_NEG      = 64'h8000000000000000;
const bit[63:0] DEXT_INFINITY      = 64'h7ff0000000000000;
const bit[63:0] DEXT_INFINITY_NEG  = 64'hfff0000000000000;
const bit[63:0] DEXT_SNAN          = 64'h7ff0000000000001;
const bit[63:0] DEXT_SNAN_NEG      = 64'hfff0000000000001;
const bit[63:0] DEXT_QNAN          = 64'h7ff8000000000000;
const bit[63:0] DEXT_QNAN_NEG      = 64'hfff8000000000000;

const bit[15:0] ZFHEXT_SN            = 16'h0400;
const bit[15:0] ZFHEXT_SN_NEG        = 16'h8400;
const bit[15:0] ZFHEXT_LN            = 16'h7bff;
const bit[15:0] ZFHEXT_LN_NEG        = 16'hfbff;
const bit[15:0] ZFHEXT_SSN           = 16'h0001;
const bit[15:0] ZFHEXT_SSN_NEG       = 16'h8001;
const bit[15:0] ZFHEXT_LSN           = 16'h03ff;
const bit[15:0] ZFHEXT_LSN_NEG       = 16'h83ff;
const bit[15:0] ZFHEXT_ONE           = 16'h3c00;
const bit[15:0] ZFHEXT_ONE_NEG       = 16'hbc00;
const bit[15:0] ZFHEXT_TWO           = 16'h4000;
const bit[15:0] ZFHEXT_TWO_NEG       = 16'hc000;
const bit[15:0] ZFHEXT_THREE         = 16'h4200;
const bit[15:0] ZFHEXT_THREE_NEG     = 16'hc200;
const bit[15:0] ZFHEXT_ONE_MINUS     = 16'h3bff;
const bit[15:0] ZFHEXT_ONE_MINUS_NEG = 16'hbbff;
const bit[15:0] ZFHEXT_ONE_PLUS      = 16'h3c01;
const bit[15:0] ZFHEXT_ONE_PLUS_NEG  = 16'hbc01;
const bit[15:0] ZFHEXT_ZERO          = 16'h0000;
const bit[15:0] ZFHEXT_ZERO_NEG      = 16'h8000;
const bit[15:0] ZFHEXT_INFINITY      = 16'h7c00;
const bit[15:0] ZFHEXT_INFINITY_NEG  = 16'hfc00;
const bit[15:0] ZFHEXT_SNAN          = 16'h7c01;
const bit[15:0] ZFHEXT_SNAN_NEG      = 16'hfc01;
const bit[15:0] ZFHEXT_QNAN          = 16'h7e00;
const bit[15:0] ZFHEXT_QNAN_NEG      = 16'hfe00;

endpackage
`endif
`endif
