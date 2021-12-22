// project: w80386dx
// author: Chang Wei<changwei1006@gmail.com>
// repo: https://github.com/openx86/w80386dx
// module: decode_general_general_register_tb
// create at: 2021-10-22 02:29:28
// description: test decode_general_general_register module

`timescale 1ns/1ns
module decode_general_register_tb #(
    // parameters
) (
    // ports
);

logic [1:0] bit_width = 1 << 0;
logic [2:0] register_sequence_code;
logic       w_in_instruction;
logic       w;
logic       AL;
logic       CL;
logic       DL;
logic       BL;
logic       AH;
logic       CH;
logic       DH;
logic       BH;
logic       EAX;
logic       ECX;
logic       EDX;
logic       EBX;
logic       ESP;
logic       EBP;
logic       ESI;
logic       EDI;
logic       AX;
logic       CX;
logic       DX;
logic       BX;
logic       SP;
logic       BP;
logic       SI;
logic       DI;

decode_general_register decode_general_register_inst (
    .bit_width ( bit_width ),
    .register_sequence_code ( register_sequence_code ),
    .w_in_instruction ( w_in_instruction ),
    .w ( w ),

    .AL ( AL ),
    .CL ( CL ),
    .DL ( DL ),
    .BL ( BL ),
    .AH ( AH ),
    .CH ( CH ),
    .DH ( DH ),
    .BH ( BH ),
    .EAX ( EAX ),
    .ECX ( ECX ),
    .EDX ( EDX ),
    .EBX ( EBX ),
    .ESP ( ESP ),
    .EBP ( EBP ),
    .ESI ( ESI ),
    .EDI ( EDI ),
    .AX ( AX ),
    .CX ( CX ),
    .DX ( DX ),
    .BX ( BX ),
    .SP ( SP ),
    .BP ( BP ),
    .SI ( SI ),
    .DI ( DI )
);

initial begin: check_register_sequence_code
    bit testcase [1:0][1:0][7:0];

    foreach (testcase[testcase_w_in_instruction, testcase_w, testcase_register_sequence_code]) begin
        #1 $display ("w_in_instruction = %1b, w = %1b, register_sequence_code = %3b", testcase_w_in_instruction, testcase_w, testcase_register_sequence_code);
        w_in_instruction <= testcase_w_in_instruction;
        w <= testcase_w;
        register_sequence_code <= testcase_register_sequence_code;
    end

    $stop();
end

endmodule
