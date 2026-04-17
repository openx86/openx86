/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements stage_3_exe_execute_x87_fpu.
*/
// ============================================================================
// X87 FPU 子集（栈式寄存器 ST0–ST7）
// 数值为 64 位有符号整数路径（可综合）；后续可替换为 IEEE754 软浮点
// ============================================================================

module stage_3_exe_execute_x87_fpu (
    input  logic        i_valid,
    input  logic [ 4:0] i_op,
    input  logic [63:  0] i_push_data,
    input  logic [ 2:0] i_st_src,
    output logic [63:  0] o_st0,
    output logic [63:  0] o_st1,
    output logic        o_zf,
    output logic        o_pf,
    output logic        o_cf,
    input  logic        clk,
    input  logic        rst);

    import stage_3_exe_execute_unit_pkg::*;

    logic [63:  0] phys [ 0:  7];
    logic [ 2:0] top;
    logic        zf_r;
    logic        pf_r;
    logic        cf_r;
    logic [63:  0] swap_tmp;

    wire [ 2:  0] p0 = top + 3'd0;
    wire [ 2:  0] p1 = top + 3'd1;
    wire [ 2:  0] px = top + i_st_src;

    always_ff @(posedge clk) begin
        if (rst) begin
            top <= 3'd0;
            zf_r <= 1'b0;
            pf_r <= 1'b0;
            cf_r <= 1'b0;
            for (int k = 0; k < 8; k++) phys[k] <= 64'h0;
        end else if (i_valid) begin
            unique case (i_op)
                X87_FLD: begin
                    phys[top - 3'd1] <= i_push_data;
                    top <= top - 3'd1;
                end
                X87_FLD_STI: begin
                    phys[top - 3'd1] <= phys[px];
                    top <= top - 3'd1;
                end
                X87_FLD1: begin
                    phys[top - 3'd1] <= i_push_data;
                    top <= top - 3'd1;
                end
                X87_FLDZ: begin
                    phys[top - 3'd1] <= i_push_data;
                    top <= top - 3'd1;
                end
                X87_FST: begin
                    phys[px] <= phys[p0];
                end
                X87_FSTP: begin
                    phys[px] <= phys[p0];
                    top <= top + 3'd1;
                end
                X87_FADD: begin
                    phys[p0] <= phys[p0] + phys[px];
                end
                X87_FADDP: begin
                    phys[px] <= phys[px] + phys[p0];
                    top <= top + 3'd1;
                end
                X87_FSUB: begin
                    phys[p0] <= phys[p0] - phys[px];
                end
                X87_FSUBR: begin
                    phys[p0] <= phys[px] - phys[p0];
                end
                X87_FSUBP: begin
                    phys[px] <= phys[px] - phys[p0];
                    top <= top + 3'd1;
                end
                X87_FSUBRP: begin
                    phys[px] <= phys[p0] - phys[px];
                    top <= top + 3'd1;
                end
                X87_FMUL: begin
                    phys[p0] <= phys[p0] * phys[px];
                end
                X87_FMULP: begin
                    phys[px] <= phys[px] * phys[p0];
                    top <= top + 3'd1;
                end
                X87_FDIV: begin
                    if (phys[px] != 64'h0)
                        phys[p0] <= phys[p0] / phys[px];
                end
                X87_FDIVR: begin
                    if (phys[p0] != 64'h0)
                        phys[p0] <= phys[px] / phys[p0];
                end
                X87_FDIVP: begin
                    if (phys[p0] != 64'h0)
                        phys[px] <= phys[px] / phys[p0];
                    top <= top + 3'd1;
                end
                X87_FDIVRP: begin
                    if (phys[px] != 64'h0)
                        phys[px] <= phys[p0] / phys[px];
                    top <= top + 3'd1;
                end
                X87_FCHS: begin
                    phys[p0] <= -$signed(phys[p0]);
                end
                X87_FABS: begin
                    phys[p0] <= ($signed(phys[p0]) < 64'sd0) ? -$signed(phys[p0]) : phys[p0];
                end
                X87_FXCH: begin
                    swap_tmp = phys[p0];
                    phys[p0] <= phys[px];
                    phys[px] <= swap_tmp;
                end
                X87_FFREE: begin
                    phys[px] <= 64'h0;
                end
                X87_FCOM: begin
                    zf_r <= (phys[p0] == phys[px]);
                    pf_r <= 1'b0;
                    cf_r <= ($signed(phys[p0]) < $signed(phys[px]));
                end
                X87_FCOMP: begin
                    zf_r <= (phys[p0] == phys[px]);
                    pf_r <= 1'b0;
                    cf_r <= ($signed(phys[p0]) < $signed(phys[px]));
                    top <= top + 3'd1;
                end
                X87_FCOMIP,
                X87_FUCOMIP: begin
                    zf_r <= (phys[p0] == phys[px]);
                    pf_r <= 1'b0;
                    cf_r <= ($signed(phys[p0]) < $signed(phys[px]));
                    top <= top + 3'd1;
                end
                X87_FTST: begin
                    zf_r <= (phys[p0] == 64'h0);
                    pf_r <= 1'b0;
                    cf_r <= ($signed(phys[p0]) < 64'sd0);
                end
                X87_FNOP: begin
                    ;
                end
                X87_FCOMI: begin
                    zf_r <= (phys[p0] == phys[px]);
                    pf_r <= 1'b0;
                    cf_r <= ($signed(phys[p0]) < $signed(phys[px]));
                end
                default: ;
            endcase
        end
    end

    always_comb begin
        o_st0 = phys[p0];
        o_st1 = phys[p1];
        o_zf  = zf_r;
        o_pf  = pf_r;
        o_cf  = cf_r;
    end

endmodule
