// Instruction Register Module (8-bit) for SAP-1

module ir (
    input         clk,    // Clock input
    input         rst,    // Synchronous reset input
    input         load,   // Load enable input (captures instruction from bus)
    input  [7:0]  bus,    // 8-bit input bus (carrying the instruction byte)
    output [7:0]  out     // 8-bit output (the stored instruction byte)
);

    // Internal register to store the instruction
    reg [7:0] ir_value;

    // Synchronous logic: updates happen on the positive edge of the clock
    always @(posedge clk) begin
        if (rst) begin
            // If reset is asserted, clear the register to 0
            ir_value <= 8'b00000000; 
        end else if (load) begin
            // If load is asserted (and not reset), 
            // capture the instruction value from the bus into the register
            ir_value <= bus;
        end
        // If neither rst nor load is asserted, ir_value retains its current value.
    end

    // Continuously assign the internal register value (the full instruction) 
    // to the output port 'out'. The controller logic will read this 'out' 
    // signal and split it into opcode (out[7:4]) and operand (out[3:0]).
    assign out = ir_value;

endmodule