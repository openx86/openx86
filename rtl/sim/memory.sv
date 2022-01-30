`timescale 1ns/1ns
module memory #(
    // parameters
) (
    // ports
    input  logic [31:0] read_address,
    output logic [31:0] read_data,
    input  logic        clock,
    input  logic        reset
);

reg [31:0] mem[0:31];  // 声明有32个32位的存储单元
reg [31:0] n;

assign read_data = mem[read_address];

initial begin
	$readmemb("D:\\GitHub\\openx86\\w80386dx\\rtl\\sim\\rom", mem);
    for(n=0;n<=31;n=n+1)
        $display("mem[0x%h] = %h", n, mem[n]);
end

endmodule
