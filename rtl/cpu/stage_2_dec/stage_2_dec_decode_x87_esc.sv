/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements stage_2_dec_decode_x87_esc.
*/
// ============================================================================
// X87 FPU — ESC D8h–DFh 译码（第二字节通常为 ModR/M）
// ============================================================================

`include "openx86_defs.h.sv"

module stage_2_dec_decode_x87_esc (
    input  logic [ 7: 0]   i_b0,
    input  logic [ 7: 0]   i_b1,
    output logic         o_is_esc,
    output logic [ 1: 0] o_mod,
    output logic [ 2: 0] o_reg,
    output logic [ 2: 0] o_rm,
    output logic [ 2: 0] o_esc_group,
    output logic [31: 0] o_opmask,
    output logic         o_modrm_required,
    output logic         o_memory_operand
);
    logic [ 7: 0] esc;
    logic [ 7: 0] mr;

    assign esc = i_b0;
    assign mr = i_b1;

    assign o_mod = mr[ 7:  6];
    assign o_reg = mr[ 5:  3];
    assign o_rm  = mr[ 2: 0];

    assign o_is_esc = (esc[ 7:  3] == 5'b11011);
    assign o_esc_group = esc[ 2: 0];
    assign o_modrm_required = o_is_esc;
    assign o_memory_operand = o_is_esc && (o_mod != 2'b11);

    // 粗粒度 ESC 译码：内存形式优先按 esc 选择存取模板；寄存器形式按 reg/整字节再细分
    always_comb begin
        o_opmask = 32'h0;
        if (!o_is_esc) begin
            ;
        end else if (o_mod != 2'b11) begin
            unique case (esc)
                8'hD8: o_opmask[`X87_MASK_M_FADD_ST0_STI] = 1'b1;
                8'hD9: o_opmask[`X87_MASK_M_FLD_M32]      = 1'b1;
                8'hDA: o_opmask[`X87_MASK_M_FILD_M32]     = 1'b1;
                8'hDB: o_opmask[`X87_MASK_M_FILD_M32]     = 1'b1;
                8'hDC: o_opmask[`X87_MASK_M_FADD_ST0_STI] = 1'b1;
                8'hDD: o_opmask[`X87_MASK_M_FSTP_M32]     = 1'b1;
                8'hDE: o_opmask[`X87_MASK_M_FADDP_STI_ST0]= 1'b1;
                8'hDF: o_opmask[`X87_MASK_M_FILD_M32]     = 1'b1;
                default: o_opmask[`X87_MASK_M_RESERVED]   = 1'b1;
            endcase
        end else begin
            unique case (esc)
                8'hD8: begin
                    unique case (o_reg)
                        3'b000: o_opmask[`X87_MASK_M_FADD_ST0_STI]   = 1'b1;
                        3'b001: o_opmask[`X87_MASK_M_FMUL_ST0_STI]   = 1'b1;
                        3'b010: o_opmask[`X87_MASK_M_FCOM_STI]      = 1'b1;
                        3'b011: o_opmask[`X87_MASK_M_FCOMP_STI]     = 1'b1;
                        3'b100: o_opmask[`X87_MASK_M_FSUB_ST0_STI]  = 1'b1;
                        3'b101: o_opmask[`X87_MASK_M_FSUBR_ST0_STI] = 1'b1;
                        3'b110: o_opmask[`X87_MASK_M_FDIV_ST0_STI]  = 1'b1;
                        default: o_opmask[`X87_MASK_M_FDIVR_ST0_STI] = 1'b1;
                    endcase
                end
                8'hD9: begin
                    if (mr == 8'hD0)
                        o_opmask[`X87_MASK_M_FNOP] = 1'b1;
                    else if (mr == 8'hE0)
                        o_opmask[`X87_MASK_M_FCHS] = 1'b1;
                    else if (mr == 8'hE1)
                        o_opmask[`X87_MASK_M_FABS] = 1'b1;
                    else if (mr == 8'hE4)
                        o_opmask[`X87_MASK_M_FTST] = 1'b1;
                    else if (mr == 8'hE8)
                        o_opmask[`X87_MASK_M_FLD1] = 1'b1;
                    else if (mr == 8'hEE)
                        o_opmask[`X87_MASK_M_FLDZ] = 1'b1;
                    else if (o_reg == 3'b000)
                        o_opmask[`X87_MASK_M_FLD_STI] = 1'b1;
                    else if (o_reg == 3'b001)
                        o_opmask[`X87_MASK_M_FXCH_STI] = 1'b1;
                    else if (o_reg == 3'b010)
                        o_opmask[`X87_MASK_M_FST_STI] = 1'b1;
                    else if (o_reg == 3'b011)
                        o_opmask[`X87_MASK_M_FSTP_STI] = 1'b1;
                    else if (o_reg == 3'b100)
                        o_opmask[`X87_MASK_M_FFREE_STI] = 1'b1;
                    else
                        o_opmask[`X87_MASK_M_RESERVED] = 1'b1;
                end
                8'hDA: begin
                    o_opmask[`X87_MASK_M_RESERVED] = 1'b1;
                end
                8'hDB: begin
                    if (o_reg == 3'b111)
                        o_opmask[`X87_MASK_M_FCOMIP_STI] = 1'b1;
                    else
                        o_opmask[`X87_MASK_M_FILD_M32] = 1'b1;
                end
                8'hDC: begin
                    unique case (o_reg)
                        3'b000: o_opmask[`X87_MASK_M_FADD_ST0_STI]   = 1'b1;
                        3'b001: o_opmask[`X87_MASK_M_FMUL_ST0_STI]   = 1'b1;
                        3'b010: o_opmask[`X87_MASK_M_FCOM_STI]      = 1'b1;
                        3'b011: o_opmask[`X87_MASK_M_FCOMP_STI]     = 1'b1;
                        3'b100: o_opmask[`X87_MASK_M_FSUB_ST0_STI]  = 1'b1;
                        3'b101: o_opmask[`X87_MASK_M_FSUBR_ST0_STI] = 1'b1;
                        3'b110: o_opmask[`X87_MASK_M_FDIV_ST0_STI]  = 1'b1;
                        default: o_opmask[`X87_MASK_M_FDIVR_ST0_STI] = 1'b1;
                    endcase
                end
                8'hDD: begin
                    unique case (o_reg)
                        3'b000: o_opmask[`X87_MASK_M_FLD_STI]  = 1'b1;
                        3'b001: o_opmask[`X87_MASK_M_FXCH_STI] = 1'b1;
                        3'b010: o_opmask[`X87_MASK_M_FST_STI]  = 1'b1;
                        3'b011: o_opmask[`X87_MASK_M_FSTP_STI] = 1'b1;
                        3'b100: o_opmask[`X87_MASK_M_FFREE_STI]= 1'b1;
                        3'b110: o_opmask[`X87_MASK_M_FCOMIP_STI]= 1'b1;
                        default: o_opmask[`X87_MASK_M_RESERVED] = 1'b1;
                    endcase
                end
                8'hDE: begin
                    unique case (o_reg)
                        3'b000: o_opmask[`X87_MASK_M_FADDP_STI_ST0]  = 1'b1;
                        3'b001: o_opmask[`X87_MASK_M_FMULP_STI_ST0]  = 1'b1;
                        3'b010: o_opmask[`X87_MASK_M_FCOMP_STI]     = 1'b1;
                        3'b011: o_opmask[`X87_MASK_M_FCOMIP_STI]    = 1'b1;
                        3'b100: o_opmask[`X87_MASK_M_FSUBP_STI_ST0] = 1'b1;
                        3'b101: o_opmask[`X87_MASK_M_FSUBRP_STI_ST0]= 1'b1;
                        3'b110: o_opmask[`X87_MASK_M_FDIVP_STI_ST0] = 1'b1;
                        default: o_opmask[`X87_MASK_M_FDIVRP_STI_ST0]= 1'b1;
                    endcase
                end
                8'hDF: begin
                    unique case (o_reg)
                        3'b000: o_opmask[`X87_MASK_M_FILD_M32]  = 1'b1;
                        3'b001: o_opmask[`X87_MASK_M_FISTP_M32] = 1'b1;
                        default: o_opmask[`X87_MASK_M_RESERVED] = 1'b1;
                    endcase
                end
                default: o_opmask[`X87_MASK_M_RESERVED] = 1'b1;
            endcase
        end
    end

endmodule
