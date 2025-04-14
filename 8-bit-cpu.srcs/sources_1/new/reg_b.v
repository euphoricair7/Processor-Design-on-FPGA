// Register B Module (8-bit)

module reg_b (
    input         clk,    // Clock input
    input         rst,    // Synchronous reset input
    input         load,   // Load enable input
    input  [7:0]  bus,    // 8-bit data input bus
    output [7:0]  out     // 8-bit data output (intended for Adder)
);

    // Internal register to store the value of Register B
    reg [7:0] reg_b_value;

    // Synchronous logic: updates happen on the positive edge of the clock
    // Logic is identical to Register A
    always @(posedge clk) begin
        if (rst) begin
            // If reset is asserted, clear the register to 0
            reg_b_value <= 8'b00000000; 
        end else if (load) begin
            // If load is asserted (and not reset), 
            // capture the value from the bus into the register
            reg_b_value <= bus;
        end
        // If neither rst nor load is asserted, reg_b_value retains its current value.
    end

    // Continuously assign the internal register value to the output port
    assign out = reg_b_value;

endmodule