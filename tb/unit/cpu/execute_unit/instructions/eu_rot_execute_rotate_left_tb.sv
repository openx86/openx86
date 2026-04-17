`timescale 1ns/1ns

module eu_rot_execute_rotate_left_tb;
    logic [31:0] op, cnt, y;

    stage_3_exe_rot_execute_rotate_left u_dut (
        .operand(op),
        .count(cnt),
        .result(y)
    );

    initial begin
        op = 32'h1234_5678; cnt = 32'd8; #1;
        if (y !== 32'h3456_7812) begin
            $display("FAIL rol");
            $finish(1);
        end
        $display("eu_rot_execute_rotate_left_tb PASS");
        $finish;
    end
endmodule
