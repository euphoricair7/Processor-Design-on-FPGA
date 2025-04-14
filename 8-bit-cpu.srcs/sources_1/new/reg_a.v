// Register A Module (8-bit)

module reg_a (
    input         clk,    // Clock input
    input         rst,    // Synchronous reset input
    input         load,   // Load enable input
    input  [7:0]  bus,    // 8-bit data input bus
    output [7:0]  out     // 8-bit data output
);

    // Internal register to store the value of Register A
    reg [7:0] reg_a_value;

    // Synchronous logic: updates happen on the positive edge of the clock
    always @(posedge clk) begin
        if (rst) begin
            // If reset is asserted, clear the register to 0
            reg_a_value <= 8'b00000000; 
        end else if (load) begin
            // If load is asserted (and not reset), 
            // capture the value from the bus into the register
            reg_a_value <= bus;
        end
        // If neither rst nor load is asserted, reg_a_value retains its current value.
    end

    // Continuously assign the internal register value to the output port
    assign out = reg_a_value;

endmodule