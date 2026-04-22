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
//  File        : chip_8259_pic.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : chip_8259_pic module
// ============================================================================

// ============================================================================
// Intel 8259 PIC — 单片模型（可级联）
// 主机接口：ISA 式 nCS/nRD/nWR + A0（0=命令口，1=数据口）
// 实现要点：
//   - ICW1..ICW4 初始化流程（SNGL/IC4/LTIM）
//   - OCW1(IMR)、OCW2(EOI)、OCW3(IRR/ISR 读选择)
//   - 全嵌套优先级（IR0 最高，IR7 最低）
//   - LTIM=0 边沿触发，LTIM=1 电平触发
// 说明：该模块接口不含 INTA，内部使用“自动应答”近似来推进 IRR/ISR。
// ============================================================================

module chip_8259_pic (
    // =========================
    // CPU bus interface
    // =========================
    input  logic         i_cs_n,
    input  logic         i_rd_n,
    input  logic         i_wr_n,
    input  logic         i_a0,
    input  logic [ 7: 0] i_d,
    output logic [ 7: 0] o_d,

    // =========================
    // interrupt interface
    // =========================
    input  logic [ 7: 0] i_ir,
    output logic         o_intr,

    // =========================
    // clock and reset
    // =========================
    input  logic         clk,
    input  logic         rst_n
);

    // ============================================================
    // PIC initialization state machine
    // ============================================================
    typedef enum logic [ 2: 0] {
        ST_RESET,  // waiting for ICW1
        ST_ICW2,   // receive ICW2 (vector base)
        ST_ICW3,   // receive ICW3 (cascade/slave ID)
        ST_ICW4,   // receive ICW4 (mode bits)
        ST_READY   // running state: data port writes OCW1(IMR)
    } pic_state_e;

    function automatic logic [ 2: 0] f_highest_prio_idx(input logic [ 7: 0] i_vec);
        logic found;
        integer i;
        begin
            f_highest_prio_idx = 3'd0;
            found              = 1'b0;
            for (i = 0; i < 8; i = i + 1) begin
                if (!found && i_vec[i]) begin
                    f_highest_prio_idx = i[2: 0];
                    found              = 1'b1;
                end
            end
        end
    endfunction

    // ============================================================
    // initialization FSM state and configuration
    // ============================================================
    pic_state_e          state, state_n;
    logic                need_icw3, need_icw3_n;
    logic                need_icw4, need_icw4_n;
    logic                ltim, ltim_n;
    logic                aeoi, aeoi_n;
    logic                read_isr, read_isr_n;
    logic [ 7: 0]        icw1, icw1_n;
    logic [ 7: 0]        icw2_vec, icw2_vec_n;
    logic [ 7: 0]        icw3, icw3_n;
    logic [ 7: 0]        icw4, icw4_n;

    // ============================================================
    // interrupt registers
    // ============================================================
    logic [ 7: 0]        imr, imr_n;
    logic [ 7: 0]        irr, irr_n;
    logic [ 7: 0]        isr, isr_n;
    logic [ 7: 0]        ir_prev, ir_prev_n;

    // ============================================================
    // interrupt priority and eligibility
    // ============================================================
    logic                wr;
    logic                rd;
    logic [ 7: 0]        masked_irr, masked_irr_n;
    logic                pending_valid, pending_valid_n;
    logic [ 2: 0]        pending_idx, pending_idx_n;
    logic                isr_valid, isr_valid_n;
    logic [ 2: 0]        isr_idx, isr_idx_n;
    logic                irq_eligible, irq_eligible_n;

    assign wr          = !i_cs_n && !i_wr_n;
    assign rd          = !i_cs_n && !i_rd_n;

    // ============================================================
    // masked IRR, priority index, and INTR condition
    // ============================================================
    always_comb begin : comb_priority_logic
        masked_irr    = irr & ~imr;
        pending_valid = |masked_irr;
        pending_idx   = f_highest_prio_idx(masked_irr);
        isr_valid     = |isr;
        isr_idx       = f_highest_prio_idx(isr);

        irq_eligible  = (state == ST_READY) && pending_valid && (!isr_valid || (pending_idx < isr_idx));
    end

    assign o_intr = irq_eligible;

    // 次态与写副作用：ICW/OCW 译码、IRR 采样、内部 INTA 近似。
    always_comb begin
        state_n      = state;
        need_icw3_n  = need_icw3;
        need_icw4_n  = need_icw4;
        ltim_n       = ltim;
        aeoi_n       = aeoi;
        read_isr_n   = read_isr;
        icw1_n       = icw1;
        icw2_vec_n   = icw2_vec;
        icw3_n       = icw3;
        icw4_n       = icw4;
        imr_n        = imr;
        irr_n        = irr;
        isr_n        = isr;
        ir_prev_n    = ir_prev;

        if (ltim)
            irr_n = i_ir;
        else
            irr_n = irr | ((~ir_prev) & i_ir);

        ir_prev_n = i_ir;

        if (wr) begin
            if (i_a0 == 1'b0) begin
                // 命令口：ICW1（D4=1）或 OCW2/OCW3
                if (i_d[4]) begin
                    icw1_n      = i_d;
                    need_icw3_n = !i_d[1];
                    need_icw4_n = i_d[0];
                    ltim_n      = i_d[3];
                    aeoi_n      = 1'b0;
                    read_isr_n  = 1'b0;
                    icw4_n      = 8'h00;
                    imr_n       = 8'h00;
                    irr_n       = 8'h00;
                    isr_n       = 8'h00;
                    ir_prev_n   = i_ir;
                    state_n     = ST_ICW2;
                end else if (state == ST_READY) begin
                    if (i_d[3]) begin
                        // OCW3：读 IRR/ISR 选择
                        if (i_d[1]) begin
                            read_isr_n = i_d[0];
                        end
                    end else begin
                        // OCW2：EOI 与非特定 EOI
                        if (i_d[5]) begin
                            if (i_d[6]) begin
                                isr_n[i_d[2: 0]] = 1'b0;
                            end else if (|isr_n) begin
                                isr_n[f_highest_prio_idx(isr_n)] = 1'b0;
                            end
                        end
                    end
                end
            end else begin
                // 数据口：ICW2/3/4 序列或运行态 IMR(OCW1)
                unique case (state)
                    ST_RESET: ;
                    ST_ICW2: begin
                        icw2_vec_n = i_d;
                        if (need_icw3)
                            state_n = ST_ICW3;
                        else if (need_icw4)
                            state_n = ST_ICW4;
                        else
                            state_n = ST_READY;
                    end
                    ST_ICW3: begin
                        icw3_n = i_d;
                        if (need_icw4)
                            state_n = ST_ICW4;
                        else
                            state_n = ST_READY;
                    end
                    ST_ICW4: begin
                        icw4_n  = i_d;
                        aeoi_n  = i_d[1];
                        state_n = ST_READY;
                    end
                    ST_READY: begin
                        imr_n = i_d;
                    end
                endcase
            end
        end

        masked_irr_n   = irr_n & ~imr_n;
        pending_valid_n = |masked_irr_n;
        pending_idx_n  = f_highest_prio_idx(masked_irr_n);
        isr_valid_n    = |isr_n;
        isr_idx_n      = f_highest_prio_idx(isr_n);
        irq_eligible_n = (state_n == ST_READY) && pending_valid_n && (!isr_valid_n || (pending_idx_n < isr_idx_n));

        // 无写且可服务：内部“自动 INTA”清 IRR、置 ISR（非 AEOI）。
        if (!wr && irq_eligible_n) begin
            irr_n[pending_idx_n] = 1'b0;
            if (!aeoi_n) begin
                isr_n[pending_idx_n] = 1'b1;
            end
        end
    end

    // 寄存器采样次态（IRR/ISR 等由组合块计算）。
    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            state      <= ST_RESET;
            need_icw3  <= 1'b0;
            need_icw4  <= 1'b0;
            ltim       <= 1'b0;
            aeoi       <= 1'b0;
            read_isr   <= 1'b0;
            icw1       <= '0;
            icw2_vec   <= '0;
            icw3       <= '0;
            icw4       <= '0;
            imr        <= 8'hFF;
            irr        <= '0;
            isr        <= '0;
            ir_prev    <= '0;
        end else begin
            state      <= state_n;
            need_icw3  <= need_icw3_n;
            need_icw4  <= need_icw4_n;
            ltim       <= ltim_n;
            aeoi       <= aeoi_n;
            read_isr   <= read_isr_n;
            icw1       <= icw1_n;
            icw2_vec   <= icw2_vec_n;
            icw3       <= icw3_n;
            icw4       <= icw4_n;
            imr        <= imr_n;
            irr        <= irr_n;
            isr        <= isr_n;
            ir_prev    <= ir_prev_n;
        end
    end

    // 读：命令口返回 IRR 或 ISR；数据口返回 IMR。
    always_comb begin
        o_d = 8'hFF;
        if (rd) begin
            if (i_a0 == 1'b0)
                o_d = read_isr ? isr : irr;
            else
                o_d = imr;
        end
    end

endmodule
