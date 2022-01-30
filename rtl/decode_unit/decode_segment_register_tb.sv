// project: w80386dx
// author: Chang Wei<changwei1006@gmail.com>
// repo: https://github.com/openx86/w80386dx
// module: decode_general_general_register_tb
// create at: 2021-10-22 02:29:28
// description: test decode_general_general_register module

`timescale 1ns/1ns
module decode_segment_register_tb #(
    // parameters
) (
    // ports
);

logic [2:0] instruction_sreg;
logic       ES;
logic       CS;
logic       SS;
logic       DS;
logic       FS;
logic       GS;

decode_segment_register decode_segment_register_inst (
    .instruction_sreg ( instruction_sreg ),

    .ES ( ES ),
    .CS ( CS ),
    .SS ( SS ),
    .DS ( DS ),
    .FS ( FS ),
    .GS ( GS )
);

reg [3:0] i;

initial begin
    instruction_sreg = 0;

    $monitor("%t: instruction_reg=%h", $time, instruction_sreg);
    $monitor("%t:  ES=%h,  CS=%h,  SS=%h,  DS=%h,  FS=%h,  GS=%h", $time, ES, CS, SS, DS, FS, GS);

    #1;
    for(i=0;i<8;i=i+1) begin
        instruction_sreg = i;
        #1;
    end

    #16;
    $stop();
end

endmodule
