// ============================================================================
// true_dual_port_ram
// ----------------------------------------------------------------------------
// 真双口 RAM（2x read/write port），常用于“CPU 写入 + VGA/外设并行读取”等场景。
//
// - 端口 A/B 均支持同步写、同步读（posedge clock）。
// - 复位：清零读数据输出（不清 RAM 内容）。
//
// 冲突说明：
// - 双口同周期访问同地址（尤其是同时写）时的最终内容与读出的数据，
//   依赖综合器/器件 RAM primitive 的定义；若系统依赖确定行为，建议采用
//   厂商 IP 并显式配置 read-during-write 模式。
// ============================================================================

module true_dual_port_ram #(
    parameter int DATA_WIDTH = 8,    // 数据位宽
    parameter int ADDR_WIDTH = 10,   // 地址位宽（深度 = 2^ADDR_WIDTH）
    parameter int DEPTH      = 1 << ADDR_WIDTH  // 显式深度参数（可选）
) (    
    // 端口A（通常用于CPU访问）
    input  logic                    wea,             // 端口A写使能
    input  logic [ADDR_WIDTH-1:0]   addra,           // 端口A地址
    input  logic [DATA_WIDTH-1:0]   wdataa,          // 端口A写数据
    output logic [DATA_WIDTH-1:0]   rdataa,          // 端口A读数据
    
    // 端口B（通常用于VGA读取）
    input  logic                    web,             // 端口B写使能（可选，如果只需要读则固定为0）
    input  logic [ADDR_WIDTH-1:0]   addrb,           // 端口B地址
    input  logic [DATA_WIDTH-1:0]   wdatab,          // 端口B写数据
    output logic [DATA_WIDTH-1:0]   rdatab,           // 端口B读数据
    
    input  logic                    clock,
    input  logic                    reset
);

    // 存储器数组
    logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    // 端口A写操作（同步写）
    always_ff @(posedge clock) begin
        if (reset) begin
            // 复位时可以选择清零，也可以保持（取决于应用需求）
        end else begin
            if (wea) begin
                mem[addra] <= wdataa;
            end
        end
    end

    // 端口A读操作（同步读）
    always_ff @(posedge clock) begin
        if (reset) begin
            rdataa <= '0;
        end else begin
            rdataa <= mem[addra];
        end
    end

    // 端口B写操作（同步写）
    always_ff @(posedge clock) begin
        if (reset) begin
            // 复位时可以选择清零，也可以保持
        end else begin
            if (web) begin
                mem[addrb] <= wdatab;
            end
        end
    end

    // 端口B读操作（同步读）
    always_ff @(posedge clock) begin
        if (reset) begin
            rdatab <= '0;
        end else begin
            rdatab <= mem[addrb];
        end
    end

endmodule
