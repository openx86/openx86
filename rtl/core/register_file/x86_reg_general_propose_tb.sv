`timescale 1ns/1ps

module x86_reg_general_propose_tb;

    logic        write_enable;
    logic [2:0]  write_index;
    logic [31:0] write_data;
    logic [7:0]  AL, BL, CL, DL;
    logic [7:0]  AH, BH, CH, DH;
    logic [31:0] AX, CX, DX, BX;
    logic [31:0] SP;
    logic [15:0] BP, SI, DI;
    logic [31:0] EAX, ECX, EDX, EBX, ESP, EBP, ESI, EDI;
    logic        clock;
    logic        reset;

    initial clock = 0;
    always #5 clock = ~clock;

    x86_reg_general_propose dut (
        .write_enable(write_enable),
        .write_index (write_index),
        .write_data  (write_data),
        .AL          (AL),
        .BL          (BL),
        .CL          (CL),
        .DL          (DL),
        .AH          (AH),
        .BH          (BH),
        .CH          (CH),
        .DH          (DH),
        .AX          (AX),
        .CX          (CX),
        .DX          (DX),
        .BX          (BX),
        .SP          (SP),
        .BP          (BP),
        .SI          (SI),
        .DI          (DI),
        .EAX         (EAX),
        .ECX         (ECX),
        .EDX         (EDX),
        .EBX         (EBX),
        .ESP         (ESP),
        .EBP         (EBP),
        .ESI         (ESI),
        .EDI         (EDI),
        .clock       (clock),
        .reset       (reset)
    );

    initial begin
        write_enable = 0;
        write_index  = '0;
        write_data   = '0;
        reset        = 1;
        repeat (2) @(posedge clock);
        reset = 0;

        // write to few general registers
        @(posedge clock);
        write_enable = 1;
        write_index  = 3'd0; // EAX
        write_data   = 32'h1122_3344;

        @(posedge clock);
        write_index  = 3'd1; // ECX
        write_data   = 32'h5566_7788;

        @(posedge clock);
        write_index  = 3'd4; // ESP
        write_data   = 32'h0000_1234;

        @(posedge clock);
        write_enable = 0;

        @(posedge clock);
        $display("[x86_reg_general_propose] AL=%h AH=%h EAX=%h ECX=%h ESP=%h",
                 AL, AH, EAX, ECX, ESP);

        #20;
        $finish;
    end

endmodule

