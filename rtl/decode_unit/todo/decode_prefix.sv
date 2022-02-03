// project: w80386dx
// author: Chang Wei<changwei1006@gmail.com>
// repo: https://github.com/openx86/w80386dx
// module: decode_prefix
// create at: 2021-12-25 15:59:58
// description: decode instruction prefix

// `include "D:\GitHub\openx86\w80386dx\rtl\define.h"
// `include "../define.h"
module decode_prefix #(
    // parameters
) (
    // ports
    input  logic [7:0] instruction,
    output logic       address_size,
    output logic       bus_lock,
    output logic       operand_size,
    output logic       segment_override_CS,
    output logic       segment_override_DS,
    output logic       segment_override_ES,
    output logic       segment_override_FS,
    output logic       segment_override_GS,
    output logic       segment_override_SS
);

assign address_size        = (instruction == 8'b0110_0111) ? 1'b1 : 1'b0;
assign bus_lock            = (instruction == 8'b1111_0000) ? 1'b1 : 1'b0;
assign operand_size        = (instruction == 8'b0110_0110) ? 1'b1 : 1'b0;

assign segment_override_CS = (instruction == 8'b0010_1110) ? 1'b1 : 1'b0;
assign segment_override_DS = (instruction == 8'b0011_1110) ? 1'b1 : 1'b0;
assign segment_override_ES = (instruction == 8'b0010_0110) ? 1'b1 : 1'b0;
assign segment_override_FS = (instruction == 8'b0110_0100) ? 1'b1 : 1'b0;
assign segment_override_GS = (instruction == 8'b0110_0101) ? 1'b1 : 1'b0;
assign segment_override_SS = (instruction == 8'b0011_0110) ? 1'b1 : 1'b0;

endmodule
