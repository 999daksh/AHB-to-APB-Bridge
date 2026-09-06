# AHB-to-APB Bridge — Verilog RTL & SystemVerilog/UVM Verification

A synthesizable **32-bit AHB-to-APB Bridge** implemented in **Verilog HDL**, with a **SystemVerilog/UVM-based verification environment** for functional verification of AMBA protocol conversion.

The project demonstrates the complete RTL design and verification flow, including protocol analysis, modular RTL architecture, FSM-based control, UVM testbench development, constrained-random stimulus generation, scoreboard-based checking, behavioral simulation, waveform analysis, and RTL synthesis.

---

## Table of Contents
- [Project Overview](#project-overview)
- [Features](#features)
- [AMBA Protocols](#amba-protocols)
- [System Architecture](#system-architecture)
- [RTL Architecture](#rtl-architecture)
- [RTL Modules](#rtl-modules)
- [Bridge FSM](#bridge-fsm)
- [Data Flow](#data-flow)
- [Verification Environment](#verification-environment)
- [UVM Components](#uvm-components)
- [Verification Strategy](#verification-strategy)
- [Verification Results](#verification-results)
- [Simulation](#simulation)
- [Synthesis](#synthesis)
- [Project Directory](#project-directory)
- [Tools and Technologies](#tools-and-technologies)
- [Current Scope](#current-scope)
- [Future Enhancements](#future-enhancements)
- [Key Learning Outcomes](#key-learning-outcomes)
- [Author](#author)

---

## Project Overview

The **AHB-to-APB Bridge** provides protocol conversion between an AMBA **AHB master** and an APB peripheral.

AHB is intended for higher-performance system communication, while APB is designed for simpler, low-bandwidth peripherals such as:

- UART
- GPIO
- Timers
- Control/status registers
- Other peripheral interfaces

The bridge accepts an AHB transaction, captures the required transaction information, converts it into an APB transfer, waits for the APB peripheral to complete the transfer, and returns APB read data to the AHB side.

### Basic Transaction Flow

\`\`\`text
                 AHB Master
                     |
                     v
             +----------------+
             |  AHB Slave IF  |
             +--------+-------+
                      |
              Captured AHB Data
                      |
                      v
             +----------------+
             |   Bridge FSM   |
             +--------+-------+
                      |
                APB Control
                      |
                      v
             +----------------+
             |  APB Master IF |
             +--------+-------+
                      |
                      v
                 APB Slave
                      |
                 PRDATA/PREADY
                      |
                      v
                   AHB Side
\`\`\`

---

## Features

### RTL Features

- 32-bit AHB-to-APB bridge
- Single AHB transaction support
- Single read and write transaction support
- FSM-based protocol conversion
- APB Setup phase generation
- APB Enable phase generation
- APB wait-state handling through `PREADY`
- AHB address capture
- AHB write-data capture
- AHB read/write control capture
- APB address generation
- APB write-data generation
- APB read-data forwarding
- Modular hierarchical RTL architecture
- Synthesizable Verilog HDL

### Verification Features

- SystemVerilog/UVM-based testbench
- Constrained-random AHB stimulus generation
- Transaction-level AHB and APB monitoring
- Scoreboard-based automatic checking
- APB slave behavioral model
- Directed read and write transaction tests

---

## AMBA Protocols

### AHB

The bridge receives transactions from the AHB side.

Important AHB signals used by the design include:

| Signal | Description |
|---|---|
| `HCLK` | AHB clock |
| `HRESETn` | Active-low reset |
| `HSEL` | Selects the AHB slave |
| `HADDR` | Address |
| `HWRITE` | Read/write control |
| `HWDATA` | Write data |
| `HTRANS` | Transfer type |
| `HSIZE` | Transfer size |
| `HREADY` | Indicates completion of previous transfer |
| `HRDATA` | Read data returned to AHB master |
| `HREADYOUT` | Bridge ready/completion indication |

`HTRANS` encoding:

\`\`\`text
00 -> IDLE
01 -> BUSY
10 -> NONSEQ
11 -> SEQ
\`\`\`

The current implementation supports valid single transfers.

### APB

The bridge drives the APB side.

Important APB signals include:

| Signal | Description |
|---|---|
| `PADDR` | APB address |
| `PWDATA` | APB write data |
| `PWRITE` | Read/write control |
| `PSEL` | Peripheral select |
| `PENABLE` | APB enable phase |
| `PREADY` | Peripheral ready indication |
| `PRDATA` | Peripheral read data |

### APB Transfer

An APB transfer consists of two phases:

\`\`\`text
Setup Phase
    |
    | PSEL = 1
    | PENABLE = 0
    |
    v
Enable Phase
    |
    | PSEL = 1
    | PENABLE = 1
    |
    v
Transfer Complete
\`\`\`

The bridge remains in the Enable phase until the APB peripheral asserts `PREADY = 1`.

---

## System Architecture

The overall system is divided into an AHB interface, bridge control logic, and APB interface.

\`\`\`text
                           AHB Master
                               |
                               |
          +--------------------v--------------------+
          |              bridge_top                 |
          |                                          |
          |   +-------------------------------+      |
          |   |       ahb_slave_if            |      |
          |   +---------------+---------------+      |
          |                   |                      |
          |              addr_reg                    |
          |              data_reg                    |
          |              write_reg                   |
          |              trans_valid                 |
          |                   |                      |
          |          +--------+--------+             |
          |          |                 |             |
          |          v                 v             |
          |   +-------------+   +---------------+    |
          |   | bridge_fsm  |   | apb_master_if |    |
          |   +------+------+   +-------+-------+    |
          |          |                   |           |
          |      PSEL/PENABLE      PADDR/PWDATA       |
          |      HREADYOUT              PWRITE        |
          |          |                   |            |
          +----------+-------------------+------------+
                     |
                     v
                 APB Slave
                     |
                PRDATA/PREADY
                     |
                     v
                  HRDATA
\`\`\`

---

## RTL Architecture

The RTL is divided into four main files.

\`\`\`text
bridge_top
│
├── ahb_slave_if
│
├── bridge_fsm
│
└── apb_master_if
\`\`\`

The design follows a clear separation between:

### Control Path

`bridge_fsm` is responsible for:

- `PSEL`
- `PENABLE`
- `HREADYOUT`
- APB transfer sequencing

### Datapath

\`\`\`text
ahb_slave_if
        |
        v
addr_reg
data_reg
write_reg
        |
        v
apb_master_if
\`\`\`

Responsible for:

- Address
- Write data
- Read/write control
- APB bus connections

---

## RTL Modules

### 1. `ahb_slave_if.v`

The AHB Slave Interface receives transactions from the AHB master and captures the required information for the APB transfer.

**Responsibilities**
- Detect valid AHB transactions
- Capture `HADDR`
- Capture `HWDATA`
- Capture `HWRITE`
- Capture `HSIZE`
- Generate `trans_valid`

**Internal Registers**
- `addr_reg`
- `data_reg`
- `write_reg`
- `size_reg`
- `trans_valid`

The captured information is then provided to the bridge control logic and APB interface.

### 2. `bridge_fsm.v`

The Bridge FSM controls the AHB-to-APB transfer sequencing.

**FSM States**
- `IDLE`
- `SETUP`
- `ENABLE`

**Responsibilities**
- Generate `PSEL`
- Generate `PENABLE`
- Generate `HREADYOUT`
- Wait for `PREADY`
- Control APB timing

### 3. `apb_master_if.v`

The APB Master Interface drives the APB bus using the information captured from the AHB side.

**Responsibilities**

\`\`\`text
addr_reg   -> PADDR
data_reg   -> PWDATA
write_reg  -> PWRITE
\`\`\`

The APB control signals generated by the FSM are also forwarded to the APB interface.

### 4. `bridge_top.v`

The top-level module integrates all bridge components.

\`\`\`text
bridge_top
│
├── ahb_slave_if
├── bridge_fsm
└── apb_master_if
\`\`\`

It also provides the APB read-data return path:

\`\`\`text
PRDATA -> HRDATA
\`\`\`

---

## Bridge FSM

The bridge uses a three-state finite state machine.

\`\`\`text
                      +------+
                      | IDLE |
                      +--+---+
                         |
                   trans_valid
                         |
                         v
                    +---------+
                    |  SETUP  |
                    +----+----+
                         |
                         v
                    +---------+
                    | ENABLE  |
                    +----+----+
                         |
                 +-------+-------+
                 |               |
             PREADY = 0       PREADY = 1
                 |               |
                 +------<--------+
                                 |
                                 v
                               IDLE
\`\`\`

### State Description

**IDLE**
\`\`\`text
PSEL      = 0
PENABLE   = 0
HREADYOUT = 1
\`\`\`
The bridge waits for a valid AHB transaction.

**SETUP**
\`\`\`text
PSEL      = 1
PENABLE   = 0
\`\`\`
The APB transfer is initiated during this phase.

**ENABLE**
\`\`\`text
PSEL      = 1
PENABLE   = 1
\`\`\`
The APB transfer is active. If `PREADY = 0`, the bridge remains in `ENABLE`. When `PREADY = 1`, the APB transfer completes and the FSM returns to `IDLE`.

---

## Data Flow

### Write Transaction

\`\`\`text
AHB Master
    |
    | HADDR
    | HWDATA
    | HWRITE = 1
    |
    v
AHB Slave Interface
    |
    v
addr_reg
data_reg
write_reg
    |
    v
APB Master Interface
    |
    | PADDR
    | PWDATA
    | PWRITE = 1
    |
    v
APB Peripheral
\`\`\`

### Read Transaction

\`\`\`text
AHB Master
    |
    | HADDR
    | HWRITE = 0
    |
    v
AHB Slave Interface
    |
    v
APB Master Interface
    |
    | PADDR
    | PWRITE = 0
    |
    v
APB Peripheral
    |
    | PRDATA
    |
    v
HRDATA
    |
    v
AHB Master
\`\`\`

---

## Verification Environment

The project includes a SystemVerilog/UVM-based verification environment to verify the bridge functionality at the transaction level.

The UVM environment is organized around the AHB interface while an APB slave model provides peripheral-side behavior.

\`\`\`text
              +-------------+
              |   Sequence  |
              +-------------+
                     |
                     v
              +-------------+
              |  Sequencer  |
              +-------------+
                     |
                     v
              +-------------+
              |   Driver    |
              +-------------+
                     |
                     v
                    DUT
                 /       \\
                /         \\
               v           v
        AHB Monitor    APB Monitor
               \\           /
                \\         /
                 v       v
              +-------------+
              | Scoreboard  |
              +-------------+
\`\`\`

---

## UVM Components

- `ahb_transaction` — AHB transaction object
- `ahb_sequence` — Generates constrained-random transactions
- `ahb_sequencer` — Sends transactions to the driver
- `ahb_driver` — Converts transactions into AHB pin-level activity
- `ahb_monitor` — Observes AHB transfers
- `apb_monitor` — Observes APB transfers
- `apb_slave_model` — Models APB slave responses
- `bridge_scoreboard` — Compares AHB and APB transactions
- `ahb_agent` — Contains AHB sequencer, driver, and monitor
- `bridge_env` — Integrates the verification components

---

## Verification Strategy

The testbench generates AHB read/write transactions and verifies the corresponding APB activity.

The scoreboard checks:

- AHB address vs APB address
- AHB read/write control vs APB read/write control
- AHB write data vs APB write data
- APB read data vs AHB read data

## Verification Results

The completed test verified:

- 4 write transactions
- 1 read transaction
- 0 UVM errors
- 0 UVM fatal errors
- Successful end-to-end scoreboard matching

---

## Simulation

The testbench and UVM environment can be run with any standard SystemVerilog/UVM-capable simulator (e.g., QuestaSim, VCS, or Xcelium).

Typical simulation flow:

\`\`\`bash
# Compile RTL and UVM sources
vlog rtl/*.v uvm/*.sv tb/bridge_tb.v

# Run the simulation with UVM
vsim -c work.bridge_tb +UVM_TESTNAME=bridge_test -do "run -all"
\`\`\`

Waveforms can be dumped and viewed in a waveform viewer (e.g., QuestaSim's built-in waveform window or GTKWave) to inspect AHB and APB signal timing.

> Adjust the exact compile/run commands to match the simulator available in your environment.

## Synthesis

The RTL modules are written as synthesizable Verilog HDL and can be synthesized with standard synthesis tools (e.g., Yosys for open-source flows, or Design Compiler/Genus for commercial flows).

Typical synthesis flow:

\`\`\`bash
# Example using Yosys
yosys -p "read_verilog rtl/*.v; synth -top bridge_top; write_verilog synth/bridge_top_synth.v"
\`\`\`

> Adjust the target library and synthesis tool to match your specific flow.

---

## Project Directory

\`\`\`text
AHB-to-APB-Bridge/
│
├── rtl/
│   ├── ahb_slave_if.v
│   ├── bridge_fsm.v
│   ├── apb_master_if.v
│   └── bridge_top.v
│
├── tb/
│   └── bridge_tb.v
│
├── uvm/
│   ├── ahb_sequence_item.sv
│   ├── ahb_sequence.sv
│   ├── ahb_sequencer.sv
│   ├── ahb_driver.sv
│   ├── ahb_monitor.sv
│   ├── apb_slave_model.sv
│   ├── scoreboard.sv
│   ├── env.sv
│   └── test.sv
│
├── docs/
│   ├── block_diagram.png
│   ├── fsm.png
│   └── simulation_waveform.png
│
├── sim/
│   └── ...
│
└── README.md
\`\`\`

---

## Tools and Technologies

- **Design language:** Verilog HDL
- **Verification language/methodology:** SystemVerilog, UVM
- **Simulation:** Any UVM-capable simulator (QuestaSim / VCS / Xcelium)
- **Waveform analysis:** Simulator waveform viewer / GTKWave
- **Synthesis:** Standard RTL synthesis tools (e.g., Yosys, Design Compiler, Genus)

---

## Current Scope

The current implementation focuses on a basic 32-bit single-transfer AHB-to-APB bridge.

### Supported

- Single AHB transfer
- AHB read transactions
- AHB write transactions
- APB Setup phase
- APB Enable phase
- APB wait-state handling
- APB read-data forwarding
- SystemVerilog/UVM verification

### Not Yet Implemented

- AHB burst transfers
- Multiple APB slave address decoding
- `PSLVERR` to `HRESP` error propagation
- Full AHB pipelined address/data-phase handling
- Functional coverage
- SystemVerilog Assertions

---

## Future Enhancements

- Add support for AHB burst transfers
- Implement multiple APB slave address decoding
- Propagate `PSLVERR` to `HRESP` for error handling
- Support full AHB pipelined address/data-phase operation
- Add functional coverage collection
- Add SystemVerilog Assertions (SVA) for protocol checking

---

## Key Learning Outcomes

- Understanding of AMBA AHB and APB protocol signaling and timing
- FSM-based design for protocol bridging
- Modular, hierarchical RTL design practices
- Building a SystemVerilog/UVM verification environment from scratch
- Constrained-random stimulus generation and transaction-level modeling
- Scoreboard-based functional checking between two different bus protocols
- Waveform-based debugging and RTL synthesis flow

---

## Author

**Daksh Maheshwari**
B.Tech, Electronics and Communication Engineering, Birla Institute of Technology, Mesra
