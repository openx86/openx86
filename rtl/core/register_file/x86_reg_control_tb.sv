`timescale 1ns/1ps

module x86_reg_control_tb;

    // DUT ports
    logic         write_enable;
    logic [2:0]   write_index;
    logic [31:0]  write_data;
    logic [31:0]  CR [0:7];
    logic         PE, MP, EM, TS, R, PG;
    logic [19:0]  page_directory_base;
    logic         clock;
    logic         reset;

    // clock generation
    initial clock = 0;
    always #5 clock = ~clock;

    // DUT instance
    x86_reg_control dut (
        .write_enable      (write_enable),
        .write_index       (write_index),
        .write_data        (write_data),
        .CR                (CR),
        .PE                (PE),
        .MP                (MP),
        .EM                (EM),
        .TS                (TS),
        .R                 (R),
        .PG                (PG),
        .page_directory_base(page_directory_base),
        .clock             (clock),
        .reset             (reset)
    );

    // basic stimulus
    initial begin
        // init
        write_enable = 0;
        write_index  = '0;
        write_data   = '0;
        reset        = 1;
        repeat (2) @(posedge clock);
        reset = 0;

        // write CR0
        @(posedge clock);
        write_enable = 1;
        write_index  = 3'd0;
        write_data   = 32'h8000_000F; // set PG and low control bits

        @(posedge clock);
        write_enable = 0;

        // write CR3 to check page_directory_base
        @(posedge clock);
        write_enable = 1;
        write_index  = 3'd3;
        write_data   = 32'h1234_5000;

        @(posedge clock);
        write_enable = 0;

        // observe some outputs
        @(posedge clock);
        $display("[x86_reg_control] PE=%0d MP=%0d EM=%0d TS=%0d R=%0d PG=%0d PDB=%h",
                 PE, MP, EM, TS, R, PG, page_directory_base);

        #20;
        $finish;
    end

endmodule

