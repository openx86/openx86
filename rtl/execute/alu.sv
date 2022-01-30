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
