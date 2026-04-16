module eu_misc_cdq (
    input  logic [31:0] a,
    output logic [31:0] y
);
    always_comb begin
        y = a[31] ? 32'hFFFF_FFFF : 32'h0000_0000;
    end

endmodule
