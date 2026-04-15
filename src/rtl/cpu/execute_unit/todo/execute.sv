// ============================================================================
// todo/execute.sv
// ----------------------------------------------------------------------------
// 草稿级“执行/译码”逻辑（目录名 todo 表示未完成实现）。
//
// 注意：
// - 本文件依赖 `../define.h` 的宏定义。
// - 当前模块名为 `decode_opcode`（见下方），与文件所在目录含义并不完全一致，
//   属于历史演进过程中的临时产物。
// ============================================================================

`include "../define.h"

// ============================================================================
// todo/execute.sv
// ----------------------------------------------------------------------------
// 草稿级“执行/译码”逻辑（目录名 todo 表示未完成实现）。
//
// 注意：
// - 本文件的模块名为 `decode_opcode`，且依赖 `../define.h` 的宏定义。
// - 若后续重构目录或替换为 package/enum，建议优先清理这类 include 宏依赖。
// ============================================================================

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
