// ============================================================================
// execute_load_segment
// ----------------------------------------------------------------------------
// 处理将段选择子/描述符装载到段寄存器的执行路径（如 MOV Sreg, r/m16 等）。
//
// 端口提示（按当前实现命名）：
// - 输入提供：模式位 `protected_mode_enable`、目的段寄存器索引、源通用寄存器索引、
//   以及 8/16/32 位通用寄存器读数（由上层根据操作数宽度选择）。
// - 输出给寄存器文件：`write_enable/write_index/write_selector/write_descriptor`
// - `valid/ready`：本子模块与上层执行控制之间的握手
//
// 备注：段装载在保护模式下需要做权限检查与描述符解析；若当前实现为 bring-up，
// 可能只覆盖最小可运行路径，未实现全部异常语义。
// ============================================================================

module execute_load_segment (
    input  logic        protected_mode_enable,
    input  logic [15:0] index_segment_register,
    input  logic [15:0] index_general_register,
    input  logic [ 7:0] greg__8,
    input  logic [15:0] greg_16,
    input  logic [31:0] greg_32,
    output logic [15:0] write_enable,
    output logic [15:0] write_index,
    output logic [15:0] write_selector,
    output logic [63:0] write_descriptor,
    input  logic        valid,
    output logic        ready
);

wire is_code_segment_index = index_segment_register == `sreg_index_CS;

logic [31:0] encode_base;
logic [19:0] encode_limit;
logic        encode_present;
logic [ 1:0] encode_privilege_level;
logic        encode_available_field;
logic        encode_descriptor_type;
logic        encode_date_or_code_granularity;
logic        encode_date_or_code_default_operation_size;
logic        encode_date_or_code_executable;
logic        encode_data_expansion_direction_code_conforming;
logic        encode_data_writeable_code_readable;
logic        encode_date_or_code_accessed;

wire [63:0] encode_descriptor;

wire [31:0] decode_base;
wire [19:0] decode_limit;
wire        decode_present;
wire [ 1:0] decode_privilege_level;
wire        decode_available_field;
wire        decode_descriptor_type;
wire        decode_date_or_code_granularity;
wire        decode_date_or_code_default_operation_size;
wire        decode_date_or_code_executable;
wire        decode_data_expansion_direction;
wire        decode_data_writeable;
wire        decode_code_conforming;
wire        decode_code_readable;
wire        decode_date_or_code_accessed;

segment_descriptor_encode u_segment_descriptor_encode (
    .base                                     ( encode_base ),
    .limit                                    ( encode_limit ),
    .present                                  ( encode_present ),
    .privilege_level                          ( encode_privilege_level ),
    .available_field                          ( encode_available_field ),
    .descriptor_type                          ( encode_descriptor_type ),
    .date_or_code_granularity                 ( encode_date_or_code_granularity ),
    .date_or_code_default_operation_size      ( encode_date_or_code_default_operation_size ),
    .date_or_code_executable                  ( encode_date_or_code_executable ),
    .data_expansion_direction_code_conforming ( encode_data_expansion_direction_code_conforming ),
    .data_writeable_code_readable             ( encode_data_writeable_code_readable ),
    .date_or_code_accessed                    ( encode_date_or_code_accessed ),
    .descriptor                               ( encode_descriptor )
);

segment_descriptor_decode u_segment_descriptor_decode (
    .o_base                                     ( decode_base ),
    .o_limit                                    ( decode_limit ),
    .o_date_or_code_present                     ( decode_present ),
    .o_date_or_code_privilege_level             ( decode_privilege_level ),
    .o_available_field                          ( decode_available_field ),
    .o_segment_type                             ( decode_descriptor_type ),
    .o_date_or_code_granularity                 ( decode_date_or_code_granularity ),
    .o_date_or_code_default_operation_size      ( decode_date_or_code_default_operation_size ),
    .o_date_or_code_executable                  ( decode_date_or_code_executable ),
    .o_data_expansion_direction                 ( decode_data_expansion_direction ),
    .o_data_writeable                           ( decode_data_writeable ),
    .o_code_conforming                          ( decode_code_conforming ),
    .o_code_readable                            ( decode_code_readable ),
    .o_date_or_code_accessed                    ( decode_date_or_code_accessed ),
    .i_descriptor                               ( encode_descriptor )
);

always_comb begin
    write_enable   = 16'b0;
    write_index    = index_segment_register;
    write_selector = greg_16;
    if (~protected_mode_enable) begin
        encode_base                                     = { 16'b0, greg_16, 4'b0 };
        encode_limit                                    = 20'h0_FFFF;
        encode_present                                  = 1'b1;
        encode_privilege_level                          = 2'b0;
        encode_available_field                          = 1'b0;
        encode_descriptor_type                          = 1'b1;
        encode_date_or_code_granularity                 = `granularity_byte;
        encode_date_or_code_default_operation_size      = `default_operation_size_16;
        encode_date_or_code_executable                  = is_code_segment_index;
        encode_data_expansion_direction_code_conforming = `data_expansion_direction_up;
        encode_data_writeable_code_readable             = 1'b1;
        encode_date_or_code_accessed                    = 1'b1;
        write_descriptor                                = encode_descriptor;
    end else begin
        encode_base                                     = '0;
        encode_limit                                    = '0;
        encode_present                                  = 1'b0;
        encode_privilege_level                          = '0;
        encode_available_field                          = 1'b0;
        encode_descriptor_type                          = 1'b0;
        encode_date_or_code_granularity                 = `granularity_byte;
        encode_date_or_code_default_operation_size      = `default_operation_size_16;
        encode_date_or_code_executable                  = 1'b0;
        encode_data_expansion_direction_code_conforming = `data_expansion_direction_up;
        encode_data_writeable_code_readable             = 1'b0;
        encode_date_or_code_accessed                    = 1'b0;
        write_descriptor                                = '0;
    end
end

assign ready = 1'b1;

endmodule
