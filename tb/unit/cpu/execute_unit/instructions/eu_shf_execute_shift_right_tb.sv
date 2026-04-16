`timescale 1ns/1ns

module eu_shf_execute_shift_right_tb;
    logic [31:0] op, cnt, is_signed, y;

    eu_shf_execute_shift_right u_dut (
        .operand(op),
        .count(cnt),
        .is_signed(is_signed),
        .result(y)
    );

    initial begin
        op = 32'h8000_0000; cnt = 32'd1; is_signed = 32'd0; #1;
        if (y !== 32'h4000_0000) begin
            $display("FAIL shr");
            $finish(1);
        end
        op = 32'h8000_0000; cnt = 32'd1; is_signed = 32'd1; #1;
        if (y !== 32'hC000_0000) begin
            $display("FAIL sar");
            $finish(1);
        end
        $display("eu_shf_execute_shift_right_tb PASS");
        $finish;
    end
endmodule
