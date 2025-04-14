//------------------------------------------------------------------------------
// Module: bcd_to_7seg
// Type:        Combinational
//------------------------------------------------------------------------------
module bcd_to_7seg (
    input  [3:0] bcd_in,    // 4-bit BCD input (Value: 0 to 9)
    output [6:0] segments   // 7-segment cathode outputs {g,f,e,d,c,b,a} - Active LOW (0=ON)
                            // segments[0] = Segment A (Top)
                            // segments[1] = Segment B (Top-Right)
                            // segments[2] = Segment C (Bottom-Right)
                            // segments[3] = Segment D (Bottom)
                            // segments[4] = Segment E (Bottom-Left)
                            // segments[5] = Segment F (Top-Left)
                            // segments[6] = Segment G (Middle)
);

    reg [6:0] seg_out_reg; // Internal register for segment patterns

    // Combinational logic: Update segments whenever bcd_in changes.
    always @(bcd_in) begin
        case(bcd_in)
            // BCD -> segments {g,f,e,d,c,b,a} (Active LOW: 0=ON, 1=OFF)
            4'd0: seg_out_reg = 7'b1000000; // "0" (gfedcba = 1000000)
            4'd1: seg_out_reg = 7'b1111001; // "1" (gfedcba = 1111001)
            4'd2: seg_out_reg = 7'b0100100; // "2" (gfedcba = 0100100)
            4'd3: seg_out_reg = 7'b0110000; // "3" (gfedcba = 0110000)
            4'd4: seg_out_reg = 7'b0011001; // "4" (gfedcba = 0011001)
            4'd5: seg_out_reg = 7'b0010010; // "5" (gfedcba = 0010010)
            4'd6: seg_out_reg = 7'b0000010; // "6" (gfedcba = 0000010)
            4'd7: seg_out_reg = 7'b1111000; // "7" (gfedcba = 1111000)
            4'd8: seg_out_reg = 7'b0000000; // "8" (gfedcba = 0000000)
            4'd9: seg_out_reg = 7'b0010000; // "9" (gfedcba = 0010000)

            // For invalid BCD inputs (10-15), display blank (all segments OFF).
            default: seg_out_reg = 7'b1111111; // Blank
        endcase
    end

    // Assign the internal register to the output port.
    assign segments = seg_out_reg;

endmodule
