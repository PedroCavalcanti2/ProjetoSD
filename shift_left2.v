module ShiftLeft2 (
    input wire [31:0] offset_in,
    output wire [31:0] offset_out
);
    assign offset_out = offset_in << 2;
endmodule