# 🌉 AHB-to-APB Bridge

![Verilog](https://img.shields.io/badge/Language-Verilog-blue)
![Protocol](https://img.shields.io/badge/AMBA-AHB%20%2F%20APB-orange)
![Verification](https://img.shields.io/badge/Verification-UVM-red)
![Methodology](https://img.shields.io/badge/Methodology-SystemVerilog-purple)
![License](https://img.shields.io/badge/License-MIT-yellow)

A **32-bit AHB-to-APB Bridge** implemented in **Verilog HDL**, converting AMBA **AHB** transactions from a high-performance master into **APB** transfers for low-bandwidth peripherals. The design supports **single read/write transactions**, **FSM-based protocol sequencing**, and **APB wait-state handling** through `PREADY`.

The design was verified using a **SystemVerilog/UVM** testbench with constrained-random stimulus, transaction-level monitoring, and scoreboard-based checking between the AHB and APB sides.

---

## ✨ Features

- 32-bit AHB-to-APB bridge
- Single AHB transaction support
- Single read and write transaction support
- FSM-based protocol conversion
- APB Setup phase generation
- APB Enable phase generation
- APB wait-state handling through `PREADY`
- AHB address, write-data, and read/write control capture
- APB address, write-data generation, and read-data forwarding
- Modular hierarchical RTL architecture
- Synthesizable Verilog HDL
- SystemVerilog/UVM-based testbench
- Constrained-random AHB stimulus generation
- Transaction-level AHB and APB monitoring
- Scoreboard-based automatic checking
- APB slave behavioral model

---

# 📡 AMBA Protocols

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

```
00 -> IDLE
01 -> BUSY
10 -> NONSEQ
11 -> SEQ
```

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

```
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
```

The bridge remains in the Enable phase until the APB peripheral asserts `PREADY = 1`.

---

# 🏗️ System Architecture

The overall system is divided into an AHB interface, bridge control logic, and APB interface.

```
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
```

---

# 📂 Repository Structure

```
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
│   ├── ahb_agent.sv
│   ├── ahb_driver.sv
│   ├── ahb_if.sv
│   ├── ahb_monitor.sv
│   ├── ahb_sequence.sv
│   ├── ahb_sequence_item.sv
│   ├── ahb_sequencer.sv
│   ├── apb_if.sv
│   ├── apb_monitor.sv
│   ├── apb_sequence_item.sv
│   ├── apb_slave_model.sv
│   ├── bridge_scoreboard.sv
│   ├── env.sv
│   └── test.sv
│
├── images/
│   ├── block_diagram.png
│   ├── fsm_diagram.png
│   └── simulation_waveform.png
│
├── sim/
│   └── ...
│
├── README.md
├── LICENSE
└── .gitignore
```

---

# ⚙️ RTL Modules

### 1. `ahb_slave_if.v` — AHB Slave Interface

Receives transactions from the AHB master and captures the required information for the APB transfer.

- Detects valid AHB transactions
- Captures `HADDR`, `HWDATA`, `HWRITE`, `HSIZE`
- Generates `trans_valid`
- Internal registers: `addr_reg`, `data_reg`, `write_reg`, `size_reg`, `trans_valid`

### 2. `bridge_fsm.v` — Bridge Control FSM

Controls the AHB-to-APB transfer sequencing.

- States: `IDLE`, `SETUP`, `ENABLE`
- Generates `PSEL`, `PENABLE`, `HREADYOUT`
- Waits for `PREADY` and controls APB timing

### 3. `apb_master_if.v` — APB Master Interface

Drives the APB bus using the information captured from the AHB side.

```
addr_reg   -> PADDR
data_reg   -> PWDATA
write_reg  -> PWRITE
```

The APB control signals generated by the FSM are also forwarded to the APB interface.

### 4. `bridge_top.v` — Top-Level Integration

Integrates all bridge components and provides the APB read-data return path:

```
bridge_top
│
├── ahb_slave_if
├── bridge_fsm
└── apb_master_if

PRDATA -> HRDATA
```

---

# 🔄 Bridge FSM

The bridge uses a three-state finite state machine.

```
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
```

| State | PSEL | PENABLE | HREADYOUT | Description |
|---|---|---|---|---|
| IDLE | 0 | 0 | 1 | Waits for a valid AHB transaction |
| SETUP | 1 | 0 | – | Initiates the APB transfer |
| ENABLE | 1 | 1 | – | Transfer active; holds until `PREADY = 1` |

---

# 🔁 Data Flow

### Write Transaction

```
AHB Master → HADDR, HWDATA, HWRITE=1 → AHB Slave Interface
    → addr_reg, data_reg, write_reg → APB Master Interface
    → PADDR, PWDATA, PWRITE=1 → APB Peripheral
```

### Read Transaction

```
AHB Master → HADDR, HWRITE=0 → AHB Slave Interface
    → APB Master Interface → PADDR, PWRITE=0 → APB Peripheral
    → PRDATA → HRDATA → AHB Master
```

---

# 🧪 Verification Environment

The project includes a SystemVerilog/UVM-based verification environment to verify the bridge functionality at the transaction level. The UVM environment is organized around the AHB interface, while an APB slave model provides peripheral-side behavior.

```
Sequence → Sequencer → Driver → DUT
                                 │
                       ┌─────────┴─────────┐
                  AHB Monitor          APB Monitor
                       └─────────┬─────────┘
                             Scoreboard
```

### UVM Components

- `ahb_if.sv` — AHB interface, connects the testbench to the DUT's AHB signals
- `apb_if.sv` — APB interface, connects the testbench to the DUT's APB signals
- `ahb_sequence_item.sv` — AHB transaction object
- `apb_sequence_item.sv` — APB transaction object
- `ahb_sequence.sv` — Generates constrained-random AHB transactions
- `ahb_sequencer.sv` — Sends transactions to the AHB driver
- `ahb_driver.sv` — Converts transactions into AHB pin-level activity
- `ahb_monitor.sv` — Observes AHB transfers
- `apb_monitor.sv` — Observes APB transfers
- `apb_slave_model.sv` — Models APB slave responses
- `bridge_scoreboard.sv` — Compares AHB and APB transactions
- `ahb_agent.sv` — Contains the AHB sequencer, driver, and monitor
- `env.sv` — Integrates the verification components
- `test.sv` — Top-level UVM test that configures and runs the environment

### Verification Strategy

The testbench generates AHB read/write transactions and verifies the corresponding APB activity. The scoreboard checks:

- AHB address vs APB address
- AHB read/write control vs APB read/write control
- AHB write data vs APB write data
- APB read data vs AHB read data

---

# 📊 Verification Results

| Metric | Value |
|---|---:|
| Write transactions | 4 |
| Read transactions | 1 |
| UVM errors | 0 |
| UVM fatal errors | 0 |
| Scoreboard result | ✅ Match |

---

# 🛠️ Tools Used

| Tool | Purpose |
|---|---|
| Verilog HDL | RTL design |
| SystemVerilog / UVM | Functional verification |
| Simulator (QuestaSim / VCS / Xcelium) | Simulation & waveform generation |
| Waveform Viewer / GTKWave | Waveform debugging |
| Yosys / Design Compiler / Genus | Logic synthesis |
| Git & GitHub | Version control |

---

# ▶️ Simulation

```bash
# Compile RTL and UVM sources
vlog rtl/*.v uvm/*.sv tb/bridge_tb.v

# Run the simulation with UVM
vsim -c work.bridge_tb +UVM_TESTNAME=bridge_test -do "run -all"
```

> Adjust the exact compile/run commands to match the simulator available in your environment.

# ⚙️ Synthesis

```bash
# Example using Yosys
yosys -p "read_verilog rtl/*.v; synth -top bridge_top; write_verilog synth/bridge_top_synth.v"
```

> Adjust the target library and synthesis tool to match your specific flow.

---

# 📸 Results

## Block Diagram

![Block Diagram](images/block_diagram.png)

---

## FSM Diagram

![FSM Diagram](images/fsm_diagram.png)

---

## Simulation Waveform

![Simulation Waveform](images/simulation_waveform.png)

> Place your actual screenshots in the `images/` folder using these filenames (or update the paths above to match whatever you name them).

---

# 📋 Current Scope

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

# 🚀 Future Enhancements

- Add support for AHB burst transfers
- Implement multiple APB slave address decoding
- Propagate `PSLVERR` to `HRESP` for error handling
- Support full AHB pipelined address/data-phase operation
- Add functional coverage collection
- Add SystemVerilog Assertions (SVA) for protocol checking

---

# 📂 Repository

**GitHub Repository:**

https://github.com/999daksh/AHB-to-APB-Bridge

---

# 📚 References

- ARM AMBA AHB Protocol Specification
- ARM AMBA APB Protocol Specification
- IEEE 1800 SystemVerilog / UVM 1.2 User Guide

---

# 👨‍💻 Author

**Daksh Maheshwari**

B.Tech in Electronics & Communication Engineering
Birla Institute of Technology, Mesra

- GitHub: https://github.com/999daksh/AHB-to-APB-Bridge
- LinkedIn: https://www.linkedin.com/in/daksh-maheshwari-48612328a/

---

## ⭐ Support

If you found this project useful, consider giving it a **⭐ Star** on GitHub.
