// ============================================================================
//  Copyright (c) 2026 Chang Wei
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.
//
// ----------------------------------------------------------------------------
//  File        : dec_to_uop.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : Convert decoded macro-instruction to micro-op
// ============================================================================

`include "openx86_defs.h.sv"

module dec_to_uop (
    // =========================
    // Decoded macro-instruction inputs from stage_2_dec
    // =========================
    input  logic                i_opcode_aaa,
    input  logic                i_opcode_aad,
    input  logic                i_opcode_aam,
    input  logic                i_opcode_aas,
    input  logic                i_opcode_adc_reg_to_reg_mem,
    input  logic                i_opcode_adc_reg_mem_to_reg,
    input  logic                i_opcode_adc_imm_to_reg_mem,
    input  logic                i_opcode_adc_imm_to_acc,
    input  logic                i_opcode_add_reg_to_reg_mem,
    input  logic                i_opcode_add_reg_mem_to_reg,
    input  logic                i_opcode_add_imm_to_reg_mem,
    input  logic                i_opcode_add_imm_to_acc,
    input  logic                i_opcode_and_reg_to_reg_mem,
    input  logic                i_opcode_and_reg_mem_to_reg,
    input  logic                i_opcode_and_imm_to_reg_mem,
    input  logic                i_opcode_and_imm_to_acc,
    input  logic                i_opcode_arpl,
    input  logic                i_opcode_bound,
    input  logic                i_opcode_bsf,
    input  logic                i_opcode_bsr,
    input  logic                i_opcode_bswap,
    input  logic                i_opcode_bt_imm,
    input  logic                i_opcode_bt_reg,
    input  logic                i_opcode_btc_imm,
    input  logic                i_opcode_btc_reg,
    input  logic                i_opcode_btr_imm,
    input  logic                i_opcode_btr_reg,
    input  logic                i_opcode_bts_imm,
    input  logic                i_opcode_bts_reg,
    input  logic                i_opcode_call_near_direct,
    input  logic                i_opcode_call_near_indirect,
    input  logic                i_opcode_call_far_direct,
    input  logic                i_opcode_call_far_indirect,
    input  logic                i_opcode_cbw,
    input  logic                i_opcode_cdq,
    input  logic                i_opcode_clc,
    input  logic                i_opcode_cld,
    input  logic                i_opcode_cli,
    input  logic                i_opcode_clts,
    input  logic                i_opcode_cmc,
    input  logic                i_opcode_cmp_mem_reg,
    input  logic                i_opcode_cmp_reg_mem,
    input  logic                i_opcode_cmp_imm_reg_mem,
    input  logic                i_opcode_cmp_imm_acc,
    input  logic                i_opcode_cmps,
    input  logic                i_opcode_cmpxchg,
    input  logic                i_opcode_cpuid,
    input  logic                i_opcode_cwd,
    input  logic                i_opcode_cwde,
    input  logic                i_opcode_daa,
    input  logic                i_opcode_das,
    input  logic                i_opcode_dec_reg_mem,
    input  logic                i_opcode_dec_reg,
    input  logic                i_opcode_div,
    input  logic                i_opcode_hlt,
    input  logic                i_opcode_idiv,
    input  logic                i_opcode_imul_acc,
    input  logic                i_opcode_imul_reg,
    input  logic                i_opcode_imul_imm,
    input  logic                i_opcode_in_fixed,
    input  logic                i_opcode_in_var,
    input  logic                i_opcode_inc_reg_mem,
    input  logic                i_opcode_inc_reg,
    input  logic                i_opcode_ins,
    input  logic                i_opcode_int_n,
    input  logic                i_opcode_int_3,
    input  logic                i_opcode_int_4,
    input  logic                i_opcode_invd,
    input  logic                i_opcode_invlpg,
    input  logic                i_opcode_invpcid,
    input  logic                i_opcode_iret,
    input  logic                i_opcode_jcc_short,
    input  logic                i_opcode_jcc_near,
    input  logic                i_opcode_jcxz,
    input  logic                i_opcode_jmp_short,
    input  logic                i_opcode_jmp_near_direct,
    input  logic                i_opcode_jmp_near_indirect,
    input  logic                i_opcode_jmp_far_direct,
    input  logic                i_opcode_jmp_far_indirect,
    input  logic                i_opcode_lahf,
    input  logic                i_opcode_lar,
    input  logic                i_opcode_lds,
    input  logic                i_opcode_lea,
    input  logic                i_opcode_leave,
    input  logic                i_opcode_les,
    input  logic                i_opcode_lfs,
    input  logic                i_opcode_lgdt,
    input  logic                i_opcode_lgs,
    input  logic                i_opcode_lidt,
    input  logic                i_opcode_lldt,
    input  logic                i_opcode_lmsw,
    input  logic                i_opcode_lods,
    input  logic                i_opcode_loop,
    input  logic                i_opcode_loopz,
    input  logic                i_opcode_loopnz,
    input  logic                i_opcode_lsl,
    input  logic                i_opcode_lss,
    input  logic                i_opcode_ltr,
    input  logic                i_opcode_mov_reg_to_reg_mem,
    input  logic                i_opcode_mov_reg_mem_to_reg,
    input  logic                i_opcode_mov_imm_to_reg_mem,
    input  logic                i_opcode_mov_imm_to_reg,
    input  logic                i_opcode_mov_mem_to_acc,
    input  logic                i_opcode_mov_acc_to_mem,
    input  logic                i_opcode_mov_cr_from_reg,
    input  logic                i_opcode_mov_reg_from_cr,
    input  logic                i_opcode_mov_dr_from_reg,
    input  logic                i_opcode_mov_reg_from_dr,
    input  logic                i_opcode_mov_tr_from_reg,
    input  logic                i_opcode_mov_reg_from_tr,
    input  logic                i_opcode_mov_reg_mem_to_sreg,
    input  logic                i_opcode_mov_sreg_to_reg_mem,
    input  logic                i_opcode_movbe_mem_reg,
    input  logic                i_opcode_movbe_reg_mem,
    input  logic                i_opcode_movs,
    input  logic                i_opcode_movsx,
    input  logic                i_opcode_movzx,
    input  logic                i_opcode_mul,
    input  logic                i_opcode_neg,
    input  logic                i_opcode_nop,
    input  logic                i_opcode_nop_multibyte,
    input  logic                i_opcode_not,
    input  logic                i_opcode_or_reg_to_reg_mem,
    input  logic                i_opcode_or_reg_mem_to_reg,
    input  logic                i_opcode_or_imm_to_reg_mem,
    input  logic                i_opcode_or_imm_to_acc,
    input  logic                i_opcode_out_fixed,
    input  logic                i_opcode_out_var,
    input  logic                i_opcode_outs,
    input  logic                i_opcode_pop_reg_mem,
    input  logic                i_opcode_pop_reg,
    input  logic                i_opcode_pop_sreg_2,
    input  logic                i_opcode_pop_sreg_3,
    input  logic                i_opcode_popa,
    input  logic                i_opcode_popf,
    input  logic                i_opcode_push_reg_mem,
    input  logic                i_opcode_push_reg,
    input  logic                i_opcode_push_sreg_2,
    input  logic                i_opcode_push_sreg_3,
    input  logic                i_opcode_push_imm,
    input  logic                i_opcode_pusha,
    input  logic                i_opcode_pushf,
    input  logic                i_opcode_rcl_1,
    input  logic                i_opcode_rcl_cl,
    input  logic                i_opcode_rcl_imm,
    input  logic                i_opcode_rcr_1,
    input  logic                i_opcode_rcr_cl,
    input  logic                i_opcode_rcr_imm,
    input  logic                i_opcode_rdmsr,
    input  logic                i_opcode_rdpmc,
    input  logic                i_opcode_rdtsc,
    input  logic                i_opcode_rdtscp,
    input  logic                i_opcode_ret_near,
    input  logic                i_opcode_ret_near_imm,
    input  logic                i_opcode_ret_far,
    input  logic                i_opcode_ret_far_imm,
    input  logic                i_opcode_rol_1,
    input  logic                i_opcode_rol_cl,
    input  logic                i_opcode_rol_imm,
    input  logic                i_opcode_ror_1,
    input  logic                i_opcode_ror_cl,
    input  logic                i_opcode_ror_imm,
    input  logic                i_opcode_rsm,
    input  logic                i_opcode_sahf,
    input  logic                i_opcode_sar_1,
    input  logic                i_opcode_sar_cl,
    input  logic                i_opcode_sar_imm,
    input  logic                i_opcode_sbb_reg_to_reg_mem,
    input  logic                i_opcode_sbb_reg_mem_to_reg,
    input  logic                i_opcode_sbb_imm_to_reg_mem,
    input  logic                i_opcode_sbb_imm_to_acc,
    input  logic                i_opcode_scas,
    input  logic                i_opcode_setcc,
    input  logic                i_opcode_sgdt,
    input  logic                i_opcode_shl_1,
    input  logic                i_opcode_shl_cl,
    input  logic                i_opcode_shl_imm,
    input  logic                i_opcode_shld_imm,
    input  logic                i_opcode_shld_cl,
    input  logic                i_opcode_shr_1,
    input  logic                i_opcode_shr_cl,
    input  logic                i_opcode_shr_imm,
    input  logic                i_opcode_shrd_imm,
    input  logic                i_opcode_shrd_cl,
    input  logic                i_opcode_sidt,
    input  logic                i_opcode_sldt,
    input  logic                i_opcode_smsw,
    input  logic                i_opcode_stc,
    input  logic                i_opcode_std,
    input  logic                i_opcode_sti,
    input  logic                i_opcode_stos,
    input  logic                i_opcode_str,
    input  logic                i_opcode_sub_reg_to_reg_mem,
    input  logic                i_opcode_sub_reg_mem_to_reg,
    input  logic                i_opcode_sub_imm_to_reg_mem,
    input  logic                i_opcode_sub_imm_to_acc,
    input  logic                i_opcode_test_reg_mem,
    input  logic                i_opcode_test_imm_reg_mem,
    input  logic                i_opcode_test_imm_acc,
    input  logic                i_opcode_ud0,
    input  logic                i_opcode_ud1,
    input  logic                i_opcode_ud2,
    input  logic                i_opcode_verr,
    input  logic                i_opcode_verw,
    input  logic                i_opcode_wait,
    input  logic                i_opcode_wbinvd,
    input  logic                i_opcode_wrmsr,
    input  logic                i_opcode_xadd,
    input  logic                i_opcode_xchg_reg_mem,
    input  logic                i_opcode_xchg_acc,
    input  logic                i_opcode_xlat,
    input  logic                i_opcode_xor_reg_to_reg_mem,
    input  logic                i_opcode_xor_reg_mem_to_reg,
    input  logic                i_opcode_xor_imm_to_reg_mem,
    input  logic                i_opcode_xor_imm_to_acc,
    input  logic                i_opcode_x87_esc,
    input  logic [ 4: 0]        i_x87_exe_subop,
    input  logic [ 2: 0]        i_x87_sti,
    input  logic                i_x87_mem_access,
    input  logic                i_x87_is_store,
    input  logic                i_opcode_mmx_any,
    input  logic                i_opcode_mmx_emms,
    input  logic                i_opcode_sse_any,
    input  logic [ 3: 0]        i_tttn,
    input  logic [ 2: 0]        i_eee,

    input  logic [31: 0]        i_insn_eip,
    input  logic [ 3: 0]        i_insn_len,
    input  logic [31: 0]        i_dec_displacement,
    input  logic [31: 0]        i_dec_immediate,
    input  logic                i_dec_base_reg_is_present,
    input  logic [ 2: 0]        i_dec_base_reg_index,
    input  logic                i_dec_index_reg_is_present,
    input  logic [ 2: 0]        i_dec_index_reg_index,
    input  logic [ 2: 0]        i_dec_segment_reg_index,
    input  logic [ 2: 0]        i_dec_target_sreg_index,
    input  logic [ 1: 0]        i_dec_sib_scale_factor,
    input  logic [ 1: 0]        i_dec_modrm_mod,
    input  logic [ 2: 0]        i_gpr_bit_width,
    input  logic                i_dec_rep,
    input  logic                i_dec_repne,
    input  logic                i_dec_opsz_32,

    // =========================
    // Stage handshake
    // =========================
    input  logic                i_stage2_valid,

    // =========================
    // Micro-op output
    // =========================
    output micro_op_t           o_uop
);

    // ============================================================
    // Micro-op conversion signals
    // ============================================================
    micro_op_t uop_next;
    logic [31: 0] branch_rel;
    logic [31: 0] branch_target_abs;
    // Relative control transfers: target = next_eip + sign_extended(rel).
    // OperandSize=16: EIP ← (EIP + Dest) AND 0000FFFFH (SDM near JMP/Jcc/CALL).
    logic [31: 0] branch_target_raw;
    assign branch_rel =
        (i_opcode_jmp_short || i_opcode_jcc_short ||
         i_opcode_loop || i_opcode_loopz || i_opcode_loopnz || i_opcode_jcxz) ?
        {{24{i_dec_displacement[7]}}, i_dec_displacement[7: 0]} :
        {{16{i_dec_displacement[15]}}, i_dec_displacement[15: 0]};
    assign branch_target_raw = i_insn_eip + {28'h0, i_insn_len} + branch_rel;
    assign branch_target_abs = i_dec_opsz_32 ? branch_target_raw
                                             : {16'h0, branch_target_raw[15: 0]};

    function automatic logic [ 1: 0] f_mem_size_enc (
        input logic [ 2: 0] bw
    );
        unique case (bw)
            `bit_width_gpr__8: f_mem_size_enc = 2'b00;
            `bit_width_gpr_16: f_mem_size_enc = 2'b01;
            default:           f_mem_size_enc = 2'b10;
        endcase
    endfunction

    // Default micro-op (NOP)
    micro_op_t uop_default;
    assign uop_default = '{
        uop_opcode:      `UOP_NOP,
        uop_dest_reg:    3'b0,
        uop_src1_reg:    3'b0,
        uop_src2_reg:    3'b0,
        uop_immediate:   32'd0,
        uop_displacement: 32'd0,
        uop_tttn:        4'b0,
        uop_eee:         6'b0,
        uop_seg_index:   `index_reg_seg__DS,
        uop_sib_scale:   2'b0,
        uop_has_imm:     1'b0,
        uop_has_disp:    1'b0,
        uop_agu_base:    1'b0,
        uop_agu_index:   1'b0,
        uop_mem_access:  1'b0,
        uop_is_store:    1'b0,
        uop_mem_size:    2'b10,
        uop_rep:         1'b0,
        uop_repne:       1'b0,
        uop_valid:       1'b0
    };

    // Macro-instruction to micro-op conversion logic
    always_comb begin
        uop_next = uop_default;

        if (i_stage2_valid) begin
            uop_next.uop_valid    = 1'b1;
            uop_next.uop_tttn       = i_tttn;
            uop_next.uop_eee        = {3'b0, i_eee};
            uop_next.uop_seg_index  = i_dec_segment_reg_index;
            uop_next.uop_sib_scale  = i_dec_sib_scale_factor;
            uop_next.uop_mem_size   = f_mem_size_enc(i_gpr_bit_width);
            uop_next.uop_rep        = i_dec_rep;
            uop_next.uop_repne      = i_dec_repne;

            // Data transfer instructions: MOV, MOVSX, MOVZX, XCHG, LEA
            if (i_opcode_mov_reg_mem_to_sreg) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {13'h0, i_dec_target_sreg_index, `MISC_SUB_MOV_SEG};
                uop_next.uop_mem_access = (i_dec_modrm_mod != 2'b11);
                uop_next.uop_has_disp = (i_dec_modrm_mod != 2'b11);
                uop_next.uop_displacement = i_dec_displacement;
                // r/m GPR holds the selector (e.g. MOV DS,CX → src2=CX)
                uop_next.uop_src2_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
            end else if (i_opcode_mov_sreg_to_reg_mem) begin
                // 8C: r/m <- Sreg (FreeDOS boot: MOV [BP+disp], DS)
                uop_next.uop_opcode     = `UOP_MISC;
                uop_next.uop_immediate  = {13'h0, i_dec_target_sreg_index, `MISC_SUB_STORE_SEG};
                uop_next.uop_mem_size   = 2'b01;
                if (i_dec_modrm_mod != 2'b11) begin
                    uop_next.uop_mem_access   = 1'b1;
                    uop_next.uop_is_store     = 1'b1;
                    uop_next.uop_has_disp     = 1'b1;
                    uop_next.uop_displacement = i_dec_displacement;
                    uop_next.uop_agu_base     = i_dec_base_reg_is_present | i_dec_index_reg_is_present;
                    uop_next.uop_src1_reg     = i_dec_base_reg_is_present ? i_dec_base_reg_index :
                                               (i_dec_index_reg_is_present ? i_dec_index_reg_index : 3'b0);
                    uop_next.uop_agu_index    = i_dec_index_reg_is_present;
                    uop_next.uop_src2_reg     = i_dec_index_reg_is_present ? i_dec_index_reg_index : 3'b0;
                    uop_next.uop_sib_scale    = i_dec_index_reg_is_present ? i_dec_sib_scale_factor : 2'b0;
                end else begin
                    uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                end
            end else if (i_opcode_mov_reg_to_reg_mem || i_opcode_mov_reg_mem_to_reg) begin
                // 88/89: r/m <- r ; 8A/8B: r <- r/m. ModRM.reg is i_eee.
                // Mem address base: SIB base, else 32-bit non-SIB base in index_*.
                // Do not use field_gpr as dest for mem forms — that became MOV ESP,EAX
                // when SIB base=ESP was treated as a GPR dest with src2=EAX default.
                uop_next.uop_opcode = `UOP_MOV;
                if (i_dec_modrm_mod != 2'b11) begin
                    uop_next.uop_mem_access   = 1'b1;
                    uop_next.uop_is_store     = i_opcode_mov_reg_to_reg_mem;
                    uop_next.uop_has_disp     = 1'b1;
                    uop_next.uop_displacement = i_dec_displacement;
                    uop_next.uop_agu_base     = i_dec_base_reg_is_present | i_dec_index_reg_is_present;
                    uop_next.uop_src1_reg     = i_dec_base_reg_is_present ? i_dec_base_reg_index :
                                               (i_dec_index_reg_is_present ? i_dec_index_reg_index : 3'b0);
                    if (i_opcode_mov_reg_to_reg_mem) begin
                        uop_next.uop_src2_reg = i_eee;
                    end else begin
                        uop_next.uop_dest_reg = i_eee;
                    end
                end else if (i_opcode_mov_reg_to_reg_mem) begin
                    uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                    uop_next.uop_src2_reg = i_eee;
                end else begin
                    uop_next.uop_dest_reg = i_eee;
                    uop_next.uop_src2_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                end
            end else if (i_opcode_mov_imm_to_reg_mem || i_opcode_mov_imm_to_reg) begin
                // C6/C7: r/m <- imm ; B0+r / B8+r: reg <- imm
                uop_next.uop_opcode = `UOP_MOV;
                uop_next.uop_has_imm = 1'b1;
                uop_next.uop_immediate = i_dec_immediate;
                if (i_opcode_mov_imm_to_reg_mem && (i_dec_modrm_mod != 2'b11)) begin
                    uop_next.uop_mem_access   = 1'b1;
                    uop_next.uop_is_store     = 1'b1;
                    uop_next.uop_has_disp     = 1'b1;
                    uop_next.uop_displacement = i_dec_displacement;
                    uop_next.uop_agu_base     = i_dec_base_reg_is_present | i_dec_index_reg_is_present;
                    uop_next.uop_src1_reg     = i_dec_base_reg_is_present ? i_dec_base_reg_index :
                                               (i_dec_index_reg_is_present ? i_dec_index_reg_index : 3'b0);
                    uop_next.uop_agu_index    = i_dec_index_reg_is_present;
                    uop_next.uop_src2_reg     = i_dec_index_reg_is_present ? i_dec_index_reg_index : 3'b0;
                    uop_next.uop_sib_scale    = i_dec_index_reg_is_present ? i_dec_sib_scale_factor : 2'b0;
                end else if (i_opcode_mov_imm_to_reg &&
                             (i_gpr_bit_width == `bit_width_gpr__8) &&
                             i_dec_base_reg_is_present &&
                             i_dec_base_reg_index[2]) begin
                    // B4–B7: MOV AH/CH/DH/BH, Ib — dest is EAX/ECX/EDX/EBX, eee[0]=high byte
                    uop_next.uop_dest_reg = {1'b0, i_dec_base_reg_index[1: 0]};
                    uop_next.uop_eee      = {5'b0, 1'b1};
                end else begin
                    uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                end
            end else if (i_opcode_mov_mem_to_acc || i_opcode_mov_acc_to_mem) begin
                uop_next.uop_opcode = `UOP_MOV;
                uop_next.uop_mem_access = 1'b1;
                uop_next.uop_is_store = i_opcode_mov_acc_to_mem;
                uop_next.uop_dest_reg = 3'b0; // EAX
                uop_next.uop_has_disp = (i_dec_modrm_mod != 2'b11);
                uop_next.uop_displacement = i_dec_displacement;
            end else if (i_opcode_movsx) begin
                // 0F BE/BF: r <- sign_extend(r/m). ModRM.reg = i_eee.
                // imm[0] reserved for width (0=byte BE, 1=word BF); default byte.
                uop_next.uop_opcode = `UOP_MOVSX;
                uop_next.uop_immediate = 32'h0;
                if (i_dec_modrm_mod != 2'b11) begin
                    uop_next.uop_mem_access   = 1'b1;
                    uop_next.uop_has_disp     = 1'b1;
                    uop_next.uop_displacement = i_dec_displacement;
                    uop_next.uop_agu_base     = i_dec_base_reg_is_present | i_dec_index_reg_is_present;
                    uop_next.uop_src1_reg     = i_dec_base_reg_is_present ? i_dec_base_reg_index :
                                               (i_dec_index_reg_is_present ? i_dec_index_reg_index : 3'b0);
                    uop_next.uop_dest_reg     = i_eee;
                end else begin
                    uop_next.uop_dest_reg = i_eee;
                    uop_next.uop_src2_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                end
            end else if (i_opcode_movzx) begin
                // 0F B6/B7: r <- zero_extend(r/m). ModRM.reg = i_eee.
                // imm[0]=1 → word source (B7); 0 → byte (B6).
                uop_next.uop_opcode = `UOP_MOVZX;
                uop_next.uop_immediate = (i_gpr_bit_width == `bit_width_gpr__8) ? 32'h0 : 32'h1;
                uop_next.uop_mem_size  = uop_next.uop_immediate[0] ? 2'b01 : 2'b00;
                if (i_dec_modrm_mod != 2'b11) begin
                    uop_next.uop_mem_access   = 1'b1;
                    uop_next.uop_has_disp     = 1'b1;
                    uop_next.uop_displacement = i_dec_displacement;
                    uop_next.uop_agu_base     = i_dec_base_reg_is_present | i_dec_index_reg_is_present;
                    uop_next.uop_src1_reg     = i_dec_base_reg_is_present ? i_dec_base_reg_index :
                                               (i_dec_index_reg_is_present ? i_dec_index_reg_index : 3'b0);
                    uop_next.uop_dest_reg     = i_eee;
                end else begin
                    uop_next.uop_dest_reg = i_eee;
                    uop_next.uop_src2_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                end
            end else if (i_opcode_xchg_reg_mem || i_opcode_xchg_acc) begin
                // 86/87 XCHG r/m,r  or  90+rw XCHG r,acc
                // FreeDOS CHS uses XCHG CL,CH (same GPR byte swap) — map to
                // ROL r16,8 so a single WB swaps the bytes.
                if (i_opcode_xchg_reg_mem &&
                    (i_dec_modrm_mod == 2'b11) &&
                    (i_gpr_bit_width == `bit_width_gpr__8) &&
                    i_eee[2] &&
                    (i_eee[1: 0] == i_dec_base_reg_index[1: 0])) begin
                    uop_next.uop_opcode       = `UOP_ROL;
                    uop_next.uop_dest_reg     = {1'b0, i_eee[1: 0]};
                    uop_next.uop_src1_reg     = {1'b0, i_eee[1: 0]};
                    uop_next.uop_has_imm      = 1'b1;
                    uop_next.uop_immediate    = 32'd8;
                    uop_next.uop_mem_size     = 2'b01;
                end else if (i_opcode_xchg_acc) begin
                    // 90+rw: r ↔ AX/EAX. Opcode[2:0] is r (via base_reg);
                    // i_eee is 0 without ModRM. EXU writes dest:=src1 and
                    // EAX:=src2 (dual WB).
                    uop_next.uop_opcode   = `UOP_XCHG;
                    uop_next.uop_dest_reg = i_dec_base_reg_is_present ?
                                           i_dec_base_reg_index : 3'b0;
                    uop_next.uop_src1_reg = `index_reg_gpr_EAX;
                    uop_next.uop_src2_reg = i_dec_base_reg_is_present ?
                                           i_dec_base_reg_index : 3'b0;
                    uop_next.uop_mem_size = i_dec_opsz_32 ? 2'b10 : 2'b01;
                end else begin
                    uop_next.uop_opcode   = `UOP_XCHG;
                    uop_next.uop_dest_reg = i_dec_base_reg_is_present ?
                                           i_dec_base_reg_index : 3'b0;
                    uop_next.uop_src1_reg = i_eee;
                    uop_next.uop_src2_reg = i_dec_base_reg_is_present ?
                                           i_dec_base_reg_index : 3'b0;
                    uop_next.uop_mem_size = (i_gpr_bit_width == `bit_width_gpr__8) ?
                                           2'b00 : (i_dec_opsz_32 ? 2'b10 : 2'b01);
                end
            end else if (i_opcode_lea) begin
                // 8D: LEA r, m — ModRM.reg = i_eee is dest; r/m forms the EA.
                uop_next.uop_opcode = `UOP_LEA;
                uop_next.uop_dest_reg = i_eee;
                uop_next.uop_src1_reg = i_dec_base_reg_is_present ?
                                        i_dec_base_reg_index : 3'b0;
                uop_next.uop_agu_base = i_dec_base_reg_is_present;
                uop_next.uop_agu_index = i_dec_index_reg_is_present;
                uop_next.uop_src2_reg = i_dec_index_reg_is_present ?
                                        i_dec_index_reg_index : 3'b0;
                uop_next.uop_sib_scale = i_dec_index_reg_is_present ?
                                        i_dec_sib_scale_factor : 2'b0;
                uop_next.uop_has_disp = 1'b1;
                uop_next.uop_displacement = i_dec_displacement;
            end

            // Arithmetic instructions: ADD, ADC, SUB, SBB, INC, DEC, NEG, CMP
            // Mem forms must not treat EA base/index as GPR dest (that wrote
            // SI+EAX into a GPR — FreeDOS boot overlay ADD [BX+SI+disp],AH).
            // src2 is also AGU index, so base+index mem ops need a 3rd RF read;
            // RMW and dual-EA forms are NOP until full RMW exists.
            else if (i_opcode_add_reg_to_reg_mem || i_opcode_add_reg_mem_to_reg) begin
                uop_next.uop_opcode = `UOP_ADD;
                if (i_dec_modrm_mod != 2'b11) begin
                    if (i_opcode_add_reg_to_reg_mem ||
                        (i_dec_base_reg_is_present && i_dec_index_reg_is_present)) begin
                        uop_next.uop_opcode = `UOP_NOP;
                    end else begin
                        // r := r + r/m — single-base/index EA; load then WB dest=eee
                        uop_next.uop_mem_access   = 1'b1;
                        uop_next.uop_has_disp     = 1'b1;
                        uop_next.uop_displacement = i_dec_displacement;
                        uop_next.uop_agu_base     = i_dec_base_reg_is_present | i_dec_index_reg_is_present;
                        uop_next.uop_src1_reg     = i_dec_base_reg_is_present ? i_dec_base_reg_index :
                                                   (i_dec_index_reg_is_present ? i_dec_index_reg_index : 3'b0);
                        uop_next.uop_dest_reg     = i_eee;
                        uop_next.uop_src2_reg     = i_eee;
                    end
                end else if (i_opcode_add_reg_to_reg_mem) begin
                    uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                    uop_next.uop_src1_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                    uop_next.uop_src2_reg = i_eee;
                end else begin
                    uop_next.uop_dest_reg = i_eee;
                    uop_next.uop_src1_reg = i_eee;
                    uop_next.uop_src2_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                end
            end else if (i_opcode_add_imm_to_reg_mem || i_opcode_add_imm_to_acc) begin
                // 81/83 /0, 05: r/m := r/m + imm (RMW — src1 must be dest)
                uop_next.uop_opcode = `UOP_ADD;
                uop_next.uop_has_imm = 1'b1;
                uop_next.uop_immediate = i_dec_immediate;
                if (i_opcode_add_imm_to_acc) begin
                    uop_next.uop_dest_reg = 3'd0;
                    uop_next.uop_src1_reg = 3'd0;
                end else if (i_dec_modrm_mod == 2'b11) begin
                    uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                    uop_next.uop_src1_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                end else begin
                    uop_next.uop_mem_access   = 1'b1;
                    uop_next.uop_has_disp     = 1'b1;
                    uop_next.uop_displacement = i_dec_displacement;
                    uop_next.uop_agu_base     = i_dec_base_reg_is_present | i_dec_index_reg_is_present;
                    uop_next.uop_src1_reg     = i_dec_base_reg_is_present ? i_dec_base_reg_index :
                                               (i_dec_index_reg_is_present ? i_dec_index_reg_index : 3'b0);
                end
            end else if (i_opcode_adc_reg_to_reg_mem || i_opcode_adc_reg_mem_to_reg) begin
                uop_next.uop_opcode = `UOP_ADC;
                if (i_dec_modrm_mod != 2'b11) begin
                    uop_next.uop_opcode = `UOP_NOP;
                end else if (i_opcode_adc_reg_to_reg_mem) begin
                    uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                    uop_next.uop_src1_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                    uop_next.uop_src2_reg = i_eee;
                end else begin
                    uop_next.uop_dest_reg = i_eee;
                    uop_next.uop_src1_reg = i_eee;
                    uop_next.uop_src2_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                end
            end else if (i_opcode_adc_imm_to_reg_mem || i_opcode_adc_imm_to_acc) begin
                uop_next.uop_opcode = `UOP_ADC;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_src1_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_has_imm = 1'b1;
                uop_next.uop_immediate = i_dec_immediate;
                if (i_opcode_adc_imm_to_reg_mem && (i_dec_modrm_mod != 2'b11))
                    uop_next.uop_opcode = `UOP_NOP;
            end else if (i_opcode_sub_reg_to_reg_mem || i_opcode_sub_reg_mem_to_reg) begin
                uop_next.uop_opcode = `UOP_SUB;
                if (i_dec_modrm_mod != 2'b11) begin
                    if (i_opcode_sub_reg_to_reg_mem ||
                        (i_dec_base_reg_is_present && i_dec_index_reg_is_present)) begin
                        uop_next.uop_opcode = `UOP_NOP;
                    end else begin
                        uop_next.uop_mem_access   = 1'b1;
                        uop_next.uop_has_disp     = 1'b1;
                        uop_next.uop_displacement = i_dec_displacement;
                        uop_next.uop_agu_base     = i_dec_base_reg_is_present | i_dec_index_reg_is_present;
                        uop_next.uop_src1_reg     = i_dec_base_reg_is_present ? i_dec_base_reg_index :
                                                   (i_dec_index_reg_is_present ? i_dec_index_reg_index : 3'b0);
                        uop_next.uop_dest_reg     = i_eee;
                        uop_next.uop_src2_reg     = i_eee;
                    end
                end else if (i_opcode_sub_reg_to_reg_mem) begin
                    uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                    uop_next.uop_src1_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                    uop_next.uop_src2_reg = i_eee;
                end else begin
                    uop_next.uop_dest_reg = i_eee;
                    uop_next.uop_src1_reg = i_eee;
                    uop_next.uop_src2_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                end
            end else if (i_opcode_sub_imm_to_reg_mem || i_opcode_sub_imm_to_acc) begin
                // 80/81/83 /5, 2D: r/m := r/m - imm (RMW for mem form)
                uop_next.uop_opcode = `UOP_SUB;
                uop_next.uop_has_imm = 1'b1;
                uop_next.uop_immediate = i_dec_immediate;
                if (i_opcode_sub_imm_to_acc) begin
                    uop_next.uop_dest_reg = 3'd0;
                    uop_next.uop_src1_reg = 3'd0;
                end else if (i_dec_modrm_mod == 2'b11) begin
                    uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                    uop_next.uop_src1_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                end else begin
                    uop_next.uop_mem_access   = 1'b1;
                    uop_next.uop_has_disp     = 1'b1;
                    uop_next.uop_displacement = i_dec_displacement;
                    uop_next.uop_agu_base     = i_dec_base_reg_is_present | i_dec_index_reg_is_present;
                    uop_next.uop_src1_reg     = i_dec_base_reg_is_present ? i_dec_base_reg_index :
                                               (i_dec_index_reg_is_present ? i_dec_index_reg_index : 3'b0);
                end
            end else if (i_opcode_sbb_reg_to_reg_mem || i_opcode_sbb_reg_mem_to_reg) begin
                uop_next.uop_opcode = `UOP_SBB;
                if (i_dec_modrm_mod != 2'b11) begin
                    uop_next.uop_opcode = `UOP_NOP;
                end else if (i_opcode_sbb_reg_to_reg_mem) begin
                    uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                    uop_next.uop_src1_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                    uop_next.uop_src2_reg = i_eee;
                end else begin
                    uop_next.uop_dest_reg = i_eee;
                    uop_next.uop_src1_reg = i_eee;
                    uop_next.uop_src2_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                end
            end else if (i_opcode_sbb_imm_to_reg_mem || i_opcode_sbb_imm_to_acc) begin
                uop_next.uop_opcode = `UOP_SBB;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_src1_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_has_imm = 1'b1;
                uop_next.uop_immediate = i_dec_immediate;
                if (i_opcode_sbb_imm_to_reg_mem && (i_dec_modrm_mod != 2'b11))
                    uop_next.uop_opcode = `UOP_NOP;
            end else if (i_opcode_inc_reg_mem || i_opcode_inc_reg) begin
                uop_next.uop_opcode = `UOP_INC;
                if (i_opcode_inc_reg_mem && (i_dec_modrm_mod != 2'b11))
                    uop_next.uop_opcode = `UOP_NOP;
                else begin
                    uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                    uop_next.uop_src1_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                end
            end else if (i_opcode_dec_reg_mem || i_opcode_dec_reg) begin
                uop_next.uop_opcode = `UOP_DEC;
                if (i_opcode_dec_reg_mem && (i_dec_modrm_mod != 2'b11))
                    uop_next.uop_opcode = `UOP_NOP;
                else begin
                    uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                    uop_next.uop_src1_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                end
            end else if (i_opcode_neg) begin
                uop_next.uop_opcode = `UOP_NEG;
                if (i_dec_modrm_mod != 2'b11)
                    uop_next.uop_opcode = `UOP_NOP;
                else begin
                    uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                    uop_next.uop_src1_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                end
            end else if (i_opcode_cmp_mem_reg || i_opcode_cmp_reg_mem) begin
                uop_next.uop_opcode = `UOP_CMP;
                if (i_dec_modrm_mod != 2'b11) begin
                    if (i_dec_base_reg_is_present && i_dec_index_reg_is_present) begin
                        uop_next.uop_opcode = `UOP_NOP;
                    end else begin
                        // CMP r/m,r or CMP r,r/m — load r/m then compare in EXU
                        uop_next.uop_mem_access   = 1'b1;
                        uop_next.uop_has_disp     = 1'b1;
                        uop_next.uop_displacement = i_dec_displacement;
                        uop_next.uop_agu_base     = i_dec_base_reg_is_present | i_dec_index_reg_is_present;
                        uop_next.uop_src1_reg     = i_dec_base_reg_is_present ? i_dec_base_reg_index :
                                                   (i_dec_index_reg_is_present ? i_dec_index_reg_index : 3'b0);
                        // EXU CMP mem: imm[8]=1 → CMP r,r/m (eee-mem); else mem-eee
                        uop_next.uop_src2_reg     = i_eee;
                        uop_next.uop_immediate    = {23'h0, i_opcode_cmp_reg_mem, 8'h0};
                    end
                end else if (i_opcode_cmp_mem_reg) begin
                    uop_next.uop_src1_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                    uop_next.uop_src2_reg = i_eee;
                end else begin
                    uop_next.uop_src1_reg = i_eee;
                    uop_next.uop_src2_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                end
            end else if (i_opcode_cmp_imm_acc) begin
                // CMP AL/AX/EAX, imm — always accumulator; never treat as mem.
                uop_next.uop_opcode     = `UOP_CMP;
                uop_next.uop_src1_reg   = `index_reg_gpr_EAX;
                uop_next.uop_has_imm    = 1'b1;
                uop_next.uop_immediate  = i_dec_immediate;
                uop_next.uop_mem_access = 1'b0;
            end else if (i_opcode_cmp_imm_reg_mem) begin
                uop_next.uop_opcode = `UOP_CMP;
                // Byte AH/CH/DH/BH (mod=11, rm[2]=1): parent GPR is EAX..EBX and
                // eee[0] selects [15:8]. Raw rm=4 would wrongly read ESP.
                if ((i_gpr_bit_width == `bit_width_gpr__8) &&
                    (i_dec_modrm_mod == 2'b11) &&
                    i_dec_base_reg_is_present &&
                    i_dec_base_reg_index[2]) begin
                    uop_next.uop_dest_reg = {1'b0, i_dec_base_reg_index[1: 0]};
                    uop_next.uop_src1_reg = {1'b0, i_dec_base_reg_index[1: 0]};
                    uop_next.uop_eee      = {5'b0, 1'b1};
                end else begin
                    uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                    // AGU base: stage_4 reads uop_src1_reg; disp-only must not use EAX
                    // (src1_reg=0). uop_agu_base gates src1 in EXU address calc.
                    uop_next.uop_src1_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                    // Clear eee so GRP1 /reg (e.g. /7=CMP) does not look like *H.
                    uop_next.uop_eee      = 6'b0;
                end
                uop_next.uop_agu_base = i_dec_base_reg_is_present & (i_dec_modrm_mod != 2'b11);
                uop_next.uop_has_imm = 1'b1;
                uop_next.uop_immediate = i_dec_immediate;
                uop_next.uop_mem_access = (i_dec_modrm_mod != 2'b11);
                uop_next.uop_has_disp = uop_next.uop_mem_access;
                uop_next.uop_displacement = i_dec_displacement;
            end

            // Logic instructions: AND, OR, XOR, NOT, TEST
            else if (i_opcode_and_reg_to_reg_mem || i_opcode_and_reg_mem_to_reg) begin
                uop_next.uop_opcode = `UOP_AND;
                if (i_dec_modrm_mod != 2'b11) begin
                    uop_next.uop_opcode = `UOP_NOP;
                end else if (i_opcode_and_reg_to_reg_mem) begin
                    uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                    uop_next.uop_src1_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                    uop_next.uop_src2_reg = i_eee;
                end else begin
                    uop_next.uop_dest_reg = i_eee;
                    uop_next.uop_src1_reg = i_eee;
                    uop_next.uop_src2_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                end
            end else if (i_opcode_and_imm_to_reg_mem || i_opcode_and_imm_to_acc) begin
                uop_next.uop_opcode = `UOP_AND;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_src1_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_has_imm = 1'b1;
                uop_next.uop_immediate = i_dec_immediate;
                if (i_opcode_and_imm_to_reg_mem && (i_dec_modrm_mod != 2'b11))
                    uop_next.uop_opcode = `UOP_NOP;
            end else if (i_opcode_or_reg_to_reg_mem || i_opcode_or_reg_mem_to_reg) begin
                uop_next.uop_opcode = `UOP_OR;
                if (i_dec_modrm_mod != 2'b11) begin
                    uop_next.uop_opcode = `UOP_NOP;
                end else if (i_opcode_or_reg_to_reg_mem) begin
                    uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                    uop_next.uop_src1_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                    uop_next.uop_src2_reg = i_eee;
                end else begin
                    uop_next.uop_dest_reg = i_eee;
                    uop_next.uop_src1_reg = i_eee;
                    uop_next.uop_src2_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                end
            end else if (i_opcode_or_imm_to_reg_mem || i_opcode_or_imm_to_acc) begin
                uop_next.uop_opcode = `UOP_OR;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_src1_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_has_imm = 1'b1;
                uop_next.uop_immediate = i_dec_immediate;
                if (i_opcode_or_imm_to_reg_mem && (i_dec_modrm_mod != 2'b11))
                    uop_next.uop_opcode = `UOP_NOP;
            end else if (i_opcode_xor_reg_to_reg_mem || i_opcode_xor_reg_mem_to_reg) begin
                uop_next.uop_opcode = `UOP_XOR;
                if (i_dec_modrm_mod != 2'b11) begin
                    uop_next.uop_opcode = `UOP_NOP;
                end else if (i_opcode_xor_reg_to_reg_mem) begin
                    uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                    uop_next.uop_src1_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                    uop_next.uop_src2_reg = i_eee;
                end else begin
                    uop_next.uop_dest_reg = i_eee;
                    uop_next.uop_src1_reg = i_eee;
                    uop_next.uop_src2_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                end
            end else if (i_opcode_xor_imm_to_reg_mem || i_opcode_xor_imm_to_acc) begin
                uop_next.uop_opcode = `UOP_XOR;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_src1_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_has_imm = 1'b1;
                uop_next.uop_immediate = i_dec_immediate;
                if (i_opcode_xor_imm_to_reg_mem && (i_dec_modrm_mod != 2'b11))
                    uop_next.uop_opcode = `UOP_NOP;
            end else if (i_opcode_not) begin
                uop_next.uop_opcode = `UOP_NOT;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_src1_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
            end else if (i_opcode_test_reg_mem) begin
                // 84/85: TEST r/m, r — ModRM.reg = i_eee, r/m = base when mod=11
                uop_next.uop_opcode = `UOP_TEST;
                if (i_dec_modrm_mod != 2'b11) begin
                    uop_next.uop_mem_access = 1'b1;
                    uop_next.uop_has_disp   = 1'b1;
                    uop_next.uop_displacement = i_dec_displacement;
                    uop_next.uop_src1_reg   = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                    uop_next.uop_agu_base   = i_dec_base_reg_is_present;
                    uop_next.uop_src2_reg   = i_eee;
                end else begin
                    uop_next.uop_src1_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                    uop_next.uop_src2_reg = i_eee;
                end
            end else if (i_opcode_test_imm_reg_mem || i_opcode_test_imm_acc) begin
                uop_next.uop_opcode = `UOP_TEST;
                uop_next.uop_src1_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_has_imm = 1'b1;
                uop_next.uop_immediate = i_dec_immediate;
                uop_next.uop_mem_access = i_opcode_test_imm_reg_mem & (i_dec_modrm_mod != 2'b11);
                uop_next.uop_has_disp = uop_next.uop_mem_access;
                uop_next.uop_displacement = i_dec_displacement;
                uop_next.uop_agu_base = i_dec_base_reg_is_present & uop_next.uop_mem_access;
            end

            // Shift/rotate RMW: src1 must be r/m (dest). Count is imm/1 or CL
            // in src2 — previously src1 defaulted to EAX, so SHR EDX,4 shifted
            // EAX forever and SeaBIOS %x digit-count loop spun at jz.
            else if (i_opcode_shl_1 || i_opcode_shl_cl || i_opcode_shl_imm) begin
                uop_next.uop_opcode = `UOP_SHL;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_src1_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_has_imm = (i_opcode_shl_imm) | (i_opcode_shl_1);
                uop_next.uop_immediate = i_opcode_shl_1 ? 32'd1 : i_dec_immediate;
                if (i_opcode_shl_cl)
                    uop_next.uop_src2_reg = `index_reg_gpr_ECX;
                if ((i_gpr_bit_width == `bit_width_gpr__8) &&
                    (i_dec_modrm_mod == 2'b11) &&
                    i_dec_base_reg_is_present &&
                    i_dec_base_reg_index[2]) begin
                    uop_next.uop_dest_reg = {1'b0, i_dec_base_reg_index[1: 0]};
                    uop_next.uop_src1_reg = {1'b0, i_dec_base_reg_index[1: 0]};
                    uop_next.uop_eee      = {5'b0, 1'b1};
                end
            end else if (i_opcode_shr_1 || i_opcode_shr_cl || i_opcode_shr_imm) begin
                uop_next.uop_opcode = `UOP_SHR;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_src1_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_has_imm = (i_opcode_shr_imm) | (i_opcode_shr_1);
                uop_next.uop_immediate = i_opcode_shr_1 ? 32'd1 : i_dec_immediate;
                if (i_opcode_shr_cl)
                    uop_next.uop_src2_reg = `index_reg_gpr_ECX;
                if ((i_gpr_bit_width == `bit_width_gpr__8) &&
                    (i_dec_modrm_mod == 2'b11) &&
                    i_dec_base_reg_is_present &&
                    i_dec_base_reg_index[2]) begin
                    uop_next.uop_dest_reg = {1'b0, i_dec_base_reg_index[1: 0]};
                    uop_next.uop_src1_reg = {1'b0, i_dec_base_reg_index[1: 0]};
                    uop_next.uop_eee      = {5'b0, 1'b1};
                end
            end else if (i_opcode_sar_1 || i_opcode_sar_cl || i_opcode_sar_imm) begin
                uop_next.uop_opcode = `UOP_SAR;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_src1_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_has_imm = (i_opcode_sar_imm) | (i_opcode_sar_1);
                uop_next.uop_immediate = i_opcode_sar_1 ? 32'd1 : i_dec_immediate;
                if (i_opcode_sar_cl)
                    uop_next.uop_src2_reg = `index_reg_gpr_ECX;
                if ((i_gpr_bit_width == `bit_width_gpr__8) &&
                    (i_dec_modrm_mod == 2'b11) &&
                    i_dec_base_reg_is_present &&
                    i_dec_base_reg_index[2]) begin
                    uop_next.uop_dest_reg = {1'b0, i_dec_base_reg_index[1: 0]};
                    uop_next.uop_src1_reg = {1'b0, i_dec_base_reg_index[1: 0]};
                    uop_next.uop_eee      = {5'b0, 1'b1};
                end
            end else if (i_opcode_rol_1 || i_opcode_rol_cl || i_opcode_rol_imm) begin
                uop_next.uop_opcode = `UOP_ROL;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_src1_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_has_imm = (i_opcode_rol_imm) | (i_opcode_rol_1);
                uop_next.uop_immediate = i_opcode_rol_1 ? 32'd1 : i_dec_immediate;
                if (i_opcode_rol_cl)
                    uop_next.uop_src2_reg = `index_reg_gpr_ECX;
                if ((i_gpr_bit_width == `bit_width_gpr__8) &&
                    (i_dec_modrm_mod == 2'b11) &&
                    i_dec_base_reg_is_present &&
                    i_dec_base_reg_index[2]) begin
                    uop_next.uop_dest_reg = {1'b0, i_dec_base_reg_index[1: 0]};
                    uop_next.uop_src1_reg = {1'b0, i_dec_base_reg_index[1: 0]};
                    uop_next.uop_eee      = {5'b0, 1'b1};
                end
            end else if (i_opcode_ror_1 || i_opcode_ror_cl || i_opcode_ror_imm) begin
                uop_next.uop_opcode = `UOP_ROR;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_src1_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_has_imm = (i_opcode_ror_imm) | (i_opcode_ror_1);
                uop_next.uop_immediate = i_opcode_ror_1 ? 32'd1 : i_dec_immediate;
                if (i_opcode_ror_cl)
                    uop_next.uop_src2_reg = `index_reg_gpr_ECX;
                if ((i_gpr_bit_width == `bit_width_gpr__8) &&
                    (i_dec_modrm_mod == 2'b11) &&
                    i_dec_base_reg_is_present &&
                    i_dec_base_reg_index[2]) begin
                    uop_next.uop_dest_reg = {1'b0, i_dec_base_reg_index[1: 0]};
                    uop_next.uop_src1_reg = {1'b0, i_dec_base_reg_index[1: 0]};
                    uop_next.uop_eee      = {5'b0, 1'b1};
                end
            end else if (i_opcode_rcl_1 || i_opcode_rcl_cl || i_opcode_rcl_imm) begin
                uop_next.uop_opcode = `UOP_RCL;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_src1_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_has_imm = (i_opcode_rcl_imm) | (i_opcode_rcl_1);
                uop_next.uop_immediate = i_opcode_rcl_1 ? 32'd1 : i_dec_immediate;
                if (i_opcode_rcl_cl)
                    uop_next.uop_src2_reg = `index_reg_gpr_ECX;
                if ((i_gpr_bit_width == `bit_width_gpr__8) &&
                    (i_dec_modrm_mod == 2'b11) &&
                    i_dec_base_reg_is_present &&
                    i_dec_base_reg_index[2]) begin
                    uop_next.uop_dest_reg = {1'b0, i_dec_base_reg_index[1: 0]};
                    uop_next.uop_src1_reg = {1'b0, i_dec_base_reg_index[1: 0]};
                    uop_next.uop_eee      = {5'b0, 1'b1};
                end
            end else if (i_opcode_rcr_1 || i_opcode_rcr_cl || i_opcode_rcr_imm) begin
                uop_next.uop_opcode = `UOP_RCR;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_src1_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_has_imm = (i_opcode_rcr_imm) | (i_opcode_rcr_1);
                uop_next.uop_immediate = i_opcode_rcr_1 ? 32'd1 : i_dec_immediate;
                if (i_opcode_rcr_cl)
                    uop_next.uop_src2_reg = `index_reg_gpr_ECX;
                if ((i_gpr_bit_width == `bit_width_gpr__8) &&
                    (i_dec_modrm_mod == 2'b11) &&
                    i_dec_base_reg_is_present &&
                    i_dec_base_reg_index[2]) begin
                    uop_next.uop_dest_reg = {1'b0, i_dec_base_reg_index[1: 0]};
                    uop_next.uop_src1_reg = {1'b0, i_dec_base_reg_index[1: 0]};
                    uop_next.uop_eee      = {5'b0, 1'b1};
                end
            end else if (i_opcode_shld_imm || i_opcode_shld_cl) begin
                // SHLD r/m, r, imm/CL — dest/src1 = r/m, src2 = r (eee)
                uop_next.uop_opcode = `UOP_SHLD;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_src1_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_src2_reg = i_eee;
                uop_next.uop_has_imm = (i_opcode_shld_imm);
                uop_next.uop_immediate = i_dec_immediate;
            end else if (i_opcode_shrd_imm || i_opcode_shrd_cl) begin
                uop_next.uop_opcode = `UOP_SHRD;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_src1_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_src2_reg = i_eee;
                uop_next.uop_has_imm = (i_opcode_shrd_imm);
                uop_next.uop_immediate = i_dec_immediate;
            end

            // Multiply/Divide instructions: MUL, IMUL, DIV, IDIV
            else if (i_opcode_mul) begin
                // MUL r/m: AL/AX/EAX * r/m → AX / DX:AX / EDX:EAX
                // Mem form: AGU base/index in src1/src2 (EAX is read in EXU).
                uop_next.uop_opcode   = `UOP_MUL;
                uop_next.uop_dest_reg = `index_reg_gpr_EAX;
                uop_next.uop_mem_size = f_mem_size_enc(i_gpr_bit_width);
                if (i_dec_modrm_mod != 2'b11) begin
                    uop_next.uop_mem_access   = 1'b1;
                    uop_next.uop_has_disp     = 1'b1;
                    uop_next.uop_displacement = i_dec_displacement;
                    uop_next.uop_agu_base     = i_dec_base_reg_is_present;
                    uop_next.uop_agu_index    = i_dec_index_reg_is_present;
                    uop_next.uop_src1_reg     = i_dec_base_reg_is_present ?
                                               i_dec_base_reg_index : 3'b0;
                    uop_next.uop_src2_reg     = i_dec_index_reg_is_present ?
                                               i_dec_index_reg_index : 3'b0;
                end else begin
                    uop_next.uop_src1_reg = `index_reg_gpr_EAX;
                    uop_next.uop_src2_reg = i_dec_base_reg_is_present ?
                                           i_dec_base_reg_index : 3'b0;
                end
            end else if (i_opcode_imul_acc || i_opcode_imul_reg) begin
                uop_next.uop_opcode = `UOP_IMUL;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_src1_reg = i_dec_index_reg_is_present ? i_dec_index_reg_index : 3'b0;
            end else if (i_opcode_imul_imm) begin
                // 69/6B: r := r/m * imm. ModRM.reg = dest (i_eee); r/m = src.
                uop_next.uop_opcode = `UOP_IMUL;
                uop_next.uop_dest_reg = i_eee;
                uop_next.uop_src1_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_has_imm = 1'b1;
                uop_next.uop_immediate = i_dec_immediate;
            end else if (i_opcode_div) begin
                // DIV r/m: divisor in mem/reg; DX:AX / EDX:EAX supplied at EXU.
                uop_next.uop_opcode   = `UOP_DIV;
                uop_next.uop_dest_reg = `index_reg_gpr_EAX;
                uop_next.uop_mem_size = f_mem_size_enc(i_gpr_bit_width);
                if (i_dec_modrm_mod != 2'b11) begin
                    uop_next.uop_mem_access   = 1'b1;
                    uop_next.uop_has_disp     = 1'b1;
                    uop_next.uop_displacement = i_dec_displacement;
                    uop_next.uop_agu_base     = i_dec_base_reg_is_present;
                    uop_next.uop_agu_index    = i_dec_index_reg_is_present;
                    uop_next.uop_src1_reg     = i_dec_base_reg_is_present ?
                                               i_dec_base_reg_index : 3'b0;
                    uop_next.uop_src2_reg     = i_dec_index_reg_is_present ?
                                               i_dec_index_reg_index : 3'b0;
                end else begin
                    uop_next.uop_src1_reg = i_dec_base_reg_is_present ?
                                           i_dec_base_reg_index : 3'b0;
                end
            end else if (i_opcode_idiv) begin
                uop_next.uop_opcode   = `UOP_IDIV;
                uop_next.uop_dest_reg = `index_reg_gpr_EAX;
                uop_next.uop_mem_size = f_mem_size_enc(i_gpr_bit_width);
                if (i_dec_modrm_mod != 2'b11) begin
                    uop_next.uop_mem_access   = 1'b1;
                    uop_next.uop_has_disp     = 1'b1;
                    uop_next.uop_displacement = i_dec_displacement;
                    uop_next.uop_agu_base     = i_dec_base_reg_is_present;
                    uop_next.uop_agu_index    = i_dec_index_reg_is_present;
                    uop_next.uop_src1_reg     = i_dec_base_reg_is_present ?
                                               i_dec_base_reg_index : 3'b0;
                    uop_next.uop_src2_reg     = i_dec_index_reg_is_present ?
                                               i_dec_index_reg_index : 3'b0;
                end else begin
                    uop_next.uop_src1_reg = i_dec_base_reg_is_present ?
                                           i_dec_base_reg_index : 3'b0;
                end
            end

            // Stack instructions: PUSH, POP
            // exu_push: src1/imm = value, src2 = ESP, dest = ESP (new ESP)
            // exu_pop:  src1 = ESP (addr), dest = GPR; ESP:=ESP+4 written in EXU
            else if (i_opcode_push_reg || i_opcode_push_reg_mem || i_opcode_push_imm) begin
                uop_next.uop_opcode = `UOP_PUSH;
                uop_next.uop_src1_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_src2_reg = `index_reg_gpr_ESP;
                uop_next.uop_dest_reg = `index_reg_gpr_ESP;
                uop_next.uop_has_imm = i_opcode_push_imm;
                uop_next.uop_immediate = i_dec_immediate;
                // Stack slot follows operand size (0x66 → dword in real mode)
                uop_next.uop_mem_size = i_dec_opsz_32 ? 2'b10 : 2'b01;
                if (i_opcode_push_reg_mem && (i_dec_modrm_mod != 2'b11)) begin
                    uop_next.uop_mem_access = 1'b1;
                    uop_next.uop_has_disp = 1'b1;
                    uop_next.uop_displacement = i_dec_displacement;
                end
            end else if (i_opcode_pushf) begin
                uop_next.uop_opcode = `UOP_PUSH;
                uop_next.uop_src2_reg = `index_reg_gpr_ESP;
                uop_next.uop_dest_reg = `index_reg_gpr_ESP;
                uop_next.uop_immediate = {24'h0, `UOP_TAG_PUSHF};
                uop_next.uop_mem_size = i_dec_opsz_32 ? 2'b10 : 2'b01;
            end else if (i_opcode_pusha) begin
                uop_next.uop_opcode = `UOP_PUSH;
                uop_next.uop_src2_reg = `index_reg_gpr_ESP;
                uop_next.uop_dest_reg = `index_reg_gpr_ESP;
                uop_next.uop_mem_size = i_dec_opsz_32 ? 2'b10 : 2'b01;
            end else if (i_opcode_pop_reg || i_opcode_pop_reg_mem) begin
                uop_next.uop_opcode = `UOP_POP;
                uop_next.uop_src1_reg = `index_reg_gpr_ESP;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_mem_size = i_dec_opsz_32 ? 2'b10 : 2'b01;
            end else if (i_opcode_popf) begin
                uop_next.uop_opcode = `UOP_POP;
                uop_next.uop_src1_reg = `index_reg_gpr_ESP;
                uop_next.uop_immediate = {24'h0, `UOP_TAG_POPF};
                uop_next.uop_mem_size = i_dec_opsz_32 ? 2'b10 : 2'b01;
            end else if (i_opcode_popa) begin
                uop_next.uop_opcode = `UOP_POP;
                uop_next.uop_src1_reg = `index_reg_gpr_ESP;
                uop_next.uop_mem_size = i_dec_opsz_32 ? 2'b10 : 2'b01;
            end

            // Control flow instructions: JMP, CALL, RET, LOOP, Jcc
            else if (i_opcode_jmp_far_direct) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {8'h0, i_dec_immediate[15: 0], `MISC_SUB_FAR_JMP};
                uop_next.uop_displacement = i_dec_displacement;
                uop_next.uop_has_disp = 1'b1;
            end else if (i_opcode_jmp_far_indirect) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_FAR_JMP};
                uop_next.uop_mem_access = 1'b1;
                uop_next.uop_has_disp = (i_dec_modrm_mod != 2'b11);
                uop_next.uop_displacement = i_dec_displacement;
            end else if (i_opcode_call_far_direct) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {8'h0, i_dec_immediate[15: 0], `MISC_SUB_FAR_CALL};
                uop_next.uop_displacement = i_dec_displacement;
                uop_next.uop_has_disp = 1'b1;
            end else if (i_opcode_call_far_indirect) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_FAR_CALL};
                uop_next.uop_mem_access = 1'b1;
                uop_next.uop_has_disp = (i_dec_modrm_mod != 2'b11);
                uop_next.uop_displacement = i_dec_displacement;
            end else if (i_opcode_ret_far || i_opcode_ret_far_imm) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_FAR_RET};
                uop_next.uop_has_disp = (i_opcode_ret_far_imm);
                uop_next.uop_displacement = i_dec_displacement;
            end else if (i_opcode_jmp_short || i_opcode_jmp_near_direct) begin
                uop_next.uop_opcode = `UOP_BRANCH;
                uop_next.uop_tttn = 4'h0;
                uop_next.uop_has_imm = 1'b1;
                uop_next.uop_immediate = 32'h1; // unconditional marker
                uop_next.uop_has_disp = 1'b1;
                uop_next.uop_displacement = branch_target_abs;
            end else if (i_opcode_jmp_near_indirect) begin
                // FF /4: JMP r/m32 — register form uses src1; mem form loads later.
                // SIB index*scale+disp (e.g. puthex jump table) needs agu_index.
                uop_next.uop_opcode = `UOP_BRANCH;
                uop_next.uop_tttn = 4'h0;
                uop_next.uop_has_imm = 1'b1;
                uop_next.uop_immediate = 32'h1; // unconditional marker
                if (i_dec_modrm_mod == 2'b11) begin
                    uop_next.uop_src1_reg = i_dec_base_reg_is_present ?
                                           i_dec_base_reg_index : 3'b0;
                end else begin
                    uop_next.uop_mem_access     = 1'b1;
                    uop_next.uop_has_disp       = 1'b1;
                    uop_next.uop_displacement   = i_dec_displacement;
                    uop_next.uop_agu_base       = i_dec_base_reg_is_present;
                    uop_next.uop_src1_reg       = i_dec_base_reg_is_present ?
                                                 i_dec_base_reg_index : 3'b0;
                    uop_next.uop_agu_index      = i_dec_index_reg_is_present;
                    uop_next.uop_src2_reg       = i_dec_index_reg_is_present ?
                                                 i_dec_index_reg_index : 3'b0;
                    uop_next.uop_sib_scale      = i_dec_index_reg_is_present ?
                                                 i_dec_sib_scale_factor : 2'b0;
                end
            end else if (i_opcode_call_near_direct || i_opcode_call_near_indirect) begin
                // exu_call: imm = return EIP, src2 = ESP, dest = ESP
                // Direct: disp = absolute target. Indirect reg (FF /2 mod=11):
                // target in src1 (has_disp=0). Mem-indirect: load later.
                uop_next.uop_opcode = `UOP_CALL;
                uop_next.uop_src2_reg = `index_reg_gpr_ESP;
                uop_next.uop_dest_reg = `index_reg_gpr_ESP;
                uop_next.uop_has_imm = 1'b1;
                uop_next.uop_immediate = i_dec_opsz_32 ?
                    (i_insn_eip + {28'h0, i_insn_len}) :
                    {16'h0, i_insn_eip[15: 0] + {12'h0, i_insn_len}};
                uop_next.uop_mem_size = i_dec_opsz_32 ? 2'b10 : 2'b01;
                if (i_opcode_call_near_direct) begin
                    uop_next.uop_has_disp = 1'b1;
                    uop_next.uop_displacement = branch_target_abs;
                end else if (i_dec_modrm_mod == 2'b11) begin
                    // FF /2 r32 (SeaBIOS irqentry_arg: calll *%ecx)
                    uop_next.uop_has_disp = 1'b0;
                    uop_next.uop_src1_reg = i_dec_base_reg_is_present ?
                                           i_dec_base_reg_index : 3'b0;
                end else begin
                    // FF /2 mem: load target; keep src2=ESP for the return push.
                    uop_next.uop_mem_access     = 1'b1;
                    uop_next.uop_has_disp       = 1'b1;
                    uop_next.uop_displacement   = i_dec_displacement;
                    uop_next.uop_agu_base       = i_dec_base_reg_is_present;
                    uop_next.uop_src1_reg       = i_dec_base_reg_is_present ?
                                                 i_dec_base_reg_index : 3'b0;
                    uop_next.uop_agu_index      = i_dec_index_reg_is_present;
                    uop_next.uop_sib_scale      = i_dec_index_reg_is_present ?
                                                 i_dec_sib_scale_factor : 2'b0;
                end
            end else if (i_opcode_ret_near || i_opcode_ret_near_imm) begin
                // exu_ret: src1 = ESP (pop addr), dest = ESP (new ESP)
                uop_next.uop_opcode = `UOP_RET;
                uop_next.uop_src1_reg = `index_reg_gpr_ESP;
                uop_next.uop_dest_reg = `index_reg_gpr_ESP;
                uop_next.uop_has_imm = i_opcode_ret_near_imm;
                uop_next.uop_immediate = i_dec_immediate;
                uop_next.uop_has_disp = i_opcode_ret_near_imm;
                uop_next.uop_displacement = i_dec_displacement;
                uop_next.uop_mem_size = i_dec_opsz_32 ? 2'b10 : 2'b01;
            end else if (i_opcode_loop || i_opcode_loopz || i_opcode_loopnz || i_opcode_jcxz) begin
                uop_next.uop_opcode = `UOP_BRANCH;
                uop_next.uop_has_disp = 1'b1;
                uop_next.uop_displacement = branch_target_abs;
            end else if (i_opcode_jcc_short || i_opcode_jcc_near) begin
                uop_next.uop_opcode = `UOP_BRANCH;
                uop_next.uop_has_disp = 1'b1;
                uop_next.uop_displacement = branch_target_abs;
            end

            // String instructions: MOVS, CMPS, SCAS, LODS, STOS, INS, OUTS
            else if (i_opcode_movs || i_opcode_cmps || i_opcode_scas ||
                     i_opcode_lods || i_opcode_stos || i_opcode_ins || i_opcode_outs) begin
                uop_next.uop_opcode     = `UOP_STRING;
                uop_next.uop_mem_access = 1'b1;
                uop_next.uop_is_store   = i_opcode_stos | i_opcode_movs | i_opcode_outs;
                // Width: W=0 → byte; else opsz selects word/dword
                if (i_gpr_bit_width == `bit_width_gpr__8)
                    uop_next.uop_mem_size = 2'b00;
                else if (~i_dec_opsz_32)
                    uop_next.uop_mem_size = 2'b01;
                else
                    uop_next.uop_mem_size = 2'b10;
                // Kind in imm[3:2]; insn EIP in displacement for REP restart.
                uop_next.uop_has_imm       = 1'b1;
                uop_next.uop_has_disp      = 1'b1;
                uop_next.uop_displacement  = i_insn_eip;
                if (i_opcode_lods) begin
                    uop_next.uop_src1_reg    = `index_reg_gpr_ESI;
                    uop_next.uop_dest_reg    = `index_reg_gpr_ESI;
                    uop_next.uop_seg_index   = `index_reg_seg__DS;
                    uop_next.uop_src2_reg    = `index_reg_gpr_EAX;
                    uop_next.uop_immediate   = {28'h0, `STRING_KIND_LODS, uop_next.uop_mem_size};
                end else if (i_opcode_movs) begin
                    // src1=ESI (DS), src2=EDI (ES dest pointer)
                    uop_next.uop_src1_reg    = `index_reg_gpr_ESI;
                    uop_next.uop_src2_reg    = `index_reg_gpr_EDI;
                    uop_next.uop_dest_reg    = `index_reg_gpr_EDI;
                    uop_next.uop_seg_index   = `index_reg_seg__ES;
                    uop_next.uop_immediate   = {28'h0, `STRING_KIND_MOVS, uop_next.uop_mem_size};
                end else if (i_opcode_cmps) begin
                    uop_next.uop_src1_reg    = `index_reg_gpr_ESI;
                    uop_next.uop_src2_reg    = `index_reg_gpr_EDI;
                    uop_next.uop_dest_reg    = `index_reg_gpr_EDI;
                    uop_next.uop_seg_index   = `index_reg_seg__ES;
                    uop_next.uop_is_store     = 1'b0;
                    uop_next.uop_immediate   = {28'h0, `STRING_KIND_CMPS, uop_next.uop_mem_size};
                end else begin
                    // STOS / SCAS / INS / OUTS: ES:EDI, data in EAX
                    uop_next.uop_src1_reg    = `index_reg_gpr_EDI;
                    uop_next.uop_dest_reg    = `index_reg_gpr_EDI;
                    uop_next.uop_seg_index   = `index_reg_seg__ES;
                    uop_next.uop_src2_reg    = `index_reg_gpr_EAX;
                    uop_next.uop_immediate   = {28'h0, `STRING_KIND_STOS, uop_next.uop_mem_size};
                end
            end

            // Bit manipulation instructions: BT, BTS, BTR, BTC, BSF, BSR
            else if (i_opcode_bt_imm || i_opcode_bt_reg) begin
                uop_next.uop_opcode = `UOP_BT;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_has_imm = i_opcode_bt_imm;
                uop_next.uop_immediate = i_dec_immediate;
            end else if (i_opcode_bts_imm || i_opcode_bts_reg) begin
                uop_next.uop_opcode = `UOP_BTS;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_has_imm = i_opcode_bts_imm;
                uop_next.uop_immediate = i_dec_immediate;
            end else if (i_opcode_btr_imm || i_opcode_btr_reg) begin
                uop_next.uop_opcode = `UOP_BTR;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_has_imm = i_opcode_btr_imm;
                uop_next.uop_immediate = i_dec_immediate;
            end else if (i_opcode_btc_imm || i_opcode_btc_reg) begin
                uop_next.uop_opcode = `UOP_BTC;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_has_imm = i_opcode_btc_imm;
                uop_next.uop_immediate = i_dec_immediate;
            end else if (i_opcode_bsf) begin
                uop_next.uop_opcode = `UOP_BSF;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_src1_reg = i_dec_index_reg_is_present ? i_dec_index_reg_index : 3'b0;
            end else if (i_opcode_bsr) begin
                uop_next.uop_opcode = `UOP_BSR;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_src1_reg = i_dec_index_reg_is_present ? i_dec_index_reg_index : 3'b0;
            end

            // Flag control instructions: CLC, STC, CMC, CLD, STD, CLI, STI, LAHF, SAHF
            else if (i_opcode_clc) begin
                uop_next.uop_opcode = `UOP_FLAG_CTRL;
                uop_next.uop_immediate = {24'h0, 8'h01};
            end else if (i_opcode_stc) begin
                uop_next.uop_opcode = `UOP_FLAG_CTRL;
                uop_next.uop_immediate = {24'h0, 8'h02};
            end else if (i_opcode_cmc) begin
                uop_next.uop_opcode = `UOP_FLAG_CTRL;
                uop_next.uop_immediate = {24'h0, 8'h03};
            end else if (i_opcode_cld || i_opcode_std || i_opcode_cli || i_opcode_sti ||
                     i_opcode_lahf || i_opcode_sahf) begin
                uop_next.uop_opcode = `UOP_FLAG_CTRL;
                uop_next.uop_immediate = {24'h0,
                    i_opcode_cld ? 8'h04 :
                    i_opcode_std ? 8'h05 :
                    i_opcode_cli ? 8'h06 :
                    i_opcode_sti ? 8'h07 :
                    i_opcode_lahf ? 8'h08 : 8'h09};
            end

            // Other instructions: NOP, BSWAP, XADD, CMPXCHG, SETcc, XLAT, CBW, CWDE, CDQ
            else if (i_opcode_nop || i_opcode_nop_multibyte) begin
                uop_next.uop_opcode = `UOP_NOP;
            end             else if (i_opcode_bswap) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_BSWAP};
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
            end else if (i_opcode_xadd) begin
                uop_next.uop_opcode = `UOP_XADD;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_src1_reg = i_dec_index_reg_is_present ? i_dec_index_reg_index : 3'b0;
            end else if (i_opcode_cmpxchg) begin
                uop_next.uop_opcode = `UOP_CMPXCHG;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_src1_reg = i_dec_index_reg_is_present ? i_dec_index_reg_index : 3'b0;
            end else if (i_opcode_setcc) begin
                uop_next.uop_opcode = `UOP_SETCC;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
            end else if (i_opcode_xlat) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_XLAT};
                uop_next.uop_mem_access = 1'b1;
            end else if (i_opcode_cbw) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_CBW};
                uop_next.uop_dest_reg = 3'd0; // EAX/AX
                uop_next.uop_src1_reg = 3'd0;
            end else if (i_opcode_cwde) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_CWDE};
                uop_next.uop_dest_reg = 3'd0;
                uop_next.uop_src1_reg = 3'd0;
            end else if (i_opcode_cdq || i_opcode_cwd) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_CDQ};
                uop_next.uop_dest_reg = 3'd2; // EDX
                uop_next.uop_src1_reg = 3'd0; // EAX
            end

            // x87 instructions
            else if (i_opcode_x87_esc) begin
                uop_next.uop_opcode     = `UOP_X87;
                uop_next.uop_eee        = {1'b0, i_x87_exe_subop};
                uop_next.uop_src2_reg   = i_x87_sti;
                uop_next.uop_mem_access = i_x87_mem_access;
                uop_next.uop_is_store   = i_x87_is_store;
                if (i_x87_mem_access) begin
                    uop_next.uop_has_disp = (i_dec_modrm_mod != 2'b11);
                    uop_next.uop_displacement = i_dec_displacement;
                    uop_next.uop_src1_reg = i_dec_base_reg_is_present ?
                                            i_dec_base_reg_index : 3'b0;
                end
            end

            // Post-486 decode noise: raise #UD (not in 80486DX ISA contract)
            else if (i_opcode_mmx_emms || i_opcode_mmx_any || i_opcode_sse_any) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_UD};
            end

            // CPUID
            else if (i_opcode_cpuid) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_CPUID};
                uop_next.uop_src1_reg = 3'd0; // EAX
                uop_next.uop_src2_reg = 3'd1; // ECX
            end

            // BCD adjust
            else if (i_opcode_aaa) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_AAA};
            end else if (i_opcode_aas) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_AAS};
            end else if (i_opcode_daa) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_DAA};
            end else if (i_opcode_das) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_DAS};
            end else if (i_opcode_aad) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_AAD};
            end else if (i_opcode_aam) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_AAM};
            end

            // System instructions (HLT, INT, IRET, etc.)
            else if (i_opcode_hlt) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_HLT};
            end else if (i_opcode_invd) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_INVD};
            end else if (i_opcode_invlpg) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_INVLPG};
            end else if (i_opcode_wbinvd) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_WBINVD};
            end else if (i_opcode_int_n) begin
                // Soft INT pushes next EIP (not RF EIP — RF only updates on branches).
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {16'h0, i_dec_immediate[7: 0], `MISC_SUB_INT};
                uop_next.uop_has_disp = 1'b1;
                uop_next.uop_displacement = i_insn_eip + {28'h0, i_insn_len};
            end else if (i_opcode_int_3) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {16'h0, 8'h03, `MISC_SUB_INT};
                uop_next.uop_has_disp = 1'b1;
                uop_next.uop_displacement = i_insn_eip + {28'h0, i_insn_len};
            end else if (i_opcode_int_4) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {16'h0, 8'h04, `MISC_SUB_INT};
                uop_next.uop_has_disp = 1'b1;
                uop_next.uop_displacement = i_insn_eip + {28'h0, i_insn_len};
            end else if (i_opcode_iret) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_IRET};
            end else if (i_opcode_invpcid ||
                     i_opcode_rdmsr || i_opcode_wrmsr || i_opcode_rdtsc || i_opcode_rdtscp ||
                     i_opcode_rdpmc || i_opcode_rsm) begin
                // Post-486 / unimplemented system → #UD
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_UD};
            end else if (i_opcode_wait) begin
                // WAIT: treat as NOP when no pending FPU exception (486DX subset)
                uop_next.uop_opcode = `UOP_NOP;
            end

            // Segment/Privilege instructions
            else if (i_opcode_lgdt) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_LGDT};
                uop_next.uop_mem_access = 1'b1;
                uop_next.uop_has_disp = (i_dec_modrm_mod != 2'b11);
                uop_next.uop_displacement = i_dec_displacement;
                uop_next.uop_src1_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_agu_base = i_dec_base_reg_is_present;
            end else if (i_opcode_lidt) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_LIDT};
                uop_next.uop_mem_access = 1'b1;
                uop_next.uop_has_disp = (i_dec_modrm_mod != 2'b11);
                uop_next.uop_displacement = i_dec_displacement;
                uop_next.uop_src1_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_agu_base = i_dec_base_reg_is_present;
            end else if (i_opcode_sgdt) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_SGDT};
                uop_next.uop_mem_access = 1'b1;
                uop_next.uop_is_store = 1'b1;
                uop_next.uop_has_disp = (i_dec_modrm_mod != 2'b11);
                uop_next.uop_displacement = i_dec_displacement;
                uop_next.uop_src1_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_agu_base = i_dec_base_reg_is_present;
            end else if (i_opcode_sidt) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_SIDT};
                uop_next.uop_mem_access = 1'b1;
                uop_next.uop_is_store = 1'b1;
                uop_next.uop_has_disp = (i_dec_modrm_mod != 2'b11);
                uop_next.uop_displacement = i_dec_displacement;
                uop_next.uop_src1_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_agu_base = i_dec_base_reg_is_present;
            end else if (i_opcode_lmsw || i_opcode_mov_cr_from_reg) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, i_opcode_lmsw ? `MISC_SUB_LMSW : `MISC_SUB_MOV_CR};
                // MOV CRn,r32: eee selects CRn; r/m (base) is the GPR source.
                // LMSW always targets CR0; source is r/m.
                uop_next.uop_dest_reg = i_opcode_lmsw ? 3'd0 : i_eee;
                uop_next.uop_src2_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
            end else if (i_opcode_mov_reg_from_cr) begin
                // MOV r32,CRn — SeaBIOS PE entry reads CR0 into ECX.
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_MOV_FROM_CR};
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
            end else if (i_opcode_clts) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_CLTS};
            end else if (i_opcode_smsw) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_SMSW};
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
            end else if (i_opcode_lldt) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_LLDT};
            end else if (i_opcode_ltr) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_LTR};
            end else if (i_opcode_lar) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_LAR};
            end else if (i_opcode_lsl) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_LSL};
            end else if (i_opcode_verr) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_VERR};
            end else if (i_opcode_verw) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_VERW};
            end else if (i_opcode_arpl) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_ARPL};
            end else if (i_opcode_bound) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_BOUND};
                uop_next.uop_mem_access = 1'b1;
            end else if (i_opcode_leave) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_LEAVE};
                uop_next.uop_dest_reg = 3'd5; // EBP receives POP; ESP via special enable
            end else if (i_opcode_lds) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_LDS};
                uop_next.uop_mem_access = 1'b1;
                uop_next.uop_mem_size = 2'b10; // offset:selector dword in 16-bit opsize
                uop_next.uop_dest_reg = i_eee;
                uop_next.uop_src1_reg = i_dec_base_reg_is_present ?
                                        i_dec_base_reg_index : 3'b0;
                uop_next.uop_agu_base = i_dec_base_reg_is_present;
                uop_next.uop_agu_index = i_dec_index_reg_is_present;
                uop_next.uop_src2_reg = i_dec_index_reg_is_present ?
                                        i_dec_index_reg_index : 3'b0;
                uop_next.uop_has_disp = 1'b1;
                uop_next.uop_displacement = i_dec_displacement;
            end else if (i_opcode_les) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_LES};
                uop_next.uop_mem_access = 1'b1;
                uop_next.uop_mem_size = 2'b10;
                uop_next.uop_dest_reg = i_eee;
                uop_next.uop_src1_reg = i_dec_base_reg_is_present ?
                                        i_dec_base_reg_index : 3'b0;
                uop_next.uop_agu_base = i_dec_base_reg_is_present;
                uop_next.uop_agu_index = i_dec_index_reg_is_present;
                uop_next.uop_src2_reg = i_dec_index_reg_is_present ?
                                        i_dec_index_reg_index : 3'b0;
                uop_next.uop_has_disp = 1'b1;
                uop_next.uop_displacement = i_dec_displacement;
            end else if (i_opcode_lfs) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_LFS};
                uop_next.uop_mem_access = 1'b1;
                uop_next.uop_mem_size = 2'b10;
                uop_next.uop_dest_reg = i_eee;
                uop_next.uop_src1_reg = i_dec_base_reg_is_present ?
                                        i_dec_base_reg_index : 3'b0;
                uop_next.uop_agu_base = i_dec_base_reg_is_present;
                uop_next.uop_has_disp = 1'b1;
                uop_next.uop_displacement = i_dec_displacement;
            end else if (i_opcode_lgs) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_LGS};
                uop_next.uop_mem_access = 1'b1;
                uop_next.uop_mem_size = 2'b10;
                uop_next.uop_dest_reg = i_eee;
                uop_next.uop_src1_reg = i_dec_base_reg_is_present ?
                                        i_dec_base_reg_index : 3'b0;
                uop_next.uop_agu_base = i_dec_base_reg_is_present;
                uop_next.uop_has_disp = 1'b1;
                uop_next.uop_displacement = i_dec_displacement;
            end else if (i_opcode_lss) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_LSS};
                uop_next.uop_mem_access = 1'b1;
                uop_next.uop_mem_size = 2'b10;
                uop_next.uop_dest_reg = i_eee;
                uop_next.uop_src1_reg = i_dec_base_reg_is_present ?
                                        i_dec_base_reg_index : 3'b0;
                uop_next.uop_agu_base = i_dec_base_reg_is_present;
                uop_next.uop_has_disp = 1'b1;
                uop_next.uop_displacement = i_dec_displacement;
            end else if (i_opcode_push_sreg_2 || i_opcode_push_sreg_3) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {13'h0, i_dec_target_sreg_index, `MISC_SUB_PUSH_SEG};
                uop_next.uop_src2_reg = `index_reg_gpr_ESP;
                uop_next.uop_dest_reg = `index_reg_gpr_ESP;
                uop_next.uop_seg_index = `index_reg_seg__SS;
                // Real-mode / 16-bit opsize: PUSH Sreg is always a 16-bit stack slot
                uop_next.uop_mem_size = (~i_dec_opsz_32) ? 2'b01 : 2'b10;
            end else if (i_opcode_pop_sreg_2 || i_opcode_pop_sreg_3) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {13'h0, i_dec_target_sreg_index, `MISC_SUB_POP_SEG};
                uop_next.uop_src1_reg = `index_reg_gpr_ESP;
                uop_next.uop_dest_reg = `index_reg_gpr_ESP;
                uop_next.uop_seg_index = `index_reg_seg__SS;
                uop_next.uop_mem_size = (~i_dec_opsz_32) ? 2'b01 : 2'b10;
            end else if (i_opcode_str || i_opcode_sldt ||
                         i_opcode_mov_dr_from_reg || i_opcode_mov_reg_from_dr ||
                         i_opcode_mov_tr_from_reg || i_opcode_mov_reg_from_tr) begin
                // Partially wired debug/test register ops — #UD until complete
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_UD};
            end

            // I/O instructions (IN, OUT).
            // immediate[7:0]  = MISC_SUB_*; immediate[23:8] = port (imm8 zero-ext
            // or DX placeholder); immediate[31] = 1 → port is DX (src1).
            else if (i_opcode_in_fixed || i_opcode_in_var) begin
                uop_next.uop_opcode = `UOP_MISC;
                if (i_opcode_in_fixed)
                    uop_next.uop_immediate = {8'h0, 8'h0, i_dec_immediate[7: 0], `MISC_SUB_IN};
                else begin
                    uop_next.uop_immediate = {8'h80, 16'h0, `MISC_SUB_IN};
                    uop_next.uop_src1_reg  = 3'd2; // EDX holds DX port
                end
                uop_next.uop_dest_reg = 3'd0; // AL/AX/EAX
                // Width must follow opsize (66 prefix → inw), not default dword.
                if (i_gpr_bit_width == `bit_width_gpr__8)
                    uop_next.uop_mem_size = 2'b00;
                else if (~i_dec_opsz_32)
                    uop_next.uop_mem_size = 2'b01;
                else
                    uop_next.uop_mem_size = 2'b10;
            end else if (i_opcode_out_fixed || i_opcode_out_var) begin
                uop_next.uop_opcode = `UOP_MISC;
                if (i_opcode_out_fixed)
                    uop_next.uop_immediate = {8'h0, 8'h0, i_dec_immediate[7: 0], `MISC_SUB_OUT};
                else begin
                    uop_next.uop_immediate = {8'h80, 16'h0, `MISC_SUB_OUT};
                    uop_next.uop_src1_reg  = 3'd2; // EDX holds DX port
                end
                uop_next.uop_src2_reg = 3'd0; // AL/AX/EAX data
                if (i_gpr_bit_width == `bit_width_gpr__8)
                    uop_next.uop_mem_size = 2'b00;
                else if (~i_dec_opsz_32)
                    uop_next.uop_mem_size = 2'b01;
                else
                    uop_next.uop_mem_size = 2'b10;
            end

            // Explicit undefined opcodes
            else if (i_opcode_ud0 || i_opcode_ud1 || i_opcode_ud2) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_UD};
            end

            // Unmapped decode → architectural #UD (never silent NOP)
            else begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_UD};
            end
        end
    end

    // ============================================================
    // Output assignment
    // ============================================================
    assign o_uop = uop_next;

endmodule
