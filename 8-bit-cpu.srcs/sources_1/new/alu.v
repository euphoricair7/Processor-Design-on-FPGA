//------------------------------------------------------------------------------
// Module: alu (Arithmetic Logic Unit) for SAP-1 Expansion
// Description: Performs basic arithmetic and logical operations on 8-bit inputs.
//              Generates Zero (Z) and Carry/Borrow (C) flags.
// Type:        Combinational
//------------------------------------------------------------------------------
module alu (
    input  [7:0] in_a,      // Input Operand A (from Register A)
    input  [7:0] in_b,      // Input Operand B (from Register B)
    input  [2:0] op_sel,    // Operation Select Code (3 bits)

    output [7:0] result,    // 8-bit result of the operation
    output       Z_flag,    // Zero Flag (1 if result is 0, else 0)
    output       C_flag     // Carry Flag (for ADD) / Borrow Flag (for SUB)
);

    // --- Operation Codes ---
    // These must match the values assigned in controller.v
    localparam OP_ADD   = 3'b000;
    localparam OP_SUB   = 3'b001;
    localparam OP_AND   = 3'b010;
    localparam OP_OR    = 3'b011;
    localparam OP_XOR   = 3'b100;
    localparam OP_NOT_A = 3'b101;
    // Other codes (110, 111) are unused/reserved

    // --- Internal variables ---
    reg  [7:0] alu_result_comb; // Combinational result calculation
    reg        Z_flag_comb;     // Combinational Zero flag
    reg        C_flag_comb;     // Combinational Carry/Borrow flag
    reg [8:0] sum_internal;    // Internal 9-bit sum for carry detection

    // --- Combinational Logic for ALU operation ---
    always @(*) begin
        // Default outputs
        alu_result_comb = 8'b0;
        C_flag_comb = 1'b0;

        case (op_sel)
            OP_ADD: begin
                sum_internal = {1'b0, in_a} + {1'b0, in_b};
                alu_result_comb = sum_internal[7:0];
                C_flag_comb = sum_internal[8];
            end
            OP_SUB: begin
                sum_internal = {1'b0, in_a} - {1'b0, in_b};
                alu_result_comb = sum_internal[7:0];
                C_flag_comb = (in_a < in_b);
            end
            OP_AND: begin
                alu_result_comb = in_a & in_b;
            end
            OP_OR: begin
                alu_result_comb = in_a | in_b;
            end
            OP_XOR: begin
                alu_result_comb = in_a ^ in_b;
            end
            OP_NOT_A: begin
                alu_result_comb = ~in_a;
            end
            default: begin
                alu_result_comb = 8'b0;
                C_flag_comb = 1'b0;
            end
        endcase

        // Calculate Zero flag based on the final combinational result
        // Z_flag is 1 if the result is exactly zero
        Z_flag_comb = (alu_result_comb == 8'b0);

    end // end always@(*)

    // --- Assign outputs ---
    assign result = alu_result_comb;
    assign Z_flag = Z_flag_comb;
    assign C_flag = C_flag_comb;

endmodule