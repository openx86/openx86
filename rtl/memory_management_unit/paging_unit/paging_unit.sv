/*
project: w80386dx
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/w80386dx
module: paging_unit
create at: 2022-01-31 02:35:30
description: paging_unit

4.5.2 Paging Organization
4.5.2.1 PAGE MECHANISM
The Intel386 DX uses two levels of tables to translate
the linear address (from the segmentation unit)
into a physical address. There are three components
to the paging mechanism of the Intel386 DX:
the page directory, the page tables, and the page
itself (page frame). All memory-resident elements of
the Intel386 DX paging mechanism are the same
size, namely, 4K bytes. A uniform size for all of the
elements simplifies memory allocation and reallocation
schemes, since there is no problem with memory
fragmentation. Figure 4-19 shows how the paging
mechanism works.
4.5.2.2 PAGE DESCRIPTOR BASE REGISTER
CR2 is the Page Fault Linear Address register. It
holds the 32-bit linear address which caused the last
page fault detected.
CR3 is the Page Directory Physical Base Address
Register. It contains the physical starting address of
the Page Directory. The lower 12 bits of CR3 are
always zero to ensure that the Page Directory is always
page aligned. Loading it via a MOV CR3, reg
instruction causes the Page Table Entry cache to be
flushed, as will a task switch through a TSS which
changes the value of CR0. (See 4.5.4 Translation
Lookaside Buffer).
*/

module paging_unit (
    // handshake
    input  logic         i_vaild,
    output logic         o_ready,
    // signal
    input  logic [31: 0] i_linear_address,
    input  logic [31: 0] i_page_directory_base,
    output logic [31: 0] o_page_phycial_address,
    // signal from bus_interface_unit
    output logic        o_bus_vaild,
    input  logic        i_bus_ready,
    output logic        o_bus_write_enable,
    output logic [31:0] o_bus_address,
    input  logic [31:0] i_bus_data_read,
    output logic [31:0] o_bus_data_write,
    // common
    input  logic         clock, reset
);

wire  [ 9:0] page_directory_index = i_linear_address[31:22];
wire  [ 9:0] page_table_index     = i_linear_address[21:12];
wire  [11:0] page_frame_offset    = i_linear_address[11: 0];

wire  [31: 0] page_directory_offset = i_page_directory_base + (page_directory_index << 12);
logic [31: 0] page_table_base;
wire  [31: 0] page_table_address_offset = page_table_base + (page_table_index << 12);
logic [31: 0] page_frame_address_offset;
assign o_physical_address = page_frame_address_offset + page_frame_offset;

enum logic [1:0] {
    STATE_WAIT_FOR_PAGE_DIR_ENTRY_READY = 1,
    STATE_WAIT_FOR_PAGE_TBL_ENTRY_VALID = 2,
    STATE_WAIT_FOR_VAILD = 0
} state;

always_ff @(posedge clock or posedge reset) begin
    if (reset) begin
        state <= STATE_WAIT_FOR_VAILD;
        o_ready <= 0;
    end else begin
        unique case (state)
            STATE_WAIT_FOR_VAILD: begin
                o_ready <= 0;
                if (i_vaild) begin
                    state <= STATE_WAIT_FOR_PAGE_DIR_ENTRY_READY;
                    o_bus_vaild <= 1;
                    o_bus_address <= page_directory_offset;
                end else begin
                    state <= STATE_WAIT_FOR_VAILD;
                    o_bus_vaild <= 0;
                end
            end
            STATE_WAIT_FOR_PAGE_DIR_ENTRY_READY: begin
                if (i_bus_ready) begin
                    state <= STATE_WAIT_FOR_PAGE_TBL_ENTRY_VALID;
                    page_table_base <= i_bus_data_read;
                    o_bus_vaild <= 1;
                    o_bus_address <= page_table_address_offset;
                end else begin
                    state <= STATE_WAIT_FOR_PAGE_DIR_ENTRY_READY;
                    o_bus_vaild <= 0;
                    o_bus_address <= o_bus_address;
                end
            end
            STATE_WAIT_FOR_PAGE_TBL_ENTRY_VALID: begin
                if (i_bus_ready) begin
                    state <= STATE_WAIT_FOR_VAILD;
                    page_frame_address_offset <= i_bus_data_read;
                    o_bus_vaild <= 0;
                    o_ready <= 1;
                end else begin
                    state <= STATE_WAIT_FOR_PAGE_TBL_ENTRY_VALID;
                    o_bus_vaild <= 1;
                    o_ready <= 0;
                end
            end
            default: begin
                state <= STATE_WAIT_FOR_VAILD;
            end
        endcase
    end
end

endmodule
