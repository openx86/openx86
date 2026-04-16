module eu_misc_xadd (
    input  logic [31:0] a,
    input  logic [31:0] b,
    output logic [31:0] y
);
    always_comb begin
        y = a + b;
    end
endmodule
