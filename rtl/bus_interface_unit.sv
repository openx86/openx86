module bus_interface_unit #(
    //
) (
    // code
    input  logic        code_vaild,
    output logic        code_ready,
    input  logic [31:0] code_address,
    output logic [31:0] code_data_read,
    // data
    input  logic        data_vaild,
    output logic        data_ready,
    input  logic        data_write_enable,
    input  logic [31:0] data_address,
    input  logic [31:0] data_data_read,
    output logic [31:0] data_data_write,
    // bus
    input  logic        bus_vaild,
    output logic        bus_ready,
    input  logic        bus_busy,
    output logic        bus_write_enable,
    output logic [31:0] bus_address,
    input  logic [31:0] bus_data_read,
    output logic [31:0] bus_data_write,
    // common
    input  logic        clock, reset
);

assign code_data_read = bus_data_read;
assign data_data_read = bus_data_read;

assign bus_data_write = data_data_write;

logic [3:0] enum {
    STATE_WAIT_FOR_CODE_READY = 4'h1,
    STATE_WAIT_FOR_DATA_READY = 4'h2,
    STATE_WAIT_FOR_VAILD = 4'h0
} state;

always_ff @(posedge clock or posedge reset) begin
    if (reset) begin
        state <= STATE_WAIT_FOR_VAILD;
    end else begin
        case (state)
            STATE_WAIT_FOR_VAILD: begin
                if (code_vaild) begin
                    state <= STATE_WAIT_FOR_CODE_READY;
                end else if (code_vaild) begin
                    state <= STATE_WAIT_FOR_DATA_READY;
                end else begin
                    state <= STATE_WAIT_FOR_VAILD;
                end
            end
            STATE_WAIT_FOR_CODE_READY: begin
                if (code_ready) begin
                    state <= STATE_WAIT_FOR_VAILD;
                end else begin
                    state <= STATE_WAIT_FOR_CODE_READY;
                end
            end
            STATE_WAIT_FOR_DATA_READY: begin
                if (data_ready) begin
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

always_ff @(posedge clock or posedge reset) begin
    if (reset) begin
        bus_vaild <= 0;
        bus_write_enable <= 0;
        bus_address <= 0;
        code_ready <= 0;
        data_ready <= 0;
    end else begin
        unique case (state)
            STATE_WAIT_FOR_VAILD: begin
                if (code_vaild | data_vaild) begin
                    bus_vaild <= 1;
                end else begin
                    bus_vaild <= 0;
                end
                if (code_vaild) begin
                    bus_write_enable <= 0;
                    bus_address <= code_address;
                end else if (data_vaild) begin
                    bus_write_enable <= data_write_enable;
                    bus_address <= data_address;
                end else begin
                    bus_write_enable <= 0;
                end
                code_ready <= 0;
                data_ready <= 0;
            end
            STATE_WAIT_FOR_CODE_READY: begin
                if (bus_ready) begin
                    code_ready <= 1;
                end else begin
                    code_ready <= 0;
                end
            end
            STATE_WAIT_FOR_DATA_READY: begin
                if (bus_ready) begin
                    data_ready <= 1;
                end else begin
                    data_ready <= 0;
                end
            end
            default: begin
                state <= STATE_WAIT_FOR_VAILD;
            end
        endcase
    end
end


endmodule
