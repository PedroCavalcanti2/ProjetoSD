module alu (
    input [31:0] a,           // SrcA
    input [31:0] b,           // SrcB
    input [3:0] alu_control,  // Sinal de controle da ALU
    output reg [31:0] result, // Resultado da operação
    output zero,              // Flag zero
    output overflow           // Flag overflow
);
    reg [31:0] temp_result;
    reg temp_overflow;

    always @(*) begin
        temp_overflow = 0;
        case (alu_control)
            4'b0000: result = a & b;          // AND
            4'b0001: result = a | b;          // OR
            4'b0010: begin                    // ADD
                temp_result = a + b;
                temp_overflow = ((a[31] == b[31]) && (temp_result[31] != a[31]));
                result = temp_result;
            end
            4'b0110: begin                    // SUB
                temp_result = a - b;
                temp_overflow = ((a[31] != b[31]) && (temp_result[31] != a[31]));
                result = temp_result;
            end
            4'b0111: result = (a < b) ? 32'b1 : 32'b0; // SLT
            default: result = 32'b0;          // Operação inválida
        endcase
    end

    assign zero = (result == 32'b0);
    assign overflow = (alu_control == 4'b0010 || alu_control == 4'b0110) ? temp_overflow : 1'b0;
endmodule