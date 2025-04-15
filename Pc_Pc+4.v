module Adder (
    input wire [31:0] addr_in,  // Endereço de entrada
    input wire [31:0] offset,   // Offset (para branch ou +4)
    output wire [31:0] addr_out // Endereço resultante
);
    assign addr_out = addr_in + offset;
endmodule

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