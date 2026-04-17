`timescale 1ns/1ns

module eu_ari_execute_arithmetic_sbb_tb;
    logic [31:0] a, b, y;
    logic        cf;

    stage_3_exe_ari_execute_arithmetic_sbb u_dut (
        .operand_1(a),
        .operand_2(b),
        .carry_flag(cf),
        .result(y)
    );

    initial begin
        a = 32'd9; b = 32'd4; cf = 1'b1; #1;
        if (y !== 32'd4) begin
            $display("FAIL sbb");
            $finish(1);
        end
        $display("eu_ari_execute_arithmetic_sbb_tb PASS");
        $finish;
    end
endmodule
