module w80386_core (
    output logic        bus_vaild,
    input  logic        bus_ready,
    output logic        bus_write_enable,
    output logic [31:0] bus_address,
    input  logic [31:0] bus_data,
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
general_propose_register general_propose_register_in_core (
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
segment_register u_segment_register_in_core (
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
flags_register u_flags_register_in_core (
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
instruction_point_register u_instruction_point_register_in_core (
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
// segment_register u_segment_register (
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
control_register u_control_register_in_core (
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
debug_register u_debug_register_in_core (
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
test_register u_test_register_in_core (
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
global_descriptor_table_register u_global_descriptor_table_register_in_core (
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
interrupt_descriptor_table_register u_interrupt_descriptor_table_register_in_core (
    .IDTR_write_enable ( IDTR_write_enable ),
    .IDTR_write_data_limit ( IDTR_write_data_limit ),
    .IDTR_write_data_base ( IDTR_write_data_base ),
    .IDTR_limit ( IDTR_limit ),
    .IDTR_base ( IDTR_base ),
    .clock ( clock ),
    .reset ( reset )
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
// segment_descriptor_decode u_code_segment_descriptor_decode (
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
logic [ 7:0] instruction [0:9];
// logic        instruction_ready;
// logic [`info_bit_width_len-1:0] bit_width;
// fetch u_fetch (
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

logic        opcode_MOV_reg_to_reg_mem;
logic        opcode_MOV_reg_mem_to_reg;
logic        opcode_MOV_imm_to_reg_mem;
logic        opcode_MOV_imm_to_reg_short;
logic        opcode_MOV_mem_to_acc;
logic        opcode_MOV_acc_to_mem;
logic        opcode_MOV_reg_mem_to_sreg;
logic        opcode_MOV_sreg_to_reg_mem;
logic        opcode_MOVSX;
logic        opcode_MOVZX;
logic        opcode_PUSH_reg_mem;
logic        opcode_PUSH_reg_short;
logic        opcode_PUSH_sreg_2;
logic        opcode_PUSH_sreg_3;
logic        opcode_PUSH_imm;
logic        opcode_PUSH_all;
logic        opcode_POP_reg_mem;
logic        opcode_POP_reg_short;
logic        opcode_POP_sreg_2;
logic        opcode_POP_sreg_3;
logic        opcode_POP_all;
logic        opcode_XCHG_reg_mem_with_reg;
logic        opcode_XCHG_reg_with_acc_short;
logic        opcode_IN_port_fixed;
logic        opcode_IN_port_variable;
logic        opcode_OUT_port_fixed;
logic        opcode_OUT_port_variable;
logic        opcode_LEA_load_ea_to_reg;
logic        opcode_LDS_load_ptr_to_DS;
logic        opcode_LES_load_ptr_to_ES;
logic        opcode_LFS_load_ptr_to_FS;
logic        opcode_LGS_load_ptr_to_GS;
logic        opcode_LSS_load_ptr_to_SS;
logic        opcode_CLC_clear_carry_flag;
logic        opcode_CLD_clear_direction_flag;
logic        opcode_CLI_clear_interrupt_enable_flag;
logic        opcode_CLTS_clear_task_switched_flag;
logic        opcode_CMC_complement_carry_flag;
logic        opcode_LAHF_load_ah_into_flag;
logic        opcode_POPF_pop_flags;
logic        opcode_PUSHF_push_flags;
logic        opcode_SAHF_store_ah_into_flag;
logic        opcode_STC_set_carry_flag;
logic        opcode_STD_set_direction_flag;
logic        opcode_STI_set_interrupt_enable_flag;
logic        opcode_ADD_reg_to_mem;
logic        opcode_ADD_mem_to_reg;
logic        opcode_ADD_imm_to_reg_mem;
logic        opcode_ADD_imm_to_acc;
logic        opcode_ADC_reg_to_mem;
logic        opcode_ADC_mem_to_reg;
logic        opcode_ADC_imm_to_reg_mem;
logic        opcode_ADC_imm_to_acc;
logic        opcode_INC_reg_mem;
logic        opcode_INC_reg;
logic        opcode_SUB_reg_to_mem;
logic        opcode_SUB_mem_to_reg;
logic        opcode_SUB_imm_to_reg_mem;
logic        opcode_SUB_imm_to_acc;
logic        opcode_SBB_reg_to_mem;
logic        opcode_SBB_mem_to_reg;
logic        opcode_SBB_imm_to_reg_mem;
logic        opcode_SBB_imm_to_acc;
logic        opcode_DEC_reg_mem;
logic        opcode_DEC_reg;
logic        opcode_CMP_mem_with_reg;
logic        opcode_CMP_reg_with_mem;
logic        opcode_CMP_imm_with_reg_mem;
logic        opcode_CMP_imm_with_acc;
logic        opcode_NEG_change_sign;
logic        opcode_AAA;
logic        opcode_AAS;
logic        opcode_DAA;
logic        opcode_DAS;
logic        opcode_MUL_acc_with_reg_mem;
logic        opcode_IMUL_acc_with_reg_mem;
logic        opcode_IMUL_reg_with_reg_mem;
logic        opcode_IMUL_reg_mem_with_imm_to_reg;
logic        opcode_DIV_acc_by_reg_mem;
logic        opcode_IDIV_acc_by_reg_mem;
logic        opcode_AAD;
logic        opcode_AAM;
logic        opcode_CBW;
logic        opcode_CWD;
logic        opcode_ROL_reg_mem_by_1;
logic        opcode_ROL_reg_mem_by_CL;
logic        opcode_ROL_reg_mem_by_imm;
logic        opcode_ROR_reg_mem_by_1;
logic        opcode_ROR_reg_mem_by_CL;
logic        opcode_ROR_reg_mem_by_imm;
logic        opcode_SHL_reg_mem_by_1;
logic        opcode_SHL_reg_mem_by_CL;
logic        opcode_SHL_reg_mem_by_imm;
logic        opcode_SAR_reg_mem_by_1;
logic        opcode_SAR_reg_mem_by_CL;
logic        opcode_SAR_reg_mem_by_imm;
logic        opcode_SHR_reg_mem_by_1;
logic        opcode_SHR_reg_mem_by_CL;
logic        opcode_SHR_reg_mem_by_imm;
logic        opcode_RCL_reg_mem_by_1;
logic        opcode_RCL_reg_mem_by_CL;
logic        opcode_RCL_reg_mem_by_imm;
logic        opcode_RCR_reg_mem_by_1;
logic        opcode_RCR_reg_mem_by_CL;
logic        opcode_RCR_reg_mem_by_imm;
logic        opcode_SHLD_reg_mem_by_imm;
logic        opcode_SHLD_reg_mem_by_CL;
logic        opcode_SHRD_reg_mem_by_imm;
logic        opcode_SHRD_reg_mem_by_CL;
logic        opcode_AND_reg_to_mem;
logic        opcode_AND_mem_to_reg;
logic        opcode_AND_imm_to_reg_mem;
logic        opcode_AND_imm_to_acc;
logic        opcode_TEST_reg_mem_and_reg;
logic        opcode_TEST_imm_to_reg_mem;
logic        opcode_TEST_imm_to_acc;
logic        opcode_OR_reg_to_mem;
logic        opcode_OR_mem_to_reg;
logic        opcode_OR_imm_to_reg_mem;
logic        opcode_OR_imm_to_acc;
logic        opcode_XOR_reg_to_mem;
logic        opcode_XOR_mem_to_reg;
logic        opcode_XOR_imm_to_reg_mem;
logic        opcode_XOR_imm_to_acc;
logic        opcode_NOT;
logic        opcode_CMPS;
logic        opcode_INS;
logic        opcode_LODS;
logic        opcode_MOVS;
logic        opcode_OUTS;
logic        opcode_SCAS;
logic        opcode_STOS;
logic        opcode_XLAT;
logic        opcode_REPE;
logic        opcode_REPNE;
logic        opcode_BSF;
logic        opcode_BSR;
logic        opcode_BT_reg_mem_with_imm;
logic        opcode_BT_reg_mem_with_reg;
logic        opcode_BTC_reg_mem_with_imm;
logic        opcode_BTC_reg_mem_with_reg;
logic        opcode_BTR_reg_mem_with_imm;
logic        opcode_BTR_reg_mem_with_reg;
logic        opcode_BTS_reg_mem_with_imm;
logic        opcode_BTS_reg_mem_with_reg;
logic        opcode_CALL_direct_within_segment;
logic        opcode_CALL_indirect_within_segment;
logic        opcode_CALL_direct_intersegment;
logic        opcode_CALL_indirect_intersegment;
logic        opcode_JMP_short;
logic        opcode_JMP_direct_within_segment;
logic        opcode_JMP_indirect_within_segment;
logic        opcode_JMP_direct_intersegment;
logic        opcode_JMP_indirect_intersegment;
logic        opcode_RET_within_segment;
logic        opcode_RET_within_segment_adding_imm_to_SP;
logic        opcode_RET_intersegment;
logic        opcode_RET_intersegment_adding_imm_to_SP;
logic        opcode_JO_8bit_disp;
logic        opcode_JO_full_disp;
logic        opcode_JNO_8bit_disp;
logic        opcode_JNO_full_disp;
logic        opcode_JB_8bit_disp;
logic        opcode_JB_full_disp;
logic        opcode_JNB_8bit_disp;
logic        opcode_JNB_full_disp;
logic        opcode_JE_8bit_disp;
logic        opcode_JE_full_disp;
logic        opcode_JNE_8bit_disp;
logic        opcode_JNE_full_disp;
logic        opcode_JBE_8bit_disp;
logic        opcode_JBE_full_disp;
logic        opcode_JNBE_8bit_disp;
logic        opcode_JNBE_full_disp;
logic        opcode_JS_8bit_disp;
logic        opcode_JS_full_disp;
logic        opcode_JNS_8bit_disp;
logic        opcode_JNS_full_disp;
logic        opcode_JP_8bit_disp;
logic        opcode_JP_full_disp;
logic        opcode_JNP_8bit_disp;
logic        opcode_JNP_full_disp;
logic        opcode_JL_8bit_disp;
logic        opcode_JL_full_disp;
logic        opcode_JNL_8bit_disp;
logic        opcode_JNL_full_disp;
logic        opcode_JLE_8bit_disp;
logic        opcode_JLE_full_disp;
logic        opcode_JNLE_8bit_disp;
logic        opcode_JNLE_full_disp;
logic        opcode_JCXZ;
logic        opcode_LOOP;
logic        opcode_LOOPZ;
logic        opcode_LOOPNZ;
logic        opcode_SETO;
logic        opcode_SETNO;
logic        opcode_SETB;
logic        opcode_SETNB;
logic        opcode_SETE;
logic        opcode_SETNE;
logic        opcode_SETBE;
logic        opcode_SETNBE;
logic        opcode_SETS;
logic        opcode_SETNS;
logic        opcode_SETP;
logic        opcode_SETNP;
logic        opcode_SETL;
logic        opcode_SETNL;
logic        opcode_SETLE;
logic        opcode_SETNLE;
logic        opcode_ENTER;
logic        opcode_LEAVE;
logic        opcode_INT_type_3;
logic        opcode_INT_type_specified;
logic        opcode_INTO;
logic        opcode_BOUND;
logic        opcode_IRET;
logic        opcode_HLT;
logic        opcode_MOV_CR0_CR2_CR3_from_reg;
logic        opcode_MOV_reg_from_CR0_3;
logic        opcode_MOV_DR0_7_from_reg;
logic        opcode_MOV_reg_from_DR0_7;
logic        opcode_MOV_TR6_7_from_reg;
logic        opcode_MOV_reg_from_TR6_7;
logic        opcode_NOP;
logic        opcode_WAIT;
logic        opcode_processor_extension_escape;
logic        opcode_prefix_address_size;
logic        opcode_prefix_bus_lock;
logic        opcode_prefix_operand_size;
logic        opcode_prefix_segment_override_CS;
logic        opcode_prefix_segment_override_DS;
logic        opcode_prefix_segment_override_ES;
logic        opcode_prefix_segment_override_FS;
logic        opcode_prefix_segment_override_GS;
logic        opcode_prefix_segment_override_SS;
logic        opcode_ARPL;
logic        opcode_LAR;
logic        opcode_LGDT;
logic        opcode_LIDT;
logic        opcode_LLDT;
logic        opcode_LMSW;
logic        opcode_LSL;
logic        opcode_LTR;
logic        opcode_SGDT;
logic        opcode_SIDT;
logic        opcode_SLDT;
logic        opcode_SMSW;
logic        opcode_STR;
logic        opcode_VERR;
logic        opcode_VERW;
decode u_decode (
    .opcode_MOV_reg_to_reg_mem ( opcode_MOV_reg_to_reg_mem ),
    .opcode_MOV_reg_mem_to_reg ( opcode_MOV_reg_mem_to_reg ),
    .opcode_MOV_imm_to_reg_mem ( opcode_MOV_imm_to_reg_mem ),
    .opcode_MOV_imm_to_reg_short ( opcode_MOV_imm_to_reg_short ),
    .opcode_MOV_mem_to_acc ( opcode_MOV_mem_to_acc ),
    .opcode_MOV_acc_to_mem ( opcode_MOV_acc_to_mem ),
    .opcode_MOV_reg_mem_to_sreg ( opcode_MOV_reg_mem_to_sreg ),
    .opcode_MOV_sreg_to_reg_mem ( opcode_MOV_sreg_to_reg_mem ),
    .opcode_MOVSX ( opcode_MOVSX ),
    .opcode_MOVZX ( opcode_MOVZX ),
    .opcode_PUSH_reg_mem ( opcode_PUSH_reg_mem ),
    .opcode_PUSH_reg_short ( opcode_PUSH_reg_short ),
    .opcode_PUSH_sreg_2 ( opcode_PUSH_sreg_2 ),
    .opcode_PUSH_sreg_3 ( opcode_PUSH_sreg_3 ),
    .opcode_PUSH_imm ( opcode_PUSH_imm ),
    .opcode_PUSH_all ( opcode_PUSH_all ),
    .opcode_POP_reg_mem ( opcode_POP_reg_mem ),
    .opcode_POP_reg_short ( opcode_POP_reg_short ),
    .opcode_POP_sreg_2 ( opcode_POP_sreg_2 ),
    .opcode_POP_sreg_3 ( opcode_POP_sreg_3 ),
    .opcode_POP_all ( opcode_POP_all ),
    .opcode_XCHG_reg_mem_with_reg ( opcode_XCHG_reg_mem_with_reg ),
    .opcode_XCHG_reg_with_acc_short ( opcode_XCHG_reg_with_acc_short ),
    .opcode_IN_port_fixed ( opcode_IN_port_fixed ),
    .opcode_IN_port_variable ( opcode_IN_port_variable ),
    .opcode_OUT_port_fixed ( opcode_OUT_port_fixed ),
    .opcode_OUT_port_variable ( opcode_OUT_port_variable ),
    .opcode_LEA_load_ea_to_reg ( opcode_LEA_load_ea_to_reg ),
    .opcode_LDS_load_ptr_to_DS ( opcode_LDS_load_ptr_to_DS ),
    .opcode_LES_load_ptr_to_ES ( opcode_LES_load_ptr_to_ES ),
    .opcode_LFS_load_ptr_to_FS ( opcode_LFS_load_ptr_to_FS ),
    .opcode_LGS_load_ptr_to_GS ( opcode_LGS_load_ptr_to_GS ),
    .opcode_LSS_load_ptr_to_SS ( opcode_LSS_load_ptr_to_SS ),
    .opcode_CLC_clear_carry_flag ( opcode_CLC_clear_carry_flag ),
    .opcode_CLD_clear_direction_flag ( opcode_CLD_clear_direction_flag ),
    .opcode_CLI_clear_interrupt_enable_flag ( opcode_CLI_clear_interrupt_enable_flag ),
    .opcode_CLTS_clear_task_switched_flag ( opcode_CLTS_clear_task_switched_flag ),
    .opcode_CMC_complement_carry_flag ( opcode_CMC_complement_carry_flag ),
    .opcode_LAHF_load_ah_into_flag ( opcode_LAHF_load_ah_into_flag ),
    .opcode_POPF_pop_flags ( opcode_POPF_pop_flags ),
    .opcode_PUSHF_push_flags ( opcode_PUSHF_push_flags ),
    .opcode_SAHF_store_ah_into_flag ( opcode_SAHF_store_ah_into_flag ),
    .opcode_STC_set_carry_flag ( opcode_STC_set_carry_flag ),
    .opcode_STD_set_direction_flag ( opcode_STD_set_direction_flag ),
    .opcode_STI_set_interrupt_enable_flag ( opcode_STI_set_interrupt_enable_flag ),
    .opcode_ADD_reg_to_mem ( opcode_ADD_reg_to_mem ),
    .opcode_ADD_mem_to_reg ( opcode_ADD_mem_to_reg ),
    .opcode_ADD_imm_to_reg_mem ( opcode_ADD_imm_to_reg_mem ),
    .opcode_ADD_imm_to_acc ( opcode_ADD_imm_to_acc ),
    .opcode_ADC_reg_to_mem ( opcode_ADC_reg_to_mem ),
    .opcode_ADC_mem_to_reg ( opcode_ADC_mem_to_reg ),
    .opcode_ADC_imm_to_reg_mem ( opcode_ADC_imm_to_reg_mem ),
    .opcode_ADC_imm_to_acc ( opcode_ADC_imm_to_acc ),
    .opcode_INC_reg_mem ( opcode_INC_reg_mem ),
    .opcode_INC_reg ( opcode_INC_reg ),
    .opcode_SUB_reg_to_mem ( opcode_SUB_reg_to_mem ),
    .opcode_SUB_mem_to_reg ( opcode_SUB_mem_to_reg ),
    .opcode_SUB_imm_to_reg_mem ( opcode_SUB_imm_to_reg_mem ),
    .opcode_SUB_imm_to_acc ( opcode_SUB_imm_to_acc ),
    .opcode_SBB_reg_to_mem ( opcode_SBB_reg_to_mem ),
    .opcode_SBB_mem_to_reg ( opcode_SBB_mem_to_reg ),
    .opcode_SBB_imm_to_reg_mem ( opcode_SBB_imm_to_reg_mem ),
    .opcode_SBB_imm_to_acc ( opcode_SBB_imm_to_acc ),
    .opcode_DEC_reg_mem ( opcode_DEC_reg_mem ),
    .opcode_DEC_reg ( opcode_DEC_reg ),
    .opcode_CMP_mem_with_reg ( opcode_CMP_mem_with_reg ),
    .opcode_CMP_reg_with_mem ( opcode_CMP_reg_with_mem ),
    .opcode_CMP_imm_with_reg_mem ( opcode_CMP_imm_with_reg_mem ),
    .opcode_CMP_imm_with_acc ( opcode_CMP_imm_with_acc ),
    .opcode_NEG_change_sign ( opcode_NEG_change_sign ),
    .opcode_AAA ( opcode_AAA ),
    .opcode_AAS ( opcode_AAS ),
    .opcode_DAA ( opcode_DAA ),
    .opcode_DAS ( opcode_DAS ),
    .opcode_MUL_acc_with_reg_mem ( opcode_MUL_acc_with_reg_mem ),
    .opcode_IMUL_acc_with_reg_mem ( opcode_IMUL_acc_with_reg_mem ),
    .opcode_IMUL_reg_with_reg_mem ( opcode_IMUL_reg_with_reg_mem ),
    .opcode_IMUL_reg_mem_with_imm_to_reg ( opcode_IMUL_reg_mem_with_imm_to_reg ),
    .opcode_DIV_acc_by_reg_mem ( opcode_DIV_acc_by_reg_mem ),
    .opcode_IDIV_acc_by_reg_mem ( opcode_IDIV_acc_by_reg_mem ),
    .opcode_AAD ( opcode_AAD ),
    .opcode_AAM ( opcode_AAM ),
    .opcode_CBW ( opcode_CBW ),
    .opcode_CWD ( opcode_CWD ),
    .opcode_ROL_reg_mem_by_1 ( opcode_ROL_reg_mem_by_1 ),
    .opcode_ROL_reg_mem_by_CL ( opcode_ROL_reg_mem_by_CL ),
    .opcode_ROL_reg_mem_by_imm ( opcode_ROL_reg_mem_by_imm ),
    .opcode_ROR_reg_mem_by_1 ( opcode_ROR_reg_mem_by_1 ),
    .opcode_ROR_reg_mem_by_CL ( opcode_ROR_reg_mem_by_CL ),
    .opcode_ROR_reg_mem_by_imm ( opcode_ROR_reg_mem_by_imm ),
    .opcode_SHL_reg_mem_by_1 ( opcode_SHL_reg_mem_by_1 ),
    .opcode_SHL_reg_mem_by_CL ( opcode_SHL_reg_mem_by_CL ),
    .opcode_SHL_reg_mem_by_imm ( opcode_SHL_reg_mem_by_imm ),
    .opcode_SAR_reg_mem_by_1 ( opcode_SAR_reg_mem_by_1 ),
    .opcode_SAR_reg_mem_by_CL ( opcode_SAR_reg_mem_by_CL ),
    .opcode_SAR_reg_mem_by_imm ( opcode_SAR_reg_mem_by_imm ),
    .opcode_SHR_reg_mem_by_1 ( opcode_SHR_reg_mem_by_1 ),
    .opcode_SHR_reg_mem_by_CL ( opcode_SHR_reg_mem_by_CL ),
    .opcode_SHR_reg_mem_by_imm ( opcode_SHR_reg_mem_by_imm ),
    .opcode_RCL_reg_mem_by_1 ( opcode_RCL_reg_mem_by_1 ),
    .opcode_RCL_reg_mem_by_CL ( opcode_RCL_reg_mem_by_CL ),
    .opcode_RCL_reg_mem_by_imm ( opcode_RCL_reg_mem_by_imm ),
    .opcode_RCR_reg_mem_by_1 ( opcode_RCR_reg_mem_by_1 ),
    .opcode_RCR_reg_mem_by_CL ( opcode_RCR_reg_mem_by_CL ),
    .opcode_RCR_reg_mem_by_imm ( opcode_RCR_reg_mem_by_imm ),
    .opcode_SHLD_reg_mem_by_imm ( opcode_SHLD_reg_mem_by_imm ),
    .opcode_SHLD_reg_mem_by_CL ( opcode_SHLD_reg_mem_by_CL ),
    .opcode_SHRD_reg_mem_by_imm ( opcode_SHRD_reg_mem_by_imm ),
    .opcode_SHRD_reg_mem_by_CL ( opcode_SHRD_reg_mem_by_CL ),
    .opcode_AND_reg_to_mem ( opcode_AND_reg_to_mem ),
    .opcode_AND_mem_to_reg ( opcode_AND_mem_to_reg ),
    .opcode_AND_imm_to_reg_mem ( opcode_AND_imm_to_reg_mem ),
    .opcode_AND_imm_to_acc ( opcode_AND_imm_to_acc ),
    .opcode_TEST_reg_mem_and_reg ( opcode_TEST_reg_mem_and_reg ),
    .opcode_TEST_imm_to_reg_mem ( opcode_TEST_imm_to_reg_mem ),
    .opcode_TEST_imm_to_acc ( opcode_TEST_imm_to_acc ),
    .opcode_OR_reg_to_mem ( opcode_OR_reg_to_mem ),
    .opcode_OR_mem_to_reg ( opcode_OR_mem_to_reg ),
    .opcode_OR_imm_to_reg_mem ( opcode_OR_imm_to_reg_mem ),
    .opcode_OR_imm_to_acc ( opcode_OR_imm_to_acc ),
    .opcode_XOR_reg_to_mem ( opcode_XOR_reg_to_mem ),
    .opcode_XOR_mem_to_reg ( opcode_XOR_mem_to_reg ),
    .opcode_XOR_imm_to_reg_mem ( opcode_XOR_imm_to_reg_mem ),
    .opcode_XOR_imm_to_acc ( opcode_XOR_imm_to_acc ),
    .opcode_NOT ( opcode_NOT ),
    .opcode_CMPS ( opcode_CMPS ),
    .opcode_INS ( opcode_INS ),
    .opcode_LODS ( opcode_LODS ),
    .opcode_MOVS ( opcode_MOVS ),
    .opcode_OUTS ( opcode_OUTS ),
    .opcode_SCAS ( opcode_SCAS ),
    .opcode_STOS ( opcode_STOS ),
    .opcode_XLAT ( opcode_XLAT ),
    .opcode_REPE ( opcode_REPE ),
    .opcode_REPNE ( opcode_REPNE ),
    .opcode_BSF ( opcode_BSF ),
    .opcode_BSR ( opcode_BSR ),
    .opcode_BT_reg_mem_with_imm ( opcode_BT_reg_mem_with_imm ),
    .opcode_BT_reg_mem_with_reg ( opcode_BT_reg_mem_with_reg ),
    .opcode_BTC_reg_mem_with_imm ( opcode_BTC_reg_mem_with_imm ),
    .opcode_BTC_reg_mem_with_reg ( opcode_BTC_reg_mem_with_reg ),
    .opcode_BTR_reg_mem_with_imm ( opcode_BTR_reg_mem_with_imm ),
    .opcode_BTR_reg_mem_with_reg ( opcode_BTR_reg_mem_with_reg ),
    .opcode_BTS_reg_mem_with_imm ( opcode_BTS_reg_mem_with_imm ),
    .opcode_BTS_reg_mem_with_reg ( opcode_BTS_reg_mem_with_reg ),
    .opcode_CALL_direct_within_segment ( opcode_CALL_direct_within_segment ),
    .opcode_CALL_indirect_within_segment ( opcode_CALL_indirect_within_segment ),
    .opcode_CALL_direct_intersegment ( opcode_CALL_direct_intersegment ),
    .opcode_CALL_indirect_intersegment ( opcode_CALL_indirect_intersegment ),
    .opcode_JMP_short ( opcode_JMP_short ),
    .opcode_JMP_direct_within_segment ( opcode_JMP_direct_within_segment ),
    .opcode_JMP_indirect_within_segment ( opcode_JMP_indirect_within_segment ),
    .opcode_JMP_direct_intersegment ( opcode_JMP_direct_intersegment ),
    .opcode_JMP_indirect_intersegment ( opcode_JMP_indirect_intersegment ),
    .opcode_RET_within_segment ( opcode_RET_within_segment ),
    .opcode_RET_within_segment_adding_imm_to_SP ( opcode_RET_within_segment_adding_imm_to_SP ),
    .opcode_RET_intersegment ( opcode_RET_intersegment ),
    .opcode_RET_intersegment_adding_imm_to_SP ( opcode_RET_intersegment_adding_imm_to_SP ),
    .opcode_JO_8bit_disp ( opcode_JO_8bit_disp ),
    .opcode_JO_full_disp ( opcode_JO_full_disp ),
    .opcode_JNO_8bit_disp ( opcode_JNO_8bit_disp ),
    .opcode_JNO_full_disp ( opcode_JNO_full_disp ),
    .opcode_JB_8bit_disp ( opcode_JB_8bit_disp ),
    .opcode_JB_full_disp ( opcode_JB_full_disp ),
    .opcode_JNB_8bit_disp ( opcode_JNB_8bit_disp ),
    .opcode_JNB_full_disp ( opcode_JNB_full_disp ),
    .opcode_JE_8bit_disp ( opcode_JE_8bit_disp ),
    .opcode_JE_full_disp ( opcode_JE_full_disp ),
    .opcode_JNE_8bit_disp ( opcode_JNE_8bit_disp ),
    .opcode_JNE_full_disp ( opcode_JNE_full_disp ),
    .opcode_JBE_8bit_disp ( opcode_JBE_8bit_disp ),
    .opcode_JBE_full_disp ( opcode_JBE_full_disp ),
    .opcode_JNBE_8bit_disp ( opcode_JNBE_8bit_disp ),
    .opcode_JNBE_full_disp ( opcode_JNBE_full_disp ),
    .opcode_JS_8bit_disp ( opcode_JS_8bit_disp ),
    .opcode_JS_full_disp ( opcode_JS_full_disp ),
    .opcode_JNS_8bit_disp ( opcode_JNS_8bit_disp ),
    .opcode_JNS_full_disp ( opcode_JNS_full_disp ),
    .opcode_JP_8bit_disp ( opcode_JP_8bit_disp ),
    .opcode_JP_full_disp ( opcode_JP_full_disp ),
    .opcode_JNP_8bit_disp ( opcode_JNP_8bit_disp ),
    .opcode_JNP_full_disp ( opcode_JNP_full_disp ),
    .opcode_JL_8bit_disp ( opcode_JL_8bit_disp ),
    .opcode_JL_full_disp ( opcode_JL_full_disp ),
    .opcode_JNL_8bit_disp ( opcode_JNL_8bit_disp ),
    .opcode_JNL_full_disp ( opcode_JNL_full_disp ),
    .opcode_JLE_8bit_disp ( opcode_JLE_8bit_disp ),
    .opcode_JLE_full_disp ( opcode_JLE_full_disp ),
    .opcode_JNLE_8bit_disp ( opcode_JNLE_8bit_disp ),
    .opcode_JNLE_full_disp ( opcode_JNLE_full_disp ),
    .opcode_JCXZ ( opcode_JCXZ ),
    .opcode_LOOP ( opcode_LOOP ),
    .opcode_LOOPZ ( opcode_LOOPZ ),
    .opcode_LOOPNZ ( opcode_LOOPNZ ),
    .opcode_SETO ( opcode_SETO ),
    .opcode_SETNO ( opcode_SETNO ),
    .opcode_SETB ( opcode_SETB ),
    .opcode_SETNB ( opcode_SETNB ),
    .opcode_SETE ( opcode_SETE ),
    .opcode_SETNE ( opcode_SETNE ),
    .opcode_SETBE ( opcode_SETBE ),
    .opcode_SETNBE ( opcode_SETNBE ),
    .opcode_SETS ( opcode_SETS ),
    .opcode_SETNS ( opcode_SETNS ),
    .opcode_SETP ( opcode_SETP ),
    .opcode_SETNP ( opcode_SETNP ),
    .opcode_SETL ( opcode_SETL ),
    .opcode_SETNL ( opcode_SETNL ),
    .opcode_SETLE ( opcode_SETLE ),
    .opcode_SETNLE ( opcode_SETNLE ),
    .opcode_ENTER ( opcode_ENTER ),
    .opcode_LEAVE ( opcode_LEAVE ),
    .opcode_INT_type_3 ( opcode_INT_type_3 ),
    .opcode_INT_type_specified ( opcode_INT_type_specified ),
    .opcode_INTO ( opcode_INTO ),
    .opcode_BOUND ( opcode_BOUND ),
    .opcode_IRET ( opcode_IRET ),
    .opcode_HLT ( opcode_HLT ),
    .opcode_MOV_CR0_CR2_CR3_from_reg ( opcode_MOV_CR0_CR2_CR3_from_reg ),
    .opcode_MOV_reg_from_CR0_3 ( opcode_MOV_reg_from_CR0_3 ),
    .opcode_MOV_DR0_7_from_reg ( opcode_MOV_DR0_7_from_reg ),
    .opcode_MOV_reg_from_DR0_7 ( opcode_MOV_reg_from_DR0_7 ),
    .opcode_MOV_TR6_7_from_reg ( opcode_MOV_TR6_7_from_reg ),
    .opcode_MOV_reg_from_TR6_7 ( opcode_MOV_reg_from_TR6_7 ),
    .opcode_NOP ( opcode_NOP ),
    .opcode_WAIT ( opcode_WAIT ),
    .opcode_processor_extension_escape ( opcode_processor_extension_escape ),
    .opcode_prefix_address_size ( opcode_prefix_address_size ),
    .opcode_prefix_bus_lock ( opcode_prefix_bus_lock ),
    .opcode_prefix_operand_size ( opcode_prefix_operand_size ),
    .opcode_prefix_segment_override_CS ( opcode_prefix_segment_override_CS ),
    .opcode_prefix_segment_override_DS ( opcode_prefix_segment_override_DS ),
    .opcode_prefix_segment_override_ES ( opcode_prefix_segment_override_ES ),
    .opcode_prefix_segment_override_FS ( opcode_prefix_segment_override_FS ),
    .opcode_prefix_segment_override_GS ( opcode_prefix_segment_override_GS ),
    .opcode_prefix_segment_override_SS ( opcode_prefix_segment_override_SS ),
    .opcode_ARPL ( opcode_ARPL ),
    .opcode_LAR ( opcode_LAR ),
    .opcode_LGDT ( opcode_LGDT ),
    .opcode_LIDT ( opcode_LIDT ),
    .opcode_LLDT ( opcode_LLDT ),
    .opcode_LMSW ( opcode_LMSW ),
    .opcode_LSL ( opcode_LSL ),
    .opcode_LTR ( opcode_LTR ),
    .opcode_SGDT ( opcode_SGDT ),
    .opcode_SIDT ( opcode_SIDT ),
    .opcode_SLDT ( opcode_SLDT ),
    .opcode_SMSW ( opcode_SMSW ),
    .opcode_STR ( opcode_STR ),
    .opcode_VERR ( opcode_VERR ),
    .opcode_VERW ( opcode_VERW ),
    // .bit_width ( bit_width ),
    .instruction ( instruction )
);

endmodule
