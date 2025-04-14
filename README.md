## Structure
It contains the verilog files, assembler script and a test program.
```
.
├── 8-bit-cpu.srcs
│   ├── constrs_1
│   │   └── new
│   │       └── basys3.xdc
│   ├── sim_1
│   │   └── new
│   │       └── sap_1_cpu_tb.v
│   ├── sources_1
│   │   └── new
│   │       ├── alu.v
│   │       ├── basys3.xdc
│   │       ├── bcd_to_7seg.v
│   │       ├── binary_to_bcd.v
│   │       ├── bux_mux.v
│   │       ├── clock.v
│   │       ├── controller.v
│   │       ├── ir.v
│   │       ├── memory.v
│   │       ├── pc.v
│   │       ├── reg_a.v
│   │       ├── reg_b.v
│   │       ├── sap_1_cpu_top.v
│   │       └── seven_segment_controller.v
│   └── utils_1
│       └── imports
│           └── synth_1
│               └── sap1_cpu_top.dcp
├── assemble_sap1.sh
└── p-alu-full-test-program.sap1
```
