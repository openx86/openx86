`include "../define.h"
module decode_opcode #(
    // parameters
) (
    // ports
    input  logic [`DECODE_OPCODE_INFO_LEN-1:0] opcode_info,
    input  logic [`OPERAND_BIT_WIDTH-1:0] operand[4],
    output logic [`OPERAND_BIT_WIDTH-1:0] result[4],
);

logic [31:0] address;
logic        write_enable;
logic [31:0] write_data;
logic        read_enable;
logic [31:0] read_data;
memory memory_inst (
    // port_list
    .address ( address ),
    .write_enable ( write_enable ),
    .write_data ( write_data ),
    .read_enable ( read_enable ),
    .read_data ( read_data ),
);

always_comb begin
    case (opcode_info)
        `DECODE_OPCODE_LOAD : begin
            read_enable <= 1;
            address <= operand[0];
            result[0] <= read_data;
        end
        `DECODE_OPCODE_STOR : begin
            write_enable <= 1;
            address <= operand[0];
            write_data <= operand[1];
        end
        // default: begin
        //     default_case
        // end
    endcase
end

endmodule
