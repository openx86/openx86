/*
project: w80386dx
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/w80386dx
module: segment_register
create at: 2022-01-31 03:54:23
description: define the segment register
*/

/* ref:
Intel386(TM) DX MICROPROCESSOR 32-BIT CHMOS MICROPROCESSOR WITH INTEGRATED MEMORY MANAGEMENT

*/

module segment_register (
    input  logic        write_enable,
    input  logic [ 2:0] write_index,
    input  logic [15:0] write_selector,
    input  logic [63:0] write_descriptor,
    output logic [15:0] segment_selector [0:5],
    output logic [63:0] descriptor_cache [0:5],
    input  logic        clock, reset
);

always_ff @( posedge clock or posedge reset ) begin
    if (reset) begin
        segment_selector[0] <= 16'b0;
        segment_selector[1] <= 16'b0;
        segment_selector[2] <= 16'b0;
        segment_selector[3] <= 16'b0;
        segment_selector[4] <= 16'b0;
        segment_selector[5] <= 16'b0;
    end else begin
        if (write_enable) begin
            segment_selector[write_index] <= write_selector;
        end
    end
end

always_ff @( posedge clock or posedge reset ) begin
    if (reset) begin
        descriptor_cache[0] <= 64'b0;
        descriptor_cache[1] <= 64'b0;
        descriptor_cache[2] <= 64'b0;
        descriptor_cache[3] <= 64'b0;
        descriptor_cache[4] <= 64'b0;
        descriptor_cache[5] <= 64'b0;
    end else begin
        if (write_enable) begin
            descriptor_cache[write_index] <= write_descriptor;
        end
    end
end

endmodule
