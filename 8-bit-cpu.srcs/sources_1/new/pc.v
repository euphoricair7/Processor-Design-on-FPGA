// Program Counter Module (4-bit for SAP-1)

module pc (
    input         clk, // Clock input
    input         rst, // Synchronous reset input
    input         inc, // Increment enable input
    output [3:0]  out  // 4-bit Program Counter output (addresses 0x0 to 0xF)
);

    // Internal register to store the 4-bit PC value
    reg [3:0] pc_reg;

    // Synchronous logic: updates happen on the positive edge of the clock
    always @(posedge clk) begin
        if (rst) begin
            // If reset is asserted, set PC to 0
            pc_reg <= 4'b0000; 
        end else if (inc) begin
            // If increment is asserted (and not reset), increment PC by 1
            // It will automatically wrap from 15 (1111) back to 0 (0000)
            pc_reg <= pc_reg + 1;
        end
        // If neither rst nor inc is asserted, pc_reg retains its current value.
    end

    // Continuously assign the internal register value to the output port
    assign out = pc_reg;

endmodule