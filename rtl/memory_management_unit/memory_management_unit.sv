/*
project: w80386dx
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/w80386dx
module: memory_management_unit
create at: 2022-02-04 23:34:40
description: memory_management_unit
*/

module memory_management_unit (
    input  logic [ 2:0] segment_index,
    input  logic [31:0] offset,
    output logic [31:0] physical_address
);

wire [31:0] linear_address = 32'b0;
// TODO: refer to 4.5.2 Paging Organization
assign physical_address = linear_address;

endmodule
