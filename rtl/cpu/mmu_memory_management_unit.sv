/*
project: w80386dx
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/w80386dx
module: mmu_memory_management_unit
create at: 2022-02-04 23:34:40
description: mmu_memory_management_unit
*/

module mmu_memory_management_unit #(
    parameter bit read_from_fetch = 1'b0
) (
    // handshake
    input  logic         i_vaild,
    output logic         o_ready,
    // signal
    input  logic         i_protected_mode, // from CR0.PE (CR[0][0])
    input  logic [15: 0] i_segment_selector [6], // from segment register file
    input  logic [ 1: 0] i_current_privilege_level, // from flags register file
    input  logic [ 2: 0] i_segment_index, // from bus_interface_unit module
    input  logic [31: 0] i_effective_address, // from bus_interface_unit module
    input  logic         i_write_enable, // from bus_interface_unit module
    input  logic         i_paging_enable, // from CR register
    input  logic [31: 0] i_page_directory_base, // from CR[3]
    output logic [31: 0] o_physical_address,
    // bus for paging walks (used only when paging enabled)
    output logic        o_bus_vaild,
    input  logic        i_bus_ready,
    output logic        o_bus_write_enable,
    output logic [31:0] o_bus_address,
    input  logic [31:0] i_bus_data_read,
    output logic [31:0] o_bus_data_write,
    // common
    input  logic         clock, reset
);

logic [31: 0] linear_address;
logic [31: 0] physical_address;

logic         paging_vaild;
logic         paging_ready;

// Bring-up：描述符缓存尚未接到 MMU 时，用全 0 占位（实模式/未保护路径）
logic [63:0] segment_descriptor_stub [0:5];
always_comb begin
    for (int i = 0; i < 6; i++) begin
        segment_descriptor_stub[i] = 64'h0;
    end
end

mmu_seg_segmentation_unit #(
    .read_from_fetch ( read_from_fetch )
) mmu_segmentation_unit (
    .i_protected_mode ( i_protected_mode ),
    .i_segment_selector ( i_segment_selector ),
    .o_segment_descriptor ( segment_descriptor_stub ),
    .i_current_privilege_level ( i_current_privilege_level ),
    .i_segment_index ( i_segment_index ),
    .i_effective_address ( i_effective_address ),
    .i_write_enable ( i_write_enable ),
    .o_linear_address ( linear_address ),
    .clock ( clock ),
    .reset ( reset )
);

mmu_pg_paging_unit mmu_paging_unit (
    .i_vaild ( paging_vaild ),
    .o_ready ( paging_ready ),
    .i_linear_address ( linear_address ),
    .i_page_directory_base ( i_page_directory_base ),
    .o_physical_address ( physical_address ),
    .o_bus_vaild ( o_bus_vaild ),
    .i_bus_ready ( i_bus_ready ),
    .o_bus_write_enable ( o_bus_write_enable ),
    .o_bus_address ( o_bus_address ),
    .i_bus_data_read ( i_bus_data_read ),
    .o_bus_data_write ( o_bus_data_write ),
    .clock ( clock ),
    .reset ( reset )
);


enum logic [1:0] {
    STATE_WAIT_FOR_PAGING_UNIT_READY = 2'h1,
    STATE_OUTPUT_LINEAR_ADDRESS = 2'h2,
    STATE_WAIT_FOR_VAILD = 2'h0
} state;

always_ff @(posedge clock or posedge reset) begin
    if (reset) begin
        state <= STATE_WAIT_FOR_VAILD;
        o_ready <= 0;
    end else begin
        unique case (state)
            STATE_WAIT_FOR_VAILD: begin
                if (i_vaild) begin
                    o_ready <= 0;
                    if (i_paging_enable) begin
                        state <= STATE_WAIT_FOR_PAGING_UNIT_READY;
                        paging_vaild <= 1;
                    end else begin
                        state <= STATE_OUTPUT_LINEAR_ADDRESS;
                        paging_vaild <= 0;
                    end
                end else begin
                    state <= STATE_WAIT_FOR_VAILD;
                    paging_vaild <= 0;
                end
            end
            STATE_WAIT_FOR_PAGING_UNIT_READY: begin
                if (paging_ready) begin
                    state <= STATE_WAIT_FOR_VAILD;
                    o_ready <= 1;
                    o_physical_address <= physical_address;
                end else begin
                    state <= STATE_WAIT_FOR_PAGING_UNIT_READY;
                    o_ready <= 0;
                    o_physical_address <= o_physical_address;
                end
            end
            STATE_OUTPUT_LINEAR_ADDRESS: begin
                state <= STATE_WAIT_FOR_VAILD;
                o_ready <= 1;
                o_physical_address <= linear_address;
            end
            default: begin
                state <= STATE_WAIT_FOR_VAILD;
            end
        endcase
    end
end

endmodule
