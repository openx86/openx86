`timescale 1ns/1ns

module eu_bit_bt_tb;
    logic [31:0] a;
    logic [31:0] b;
    logic [31:0] y;
    logic        cf;

    stage_3_exe_eu_bit_bt u_dut (
        .a ( a ),
        .bit_index ( b ),
        .y ( y ),
        .cf ( cf )
    );

    initial begin
        a = 32'h0000_0020;
        b = 32'd5;
        #1;
        if (cf !== 1'b1 || y !== a) begin
            $display("FAIL stage_3_exe_eu_bit_bt bit1");
            $finish(1);
        end

        b = 32'd4;
        #1;
        if (cf !== 1'b0 || y !== a) begin
            $display("FAIL stage_3_exe_eu_bit_bt bit0");
            $finish(1);
        end

        $display("eu_bit_bt_tb PASS");
        $finish;
    end
endmodule
