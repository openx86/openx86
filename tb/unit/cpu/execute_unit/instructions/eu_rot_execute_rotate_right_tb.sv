`timescale 1ns/1ns

module eu_rot_execute_rotate_right_tb;
    logic [31:0] op, cnt, y;

    eu_rot_execute_rotate_right u_dut (
        .operand(op),
        .count(cnt),
        .result(y)
    );

    initial begin
        op = 32'h1234_5678; cnt = 32'd8; #1;
        if (y !== 32'h7812_3456) begin
            $display("FAIL ror");
            $finish(1);
        end
        $display("eu_rot_execute_rotate_right_tb PASS");
        $finish;
    end
endmodule
