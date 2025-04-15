`timescale 1ns / 1ps

module tb_MIPS_Processor;

    // Sinais
    reg clk;
    reg rst;

    // Instanciação do DUT (Device Under Test)
    MIPS_Processor dut (
        .clk(clk),
        .rst(rst)
    );

    // Geração do clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Clock com período de 10ns
    end

    // Reset inicial
    initial begin
        rst = 1;
        #10;
        rst = 0;
    end




    // Monitoramento
    always @(negedge clk) begin
      $display("Time: %0t | PC: %d | Instruction: %h | Reg[8]: %d | Reg[9]: %d | Mem[4]: %d",
                 $time, dut.pc_out, dut.instruction, dut.rf.registers[8], dut.rf.registers[9], dut.dm.memoria[1]);
    end

    // Terminar a simulação após um tempo suficiente
    initial begin
        #200 $finish;
    end

endmodule