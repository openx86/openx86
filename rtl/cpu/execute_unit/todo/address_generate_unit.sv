/*
project: w80386dx
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/w80386dx
module: address_generate_unit
create at: 2021-10-23 15:09:38
description: generate the physical memory address
*/

/* ref:
Intel386(TM) DX MICROPROCESSOR 32-BIT CHMOS MICROPROCESSOR WITH INTEGRATED MEMORY MANAGEMENT
2.3.6 Control Registers
*/

module address_generate_unit (
    // ports
    input  logic [ 1:0] segment,
    input  logic [24:0] base,
    input  logic [24:0] index,
    input  logic [24:0] scale,
    input  logic [ 3:0] imm,
    output logic [ 3:0] physical_address
);

logic [28:0] segment_physical_address;
assign segment_physical_address = {segment, 4'h0, 23'h0} >> (27 - 4);

// TODO: index_physical_address is incorrect
logic [28:0] index_physical_address;
assign index_physical_address = index << scale;

assign physical_address = segment_physical_address + base + imm;

endmodule
