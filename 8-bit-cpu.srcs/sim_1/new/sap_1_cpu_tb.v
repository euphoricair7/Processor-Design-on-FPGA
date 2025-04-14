`timescale 1ns / 1ps

module top_tb();

    // --- Testbench Signals ---

    // Inputs to the DUT (sap1_cpu_top)
    reg  clk_in; // 100MHz clock input signal
    reg  rst;    // Reset signal

    // Outputs from the DUT (sap1_cpu_top)
    wire hlt_out;   // Halt status output
    wire [6:0] seg_out; // 7-Segment cathode outputs
    wire [3:0] an_out;  // 7-Segment anode selector outputs

    // --- Instantiate the Design Under Test (DUT) ---
    sap1_cpu_top u_dut (
        .clk_in(clk_in),
        .rst(rst),
        .hlt_out(hlt_out),
        .seg_out(seg_out),
        .an_out(an_out)
    );

    // --- Clock Generation ---
    parameter CLK_PERIOD = 10; // 10ns period for 100MHz
    initial begin
        clk_in = 0;
        forever #(CLK_PERIOD / 2) clk_in = ~clk_in;
    end

    // --- Reset Generation & Simulation Control ---
    initial begin
        // VCD Dump Setup
        $dumpfile("sap1_cpu_top_tb_detailed.vcd"); // New VCD filename
        $dumpvars(0, top_tb.u_dut); // Dump DUT internals

        // Reset Sequence
        $display("\n--- Simulation Start ---");
        rst = 1'b1; // Assert reset
        $display("@%t: Reset Asserted", $time);
        #(CLK_PERIOD * 2); // Hold reset
        rst = 1'b0; // De-assert reset
        $display("@%t: Reset De-asserted", $time);

        // Simulation Duration
        #6000; // Increased duration slightly for more post-halt observation

        $display("\n--- Simulation Finished @ Time %t ns ---", $time);
        $finish;
    end

    // --- Detailed Monitoring Block ---
    // Use the *internal* gated clock (u_dut.clk) for cycle-accurate logging
    // Note: Accessing internal signals like u_dut.clk, u_dut.u_controller.stage, etc.
    // relies on simulator capabilities and synthesis tools might complain if trying to
    // synthesize the testbench (which you wouldn't normally do).

    // We need to access internal signals via hierarchical paths.
    // Ensure instance names inside sap1_cpu_top.v match:
    // u_controller, u_pc, u_memory, u_ir, u_reg_a, u_reg_b, u_adder, u_bus_mux, u_clock
    // Also need BCD converter instance name, assuming u_bin_to_bcd

//    always @(posedge u_dut.clk) begin // Log actions happening *because* of this posedge
//        // Don't log during reset or if halted (clock might be 0)
//        if (!rst && !u_dut.hlt) begin
//             // Use $timeformat if needed for better time alignment
//             // $timeformat(-9, 2, " ns", 10); // Example: ns with 2 decimal places

//            $display("\n--- Cycle End @ %t (Entering Stage %d) ---", $time, u_dut.u_controller.stage); // Stage shown is the one *just entered*

//            // Display current PC value (before potential increment)
//            $display("  PC State: Current PC = %h", u_dut.pc_out_internal);

//            // Display current Instruction Register content
//            $display("  IR State: Current IR = %h (Op: %h, Operand: %h)",
//                     u_dut.ir_out, u_dut.ir_out[7:4], u_dut.ir_out[3:0]);

//            // --- Log Control Signals Asserted (by the controller for *this* stage) ---
//            // These signals determine actions within *this* cycle or setup for next
//            string ctrl_active;
//            ctrl_active = "";
//            if (u_dut.pc_inc)    ctrl_active = {ctrl_active, "PC_INC "};
//            if (u_dut.pc_en)     ctrl_active = {ctrl_active, "PC_EN "};
//            if (u_dut.mar_load)  ctrl_active = {ctrl_active, "MAR_LD "};
//            if (u_dut.mem_en)    ctrl_active = {ctrl_active, "MEM_EN "};
//            if (u_dut.ir_load)   ctrl_active = {ctrl_active, "IR_LD "};
//            if (u_dut.ir_en)     ctrl_active = {ctrl_active, "IR_EN "};
//            if (u_dut.a_load)    ctrl_active = {ctrl_active, "A_LD "};
//            if (u_dut.a_en)      ctrl_active = {ctrl_active, "A_EN "};
//            if (u_dut.b_load)    ctrl_active = {ctrl_active, "B_LD "};
//            if (u_dut.adder_sub) ctrl_active = {ctrl_active, "ADDER_SUB "};
//            if (u_dut.adder_en)  ctrl_active = {ctrl_active, "ADDER_EN "};
//            if (u_dut.hlt)       ctrl_active = {ctrl_active, "HLT "};
//            $display("  Control : Signals Active: %s", ctrl_active);

//            // --- Log Bus Activity (Which module is driving the bus *now*) ---
//            if (u_dut.pc_en)    $display("  Bus <= PC        (%h)", {4'b0, u_dut.pc_out_internal});
//            if (u_dut.mem_en)   $display("  Bus <= MEM (addr %h) = %h", u_dut.u_memory.mar, u_dut.mem_out); // Show MAR value
//            if (u_dut.ir_en)    $display("  Bus <= IR        (%h)", u_dut.ir_out); // Log full IR as mux connects it
//            if (u_dut.a_en)     $display("  Bus <= RegA      (%h)", u_dut.a_out);
//            if (u_dut.adder_en) begin
//                if (u_dut.adder_sub)
//                    $display("  Bus <= Adder (SUB %h-%h) = %h", u_dut.a_out, u_dut.b_out, u_dut.adder_out);
//                else
//                    $display("  Bus <= Adder (ADD %h+%h) = %h", u_dut.a_out, u_dut.b_out, u_dut.adder_out);
//            end
//            if (!u_dut.pc_en && !u_dut.mem_en && !u_dut.ir_en && !u_dut.a_en && !u_dut.adder_en)
//                $display("  Bus <= Driven Low (No EN active)");

//            $display("        Bus Value = %h", u_dut.bus_data);


//            // --- Log Register Loading Actions (Value latched *at this* posedge) ---
//            // Check the *previous* cycle's load signals if needed for precise timing,
//            // but logging based on current load signals shows intent for *next* state.
//            // Let's log what WILL be loaded based on signals asserted NOW.
//            if (u_dut.mar_load) $display("  MAR  <= Bus[3:0] (%h)", u_dut.bus_data[3:0]);
//            if (u_dut.ir_load)  $display("  IR   <= Bus (%h)", u_dut.bus_data);
//            if (u_dut.a_load)   $display("  RegA <= Bus (%h)", u_dut.bus_data);
//            if (u_dut.b_load)   $display("  RegB <= Bus (%h)", u_dut.bus_data);
//            if (u_dut.pc_inc)   $display("  PC incremented (Effect next cycle)");

//            // --- Log Internal Register State (Values *after* this posedge) ---
//            // Use #1 delay to sample values *after* potential updates at posedge
//            // Or simply display current values, knowing they reflect the state *before* the clock edge loads
//            // Let's display the values visible *just before* the next cycle starts
//            #1; // Tiny delay to allow registers to update (for simulation view)
//            $display("  Reg State (Post-Update): A=%h, B=%h, IR=%h, PC=%h, MAR=%h",
//                      u_dut.a_out, u_dut.b_out, u_dut.ir_out,
//                      u_dut.pc_out_internal, u_dut.u_memory.mar);
//            #0; // Reset delay


//        end else if (rst) begin
//             //$display("@%t: In Reset State", $time); // Optional: log during reset
//        end
//        // No logging if halted and not reset
//    end

//    // --- Halt and Display Monitoring ---
//    initial begin
//        // Wait until the HLT output from the DUT is asserted
//        wait (hlt_out == 1'b1);

//        $display("\n--------------------------------------------------");
//        $display("CPU HALTED at Time: %t ns", $time);
//        $display("--------------------------------------------------");
//        $display("Final CPU State:");
//        $display("  PC = %h", u_dut.pc_out_internal);
//        $display("  IR = %h", u_dut.ir_out);
//        $display("  A  = %h (Decimal: %0d)", u_dut.a_out, u_dut.a_out);
//        $display("  B  = %h (Decimal: %0d)", u_dut.b_out, u_dut.b_out);
//        $display("  MAR= %h", u_dut.u_memory.mar);

//        // Display BCD conversion results (accessing internal signals)
//        $display("\nBCD Conversion of Register A (%h):", u_dut.a_out);
//        // ** Check instance name of binary_to_bcd inside sap1_cpu_top **
//        // Assuming it's u_bin_to_bcd:
//        $display("  Hundreds = %d (%h)", u_dut.u_bin_to_bcd.bcd_hundreds, u_dut.u_bin_to_bcd.bcd_hundreds);
//        $display("  Tens     = %d (%h)", u_dut.u_bin_to_bcd.bcd_tens, u_dut.u_bin_to_bcd.bcd_tens);
//        $display("  Ones     = %d (%h)", u_dut.u_bin_to_bcd.bcd_ones, u_dut.u_bin_to_bcd.bcd_ones);

//        // Monitor the 7-segment display outputs for a short period after halt
//        $display("\nMonitoring 7-Segment Outputs (Post-Halt):");
//        $display("Format: Time | AN(3:0) | SEG(gfedcba)");
//        repeat (16) begin // Monitor for 16 clock cycles (adjust as needed)
//             @(posedge clk_in); // Use the main clock here
//             $display("  @%t | %b | %b", $time, an_out, seg_out);
//        end
//        $display("--------------------------------------------------");

//    end

endmodule