/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: testbench for IFU-DEC length handshake with FIFO consume.
*/
`timescale 1ns/1ns

module ifu_dec_tb;

    logic                clk;
    logic                rst_n;

    logic                o_code_vaild;
    logic                i_code_ready;
    logic [31: 0]        o_code_address;
    logic [31: 0]        i_code_data_read;

    logic                o_mmu_bus_vaild;
    logic                i_mmu_bus_ready;
    logic [31: 0]        o_mmu_bus_addr;
    logic [31: 0]        i_mmu_bus_rdata;

    logic                i_protected_mode;
    logic [ 5: 0][15: 0] i_segment_selector;
    logic [ 5: 0][63: 0] i_segment_descriptor;
    logic [ 1: 0]        i_current_privilege_level;
    logic                i_paging_enable;
    logic [31: 0]        i_page_directory_base;

    logic                i_start;
    logic [31: 0]        i_initial_eip;
    logic                i_reload_eip;
    logic [31: 0]        i_reload_eip_value;

    logic [15: 0][ 7: 0] o_instruction;
    logic                o_instruction_valid;
    logic [ 3: 0]        o_decode_length;
    logic                o_decode_fire;
    logic                o_decode_error;
    logic                o_segment_fault;
    logic [ 4: 0]        o_fifo_count;
    logic [31: 0]        o_eip;

    ifu u_dut (
        .o_code_vaild              ( o_code_vaild ),
        .i_code_ready              ( i_code_ready ),
        .o_code_address            ( o_code_address ),
        .i_code_data_read          ( i_code_data_read ),
        .o_mmu_bus_vaild           ( o_mmu_bus_vaild ),
        .i_mmu_bus_ready           ( i_mmu_bus_ready ),
        .o_mmu_bus_addr            ( o_mmu_bus_addr ),
        .i_mmu_bus_rdata           ( i_mmu_bus_rdata ),
        .i_protected_mode          ( i_protected_mode ),
        .i_segment_selector        ( i_segment_selector ),
        .i_segment_descriptor      ( i_segment_descriptor ),
        .i_current_privilege_level ( i_current_privilege_level ),
        .i_paging_enable           ( i_paging_enable ),
        .i_page_directory_base     ( i_page_directory_base ),
        .i_start                   ( i_start ),
        .i_initial_eip             ( i_initial_eip ),
        .i_reload_eip              ( i_reload_eip ),
        .i_reload_eip_value        ( i_reload_eip_value ),
        .o_instruction             ( o_instruction ),
        .o_instruction_valid       ( o_instruction_valid ),
        .o_decode_length           ( o_decode_length ),
        .o_decode_fire             ( o_decode_fire ),
        .o_decode_error            ( o_decode_error ),
        .o_segment_fault           ( o_segment_fault ),
        .o_fifo_count              ( o_fifo_count ),
        .o_eip                     ( o_eip ),
        .clk                       ( clk ),
        .rst_n                     ( rst_n )
    );

    task automatic tick;
        begin
            #5 clk = 1'b1;
            #5 clk = 1'b0;
        end
    endtask

    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            i_code_ready     <= 1'b0;
            i_code_data_read <= 32'h0000_0000;
        end else begin
            i_code_ready     <= o_code_vaild;
            i_code_data_read <= 32'h9090_9090;
        end
    end

    initial begin
        int fire_count;

        clk                       = 1'b0;
        rst_n                     = 1'b0;
        i_protected_mode          = 1'b0;
        i_current_privilege_level = 2'b00;
        i_paging_enable           = 1'b0;
        i_page_directory_base     = 32'h0000_0000;
        i_start                   = 1'b0;
        i_initial_eip             = 32'h0000_1000;
        i_reload_eip              = 1'b0;
        i_reload_eip_value        = 32'h0000_0000;

        i_mmu_bus_ready = 1'b1;
        i_mmu_bus_rdata = 32'h0000_0000;

        for (int i = 0; i < 6; i++) begin
            i_segment_selector[i]   = 16'h0000;
            i_segment_descriptor[i] = 64'h0000_0000_0000_0000;
        end

        repeat (2) tick();
        rst_n   = 1'b1;
        i_start = 1'b1;

        fire_count = 0;
        for (int cyc = 0; cyc < 200; cyc++) begin
            tick();

            if (o_instruction_valid && (o_fifo_count == 5'd0)) begin
                $fatal(1, "ifu valid should not be high when fifo count is zero");
            end

            if (o_decode_fire) begin
                fire_count++;
                if (o_decode_length !== 4'd1) begin
                    $fatal(1, "expected NOP length=1, got %0d", o_decode_length);
                end
                if (o_decode_error !== 1'b0) begin
                    $fatal(1, "unexpected decode error during NOP stream");
                end
            end

            if (fire_count >= 10) begin
                break;
            end
        end

        if (fire_count < 10) begin
            $fatal(1, "timeout waiting decode fire events");
        end

        $display("ifu_dec_tb PASS");
        $finish;
    end

endmodule
