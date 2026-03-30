`ifndef COVERAGE_UNSUPPORTED

import cp_pkg::*;

covergroup iext__cg with function sample();

    option.per_instance = 1;
    option.name = "cg_iext";

    iext__general_cp_iext_instr: coverpoint iext_var {                    
        ignore_bins ignore_instrs = {IEXT_DRET, IEXT_EBREAK, IEXT_MNRET, IEXT_MRET};                       
    }

    iext__general_cp_arithmetic_instr: coverpoint instrenum_var {
        bins arithmetic_instrs[]    =   {
            INSTRENUM_ADD,
            INSTRENUM_ADDI,
            INSTRENUM_ADDIW,
            INSTRENUM_ADDW,
            INSTRENUM_AND,
            INSTRENUM_ANDI,
            INSTRENUM_AUIPC,
            INSTRENUM_LUI,
            INSTRENUM_OR,
            INSTRENUM_ORI,
            INSTRENUM_SLL,
            INSTRENUM_SLLI,
            INSTRENUM_SLLIW,
            INSTRENUM_SLLW,
            INSTRENUM_SLT,
            INSTRENUM_SLTI,
            INSTRENUM_SLTIU,
            INSTRENUM_SLTU,
            INSTRENUM_SRA,
            INSTRENUM_SRAI,
            INSTRENUM_SRAIW,
            INSTRENUM_SRAW,
            INSTRENUM_SRL,
            INSTRENUM_SRLI,
            INSTRENUM_SRLIW,
            INSTRENUM_SRLW,
            INSTRENUM_SUB,
            INSTRENUM_SUBW,
            INSTRENUM_XOR,
            INSTRENUM_XORI
        };          
    }

    iext__general_cp_load_instr: coverpoint instrenum_var{
        bins load_instrs[]  =   {
            INSTRENUM_LB,
            INSTRENUM_LBU,
            INSTRENUM_LD,
            INSTRENUM_LH,
            INSTRENUM_LHU,
            INSTRENUM_LW,
            INSTRENUM_LWU
        };
    }

    iext__general_cp_store_instr: coverpoint instrenum_var{
        bins store_instrs[] =   {
            INSTRENUM_SB,
            INSTRENUM_SD,
            INSTRENUM_SH,
            INSTRENUM_SW
        };
    }

    iext__general_cp_conditional_branch_instr: coverpoint instrenum_var{
        bins conditional_branch_instrs[]   =  {
            INSTRENUM_BEQ,
            INSTRENUM_BGE,
            INSTRENUM_BGEU,
            INSTRENUM_BLT,
            INSTRENUM_BLTU,
            INSTRENUM_BNE
        };  
    }

    iext__general_cp_unconditional_branch_instr: coverpoint instrenum_var{
        bins unconditional_branch_instrs[] = {
            INSTRENUM_JAL,
            INSTRENUM_JALR
        };
    }

    iext__general_cp_shift_instr: coverpoint instrenum_var{
        bins shift_instrs[] = {
            INSTRENUM_SLLI,
            INSTRENUM_SRLI,
            INSTRENUM_SRAI
        };    
    }

    iext__general_cp_shift_w_instr: coverpoint instrenum_var{
        bins shift_w_instrs[] = {
            INSTRENUM_SLLIW,
            INSTRENUM_SRLIW,
            INSTRENUM_SRAIW
        };             
    }

    iext__general_cp_system_instr: coverpoint instrenum_var{
        bins system_instrs[] = {
            INSTRENUM_ECALL,
            INSTRENUM_MRET,
            INSTRENUM_SRET
        };              
    }

    iext__general_cp_uformat_instr: coverpoint uformat_var;
    
    iext__general_cp_privilege_modes: coverpoint privilegemode_var {
        bins vals[]     =   {
                                PRIVILEGEMODE_MACHINE, 
                                PRIVILEGEMODE_SUPERVISOR, 
                                PRIVILEGEMODE_USER
        };
    }

    iext__general_cp_special_instr: coverpoint instrenum_var{
        bins special_instr[] = {INSTRENUM_ILLEGAL};
    }

    iext__general_cp_fence_instr: coverpoint instrenum_var{
        bins fence_instr[] = {INSTRENUM_FENCE, INSTRENUM_FENCE_I, INSTRENUM_FENCE_TSO};
    }

    iext__general_addi_hint_instruction: coverpoint Inst[6:0] iff(Inst[14:12]==0){
        bins hint_addi_instr1  = {7'b0010011} iff(Inst[11:7] == 0 && Inst[19:15] != 0);
        bins hint_addi_instr2  = {7'b0010011} iff(Inst[11:7] == 0 && Inst[31:20] != 0);
    }
    
    iext__general_add_hint_instruction: coverpoint instrenum_var{
        bins hint_add_instr1   = {INSTRENUM_ADD} iff(rd==0 && (rs1 != 0));
        bins hint_add_instr2   = {INSTRENUM_ADD} iff(rd==0 && rs1 == 0 && (rs2 < 2 || rs2 > 5));
        bins hint_add_instr3   = {INSTRENUM_ADD} iff(rd==0 && rs1 == 0 && rs2 == 2); 
        bins hint_add_instr4   = {INSTRENUM_ADD} iff(rd==0 && rs1 == 0 && rs2 == 3);
        bins hint_add_instr5   = {INSTRENUM_ADD} iff(rd==0 && rs1 == 0 && rs2 == 4);
        bins hint_add_instr6   = {INSTRENUM_ADD} iff(rd==0 && rs1 == 0 && rs2 == 5);
    }
    
    iext__general_fence_hint_instruction: coverpoint Inst[6:0] iff(Inst[14:12]== 0){
        bins hint_fence_instr1 = {7'b0001111} iff(Inst[11:7]==0 && Inst[19:15] != 0 && Inst[31:28]==0 && (Inst[27:24]==0 || Inst[23:20]==0)); 
        bins hint_fence_instr2 = {7'b0001111} iff(Inst[11:7]!=0 && Inst[19:15] == 0 && Inst[31:28]==0 && (Inst[27:24]==0 || Inst[23:20]==0));
        bins hint_fence_instr3 = {7'b0001111} iff(Inst[11:7]==0 && Inst[19:15] == 0 && Inst[31:28]==0 && Inst[27:24]==0 && Inst[23:20]!=0);
        bins hint_fence_instr4 = {7'b0001111} iff(Inst[11:7]==0 && Inst[19:15] == 0 && Inst[31:28]==0 && Inst[27:24]!=1 && Inst[23:20]==0);
        bins hint_fence_instr5 = {7'b0001111} iff(Inst[11:7]==0 && Inst[19:15] == 0 && Inst[31:28]==0 && Inst[27:24]==1 && Inst[23:20]==0);
    }
    
    iext__general_addi_nop_instruction: coverpoint instrenum_var{
        bins NOP_instr = {INSTRENUM_ADDI} iff(rd==0 && rs1 == 0 && rs2_val == 0);
    }

    iext__general_ras_instruction: coverpoint instrenum_var{
        bins jal_push_ras      = {INSTRENUM_JAL}  iff(rd == 1 || rd == 5);
        bins jalr_none_ras     = {INSTRENUM_JALR} iff((rd != 1 && rd != 5) && (rs1 != 1 && rs1 != 5));
        bins jalr_pop_ras      = {INSTRENUM_JALR} iff((rd != 1 && rd != 5) && (rs1 == 1 || rs1 == 5));
        bins jalr_push_ras     = {INSTRENUM_JALR} iff((rd == 1 || rd == 5) && (rs1 != 1 && rs1 != 5));
        bins jalr_pop_push_ras = {INSTRENUM_JALR} iff((rd == 1 || rd == 5) && (rs1 == 1 || rs1 == 5) && (rs1 != rd));
        bins jalr_push2_ras    = {INSTRENUM_JALR} iff((rd == 1 || rd == 5) && (rs1 == 1 || rs1 == 5) && (rs1 == rd));
    }

    iext__general_cp_imm_20_signed_jal: coverpoint instrenum_var{
        bins jal_imm_sign_0 = {INSTRENUM_JAL} iff (rs1_val[19] == 0);
        bins jal_imm_sign_1 = {INSTRENUM_JAL} iff (rs1_val[19] == 1);
    }

   iext__general_cp_imm_12_signed_instr: coverpoint instrenum_var{
        bins instr_imm_12[] = {
            INSTRENUM_JALR, 
            INSTRENUM_ADDI, 
            INSTRENUM_SLTI, 
            INSTRENUM_XORI, 
            INSTRENUM_ORI, 
            INSTRENUM_ANDI, 
            INSTRENUM_ADDIW
        };
    }
    
    iext__dataset_cp_imm_12_sign_bit: coverpoint rs2_val[11]{
        bins imm_12_sign[] = {0,1};
    }

    iext__dataset_cp_imm_5_Uminmax: coverpoint rs2_val[4:0] iff(rd!=0){
        bins imm_5_minmax[] = {UMIN5,UMAX5};
    }

    iext__dataset_cp_imm_6_Uminmax: coverpoint rs2_val[5:0] iff(rd!=0){
        bins imm_6_minmax[] = {UMIN6,UMAX6};
    }

    iext__dataset_cp_imm_12_Uminmax: coverpoint rs2_val[11:0] iff(rd!=0){
        bins imm_12_minmax[] = {UMIN12,UMAX12};
    }

    iext__dataset_cp_imm_20_Uminmax: coverpoint rs1_val[19:0] iff(rd!=0){ 
        bins imm_19_minmax[] = {UMIN20,UMAX20}; 
    }

    iext__general_cp_imm_12_unsigned_instr: coverpoint instrenum_var{
        bins instr_imm_12[] = {
            INSTRENUM_ADDI, 
            INSTRENUM_SLTI, 
            INSTRENUM_SLTIU, 
            INSTRENUM_XORI, 
            INSTRENUM_ORI, 
            INSTRENUM_ANDI, 
            INSTRENUM_ADDIW
        };
    }

    iext__general_cp_imm_20_unsigned_instr: coverpoint instrenum_var{
        bins instr_imm_20[] = {
            INSTRENUM_LUI, 
            INSTRENUM_AUIPC
        }; 
    }

    iext__dataset_cp_imm_12_Sminmax: coverpoint rs2_val[11:0] iff(rd!=0){
        bins imm_12_minmax_store[]   = {SMIN12, SMAX12} iff(instrenum_var == INSTRENUM_SB    || instrenum_var == INSTRENUM_SH  || instrenum_var == INSTRENUM_SH  || instrenum_var == INSTRENUM_SD );
        bins imm_12_minmax_load[]    = {SMIN12, SMAX12} iff(instrenum_var == INSTRENUM_LB    || instrenum_var == INSTRENUM_LH  || instrenum_var == INSTRENUM_LH  || instrenum_var == INSTRENUM_LD );
        bins imm_12_minmax_logical[] = {SMIN12, SMAX12} iff(instrenum_var == INSTRENUM_XORI  || instrenum_var == INSTRENUM_ORI || instrenum_var == INSTRENUM_ANDI);
        bins imm_12_minmax_add[]     = {SMIN12, SMAX12} iff(instrenum_var == INSTRENUM_ADDIW || instrenum_var == INSTRENUM_ADDI);
        bins imm_12_minmax_slti[]    = {SMIN12, SMAX12} iff(instrenum_var == INSTRENUM_SLTI);
    }

    iext__dataset_cp_imm_12_Sminmax_branch: coverpoint rs2_val[11:0]{
        bins imm_12_minmax_branch[]  = {SMIN12, SMAX12 - 1} iff(instrenum_var == INSTRENUM_BEQ   || instrenum_var == INSTRENUM_BNE || instrenum_var == INSTRENUM_BLT || instrenum_var == INSTRENUM_BGE);
    }

    iext__dataset_cp_imm_12_Sminmax_j: coverpoint rs2_val[11:0]{
        bins imm_12_minmax_jalr[]    = {SMIN12, SMAX12} iff(instrenum_var == INSTRENUM_JALR);
    }

    iext__dataset_cp_imm_20_Sminmax_j: coverpoint Inst{ 
        bins jal_min_imm_signed = {'h8000006f} iff(instrenum_var == INSTRENUM_JAL);
        bins jal_max_imm_signed = {'h7ffff06f} iff(instrenum_var == INSTRENUM_JAL);
    }

    iext__dataset_cp_imm_reordering_jal: coverpoint instrenum_var{ 
        bins imm_reordering_jal1 = {INSTRENUM_JAL} iff(rs2_val[19]!=rs2_val[10]); 
        bins imm_reordering_jal2 = {INSTRENUM_JAL} iff(rs2_val[19]!=rs2_val[9]); 
        bins imm_reordering_jal3 = {INSTRENUM_JAL} iff(rs2_val[0] !=rs2_val[10]); 
        bins imm_reordering_jal4 = {INSTRENUM_JAL} iff(rs2_val[10]!=rs2_val[18]); 
        bins imm_reordering_jal5 = {INSTRENUM_JAL} iff(rs2_val[11]!=rs2_val[19]);

    }

    iext__dataset_cp_imm_reordering_store: coverpoint instrenum_var iff(rd!=0){
        bins imm_reordering_store1 = {
            INSTRENUM_SB,
            INSTRENUM_SD,
            INSTRENUM_SH,
            INSTRENUM_SW
        } iff(rs2_val[11]!=rs2_val[4]);
        bins imm_reordering_store2 = {
            INSTRENUM_SB,
            INSTRENUM_SD,
            INSTRENUM_SH,
            INSTRENUM_SW
        } iff(rs2_val[5]!=rs2_val[0]);
        bins imm_reordering_store3 = {
            INSTRENUM_SB,
            INSTRENUM_SD,
            INSTRENUM_SH,
            INSTRENUM_SW
        } iff(rs2_val[5]!=rs2_val[4]);
    }

    iext__dataset_cp_shift_instr_imm_reserved: coverpoint Inst[6:0]{
        bins imm_reserved_slli        = {7'b0010011} iff(Inst[14:12]==3'b001 && Inst[31:26]!=6'b000000);
        bins imm_reserved_srli_srai   = {7'b0010011} iff(Inst[14:12]==3'b101 && Inst[31:26]!=6'b000000 && Inst[31:26]!=6'b010000);
        bins imm_reserved_slliw       = {7'b0011011} iff(Inst[14:12]==3'b001 && Inst[31:25]!=7'b0000000);
        bins imm_reserved_srliw_sraiw = {7'b0011011} iff(Inst[14:12]==3'b101 && Inst[31:25]!=7'b0000000 && Inst[31:25]!=7'b0100000);
    }

    iext__dataset_cp_shift_instr_imm_unused: coverpoint instrenum_var{
        bins imm_unused_sll = {INSTRENUM_SLL} iff(rs2_val[63:6]!=0);
        bins imm_unused_srl = {INSTRENUM_SRL} iff(rs2_val[63:6]!=0);
        bins imm_unused_sra = {INSTRENUM_SLL} iff(rs2_val[63:6]!=0);

        bins imm_unused_sllw = {INSTRENUM_SLLW} iff(rs2_val[63:5]!=0);
        bins imm_unused_srlw = {INSTRENUM_SRLW} iff(rs2_val[63:5]!=0);
        bins imm_unused_sraw = {INSTRENUM_SLLW} iff(rs2_val[63:5]!=0);
    }

    iext__dataset_cp_fence_instr_fm_reserved: coverpoint Inst[6:0]{
        bins fence_fm_normal = {7'b000111} iff(Inst[31:28] == 7'b0000);
        bins fence_fm_tso = {7'b000111} iff(Inst[31:28] != 7'b0000);
        bins fence_fm_reserved = {7'b000111} iff(Inst[31:28] != 7'b0000 && Inst[31:28] != 7'b1000);
    }

    iext__dataset_cp_fence_instr_pred_succ: coverpoint Inst[6:0] iff(Inst[31:28] != 7'b0000) {
        bins fence_pi = {7'b000111} iff(Inst[27] == 1); 
        bins fence_po = {7'b000111} iff(Inst[26] == 1); 
        bins fence_pr = {7'b000111} iff(Inst[25] == 1); 
        bins fence_pw = {7'b000111} iff(Inst[24] == 1); 
        bins fence_si = {7'b000111} iff(Inst[23] == 1); 
        bins fence_so = {7'b000111} iff(Inst[22] == 1); 
        bins fence_sr = {7'b000111} iff(Inst[21] == 1); 
        bins fence_sw = {7'b000111} iff(Inst[20] == 1); 
    }

    iext__dataset_cp_imm_lsb_toggle: coverpoint instrenum_var{
        bins jal_imm_bit_1 = {INSTRENUM_JAL} iff(rs1_val[1] == 1);
        bins jalr_imm_bit_0 = {INSTRENUM_JALR} iff(rs2_val[0] == 1);
        bins jalr_imm_bit_1 = {INSTRENUM_JALR} iff(rs2_val[1] == 1);
    }

    iext__general_cr_arithmetic_priv:           cross iext__general_cp_privilege_modes, iext__general_cp_arithmetic_instr;
    iext__general_cr_conditional_branch_priv:   cross iext__general_cp_privilege_modes, iext__general_cp_conditional_branch_instr;
    iext__general_cr_unconditional_branch_priv: cross iext__general_cp_privilege_modes, iext__general_cp_unconditional_branch_instr;
    iext__general_cr_load_priv:                 cross iext__general_cp_privilege_modes, iext__general_cp_load_instr;
    iext__general_cr_store_priv:                cross iext__general_cp_privilege_modes, iext__general_cp_store_instr;
    iext__general_cr_system_instr_priv:         cross iext__general_cp_privilege_modes, iext__general_cp_system_instr;  
    iext__general_cr_special_instr_priv:        cross iext__general_cp_privilege_modes, iext__general_cp_special_instr;
    iext__general_cr_fence_instr_priv:          cross iext__general_cp_privilege_modes, iext__general_cp_fence_instr;
    iext__general_cr_nop_instr_priv:            cross iext__general_cp_privilege_modes, iext__general_addi_nop_instruction;

    iext__dataset_cr_store_imm_sign_bit:              cross iext__dataset_cp_imm_12_sign_bit, iext__general_cp_store_instr;
    iext__dataset_cr_load_imm_sign_bit:               cross iext__dataset_cp_imm_12_sign_bit, iext__general_cp_load_instr;
    iext__dataset_cr_conditional_branch_imm_sign_bit: cross iext__dataset_cp_imm_12_sign_bit, iext__general_cp_conditional_branch_instr;
    iext__dataset_cr_instr_12_imm_sign_bit:           cross iext__dataset_cp_imm_12_sign_bit, iext__general_cp_imm_12_signed_instr;

    iext__dataset_cr_store_12_imm_Uminmax:  cross iext__dataset_cp_imm_12_Uminmax, iext__general_cp_store_instr;
    iext__dataset_cr_load_12_imm_Uminmax:   cross iext__dataset_cp_imm_12_Uminmax, iext__general_cp_load_instr;
    iext__dataset_cr_instr_12_imm_Uminmax:  cross iext__dataset_cp_imm_12_Uminmax, iext__general_cp_imm_12_unsigned_instr;
    iext__dataset_cr_instr_20_imm_Uminmax:  cross iext__dataset_cp_imm_20_Uminmax, iext__general_cp_imm_20_unsigned_instr;
    iext__dataset_cr_shift_6_imm_Uminmax:   cross iext__dataset_cp_imm_6_Uminmax,  iext__general_cp_shift_instr;
    iext__dataset_cr_shift_w_5_imm_Uminmax: cross iext__dataset_cp_imm_5_Uminmax,  iext__general_cp_shift_w_instr;

    iext__dataset_cp_comparision_instr_rs1_equal_rs2: coverpoint instrenum_var iff(rd!=0){
        bins comparision_instrs[] = {
            INSTRENUM_SLT,
            INSTRENUM_SLTI,
            INSTRENUM_SLTIU,
            INSTRENUM_SLTU
        } iff(rs1_val[62:0]==rs2_val[62:0]);
    }
    iext__dataset_cp_comparision_instr_rs1_greater_rs2: coverpoint instrenum_var iff(rd!=0){
        bins comparision_instrs[] = {
            INSTRENUM_SLT,
            INSTRENUM_SLTI,
            INSTRENUM_SLTIU,
            INSTRENUM_SLTU
        } iff(rs1_val[62:0]>rs2_val[62:0]);
    }
    iext__dataset_cp_comparision_instr_rs1_less_rs2: coverpoint instrenum_var iff(rd!=0){
        bins comparision_instrs[] = {
            INSTRENUM_SLT,
            INSTRENUM_SLTI,
            INSTRENUM_SLTIU,
            INSTRENUM_SLTU
        } iff(rs1_val[62:0]<rs2_val[62:0]);
    }

    iext__dataset_cp_branch_instr_rs1_equal_rs2: coverpoint instrenum_var{
        bins conditional_branch_instrs[] = {
            INSTRENUM_BEQ,
            INSTRENUM_BGE,
            INSTRENUM_BGEU,
            INSTRENUM_BLT,
            INSTRENUM_BLTU,
            INSTRENUM_BNE
        } iff(rd_val[62:0]==rs1_val[62:0]);
    }
    iext__dataset_cp_branch_instr_rs1_greater_rs2: coverpoint instrenum_var{
        bins conditional_branch_instrs[] = {
            INSTRENUM_BEQ,
            INSTRENUM_BGE,
            INSTRENUM_BGEU,
            INSTRENUM_BLT,
            INSTRENUM_BLTU,
            INSTRENUM_BNE
        } iff(rd_val[62:0]>rs1_val[62:0]);
    }
    iext__dataset_cp_branch_instr_rs1_less_rs2: coverpoint instrenum_var{
        bins conditional_branch_instrs[] = {
            INSTRENUM_BEQ,
            INSTRENUM_BGE,
            INSTRENUM_BGEU,
            INSTRENUM_BLT,
            INSTRENUM_BLTU,
            INSTRENUM_BNE
        } iff(rd_val[62:0]<rs1_val[62:0]);
    }

    iext__dataset_cp_rd_sign_64bit:  coverpoint rd_val[63]  {bins rd_sign[] = {1,0};}
    iext__dataset_cp_rs1_sign_64bit: coverpoint rs1_val[63] {bins rs1_sign[] = {1,0};}
    iext__dataset_cp_rs2_sign_64bit: coverpoint rs2_val[63] {bins rs2_sign[] = {1,0};}
    iext__dataset_cp_rs1_sign_32bit: coverpoint rs1_val[31] {bins rs1_sign[] = {1,0};}
    iext__dataset_cp_rs2_sign_32bit: coverpoint rs2_val[31] {bins rs2_sign[] = {1,0};}
    iext__dataset_cp_rs2_sign_5bit:  coverpoint rs2_val[4]  {bins rs2_sign[] = {1,0};}

    iext__dataset_cr_branch_signed_instr_rs1_equal_rs2:   cross iext__dataset_cp_rd_sign_64bit, iext__dataset_cp_rs1_sign_64bit, iext__dataset_cp_branch_instr_rs1_equal_rs2;
    iext__dataset_cr_branch_signed_instr_rs1_greater_rs2: cross iext__dataset_cp_rd_sign_64bit, iext__dataset_cp_rs1_sign_64bit, iext__dataset_cp_branch_instr_rs1_greater_rs2;
    iext__dataset_cr_branch_signed_instr_rs1_less_rs2:    cross iext__dataset_cp_rd_sign_64bit, iext__dataset_cp_rs1_sign_64bit, iext__dataset_cp_branch_instr_rs1_less_rs2;

    iext__dataset_cr_comparision_signed_instr_rs1_equal_rs2:   cross iext__dataset_cp_rs1_sign_64bit, iext__dataset_cp_rs2_sign_64bit, iext__dataset_cp_comparision_instr_rs1_equal_rs2;
    iext__dataset_cr_comparision_signed_instr_rs1_greater_rs2: cross iext__dataset_cp_rs1_sign_64bit, iext__dataset_cp_rs2_sign_64bit, iext__dataset_cp_comparision_instr_rs1_greater_rs2;
    iext__dataset_cr_comparision_signed_instr_rs1_less_rs2:    cross iext__dataset_cp_rs1_sign_64bit, iext__dataset_cp_rs2_sign_64bit, iext__dataset_cp_comparision_instr_rs1_less_rs2;

    iext__dataset_cp_store_rs2_sign_8bit:  coverpoint rd_val[7] iff(rd!=0){
        bins rs2_sign[] = {1,0} iff(instrenum_var == INSTRENUM_SB);
    }
    iext__dataset_cp_store_rs2_sign_16bit:  coverpoint rd_val[15] iff(rd!=0){
        bins rs2_sign[] = {1,0} iff(instrenum_var == INSTRENUM_SH);
    }
    iext__dataset_cp_store_rs2_sign_32bit:  coverpoint rd_val[31] iff(rd!=0){
        bins rs2_sign[] = {1,0} iff(instrenum_var == INSTRENUM_SW);
    }
    iext__dataset_cp_store_rs2_sign_64bit:  coverpoint rd_val[63] iff(rd!=0){
        bins rs2_sign[] = {1,0} iff(instrenum_var == INSTRENUM_SD);
    }

    iext__dataset_cr_branch_rs1_rs2_sign: cross iext__dataset_cp_rd_sign_64bit, iext__dataset_cp_rs1_sign_64bit, iext__general_cp_conditional_branch_instr; 

    iext__dataset_cp_rs1_rs2_signed_instr: coverpoint instrenum_var iff(rd!=0){
        bins instrenum_var[] = {INSTRENUM_ADD, INSTRENUM_SUB, INSTRENUM_SLT, INSTRENUM_SRA};
    }
    iext__dataset_cp_rs1_rs2_signed_w_instr: coverpoint instrenum_var iff(rd!=0){
        bins instrenum_var[] = {INSTRENUM_ADDW, INSTRENUM_SUBW};
    }
    iext__dataset_cp_rs1_signed_instr: coverpoint instrenum_var iff(rd!=0){
        bins instrenum_var[] = {INSTRENUM_ADDI, INSTRENUM_SLTI, INSTRENUM_SLLI};
    }
    iext__dataset_cr_instr_rs1_rs2_sign:   cross iext__dataset_cp_rs1_sign_64bit, iext__dataset_cp_rs2_sign_64bit, iext__dataset_cp_rs1_rs2_signed_instr;
    iext__dataset_cr_instr_w_rs1_rs2_sign: cross iext__dataset_cp_rs1_sign_32bit, iext__dataset_cp_rs2_sign_32bit, iext__dataset_cp_rs1_rs2_signed_w_instr;
    iext__dataset_cr_instr_w_rs1_sign:     cross iext__dataset_cp_rs1_sign_64bit, iext__dataset_cp_rs1_signed_instr;
    iext__dataset_cr_shift_rs1_rs2_sign:   cross iext__dataset_cp_rs1_sign_32bit, iext__dataset_cp_rs2_sign_5bit,  iext__general_cp_shift_w_instr;

    iext__dataset_cp_store_rs2_minmax_8bit: coverpoint rd_val[7:0] iff(rd!=0){
        bins rs2_minmax[] = {UMIN8, UMAX8, SMIN8, SMAX8} iff(instrenum_var == INSTRENUM_SB);
    }
    iext__dataset_cp_store_rs2_minmax_16bit: coverpoint rd_val[15:0] iff(rd!=0){
        bins rs2_minmax[] = {UMIN16, UMAX16, SMIN16, SMAX16} iff(instrenum_var == INSTRENUM_SH);
    }
    iext__dataset_cp_store_rs2_minmax_32bit: coverpoint rd_val[31:0] iff(rd!=0){
        bins rs2_minmax[] = {UMIN32, UMAX32, SMIN32, SMAX32} iff(instrenum_var == INSTRENUM_SW);
    }
    iext__dataset_cp_store_rs2_minmax_64bit: coverpoint rd_val[63:0] iff(rd!=0){
        bins rs2_minmax[] = {UMIN64, UMAX64, SMIN64, SMAX64} iff(instrenum_var == INSTRENUM_SD);
    }
    iext__dataset_cp_branch_rs1_Sminmax_64bit: coverpoint rd_val{ 
        bins rs1_minmax[] = {SMIN64, SMAX64} iff(instrenum_var == INSTRENUM_BEQ || instrenum_var == INSTRENUM_BNE || instrenum_var == INSTRENUM_BLT || instrenum_var == INSTRENUM_BGE);
    }

    iext__dataset_cp_branch_rs2_Sminmax_64bit: coverpoint rs1_val{ 
        bins rs2_minmax[] = {SMIN64, SMAX64} iff(instrenum_var == INSTRENUM_BEQ || instrenum_var == INSTRENUM_BNE || instrenum_var == INSTRENUM_BLT || instrenum_var == INSTRENUM_BGE);
    }
    iext__dataset_cr_branch_rs1_Uminmax: cross iext__dataset_cp_rs1_sign_64bit, iext__general_cp_conditional_branch_instr;
    iext__dataset_cr_branch_rs2_Uminmax: cross iext__dataset_cp_rs2_sign_64bit, iext__general_cp_conditional_branch_instr;

    iext__dataset_cp_arithmetic_rs1_Uminmax_64bit: coverpoint rs1_val iff(rd!=0){
        bins rs1_minmax_add[]     = {UMIN64, UMAX64} iff(instrenum_var == INSTRENUM_ADD || instrenum_var == INSTRENUM_ADDI);
        bins rs1_minmax_sub[]     = {UMIN64, UMAX64} iff(instrenum_var == INSTRENUM_SUB);
        bins rs1_minmax_slt[]     = {UMIN64, UMAX64} iff(instrenum_var == INSTRENUM_SLT || instrenum_var == INSTRENUM_SLTI || instrenum_var == INSTRENUM_SLTU || instrenum_var == INSTRENUM_SLTIU);
        bins rs1_minmax_logical[] = {UMIN64, UMAX64} iff(instrenum_var == INSTRENUM_XOR || instrenum_var == INSTRENUM_OR || instrenum_var == INSTRENUM_AND || instrenum_var == INSTRENUM_XORI || instrenum_var == INSTRENUM_ORI || instrenum_var == INSTRENUM_ANDI);
        bins rs1_minmax_sll[]     = {UMIN64, UMAX64} iff(instrenum_var == INSTRENUM_SLL || instrenum_var == INSTRENUM_SLLI);
        bins rs1_minmax_srl[]     = {UMIN64, UMAX64} iff(instrenum_var == INSTRENUM_SRL || instrenum_var == INSTRENUM_SRLI);
        bins rs1_minmax_sra[]     = {UMIN64, UMAX64} iff(instrenum_var == INSTRENUM_SRA || instrenum_var == INSTRENUM_SRAI);
    }

    iext__dataset_cp_arithmetic_rs1_Sminmax_64bit: coverpoint rs1_val iff(rd!=0){
        bins rs1_minmax_add[]     = {SMIN64, SMAX64} iff(instrenum_var == INSTRENUM_ADD || instrenum_var == INSTRENUM_ADDI);
        bins rs1_minmax_sub[]     = {SMIN64, SMAX64} iff(instrenum_var == INSTRENUM_SUB);
        bins rs1_minmax_slt[]     = {SMIN64, SMAX64} iff(instrenum_var == INSTRENUM_SLT || instrenum_var == INSTRENUM_SLTI);
        bins rs1_minmax_logical[] = {SMIN64, SMAX64} iff(instrenum_var == INSTRENUM_XOR || instrenum_var == INSTRENUM_OR || instrenum_var == INSTRENUM_AND || instrenum_var == INSTRENUM_XORI || instrenum_var == INSTRENUM_ORI || instrenum_var == INSTRENUM_ANDI);
        bins rs1_minmax_sra[]     = {SMIN64, SMAX64} iff(instrenum_var == INSTRENUM_SRA || instrenum_var == INSTRENUM_SRAI); 
    }

    iext__dataset_cp_arithmetic_rs1_minmax_32bit: coverpoint rs1_val[31:0] iff(rd!=0){
        bins rs1_minmax_add[]     = {UMIN32, UMAX32, SMIN32, SMAX32} iff(instrenum_var == INSTRENUM_ADDW || instrenum_var == INSTRENUM_ADDIW);
        bins rs1_minmax_sub[]     = {UMIN32, UMAX32, SMIN32, SMAX32} iff(instrenum_var == INSTRENUM_SUBW);
        bins rs1_minmax_sll[]     = {UMIN32, UMAX32, SMIN32, SMAX32} iff(instrenum_var == INSTRENUM_SLLW || instrenum_var == INSTRENUM_SLLIW);
        bins rs1_minmax_srl[]     = {UMIN32, UMAX32, SMIN32, SMAX32} iff(instrenum_var == INSTRENUM_SRLW || instrenum_var == INSTRENUM_SRLIW);
        bins rs1_minmax_sra[]     = {UMIN32, UMAX32, SMIN32, SMAX32} iff(instrenum_var == INSTRENUM_SRAW || instrenum_var == INSTRENUM_SRAIW);
    }

    iext__dataset_cp_arithmetic_rs2_Uminmax_64bit: coverpoint rs2_val[31:0] iff(rd!=0){
        bins rs2_minmax_add[]     = {UMIN64, UMAX64} iff(instrenum_var == INSTRENUM_ADD);
        bins rs2_minmax_sub[]     = {UMIN64, UMAX64} iff(instrenum_var == INSTRENUM_SUB);
        bins rs2_minmax_slt[]     = {UMIN64, UMAX64} iff(instrenum_var == INSTRENUM_SLT || instrenum_var == INSTRENUM_SLTU );
        bins rs2_minmax_logical[] = {UMIN64, UMAX64} iff(instrenum_var == INSTRENUM_XOR || instrenum_var == INSTRENUM_OR || instrenum_var == INSTRENUM_AND);
        bins rs2_minmax_sll[]     = {UMIN64, UMAX64} iff(instrenum_var == INSTRENUM_SLL);
        bins rs2_minmax_srl[]     = {UMIN64, UMAX64} iff(instrenum_var == INSTRENUM_SRL);
        bins rs2_minmax_sra[]     = {UMIN64, UMAX64} iff(instrenum_var == INSTRENUM_SRA);
    }

    iext__dataset_cp_arithmetic_rs2_Sminmax_64bit: coverpoint rs2_val iff(rd!=0){
        bins rs2_minmax_add[]     = {SMIN64, SMAX64} iff(instrenum_var == INSTRENUM_ADD);
        bins rs2_minmax_sub[]     = {SMIN64, SMAX64} iff(instrenum_var == INSTRENUM_SUB);
        bins rs2_minmax_slt[]     = {SMIN64, SMAX64} iff(instrenum_var == INSTRENUM_SLT);
        bins rs2_minmax_logical[] = {SMIN64, SMAX64} iff(instrenum_var == INSTRENUM_XOR || instrenum_var == INSTRENUM_OR || instrenum_var == INSTRENUM_AND);
    }

    iext__dataset_cp_arithmetic_rs2_minmax_32bit: coverpoint rs2_val[31:0] iff(rd!=0){
        bins rs2_minmax_add[]     = {UMIN32, UMAX32, SMIN32, SMAX32} iff(instrenum_var == INSTRENUM_ADDW);
        bins rs2_minmax_sub[]     = {UMIN32, UMAX32, SMIN32, SMAX32} iff(instrenum_var == INSTRENUM_SUBW);
    }

    iext__dataset_cp_arithmetic_rs2_Uminmax_5bit: coverpoint rs2_val[4:0] iff(rd!=0){
        bins rs2_minmax_sll[]     = {UMIN5, UMAX5} iff(instrenum_var == INSTRENUM_SLLW);
        bins rs2_minmax_srl[]     = {UMIN5, UMAX5} iff(instrenum_var == INSTRENUM_SRLW);
        bins rs2_minmax_sra[]     = {UMIN5, UMAX5} iff(instrenum_var == INSTRENUM_SRAW);
    }

    iext__dataset_cp_arithmetic_overflow: coverpoint instrenum_var iff(rd!=0){
        bins add_rs1_Umax   = {INSTRENUM_ADD}   iff(rs1_val==UMAX64 && rs2_val[63]==0 && rs2_val[62:0]!=0);
        bins add_rs1_Smax   = {INSTRENUM_ADD}   iff(rs1_val==SMAX64 && rs2_val[63]==0 && rs2_val[62:0]!=0);
        bins add_rs2_Umax   = {INSTRENUM_ADD}   iff(rs1_val[63]==0 && rs1_val[62:0]!=0 && rs2_val==UMAX64);
        bins add_rs2_Smax   = {INSTRENUM_ADD}   iff(rs1_val[63]==0 && rs1_val[62:0]!=0 && rs2_val==SMAX64);

        bins addw_rs1_Umax  = {INSTRENUM_ADDW}  iff(rs1_val[31:0]==UMAX32 && rs2_val[31]==0 && rs2_val[30:0]!=0);
        bins addw_rs1_Smax  = {INSTRENUM_ADDW}  iff(rs1_val[31:0]==SMAX32 && rs2_val[31]==0 && rs2_val[30:0]!=0);
        bins addw_rs2_Umax  = {INSTRENUM_ADDW}  iff(rs1_val[31]==0 && rs1_val[30:0]!=0 && rs2_val[31:0]==UMAX32);
        bins addw_rs2_Smax  = {INSTRENUM_ADDW}  iff(rs1_val[31]==0 && rs1_val[30:0]!=0 && rs2_val[31:0]==SMAX32);

        bins addi_rs1_Umax  = {INSTRENUM_ADDI}  iff(rs1_val==UMAX64 && rs2_val[11]==0 && rs2_val[10:0]!=0);
        bins addi_rs1_Smax  = {INSTRENUM_ADDI}  iff(rs1_val==SMAX64 && rs2_val[11]==0 && rs2_val[10:0]!=0);
        bins addi_rs2_Umax  = {INSTRENUM_ADDI}  iff(rs1_val>UMAX64-UMAX12 && rs2_val[11:0]==UMAX12);
        bins addi_rs2_Smax  = {INSTRENUM_ADDI}  iff(rs1_val[63]==0 && rs1_val>(SMAX64-SMAX12) && rs2_val[11:0]==SMAX12);

        bins addiw_rs1_Umax = {INSTRENUM_ADDIW} iff(rs1_val[31:0]==UMAX32 && rs2_val[11]==0 && rs2_val[10:0]!=0);
        bins addiw_rs1_Smax = {INSTRENUM_ADDIW} iff(rs1_val[31:0]==SMAX32 && rs2_val[11]==0 && rs2_val[10:0]!=0);
        bins addiw_rs2_Umax = {INSTRENUM_ADDIW} iff(rs1_val[31:0]>UMAX32-UMAX12 && rs2_val[11:0]==UMAX12);
        bins addiw_rs2_Smax = {INSTRENUM_ADDIW} iff(rs1_val[31]==0 && rs1_val[31:0]>(SMAX32-SMAX12) && rs2_val[11:0]==SMAX12);

        bins sub_rs1_Umax  = {INSTRENUM_SUB} iff(rs1_val==UMAX64 && rs2_val[63]==0 && rs2_val[62:0]!=0);
        bins sub_rs2_Umin  = {INSTRENUM_SUB} iff(rs1_val[63]==0 && rs2_val==UMIN64);
        bins sub_rs1_Smax  = {INSTRENUM_SUB} iff(rs1_val==SMAX64 && rs2_val[63]==0 && rs2_val[62:0]!=0);
        bins sub_rs2_Smin  = {INSTRENUM_SUB} iff(rs1_val[63]==0 && rs2_val==SMIN64);
    }
    åå
    iext__dataset_cp_arithmetic_underflow: coverpoint instrenum_var iff(rd!=0){
        bins add_rs1_Smin   = {INSTRENUM_ADD}   iff(rs1_val==SMIN64 && rs2_val[63]==1);
        bins addw_rs1_Smin  = {INSTRENUM_ADDW}  iff(rs1_val[31:0]==SMIN32 && rs2_val[31]==1);
        bins addi_rs1_Smin  = {INSTRENUM_ADDI}  iff(rs1_val==SMIN64 && rs2_val[11]==1);
        bins addiw_rs1_Smin = {INSTRENUM_ADDIW} iff(rs1_val[31:0]==SMIN32 && rs2_val[11]==1);

        bins add_rs2_Smin   = {INSTRENUM_ADD}   iff(rs1_val[63]==1 && rs2_val==SMIN64);
        bins addw_rs2_Smin  = {INSTRENUM_ADDW}  iff(rs1_val[31]==1 && rs2_val[31:0]==SMIN32);
        bins addi_rs2_Smin  = {INSTRENUM_ADDI}  iff(rs1_val[63]==1 && rs1_val>SMIN64-SMIN12 && rs2_val[11:0]==SMIN12);
        bins addiw_rs2_Smin = {INSTRENUM_ADDIW} iff(rs1_val[31]==1 && rs1_val[31:0]>SMIN32-SMIN12 && rs2_val[11:0]==SMIN12);

        bins sub_rs1_Umin  = {INSTRENUM_SUB} iff(rs1_val==UMIN64 && rs2_val[63]==0);
        bins sub_rs2_Umax  = {INSTRENUM_SUB} iff(rs1_val[63]==0 && rs2_val==UMAX64);
        bins sub_rs1_rs2   = {INSTRENUM_SUB} iff(rs1_val < rs2_val);
        bins sub_rs1_Smin  = {INSTRENUM_SUB} iff(rs1_val==SMIN64 && rs2_val[63]==0);
        bins sub_rs2_Smax  = {INSTRENUM_SUB} iff(rs1_val[63]==1 && rs1_val[62:0]>1 && rs2_val==SMAX64);
    }

    iext__dataset_cp_shift_overflow: coverpoint instrenum_var iff(rd!=0){
        bins shift_left[]        = {INSTRENUM_SLL,  INSTRENUM_SLLI } iff(rs1_val[63]==1 && rs2_val!=0);
        bins shift_left_w[]      = {INSTRENUM_SLLW, INSTRENUM_SLLIW} iff(rs1_val[31]==1 && rs2_val!=0);
        bins shift_right_pos[]   = {INSTRENUM_SRA,  INSTRENUM_SRAI } iff(rs1_val[63]==1 && rs2_val!=0);
        bins shift_right_neg[]   = {INSTRENUM_SRA,  INSTRENUM_SRAI } iff(rs1_val[63]==0 && rs2_val!=0);
        bins shift_right_pos_w[] = {INSTRENUM_SRAW, INSTRENUM_SRAIW} iff(rs1_val[31]==1 && rs2_val!=0);
        bins shift_right_neg_w[] = {INSTRENUM_SRAW, INSTRENUM_SRAIW} iff(rs1_val[31]==0 && rs2_val!=0);
        bins shift_right[]       = {INSTRENUM_SRL,  INSTRENUM_SRLI,  INSTRENUM_SRA,  INSTRENUM_SRAI } iff(rs1_val[0] ==1 && rs2_val!=0);
        bins shift_right_w[]     = {INSTRENUM_SRLW, INSTRENUM_SRLIW, INSTRENUM_SRAW, INSTRENUM_SRAIW} iff(rs1_val[0] ==1 && rs2_val!=0);
    }
endgroup

`endif
