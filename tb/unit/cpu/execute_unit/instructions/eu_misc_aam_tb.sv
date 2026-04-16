`timescale 1ns/1ns

module eu_misc_aam_tb;
    logic [31:0] a;
    logic [31:0] b;
    logic [31:0] y;

    eu_misc_aam u_dut (
        .a ( a ),
        .b ( b ),
        .y ( y )
    );

    initial begin
        a = 32'h0000_0017;
        b = 32'h0000_0000; // defaults to base 10
        #1;
        if (y !== 32'h0000_0203) begin
            $display("FAIL eu_misc_aam base10");
            $finish(1);
        end

        a = 32'h0000_000E;
        b = 32'h0000_0004;
        #1;
        if (y !== 32'h0000_0302) begin
            $display("FAIL eu_misc_aam base4");
            $finish(1);
        end

        $display("eu_misc_aam_tb PASS");
        $finish;
    end
endmodule
