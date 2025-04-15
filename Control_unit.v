module control_unit (
    input [5:0] opcode,          // Opcode da instrução (6 bits)
    output reg RegDst,           // Seleciona registrador de destino
    output reg ALUSrc,           // Seleciona fonte da ALU
    output reg MemtoReg,         // Seleciona fonte para escrita no registrador
    output reg RegWrite,         // Habilita escrita no registrador
    output reg MemRead,          // Habilita leitura da memória
    output reg MemWrite,         // Habilita escrita na memória
    output reg Branch,           // Indica instrução de branch
    output reg BNE,              // Indica instrução BNE
    output reg [1:0] ALUOp       // Controla operação da ALU
);
    always @(*) begin
        case (opcode)
            6'b000000: begin // R-type (ADD, SUB, AND, OR, SLT)
                RegDst = 1;
                ALUSrc = 0;
                MemtoReg = 0;
                RegWrite = 1;
                MemRead = 0;
                MemWrite = 0;
                Branch = 0;
                BNE = 0;
                ALUOp = 2'b10;
            end
            6'b100011: begin // LW (Load Word)
                RegDst = 0;
                ALUSrc = 1;
                MemtoReg = 1;
                RegWrite = 1;
                MemRead = 1;
                MemWrite = 0;
                Branch = 0;
                BNE = 0;
                ALUOp = 2'b00;
            end
            6'b101011: begin // SW (Store Word)
                RegDst = 0;
                ALUSrc = 1;
                MemtoReg = 0;
                RegWrite = 0;
                MemRead = 0;
                MemWrite = 1;
                Branch = 0;
                BNE = 0;
                ALUOp = 2'b00;
            end
            6'b000100: begin // BEQ (Branch Equal)
                RegDst = 0;
                ALUSrc = 0;
                MemtoReg = 0;
                RegWrite = 0;
                MemRead = 0;
                MemWrite = 0;
                Branch = 1;
                BNE = 0;
                ALUOp = 2'b01;
            end
            6'b000101: begin // BNE (Branch Not Equal)
                RegDst = 0;
                ALUSrc = 0;
                MemtoReg = 0;
                RegWrite = 0;
                MemRead = 0;
                MemWrite = 0;
                Branch = 1;
                BNE = 1;
                ALUOp = 2'b01;
            end
            6'b001000: begin // ADDI (Add Immediate)
                RegDst = 0;
                ALUSrc = 1;
                MemtoReg = 0;
                RegWrite = 1;
                MemRead = 0;
                MemWrite = 0;
                Branch = 0;
                BNE = 0;
                ALUOp = 2'b00;
            end
            default: begin   // Caso padrão (opcode inválido)
                RegDst = 0;
                ALUSrc = 0;
                MemtoReg = 0;
                RegWrite = 0;
                MemRead = 0;
                MemWrite = 0;
                Branch = 0;
                BNE = 0;
                ALUOp = 2'b00;
            end
        endcase
    end
endmodule