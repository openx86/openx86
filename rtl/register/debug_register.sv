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
    output logic [31: 0] DR0,
    output logic [31: 0] DR1,
    output logic [31: 0] DR2,
    output logic [31: 0] DR3,
    output logic [31: 0] DR4,
    output logic [31: 0] DR5,
    output logic [31: 0] DR6,
    output logic [31: 0] DR7,
    input  logic         clock, reset
);

reg [31:0] debug_reg [7:0];

always_ff @( posedge clock or posedge reset ) begin
    if (reset) begin
        debug_reg[0] <= 32'b0;
        debug_reg[1] <= 32'b0;
        debug_reg[2] <= 32'b0;
        debug_reg[3] <= 32'b0;
        debug_reg[4] <= 32'b0;
        debug_reg[5] <= 32'b0;
        debug_reg[6] <= 32'b0;
        debug_reg[7] <= 32'b0;
    end else begin
        if (write_enable) begin
            debug_reg[write_index] <= write_data;
        end
    end
end

assign DR0 = debug_reg[0];
assign DR1 = debug_reg[1];
assign DR2 = debug_reg[2];
assign DR3 = debug_reg[3];
assign DR4 = debug_reg[4];
assign DR5 = debug_reg[5];
assign DR6 = debug_reg[6];
assign DR7 = debug_reg[7];

endmodule
