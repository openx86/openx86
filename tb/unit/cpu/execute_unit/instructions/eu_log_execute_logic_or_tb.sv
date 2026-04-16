`timescale 1ns/1ns

module eu_log_execute_logic_or_tb;
    logic [31:0] a, b, y;

    eu_log_execute_logic_or u_dut (
        .operand_1(a),
        .operand_2(b),
        .result(y)
    );

    initial begin
        a = 32'hF0F0_00FF; b = 32'h0FF0_F00F; #1;
        if (y !== 32'hFFF0_F0FF) begin
            $display("FAIL or");
            $finish(1);
        end
        $display("eu_log_execute_logic_or_tb PASS");
        $finish;
    end
endmodule
