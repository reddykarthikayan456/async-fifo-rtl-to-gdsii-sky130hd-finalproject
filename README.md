# Asynchronous FIFO RTL-to-GDSII — SKY130HD

## Overview
Asynchronous FIFO design implemented in Verilog, simulated with Icarus Verilog, and taken through physical design using OpenROAD Flow Scripts and the SKY130HD platform.

## Repository Contents
- rtl/: FIFO Verilog source
- testbench/: RTL testbench
- simulation/: simulation output and waveform
- sta/: selected timing reports
- reports/: physical-design and verification reports
- layout/: final GDSII and OpenDB files
- screenshots/: project screenshots

## Verified Timing Results

| Corner | Worst Setup Slack | Worst Hold Slack | Reported Status |
|---|---:|---:|---|
| TT, 0.25°C, 1.80 V | +7.08 ns | +0.35 ns | MET |
| FF, -40°C, 1.95 V | +7.80 ns | +0.22 ns | MET |

These results are from the available timing reports and apply only to the listed corners and checks. They do not establish that all corners pass.

## Tools
- Verilog HDL and Icarus Verilog
- GTKWave
- OpenROAD Flow Scripts (ORFS)
- SKY130HD platform
- Ubuntu Linux

## Simulation
From the repository root, run:

```bash
iverilog -o /tmp/async_fifo_sim rtl/async_fifo.v testbench/tb_async_fifo.v
vvp /tmp/async_fifo_sim
```

Open the saved waveform, if available, with `gtkwave simulation/async_fifo.vcd`.

## Physical Design
The `layout/` directory contains the final GDSII and OpenDB deliverables. Selected routing and verification evidence is in `reports/`.

## Scope
This repository publishes selected project deliverables and verified results, not the complete OpenROAD installation.
