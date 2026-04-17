`timescale 1ns/1ns

module eu_log_execute_logic_and_tb;
    logic [31:0] a, b, y;

    stage_3_exe_eu_log_execute_logic_and u_dut (
        .operand_1(a),
        .operand_2(b),
        .result(y)
    );

    initial begin
        a = 32'hF0F0_00FF; b = 32'h0FF0_F00F; #1;
        if (y !== 32'h00F0_000F) begin
            $display("FAIL and");
            $finish(1);
        end
        $display("eu_log_execute_logic_and_tb PASS");
        $finish;
    end
endmodule
