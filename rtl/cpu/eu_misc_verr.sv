module eu_misc_verr (
    input  logic [31:0] selector,
    output logic        zf
);
    always_comb begin
        zf = (selector[15:0] != 16'd0);
    end
endmodule
