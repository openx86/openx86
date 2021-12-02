`timescale 1ns/1ns
module soc_top_tb #(
    // parameters
    clock_period = 2
) (
    // ports
);

logic clock, reset;

always #(clock_period/2) clock = ~clock;

initial begin
    clock <= 0;
    reset <= 1;

    #3;
    reset <= 0;

    #100;

    $stop();
end

soc_top soc_top_inst (
    .clock ( clock ),
    .reset ( reset )
);

endmodule
