module eu_misc_arpl (
    input  logic [31:0] dst,
    input  logic [31:0] src,
    output logic [31:0] y,
    output logic        zf
);
    always_comb begin
        if (dst[1:0] < src[1:0]) begin
            y  = { dst[31:2], src[1:0] };
            zf = 1'b1;
        end else begin
            y  = dst;
            zf = 1'b0;
        end
    end
endmodule
