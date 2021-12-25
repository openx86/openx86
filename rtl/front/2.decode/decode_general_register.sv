// project: w80386dx
// author: Chang Wei<changwei1006@gmail.com>
// repo: https://github.com/openx86/w80386dx
// module: decode_general_register
// create at: 2021-10-22 02:00:55
// description: pure combinatorial logic for decoding general purpose registers in IA-32

// ref:
// Intel386(TM) DX MICROPROCESSOR 32-BIT CHMOS MICROPROCESSOR WITH INTEGRATED MEMORY MANAGEMENT
// 6.2.3.2 ENCODING OF THE GENERAL REGISTER (reg) FIELD
// The general register is specified by the reg field,
// which may appear in the primary opcode bytes, or as
// the reg field of the 'mod r/m' byte, or as the r/m
// field of the 'mod r/m' byte.

// `include "D:\GitHub\openx86\w80386dx\rtl\define.h"
// `include "../define.h"
module decode_general_register #(
    // parameters
) (
    // ports
    input  logic [2:0] instruction_reg,
    input  logic       bit_width_16,
    input  logic       bit_width_32,
    input  logic       w_is_present,
    input  logic       w,
    output logic       AL,
    output logic       CL,
    output logic       DL,
    output logic       BL,
    output logic       AH,
    output logic       CH,
    output logic       DH,
    output logic       BH,
    output logic       AX,
    output logic       CX,
    output logic       DX,
    output logic       BX,
    output logic       SP,
    output logic       BP,
    output logic       SI,
    output logic       DI,
    output logic       EAX,
    output logic       ECX,
    output logic       EDX,
    output logic       EBX,
    output logic       ESP,
    output logic       EBP,
    output logic       ESI,
    output logic       EDI
);

assign  AL = instruction_reg === 3'b000 && (bit_width_16 || bit_width_32) && (w_is_present && ~w);
assign  CL = instruction_reg === 3'b001 && (bit_width_16 || bit_width_32) && (w_is_present && ~w);
assign  DL = instruction_reg === 3'b010 && (bit_width_16 || bit_width_32) && (w_is_present && ~w);
assign  BL = instruction_reg === 3'b011 && (bit_width_16 || bit_width_32) && (w_is_present && ~w);
assign  AH = instruction_reg === 3'b100 && (bit_width_16 || bit_width_32) && (w_is_present && ~w);
assign  CH = instruction_reg === 3'b101 && (bit_width_16 || bit_width_32) && (w_is_present && ~w);
assign  DH = instruction_reg === 3'b110 && (bit_width_16 || bit_width_32) && (w_is_present && ~w);
assign  BH = instruction_reg === 3'b111 && (bit_width_16 || bit_width_32) && (w_is_present && ~w);

assign  AX = instruction_reg === 3'b000 && bit_width_16 && (~w_is_present || (w_is_present && w));
assign  CX = instruction_reg === 3'b001 && bit_width_16 && (~w_is_present || (w_is_present && w));
assign  DX = instruction_reg === 3'b010 && bit_width_16 && (~w_is_present || (w_is_present && w));
assign  BX = instruction_reg === 3'b011 && bit_width_16 && (~w_is_present || (w_is_present && w));
assign  SP = instruction_reg === 3'b100 && bit_width_16 && (~w_is_present || (w_is_present && w));
assign  BP = instruction_reg === 3'b101 && bit_width_16 && (~w_is_present || (w_is_present && w));
assign  SI = instruction_reg === 3'b110 && bit_width_16 && (~w_is_present || (w_is_present && w));
assign  DI = instruction_reg === 3'b111 && bit_width_16 && (~w_is_present || (w_is_present && w));

assign EAX = instruction_reg === 3'b000 && bit_width_32 && (~w_is_present || (w_is_present && w));
assign ECX = instruction_reg === 3'b001 && bit_width_32 && (~w_is_present || (w_is_present && w));
assign EDX = instruction_reg === 3'b010 && bit_width_32 && (~w_is_present || (w_is_present && w));
assign EBX = instruction_reg === 3'b011 && bit_width_32 && (~w_is_present || (w_is_present && w));
assign ESP = instruction_reg === 3'b100 && bit_width_32 && (~w_is_present || (w_is_present && w));
assign EBP = instruction_reg === 3'b101 && bit_width_32 && (~w_is_present || (w_is_present && w));
assign ESI = instruction_reg === 3'b110 && bit_width_32 && (~w_is_present || (w_is_present && w));
assign EDI = instruction_reg === 3'b111 && bit_width_32 && (~w_is_present || (w_is_present && w));


// localparam bit_width_16 = 2'b01 << 0;
// localparam bit_width_32 = 2'b01 << 1;

// always_comb begin
//     unique case (w_is_present)
//         // Encoding of reg Field When w Field is not Present in Instruction
//         // 000 AX EAX
//         // 001 CX ECX
//         // 010 DX EDX
//         // 011 BX EBX
//         // 100 SP ESP
//         // 101 BP EBP
//         // 110 SI ESI
//         // 111 DI EDI
//         1'b0 : begin
//             unique case (bit_width)
//                 // Register Selected During 16-Bit Data Operations
//                 bit_width_16 : begin
//                     unique case (register_sequence_code)
//                         3'b000 : gen_reg_sel_info <= `reg__AX;
//                         3'b001 : gen_reg_sel_info <= `reg__CX;
//                         3'b010 : gen_reg_sel_info <= `reg__DX;
//                         3'b011 : gen_reg_sel_info <= `reg__BX;
//                         3'b100 : gen_reg_sel_info <= `reg__SP;
//                         3'b101 : gen_reg_sel_info <= `reg__BP;
//                         3'b110 : gen_reg_sel_info <= `reg__SI;
//                         3'b111 : gen_reg_sel_info <= `reg__DI;
//                     endcase
//                 end
//                 // Register Selected During 32-Bit Data Operations
//                 bit_width_32 : begin
//                     unique case (register_sequence_code)
//                         3'b000 : gen_reg_sel_info <= `reg_EAX;
//                         3'b001 : gen_reg_sel_info <= `reg_ECX;
//                         3'b010 : gen_reg_sel_info <= `reg_EDX;
//                         3'b011 : gen_reg_sel_info <= `reg_EBX;
//                         3'b100 : gen_reg_sel_info <= `reg_ESP;
//                         3'b101 : gen_reg_sel_info <= `reg_EBP;
//                         3'b110 : gen_reg_sel_info <= `reg_ESI;
//                         3'b111 : gen_reg_sel_info <= `reg_EDI;
//                     endcase
//                 end
//             endcase
//         end
//         // Encoding of reg Field When w Field is Present in Instruction
//         8'b1 : begin
//             unique case (bit_width)
//                 // Register Specified by reg Field During 16-Bit Data Operations:
//                 // 000 AL AX
//                 // 001 CL CX
//                 // 010 DL DX
//                 // 011 BL BX
//                 // 100 AH SP
//                 // 101 CH BP
//                 // 110 DH SI
//                 // 111 BH DI
//                 bit_width_16 : begin
//                     // Function of w Field
//                     unique case (w)
//                         // (when w == 0)
//                         1'b0 : begin
//                             unique case (register_sequence_code)
//                                 3'b000 : gen_reg_sel_info <= `reg__AL;
//                                 3'b001 : gen_reg_sel_info <= `reg__CL;
//                                 3'b010 : gen_reg_sel_info <= `reg__DL;
//                                 3'b011 : gen_reg_sel_info <= `reg__BL;
//                                 3'b100 : gen_reg_sel_info <= `reg__AH;
//                                 3'b101 : gen_reg_sel_info <= `reg__CH;
//                                 3'b110 : gen_reg_sel_info <= `reg__DH;
//                                 3'b111 : gen_reg_sel_info <= `reg__BH;
//                             endcase
//                         end
//                         // (when w == 1)
//                         8'b1 : begin
//                             unique case (register_sequence_code)
//                                 3'b000 : gen_reg_sel_info <= `reg__AX;
//                                 3'b001 : gen_reg_sel_info <= `reg__CX;
//                                 3'b010 : gen_reg_sel_info <= `reg__DX;
//                                 3'b011 : gen_reg_sel_info <= `reg__BX;
//                                 3'b100 : gen_reg_sel_info <= `reg__SP;
//                                 3'b101 : gen_reg_sel_info <= `reg__BP;
//                                 3'b110 : gen_reg_sel_info <= `reg__SI;
//                                 3'b111 : gen_reg_sel_info <= `reg__DI;
//                             endcase
//                         end
//                     endcase
//                 end
//                 // Register Specified by reg Field During 32-Bit Data Operations
//                 // 000 AL EAX
//                 // 001 CL ECX
//                 // 010 DL EDX
//                 // 011 BL EBX
//                 // 100 AH ESP
//                 // 101 CH EBP
//                 // 110 DH ESI
//                 // 111 BH EDI
//                 bit_width_32 : begin
//                     // Function of w Field
//                     unique case (w)
//                         // (when w == 0)
//                         1'b0 : begin
//                             unique case (register_sequence_code)
//                                 3'b000 : gen_reg_sel_info <= `reg__AL;
//                                 3'b001 : gen_reg_sel_info <= `reg__CL;
//                                 3'b010 : gen_reg_sel_info <= `reg__DL;
//                                 3'b011 : gen_reg_sel_info <= `reg__BL;
//                                 3'b100 : gen_reg_sel_info <= `reg__AH;
//                                 3'b101 : gen_reg_sel_info <= `reg__CH;
//                                 3'b110 : gen_reg_sel_info <= `reg__DH;
//                                 3'b111 : gen_reg_sel_info <= `reg__BH;
//                             endcase
//                         end
//                         // (when w == 1)
//                         8'b1 : begin
//                             unique case (register_sequence_code)
//                                 3'b000 : gen_reg_sel_info <= `reg_EAX;
//                                 3'b001 : gen_reg_sel_info <= `reg_ECX;
//                                 3'b010 : gen_reg_sel_info <= `reg_EDX;
//                                 3'b011 : gen_reg_sel_info <= `reg_EBX;
//                                 3'b100 : gen_reg_sel_info <= `reg_ESP;
//                                 3'b101 : gen_reg_sel_info <= `reg_EBP;
//                                 3'b110 : gen_reg_sel_info <= `reg_ESI;
//                                 3'b111 : gen_reg_sel_info <= `reg_EDI;
//                             endcase
//                         end
//                     endcase
//                 end
//             endcase
//         end
//     endcase
// end

endmodule
