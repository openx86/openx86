`timescale 1ns/1ns

module eu_ari_execute_arithmetic_sub_tb;
    logic [31:0] a, b, y;

    stage_3_exe_ari_execute_arithmetic_sub u_dut (
        .operand_1(a),
        .operand_2(b),
        .result(y)
    );

    initial begin
        a = 32'd9; b = 32'd4; #1;
        if (y !== 32'd5) begin
            $display("FAIL sub");
            $finish(1);
        end
        $display("eu_ari_execute_arithmetic_sub_tb PASS");
        $finish;
    end
endmodule
