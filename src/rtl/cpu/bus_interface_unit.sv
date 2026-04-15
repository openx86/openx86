// ============================================================================
// bus_interface_unit (BIU)
// ----------------------------------------------------------------------------
// 将 CPU 的“取指(code)”与“数据(data)”两类访问复用到单一系统总线接口上。
//
// 端口语义（约定）：
// - `*_vaild`/`*_ready`：源端发起/汇端接受的一拍握手（历史拼写 `vaild` 保留）
// - `i_bus_busy`：下游系统（如 SDRAM/外设）正在处理长事务，BIU 需暂停新请求
//
// 典型数据流：
// - code 侧优先级（通常高于 data，用于保证前端不断流）
// - data 侧在 code 空闲时占用总线
//
// 注意：本模块本身不做缓存/重排序；属于“最小可用 bring-up”式 BIU。
// ============================================================================

module bus_interface_unit (
    // code
    input  logic        i_code_vaild,
    output logic        o_code_ready,
    input  logic [31:0] i_code_address,
    output logic [31:0] o_code_data_read,
    // data
    input  logic        i_data_vaild,
    output logic        o_data_ready,
    input  logic        i_data_write_enable,
    input  logic [31:0] i_data_address,
    output logic [31:0] o_data_data_read,
    input  logic [31:0] i_data_data_write,
    // bus
    output logic        o_bus_vaild,
    input  logic        i_bus_ready,
    input  logic        i_bus_busy,
    output logic        o_bus_write_enable,
    output logic [31:0] o_bus_address,
    input  logic [31:0] i_bus_data_read,
    output logic [31:0] o_bus_data_write,
    // common
    input  logic        i_clock, i_reset
);

assign o_code_data_read = i_bus_data_read;
assign o_data_data_read = i_bus_data_read;

assign o_bus_data_write = i_data_data_write;

enum logic [3:0] {
    STATE_WAIT_FOR_CODE_READY = 4'h1,
    STATE_WAIT_FOR_DATA_READY = 4'h2,
    STATE_WAIT_FOR_VAILD = 4'h0
} state;

always_ff @(posedge i_clock or posedge i_reset) begin
    if (i_reset) begin
        state <= STATE_WAIT_FOR_VAILD;
    end else begin
        case (state)
            STATE_WAIT_FOR_VAILD: begin
                if (i_code_vaild) begin
                    state <= STATE_WAIT_FOR_CODE_READY;
                end else if (i_data_vaild) begin
                    state <= STATE_WAIT_FOR_DATA_READY;
                end else begin
                    state <= STATE_WAIT_FOR_VAILD;
                end
            end
            STATE_WAIT_FOR_CODE_READY: begin
                if (i_bus_ready) begin
                    state <= STATE_WAIT_FOR_VAILD;
                end else begin
                    state <= STATE_WAIT_FOR_CODE_READY;
                end
            end
            STATE_WAIT_FOR_DATA_READY: begin
                if (i_bus_ready) begin
                    state <= STATE_WAIT_FOR_VAILD;
                end else begin
                    state <= STATE_WAIT_FOR_DATA_READY;
                end
            end
            default: begin
                state <= STATE_WAIT_FOR_VAILD;
            end
        endcase
    end
end

always_ff @(posedge i_clock or posedge i_reset) begin
    if (i_reset) begin
        o_bus_vaild <= 0;
        o_bus_write_enable <= 0;
        o_bus_address <= 0;
        o_code_ready <= 0;
        o_data_ready <= 0;
    end else begin
        unique case (state)
            STATE_WAIT_FOR_VAILD: begin
                if (i_code_vaild | i_data_vaild) begin
                    o_bus_vaild <= 1;
                end else begin
                    o_bus_vaild <= 0;
                end
                if (i_code_vaild) begin
                    o_bus_write_enable <= 0;
                    o_bus_address <= i_code_address;
                end else if (i_data_vaild) begin
                    o_bus_write_enable <= i_data_write_enable;
                    o_bus_address <= i_data_address;
                end else begin
                    o_bus_write_enable <= 0;
                end
                o_code_ready <= 0;
                o_data_ready <= 0;
            end
            STATE_WAIT_FOR_CODE_READY: begin
                if (i_bus_ready) begin
                    o_code_ready <= 1;
                end else begin
                    o_code_ready <= 0;
                end
            end
            STATE_WAIT_FOR_DATA_READY: begin
                if (i_bus_ready) begin
                    o_data_ready <= 1;
                end else begin
                    o_data_ready <= 0;
                end
            end
            default: begin
                state <= STATE_WAIT_FOR_VAILD;
            end
        endcase
    end
end


endmodule
