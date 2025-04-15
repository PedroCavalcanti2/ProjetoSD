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