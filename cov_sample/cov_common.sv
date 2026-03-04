`ifndef COV_COMMON_SV
`define COV_COMMON_SV
`ifndef COVERAGE_UNSUPPORTED

import cp_pkg::*;

package cov_common;

typedef struct {
  longint unsigned cp;
  longint unsigned val;
  longint unsigned isLastPkt;
} cp_pkt;

typedef cp_pkt cp_arr_t[$];

class csrType;

  cp_pkg::csrEnum_e name;
  logic [63:0]      value;

endclass

class cp_table;

  cp_arr_t cp_q;

  function void insert_cp(cp_pkt pkt);
    cp_q.push_back(pkt);
  endfunction

  function int cp_q_len();
    return cp_q.size();
  endfunction

  function void clear_cp_q();
    cp_q.delete();
  endfunction

  function void print_cp_q();
  cp_pkg::archInfoPoints_e cp_enum;
  foreach(cp_q[i]) begin
    cp_enum = cp_pkg::archInfoPoints_e'(cp_q[i].cp);
    $display("Coverpoint = %s, Value = %d",cp_enum.name(),cp_q[i].val);
  end
  endfunction

  function csrType get_csr(cp_pkg::csrEnum_e csrName);
    csrType csr;
    cp_pkg::archInfoPoints_e cp_enum;
    cp_pkg::csrEnum_e csr_enum;

    foreach(cp_q[i]) begin

      //Whisper sends CsrAddress and CsrValue consecutively.
      cp_enum =  cp_pkg::archInfoPoints_e'(cp_q[i].cp);

      //If this is a CsrAddress coverpoint
      if(cp_enum == cp_pkg::POINT_CSRNUM) begin
        csr_enum = cp_pkg::csrEnum_e'(cp_q[i].val);

        //Issue an error if this protocol is violated as there is no way to correlate the
        //csr address with the csr value.
        cp_enum = cp_pkg::archInfoPoints_e'(cp_q[i+1].cp);
        if(cp_enum != cp_pkg::POINT_CSRVALUE) begin
          $fatal("Protocol Violation : CSR address and value are not consecutive");
        end

        //If the CsrValue is the one which is being queried
        if(csr_enum == csrName) begin

          //Create a new Csr
          csr = new();
          csr.name  = csr_enum;
          csr.value = cp_q[i+1].val;
          return csr;

        end
      end
    end
    return null;
  endfunction

  function bit exists(cp_pkg::archInfoPoints_e cp);
    foreach(cp_q[i]) begin
      if(cp_pkg::archInfoPoints_e'(cp_q[i].cp) == cp) begin
        return 1;
      end
    end
    return 0;
  endfunction

  function logic[63:0] get_cp_val(cp_pkg::archInfoPoints_e cp);
    foreach(cp_q[i]) begin
      if(cp_pkg::archInfoPoints_e'(cp_q[i].cp) == cp) begin
        return cp_q[i].val;
      end
    end
    return null;
  endfunction
endclass

// get all possible values in an array for a generic enum
virtual class Enums#(type e);
  typedef e enum_list_t[$];
  static function automatic enum_list_t getEnumValues();
    enum_list_t enum_array;
    e val = val.first;
    do begin
      enum_array.push_back(val);
      val = val.next;
    end
    while (val  != val.first);
    return enum_array;
  endfunction
endclass

endpackage

`endif
`endif
