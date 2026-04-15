`timescale 1ns/1ns
module edge_detect_tb #(
    // parameters
    clock_period = 2
) (
    // ports
);

logic clock, reset;
logic signal;

always #(clock_period/2) clock = ~clock;

initial begin
    clock <= 0;
    reset <= 1;
    signal <= 0;

    #3;
    reset <= 0;

    #1;
    signal <= 0;

    #2;
    signal <= 1;

    #1;
    signal <= 1;

    #3;
    signal <= 0;

    #4;

    $stop();
end

logic pos_edge, neg_edge;
edge_detect edge_detect_inst (
    .signal ( signal ),
    .pos_edge ( pos_edge ),
    .neg_edge ( neg_edge ),
    .clock ( clock ),
    .reset ( reset )
);

endmodule