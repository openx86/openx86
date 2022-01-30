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
    output logic [31: 0] TR0,
    output logic [31: 0] TR1,
    output logic [31: 0] TR2,
    output logic [31: 0] TR3,
    output logic [31: 0] TR4,
    output logic [31: 0] TR5,
    output logic [31: 0] TR6,
    output logic [31: 0] TR7,
    input  logic         clock, reset
);

reg [31:0] test_reg [7:0];

always_ff @( posedge clock or posedge reset ) begin
    if (reset) begin
        test_reg[0] <= 32'b0;
        test_reg[1] <= 32'b0;
        test_reg[2] <= 32'b0;
        test_reg[3] <= 32'b0;
        test_reg[4] <= 32'b0;
        test_reg[5] <= 32'b0;
        test_reg[6] <= 32'b0;
        test_reg[7] <= 32'b0;
    end else begin
        if (write_enable) begin
            test_reg[write_index] <= write_data;
        end
    end
end

assign TR0 = test_reg[0];
assign TR1 = test_reg[1];
assign TR2 = test_reg[2];
assign TR3 = test_reg[3];
assign TR4 = test_reg[4];
assign TR5 = test_reg[5];
assign TR6 = test_reg[6];
assign TR7 = test_reg[7];

endmodule
