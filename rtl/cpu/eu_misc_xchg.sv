module eu_misc_xchg (
    input  logic [31:0] a,
    input  logic [31:0] b,
    output logic [31:0] y
);
    always_comb begin
        y = b;
    end
endmodule
