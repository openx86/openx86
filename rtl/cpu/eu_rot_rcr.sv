module eu_rot_rcr (
    input  logic [31:0] a,
    input  logic [31:0] count,
    input  logic        cf_in,
    output logic [31:0] y,
    output logic        cf_out
);
    logic [31:0] tmp;
    logic [4:0]  sh;
    logic        cf;
    logic        next_cf;

    always_comb begin
        tmp = a;
        sh = count[4:0];
        cf = cf_in;

        for (int i = 0; i < 32; i++) begin
            if (i < sh) begin
                next_cf = tmp[0];
                tmp = { cf, tmp[31:1] };
                cf = next_cf;
            end
        end

        y = tmp;
        cf_out = cf;
    end
endmodule
