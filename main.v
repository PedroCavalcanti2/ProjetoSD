`timescale 1ns / 1ps

module ProgramCounter (
    input wire clk,          // Clock
    input wire rst,          // Reset
    input wire [31:0] pc_in, // Endereço de entrada
    output reg [31:0] pc_out // Endereço atual
);
    always @(posedge clk or posedge rst) begin
        if (rst)
            pc_out <= 32'b0;    // Reseta para 0
        else
            pc_out <= pc_in;    // Atualiza com pc_in
    end
endmodule

module Adder (
    input wire [31:0] addr_in,  // Endereço de entrada
    input wire [31:0] offset,   // Offset (para branch ou +4)
    output wire [31:0] addr_out // Endereço resultante
);
    assign addr_out = addr_in + offset;
endmodule

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

module RegisterFile (
    input wire [4:0] ReadRegister1,  // Endereço do registrador rs
    input wire [4:0] ReadRegister2,  // Endereço do registrador rt
    input wire [4:0] WriteRegister,  // Endereço do registrador rd ou rt
    input wire [31:0] WriteData,     // Dado a ser escrito
    input wire RegWrite,             // Sinal de controle para escrita
    input wire clk,                  // Clock
    output reg [31:0] ReadData1,     // Dado lido de rs
    output reg [31:0] ReadData2      // Dado lido de rt
);
    reg [31:0] registers [0:31]; // Banco de registradores

    initial begin
        integer i;
        for (i = 0; i < 32; i = i + 1) begin
            registers[i] = 32'b0; // Inicializa todos os registradores com 0
        end
    end

    always @(*) begin
        ReadData1 = (ReadRegister1 == 5'b0) ? 32'b0 : registers[ReadRegister1];
        ReadData2 = (ReadRegister2 == 5'b0) ? 32'b0 : registers[ReadRegister2];
    end

    always @(posedge clk) begin
        if (RegWrite && WriteRegister != 5'b0) begin
            registers[WriteRegister] <= WriteData;
        end
    end
endmodule

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

module MemoriaDados (
    input clk,
    input MemWrite,         // Sinal de controle para escrita
    input MemRead,          // Sinal de controle para leitura
    input [31:0] endereco,  // Endereço de leitura/escrita
    input [31:0] dado_in,   // Dado a ser escrito
    output reg [31:0] dado_out // Dado lido
);
    reg [31:0] memoria [0:1023]; // 1024 posições de 32 bits

    always @(posedge clk) begin
        if (MemWrite && endereco[1:0] == 2'b00) begin
            memoria[endereco[11:2]] <= dado_in;  // Escrita (word-aligned)
        end
    end

    always @(*) begin
        if (MemRead && endereco[1:0] == 2'b00) begin
            dado_out = memoria[endereco[11:2]];  // Leitura (word-aligned)
        end else begin
            dado_out = 32'b0;
        end
    end
endmodule

module InstructionMemory (
    input [31:0] address,
    output [31:0] instruction
);
    reg [31:0] mem[0:1023]; // Memória de 1024 words

    initial begin
        // Instruções de teste
        mem[0] = 32'h20020004; // addi $2, $zero, 4
        mem[1] = 32'hac020004; // sw $2, 4($zero)
        mem[2] = 32'h8c080004; // lw $8, 4($zero)
        mem[3] = 32'h21090005; // addi $9, $8, 5
        mem[4] = 32'hac090004; // sw $9, 4($zero)
      	mem[5] = 32'h10420001; // beq $2, $2, 1 (pula para mem[7])
      	mem[6] = 32'h20030007; // addi $3, $zero, 7 (não deve executar)
      	mem[7] = 32'h14c80001; // bne $6, $8, 1 (não pula, $6=0)
      	mem[8] = 32'h2006000a; // addi $6, $zero, 10
    end

    assign instruction = mem[address[31:2]]; // Endereço em words
endmodule

module RegDst_Mux (
    input wire [4:0] rt,
    input wire [4:0] rd,
    input wire RegDst,
    output wire [4:0] RegDstOut
);
    assign RegDstOut = (RegDst) ? rd : rt;
endmodule

module PCSrc_Mux (
    input wire [31:0] PC_plus_4,
    input wire [31:0] BranchAddress,
    input wire PCSrc,
    output wire [31:0] NextPC
);
    assign NextPC = (PCSrc) ? BranchAddress : PC_plus_4;
endmodule

module ShiftLeft2 (
    input wire [31:0] offset_in,
    output wire [31:0] offset_out
);
    assign offset_out = offset_in << 2;
endmodule

module sign_extender (
    input wire [15:0] in,
    output wire [31:0] out
);
    assign out = {{16{in[15]}}, in};
endmodule

module BranchControl (
    input wire branch,
    input wire zero,
    input wire bne,
    output wire take_branch
);
    wire zero_cond;
    assign zero_cond = bne ? ~zero : zero;
    assign take_branch = branch & zero_cond;
endmodule

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

module MemtoRegMux (
    input wire [31:0] ALUResult,
    input wire [31:0] MemData,
    input wire MemtoReg,
    output wire [31:0] WriteData
);
    assign WriteData = (MemtoReg) ? MemData : ALUResult;
endmodule

module MIPS_Processor (
    input wire clk,
    input wire rst
);
    wire [31:0] pc_out, pc_in, pc_plus_4, instruction, sign_ext_imm, shifted_imm, branch_addr, alu_result, read_data1, read_data2, alu_src_b, mem_data, write_data;
    wire [4:0] write_reg;
    wire zero, take_branch, overflow;
    wire RegDst, ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, BNE;
    wire [1:0] ALUOp;
    wire [3:0] alu_control;

    wire [5:0] opcode = instruction[31:26];
    wire [4:0] rs = instruction[25:21];
    wire [4:0] rt = instruction[20:16];
    wire [4:0] rd = instruction[15:11];
    wire [15:0] immediate = instruction[15:0];

    ProgramCounter pc (.clk(clk), .rst(rst), .pc_in(pc_in), .pc_out(pc_out));
    Adder pc_adder (.addr_in(pc_out), .offset(32'd4), .addr_out(pc_plus_4));
    InstructionMemory im (.address(pc_out), .instruction(instruction));
    control_unit cu (.opcode(opcode), .RegDst(RegDst), .ALUSrc(ALUSrc), .MemtoReg(MemtoReg), .RegWrite(RegWrite), .MemRead(MemRead), .MemWrite(MemWrite), .Branch(Branch), .BNE(BNE), .ALUOp(ALUOp));
    RegisterFile rf (.ReadRegister1(rs), .ReadRegister2(rt), .WriteRegister(write_reg), .WriteData(write_data), .RegWrite(RegWrite), .clk(clk), .ReadData1(read_data1), .ReadData2(read_data2));
    sign_extender se (.in(immediate), .out(sign_ext_imm));
    ShiftLeft2 sl2 (.offset_in(sign_ext_imm), .offset_out(shifted_imm));
    Adder branch_adder (.addr_in(pc_plus_4), .offset(shifted_imm), .addr_out(branch_addr));
    RegDst_Mux rdm (.rt(rt), .rd(rd), .RegDst(RegDst), .RegDstOut(write_reg));
    assign alu_src_b = (ALUSrc) ? sign_ext_imm : read_data2;
    alu_control ac (.ALUOp(ALUOp), .funct(instruction[5:0]), .alu_control(alu_control));
    alu alu_inst (.a(read_data1), .b(alu_src_b), .alu_control(alu_control), .result(alu_result), .zero(zero), .overflow(overflow));
    MemoriaDados dm (.clk(clk), .MemWrite(MemWrite), .MemRead(MemRead), .endereco(alu_result), .dado_in(read_data2), .dado_out(mem_data));
    MemtoRegMux mtm (.ALUResult(alu_result), .MemData(mem_data), .MemtoReg(MemtoReg), .WriteData(write_data));
    BranchControl bc (.branch(Branch), .zero(zero), .bne(BNE), .take_branch(take_branch));
    PCSrc_Mux pcs (.PC_plus_4(pc_plus_4), .BranchAddress(branch_addr), .PCSrc(take_branch), .NextPC(pc_in));
endmodule