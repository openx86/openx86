/*
project: w80386dx
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/w80386dx
module: register_segment
create at: 2021-10-23 13:43:22
description: define the segment register
*/

/* ref:
Intel386(TM) DX MICROPROCESSOR 32-BIT CHMOS MICROPROCESSOR WITH INTEGRATED MEMORY MANAGEMENT
2.3.4 Segment Registers
Six 16-bit segment registers hold segment selector
values identifying the currently addressable memory
segments. Segment registers are shown in Figure 2-
4. In Protected Mode, each segment may range in
size from one byte up to the entire linear and physi-
cal space of the machine, 4 Gbytes (232 bytes). If a
maximum sized segment is used (limit e
FFFFFFFFH) it should be Dword aligned (i.e., the
least two significant bits of the segment base should
be zero). This will avoid a segment limit violation (exception
13) caused by the wrap around. In Real Address
Mode, the maximum segment size is fixed at
64 Kbytes (216 bytes).
The six segments addressable at any given moment
are defined by the segment registers CS, SS, DS,
ES, FS and GS. The selector in CS indicates the
current code segment; the selector in SS indicates
the current stack segment; the selectors in DS, ES,
FS and GS indicate the current data segments.
*/

module register_segment #(
    // parameters
) (
    // ports
    input  logic        write_enable,
    input  logic [ 4:0] write_index,
    input  logic [15:0] write_data,
    output logic [15:0] CS,
    output logic [15:0] SS,
    output logic [15:0] DS,
    output logic [15:0] ES,
    output logic [15:0] FS,
    output logic [15:0] GS,
    input  logic        clock, reset
);

reg [15:0] segment_register [6];

always_ff @( posedge clock or negedge reset ) begin : ff_segment_register
    if (reset) begin
        segment_register[0] <= 16'b0;
        segment_register[1] <= 16'b0;
        segment_register[2] <= 16'b0;
        segment_register[3] <= 16'b0;
        segment_register[4] <= 16'b0;
        segment_register[5] <= 16'b0;
    end else begin
        if (write_enable) begin
            segment_register[write_index] <= write_data;
        end
    end
end

assign CS = segment_register[0][15:0];
assign SS = segment_register[1][15:0];
assign DS = segment_register[2][15:0];
assign ES = segment_register[3][15:0];
assign FS = segment_register[4][15:0];
assign GS = segment_register[5][15:0];

endmodule
