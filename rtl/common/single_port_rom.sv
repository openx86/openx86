module single_port_rom #(
    parameter int DATA_WIDTH = 8,    // 数据位宽
    parameter int ADDR_WIDTH = 10,   // 地址位宽（深度 = 2^ADDR_WIDTH）
    parameter int DEPTH      = 1 << ADDR_WIDTH,  // 显式深度参数（可选）
    parameter string INIT_FILE = ""  // 初始化文件路径（可选，支持 $readmemh/$readmemb）
) (
    // 读端口
    input  logic [ADDR_WIDTH-1:0]   addr,            // 地址
    output logic [DATA_WIDTH-1:0]   rdata,           // 读数据
    
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

    // 读操作（同步读，在时钟上升沿后输出）
    always_ff @(posedge clock) begin
        if (reset) begin
            rdata <= '0;
        end else begin
            rdata <= rom[addr];
        end
    end

endmodule
