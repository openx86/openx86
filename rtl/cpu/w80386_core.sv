module w80386_core (
    // bus
    output logic        o_bus_vaild,
    input  logic        i_bus_ready,
    input  logic        i_bus_busy,
    output logic        o_bus_write_enable,
    output logic [31:0] o_bus_address,
    input  logic [31:0] i_bus_data_read,
    output logic [31:0] o_bus_data_write,
    // common
    input  logic        clock,
    input  logic        reset
);

// register
logic        write_enable;
logic [ 2:0] write_index;
logic [31:0] write_data;
logic [31:0] GPR_read__8 [0:7];
logic [31:0] GPR_read_16 [0:7];
logic [31:0] GPR_read_32 [0:7];
general_propose_register general_propose_register (
    .write_enable ( write_enable ),
    .write_index ( write_index ),
    .write_data ( write_data ),
    .read__8 ( GPR_read__8 ),
    .read_16 ( GPR_read_16 ),
    .read_32 ( GPR_read_32 ),
    .clock ( clock ),
    .reset ( reset )
);

logic        SREG_write_enable;
logic [ 2:0] SREG_write_index;
logic [15:0] SREG_write_selector;
logic [63:0] SREG_write_descriptor;
logic [15:0] segment_selector [0:5];
logic [63:0] descriptor_cache [0:5];
segment_register core_segment_register (
    .write_enable ( SREG_write_enable ),
    .write_index ( SREG_write_index ),
    .write_selector ( SREG_write_selector ),
    .write_descriptor ( SREG_write_descriptor ),
    .segment_selector ( segment_selector ),
    .descriptor_cache ( descriptor_cache ),
    .clock ( clock ),
    .reset ( reset )
);

logic        FLAGS_write_enable;
logic        FLAGS_write_data;
logic        CF;
logic        PF;
logic        AF;
logic        ZF;
logic        SF;
logic        TF;
logic        IF;
logic        DF;
logic        OF;
logic [ 1:0] IOPL;
logic        NT;
logic        RF;
logic        VM;
logic        EFLAGS;
logic        FLAGS;
flags_register core_flags_register (
    .write_enable ( FLAGS_write_enable ),
    .write_data ( FLAGS_write_data ),
    .CF ( CF ),
    .PF ( PF ),
    .AF ( AF ),
    .ZF ( ZF ),
    .SF ( SF ),
    .TF ( TF ),
    .IF ( IF ),
    .DF ( DF ),
    .OF ( OF ),
    .IOPL ( IOPL ),
    .NT ( NT ),
    .RF ( RF ),
    .VM ( VM ),
    .EFLAGS ( EFLAGS ),
    .FLAGS ( FLAGS ),
    .clock ( clock ),
    .reset ( reset )
);

logic        IP_write_enable;
logic [31:0] IP_write_data;
logic [15:0] IP;
logic [31:0] EIP;
instruction_point_register core_instruction_point_register (
    .write_enable ( IP_write_enable ),
    .write_data ( IP_write_data ),
    .IP ( IP ),
    .EIP ( EIP ),
    .clock ( clock ),
    .reset ( reset )
);

// logic        seg_reg_write_enable;
// logic [ 4:0] seg_reg_write_index;
// logic [15:0] seg_reg_write_data;
// logic [15:0] CS;
// logic [15:0] SS;
// logic [15:0] DS;
// logic [15:0] ES;
// logic [15:0] FS;
// logic [15:0] GS;
// logic [63:0] CS_descriptor;
// logic [63:0] SS_descriptor;
// logic [63:0] DS_descriptor;
// logic [63:0] ES_descriptor;
// logic [63:0] FS_descriptor;
// logic [63:0] GS_descriptor;
// segment_register core_segment_register (
//     .write_enable ( seg_reg_write_enable ),
//     .write_index ( seg_reg_write_index ),
//     .write_data ( seg_reg_write_data ),
//     .CS ( CS ),
//     .SS ( SS ),
//     .DS ( DS ),
//     .ES ( ES ),
//     .FS ( FS ),
//     .GS ( GS ),
//     .CS_descriptor ( CS_descriptor ),
//     .SS_descriptor ( SS_descriptor ),
//     .DS_descriptor ( DS_descriptor ),
//     .ES_descriptor ( ES_descriptor ),
//     .FS_descriptor ( FS_descriptor ),
//     .GS_descriptor ( GS_descriptor ),
//     .clock ( clock ),
//     .reset ( reset )
// );

logic         CR_write_enable;
logic [ 2: 0] CR_write_index;
logic [31: 0] CR_write_data;
logic [31: 0] CR [0:7];
logic         PE;
logic         MP;
logic         EM;
logic         TS;
logic         R;
logic         PG;
logic [19: 0] page_directory_base;
control_register core_control_register (
    .write_enable ( CR_write_enable ),
    .write_index ( CR_write_index ),
    .write_data ( CR_write_data ),
    .CR ( CR ),
    .PE ( PE ),
    .MP ( MP ),
    .EM ( EM ),
    .TS ( TS ),
    .R ( R ),
    .PG ( PG ),
    .page_directory_base ( page_directory_base ),
    .clock ( clock ),
    .reset ( reset )
);

logic         DR_write_enable;
logic [ 2: 0] DR_write_index;
logic [31: 0] DR_write_data;
logic [31: 0] DR [0:7];
debug_register core_debug_register (
    .write_enable ( DR_write_enable ),
    .write_index ( DR_write_index ),
    .write_data ( DR_write_data ),
    .DR ( DR ),
    .clock ( clock ),
    .reset ( reset )
);

logic         TR_write_enable;
logic [ 2: 0] TR_write_index;
logic [31: 0] TR_write_data;
logic [31: 0] TR [0:7];
test_register core_test_register (
    .write_enable ( TR_write_enable ),
    .write_index ( TR_write_index ),
    .write_data ( TR_write_data ),
    .TR ( TR ),
    .clock ( clock ),
    .reset ( reset )
);

logic        GDTR_write_enable;
logic [15:0] GDTR_write_data_limit;
logic [31:0] GDTR_write_data_base;
logic [15:0] GDTR_limit;
logic [31:0] GDTR_base;
global_descriptor_table_register core_global_descriptor_table_register (
    .GDTR_write_enable ( GDTR_write_enable ),
    .GDTR_write_data_limit ( GDTR_write_data_limit ),
    .GDTR_write_data_base ( GDTR_write_data_base ),
    .GDTR_limit ( GDTR_limit ),
    .GDTR_base ( GDTR_base ),
    .clock ( clock ),
    .reset ( reset )
);

logic        IDTR_write_enable;
logic [15:0] IDTR_write_data_limit;
logic [31:0] IDTR_write_data_base;
logic [15:0] IDTR_limit;
logic [31:0] IDTR_base;
interrupt_descriptor_table_register core_interrupt_descriptor_table_register (
    .IDTR_write_enable ( IDTR_write_enable ),
    .IDTR_write_data_limit ( IDTR_write_data_limit ),
    .IDTR_write_data_base ( IDTR_write_data_base ),
    .IDTR_limit ( IDTR_limit ),
    .IDTR_base ( IDTR_base ),
    .clock ( clock ),
    .reset ( reset )
);

logic        code_vaild;
logic        code_ready;
logic [31:0] code_address;
logic [31:0] code_data_read;
logic        data_vaild;
logic        data_ready;
logic        data_write_enable;
logic [31:0] data_address;
logic [31:0] data_data_read;
logic [31:0] data_data_write;

bus_interface_unit core_bus_interface_unit (
    .i_code_vaild ( code_vaild ),
    .o_code_ready ( code_ready ),
    .i_code_address ( code_address ),
    .o_code_data_read ( code_data_read ),
    .i_data_vaild ( data_vaild ),
    .o_data_ready ( data_ready ),
    .i_data_write_enable ( data_write_enable ),
    .i_data_address ( data_address ),
    .o_data_data_read ( data_data_read ),
    .i_data_data_write ( data_data_write ),
    .o_bus_vaild ( o_bus_vaild ),
    .i_bus_ready ( i_bus_ready ),
    .i_bus_busy ( i_bus_busy ),
    .o_bus_write_enable ( o_bus_write_enable ),
    .o_bus_address ( o_bus_address ),
    .i_bus_data_read ( i_bus_data_read ),
    .o_bus_data_write ( o_bus_data_write ),
    .i_clock ( clock ),
    .i_reset ( reset )
);

logic         IP_vaild;
logic [ 7: 0] instruction [0:15];
logic         instruction_ready;
instruction_fetch core_instruction_fetch (
    .o_code_vaild ( code_vaild ),
    .i_code_ready ( code_ready ),
    .o_code_address ( code_address ),
    .i_code_data_read ( code_data_read ),
    .i_IP_vaild ( IP_vaild ),
    .o_instruction ( instruction[0:15] ),
    .o_instruction_ready ( instruction_ready ),
    .EIP ( EIP ),
    .clock ( clock ),
    .reset ( reset )
);

decode core_decode (
    .i_instruction ( instruction[0:15] )
);

// logic [31:0] code_base;
// logic [19:0] code_limit;
// logic        code_present;
// logic [ 1:0] code_privilege_level;
// logic        code_available_field;
// logic        code_segment_type;
// logic        code_date_or_code_granularity;
// logic        code_default_operation_size;
// logic        code_date_or_code_segment_executable;
// logic        code_code_segment_conforming;
// logic        code_code_segment_readable;
// segment_descriptor_decode core_code_segment_descriptor_decode (
//     .base ( code_base ),
//     .limit ( code_limit ),
//     .present ( code_present ),
//     .privilege_level ( code_privilege_level ),
//     .available_field ( code_available_field ),
//     .segment_type ( code_segment_type ),
//     .date_or_code_granularity ( code_date_or_code_granularity ),
//     .date_or_code_default_operation_size ( code_default_operation_size ),
//     .date_or_code_segment_executable ( code_date_or_code_segment_executable ),
//     .code_segment_conforming ( code_code_segment_conforming ),
//     .code_segment_readable ( code_code_segment_readable ),
//     .descriptor ( CS_descriptor )
// );

// logic program_counter_valid = 1;
// logic [ 7:0] instruction [0:15];
// wire  default_operand_size = 1;

// logic        instruction_ready;
// logic [`info_bit_width_len-1:0] bit_width;
// fetch core_fetch (
//     .PE ( PE ),
//     .IP ( IP ),
//     .EIP ( EIP ),
//     .CS ( CS ),
//     .code_segment_base ( code_base ),
//     .code_default_operation_size ( code_default_operation_size ),
//     .bus_read_vaild ( bus_read_vaild ),
//     .bus_read_ready ( bus_read_ready ),
//     .bus_read_address ( bus_read_address ),
//     .bus_read_data ( bus_read_data ),
//     .program_counter_valid ( program_counter_valid ),
//     .instruction ( instruction ),
//     .instruction_ready ( instruction_ready ),
//     .bit_width ( bit_width ),
//     .clock ( clock ),
//     .reset ( reset )
// );

// interface_opcode opcode_interface_instance ();

// logic [ 7:0] decode_i_instruction [0:15];
// logic        decode_i_default_operand_size;
// logic[241:0] decode_o_opcode;
// logic        decode_o_prefix_lock_bus;
// logic        decode_o_prefix_repeat_not_equal;
// logic        decode_o_prefix_repeat_equal;
// logic        decode_o_prefix_bound;
// logic        decode_o_prefix_hint_branch_not_taken;
// logic        decode_o_prefix_hint_branch_taken;
// logic        o_field_gen_reg_is_present;
// logic [ 2:0] o_field_gen_reg_index;
// logic [ 2:0] decode_o_segment_reg_index;
// logic [ 1:0] decode_o_scale_factor;
// logic        decode_o_base_reg_is_present;
// logic [ 2:0] decode_o_base_reg_index;
// logic        decode_o_index_reg_is_present;
// logic [ 2:0] decode_o_index_reg_index;
// logic        decode_o_gen_reg_used;
// logic [ 2:0] decode_o_gen_reg_index;
// logic [ 2:0] decode_o_gen_reg_bit_width;
// logic        decode_o_displacement_is_present;
// logic [31:0] decode_o_displacement;
// logic        decode_o_immediate_is_present;
// logic [31:0] decode_o_immediate;
// logic [ 4:0] decode_o_bytes_consumed;
// logic        decode_o_error;
//
// decode decode (
//     .i_instruction                  ( decode_i_instruction ),
//     .i_default_operand_size         ( decode_i_default_operand_size ),
//     .o_prefix_lock_bus              ( decode_o_prefix_lock_bus ),
//     .o_prefix_repeat_not_equal      ( decode_o_prefix_repeat_not_equal ),
//     .o_prefix_repeat_equal          ( decode_o_prefix_repeat_equal ),
//     .o_prefix_bound                 ( decode_o_prefix_bound ),
//     .o_prefix_hint_branch_not_taken ( decode_o_prefix_hint_branch_not_taken ),
//     .o_prefix_hint_branch_taken     ( decode_o_prefix_hint_branch_taken ),
//     .o_field_gen_reg_is_present     ( decode_o_field_gen_reg_is_present ),
//     .o_field_gen_reg_index          ( decode_o_field_gen_reg_index ),
//     .o_segment_reg_index            ( decode_o_segment_reg_index ),
//     .o_scale_factor                 ( decode_o_scale_factor ),
//     .o_base_reg_is_present          ( decode_o_base_reg_is_present ),
//     .o_base_reg_index               ( decode_o_base_reg_index ),
//     .o_index_reg_is_present         ( decode_o_index_reg_is_present ),
//     .o_index_reg_index              ( decode_o_index_reg_index ),
//     .o_mod_rm_gen_reg_is_present    ( decode_o_mod_rm_gen_reg_is_present ),
//     .o_mod_rm_gen_reg_index         ( decode_o_mod_rm_gen_reg_index ),
//     .o_mod_rm_gen_reg_bit_width     ( decode_o_mod_rm_gen_reg_bit_width ),
//     .o_displacement_is_present      ( decode_o_displacement_is_present ),
//     .o_displacement                 ( decode_o_displacement ),
//     .o_immediate_is_present         ( decode_o_immediate_is_present ),
//     .o_immediate                    ( decode_o_immediate ),
//     .o_bytes_consumed               ( decode_o_bytes_consumed ),
//     .o_error                        ( decode_o_error )
// );

endmodule
