module eu_misc_cbw (
    input  logic [31:0] a,
    output logic [31:0] y
);
    always_comb begin
        y = { { 16{ a[15] } }, a[15:0] };
    end

endmodule
