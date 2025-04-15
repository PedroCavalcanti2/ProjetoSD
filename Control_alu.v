module alu_control (
    input [1:0] ALUOp,
    input [5:0] funct,
    output reg [3:0] alu_control
);
    always @(*) begin
        case (ALUOp)
            2'b00: alu_control = 4'b0010; // ADD (para LW, SW, ADDI)
            2'b01: alu_control = 4'b0110; // SUB (para BEQ, BNE)
            2'b10: begin
                case (funct)
                    6'b100000: alu_control = 4'b0010; // ADD
                    6'b100010: alu_control = 4'b0110; // SUB
                    6'b100100: alu_control = 4'b0000; // AND
                    6'b100101: alu_control = 4'b0001; // OR
                    6'b101010: alu_control = 4'b0111; // SLT
                    default: alu_control = 4'b0000;   // Padrão
                endcase
            end
            default: alu_control = 4'b0000;   // Padrão
        endcase
    end
endmodule