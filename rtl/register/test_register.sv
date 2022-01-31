/*
project: w80386dx
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/w80386dx
module: test_register
create at: 2022-01-31 01:07:15
description: define the test register
*/

/* ref:
Intel386(TM) DX MICROPROCESSOR 32-BIT CHMOS MICROPROCESSOR WITH INTEGRATED MEMORY MANAGEMENT
*/

module debug_register #(
    // parameters
) (
    // ports
    input  logic         write_enable,
    input  logic [ 2: 0] write_index,
    input  logic [31: 0] write_data,
    output logic [31: 0] TR [0:7],
    input  logic         clock, reset
);

always_ff @( posedge clock or posedge reset ) begin
    if (reset) begin
        TR[0] <= 32'b0;
        TR[1] <= 32'b0;
        TR[2] <= 32'b0;
        TR[3] <= 32'b0;
        TR[4] <= 32'b0;
        TR[5] <= 32'b0;
        TR[6] <= 32'b0;
        TR[7] <= 32'b0;
    end else begin
        if (write_enable) begin
            TR[write_index] <= write_data;
        end
    end
end

endmodule
