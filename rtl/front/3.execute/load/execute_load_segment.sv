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
    output logic [15:0] write_descriptor,
    input  logic        valid,
    output logic        ready,
);

wire is_code_segment_index = index_segment_register == `sreg_index_CS;

wire [31:0] encode_base                               , decode_base;
wire [19:0] encode_limit                              , decode_limit;
wire        encode_present                            , decode_present;
wire [ 1:0] encode_privilege_level                    , decode_privilege_level;
wire        encode_available_field                    , decode_available_field;
wire        encode_descriptor_type                    , decode_descriptor_type;
wire        encode_date_or_code_granularity           , decode_date_or_code_granularity;
wire        encode_date_or_code_default_operation_size, decode_date_or_code_default_operation_size;
wire        encode_date_or_code_executable            , decode_date_or_code_executable;
wire        encode_data_expansion_direction           , decode_data_expansion_direction;
wire        encode_data_writeable                     , decode_data_writeable;
wire        encode_code_conforming                    , decode_code_conforming;
wire        encode_code_readable                      , decode_code_readable;
wire        encode_date_or_code_accessed              , decode_date_or_code_accessed;
wire [ 3:0] encode_segment_type                       , decode_segment_type;

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
    .descriptor                               ( encode_segment_type )
);

segment_descriptor_decode u_segment_descriptor_decode (
    .base                                     ( decode_base ),
    .limit                                    ( decode_limit ),
    .present                                  ( decode_present ),
    .privilege_level                          ( decode_privilege_level ),
    .available_field                          ( decode_available_field ),
    .descriptor_type                          ( decode_descriptor_type ),
    .date_or_code_granularity                 ( decode_date_or_code_granularity ),
    .date_or_code_default_operation_size      ( decode_date_or_code_default_operation_size ),
    .date_or_code_executable                  ( decode_date_or_code_executable ),
    .data_expansion_direction_code_conforming ( decode_data_expansion_direction_code_conforming ),
    .data_writeable_code_readable             ( decode_data_writeable_code_readable ),
    .date_or_code_accessed                    ( decode_date_or_code_accessed ),
    .descriptor                               ( decode_segment_type )
);

always_comb begin
    if (~protected_mode_enable) begin
        base                                     <= ;
        limit                                    <= 32'h0000_FFFF;
        present                                  <= 1;
        privilege_level                          <= 0;
        available_field                          <= 0;
        descriptor_type                          <= 0;
        date_or_code_granularity                 <= `granularity_byte;
        date_or_code_default_operation_size      <= `default_operation_size_16;
        date_or_code_executable                  <= is_code_segment_index;
        data_expansion_direction_code_conforming <= `data_expansion_direction_up;
        data_writeable_code_readable             <= 1;
        date_or_code_accessed                    <= 1;
        write_descriptor <= encode_segment_type;
    end else begin

    end
end



endmodule
