# Plug-and-Play IPs for any SoC

Welcome to the **Plug-and-Play IPs** repository. This project focuses on designing, verifying, and implementing modular hardware Intellectual Property (IP) blocks suitable for integration into VSDSquadron FPGA-based SoCs.

The goal is to create peripherals that use standard memory-mapped interfaces, allowing for easy expansion of SoC capabilities on platforms like the VSDSquadron FPGA.

## Repository Structure
* **`ip/`**: Contains the source code, documentation, and drivers for the standalone IP blocks.
* **`basicRISCV/`**: Contains the reference SoC implementation (RTL), firmware drivers, and simulation environment used to test the IPs.


## Getting Started
Below is a list of the custom peripheral IPs developed in this repository. Click on the IP Name to view its detailed documentation, register map, and integration guide.

| IP Name | Description | Key Features |
| :-----: | :---------: | :------------|
| [**PWM IP**](ip/pwm/README.md) | Pulse Width Modulation Controller | <ul><li>Variable Duty Cycle</li> <li>Active High/Low Polarity control</li> <li>Ideal for LED dimming or Servo control</li></ul> |
| [**GPIO Control IP**](ip/multi-register_gpio/README.md) | General Purpose I/O Controller | <ul><li>4-Channel Input/Output</li> <li>Individual Data and Direction registers</li> <li>Standard APB-style interface</li></ul> |


## General Integration Flow
These IPs are designed to be "Plug-and-Play." The general workflow for integrating any IP from this repository into an SoC is as follows:

1. **Add Source:** Copy the IP's `.v` file from `ip/<ip_name>/rtl/` into your SoC's source directory.
2. **Instantiate:** Add the module instance to your top-level SoC wrapper (e.g., `riscv.v`), connecting it to the system clock, reset, and data bus.
3. **Address Mapping:** Assign a unique Base Address (e.g., `0x400000`) within the SoC's memory map to enable CPU communication.
4. **Constraints:** Update your physical constraint file (`.pcf`) to map the IP's external ports (like `pwm_out`) to physical FPGA pins.
5. **Firmware:** Use the provided C-driver headers to control the hardware from software.


## Simulation & Validation
IPs in this repository undergo a two-step verification process:

1. **RTL Simulation:**
* Tools: `iverilog` (Icarus Verilog) and `gtkwave`.
* Located in: `basicRISCV/rtl/`
* Verifies bus timing, register read/write operations, and logic behavior.

2. **Hardware Validation:**
* Platform: VSDSquadron FPGA (Lattice iCE40).
* Tools: `yosys`, `nextpnr`, `icepack`.
* Verifies real-world functionality using UART console output and physical peripherals.

______

*This project was developed as a part of the VSDSquadron FPGA Internship.*
