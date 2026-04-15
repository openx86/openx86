// ============================================================================
// todo/alu
// ----------------------------------------------------------------------------
// 该目录下模块属于“未收敛 / 实验性 / bring-up 草稿”实现。
//
// 本 ALU 以 `operation` 选择不同运算，直接用 SystemVerilog 运算符给出结果。
// 教学提示：
// - `* / %` 在综合中资源昂贵，通常需要多周期或共享单元
// - 还需要与 x86 的标志位、位宽、饱和/异常语义对齐（当前文件未体现）
// ============================================================================

module alu #(
    // parameters
) (
    // port_list
    input  logic [31:0] operation,
    input  logic [31:0] operand[3],
    output logic [31:0] result,
);

logic [31:0] result_add = operand[0] + operand[1];
logic [31:0] result_sub = operand[0] - operand[1];
logic [31:0] result_mul = operand[0] * operand[1];
logic [31:0] result_div = operand[0] / operand[1];
logic [31:0] result_mod = operand[0] % operand[1];
logic [31:0] result__or = operand[0] | operand[1];
logic [31:0] result_and = operand[0] & operand[1];
logic [31:0] result_xor = operand[0] ^ operand[1];
logic [31:0] result_not = ~operand[0];
logic [31:0] result_nor = ~(operand[0] | operand[1]);
logic [31:0] result_shl = operand[0] <<  operand[1];
logic [31:0] result_shr = operand[0] <<  operand[1];
logic [31:0] result_sal = operand[0] >>> operand[1];
logic [31:0] result_sar = operand[0] >>> operand[1];


// algorithm
always_comb begin : algorithm_logic
    case (operation)
        ADD : result <= result_add;
        SUB : result <= result_sub;
        MUL : result <= result_mul;
        DIV : result <= result_div;
        MOD : result <= result_mod;
        _OR : result <= result__or;
        AND : result <= result_and;
        XOR : result <= result_xor;
        NOT : result <= result_not;
        NOR : result <= result_nor;
        SHL : result <= result_shl;
        SHR : result <= result_shr;
        SAL : result <= result_sal;
        SAR : result <= result_sar;
        default: result <= 0;
    endcase
end

// decode_main decode_main_inst (
//     .instruction ( instruction ),
//     .opcode ( opcode ),
//     .operand ( operand ),
// );

endmodule
