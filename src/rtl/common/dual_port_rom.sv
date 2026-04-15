// ============================================================================
// dual_port_rom
// ----------------------------------------------------------------------------
// 双端口只读存储器（2x read port），用于仿真/综合中的 ROM 建模。
//
// - **初始化**：支持通过 `INIT_FILE` 使用 `$readmemh` 预加载内容；否则清零。
// - **时序**：两路读口均为 **同步读**（posedge clock 更新输出）。
// - **综合注意**：不同综合器对 `$readmemh` 支持差异较大；上板前建议使用
//   Quartus/目标器件推荐的 ROM/IP 或在工程脚本中指定 memory init flow。
//
// Reset 行为：复位时把读数据输出清零（不影响 ROM 内容）。
// ============================================================================

module dual_port_rom #(
    parameter int DATA_WIDTH = 8,    // 数据位宽
    parameter int ADDR_WIDTH = 10,   // 地址位宽（深度 = 2^ADDR_WIDTH）
    parameter int DEPTH      = 1 << ADDR_WIDTH,  // 显式深度参数（可选）
    parameter string INIT_FILE = ""  // 初始化文件路径（可选，支持 $readmemh/$readmemb）
) (
    // 读端口A
    input  logic [ADDR_WIDTH-1:0]   addra,          // 端口A地址
    output logic [DATA_WIDTH-1:0]   rdataa,         // 端口A读数据
    
    // 读端口B
    input  logic [ADDR_WIDTH-1:0]   addrb,          // 端口B地址
    output logic [DATA_WIDTH-1:0]   rdatab,         // 端口B读数据
    
    input  logic                    clock,
    input  logic                    reset
);

    // 存储器数组
    logic [DATA_WIDTH-1:0] rom [0:DEPTH-1];

    // ROM 初始化
    initial begin
        // 如果指定了初始化文件，则从文件加载
        if (INIT_FILE != "") begin
            $readmemh(INIT_FILE, rom);
        end else begin
            // 否则初始化为 0
            for (int i = 0; i < DEPTH; i++) begin
                rom[i] = '0;
            end
        end
    end

    // 端口A读操作（同步读）
    always_ff @(posedge clock) begin
        if (reset) begin
            rdataa <= '0;
        end else begin
            rdataa <= rom[addra];
        end
    end

    // 端口B读操作（同步读）
    always_ff @(posedge clock) begin
        if (reset) begin
            rdatab <= '0;
        end else begin
            rdatab <= rom[addrb];
        end
    end

endmodule
