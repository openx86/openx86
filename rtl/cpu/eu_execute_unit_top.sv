// ============================================================================
// eu_execute_unit_top — AGU / LSU / Branch / MulDiv / X87 子模块聚合顶层
// 译码/微码侧通过选择信号驱动各簇；此处为直连端口便于 SoC 集成
// ============================================================================

module eu_execute_unit_top (
    input logic clk,
    input logic rst,

    // --- AGU ---
    input  logic [31:0] i_agu_base,
    input  logic [31:0] i_agu_index,
    input  logic [ 1:0] i_agu_scale,
    input  logic [31:0] i_agu_disp,
    output logic [31:0] o_agu_effective_addr,

    // --- LSU ---
    input  logic        i_lsu_start,
    input  logic        i_lsu_is_store,
    input  logic [31:0] i_lsu_addr,
    input  logic [31:0] i_lsu_wdata,
    output logic [31:0] o_lsu_rdata,
    output logic        o_lsu_done,
    output logic        o_lsu_busy,
    output logic        o_lsu_mem_valid,
    output logic        o_lsu_mem_we,
    output logic [31:0] o_lsu_mem_addr,
    output logic [31:0] o_lsu_mem_wdata,
    input  logic [31:0] i_lsu_mem_rdata,
    input  logic        i_lsu_mem_ready,

    // --- Branch ---
    input  logic        i_br_is_jcc,
    input  logic [ 3:0] i_br_jcc_nibble,
    input  logic        i_br_CF,
    input  logic        i_br_PF,
    input  logic        i_br_ZF,
    input  logic        i_br_SF,
    input  logic        i_br_OF,
    input  logic [31:0] i_br_eip,
    input  logic [31:0] i_br_rel32,
    input  logic signed [7:0] i_br_rel8,
    input  logic        i_br_use_rel8,
    output logic        o_br_taken,
    output logic [31:0] o_br_target_eip,

    // --- Mul/Div ---
    input  logic [2:0]  i_md_op,
    input  logic [31:0] i_md_lo,
    input  logic [31:0] i_md_hi,
    input  logic [31:0] i_md_src,
    output logic [31:0] o_md_lo,
    output logic [31:0] o_md_hi,
    output logic        o_md_div0,

    // --- X87 ---
    input  logic        i_x87_valid,
    input  logic [ 4:0] i_x87_op,
    input  logic [63:0] i_x87_push_data,
    input  logic [ 2:0] i_x87_st_src,
    output logic [63:0] o_x87_st0,
    output logic [63:0] o_x87_st1,
    output logic        o_x87_zf,
    output logic        o_x87_pf,
    output logic        o_x87_cf
);

    eu_address_generation_unit u_agu (
        .i_base              ( i_agu_base ),
        .i_index             ( i_agu_index ),
        .i_scale             ( i_agu_scale ),
        .i_disp              ( i_agu_disp ),
        .o_effective_address ( o_agu_effective_addr )
    );

    eu_load_store_unit u_lsu (
        .clk          ( clk ),
        .rst          ( rst ),
        .i_start      ( i_lsu_start ),
        .i_is_store   ( i_lsu_is_store ),
        .i_addr       ( i_lsu_addr ),
        .i_wdata      ( i_lsu_wdata ),
        .o_rdata      ( o_lsu_rdata ),
        .o_done       ( o_lsu_done ),
        .o_busy       ( o_lsu_busy ),
        .o_mem_valid  ( o_lsu_mem_valid ),
        .o_mem_we     ( o_lsu_mem_we ),
        .o_mem_addr   ( o_lsu_mem_addr ),
        .o_mem_wdata  ( o_lsu_mem_wdata ),
        .i_mem_rdata  ( i_lsu_mem_rdata ),
        .i_mem_ready  ( i_lsu_mem_ready )
    );

    eu_execute_branch_unit u_br (
        .i_is_jcc      ( i_br_is_jcc ),
        .i_jcc_nibble  ( i_br_jcc_nibble ),
        .i_CF          ( i_br_CF ),
        .i_PF          ( i_br_PF ),
        .i_ZF          ( i_br_ZF ),
        .i_SF          ( i_br_SF ),
        .i_OF          ( i_br_OF ),
        .i_eip         ( i_br_eip ),
        .i_rel32       ( i_br_rel32 ),
        .i_rel8        ( i_br_rel8 ),
        .i_use_rel8    ( i_br_use_rel8 ),
        .o_taken       ( o_br_taken ),
        .o_target_eip  ( o_br_target_eip )
    );

    eu_execute_muldiv_unit u_md (
        .i_op   ( i_md_op ),
        .i_lo   ( i_md_lo ),
        .i_hi   ( i_md_hi ),
        .i_src  ( i_md_src ),
        .o_lo   ( o_md_lo ),
        .o_hi   ( o_md_hi ),
        .o_div0 ( o_md_div0 )
    );

    eu_execute_x87_fpu u_x87 (
        .clk         ( clk ),
        .rst         ( rst ),
        .i_valid     ( i_x87_valid ),
        .i_op        ( i_x87_op ),
        .i_push_data ( i_x87_push_data ),
        .i_st_src    ( i_x87_st_src ),
        .o_st0       ( o_x87_st0 ),
        .o_st1       ( o_x87_st1 ),
        .o_zf        ( o_x87_zf ),
        .o_pf        ( o_x87_pf ),
        .o_cf        ( o_x87_cf )
    );

endmodule
