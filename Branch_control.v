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