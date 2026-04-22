/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: decode x87 FPU ESC instruction set (D8–DF)
*/

module stage_2_dec_x87_opcode (

    // -------------------------
    // x87 basic data transfer
    // -------------------------
    output logic            o_opcode_x87_FLD_load_real,
    output logic            o_opcode_x87_FST_store_real,
    output logic            o_opcode_x87_FSTP_store_pop_real,
    output logic            o_opcode_x87_FILD_load_int,
    output logic            o_opcode_x87_FIST_store_int,
    output logic            o_opcode_x87_FISTP_store_pop_int,

    // -------------------------
    // x87 arithmetic
    // -------------------------
    output logic            o_opcode_x87_FADD,
    output logic            o_opcode_x87_FMUL,
    output logic            o_opcode_x87_FSUB,
    output logic            o_opcode_x87_FSUBR,
    output logic            o_opcode_x87_FDIV,
    output logic            o_opcode_x87_FDIVR,

    // -------------------------
    // x87 register stack ops
    // -------------------------
    output logic            o_opcode_x87_FLD_STi,
    output logic            o_opcode_x87_FXCH,
    output logic            o_opcode_x87_FFREE,
    output logic            o_opcode_x87_FST_STi,

    // -------------------------
    // control / status
    // -------------------------
    output logic            o_opcode_x87_FINCSTP,
    output logic            o_opcode_x87_FDECSTP,
    output logic            o_opcode_x87_FINIT,
    output logic            o_opcode_x87_FCLEX,
    output logic            o_opcode_x87_FNSTSW,

    input  logic [3: 0][7: 0] i_instruction
);

    // wire       esc           = (i_instruction[0] >= 8'hD8) && (i_instruction[0] <= 8'hDF);
    logic [2: 0] modrm_reg = i_instruction[1][5: 3];
    logic [1: 0] mod       = i_instruction[1][7: 6];
    // wire       fpu_reg_group = esc && (mod == 2'b11);

    assign o_opcode_x87_FADD                = (i_instruction[0] == 8'hD8 && modrm_reg == 3'b000);
    assign o_opcode_x87_FMUL                = (i_instruction[0] == 8'hD8 && modrm_reg == 3'b001);
    assign o_opcode_x87_FCOM                = (i_instruction[0] == 8'hD8 && modrm_reg == 3'b010);
    assign o_opcode_x87_FCOMP               = (i_instruction[0] == 8'hD8 && modrm_reg == 3'b011);
    assign o_opcode_x87_FSUB                = (i_instruction[0] == 8'hD8 && modrm_reg == 3'b100);
    assign o_opcode_x87_FSUBR               = (i_instruction[0] == 8'hD8 && modrm_reg == 3'b101);
    assign o_opcode_x87_FDIV                = (i_instruction[0] == 8'hD8 && modrm_reg == 3'b110);
    assign o_opcode_x87_FDIVR               = (i_instruction[0] == 8'hD8 && modrm_reg == 3'b111);

    assign o_opcode_x87_FLD_load_real       = (i_instruction[0] == 8'hD9 && modrm_reg == 3'b000);
    assign o_opcode_x87_FST_store_real      = (i_instruction[0] == 8'hD9 && modrm_reg == 3'b010);
    assign o_opcode_x87_FSTP_store_pop_real = (i_instruction[0] == 8'hD9 && modrm_reg == 3'b011);
    assign o_opcode_x87_FLD_STi             = (i_instruction[0] == 8'hD9 && mod == 2'b11 && i_instruction[1][2: 0] < 3'd8);
    assign o_opcode_x87_FXCH                = (i_instruction[0] == 8'hD9 && modrm_reg == 3'b001);
    assign o_opcode_x87_FINIT               = (i_instruction[0] == 8'hD9 && i_instruction[1] == 8'hE3);
    assign o_opcode_x87_FCLEX               = (i_instruction[0] == 8'hD9 && i_instruction[1] == 8'hE2);

    assign o_opcode_x87_FILD_load_int       = (i_instruction[0] == 8'hDB && modrm_reg == 3'b000);
    assign o_opcode_x87_FIST_store_int      = (i_instruction[0] == 8'hDB && modrm_reg == 3'b010);
    assign o_opcode_x87_FISTP_store_pop_int = (i_instruction[0] == 8'hDB && modrm_reg == 3'b011);

    assign o_opcode_x87_FFREE               = (i_instruction[0] == 8'hDD && modrm_reg == 3'b000);
    assign o_opcode_x87_FINCSTP             = (i_instruction[0] == 8'hD9 && i_instruction[1] == 8'hF7);
    assign o_opcode_x87_FDECSTP             = (i_instruction[0] == 8'hD9 && i_instruction[1] == 8'hF6);
    assign o_opcode_x87_FNSTSW              = (i_instruction[0] == 8'hDF && i_instruction[1] == 8'hE0);

endmodule
