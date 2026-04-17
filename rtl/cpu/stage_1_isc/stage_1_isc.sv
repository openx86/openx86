/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements stage_1_isc.
*/
// ============================================================================
// stage_1_isc
// ----------------------------------------------------------------------------
// Stage 1 (ISC / instruction fetch): wraps instruction fetch + MMU translation.
// ============================================================================

module stage_1_isc (
    output logic        o_code_vaild,
    input  logic        i_code_ready,
    output logic [31:  0] o_code_address,
    input  logic [31:  0] i_code_data_read,

    output logic        o_mmu_bus_vaild,
    input  logic        i_mmu_bus_ready,
    output logic [31:  0] o_mmu_bus_addr,
    input  logic [31:  0] i_mmu_bus_rdata,

    input  logic        i_protected_mode,
    input  logic [15:  0] i_segment_selector [ 0:  5],
    input  logic [63:  0] i_segment_descriptor [ 0:  5],
    input  logic [ 1:  0]  i_current_privilege_level,
    input  logic        i_paging_enable,
    input  logic [31:  0] i_page_directory_base,
    input  logic        i_IP_vaild,

    output logic [ 7:  0]  o_instruction [ 0: 15],
    output logic        o_instruction_ready,
    output logic        o_segment_fault,

    input  logic [31:  0] EIP,
    input  logic        reset_n,
    input  logic        clock);

    stage_1_isc_if_instruction_fetch u_if_instruction_fetch (
        .o_code_vaild              ( o_code_vaild ),
        .i_code_ready              ( i_code_ready ),
        .o_code_address            ( o_code_address ),
        .i_code_data_read          ( i_code_data_read ),
        .o_mmu_bus_vaild           ( o_mmu_bus_vaild ),
        .i_mmu_bus_ready           ( i_mmu_bus_ready ),
        .o_mmu_bus_addr            ( o_mmu_bus_addr ),
        .i_mmu_bus_rdata           ( i_mmu_bus_rdata ),
        .i_protected_mode          ( i_protected_mode ),
        .i_segment_selector        ( i_segment_selector ),
        .i_segment_descriptor      ( i_segment_descriptor ),
        .i_current_privilege_level ( i_current_privilege_level ),
        .i_paging_enable           ( i_paging_enable ),
        .i_page_directory_base     ( i_page_directory_base ),
        .i_IP_vaild                ( i_IP_vaild ),
        .o_instruction             ( o_instruction ),
        .o_instruction_ready       ( o_instruction_ready ),
        .o_segment_fault           ( o_segment_fault ),
        .EIP                       ( EIP ),
        .clock                     ( clock ),
        .reset_n                     ( reset_n )
    );

endmodule
