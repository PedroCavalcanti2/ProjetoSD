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