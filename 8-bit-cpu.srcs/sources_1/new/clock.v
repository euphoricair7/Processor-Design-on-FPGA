//------------------------------------------------------------------------------
// Module: clock (Modified for Step/Run Control)
// Description: Generates the CPU clock based on 100MHz input, reset, halt,
//              and step/run button inputs. Includes basic synchronizers.
// Note:        Does NOT include full debouncing logic for buttons.
//              Bouncing buttons might cause multiple steps on a single press.
//------------------------------------------------------------------------------
module clock (
    input clk_100mhz, // Input from the Basys 3 100MHz oscillator
    input rst,        // System reset (active high)
    input hlt,        // Halt signal input from controller (latched)
    input step_in,    // Step button input (e.g., BTNR) - Active High
    input run_in,     // Run button input (e.g., BTND) - Active High
    output clk_out    // Gated/Pulsed Clock output for CPU components
);

    // Synchronizers for inputs (reduce metastability risk)
    reg step_sync1, step_sync2;
    reg run_sync1, run_sync2;

    always @(posedge clk_100mhz or posedge rst) begin
        if (rst) begin
            step_sync1 <= 1'b0;
            step_sync2 <= 1'b0;
            run_sync1  <= 1'b0;
            run_sync2  <= 1'b0;
        end else begin
            // Cascade the synchronizers
            step_sync1 <= step_in;
            step_sync2 <= step_sync1;
            run_sync1  <= run_in;
            run_sync2  <= run_sync1;
        end
    end

    // Edge detection for step button (generate a single pulse)
    wire step_pressed_edge = step_sync1 & ~step_sync2; // Rising edge detected

    // Internal signal for generating the step pulse
    reg step_pulse_active = 1'b0;

    // Generate a single cycle pulse on step_pressed_edge
    // This needs to be clocked by clk_100mhz to ensure it aligns
    always @(posedge clk_100mhz or posedge rst) begin
        if (rst) begin
            step_pulse_active <= 1'b0;
        end else begin
            // Pulse is active only for the cycle the edge is detected
            step_pulse_active <= step_pressed_edge;
        end
    end

    // Determine if the clock should be enabled for this cycle
    // Priority: Reset > Halt > Run > Step
    wire clock_enable_signal;
    assign clock_enable_signal = ~rst & ~hlt & (run_sync2 | step_pulse_active);

    // Generate the CPU clock output
    // WARNING: Direct clock gating like this can sometimes cause timing issues.
    // A safer approach uses Clock Enable (CE) on flops, but this follows
    // the original design's gating pattern.
    assign clk_out = clk_100mhz & clock_enable_signal;

endmodule