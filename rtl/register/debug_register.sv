/*
project: w80386dx
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/w80386dx
module: debug_register
create at: 2022-01-31 01:09:17
description: define the debug register
*/

/* ref:
Intel386(TM) DX MICROPROCESSOR 32-BIT CHMOS MICROPROCESSOR WITH INTEGRATED MEMORY MANAGEMENT
*/

module debug_register (
    // ports
    input  logic         write_enable,
    input  logic [ 2: 0] write_index,
    input  logic [31: 0] write_data,
    output logic [31: 0] DR [0:7],
    input  logic         clock, reset
);

always_ff @( posedge clock or posedge reset ) begin
    if (reset) begin
        DR[0] <= 32'b0;
        DR[1] <= 32'b0;
        DR[2] <= 32'b0;
        DR[3] <= 32'b0;
        DR[4] <= 32'b0;
        DR[5] <= 32'b0;
        DR[6] <= 32'b0;
        DR[7] <= 32'b0;
    end else begin
        if (write_enable) begin
            DR[write_index] <= write_data;
        end
    end
end

endmodule
