`timescale 1ns/1ps

module x86_reg_interrupt_descriptor_table_tb;

    logic        IDTR_write_enable;
    logic [15:0] IDTR_write_data_limit;
    logic [31:0] IDTR_write_data_base;
    logic [15:0] IDTR_limit;
    logic [31:0] IDTR_base;
    logic        clock;
    logic        reset;

    initial clock = 0;
    always #5 clock = ~clock;

    x86_reg_interrupt_descriptor_table dut (
        .IDTR_write_enable    (IDTR_write_enable),
        .IDTR_write_data_limit(IDTR_write_data_limit),
        .IDTR_write_data_base (IDTR_write_data_base),
        .IDTR_limit           (IDTR_limit),
        .IDTR_base            (IDTR_base),
        .clock                (clock),
        .reset                (reset)
    );

    initial begin
        IDTR_write_enable     = 0;
        IDTR_write_data_limit = '0;
        IDTR_write_data_base  = '0;
        reset                 = 1;
        repeat (2) @(posedge clock);
        reset = 0;

        @(posedge clock);
        IDTR_write_enable     = 1;
        IDTR_write_data_limit = 16'h01FF;
        IDTR_write_data_base  = 32'h0000_9000;

        @(posedge clock);
        IDTR_write_enable = 0;

        @(posedge clock);
        $display("[x86_reg_interrupt_descriptor_table] limit=%h base=%h",
                 IDTR_limit, IDTR_base);

        #20;
        $finish;
    end

endmodule

