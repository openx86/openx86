// ============================================================================
// bus_interface_unit (BIU)
// ----------------------------------------------------------------------------
// 「分页表遍历(mmu)」「取指(code)」「数据(data)」复用到单一系统总线。
// 优先级：MMU > code > data。
// ============================================================================

module bus_interface_unit (
    input  logic        i_mmu_vaild,
    output logic        o_mmu_ready,
    input  logic [31:0] i_mmu_address,
    output logic [31:0] o_mmu_data_read,

    input  logic        i_code_vaild,
    output logic        o_code_ready,
    input  logic [31:0] i_code_address,
    output logic [31:0] o_code_data_read,

    input  logic        i_data_vaild,
    output logic        o_data_ready,
    input  logic        i_data_write_enable,
    input  logic        i_data_io_access,
    input  logic [31:0] i_data_address,
    output logic [31:0] o_data_data_read,
    input  logic [31:0] i_data_data_write,

    output logic        o_bus_vaild,
    input  logic        i_bus_ready,
    input  logic        i_bus_busy,
    output logic        o_bus_write_enable,
    output logic        o_bus_io_access,
    output logic [31:0] o_bus_address,
    input  logic [31:0] i_bus_data_read,
    output logic [31:0] o_bus_data_write,

    input  logic        i_clock, i_reset
);

assign o_mmu_data_read  = i_bus_data_read;
assign o_code_data_read = i_bus_data_read;
assign o_data_data_read = i_bus_data_read;

typedef enum logic [2:0] {
    S_IDLE,
    S_MMU,
    S_CODE,
    S_DATA
} biu_state_e;

biu_state_e state;

always_ff @(posedge i_clock or posedge i_reset) begin
    if (i_reset) begin
        state <= S_IDLE;
        o_bus_vaild <= 1'b0;
        o_bus_write_enable <= 1'b0;
        o_bus_io_access <= 1'b0;
        o_bus_address <= 32'h0;
        o_bus_data_write <= 32'h0;
        o_mmu_ready <= 1'b0;
        o_code_ready <= 1'b0;
        o_data_ready <= 1'b0;
    end else begin
        o_mmu_ready <= 1'b0;
        o_code_ready <= 1'b0;
        o_data_ready <= 1'b0;

        unique case (state)
            S_IDLE: begin
                o_bus_vaild <= 1'b0;
                if (i_mmu_vaild) begin
                    state <= S_MMU;
                    o_bus_vaild <= 1'b1;
                    o_bus_write_enable <= 1'b0;
                    o_bus_io_access <= 1'b0;
                    o_bus_address <= i_mmu_address;
                    o_bus_data_write <= 32'h0;
                end else if (i_code_vaild) begin
                    state <= S_CODE;
                    o_bus_vaild <= 1'b1;
                    o_bus_write_enable <= 1'b0;
                    o_bus_io_access <= 1'b0;
                    o_bus_address <= i_code_address;
                    o_bus_data_write <= 32'h0;
                end else if (i_data_vaild) begin
                    state <= S_DATA;
                    o_bus_vaild <= 1'b1;
                    o_bus_write_enable <= i_data_write_enable;
                    o_bus_io_access <= i_data_io_access;
                    o_bus_address <= i_data_address;
                    o_bus_data_write <= i_data_data_write;
                end
            end
            S_MMU: begin
                if (i_bus_ready) begin
                    o_mmu_ready <= 1'b1;
                    o_bus_vaild <= 1'b0;
                    state <= S_IDLE;
                end
            end
            S_CODE: begin
                if (i_bus_ready) begin
                    o_code_ready <= 1'b1;
                    o_bus_vaild <= 1'b0;
                    state <= S_IDLE;
                end
            end
            S_DATA: begin
                if (i_bus_ready) begin
                    o_data_ready <= 1'b1;
                    o_bus_vaild <= 1'b0;
                    state <= S_IDLE;
                end
            end
            default: state <= S_IDLE;
        endcase
    end
end

endmodule
