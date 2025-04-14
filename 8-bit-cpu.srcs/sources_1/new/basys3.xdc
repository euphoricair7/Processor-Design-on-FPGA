## Basys 3 Constraints File for SAP-1 CPU Project
## Target Device: Xilinx Artix-7 XC7A35T-1CPG236C

#------------------------------------------------------------------------------
# Clock Signal
#------------------------------------------------------------------------------
# Connects to the 100MHz oscillator on the Basys 3 board (Pin W5)
set_property -dict { PACKAGE_PIN W5   IOSTANDARD LVCMOS33 } [get_ports clk_in]
# Define the clock period (10ns for 100MHz) for timing analysis
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk_in]

#------------------------------------------------------------------------------
# Reset Button
#------------------------------------------------------------------------------
# Connects to the Center Push Button (BTNC - Pin U18)
set_property -dict { PACKAGE_PIN U18 IOSTANDARD LVCMOS33 } [get_ports rst]

#------------------------------------------------------------------------------
# Halt Status LED
#------------------------------------------------------------------------------
# Connects to LED LD0 (Pin U16) to indicate CPU halt status
set_property -dict { PACKAGE_PIN U16 IOSTANDARD LVCMOS33 } [get_ports hlt_out]

#------------------------------------------------------------------------------
# 7-Segment Display
#------------------------------------------------------------------------------
## Segment Cathodes (Active LOW)
# Maps seg_out[6:0] to segments g,f,e,d,c,b,a respectively
set_property -dict { PACKAGE_PIN W7   IOSTANDARD LVCMOS33 } [get_ports {seg_out[0]}] ;# Segment A
set_property -dict { PACKAGE_PIN W6   IOSTANDARD LVCMOS33 } [get_ports {seg_out[1]}] ;# Segment B
set_property -dict { PACKAGE_PIN U8   IOSTANDARD LVCMOS33 } [get_ports {seg_out[2]}] ;# Segment C
set_property -dict { PACKAGE_PIN V8   IOSTANDARD LVCMOS33 } [get_ports {seg_out[3]}] ;# Segment D
set_property -dict { PACKAGE_PIN U5   IOSTANDARD LVCMOS33 } [get_ports {seg_out[4]}] ;# Segment E
set_property -dict { PACKAGE_PIN V5   IOSTANDARD LVCMOS33 } [get_ports {seg_out[5]}] ;# Segment F
set_property -dict { PACKAGE_PIN U7   IOSTANDARD LVCMOS33 } [get_ports {seg_out[6]}] ;# Segment G

## Anode Selectors (Active HIGH)
# Maps an_out[3:0] to AN3, AN2, AN1, AN0 respectively (Left to Right)
set_property -dict { PACKAGE_PIN U2   IOSTANDARD LVCMOS33 } [get_ports {an_out[0]}] ;# Anode 0 (Rightmost)
set_property -dict { PACKAGE_PIN U4   IOSTANDARD LVCMOS33 } [get_ports {an_out[1]}] ;# Anode 1
set_property -dict { PACKAGE_PIN V4   IOSTANDARD LVCMOS33 } [get_ports {an_out[2]}] ;# Anode 2
set_property -dict { PACKAGE_PIN W4   IOSTANDARD LVCMOS33 } [get_ports {an_out[3]}] ;# Anode 3 (Leftmost)

#------------------------------------------------------------------------------
# General Configuration Settings (Recommended for all Basys 3 designs)
#------------------------------------------------------------------------------
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]

#------------------------------------------------------------------------------
# SPI Configuration Settings (for programming via QSPI Flash)
#------------------------------------------------------------------------------
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]

# --- End of Constraints File ---