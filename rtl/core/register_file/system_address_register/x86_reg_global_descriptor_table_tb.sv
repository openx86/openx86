`timescale 1ns/1ps

module x86_reg_global_descriptor_table_tb;

    logic        GDTR_write_enable;
    logic [15:0] GDTR_write_data_limit;
    logic [31:0] GDTR_write_data_base;
    logic [15:0] GDTR_limit;
    logic [31:0] GDTR_base;
    logic        clock;
    logic        reset;

    initial clock = 0;
    always #5 clock = ~clock;

    x86_reg_global_descriptor_table dut (
        .GDTR_write_enable    (GDTR_write_enable),
        .GDTR_write_data_limit(GDTR_write_data_limit),
        .GDTR_write_data_base (GDTR_write_data_base),
        .GDTR_limit           (GDTR_limit),
        .GDTR_base            (GDTR_base),
        .clock                (clock),
        .reset                (reset)
    );

    initial begin
        GDTR_write_enable     = 0;
        GDTR_write_data_limit = '0;
        GDTR_write_data_base  = '0;
        reset                 = 1;
        repeat (2) @(posedge clock);
        reset = 0;

        @(posedge clock);
        GDTR_write_enable     = 1;
        GDTR_write_data_limit = 16'h003F;
        GDTR_write_data_base  = 32'h0000_8000;

        @(posedge clock);
        GDTR_write_enable = 0;

        @(posedge clock);
        $display("[x86_reg_global_descriptor_table] limit=%h base=%h",
                 GDTR_limit, GDTR_base);

        #20;
        $finish;
    end

endmodule

