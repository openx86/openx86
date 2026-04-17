`timescale 1ns/1ns

module eu_misc_aaa_tb;
    logic [31:0] a;
    logic        af_in;
    logic [31:0] y;
    logic        af_out;
    logic        cf_out;

    stage_3_exe_eu_misc_aaa u_dut (
        .a ( a ),
        .af_in ( af_in ),
        .y ( y ),
        .af_out ( af_out ),
        .cf_out ( cf_out )
    );

    initial begin
        a = 32'h0000_020B;
        af_in = 1'b0;
        #1;
        if ((y !== 32'h0000_0301) || (af_out !== 1'b1) || (cf_out !== 1'b1)) begin
            $display("FAIL stage_3_exe_eu_misc_aaa adjust");
            $finish(1);
        end

        a = 32'h0000_0209;
        af_in = 1'b0;
        #1;
        if ((y !== 32'h0000_0209) || (af_out !== 1'b0) || (cf_out !== 1'b0)) begin
            $display("FAIL stage_3_exe_eu_misc_aaa no-adjust");
            $finish(1);
        end

        $display("eu_misc_aaa_tb PASS");
        $finish;
    end
endmodule
