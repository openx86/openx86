// ============================================================================
// X87 FPU 子集（栈式寄存器 ST0–ST7）
// 数值为 64 位有符号整数路径（可综合）；后续可替换为 IEEE754 软浮点
// ============================================================================

module execute_x87_fpu (
    input  logic        clk,
    input  logic        rst,
    input  logic        i_valid,
    input  logic [ 4:0] i_op,
    input  logic [63:0] i_push_data,
    input  logic [ 2:0] i_st_src,
    output logic [63:0] o_st0,
    output logic [63:0] o_st1,
    output logic        o_zf,
    output logic        o_pf,
    output logic        o_cf
);

    import execute_unit_pkg::*;

    logic [63:0] phys [0:7];
    logic [ 2:0] top;

    wire [2:0] p0 = top + 3'd0;
    wire [2:0] p1 = top + 3'd1;
    wire [2:0] px = top + i_st_src;

    always_ff @(posedge clk) begin
        if (rst) begin
            top <= 3'd0;
            for (int k = 0; k < 8; k++) phys[k] <= 64'h0;
        end else if (i_valid) begin
            unique case (i_op)
                X87_FLD: begin
                    phys[top - 3'd1] <= i_push_data;
                    top <= top - 3'd1;
                end
                X87_FSTP: begin
                    top <= top + 3'd1;
                end
                X87_FADD: begin
                    phys[p1] <= phys[p1] + phys[p0];
                    top <= top + 3'd1;
                end
                X87_FSUB: begin
                    phys[p1] <= phys[p1] - phys[p0];
                    top <= top + 3'd1;
                end
                X87_FMUL: begin
                    phys[p1] <= phys[p1] * phys[p0];
                    top <= top + 3'd1;
                end
                X87_FDIV: begin
                    if (phys[p0] != 64'h0)
                        phys[p1] <= phys[p1] / phys[p0];
                    top <= top + 3'd1;
                end
                X87_FCHS: begin
                    phys[p0] <= -$signed(phys[p0]);
                end
                X87_FABS: begin
                    phys[p0] <= ($signed(phys[p0]) < 64'sd0) ? -$signed(phys[p0]) : phys[p0];
                end
                X87_FXCH: begin
                    phys[p0] <= phys[px];
                    phys[px] <= phys[p0];
                end
                default: ;
            endcase
        end
    end

    always_comb begin
        o_st0 = phys[p0];
        o_st1 = phys[p1];
        o_zf  = (phys[p0] == phys[p1]);
        o_pf  = 1'b0;
        o_cf  = ($signed(phys[p0]) < $signed(phys[p1]));
    end

endmodule
