/*
project: w80386dx
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/w80386dx
module: decode_mod_rm
create at: 2021-10-23 15:54:39
description: decode mod and r/m field in instruction
*/

/* ref:
Intel386(TM) DX MICROPROCESSOR 32-BIT CHMOS MICROPROCESSOR WITH INTEGRATED MEMORY MANAGEMENT
6.2.3.4 ENCODING OF ADDRESS MODE
Except for special instructions, such as PUSH or
POP, where the addressing mode is pre-determined,
the addressing mode for the current instruction is
specified by addressing bytes following the primary
opcode. The primary addressing byte is the ``mod
r/m'' byte, and a second byte of addressing information,
the ``s-i-b'' (scale-index-basecan beyte) is specified
when using 32-bit addressing ``mod1 or 10.
When the sib byte is present, the 32-bit addressing
mode is a function of the mod, ss, index, fields.
also contains three bits (shown as TTT in Figure 6-1)
sometimes used as an extension of the primary opcode.
The three bits, however, may also be used as
a register field (reg).
When calculating an effective address, either 16-bit
addressing or 32-bit addressing is used. 16-bit addressing
uses 16-bit address components to calculate
the effective address while 32-bit addressing
uses 32-bit address components to calculate the effective
address. When 16-bit addressing is used, the
``mod r/m'' byte is interpreted as a 16-bit addressing
mode specifier. When 32-bit addressing is used, the
``mod r/m'' byte is interpreted as a 32-bit addressing
mode specifier.
Tables on the following three pages define all encodings
of all 16-bit addressing modes and 32-bit
addressing modes.
*/

module address_generate_unit #(
    // parameters
) (
    // ports
    input  logic        prefix_address_size,
    input  logic        prefix_bus_lock,
    input  logic        prefix_operand_size,
    input  logic        prefix_segment_override_CS,
    input  logic        prefix_segment_override_DS,
    input  logic        prefix_segment_override_ES,
    input  logic        prefix_segment_override_FS,
    input  logic        prefix_segment_override_GS,
    input  logic        prefix_segment_override_SS,
    input  logic        segment_DS,
    input  logic        segment_SS,
    input  logic [31:0] base,
    input  logic [31:0] index,
    input  logic        scale_x1,
    input  logic        scale_x2,
    input  logic        scale_x4,
    input  logic        scale_x8,
    input  logic [31:0] displacement,
    input  logic [ 7:0] AL,
    input  logic [ 7:0] BL,
    input  logic [ 7:0] CL,
    input  logic [ 7:0] DL,
    input  logic [ 7:0] AH,
    input  logic [ 7:0] BH,
    input  logic [ 7:0] CH,
    input  logic [ 7:0] DH,
    input  logic [15:0] AX,
    input  logic [15:0] BX,
    input  logic [15:0] CX,
    input  logic [15:0] DX,
    input  logic [15:0] SI,
    input  logic [15:0] DI,
    input  logic [15:0] BP,
    input  logic [15:0] SP,
    input  logic [31:0] EAX,
    input  logic [31:0] EBX,
    input  logic [31:0] ECX,
    input  logic [31:0] EDX,
    input  logic [31:0] ESI,
    input  logic [31:0] EDI,
    input  logic [31:0] EBP,
    input  logic [31:0] ESP,
    input  logic [15:0] CS,
    input  logic [15:0] SS,
    input  logic [15:0] DS,
    input  logic [15:0] ES,
    input  logic [15:0] FS,
    input  logic [15:0] GS,
    output logic [31:0] address
);

// wire [31:0] segment;
// wire [7:0] segment_info = {
//     prefix_segment_override_CS,
//     prefix_segment_override_DS,
//     prefix_segment_override_ES,
//     prefix_segment_override_FS,
//     prefix_segment_override_GS,
//     prefix_segment_override_SS,
//     segment_DS,
//     segment_SS
// };
// localparam segment_sel_CS = 8'b1000_0000;
// localparam segment_sel_DS = 8'b0100_0010;
// localparam segment_sel_ES = 8'b0010_0000;
// localparam segment_sel_FS = 8'b0001_0000;
// localparam segment_sel_GS = 8'b0000_1000;
// localparam segment_sel_SS = 8'b0000_0101;
// always_comb begin
//     unique case (segment_info)
//         segment_sel_CS: segment <= CS;
//         segment_sel_DS: segment <= DS;
//         segment_sel_ES: segment <= ES;
//         segment_sel_FS: segment <= FS;
//         segment_sel_GS: segment <= GS;
//         segment_sel_SS: segment <= SS;
//         default: begin
//             segment <= 0;
//         end
//     endcase
// end

// wire [31:0] scaled_index;
// wire [ 3:0] scale_info = {scale_x1, scale_x2, scale_x4, scale_x8};
// localparam scale_info_x1 = 4'b0001 << 0;
// localparam scale_info_x2 = 4'b0001 << 1;
// localparam scale_info_x4 = 4'b0001 << 2;
// localparam scale_info_x8 = 4'b0001 << 3;
// always_comb begin
//     unique case (scale_info)
//         scale_info_x1: scaled_index <= index << 0;
//         scale_info_x2: scaled_index <= index << 1;
//         scale_info_x4: scaled_index <= index << 2;
//         scale_info_x8: scaled_index <= index << 3;
//         default: begin
//             scaled_index <= index;
//         end
//     endcase
// end

// assign address = segment << 4 + base + scaled_index + displacement;

endmodule
