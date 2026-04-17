`timescale 1ns/1ns

module eu_ari_execute_arithmetic_add_tb;
    logic [31:0] a, b, y;

    stage_3_exe_ari_execute_arithmetic_add u_dut (
        .operand_1(a),
        .operand_2(b),
        .result(y)
    );

    initial begin
        a = 32'd2; b = 32'd3; #1;
        if (y !== 32'd5) begin
            $display("FAIL add");
            $finish(1);
        end
        $display("eu_ari_execute_arithmetic_add_tb PASS");
        $finish;
    end
endmodule
