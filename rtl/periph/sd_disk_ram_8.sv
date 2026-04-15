// ============================================================================
// 共享 8 位盘映像 RAM — IDE 与 SD 模型双读口 + 单写口
// 阵列内容不在本模块初始化；仿真由 testbench 或上层绑定逻辑装载。
// ============================================================================

module disk_ram_8 #(
    parameter int BYTE_DEPTH = 524288
) (
    input  logic        i_clock,
    input  logic        i_reset,
    input  logic        i_we,
    input  logic [31:0] i_waddr,
    input  logic [7:0]  i_wdata,
    input  logic [31:0] i_raddr_a,
    input  logic [31:0] i_raddr_b,
    output logic [7:0]  o_rdata_a,
    output logic [7:0]  o_rdata_b
);

    logic [7:0] mem [0:BYTE_DEPTH-1];

    always_ff @(posedge i_clock) begin
        if (i_we && i_waddr < BYTE_DEPTH)
            mem[i_waddr[31:0]] <= i_wdata;
    end

    always_comb begin
        if (i_raddr_a < BYTE_DEPTH)
            o_rdata_a = mem[i_raddr_a[31:0]];
        else
            o_rdata_a = 8'h00;
    end

    always_comb begin
        if (i_raddr_b < BYTE_DEPTH)
            o_rdata_b = mem[i_raddr_b[31:0]];
        else
            o_rdata_b = 8'h00;
    end

endmodule
