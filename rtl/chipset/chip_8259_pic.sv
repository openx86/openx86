/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements chip_8259_pic.
*/
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
    input  logic         i_cs_n, // 低有效片选
    input  logic         i_rd_n, // 低有效读
    input  logic         i_wr_n, // 低有效写
    input  logic         i_a0, // 0=命令口，1=数据口
    input  logic [ 7: 0] i_d, // 写数据
    output logic [ 7: 0] o_d, // 读数据
    input  logic [ 7: 0] i_ir, // 中断请求输入 IR7..IR0
    output logic         o_intr, // 向 CPU 输出的中断请求
    input  logic         rst_n, // 异步低有效复位
    input  logic         clk // 系统时钟
);

    typedef enum logic [ 2: 0] {
        ST_RESET,  // 等待 ICW1
        ST_ICW2,   // 收 ICW2（向量基址）
        ST_ICW3,   // 收 ICW3（级联/从片标识）
        ST_ICW4,   // 收 ICW4（模式位）
        ST_READY   // 运行态：数据口写 OCW1(IMR)
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

    pic_state_e          state, state_n;       // 初始化 FSM 现态/次态
    logic                need_icw3, need_icw3_n;  // 是否需要 ICW3
    logic                need_icw4, need_icw4_n;  // 是否需要 ICW4
    logic                ltim, ltim_n;       // 1=电平触发，0=边沿触发
    logic                aeoi, aeoi_n;       // 自动 EOI
    logic                read_isr, read_isr_n; // 0 读 IRR，1 读 ISR
    logic [ 7: 0]        icw1, icw1_n;
    logic [ 7: 0]        icw2_vec, icw2_vec_n; // 中断向量基址（高 5 位等）
    logic [ 7: 0]        icw3, icw3_n;
    logic [ 7: 0]        icw4, icw4_n;
    logic [ 7: 0]        imr, imr_n;           // 中断屏蔽
    logic [ 7: 0]        irr, irr_n;           // 请求寄存器
    logic [ 7: 0]        isr, isr_n;           // 服务寄存器
    logic [ 7: 0]        ir_prev, ir_prev_n;  // IR 前一拍（边沿检测）

    logic                wr;
    logic                rd;
    logic [ 7: 0]        masked_irr, masked_irr_n;  // 屏蔽后的 IRR
    logic                pending_valid, pending_valid_n;  // 存在未屏蔽请求
    logic [ 2: 0]        pending_idx, pending_idx_n;      // 当前最高优先级请求索引
    logic                isr_valid, isr_valid_n;          // ISR 非空
    logic [ 2: 0]        isr_idx, isr_idx_n;                // 正在服务的中断索引
    logic                irq_eligible, irq_eligible_n;    // 可拉 INTR（含嵌套规则）

    assign wr = !i_cs_n && !i_wr_n;
    assign rd = !i_cs_n && !i_rd_n;

    // 屏蔽 IRR、优先级索引与 INTR 条件（基于现态寄存器）。
    always_comb begin
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
