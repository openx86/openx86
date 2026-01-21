// ============================================================================
// SD Card Controller Module
// 通过SDIO接口控制SD卡，模拟硬盘以支持INT 13h中断请求
// ============================================================================

module sdcard_controller (
    // CPU I/O 端口访问（用于INT 13h兼容接口）
    input  logic        io_en_w,
    input  logic        io_en_r,
    input  logic [15:0] io_addr,
    input  logic [7:0]  io_data_w,
    output logic [7:0]  io_data_r,
    
    // CPU 直接访问接口（可选，用于DMA或直接内存访问）
    input  logic        mem_en_w,
    input  logic        mem_en_r,
    input  logic [31:0] mem_addr,      // LBA扇区地址
    input  logic [7:0]  mem_data_w,
    output logic [7:0]  mem_data_r,
    output logic        mem_ready,
    
    // SDIO 物理接口
    output logic        sd_clk,         // SD卡时钟
    output logic        sd_cmd_out,     // SD卡命令输出
    input  logic        sd_cmd_in,     // SD卡命令输入（双向）
    output logic        sd_cmd_oe,      // SD卡命令输出使能
    output logic [3:0]  sd_dat_out,     // SD卡数据输出
    input  logic [3:0]  sd_dat_in,      // SD卡数据输入（双向）
    output logic        sd_dat_oe,      // SD卡数据输出使能
    
    // 状态和中断
    output logic        card_detected,  // 卡检测信号
    output logic        card_ready,     // 卡就绪信号
    output logic        interrupt,      // 中断请求
    
    // 公共信号
    input  logic        clock,
    input  logic        reset
);

// ============================================================================
// 参数定义
// ============================================================================

// I/O 端口地址定义（类似IDE控制器，但简化）
localparam logic [15:0] PORT_DATA_REG      = 16'h01F0;  // 数据寄存器
localparam logic [15:0] PORT_ERROR_REG    = 16'h01F1;  // 错误寄存器
localparam logic [15:0] PORT_SECTOR_COUNT = 16'h01F2;  // 扇区计数
localparam logic [15:0] PORT_LBA_LOW      = 16'h01F3;  // LBA低字节
localparam logic [15:0] PORT_LBA_MID     = 16'h01F4;  // LBA中字节
localparam logic [15:0] PORT_LBA_HIGH    = 16'h01F5;  // LBA高字节
localparam logic [15:0] PORT_DEVICE_HEAD  = 16'h01F6;  // 设备/磁头寄存器
localparam logic [15:0] PORT_STATUS      = 16'h01F7;  // 状态寄存器
localparam logic [15:0] PORT_COMMAND     = 16'h01F7;  // 命令寄存器（与状态寄存器同一地址）
localparam logic [15:0] PORT_ALT_STATUS  = 16'h03F6;  // 备用状态寄存器

// SD卡命令定义
localparam logic [5:0] CMD_GO_IDLE_STATE    = 6'd0;   // CMD0: 复位
localparam logic [5:0] CMD_SEND_IF_COND    = 6'd8;   // CMD8: 发送接口条件
localparam logic [5:0] CMD_APP_CMD          = 6'd55;  // CMD55: 应用命令前缀
localparam logic [5:0] CMD_SD_SEND_OP_COND  = 6'd41;  // ACMD41: 发送操作条件
localparam logic [5:0] CMD_ALL_SEND_CID    = 6'd2;   // CMD2: 获取CID
localparam logic [5:0] CMD_SEND_RELATIVE_ADDR = 6'd3; // CMD3: 获取RCA
localparam logic [5:0] CMD_SELECT_CARD     = 6'd7;   // CMD7: 选择卡
localparam logic [5:0] CMD_SET_BLOCKLEN   = 6'd16;  // CMD16: 设置块长度
localparam logic [5:0] CMD_READ_SINGLE_BLOCK = 6'd17; // CMD17: 读单个块
localparam logic [5:0] CMD_WRITE_BLOCK    = 6'd24;  // CMD24: 写单个块

// 状态机状态定义
typedef enum logic [4:0] {
    STATE_IDLE,
    STATE_INIT_RESET,
    STATE_INIT_CMD8,
    STATE_INIT_ACMD41,
    STATE_INIT_CMD2,
    STATE_INIT_CMD3,
    STATE_INIT_CMD7,
    STATE_INIT_CMD16,
    STATE_READY,
    STATE_READ_SECTOR,
    STATE_WRITE_SECTOR,
    STATE_WAIT_RESPONSE,
    STATE_WAIT_DATA_TOKEN,
    STATE_TRANSFER_DATA,
    STATE_WAIT_WRITE_COMPLETE
} state_t;

// ============================================================================
// 内部信号定义
// ============================================================================

state_t current_state;
state_t next_state;

// SDIO接口信号
logic        sd_cmd_reg;
logic        sd_cmd_oe_reg;
logic [3:0]  sd_dat_reg;
logic        sd_dat_oe_reg;
logic        sd_clk_en;
logic [15:0] clk_divider;
logic [15:0] clk_counter;

// 命令发送相关
logic [47:0] cmd_token;
logic [5:0]  cmd_index;
logic [31:0] cmd_argument;
logic        cmd_send_en;
logic        cmd_send_done;
logic [5:0]  cmd_bit_counter;

// 响应接收相关
logic [127:0] response_reg;
logic [6:0]   response_bit_counter;
logic         response_received;
logic         response_type;  // 0=R1/R3, 1=R2

// 数据传输相关
logic [31:0]  lba_address;      // 当前LBA地址
logic [7:0]   sector_count;    // 扇区计数
logic [7:0]   data_buffer [0:511];  // 512字节扇区缓冲区
logic [9:0]   data_byte_counter;
logic         data_transfer_active;
logic         data_crc_enable;
logic [15:0]  data_crc;

// 寄存器
logic [7:0]  status_reg;
logic [7:0]  error_reg;
logic [7:0]  sector_count_reg;
logic [31:0] lba_reg;
logic [7:0]  device_head_reg;
logic [7:0]  command_reg;

// 控制信号
logic        read_enable;
logic        write_enable;
logic        init_start;
logic        init_done;

// ============================================================================
// I/O 端口寄存器访问
// ============================================================================

always_ff @(posedge clock or posedge reset) begin
    if (reset) begin
        status_reg <= 8'h00;
        error_reg <= 8'h00;
        sector_count_reg <= 8'h00;
        lba_reg <= 32'h0;
        device_head_reg <= 8'h00;
        command_reg <= 8'h00;
        read_enable <= 1'b0;
        write_enable <= 1'b0;
    end else begin
        // 状态寄存器自动更新
        status_reg[7] <= card_ready;  // BSY: 忙标志
        status_reg[6] <= 1'b0;        // DRDY: 数据就绪（简化）
        status_reg[5] <= 1'b0;        // DF: 设备故障
        status_reg[4] <= 1'b0;        // DSC: 寻道完成
        status_reg[3] <= 1'b0;        // DRQ: 数据请求
        status_reg[2] <= 1'b0;        // CORR: 已纠正错误
        status_reg[1] <= 1'b0;        // IDX: 索引标记
        status_reg[0] <= error_reg != 8'h00;  // ERR: 错误标志
        
        // I/O写操作
        if (io_en_w) begin
            unique case (io_addr)
                PORT_DATA_REG: begin
                    // 数据寄存器写入（用于写扇区数据）
                    if (data_transfer_active && write_enable) begin
                        data_buffer[data_byte_counter] <= io_data_w;
                    end
                end
                PORT_SECTOR_COUNT: begin
                    sector_count_reg <= io_data_w;
                end
                PORT_LBA_LOW: begin
                    lba_reg[7:0] <= io_data_w;
                end
                PORT_LBA_MID: begin
                    lba_reg[15:8] <= io_data_w;
                end
                PORT_LBA_HIGH: begin
                    lba_reg[23:16] <= io_data_w;
                end
                PORT_DEVICE_HEAD: begin
                    device_head_reg <= io_data_w;
                    lba_reg[31:24] <= io_data_w[3:0];  // LBA高4位
                end
                PORT_COMMAND: begin
                    command_reg <= io_data_w;
                    // 命令执行
                    if (io_data_w == 8'h20) begin  // READ SECTORS
                        read_enable <= 1'b1;
                        lba_address <= lba_reg;
                        sector_count <= sector_count_reg;
                    end else if (io_data_w == 8'h30) begin  // WRITE SECTORS
                        write_enable <= 1'b1;
                        lba_address <= lba_reg;
                        sector_count <= sector_count_reg;
                    end
                end
                default: begin
                end
            endcase
        end
        
        // 命令执行完成后清除标志
        if (current_state == STATE_READY && (read_enable || write_enable)) begin
            read_enable <= 1'b0;
            write_enable <= 1'b0;
        end
    end
end

// I/O读操作
always_comb begin
    io_data_r = 8'hFF;
    
    if (io_en_r) begin
        unique case (io_addr)
            PORT_DATA_REG: begin
                // 数据寄存器读取（用于读扇区数据）
                if (data_transfer_active && read_enable) begin
                    io_data_r = data_buffer[data_byte_counter];
                end else begin
                    io_data_r = 8'h00;
                end
            end
            PORT_ERROR_REG: begin
                io_data_r = error_reg;
            end
            PORT_SECTOR_COUNT: begin
                io_data_r = sector_count_reg;
            end
            PORT_LBA_LOW: begin
                io_data_r = lba_reg[7:0];
            end
            PORT_LBA_MID: begin
                io_data_r = lba_reg[15:8];
            end
            PORT_LBA_HIGH: begin
                io_data_r = lba_reg[23:16];
            end
            PORT_DEVICE_HEAD: begin
                io_data_r = device_head_reg;
            end
            PORT_STATUS, PORT_ALT_STATUS: begin
                io_data_r = status_reg;
            end
            default: begin
                io_data_r = 8'hFF;
            end
        endcase
    end
end

// ============================================================================
// SD卡时钟生成（简化版本，使用分频器）
// ============================================================================

localparam logic [15:0] CLK_DIV_INIT = 16'd1000;  // 初始化时钟：~100kHz (假设系统时钟100MHz)
localparam logic [15:0] CLK_DIV_NORMAL = 16'd4;   // 正常工作时钟：~25MHz

always_ff @(posedge clock or posedge reset) begin
    if (reset) begin
        clk_counter <= 16'h0;
        sd_clk <= 1'b0;
        clk_divider <= CLK_DIV_INIT;
    end else begin
        if (current_state == STATE_READY) begin
            clk_divider <= CLK_DIV_NORMAL;
        end else begin
            clk_divider <= CLK_DIV_INIT;
        end
        
        if (clk_counter >= clk_divider) begin
            clk_counter <= 16'h0;
            sd_clk <= ~sd_clk;
        end else begin
            clk_counter <= clk_counter + 1;
        end
    end
end

// ============================================================================
// SD卡命令发送逻辑（简化版本）
// ============================================================================

// 命令格式：48位 = [起始位01][命令索引6位][参数32位][CRC7][结束位1]
always_comb begin
    cmd_token[47:46] = 2'b01;  // 起始位
    cmd_token[45:40] = cmd_index;
    cmd_token[39:8]  = cmd_argument;
    cmd_token[7:1]   = 7'h00;  // CRC（简化，实际需要计算）
    cmd_token[0]     = 1'b1;   // 结束位
end

always_ff @(posedge sd_clk or posedge reset) begin
    if (reset) begin
        sd_cmd_reg <= 1'b1;
        sd_cmd_oe_reg <= 1'b1;
        cmd_bit_counter <= 6'd0;
        cmd_send_done <= 1'b0;
    end else begin
        if (cmd_send_en && !cmd_send_done) begin
            if (cmd_bit_counter < 48) begin
                sd_cmd_reg <= cmd_token[47 - cmd_bit_counter];
                cmd_bit_counter <= cmd_bit_counter + 1;
            end else begin
                cmd_send_done <= 1'b1;
                sd_cmd_oe_reg <= 1'b0;  // 切换到输入模式等待响应
            end
        end else if (!cmd_send_en) begin
            cmd_bit_counter <= 6'd0;
            cmd_send_done <= 1'b0;
            sd_cmd_oe_reg <= 1'b1;
            sd_cmd_reg <= 1'b1;
        end
    end
end

// ============================================================================
// SD卡响应接收逻辑（简化版本）
// ============================================================================

always_ff @(posedge sd_clk or posedge reset) begin
    if (reset) begin
        response_reg <= 128'h0;
        response_bit_counter <= 7'd0;
        response_received <= 1'b0;
    end else begin
        if (cmd_send_done && !response_received) begin
            if (response_bit_counter < 48) begin  // R1响应是48位
                response_reg[127 - response_bit_counter] <= sd_cmd_in;
                response_bit_counter <= response_bit_counter + 1;
            end else begin
                response_received <= 1'b1;
            end
        end else if (!cmd_send_done) begin
            response_bit_counter <= 7'd0;
            response_received <= 1'b0;
        end
    end
end

// ============================================================================
// 主状态机
// ============================================================================

always_ff @(posedge clock or posedge reset) begin
    if (reset) begin
        current_state <= STATE_IDLE;
        card_ready <= 1'b0;
        card_detected <= 1'b1;  // 假设卡已插入（简化）
        init_done <= 1'b0;
    end else begin
        current_state <= next_state;
        
        // 初始化完成标志
        if (current_state == STATE_READY) begin
            init_done <= 1'b1;
            card_ready <= 1'b1;
        end
    end
end

always_comb begin
    next_state = current_state;
    cmd_send_en = 1'b0;
    cmd_index = 6'd0;
    cmd_argument = 32'h0;
    data_transfer_active = 1'b0;
    mem_ready = 1'b0;
    
    unique case (current_state)
        STATE_IDLE: begin
            if (card_detected && !init_done) begin
                next_state = STATE_INIT_RESET;
            end else if (init_done && read_enable) begin
                next_state = STATE_READ_SECTOR;
            end else if (init_done && write_enable) begin
                next_state = STATE_WRITE_SECTOR;
            end
        end
        
        STATE_INIT_RESET: begin
            // 发送CMD0复位
            if (!cmd_send_en) begin
                cmd_send_en = 1'b1;
                cmd_index = CMD_GO_IDLE_STATE;
                cmd_argument = 32'h0;
            end
            if (cmd_send_done && response_received) begin
                next_state = STATE_INIT_CMD8;
            end
        end
        
        STATE_INIT_CMD8: begin
            // 发送CMD8检查电压兼容性
            if (!cmd_send_en) begin
                cmd_send_en = 1'b1;
                cmd_index = CMD_SEND_IF_COND;
                cmd_argument = 32'h0000_01AA;  // 电压范围2.7-3.6V，检查模式
            end
            if (cmd_send_done && response_received) begin
                next_state = STATE_INIT_ACMD41;
            end
        end
        
        STATE_INIT_ACMD41: begin
            // 先发送CMD55
            if (!cmd_send_en) begin
                cmd_send_en = 1'b1;
                cmd_index = CMD_APP_CMD;
                cmd_argument = 32'h0;
            end
            if (cmd_send_done && response_received) begin
                // 然后发送ACMD41
                // 这里简化处理，实际需要循环发送直到卡就绪
                // 暂时直接进入下一步
                next_state = STATE_INIT_CMD2;
            end
        end
        
        STATE_INIT_CMD2: begin
            // 获取CID
            if (!cmd_send_en) begin
                cmd_send_en = 1'b1;
                cmd_index = CMD_ALL_SEND_CID;
                cmd_argument = 32'h0;
            end
            if (cmd_send_done && response_received) begin
                next_state = STATE_INIT_CMD3;
            end
        end
        
        STATE_INIT_CMD3: begin
            // 获取RCA
            if (!cmd_send_en) begin
                cmd_send_en = 1'b1;
                cmd_index = CMD_SEND_RELATIVE_ADDR;
                cmd_argument = 32'h0;
            end
            if (cmd_send_done && response_received) begin
                next_state = STATE_INIT_CMD7;
            end
        end
        
        STATE_INIT_CMD7: begin
            // 选择卡
            if (!cmd_send_en) begin
                cmd_send_en = 1'b1;
                cmd_index = CMD_SELECT_CARD;
                cmd_argument = 32'h0001_0000;  // 使用RCA（简化）
            end
            if (cmd_send_done && response_received) begin
                next_state = STATE_INIT_CMD16;
            end
        end
        
        STATE_INIT_CMD16: begin
            // 设置块长度为512字节
            if (!cmd_send_en) begin
                cmd_send_en = 1'b1;
                cmd_index = CMD_SET_BLOCKLEN;
                cmd_argument = 32'd512;
            end
            if (cmd_send_done && response_received) begin
                next_state = STATE_READY;
            end
        end
        
        STATE_READY: begin
            if (read_enable) begin
                next_state = STATE_READ_SECTOR;
            end else if (write_enable) begin
                next_state = STATE_WRITE_SECTOR;
            end
        end
        
        STATE_READ_SECTOR: begin
            // 发送读命令
            if (!cmd_send_en) begin
                cmd_send_en = 1'b1;
                cmd_index = CMD_READ_SINGLE_BLOCK;
                cmd_argument = lba_address;  // LBA地址
            end
            if (cmd_send_done && response_received) begin
                next_state = STATE_WAIT_DATA_TOKEN;
            end
        end
        
        STATE_WAIT_DATA_TOKEN: begin
            // 等待数据令牌（0xFE）
            // 简化处理：等待一定时间后进入数据传输
            // 实际应该检测DAT线上的数据令牌
            next_state = STATE_TRANSFER_DATA;
        end
        
        STATE_TRANSFER_DATA: begin
            data_transfer_active = 1'b1;
            // 从SD卡读取512字节数据到缓冲区
            // 简化处理：假设数据已经准备好
            if (read_enable) begin
                // 读操作：等待CPU读取数据
                if (data_byte_counter >= 512) begin
                    next_state = STATE_READY;
                    mem_ready = 1'b1;
                end
            end else if (write_enable) begin
                // 写操作：等待CPU写入数据
                if (data_byte_counter >= 512) begin
                    next_state = STATE_WAIT_WRITE_COMPLETE;
                end
            end
        end
        
        STATE_WAIT_WRITE_COMPLETE: begin
            // 等待写操作完成响应
            // 简化处理：直接返回就绪
            next_state = STATE_READY;
            mem_ready = 1'b1;
        end
        
        STATE_WRITE_SECTOR: begin
            // 发送写命令
            if (!cmd_send_en) begin
                cmd_send_en = 1'b1;
                cmd_index = CMD_WRITE_BLOCK;
                cmd_argument = lba_address;  // LBA地址
            end
            if (cmd_send_done && response_received) begin
                next_state = STATE_TRANSFER_DATA;
            end
        end
        
        default: begin
            next_state = STATE_IDLE;
        end
    endcase
end

// ============================================================================
// 数据字节计数器
// ============================================================================

// 检测状态转换，用于重置计数器
logic prev_state_transfer;
always_ff @(posedge clock) begin
    prev_state_transfer <= (current_state == STATE_TRANSFER_DATA);
end

logic transfer_state_entered;
assign transfer_state_entered = (current_state == STATE_TRANSFER_DATA) && !prev_state_transfer;

always_ff @(posedge clock or posedge reset) begin
    if (reset) begin
        data_byte_counter <= 10'd0;
    end else begin
        // 进入传输状态时重置计数器
        if (transfer_state_entered) begin
            data_byte_counter <= 10'd0;
        end else if (data_transfer_active) begin
            if (read_enable && io_en_r && io_addr == PORT_DATA_REG) begin
                data_byte_counter <= data_byte_counter + 1;
            end else if (write_enable && io_en_w && io_addr == PORT_DATA_REG) begin
                data_byte_counter <= data_byte_counter + 1;
            end
        end else begin
            data_byte_counter <= 10'd0;
        end
    end
end

// ============================================================================
// 输出信号连接
// ============================================================================

assign sd_cmd_out = sd_cmd_reg;
assign sd_cmd_oe = sd_cmd_oe_reg;
assign sd_dat_out = sd_dat_reg;
assign sd_dat_oe = sd_dat_oe_reg;
assign interrupt = 1'b0;  // 暂时不使用中断

endmodule
