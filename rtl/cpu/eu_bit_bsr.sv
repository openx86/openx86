module eu_bit_bsr (
    input  logic [31:0] a,
    output logic [31:0] y,
    output logic        zf
);
    always_comb begin
        y = 32'd0;
        zf = 1'b1;
        for (int i = 0; i < 32; i++) begin
            if (a[31-i] && zf) begin
                y = 31 - i;
                zf = 1'b0;
            end
        end
    end
endmodule
