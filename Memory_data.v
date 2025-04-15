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