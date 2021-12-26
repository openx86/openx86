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

module decode_mod_rm #(
    // parameters
) (
    // ports
    input  logic [ 7:0] instruction[6],
    output logic        bit_width_16,
    output logic        bit_width_32,
    input  logic        w,
    output logic        segment_DS,
    output logic        segment_SS,
    output logic        scale_x1,
    output logic        scale_x2,
    output logic        scale_x4,
    output logic        scale_x8,
    output logic        index_EAX,
    output logic        index_ECX,
    output logic        index_EDX,
    output logic        index_EBX,
    output logic        index_EBP,
    output logic        index_ESI,
    output logic        index_EDI,
    output logic        d__0,
    output logic        d__8,
    output logic        d_16,
    output logic        d_32,
    output logic        w,
    output logic        reg_AL,
    output logic        reg_CL,
    output logic        reg_DL,
    output logic        reg_BL,
    output logic        reg_AH,
    output logic        reg_CH,
    output logic        reg_DH,
    output logic        reg_BH,
    output logic        reg_AX,
    output logic        reg_CX,
    output logic        reg_DX,
    output logic        reg_BX,
    output logic        reg_SP,
    output logic        reg_BP,
    output logic        reg_SI,
    output logic        reg_DI,
    output logic        reg_EAX,
    output logic        reg_ECX,
    output logic        reg_EDX,
    output logic        reg_EBX,
    output logic        reg_ESP,
    output logic        reg_EBP,
    output logic        reg_ESI,
    output logic        reg_EDI,
    output logic [`info_reg_seg_len-1:0] segment_reg_info,
    output logic [`info_reg_gpr_len-1:0] base_reg_info,
    output logic [`info_reg_gpr_len-1:0] index_reg_info,
    output logic [`info_scale_len-1:0] scale_info,
    output logic [`info_displacement_len-1:0] displacement_info,
);

wire [1:0] mod = instruction[7:6];
wire [2:0] rm = instruction[2:0];

wire mod_00 = (mod == 2'b00);
wire mod_01 = (mod == 2'b01);
wire mod_10 = (mod == 2'b10);
wire mod_11 = (mod == 2'b11);

wire rm_000 = (rm == 3'b000);
wire rm_001 = (rm == 3'b001);
wire rm_010 = (rm == 3'b010);
wire rm_011 = (rm == 3'b011);
wire rm_100 = (rm == 3'b100);
wire rm_101 = (rm == 3'b101);
wire rm_110 = (rm == 3'b110);
wire rm_111 = (rm == 3'b111);

assign segment_DS =
(bit_width_16 &
    (
        (mod_00 & (rm_000 | rm_001 | rm_100 | rm_101 | rm_110 | rm_111)) |
        (mod_01 & (rm_000 | rm_001 | rm_100 | rm_101 | rm_111)) |
        (mod_10 & (rm_000 | rm_001 | rm_100 | rm_101 | rm_111))
    )
);
assign segment_SS =
(bit_width_16 &
    (
        (mod_00 & (rm_010 | rm_011)) |
        (mod_01 & (rm_010 | rm_011 | rm_110)) |
        (mod_10 & (rm_010 | rm_011 | rm_110))
    )
);

// TODO: remove the logic: (bit_width_16 | bit_width_32) for saving the area, level it at here because of 64-bit compatible
assign reg_AL   = mod_11 & rm_000 & ~w & (bit_width_16 | bit_width_32);
assign reg_CL   = mod_11 & rm_001 & ~w & (bit_width_16 | bit_width_32);
assign reg_DL   = mod_11 & rm_010 & ~w & (bit_width_16 | bit_width_32);
assign reg_BL   = mod_11 & rm_011 & ~w & (bit_width_16 | bit_width_32);
assign reg_AH   = mod_11 & rm_100 & ~w & (bit_width_16 | bit_width_32);
assign reg_CH   = mod_11 & rm_101 & ~w & (bit_width_16 | bit_width_32);
assign reg_DH   = mod_11 & rm_110 & ~w & (bit_width_16 | bit_width_32);
assign reg_BH   = mod_11 & rm_111 & ~w & (bit_width_16 | bit_width_32);
assign reg_AX   = mod_11 & rm_000 &  w & (bit_width_16);
assign reg_CX   = mod_11 & rm_001 &  w & (bit_width_16);
assign reg_DX   = mod_11 & rm_010 &  w & (bit_width_16);
assign reg_BX   = mod_11 & rm_011 &  w & (bit_width_16);
assign reg_SP   = mod_11 & rm_100 &  w & (bit_width_16);
assign reg_BP   = mod_11 & rm_101 &  w & (bit_width_16);
assign reg_SI   = mod_11 & rm_110 &  w & (bit_width_16);
assign reg_DI   = mod_11 & rm_111 &  w & (bit_width_16);
assign reg_EAX  = mod_11 & rm_000 &  w & (bit_width_32);
assign reg_ECX  = mod_11 & rm_001 &  w & (bit_width_32);
assign reg_EDX  = mod_11 & rm_010 &  w & (bit_width_32);
assign reg_EBX  = mod_11 & rm_011 &  w & (bit_width_32);
assign reg_ESP  = mod_11 & rm_100 &  w & (bit_width_32);
assign reg_EBP  = mod_11 & rm_101 &  w & (bit_width_32);
assign reg_ESI  = mod_11 & rm_110 &  w & (bit_width_32);
assign reg_EDI  = mod_11 & rm_111 &  w & (bit_width_32);

// TODO: remove the signal because we need to get the follow displacement info from other instruction
assign d__0 = mod_00;
// TODO: remove the logic: (bit_width_16 | bit_width_32) for saving the area
assign d__8 = mod_01 & (bit_width_16 | bit_width_32);
assign d_16 = mod_10 & (bit_width_16);
assign d_32 = mod_10 & (bit_width_32);

assign base_BX = bit_width_16 & (
    rm_000 | rm_001 | rm_111
);
assign base_BP = bit_width_16 & (
    (mod_00 & (rm_010 | rm_011)) | (mod_01 & (rm_010 | rm_011 | rm_110)) | (mod_10 & (rm_010 | rm_011 | rm_110))
);

assign base_EAX = bit_width_32 & ((mod_00 & rm_000) | (mod_10 & rm_000) | (mod_10 & rm_000));
assign base_ECX = bit_width_32 & ((mod_00 & rm_001) | (mod_10 & rm_001) | (mod_10 & rm_001));
assign base_EDX = bit_width_32 & ((mod_00 & rm_010) | (mod_10 & rm_010) | (mod_10 & rm_010));
assign base_EBX = bit_width_32 & ((mod_00 & rm_011) | (mod_10 & rm_011) | (mod_10 & rm_011));
// assign base_ESP = bit_width_32 & ((mod_00 & rm_100) | (mod_10 & rm_100) | (mod_10 & rm_100));
assign base_EBP = bit_width_32 & ((mod_10 & rm_101) | (mod_10 & rm_101));
assign base_ESI = bit_width_32 & ((mod_00 & rm_110) | (mod_10 & rm_110) | (mod_10 & rm_110));
assign base_EDI = bit_width_32 & ((mod_00 & rm_111) | (mod_10 & rm_111) | (mod_10 & rm_111));

// logic [2:0] general_register_sequence_code;
// logic [`reg_sel_info_len-1:0] reg_sel_info;
// decode_general_register decode_general_register_inst (
//     .bit_width ( bit_width ),
//     .register_sequence_code ( general_register_sequence_code ),
//     .w_in_instruction ( w_in_instruction ),
//     .w ( w ),
//     .reg_sel_info ( reg_sel_info ),
// );

always_comb begin
    unique case (mod)
        2'b00 : begin
            unique case (rm)
                3'b000 : begin segment <= `reg_gen__DS; base <= `reg_gen__BX; index <= `reg_gen__SI; scale <= imm__0; imm <= imm__0; end
                3'b001 : begin segment <= `reg_gen__DS; base <= `reg_gen__BX; index <= `reg_gen__DI; scale <= imm__0; imm <= imm__0; end
                3'b010 : begin segment <= `reg_gen__SS; base <= `reg_gen__BX; index <= `reg_gen__SI; scale <= imm__0; imm <= imm__0; end
                3'b011 : begin segment <= `reg_gen__SS; base <= `reg_gen__BX; index <= `reg_gen__DI; scale <= imm__0; imm <= imm__0; end
                3'b100 : begin segment <= `reg_gen__DS; base <= `reg_gen_NUL; index <= `reg_gen__SI; scale <= imm__0; imm <= imm__0; end
                3'b101 : begin segment <= `reg_gen__DS; base <= `reg_gen_NUL; index <= `reg_gen__DI; scale <= imm__0; imm <= imm__0; end
                3'b110 : begin segment <= `reg_gen__DS; base <= `reg_gen_NUL; index <= `reg_gen_NUL; scale <= imm__0; imm <= imm_16; end
                3'b111 : begin segment <= `reg_gen__DS; base <= `reg_gen__BX; index <= `reg_gen_NUL; scale <= imm__0; imm <= imm__0; end
            endcase
        end
        2'b01 : begin
            unique case (rm)
                3'b000 : begin segment <= `reg_gen__DS; base <= `reg_gen__BX; index <= `reg_gen__SI; scale <= imm__0; imm <= imm__8; end
                3'b001 : begin segment <= `reg_gen__DS; base <= `reg_gen__BX; index <= `reg_gen__DI; scale <= imm__0; imm <= imm__8; end
                3'b010 : begin segment <= `reg_gen__SS; base <= `reg_gen__BP; index <= `reg_gen__SI; scale <= imm__0; imm <= imm__8; end
                3'b011 : begin segment <= `reg_gen__SS; base <= `reg_gen__BP; index <= `reg_gen__DI; scale <= imm__0; imm <= imm__8; end
                3'b100 : begin segment <= `reg_gen__DS; base <= `reg_gen_NUL; index <= `reg_gen__SI; scale <= imm__0; imm <= imm__8; end
                3'b101 : begin segment <= `reg_gen__DS; base <= `reg_gen_NUL; index <= `reg_gen__DI; scale <= imm__0; imm <= imm__8; end
                3'b110 : begin segment <= `reg_gen__SS; base <= `reg_gen__BP; index <= `reg_gen_NUL; scale <= imm__0; imm <= imm__8; end
                3'b111 : begin segment <= `reg_gen__DS; base <= `reg_gen__BX; index <= `reg_gen_NUL; scale <= imm__0; imm <= imm__8; end
            endcase
        end
        2'b10 : begin
            unique case (rm)
                3'b000 : begin segment <= `reg_gen__DS; base <= `reg_gen__BX; index <= `reg_gen__SI; scale <= imm__0; imm <= imm_16; end
                3'b001 : begin segment <= `reg_gen__DS; base <= `reg_gen__BX; index <= `reg_gen__DI; scale <= imm__0; imm <= imm_16; end
                3'b010 : begin segment <= `reg_gen__SS; base <= `reg_gen__BP; index <= `reg_gen__SI; scale <= imm__0; imm <= imm_16; end
                3'b011 : begin segment <= `reg_gen__SS; base <= `reg_gen__BP; index <= `reg_gen__DI; scale <= imm__0; imm <= imm_16; end
                3'b100 : begin segment <= `reg_gen__DS; base <= `reg_gen_NUL; index <= `reg_gen__SI; scale <= imm__0; imm <= imm_16; end
                3'b101 : begin segment <= `reg_gen__DS; base <= `reg_gen_NUL; index <= `reg_gen__DI; scale <= imm__0; imm <= imm_16; end
                3'b110 : begin segment <= `reg_gen__SS; base <= `reg_gen__BP; index <= `reg_gen_NUL; scale <= imm__0; imm <= imm_16; end
                3'b111 : begin segment <= `reg_gen__DS; base <= `reg_gen__BX; index <= `reg_gen_NUL; scale <= imm__0; imm <= imm_16; end
            endcase
        end
        2'b11 : begin
            unique case (w)
                1'b0 : begin
                    unique case (rm)
                        3'b000 : begin segment <= `reg_gen_NUL; base <= `reg_gen__AL; index <= `reg_gen_NUL; scale <= imm__0; imm <= imm_16; end
                        3'b001 : begin segment <= `reg_gen_NUL; base <= `reg_gen__CL; index <= `reg_gen_NUL; scale <= imm__0; imm <= imm_16; end
                        3'b010 : begin segment <= `reg_gen_NUL; base <= `reg_gen__DL; index <= `reg_gen_NUL; scale <= imm__0; imm <= imm_16; end
                        3'b011 : begin segment <= `reg_gen_NUL; base <= `reg_gen__BL; index <= `reg_gen_NUL; scale <= imm__0; imm <= imm_16; end
                        3'b100 : begin segment <= `reg_gen_NUL; base <= `reg_gen__AH; index <= `reg_gen_NUL; scale <= imm__0; imm <= imm_16; end
                        3'b101 : begin segment <= `reg_gen_NUL; base <= `reg_gen__CH; index <= `reg_gen_NUL; scale <= imm__0; imm <= imm_16; end
                        3'b110 : begin segment <= `reg_gen_NUL; base <= `reg_gen__DH; index <= `reg_gen_NUL; scale <= imm__0; imm <= imm_16; end
                        3'b111 : begin segment <= `reg_gen_NUL; base <= `reg_gen__BH; index <= `reg_gen_NUL; scale <= imm__0; imm <= imm_16; end
                    endcase
                end
                1'b1 : begin
                    unique case (rm)
                        3'b000 : begin segment <= `reg_gen_NUL; base <= `reg_gen__AL; index <= `reg_gen_NUL; scale <= imm__0; imm <= imm_16; end
                        3'b001 : begin segment <= `reg_gen_NUL; base <= `reg_gen__CL; index <= `reg_gen_NUL; scale <= imm__0; imm <= imm_16; end
                        3'b010 : begin segment <= `reg_gen_NUL; base <= `reg_gen__DL; index <= `reg_gen_NUL; scale <= imm__0; imm <= imm_16; end
                        3'b011 : begin segment <= `reg_gen_NUL; base <= `reg_gen__BL; index <= `reg_gen_NUL; scale <= imm__0; imm <= imm_16; end
                        3'b100 : begin segment <= `reg_gen_NUL; base <= `reg_gen__AH; index <= `reg_gen_NUL; scale <= imm__0; imm <= imm_16; end
                        3'b101 : begin segment <= `reg_gen_NUL; base <= `reg_gen__CH; index <= `reg_gen_NUL; scale <= imm__0; imm <= imm_16; end
                        3'b110 : begin segment <= `reg_gen_NUL; base <= `reg_gen__DH; index <= `reg_gen_NUL; scale <= imm__0; imm <= imm_16; end
                        3'b111 : begin segment <= `reg_gen_NUL; base <= `reg_gen__BH; index <= `reg_gen_NUL; scale <= imm__0; imm <= imm_16; end
                    endcase
                end
            endcase

        end
    endcase
end

endmodule
