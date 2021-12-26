// project: w80386dx
// author: Chang Wei<changwei1006@gmail.com>
// repo: https://github.com/openx86/w80386dx
// module: decode_register_segment
// create at: 2021-10-22 02:00:55
// description: pure combinatorial logic for decoding general purpose registers in IA-32

// ref:
// Intel386(TM) DX MICROPROCESSOR 32-BIT CHMOS MICROPROCESSOR WITH INTEGRATED MEMORY MANAGEMENT
// 6.2.3.3 ENCODING OF THE SEGMENT REGISTER (sreg) FIELD
// The sreg field in certain instructions is a 2-bit field
// allowing one of the four 80286 segment registers to
// be specified. The sreg field in other instructions is a
// 3-bit field, allowing the Intel386 DX FS and GS segment
// registers to be specified.

// `include "../define.h"
module decode_segment_register #(
    // parameters
) (
    // ports
    input  logic [2:0] instruction_sreg,
    output logic       ES,
    output logic       CS,
    output logic       SS,
    output logic       DS,
    output logic       FS,
    output logic       GS
    // output logic [`reg_seg_sel_info_len-1:0] reg_seg_sel_info
);

assign ES = instruction_sreg[1:0] == 2'b00;
assign CS = instruction_sreg[1:0] == 2'b01;
assign SS = instruction_sreg[1:0] == 2'b10;
assign DS = instruction_sreg[1:0] == 2'b11;
assign FS = instruction_sreg[2:0] == 3'b100;
assign GS = instruction_sreg[2:0] == 3'b101;

// always_comb begin
//     unique casex (sreg_sequence_code)
//         3'b?00 : reg_seg_sel_info <= `reg_seg__ES;
//         3'b?01 : reg_seg_sel_info <= `reg_seg__CS;
//         3'b?10 : reg_seg_sel_info <= `reg_seg__SS;
//         3'b?11 : reg_seg_sel_info <= `reg_seg__DS;
//         3'b100 : reg_seg_sel_info <= `reg_seg__FS;
//         3'b101 : reg_seg_sel_info <= `reg_seg__GS;
//         3'b110 : reg_seg_sel_info <= `reg_seg_NUL;
//         3'b111 : reg_seg_sel_info <= `reg_seg_NUL;
//     endcase
// end

endmodule