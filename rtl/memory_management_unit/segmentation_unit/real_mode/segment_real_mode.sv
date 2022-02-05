/*
project: w80386dx
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/w80386dx
module: segment_real_mode
create at: 2022-01-26 19:55:20
description: segment_real_mode
*/

module segment_real_mode #(
    // parameters
) (
    // ports
    input  logic [31: 0] segment_value,
    output logic [31: 0] base_address,
);

assign base_address = segment_value << 4;

endmodule
