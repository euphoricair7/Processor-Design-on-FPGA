module binary_to_bcd (
    input  [7:0] bin_in,        // 8-bit binary input (Value: 0 to 255)

    output [3:0] bcd_hundreds,  // BCD digit for 100s place
    output [3:0] bcd_tens,      // BCD digit for 10s place
    output [3:0] bcd_ones       // BCD digit for 1s place
);

    // Internal register for the Double Dabble process.
    // Size: 3 * 4 bits (BCD) + 8 bits (Binary) = 20 bits.
    // Layout: [ Hundreds | Tens | Ones | Original Binary ]
    reg [19:0] dabble_reg;
    integer i; // Loop counter for shifts

    // Combinational logic: Recalculates whenever bin_in changes.
    always @(bin_in) begin
        // Step 1: Initialize the register.
        // Place the binary input in the lower 8 bits, BCD digits are initially 0.
        dabble_reg = {12'b0, bin_in};

        // Step 2: Perform 8 iterations (one for each bit of the input).
        for (i = 0; i < 8; i = i + 1) begin
            // Step 2a: Check each BCD digit *before* shifting.
            // If a digit is 5 or greater, add 3 to it.
            // Check Hundreds Digit (bits 19:16)
            if (dabble_reg[19:16] >= 4'd5) begin
                dabble_reg[19:16] = dabble_reg[19:16] + 4'd3;
            end
            // Check Tens Digit (bits 15:12)
            if (dabble_reg[15:12] >= 4'd5) begin
                dabble_reg[15:12] = dabble_reg[15:12] + 4'd3;
            end
            // Check Ones Digit (bits 11:8)
            if (dabble_reg[11:8] >= 4'd5) begin
                dabble_reg[11:8] = dabble_reg[11:8] + 4'd3;
            end

            // Step 2b: Shift the entire register left by 1 bit.
            dabble_reg = dabble_reg << 1;
        end
    end

    // Step 3: Assign the final BCD digits to the output ports.
    // The BCD digits are now in the upper 12 bits of the dabble_reg.
    assign bcd_hundreds = dabble_reg[19:16];
    assign bcd_tens     = dabble_reg[15:12];
    assign bcd_ones     = dabble_reg[11:8];

endmodule
