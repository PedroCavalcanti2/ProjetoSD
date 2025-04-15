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