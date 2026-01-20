module simple_dual_port_ram #(
    parameter int DATA_WIDTH = 8,    // 数据位宽
    parameter int ADDR_WIDTH = 10,   // 地址位宽（深度 = 2^ADDR_WIDTH）
    parameter int DEPTH      = 1 << ADDR_WIDTH  // 显式深度参数（可选）
) (
    // 写端口
    input  logic                    we,
    input  logic [ADDR_WIDTH-1:0]   waddr,
    input  logic [DATA_WIDTH-1:0]   wdata,

    // 读端口
    input  logic                    re,
    input  logic [ADDR_WIDTH-1:0]   raddr,
    output logic [DATA_WIDTH-1:0]   rdata,

    // 时钟与复位（放在末尾）
    input  logic                    clock,
    input  logic                    reset
);

    // 存储器数组
    logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    // 写操作（同步写）
    always_ff @(posedge clock) begin
        if (reset) begin
            // 可选：清零或保持
        end else begin
            if (we) begin
                mem[waddr] <= wdata;
            end
        end
    end

    // 读操作（同步读，在时钟上升沿后输出）
    always_ff @(posedge clock) begin
        if (reset) begin
            rdata <= '0;
        end else begin
            if (re) begin
                rdata <= mem[raddr];
            end
        end
    end

endmodule
