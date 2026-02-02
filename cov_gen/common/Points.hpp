#pragma once

namespace ArchCov
{
  // Entry description
  enum class Point {
      
      // Instruction Encoding
      HartIndex,                                  //Hart ID 
      InstId,                                     // instruction id
      Inst,                                       // actual encoding (32b)
      Rm,                                         // Rounding Mode field
      Op0, Op1, Op2, Op3,                         // Operand IDs. Eg For Integer Instructions, Op0 is rs1 id, Op1 is rs2 id etc 
      Op0Val, Op1Val, Op2Val, Op3Val,             // Operand Values. Eg For Integer Instructions, Op0Val is rs1 value, Op1Val is rs2 value etc 
      BrTaken,                                    // Branch Taken. 1 if branch is taken, 0 if branch is not taken

      // Privileges
      PrivilegeMode,                              // Current Privilege Mode. 0 for User Mode, 1 for Supervisor Mode, 2 for Machine Mode
      NextPrivilegeMode,                          // Next Privilege Mode.    0 for User Mode, 1 for Supervisor Mode, 2 for Machine Mode
      DebugMode,                                  // Debug Mode.             0 for No Debug, 1 for Debug
      NextDebugMode,                              // Next Debug Mode.        0 for No Debug, 1 for Debug
      NumVectorPagesAccessed,                     // Number of Vector Pages Accessed. Number of vector pages accessed by the instruction

      // CSRs
      CsrNum, CsrValue,                           //CSR Number is the 12 bit address of the CSR, CSR Value is the value of the CSR

      // Interrupts/Exceptions
      Interrupt,                                  // Interrupt Cause. 0 for No Interrupt, 1 for Interrupt
      Exception,                                  // Exception Cause. 0 for No Exception, 1 for Exception
    
      // Program Counter
      VirtPc,                                     // VirtPc is the virtual program counter (Virtual Address of the current instruction)
      PhysPc,                                     // PhysPc is the physical program counter (Physical Address of the current instruction)
      NextVirtPc,                                 // NextVirtPc is the next virtual program counter (Virtual Address of the next instruction)

      // Load/Store
      VirtLdStAddr,                               // VirtLdStAddr is the virtual load/store address 
      PhysLdStAddr,                               // PhysLdStAddr is the physical load/store address 
      LastStoreValue,                             // LastStoreValue is the value of the last store
      LdStMisal,                                  // LdStMisal is the load/store misalignment. 1 if the load/store is misaligned, 0 if the load/store is aligned
    
      // LR/SC
      ValidLR,                                    // ValidLR is the valid load/store address. 1 if the load/store is valid, 0 if the load/store is not valid
      CancelLrCause,                              // CancelLrCause is the cancel load/store cause.
      // CancelLrCause values and causes:
      //   Value | Cause
      //   ------|--------------------------------------------------------
      //   0     | CANCELLRCAUSE_NONE - No cancellation
      //   1     | CANCELLRCAUSE_SC - Store-Conditional from same hart
      //   2     | CANCELLRCAUSE_STORE - Store/SC from another hart
      //   3     | CANCELLRCAUSE_RESET - System reset occurred
      //   4     | CANCELLRCAUSE_TRAP - Trap/exception occurred
      //   5     | CANCELLRCAUSE_ENTER_DEBUG - Entered debug mode
      //   6     | CANCELLRCAUSE_EXIT_DEBUG - Exited debug mode
      //   7     | CANCELLRCAUSE_WRS_NTO - Wait-for-Read-Set (WRS) Non-Trap-Only
      //   8     | CANCELLRCAUSE_WRS_STO - Wait-for-Read-Set (WRS) Store-Only
      //   9     | CANCELLRCAUSE_INTERACTIVE - Interactive mode cancellation
      //   10    | CANCELLRCAUSE_SERVER - Server/cosimulation mode cancellation

      // Virtual Mode
      VirtualMode,                                // VirtualMode is the virtual mode. 
      NextVirtualMode,                            // NextVirtualMode is the next virtual mode.

      // PMA
      FPmaPtw,      DPmaPtw,                      // PMA configuration encountered during page table walk for Instruction(F) and Data(D) Memory Accesses.
      FPmaFault,    DPmaFault,                    // PMA fault encountered during page table walk for Instruction(F) and Data(D) Memory Accesses.
      FPmaMultihit, DPmaMultihit,                 // PMA multihit encountered during page table walk for Instruction(F) and Data(D) Memory Accesses.
      FPmaCrossing, DPmaCrossing,                 // PMA crossing encountered during page table walk for Instruction(F) and Data(D) Memory Accesses.
      FPmaRoot,     DPmaRoot,                     // PMA root encountered during page table walk for Instruction(F) and Data(D) Memory Accesses.

      // IMSIC
      ImsicMCsrNum,                               // IMSIC Machine CSR Number  
      ImsicMCsrValue,                             // IMSIC Machine CSR Value
      ImsicSCsrNum,                               // IMSIC Supervisor CSR Number
      ImsicSCsrValue,                             // IMSIC Supervisor CSR Value
      ImsicGCsrNum,                               // IMSIC Guest CSR Number
      ImsicGCsrValue,                             // IMSIC Guest CSR Value
      ImsicGuest,
      ImsicMMSI, 
      ImsicSMSI, 
      ImsicGMSI, 
      ImsicMSIGuest,

      // PMP
      FPmpPtw, DPmpPtw,
      FPmpIndex, DPmpIndex,
      FPmpMultihit, DPmpMultihit,
      FPmpCrossing, DPmpCrossing,
      FPmpCrossingIndex, DPmpCrossingIndex,
      FPtwFaultIsLeaf, DPtwFaultIsLeaf,
      FPtwFaultLevel, DPtwFaultLevel,

    // trigger
      Trigger,
      TriggerHitVec,

      FVPageSize,      DVPageSize,
      FPageCross,      DPageCross,
      FPageCrossSize,  DPageCrossSize,

    // paging
    // --- Do not change the below order carelessly (see arch/sample/Sample.cpp)
      FGPA,           DGPA,
      FPTELeaf,       DPTELeaf,
      FPTELeafADUpdate, DPTELeafADUpdate,
      FPTENonLeaf,    DPTENonLeaf,
      FPageSize,      DPageSize,
      FPma,           DPma,
      FPmaLeaf,       DPmaLeaf,
      FPmp,           DPmp,
      FPmpLeaf,       DPmpLeaf,
      FVPTE,          DVPTE, // these two shall never be set
      FVPTE_ADUpdate, DVPTE_ADUpdate,

      FGPA_GStageLevel1,        DGPA_GStageLevel1,
      FPTELeaf_GStageLevel1,    DPTELeaf_GStageLevel1,
      FPTELeafADUpdate_GStageLevel1, DPTELeafADUpdate_GStageLevel1,
      FPTENonLeaf_GStageLevel1, DPTENonLeaf_GStageLevel1,
      FPageSize_GStageLevel1,   DPageSize_GStageLevel1,
      FPma_GStageLevel1,        DPma_GStageLevel1,
      FPmaLeaf_GStageLevel1,    DPmaLeaf_GStageLevel1,
      FPmp_GStageLevel1,        DPmp_GStageLevel1,
      FPmpLeaf_GStageLevel1,    DPmpLeaf_GStageLevel1,
      FVPTE_Level1,             DVPTE_Level1,
      FVPTE_ADUpdate_Level1,    DVPTE_ADUpdate_Level1,

      FGPA_GStageLevel2,        DGPA_GStageLevel2,
      FPTELeaf_GStageLevel2,    DPTELeaf_GStageLevel2,
      FPTELeafADUpdate_GStageLevel2, DPTELeafADUpdate_GStageLevel2,
      FPTENonLeaf_GStageLevel2, DPTENonLeaf_GStageLevel2,
      FPageSize_GStageLevel2,   DPageSize_GStageLevel2,
      FPma_GStageLevel2,        DPma_GStageLevel2,
      FPmaLeaf_GStageLevel2,    DPmaLeaf_GStageLevel2,
      FPmp_GStageLevel2,        DPmp_GStageLevel2,
      FPmpLeaf_GStageLevel2,    DPmpLeaf_GStageLevel2,
      FVPTE_Level2,             DVPTE_Level2,
      FVPTE_ADUpdate_Level2,    DVPTE_ADUpdate_Level2,

      FGPA_GStageLevel3,        DGPA_GStageLevel3,
      FPTELeaf_GStageLevel3,    DPTELeaf_GStageLevel3,
      FPTELeafADUpdate_GStageLevel3, DPTELeafADUpdate_GStageLevel3,
      FPTENonLeaf_GStageLevel3, DPTENonLeaf_GStageLevel3,
      FPageSize_GStageLevel3,   DPageSize_GStageLevel3,
      FPma_GStageLevel3,        DPma_GStageLevel3,
      FPmaLeaf_GStageLevel3,    DPmaLeaf_GStageLevel3,
      FPmp_GStageLevel3,        DPmp_GStageLevel3,
      FPmpLeaf_GStageLevel3,    DPmpLeaf_GStageLevel3,
      FVPTE_Level3,             DVPTE_Level3,
      FVPTE_ADUpdate_Level3,    DVPTE_ADUpdate_Level3,

      FGPA_GStageLevel4,        DGPA_GStageLevel4,
      FPTELeaf_GStageLevel4,    DPTELeaf_GStageLevel4,
      FPTELeafADUpdate_GStageLevel4, DPTELeafADUpdate_GStageLevel4,
      FPTENonLeaf_GStageLevel4, DPTENonLeaf_GStageLevel4,
      FPageSize_GStageLevel4,   DPageSize_GStageLevel4,
      FPma_GStageLevel4,        DPma_GStageLevel4,
      FPmaLeaf_GStageLevel4,    DPmaLeaf_GStageLevel4,
      FPmp_GStageLevel4,        DPmp_GStageLevel4,
      FPmpLeaf_GStageLevel4,    DPmpLeaf_GStageLevel4,
      FVPTE_Level4,             DVPTE_Level4,
      FVPTE_ADUpdate_Level4,    DVPTE_ADUpdate_Level4,

      FGPA_GStageLevel5,        DGPA_GStageLevel5,
      FPTELeaf_GStageLevel5,    DPTELeaf_GStageLevel5,
      FPTELeafADUpdate_GStageLevel5, DPTELeafADUpdate_GStageLevel5,
      FPTENonLeaf_GStageLevel5, DPTENonLeaf_GStageLevel5,
      FPageSize_GStageLevel5,   DPageSize_GStageLevel5,
      FPma_GStageLevel5,        DPma_GStageLevel5,
      FPmaLeaf_GStageLevel5,    DPmaLeaf_GStageLevel5,
      FPmp_GStageLevel5,        DPmp_GStageLevel5,
      FPmpLeaf_GStageLevel5,    DPmpLeaf_GStageLevel5,
      FVPTE_Level5,             DVPTE_Level5,
      FVPTE_ADUpdate_Level5,    DVPTE_ADUpdate_Level5,
    // --- End

      Undefined,
      EndOfSim };
}

