#!/bin/bash

# --- Simple SAP-1 Assembler Script (with ALU Instructions) ---

# Input assembly file is the first argument
input_asm_file="$1"
# Output hex file for Verilog memory initialization
output_hex_file="memory.hex"
# Total memory size for SAP-1 (16 bytes)
mem_size=16

# --- Input Validation ---
if [[ -z "$input_asm_file" ]]; then
  echo "Usage: $0 <input_assembly_file.sap1>"
  exit 1
fi
if [[ ! -f "$input_asm_file" ]]; then
  echo "Error: Input file '$input_asm_file' not found."
  exit 1
fi

# --- Opcode Definitions (4-bit Hex Nibbles) ---
# Associative array to map instruction mnemonics to hex opcodes
declare -A opcodes=(
  ["LDA"]="0"
  ["ADD"]="1"
  ["SUB"]="2"
  # Opcodes 3, 4 unused
  ["AND"]="5"   # New
  ["OR"]="6"    # New
  ["XOR"]="7"   # New
  ["NOTA"]="8"  # New (Assumes operand needed for address fetch consistency)
  # Opcodes 9-E unused
  ["HLT"]="F"
)

# --- Memory Representation ---
declare -a memory_image
for ((i=0; i<mem_size; i++)); do
  memory_image[$i]="00"
done
current_address=0

# --- Processing the Assembly File ---
echo "Assembling '$input_asm_file'..."
while IFS= read -r line || [[ -n "$line" ]]; do
  # Clean up line (remove whitespace, comments)
  line=$(echo "$line" | sed 's/^[ \t]*//;s/[ \t]*$//')
  if [[ -z "$line" ]] || [[ "$line" == \#* ]]; then continue; fi
  line=${line%%#*}
  line=$(echo "$line" | sed 's/[ \t]*$//')
  if [[ -z "$line" ]]; then continue; fi

  # Parse instruction/directive and operand
  read -r instruction operand <<< "$line"
  instruction=$(echo "$instruction" | tr '[:lower:]' '[:upper:]')

  # --- Handle Directives ---
  if [[ "$instruction" == ".PAD" ]]; then
    if [[ -z "$operand" ]] || ! [[ "$operand" =~ ^[0-9A-Fa-f]$ ]]; then
        echo "Error: Invalid/missing hex address '$operand' for .PAD (must be 0-F). Line: $line"; exit 1;
    fi
    target_address=$((16#$operand))
    if (( target_address < current_address )) || (( target_address >= mem_size )); then
       echo "Error: .PAD target address 0x$operand out of range or backwards. Line: $line"; exit 1;
    fi
    echo "  Padding up to address 0x$operand"
    current_address=$target_address
    continue

  elif [[ "$instruction" == ".BYTE" ]]; then
    if [[ -z "$operand" ]] || ! [[ "$operand" =~ ^[0-9A-Fa-f]{1,2}$ ]]; then
        echo "Error: Invalid/missing hex operand '$operand' for .BYTE. Line: $line"; exit 1;
    fi
    if (( current_address >= mem_size )); then
      echo "Error: Program exceeds memory size ($mem_size bytes). Address 0x$(printf %X $current_address)"; exit 1;
    fi
    hex_byte=$(printf "%02X" "0x$operand")
    echo "  Address 0x$(printf %X $current_address): .BYTE $hex_byte"
    memory_image[$current_address]="$hex_byte"
    ((current_address++))
    continue
  fi

  # --- Handle Instructions ---
  opcode_nibble=${opcodes[$instruction]}
  if [[ -z "$opcode_nibble" ]]; then
    echo "Error: Unknown instruction '$instruction'. Line: $line"; exit 1;
  fi

  # Prepare operand nibble (default to 0 for HLT, potentially check NOTA later if simplified)
  operand_nibble="0"
  # Assume all instructions except HLT require an operand (even NOTA for consistency here)
  if [[ "$instruction" != "HLT" ]]; then
    if [[ -z "$operand" ]] || ! [[ "$operand" =~ ^[0-9A-Fa-f]$ ]]; then
        echo "Error: Invalid/missing hex operand '$operand' for $instruction (must be 0-F). Line: $line"; exit 1;
    fi
    operand_nibble=$(echo "$operand" | tr '[:lower:]' '[:upper:]')
  fi

  hex_byte="${opcode_nibble}${operand_nibble}"
  if (( current_address >= mem_size )); then
    echo "Error: Program exceeds memory size ($mem_size bytes). Address 0x$(printf %X $current_address)"; exit 1;
  fi

  echo "  Address 0x$(printf %X $current_address): $instruction $operand -> $hex_byte"
  memory_image[$current_address]="$hex_byte"
  ((current_address++))

done < "$input_asm_file"

# --- Write the Output Hex File ---
> "$output_hex_file"
echo "Writing memory image to '$output_hex_file'..."
for ((i=0; i<mem_size; i++)); do
  echo "${memory_image[$i]}" >> "$output_hex_file"
done

echo "Assembly complete. Output file: $output_hex_file"
exit 0
