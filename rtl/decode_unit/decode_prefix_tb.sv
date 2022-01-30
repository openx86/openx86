// project: w80386dx
// author: Chang Wei<changwei1006@gmail.com>
// repo: https://github.com/openx86/w80386dx
// module: decode_prefix_tb
// create at: 2021-12-25 21:53:25
// description: test decode_prefix module

`timescale 1ns/1ns
module decode_prefix_tb #(
    // parameters
) (
    // ports
);

logic [7:0] instruction;
logic       address_size;
logic       bus_lock;
logic       operand_size;
logic       segment_override_CS;
logic       segment_override_DS;
logic       segment_override_ES;
logic       segment_override_FS;
logic       segment_override_GS;
logic       segment_override_SS;

// logic        clock, reset;
// always #1 clock = ~clock;

decode_prefix decode_prefix_inst (
    .instruction ( instruction ),
    .address_size ( address_size ),
    .bus_lock ( bus_lock ),
    .operand_size ( operand_size ),
    .segment_override_CS ( segment_override_CS ),
    .segment_override_DS ( segment_override_DS ),
    .segment_override_ES ( segment_override_ES ),
    .segment_override_FS ( segment_override_FS ),
    .segment_override_GS ( segment_override_GS ),
    .segment_override_SS ( segment_override_SS )
);

initial begin
    instruction = 8'b0;

    $monitor("%t: address_size=%h", $time, address_size);
    $monitor("%t: bus_lock=%h", $time, bus_lock);
    $monitor("%t: operand_size=%h", $time, operand_size);
    $monitor("%t: segment_override_CS=%h", $time, segment_override_CS);
    $monitor("%t: segment_override_DS=%h", $time, segment_override_DS);
    $monitor("%t: segment_override_ES=%h", $time, segment_override_ES);
    $monitor("%t: segment_override_FS=%h", $time, segment_override_FS);
    $monitor("%t: segment_override_GS=%h", $time, segment_override_GS);
    $monitor("%t: segment_override_SS=%h", $time, segment_override_SS);

    #1;
    instruction = 8'b0110_0111;
    #1;
    instruction = 8'b1111_0000;
    #1;
    instruction = 8'b0110_0110;
    #1;
    instruction = 8'b0010_1110;
    #1;
    instruction = 8'b0011_1110;
    #1;
    instruction = 8'b0010_0110;
    #1;
    instruction = 8'b0110_0100;
    #1;
    instruction = 8'b0110_0101;
    #1;
    instruction = 8'b0011_0110;
    #1;
    instruction = 8'b0;

    #16;
    $stop();
end

endmodule
