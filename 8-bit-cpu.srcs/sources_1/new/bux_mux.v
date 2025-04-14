//------------------------------------------------------------------------------
// Module: bus_mux (Modified for ALU)
// Description: System Bus Multiplexer Module for SAP-1. Selects one input
//              to drive the main data bus based on enable signals.
//------------------------------------------------------------------------------
module bus_mux (
    // --- Data inputs from CPU components ---
    input [7:0] alu_result,   // *** CHANGED from adder_out ***
    input [7:0] a_out,        // Output from Register A
    input [7:0] ir_out,       // Output from Instruction Register
    input [7:0] mem_out,      // Output from Memory
    input [3:0] pc_out,       // Output from Program Counter (4 bits)

    // --- Enable signals from Controller ---
    input       alu_en,       // *** CHANGED from adder_en ***
    input       a_en,         // Enable for Register A output
    input       ir_en,        // Enable for Instruction Register output
    input       mem_en,       // Enable for Memory output
    input       pc_en,        // Enable for Program Counter output

    // --- Bus output ---
    output reg [7:0] bus_data // Represents the value driven onto the bus
);

    // Combinational logic block sensitive to changes in any input
    // Implements the multiplexer logic
    always @* begin
        // Default to zero if no enable signal is active
        bus_data = 8'b00000000;

        // Select the source based on the active enable signal
        if (alu_en) begin         // *** CHANGED from adder_en ***
            bus_data = alu_result; // *** CHANGED from adder_out ***
        end else if (a_en) begin
            bus_data = a_out;
        end else if (ir_en) begin
            // Place the full IR output (or just operand based on design)
            bus_data = ir_out;
        end else if (mem_en) begin
            bus_data = mem_out;
        end else if (pc_en) begin
            // Zero-extend the 4-bit PC output to 8 bits
            bus_data = {4'b0000, pc_out};
        end
        // If no enable is active, bus_data remains the default (zero).
    end

endmodule