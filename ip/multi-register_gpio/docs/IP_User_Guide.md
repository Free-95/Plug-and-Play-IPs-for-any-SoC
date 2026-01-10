# GPIO Control IP User Guide

## 1. Overview

### Purpose
The GPIO (General Purpose Input/Output) Control IP is a 4-channel, memory-mapped peripheral designed to integrate with a processor core. It serves as a bridge between the software running on the CPU and the physical pads of an FPGA, allowing digital signals to be driven out or read in.

### Why use this IP?
You should use this IP when your system needs to interact with simple external hardware that does not require a complex communication protocol. It provides the most fundamental method for the processor to affect the physical world.

### Typical Use Cases
* **Status Indication:** Driving LEDs to show system heartbeat or error states.
* **User Input:** Reading the state of physical push-buttons or dip-switches.
* **Control Signals:** Sending enable/reset signals to other external ICs (e.g., resetting a sensor).


## 2. Feature Summary

### Key Features
* **Bit Widths:** 4-bit bidirectional port (4 independent channels).
* **Supported Modes:**
    * **Output:** Push-Pull driver (Logic High/Low).
    * **Input:** High-Impedance (Hi-Z) for reading external signals.
* **Interface:** 32-bit Memory-Mapped (APB-style) bus interface.

### Clock Assumptions
* **Domain:** Fully synchronous to the system bus clock (`clk`).
* **Frequency:** Tested up to 12 MHz (standard VSDSquadron operation), capable of higher frequencies depending on synthesis results.

### Limitations
* **No Interrupt Support:** The IP does not generate interrupts; software must poll the `GPIO_READ` register to detect input changes.
* **No Hardware Debouncing:** Input signals are read directly; noisy switches must be debounced in software or with external capacitors.
* **Fixed Width:** The IP is hardcoded to 4 pins (not parameterized).
* **No Internal Pull-ups:** Internal pull-up/pull-down resistors must be configured via the FPGA Constraints File (.pcf), not through software registers.


## 3. Block Diagram

```text
       +---------------------------------------+
       |           GPIO Control IP             |
       |                                       |
       |   +--------------+    +-----------+   |
======>|   |  Register    |    | Tristate  |   |
CPU    |   |    File      |===>|  Buffers  |<==> gpio_pins[3:0]
Bus    |   +--------------+    +-----------+   |
======>|          |                  ^         |
       |          v                  |         |
       |     [Read Logic]-------------         |
       +---------------------------------------+
```
