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
//  File        : misc_loop_ctrl.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : misc_loop_ctrl module
// ============================================================================

module misc_loop_ctrl (    input  logic [31: 0]  ecx,  // ECX 当前值
    input  logic          zf, // 零标志
    input  logic [ 1: 0]   mode, // LOOP 族模式
    output logic [31: 0] ecx_next, // LOOP 后 ECX
    output logic         taken // 条件成立 / 跳转
);
    // 组合逻辑：推导输出
    always_comb begin
        // LOOP / LOOPE / LOOPNE：ECX 递减后与 ZF 组合
        unique case (mode)
            2'b00: begin
                ecx_next = ecx - 32'd1;
                taken = (ecx_next != 32'd0);
            end
            2'b01: begin
                ecx_next = ecx - 32'd1;
                taken = (ecx_next != 32'd0) && zf;
            end
            2'b10: begin
                ecx_next = ecx - 32'd1;
                taken = (ecx_next != 32'd0) && !zf;
            end
            default: begin
                ecx_next = ecx;
                taken = (ecx == 32'd0);
            end
        endcase
    end
endmodule
