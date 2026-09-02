//  SPDX-FileCopyrightText: © 2026 Tenstorrent AI ULC
//  SPDX-License-Identifier: Apache-2.0
`ifndef COVERAGE_UNSUPPORTED
`ifndef USER_COV_COMMON_SV
`define USER_COV_COMMON_SV
package user_cov_common;
import cp_pkg::*;
import cov_common::*;

import "DPI-C" function void get_leaf_nonleaf_ptes(
    input longint unsigned pte1,
    input longint unsigned pte2,
    input longint unsigned pte3,
    input longint unsigned pte4,
    input longint unsigned pte5,
    input int start_level,
    input int end_level,
    output longint unsigned leaf_pte,
    output longint unsigned nonleaf_pte
);

bit br_taken;
bit reservation_valid_prev = 0;
bit reservation_valid_current = 0;

logic[4:0]  rs1, rs2, rs3, rd;
logic[63:0] rs1_val, rs2_val, rs3_val, rd_val;
logic[63:0] time_val;
bit         always_one = 1;
logic[63:0] csr_val;
csrEnum_e   csr_accessed; 
bit         match_excp;
bit         match_trigger; 
bit         match_csr_r_instr;
bit         match_csr_w_instr;
bit         match_instr_load;
bit         match_instr_store;
bit         match_aext;
bit         match_mem_sync;
bit         match_hext_mem_sync;
bit         match_hext_ld_st;
bit         match_zicbomext;
bit         match_zicbozext;
bit         match_fext;
bit         match_dext;
bit         match_vext;

bit         counter_csr_access;
bit[4:0]    counter_csr_index;
bit         mcounteren_access_bit;
bit         hcounteren_access_bit;
bit         scounteren_access_bit;

bit         in_excp_handler;
bit         in_trigger_handler;
bit         interrupt_taken;
bit         in_intr_handler;

logic[63:0] prev_mstatus_csr,cur_mstatus_csr;
logic[63:0] prev_hstatus_csr, cur_hstatus_csr;
logic[63:0] prev_vsstatus_csr, cur_vsstatus_csr;
logic[63:0] prev_medeleg_csr, cur_medeleg_csr;
logic[63:0] prev_hedeleg_csr, cur_hedeleg_csr;
logic[63:0] prev_sstatus_csr, cur_sstatus_csr;
logic[63:0] prev_satp_csr, cur_satp_csr;
logic[63:0] prev_vsatp_csr, cur_vsatp_csr;
logic[63:0] prev_hgatp_csr, cur_hgatp_csr;



// Paging
logic [63:0] FVPTELeaf;
logic [63:0] DVPTELeaf;
logic [63:0] FVPTENonLeaf;
logic [63:0] DVPTENonLeaf;
logic [2:0] FVPTE_LowestLevel;
logic [2:0] DVPTE_LowestLevel;
logic [2:0] DVPTE_HighestLevel;
logic [2:0] FVPTE_HighestLevel;

logic[1:0]  DPTE_LeafADUpdate_GStageLevel5;
logic[1:0]  DPTE_LeafADUpdate_GStageLevel4;
logic[1:0]  DPTE_LeafADUpdate_GStageLevel3;
logic[1:0]  DPTE_LeafADUpdate_GStageLevel2;
logic[1:0]  DPTE_LeafADUpdate_GStageLevel1;

logic[1:0]  DVPTE_ADUpdate;
logic[1:0]  FVPTE_ADUpdate;

logic[1:0]  DVPTE_ADUpdate_Level5;
logic[1:0]  DVPTE_ADUpdate_Level4;
logic[1:0]  DVPTE_ADUpdate_Level3;
logic[1:0]  DVPTE_ADUpdate_Level2;
logic[1:0]  DVPTE_ADUpdate_Level1;
logic[1:0]  FVPTE_ADUpdate_Level5;
logic[1:0]  FVPTE_ADUpdate_Level4;
logic[1:0]  FVPTE_ADUpdate_Level3;
logic[1:0]  FVPTE_ADUpdate_Level2;
logic[1:0]  FVPTE_ADUpdate_Level1;


bit  FPTE_LeafA;
bit  DPTE_LeafA;
bit  FPTE_NonLeafA;
bit  DPTE_NonLeafA;

bit  FPTE_LeafD;
bit  DPTE_LeafD;
bit  FPTE_NonLeafD;
bit  DPTE_NonLeafD;

bit  DPTE_LeafG;
bit  FPTE_LeafG;
bit  FPTE_NonLeafG;
bit  DPTE_NonLeafG;

bit  DPTE_LeafNapot;
bit  FPTE_LeafNapot;
bit  FPTE_NonLeafNapot;
bit  DPTE_NonLeafNapot;

bit  FPTE_LeafR;
bit  DPTE_LeafR;
bit  FPTE_NonLeafR;
bit  DPTE_NonLeafR;

bit  FPTE_LeafU;
bit  DPTE_LeafU;
bit  FPTE_NonLeafU;
bit  DPTE_NonLeafU;

bit  FPTE_LeafV;
bit  DPTE_LeafV;
bit  FPTE_NonLeafV;
bit  DPTE_NonLeafV;

bit  FPTE_LeafW;
bit  DPTE_LeafW;
bit  FPTE_NonLeafW;
bit  DPTE_NonLeafW;

bit  FPTE_LeafX;
bit  DPTE_LeafX;
bit  FPTE_NonLeafX;
bit  DPTE_NonLeafX;

logic[1:0] FPTE_NonLeafRsw;
logic[1:0] DPTE_NonLeafRsw;
logic[1:0] FPTE_LeafRsw;
logic[1:0] DPTE_LeafRsw;

logic[43:0] DPTE_LeafPpn;
logic[43:0] FPTE_LeafPpn;
logic[6:0] FPTE_LeafRes;
logic[6:0] DPTE_LeafRes;
logic[6:0] DPTE_NonLeafRes;
logic[6:0] FPTE_NonLeafRes;
logic[1:0] FPTE_LeafPbmt;
logic[1:0] DPTE_LeafPbmt;
logic[1:0] FPTE_NonLeafPbmt;
logic[1:0] DPTE_NonLeafPbmt;

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

//Bit Positions 
// mcause exception codes (mcause[63] == 0). Codes 14, 17 and 24-31 are reserved.
// These double as the bit positions of the matching medeleg/hedeleg bits.
const int INSTR_ADDR_MISALIGNED          = 0;
const int INSTR_ACC_FAULT_EXCP           = 1;
const int INSTR_ILLEGAL_EXCP             = 2;
const int BREAKPOINT_EXCP                = 3;
const int LOAD_ADDR_MISALIGNED           = 4;
const int LOAD_ACC_FAULT_EXCP            = 5;
const int STORE_ADDR_MISALIGNED          = 6;
const int STORE_ACC_FAULT_EXCP           = 7;
const int U_ENV_CALL_EXCP                = 8;
const int S_ENV_CALL_EXCP                = 9;
const int VS_ENV_CALL_EXCP               = 10;
const int M_ENV_CALL_EXCP                = 11;
const int INSTR_PAGE_FAULT_EXCP          = 12;
const int LOAD_PAGE_FAULT_EXCP           = 13;
const int STORE_PAGE_FAULT_EXCP          = 15;
const int DOUBLE_TRAP_EXCP               = 16;
const int SOFTWARE_CHECK_EXCP            = 18;
const int HARDWARE_ERROR_EXCP            = 19;
const int INSTR_GUEST_PAGE_FAULT_EXCP    = 20;
const int LOAD_GUEST_PAGE_FAULT_EXCP     = 21;
const int VIRT_INSTR_EXCP                = 22;
const int STORE_GUEST_PAGE_FAULT_EXCP    = 23;

const int HSTATUS_VTSR  = 22; 
const int HSTATUS_VTW   = 21;
const int HSTATUS_VTVM  = 20;
const int MSTATUS_TW    = 21;

// Unprivileged counter/timer CSRs: cycle..hpmcounter31 and their high-half aliases.
localparam bit[11:0] CSR_COUNTER_LO  = 12'hc00;
localparam bit[11:0] CSR_COUNTER_HI  = 12'hc1f;
localparam bit[11:0] CSR_COUNTERH_LO = 12'hc80;
localparam bit[11:0] CSR_COUNTERH_HI = 12'hc9f;


parameter PTE_VALID = 0;
parameter PTE_READ = 1;
parameter PTE_WRITE= 2;
parameter PTE_EXECUTE = 3;
parameter PTE_USER = 4;
parameter PTE_GLOBAL = 5;
parameter PTE_ACCESSED = 6;
parameter PTE_DIRTY = 7;
parameter PTE_RSW_LO = 8;
parameter PTE_RSW_HI = 9;
parameter PTE_PPN0_LO = 10;
parameter PTE_PPN0_HI = 18;
parameter PTE_PPN1_LO = 19;
parameter PTE_PPN1_HI = 27;
parameter PTE_PPN2_LO = 28;
parameter PTE_PPN2_HI = 36;
parameter PTE_PPN3_LO = 37;
parameter PTE_PPN3_HI = 45;
parameter PTE_PPN4_LO = 46;
parameter PTE_PPN4_HI = 53;
parameter PTE_RES_LO = 54;
parameter PTE_RES_HI = 60;
parameter PTE_PBMT_LO = 61;
parameter PTE_PBMT_HI = 62;
parameter PTE_NAPOT = 63;

localparam bit [6:0] OPCODE_SYSTEM = 7'b1110011;
localparam bit [2:0] FUNCT3_PRIV   = 3'b000;  // ECALL, EBREAK, *RET, …
localparam bit [2:0] FUNCT3_CSRRW  = 3'b001;
localparam bit [2:0] FUNCT3_CSRRS  = 3'b010;
localparam bit [2:0] FUNCT3_CSRRC  = 3'b011;
localparam bit [2:0] FUNCT3_CSRRWI = 3'b101;
localparam bit [2:0] FUNCT3_CSRRSI = 3'b110;
localparam bit [2:0] FUNCT3_CSRRCI = 3'b111;

function void get_pte_level_range(
    input cp_table table,
    input archInfoPoints_e level_points[5],
    output logic [2:0] lowest_level,
    output logic [2:0] highest_level
);
    bit found_any = 0;
    
    // Find lowest level (first existing level)
    lowest_level = 0;  // Default if none found
    for (int i = 0; i < 5; i++) begin
        if (table.exists(level_points[i])) begin
            lowest_level = i + 1;  // Convert to 1-based indexing
            found_any = 1;
            break;
        end
    end
    
    // Find highest level (last existing level)
    highest_level = 0;  // Default if none found
    if (found_any) begin
        for (int i = 4; i >= 0; i--) begin
            if (table.exists(level_points[i])) begin
                highest_level = i + 1;  // Convert to 1-based indexing
                break;
            end
        end
    end
endfunction


function automatic void classify_csr_instruction(input logic [31:0] instr);

    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [4:0] rd;
    logic [4:0] rs1_or_uimm;

    match_csr_r_instr = 1'b0;
    match_csr_w_instr = 1'b0;

    opcode = instr[6:0];
    if (opcode != OPCODE_SYSTEM)
        return;

    funct3 = instr[14:12];
    if (funct3 == FUNCT3_PRIV)
        return;

    if (!(funct3 inside {FUNCT3_CSRRW, FUNCT3_CSRRS, FUNCT3_CSRRC,
                        FUNCT3_CSRRWI, FUNCT3_CSRRSI, FUNCT3_CSRRCI}))
        return;

    rd                = instr[11:7];
    rs1_or_uimm       = instr[19:15];

    if (rd !=0 ) begin 
        void'($cast(csr_accessed,rd));
    end

    if (funct3 inside {FUNCT3_CSRRW, FUNCT3_CSRRWI}) begin
        if (rd == 0) begin 
            match_csr_r_instr = 0;
            match_csr_w_instr = 1;
        end else begin 
            match_csr_r_instr = 1;
            match_csr_w_instr = 1;
        end
    end else begin 
        if (rs1_or_uimm == 0) begin 
            match_csr_r_instr = 1;
            match_csr_w_instr = 0;
        end else begin 
            match_csr_r_instr = 1;
            match_csr_w_instr = 1;
        end 
    end 

endfunction

function automatic bit is_counter_csr(input logic [11:0] addr, input bit incl_high_half = 0);
    return (addr inside {[CSR_COUNTER_LO:CSR_COUNTER_HI]}) ||
           (incl_high_half && (addr inside {[CSR_COUNTERH_LO:CSR_COUNTERH_HI]}));
endfunction

// Must be called after classify_csr_instruction(), which sets match_csr_r/w_instr.
// The counter number is the low 5 bits of the CSR address for both the 0xc00 block
// and its 0xc80 high-half aliases, so no base-address arithmetic is needed.
function automatic void classify_counter_csr_access(input logic [31:0] instr,
                                                    input logic [63:0] mcounteren_value,
                                                    input logic [63:0] hcounteren_value,
                                                    input logic [63:0] scounteren_value);

    logic [11:0] addr;

    counter_csr_access    = 1'b0;
    counter_csr_index     = 5'b0;
    mcounteren_access_bit = 1'b0;
    hcounteren_access_bit = 1'b0;
    scounteren_access_bit = 1'b0;

    addr = instr[31:20];

    if (!(match_csr_r_instr || match_csr_w_instr))
        return;

    if (!is_counter_csr(addr))
        return;

    counter_csr_access    = 1'b1;
    counter_csr_index     = addr[4:0];
    mcounteren_access_bit = mcounteren_value[counter_csr_index];
    hcounteren_access_bit = hcounteren_value[counter_csr_index];
    scounteren_access_bit = scounteren_value[counter_csr_index];

endfunction

endpackage
`endif
`endif
