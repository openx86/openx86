// ============================================================================
// todo/load.sv
// ----------------------------------------------------------------------------
// 草稿级的内存访问模型（目录名 todo 表示未完成实现）。
//
// 当前模块 `memory` 仅提供一个抽象的读写接口，具体与系统总线/缓存/MMU 的对接
// 需要在后续设计中明确（时序、字节使能、对齐、异常等）。
// ============================================================================

module memory #(
    // parameters
) (
    // port_list
    input  logic [31:0] address,
    input  logic        write_enable,
    input  logic [31:0] write_data,
    input  logic        read_enable,
    output logic [31:0] read_data,
);

// decode_main decode_main_inst (
//     .instruction ( instruction ),
//     .opcode ( opcode ),
//     .operand ( operand ),
// );

endmodule
