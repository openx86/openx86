/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements execute_x87_fpu.
*/
// ============================================================================
// X87 FPU 子集（栈式寄存器 ST0–ST7）
// 数值为 64 位有符号整数路径（可综合）；后续可替换为 IEEE754 软浮点
// ============================================================================

`include "openx86_defs.h.sv"

module execute_x87_fpu (    input  logic          i_valid,  // 操作有效
    input  logic [ 4: 0]   i_op,  // 乘除操作类型
    input  logic [63: 0] i_push_data,  // 压栈数据
    input  logic [ 2: 0]   i_st_src,  // 源栈寄存器编号
    output logic [63: 0] o_st0,  // 栈顶 ST0
    output logic [63: 0] o_st1,  // 次栈顶 ST1
    output logic         o_zf,  // ZF 输出
    output logic         o_pf,  // PF 输出
    output logic         o_cf,  // CF 输出
    input  logic          clk,  // 时钟
    input  logic          rst_n  // 异步低有效复位
);
    // ST0–ST7 物理寄存器；top 为栈顶索引（向下增长）
    logic [63: 0] phys [ 0:  7];
    logic [ 2: 0] top;
    // 最近一次比较类指令输出的标志影子寄存器
    logic        zf_r;
    logic        pf_r;
    logic        cf_r;

    // 物理索引：p0=栈顶，p1=次栈顶，px=操作数 STi
    logic [ 2: 0] p0;
    logic [ 2: 0] p1;
    logic [ 2: 0] px;

    // 组合逻辑：连续赋值
    assign p0 = top + 3'd0;
    assign p1 = top + 3'd1;
    assign px = top + i_st_src;

    // 时序逻辑：寄存器更新
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            top <= 3'd0;
            zf_r <= 1'b0;
            pf_r <= 1'b0;
            cf_r <= 1'b0;
            for (int k = 0; k < 8; k++) phys[k] <= 64'h0;
        end else if (i_valid) begin
            // X87 子操作：更新物理寄存器堆与栈顶指针
            unique case (i_op)
                `EXE_X87_FLD: begin
                    phys[top - 3'd1] <= i_push_data;
                    top <= top - 3'd1;
                end
                `EXE_X87_FLD_STI: begin
                    phys[top - 3'd1] <= phys[px];
                    top <= top - 3'd1;
                end
                `EXE_X87_FLD1: begin
                    phys[top - 3'd1] <= i_push_data;
                    top <= top - 3'd1;
                end
                `EXE_X87_FLDZ: begin
                    phys[top - 3'd1] <= i_push_data;
                    top <= top - 3'd1;
                end
                `EXE_X87_FST: begin
                    phys[px] <= phys[p0];
                end
                `EXE_X87_FSTP: begin
                    phys[px] <= phys[p0];
                    top <= top + 3'd1;
                end
                `EXE_X87_FADD: begin
                    phys[p0] <= phys[p0] + phys[px];
                end
                `EXE_X87_FADDP: begin
                    phys[px] <= phys[px] + phys[p0];
                    top <= top + 3'd1;
                end
                `EXE_X87_FSUB: begin
                    phys[p0] <= phys[p0] - phys[px];
                end
                `EXE_X87_FSUBR: begin
                    phys[p0] <= phys[px] - phys[p0];
                end
                `EXE_X87_FSUBP: begin
                    phys[px] <= phys[px] - phys[p0];
                    top <= top + 3'd1;
                end
                `EXE_X87_FSUBRP: begin
                    phys[px] <= phys[p0] - phys[px];
                    top <= top + 3'd1;
                end
                `EXE_X87_FMUL: begin
                    phys[p0] <= phys[p0] * phys[px];
                end
                `EXE_X87_FMULP: begin
                    phys[px] <= phys[px] * phys[p0];
                    top <= top + 3'd1;
                end
                `EXE_X87_FDIV: begin
                    if (phys[px] != 64'h0)
                        phys[p0] <= phys[p0] / phys[px];
                end
                `EXE_X87_FDIVR: begin
                    if (phys[p0] != 64'h0)
                        phys[p0] <= phys[px] / phys[p0];
                end
                `EXE_X87_FDIVP: begin
                    if (phys[p0] != 64'h0)
                        phys[px] <= phys[px] / phys[p0];
                    top <= top + 3'd1;
                end
                `EXE_X87_FDIVRP: begin
                    if (phys[px] != 64'h0)
                        phys[px] <= phys[p0] / phys[px];
                    top <= top + 3'd1;
                end
                `EXE_X87_FCHS: begin
                    phys[p0] <= -$signed(phys[p0]);
                end
                `EXE_X87_FABS: begin
                    phys[p0] <= ($signed(phys[p0]) < 64'sd0) ? -$signed(phys[p0]) : phys[p0];
                end
                `EXE_X87_FXCH: begin
                    phys[p0] <= phys[px];
                    phys[px] <= phys[p0];
                end
                `EXE_X87_FFREE: begin
                    phys[px] <= 64'h0;
                end
                `EXE_X87_FCOM: begin
                    zf_r <= (phys[p0] == phys[px]);
                    pf_r <= 1'b0;
                    cf_r <= ($signed(phys[p0]) < $signed(phys[px]));
                end
                `EXE_X87_FCOMP: begin
                    zf_r <= (phys[p0] == phys[px]);
                    pf_r <= 1'b0;
                    cf_r <= ($signed(phys[p0]) < $signed(phys[px]));
                    top <= top + 3'd1;
                end
                `EXE_X87_FCOMIP,
                `EXE_X87_FUCOMIP: begin
                    zf_r <= (phys[p0] == phys[px]);
                    pf_r <= 1'b0;
                    cf_r <= ($signed(phys[p0]) < $signed(phys[px]));
                    top <= top + 3'd1;
                end
                `EXE_X87_FTST: begin
                    zf_r <= (phys[p0] == 64'h0);
                    pf_r <= 1'b0;
                    cf_r <= ($signed(phys[p0]) < 64'sd0);
                end
                `EXE_X87_FNOP: begin
                    ;
                end
                `EXE_X87_FCOMI: begin
                    zf_r <= (phys[p0] == phys[px]);
                    pf_r <= 1'b0;
                    cf_r <= ($signed(phys[p0]) < $signed(phys[px]));
                end
                default: ;
            endcase
        end
    end

    // 组合逻辑：推导输出
    always_comb begin
        o_st0 = phys[p0];
        o_st1 = phys[p1];
        o_zf  = zf_r;
        o_pf  = pf_r;
        o_cf  = cf_r;
    end

endmodule
