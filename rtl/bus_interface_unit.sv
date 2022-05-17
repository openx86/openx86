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
