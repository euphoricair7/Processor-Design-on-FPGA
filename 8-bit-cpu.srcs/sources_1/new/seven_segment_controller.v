//------------------------------------------------------------------------------
// Module: seven_segment_controller
// Description: Drives a 4-digit 7-segment common anode display (Basys 3).
//              Multiplexes three BCD digits (H, T, O) onto the rightmost
//              three display digits (AN2, AN1, AN0). The leftmost digit (AN3)
//              can be configured (e.g., shows 0 if H=0, or stays blank).
//              Includes an enable signal to turn the display on/off.
// Target:      Basys 3 (Common Anode -> Active-LOW Anodes, Active-LOW Cathodes)
// Type:        Mixed Sequential (Counter) and Combinational (Mux, Output Drive)
//------------------------------------------------------------------------------
module seven_segment_controller (
    input         clk,       // System clock input (e.g., 100MHz)
    input         reset,     // System reset input (active high)
    input         enable,    // Display enable input (e.g., from CPU halt signal)

    // BCD digits from the binary_to_bcd converter
    input [3:0]   bcd_h,     // Hundreds digit
    input [3:0]   bcd_t,     // Tens digit
    input [3:0]   bcd_o,     // Ones digit

    // Outputs to the Basys 3 7-Segment Display Pins
    output reg [6:0] seg_out,  // Segment cathode outputs {g,f,e,d,c,b,a} (Active LOW)
    output reg [3:0] an_out    // Anode selector outputs {AN3,AN2,AN1,AN0} (Active LOW)
);

    // --- Parameters ---
    // Clock divider setup for display refresh rate
    // Target refresh rate per digit > 60Hz to avoid flicker.
    // With 100MHz clock:
    // 18 bits -> 2^18 / 100MHz = 2.62ms per digit -> ~95 Hz refresh per 4 digits.
    // 19 bits -> 5.24ms -> ~47 Hz refresh. Might flicker slightly.
    // 20 bits -> 10.48ms -> ~24 Hz refresh. Will likely flicker.
    // Let's use 18 bits for a faster refresh (~380 Hz per digit).
    localparam REFRESH_COUNTER_BITS = 18;

    // Define which digit selection value corresponds to which anode
    localparam ANODE_SEL_ONES      = 2'b00; // Rightmost digit (AN0)
    localparam ANODE_SEL_TENS      = 2'b01; // Digit AN1
    localparam ANODE_SEL_HUNDREDS  = 2'b10; // Digit AN2
    localparam ANODE_SEL_UNUSED    = 2'b11; // Leftmost digit (AN3) - currently unused/blank

    // --- Internal Signals ---
    reg [REFRESH_COUNTER_BITS-1:0] refresh_counter; // Counter for multiplexing
    wire [1:0] digit_select;      // Selects which digit (0-3) is currently active

    reg [3:0] current_bcd;        // BCD value for the currently selected digit
    wire [6:0] current_segments;  // Segment pattern for the current BCD value

    // --- Clock Divider for Refresh Rate ---
    // Free-running counter based on the system clock
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            refresh_counter <= 0;
        end else begin
            refresh_counter <= refresh_counter + 1;
        end
    end

    // Use the top bits of the counter to select the active digit (00, 01, 10, 11)
    assign digit_select = refresh_counter[REFRESH_COUNTER_BITS-1 : REFRESH_COUNTER_BITS-2];

    // --- BCD Digit Multiplexer ---
    // Selects the appropriate BCD input based on the active digit
    always @(*) begin
        case (digit_select)
            ANODE_SEL_ONES:     current_bcd = bcd_o;        // AN0 -> Ones digit
            ANODE_SEL_TENS:     current_bcd = bcd_t;        // AN1 -> Tens digit
            ANODE_SEL_HUNDREDS: current_bcd = bcd_h;        // AN2 -> Hundreds digit
            ANODE_SEL_UNUSED:   current_bcd = 4'b1111;      // AN3 -> Display Blank (using default in BCD decoder)
            default:            current_bcd = 4'b1111;      // Default: Blank
        endcase
    end

    // --- Instantiate BCD to 7-Segment Decoder ---
    // Connect the currently selected BCD digit to the decoder
    bcd_to_7seg bcd_decoder (
        .bcd_in   (current_bcd),
        .segments (current_segments) // Gets the Active-LOW segment pattern
    );

    // --- Output Drive Logic ---
    // Drives the anode and segment outputs based on selection and enable signal
    always @(*) begin
        if (enable) begin
            // Display is enabled - drive segments and selected anode

            // Drive segments based on the decoder output (Active LOW)
            seg_out = current_segments;

            // Activate the selected Anode (Active LOW)
            // Only one anode is LOW at a time.
            case (digit_select)
                ANODE_SEL_ONES:     an_out = 4'b1110; // AN0 LOW, others HIGH
                ANODE_SEL_TENS:     an_out = 4'b1101; // AN1 LOW, others HIGH
                ANODE_SEL_HUNDREDS: an_out = 4'b1011; // AN2 LOW, others HIGH
                ANODE_SEL_UNUSED:   an_out = 4'b0111; // AN3 LOW, others HIGH (if displaying blank)
                                     // If truly unused, set to 4'b1111 here.
                                     // Let's drive it but show blank via current_bcd.
                default:            an_out = 4'b1111; // All anodes HIGH (OFF)
            endcase

        end else begin
            // Display is disabled - turn off all segments and anodes
            an_out = 4'b1111;      // All anodes HIGH (OFF)
            seg_out = 7'b1111111; // All segments HIGH (Segments OFF)
        end
    end

endmodule
