`timescale 1ns/1ns

module eu_bit_bsf_tb;
    logic [31:0] a;
    logic [31:0] y;
    logic        zf;

    stage_3_exe_bit_bsf u_dut (
        .a ( a ),
        .y ( y ),
        .zf ( zf )
    );

    initial begin
        a = 32'h0000_0000; #1;
        if (zf !== 1'b1 || y !== 32'd0) begin
            $display("FAIL stage_3_exe_bit_bsf zero");
            $finish(1);
        end

        a = 32'h0010_0800; #1;
        if (zf !== 1'b0 || y !== 32'd11) begin
            $display("FAIL stage_3_exe_bit_bsf nonzero");
            $finish(1);
        end

        $display("eu_bit_bsf_tb PASS");
        $finish;
    end
endmodule
