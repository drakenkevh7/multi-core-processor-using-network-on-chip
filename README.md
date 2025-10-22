# Multi-Core Processor using Network-on-Chip (NoC)

A modular, synthesizable Verilog project that builds a tiled multi-core system interconnected by a packet-switched Network-on-Chip. The codebase includes routers, arbiters, buffering/control logic, and self-checking testbenches, with a Cadence Xcelium/Incisive–friendly build flow via `make`.

> Status: work-in-progress; tests and topologies will evolve as modules are refined.

---

## ✨ Key Features

- **Modular NoC Router** with per-output arbitration (round-robin) and back-pressure (ready/valid).
- **Tiled system**: processing elements (PEs/cores) attach via simple link interfaces.
- **Configurable data width** (default 64-bit flits) and parameters via shared includes.
- **Self-checking testbenches** for regression and debug.
- **Cadence-friendly project layout** (SimVision waveform databases, `cds.lib`, `hdl.var`) with a Makefile flow.

---

## 🗂️ Repository Structure
