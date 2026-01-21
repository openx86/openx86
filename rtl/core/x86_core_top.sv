// ============================================================================
// x86 core top (minimal bring-up pipeline)
// fetch -> decode -> microcode -> execute -> writeback
// - Implements real mode and a protected-mode address-forming hook (CR0.PE + CS.base)
// - For now: executes only MOV r32,imm32 / ADD EAX,imm32 / HLT
// - clock/reset at end of port list
// ============================================================================

`include "rtl/core/x86_types.sv"

module x86_core_top (
    // external bus (compatible with rtl/bus.sv)
    output logic        o_bus_valid,
    input  logic        i_bus_ready,
    input  logic        i_bus_busy,
    output logic        o_bus_write_enable,
    output logic        o_bus_io_access,
    output logic [31:0] o_bus_address,
    input  logic [31:0] i_bus_data_read,
    output logic [31:0] o_bus_data_write,

    // minimal control for demo
    input  logic        i_cr0_we,
    input  logic [31:0] i_cr0_wdata,

    input  logic        i_clock,
    input  logic        i_reset
);

    // ------------------------------------------------------------------------
    // Control regs
    // ------------------------------------------------------------------------
    logic [31:0] cr0;
    logic protected_mode;
    x86_control_regs u_ctrl (
        .i_cr0_we         ( i_cr0_we ),
        .i_cr0_wdata      ( i_cr0_wdata ),
        .o_cr0            ( cr0 ),
        .o_protected_mode ( protected_mode ),
        .i_clock          ( i_clock ),
        .i_reset          ( i_reset )
    );

    // Minimal CS state: real mode starts at F000:FFF0 like classic x86 reset
    logic [15:0] cs;
    logic [31:0] cs_base;
    logic [31:0] eip;
    always_ff @(posedge i_clock or posedge i_reset) begin
        if (i_reset) begin
            cs      <= 16'hF000;
            cs_base <= 32'h000F_0000; // typical reset CS base
            eip     <= 32'h0000_FFF0;
        end
    end

    // ------------------------------------------------------------------------
    // Fetch
    // ------------------------------------------------------------------------
    logic pc_valid;
    logic [7:0] instr_bytes [0:15];
    logic instr_ready;
    logic [31:0] fetch_linear_base;

    always_ff @(posedge i_clock or posedge i_reset) begin
        if (i_reset) begin
            pc_valid <= 1'b1; // kick off first fetch after reset
        end else begin
            // request next fetch when previous instruction has been accepted
            if (instr_ready) pc_valid <= 1'b0;
            if (advance_ip)  pc_valid <= 1'b1;
        end
    end

    x86_fetch_unit u_fetch (
        .o_bus_valid        ( o_bus_valid ),
        .i_bus_ready        ( i_bus_ready ),
        .o_bus_write_enable ( o_bus_write_enable ),
        .o_bus_io_access    ( o_bus_io_access ),
        .o_bus_address      ( o_bus_address ),
        .i_bus_data_read    ( i_bus_data_read ),
        .o_bus_data_write   ( o_bus_data_write ),
        .i_pc_valid         ( pc_valid ),
        .i_eip              ( eip ),
        .i_cs               ( cs ),
        .i_cs_base          ( cs_base ),
        .i_protected_mode   ( protected_mode ),
        .o_instruction      ( instr_bytes ),
        .o_instr_ready      ( instr_ready ),
        .o_fetch_linear_base( fetch_linear_base ),
        .i_clock            ( i_clock ),
        .i_reset            ( i_reset )
    );

    // ------------------------------------------------------------------------
    // Decode
    // ------------------------------------------------------------------------
    x86_macro_op_t macro;
    logic macro_valid;
    x86_decode_unit u_decode (
        .i_instruction ( instr_bytes ),
        .i_instr_valid ( instr_ready ),
        .o_macro_valid ( macro_valid ),
        .o_macro       ( macro ),
        .i_clock       ( i_clock ),
        .i_reset       ( i_reset )
    );

    // ------------------------------------------------------------------------
    // Microcode
    // ------------------------------------------------------------------------
    x86_uop_t uop;
    logic uop_valid, uop_ready;
    x86_microcode_translate u_ucode (
        .i_macro_valid ( macro_valid ),
        .i_macro       ( macro ),
        .o_uop_valid   ( uop_valid ),
        .o_uop         ( uop ),
        .i_uop_ready   ( uop_ready ),
        .i_clock       ( i_clock ),
        .i_reset       ( i_reset )
    );

    // ------------------------------------------------------------------------
    // Regfile
    // ------------------------------------------------------------------------
    logic gpr_rd_en;
    logic [2:0] gpr_rd_idx;
    logic [31:0] gpr_rd_data;
    logic gpr_wr_en;
    logic [2:0] gpr_wr_idx;
    logic [31:0] gpr_wr_data;

    x86_gpr_file u_gpr (
        .i_rd0_en   ( gpr_rd_en ),
        .i_rd0_idx  ( gpr_rd_idx ),
        .o_rd0_data ( gpr_rd_data ),
        .i_rd1_en   ( 1'b0 ),
        .i_rd1_idx  ( 3'd0 ),
        .o_rd1_data ( ),
        .i_wr_en    ( gpr_wr_en ),
        .i_wr_idx   ( gpr_wr_idx ),
        .i_wr_data  ( gpr_wr_data ),
        .i_clock    ( i_clock ),
        .i_reset    ( i_reset )
    );

    // ------------------------------------------------------------------------
    // Execute
    // ------------------------------------------------------------------------
    logic wb_valid;
    logic [2:0] wb_gpr_idx;
    logic [31:0] wb_gpr_data;
    logic halted;

    x86_execute_unit u_exec (
        .i_uop_valid    ( uop_valid ),
        .i_uop          ( uop ),
        .o_uop_ready    ( uop_ready ),
        .o_gpr_rd_en    ( gpr_rd_en ),
        .o_gpr_rd_idx   ( gpr_rd_idx ),
        .i_gpr_rd_data  ( gpr_rd_data ),
        .o_wb_valid     ( wb_valid ),
        .o_wb_gpr_idx   ( wb_gpr_idx ),
        .o_wb_gpr_data  ( wb_gpr_data ),
        .o_halted       ( halted ),
        .i_clock        ( i_clock ),
        .i_reset        ( i_reset )
    );

    // ------------------------------------------------------------------------
    // Writeback
    // ------------------------------------------------------------------------
    x86_writeback_unit u_wb (
        .i_wb_valid    ( wb_valid ),
        .i_wb_gpr_idx  ( wb_gpr_idx ),
        .i_wb_gpr_data ( wb_gpr_data ),
        .o_gpr_wr_en   ( gpr_wr_en ),
        .o_gpr_wr_idx  ( gpr_wr_idx ),
        .o_gpr_wr_data ( gpr_wr_data ),
        .i_clock       ( i_clock ),
        .i_reset       ( i_reset )
    );

    // ------------------------------------------------------------------------
    // Retire/PC update (minimal: sequential EIP += macro.length)
    // ------------------------------------------------------------------------
    logic advance_ip;
    always_ff @(posedge i_clock or posedge i_reset) begin
        if (i_reset) begin
            advance_ip <= 1'b0;
        end else begin
            advance_ip <= 1'b0;
            if (macro_valid && !halted) begin
                eip <= eip + {{28{1'b0}}, macro.length};
                advance_ip <= 1'b1;
            end
        end
    end

    // i_bus_busy currently unused in this minimal core
    logic unused_busy;
    always_comb unused_busy = i_bus_busy;

endmodule

