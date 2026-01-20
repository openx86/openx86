module single_port_ram #(
    parameter int DATA_WIDTH = 8,    // 数据位宽
    parameter int ADDR_WIDTH = 10,   // 地址位宽（深度 = 2^ADDR_WIDTH）
    parameter int DEPTH      = 1 << ADDR_WIDTH  // 显式深度参数（可选）
) (
    // 读写端口
    input  logic                    we,              // 写使能
    input  logic [ADDR_WIDTH-1:0]   addr,            // 地址
    input  logic [DATA_WIDTH-1:0]   wdata,           // 写数据
    output logic [DATA_WIDTH-1:0]   rdata,            // 读数据
    
    input  logic                    clock,
    input  logic                    reset
);

    // 存储器数组
    logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    // 写操作（同步写）
    always_ff @(posedge clock) begin
        if (reset) begin
            // 复位时可以选择清零，也可以保持（取决于应用需求）
            // 这里不自动清零，由用户控制
        end else begin
            if (we) begin
                mem[addr] <= wdata;
            end
        end
    end

    // 读操作（同步读，在时钟上升沿后输出）
    always_ff @(posedge clock) begin
        if (reset) begin
            rdata <= '0;
        end else begin
            rdata <= mem[addr];
        end
    end

endmodule
