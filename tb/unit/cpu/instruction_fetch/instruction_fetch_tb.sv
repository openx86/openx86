/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements instruction_fetch_tb.
*/
// project: w80386dx
// author: Chang Wei<changwei1006@gmail.com>
// repo: https://github.com/openx86/w80386dx
// module: fetch_tb
// create at: 2021-12-17 01:23:49
// description: test fetch module

`timescale 1ns/1ns
module instruction_fetch_tb (
    // ports
);

logic        bus_read_vaild;
logic        bus_read_ready;
logic [31:0] bus_read_address;
logic [31:0] bus_read_data;
logic [31:0] program_counter;
logic        program_counter_valid;
logic [ 7:0] instruction [0:9];
logic [ 7:0] instruction_full [0:15];
logic        instruction_ready;
logic        clock, reset;
logic [15:0] segment_selector [0:5];
logic [63:0] segment_descriptor [0:5];
logic        segment_fault_unused;
logic        mmu_bus_valid_unused;
logic [31:0] mmu_bus_addr_unused;

stage_1_isc fetch_inst (
    .o_code_vaild              ( bus_read_vaild ),
    .i_code_ready              ( bus_read_ready ),
    .o_code_address            ( bus_read_address ),
    .i_code_data_read          ( bus_read_data ),
    .o_mmu_bus_vaild           ( mmu_bus_valid_unused ),
    .i_mmu_bus_ready           ( 1'b0 ),
    .o_mmu_bus_addr            ( mmu_bus_addr_unused ),
    .i_mmu_bus_rdata           ( 32'h0 ),
    .i_protected_mode          ( 1'b0 ),
    .i_segment_selector        ( segment_selector ),
    .i_segment_descriptor      ( segment_descriptor ),
    .i_current_privilege_level ( 2'b00 ),
    .i_paging_enable           ( 1'b0 ),
    .i_page_directory_base     ( 32'h0 ),
    .i_IP_vaild                ( program_counter_valid ),
    .o_instruction             ( instruction_full ),
    .o_instruction_ready       ( instruction_ready ),
    .o_segment_fault           ( segment_fault_unused ),
    .EIP                       ( program_counter ),
    .clock                     ( clock ),
    .reset                     ( reset )
);

always_comb begin
    for (int k = 0; k < 10; k++) begin
        instruction[k] = instruction_full[k];
    end
end

reg [31:0] i;
int unsigned wait_cycles;

always #1 clock = ~clock;

always_ff @(posedge clock or posedge reset) begin
    if (reset) begin
        bus_read_ready <= 1'b0;
        bus_read_data  <= 32'h0;
    end else begin
        // Keep bus ready asserted while fetch requests are active so the
        // fetch unit can collect all words in the burst.
        bus_read_ready <= bus_read_vaild;
        bus_read_data  <= bus_read_vaild ? 32'h1234_5678 : 32'h0;
    end
end

initial begin
    for (int s = 0; s < 6; s++) begin
        segment_selector[s] = 16'h0;
        segment_descriptor[s] = 64'h0;
    end

    bus_read_ready = 0;
    bus_read_data = 0;
    program_counter = 0;
    program_counter_valid = 0;
    clock = 0;
    reset = 1;
    #2;
    reset = 0;

    // bus_read_ready = 1;
    // bus_read_data = 32'h0000_0001;
    // bus_read_data = 32'h0001_1011;

    for(i=0;i<4;i=i+1) begin
        // program_counter = 32'h0000_0000;
        program_counter = i;
        program_counter_valid = 1;
        $display("%t: test fetch instruction: program_counter=%h", $time, program_counter);
        wait_cycles = 0;
        while (!instruction_ready && (wait_cycles < 400)) begin
            @(posedge clock);
            wait_cycles = wait_cycles + 1;
        end
        if (!instruction_ready) begin
            $display("FAIL instruction_fetch timeout: pc=%h code_valid=%0b code_addr=%h", program_counter, bus_read_vaild, bus_read_address);
            $finish;
        end
        program_counter_valid = 0;
        $monitor("%t: instruction_ready=%h, instruction=%p", $time, instruction_ready, instruction);
        $monitor("%t: bus_read_vaild=%h, bus_read_address=%h", $time, bus_read_vaild, bus_read_address);
        #32;
    end

    // #8;

    #64;

    $finish;
end

endmodule
