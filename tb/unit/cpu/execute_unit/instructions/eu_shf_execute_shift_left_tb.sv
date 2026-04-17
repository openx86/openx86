`timescale 1ns/1ns

module eu_shf_execute_shift_left_tb;
    logic [31:0] op, cnt, y;

    stage_3_exe_shf_execute_shift_left u_dut (
        .operand(op),
        .count(cnt),
        .result(y)
    );

    initial begin
        op = 32'h0000_0001; cnt = 32'd4; #1;
        if (y !== 32'h0000_0010) begin
            $display("FAIL shl");
            $finish(1);
        end
        $display("eu_shf_execute_shift_left_tb PASS");
        $finish;
    end
endmodule
