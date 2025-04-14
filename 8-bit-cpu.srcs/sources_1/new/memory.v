// SAP-1 Memory Module (16 Bytes with MAR)

module memory (
    input         clk,    // Clock input
    input         rst,    // Synchronous reset input
    input         load,   // Load enable for Memory Address Register (MAR)
    input  [7:0]  bus,    // Input bus (provides address for MAR on bits 3:0)
    output [7:0]  out     // Data output from RAM location pointed to by MAR
);

    // Declare the 16-byte x 8-bit RAM using registers
    // Addressable from 0 (0x0) to 15 (0xF)
    reg [7:0] ram [0:15];

    // Declare the 4-bit Memory Address Register (MAR)
    reg [3:0] mar;

    // Initialize memory content from an external file at power-up/simulation start
    // Create a file named "memory.hex" (or .bin) in your project directory.
    // It should contain 16 lines, each with an 8-bit hex (or binary) value.
    initial begin
        // Use $readmemh for a hex file (e.g., "memory.hex")
        // Use $readmemb for a binary file (e.g., "memory.bin")
        $readmemh("/home/shivang/vivadoprojects/8-bit-cpu/memory.hex", ram); ; 
        
//        // For testing without a file, you can initialize manually:
//         ram[0] = 8'h01; // Example instruction LDA 15
//         ram[1] = 8'h0F;
//         ram[2] = 8'h11; // Example instruction ADD 14
//         ram[3] = 8'h0E; 
//         // ... initialize other locations up to ram[15] ...
//         ram[14] = 8'h10; // Example data 16
//         ram[15] = 8'h20; // Example data 32
//         // Ensure all 16 locations are defined if using manual init
    end

    // MAR Logic: Load address bits from bus when 'load' is high
    always @(posedge clk) begin
        if (rst) begin
            // Reset MAR to 0 on reset
            mar <= 4'b0000;
        end else if (load) begin
            // Load the lower 4 bits from the bus into the MAR
            // Assuming address is placed on bus[3:0] during MAR load cycle
            mar <= bus[3:0]; 
        end
        // If neither rst nor load is high, MAR holds its previous value.
    end

    // Memory Read Logic: Combinational read based on current MAR value
    // The output 'out' always reflects the content of the RAM at the address stored in MAR.
    // The CPU controller determines when this 'out' value is actually driven onto the main bus.
    assign out = ram[mar];

endmodule