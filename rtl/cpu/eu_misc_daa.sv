module eu_misc_daa (
    input  logic [31:0] a,
    input  logic        af_in,
    input  logic        cf_in,
    output logic [31:0] y,
    output logic        af_out,
    output logic        cf_out
);
    logic [7:0] al;

    always_comb begin
        al = a[7:0];
        af_out = af_in;
        cf_out = cf_in;

        if (((al & 8'h0F) > 8'h09) || af_in) begin
            al = al + 8'h06;
            af_out = 1'b1;
        end

        if ((al > 8'h9F) || cf_in) begin
            al = al + 8'h60;
            cf_out = 1'b1;
        end

        y = { a[31:8], al };
    end

endmodule
