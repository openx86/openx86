`timescale 1ns/1ps

module x86_reg_flags_tb;

    logic        write_enable;
    logic [31:0] write_data;
    logic        CF, PF, AF, ZF, SF, TF, IF, DF, OF;
    logic [1:0]  IOPL;
    logic        NT, RF, VM;
    logic [31:0] EFLAGS;
    logic [15:0] FLAGS;
    logic        clock;
    logic        reset;

    initial clock = 0;
    always #5 clock = ~clock;

    x86_reg_flags dut (
        .write_enable(write_enable),
        .write_data  (write_data),
        .CF          (CF),
        .PF          (PF),
        .AF          (AF),
        .ZF          (ZF),
        .SF          (SF),
        .TF          (TF),
        .IF          (IF),
        .DF          (DF),
        .OF          (OF),
        .IOPL        (IOPL),
        .NT          (NT),
        .RF          (RF),
        .VM          (VM),
        .EFLAGS      (EFLAGS),
        .FLAGS       (FLAGS),
        .clock       (clock),
        .reset       (reset)
    );

    initial begin
        write_enable = 0;
        write_data   = '0;
        reset        = 1;
        repeat (2) @(posedge clock);
        reset = 0;

        // write a value with several flags set
        @(posedge clock);
        write_enable = 1;
        write_data   = 32'h0003_FF5D;

        @(posedge clock);
        write_enable = 0;

        @(posedge clock);
        $display("[x86_reg_flags] EFLAGS=%h FLAGS=%h CF=%0d PF=%0d AF=%0d ZF=%0d SF=%0d TF=%0d IF=%0d DF=%0d OF=%0d IOPL=%0d NT=%0d RF=%0d VM=%0d",
                 EFLAGS, FLAGS, CF, PF, AF, ZF, SF, TF, IF, DF, OF, IOPL, NT, RF, VM);

        #20;
        $finish;
    end

endmodule

