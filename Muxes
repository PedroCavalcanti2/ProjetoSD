module MemtoRegMux (
    input wire [31:0] ALUResult,
    input wire [31:0] MemData,
    input wire MemtoReg,
    output wire [31:0] WriteData
);
    assign WriteData = (MemtoReg) ? MemData : ALUResult;
endmodule


module PCSrc_Mux (
    input wire [31:0] PC_plus_4,
    input wire [31:0] BranchAddress,
    input wire PCSrc,
    output wire [31:0] NextPC
);
    assign NextPC = (PCSrc) ? BranchAddress : PC_plus_4;
endmodule

module RegDst_Mux (
    input wire [4:0] rt,
    input wire [4:0] rd,
    input wire RegDst,
    output wire [4:0] RegDstOut
);
    assign RegDstOut = (RegDst) ? rd : rt;
endmodule

module alusrc_mux(
    input [31:0] reg_data,        // Valor lido do registrador (ReadData2)
    input [31:0] imm_data,        // Immediate estendido (SignExtend)
    input alusrc,                 // Sinal de controle: 0 = registrador, 1 = immediate
    output [31:0] alu_operand_b   // Saída para a ALU
);
    assign alu_operand_b = (alusrc) ? imm_data : reg_data;
endmodule