//------------------------------------------------------------------------------
// Module: controller (Modified for ALU)
// Description: SAP-1 CPU Controller with expanded control word for ALU ops.
//------------------------------------------------------------------------------
module controller(
    input         clk,        // Clock input (Gated clock from clock module)
    input         rst,        // Synchronous reset input
    input  [3:0]  opcode,     // Opcode from Instruction Register (IR[7:4])
    output [13:0] out         // *** EXPANDED to 14-bit control word output ***
);

    // --- Control Signal Bit Mapping (14 bits) ---
    localparam SIG_HLT        = 13;
    localparam SIG_PC_INC     = 12; 
    localparam SIG_PC_EN      = 11;
    localparam SIG_MEM_LOAD   = 10; // MAR Load
    localparam SIG_MEM_EN     = 9;
    localparam SIG_IR_LOAD    = 8;
    localparam SIG_IR_EN      = 7;
    localparam SIG_A_LOAD     = 6;
    localparam SIG_A_EN       = 5;  // Output from Reg A onto bus (e.g., for potential future STORE)
    localparam SIG_B_LOAD     = 4;
    localparam SIG_ALU_EN     = 3;  // Enable ALU result onto bus
    // --- ALU Operation Select Bits (Uses bits 2:0) ---
    localparam SIG_ALU_OP_SEL_BASE = 0; // Bits [2:0] used for ALU op select

    // --- ALU Operation Codes (Must match alu.v) ---
    localparam OP_ADD   = 3'b000;
    localparam OP_SUB   = 3'b001;
    localparam OP_AND   = 3'b010;
    localparam OP_OR    = 3'b011;
    localparam OP_XOR   = 3'b100;
    localparam OP_NOT_A = 3'b101;

    // --- Instruction Opcodes (4-bit from IR[7:4]) ---
    localparam OP_LDA_I   = 4'b0000; // LDA instruction
    localparam OP_ADD_I   = 4'b0001; // ADD instruction
    localparam OP_SUB_I   = 4'b0010; // SUB instruction
    // Opcodes 3, 4 unused
    localparam OP_AND_I   = 4'b0101; // AND instruction (New)
    localparam OP_OR_I    = 4'b0110; // OR instruction  (New)
    localparam OP_XOR_I   = 4'b0111; // XOR instruction (New)
    localparam OP_NOTA_I  = 4'b1000; // NOT A instruction (New)
    // Opcodes 9-E unused
    localparam OP_HLT_I   = 4'b1111; // HLT instruction

    // Internal state registers
    reg [2:0]  stage;         // Execution stage (0-5)
    reg [13:0] ctrl_word;     // *** Intermediate register for 14-bit control word ***
    reg        hlt_ff;        // Flip-flop to latch HALT state

    // --- Sequential Logic ---

    // Stage Counter (Positive Edge Triggered)
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            stage <= 3'b000;
        end else if (!hlt_ff) begin // Only advance if not halted
            if (stage == 3'd5) begin
                stage <= 3'b000;      // Wrap to Stage 0
            end else begin
                stage <= stage + 1;   // Go to next stage
            end
        end
    end

    // Halt Flip-Flop: Set when HLT instruction reaches stage 3
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            hlt_ff <= 1'b0;
        // Set halt flip-flop only if HLT decoded at stage 3 and not already halted
        end else if (stage == 3'd3 && opcode == OP_HLT_I && !hlt_ff) begin
             hlt_ff <= 1'b1;
        end
        // else: halt flip-flop holds its value
    end

    // --- Combinational Logic: Generate control word ---
    always @(*) begin
        ctrl_word = 14'b0; // Default: All inactive

        if (hlt_ff) begin
            ctrl_word[SIG_HLT] = 1'b1; // Only assert HLT signal if halted
        end else begin
            // --- Instruction Fetch Stages (Common to most instructions) ---
            case (stage)
                3'd0: begin // Stage 0: PC -> MAR
                    ctrl_word[SIG_PC_EN]     = 1'b1;
                    ctrl_word[SIG_MEM_LOAD]  = 1'b1; // MAR Load
                end
                3'd1: begin // Stage 1: Increment PC
                    ctrl_word[SIG_PC_INC]    = 1'b1;
                end
                3'd2: begin // Stage 2: Memory -> IR
                    ctrl_word[SIG_MEM_EN]    = 1'b1;
                    ctrl_word[SIG_IR_LOAD]   = 1'b1;
                end

                // --- Instruction Execution Stages (Depend on Opcode) ---
                3'd3: begin // Stage 3: Decode / Operand Address Fetch (IR -> MAR)
                    case (opcode)
                        // Instructions needing an operand from memory
                        OP_LDA_I, OP_ADD_I, OP_SUB_I, OP_AND_I, OP_OR_I, OP_XOR_I, OP_NOTA_I: begin
                            ctrl_word[SIG_IR_EN] = 1'b1;
                            ctrl_word[SIG_MEM_LOAD] = 1'b1; // MAR Load
                        end
                        OP_HLT_I: begin
                            // HLT signal will be generated here but latched next cycle
                            // We can assert it combinationally too if needed immediately
                             ctrl_word[SIG_HLT] = 1'b1;
                        end
                        default: ; // Undefined opcodes are NOPs
                    endcase
                end
                3'd4: begin // Stage 4: Data Fetch (Memory -> B) or Load A
                    case (opcode)
                        OP_LDA_I: begin // LDA loads directly to A
                            ctrl_word[SIG_MEM_EN] = 1'b1;
                            ctrl_word[SIG_A_LOAD] = 1'b1;
                        end
                        // Instructions needing operand loaded into B
                        OP_ADD_I, OP_SUB_I, OP_AND_I, OP_OR_I, OP_XOR_I, OP_NOTA_I: begin
                            ctrl_word[SIG_MEM_EN] = 1'b1;
                            ctrl_word[SIG_B_LOAD] = 1'b1;
                        end
                        default: ; // HLT, NOPs are idle
                    endcase
                end
                3'd5: begin // Stage 5: Execution (ALU -> A)
                    case (opcode)
                        OP_ADD_I: begin
                             ctrl_word[SIG_ALU_EN] = 1'b1; // Put ALU result on bus
                             ctrl_word[SIG_ALU_OP_SEL_BASE + 2 : SIG_ALU_OP_SEL_BASE] = OP_ADD; // Select ADD
                             ctrl_word[SIG_A_LOAD] = 1'b1; // Load bus into A
                        end
                        OP_SUB_I: begin
                             ctrl_word[SIG_ALU_EN] = 1'b1;
                             ctrl_word[SIG_ALU_OP_SEL_BASE + 2 : SIG_ALU_OP_SEL_BASE] = OP_SUB; // Select SUB
                             ctrl_word[SIG_A_LOAD] = 1'b1;
                        end
                        OP_AND_I: begin
                             ctrl_word[SIG_ALU_EN] = 1'b1;
                             ctrl_word[SIG_ALU_OP_SEL_BASE + 2 : SIG_ALU_OP_SEL_BASE] = OP_AND; // Select AND
                             ctrl_word[SIG_A_LOAD] = 1'b1;
                        end
                        OP_OR_I: begin
                             ctrl_word[SIG_ALU_EN] = 1'b1;
                             ctrl_word[SIG_ALU_OP_SEL_BASE + 2 : SIG_ALU_OP_SEL_BASE] = OP_OR; // Select OR
                             ctrl_word[SIG_A_LOAD] = 1'b1;
                        end
                        OP_XOR_I: begin
                             ctrl_word[SIG_ALU_EN] = 1'b1;
                             ctrl_word[SIG_ALU_OP_SEL_BASE + 2 : SIG_ALU_OP_SEL_BASE] = OP_XOR; // Select XOR
                             ctrl_word[SIG_A_LOAD] = 1'b1;
                        end
                         OP_NOTA_I: begin
                             ctrl_word[SIG_ALU_EN] = 1'b1;
                             ctrl_word[SIG_ALU_OP_SEL_BASE + 2 : SIG_ALU_OP_SEL_BASE] = OP_NOT_A; // Select NOT A
                             ctrl_word[SIG_A_LOAD] = 1'b1;
                         end
                        default: ; // LDA, HLT, NOPs are idle in this stage
                    endcase
                end
                default: ; // Should not happen
            endcase
        end // end if(!hlt_ff)
    end // end always @*

    // Final assignment
    assign out = ctrl_word;

endmodule