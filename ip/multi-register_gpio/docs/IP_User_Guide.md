# GPIO Control IP User Guide

## 1. Overview

### Purpose
The GPIO (General Purpose Input/Output) Control IP is a 4-channel, memory-mapped peripheral designed for a VSDSquadron SoC. It serves as a bridge between the software running on the CPU and the physical pads of an FPGA, allowing digital signals to be driven out or read in.

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
       +-----------------------------------------------------------------------+
       |                             GPIO CONTROL IP                           |
       |                                                                       |
       |      +---------------------+       +------------------------------+   |
       |      |    Write Decoder    |------>|  Direction Reg (GPIO_DIR)    |   |
 CPU   |      |   (i_sel && i_we)   |       |   (Sets Input vs Output)     |   |
 BUS   |      +----------+----------+       +--------------+---------------+   |
======>|                 |                                 | (Enable Control)  |
i_wdata|                 |                                 v                   |
i_addr |                 |                  +------------------------------+   |
i_we   |                 +----------------->|    Data Reg (GPIO_DATA)      |   |
i_sel  |                                    |   (Holds Value to Drive)     |   |
       |                                    +--------------+---------------+   |
       |                                                   | (Drive Value)     |
       |                                                   v                   |
       |      +---------------------+       +------------------------------+   |
<======|<-----|   Read Multiplexer  |<------|      Tri-State Logic         |<=>|<==> gpio_pins [3:0]
o_rdata|      |  (Selects Source)   |       | (Dir=1: Drive, Dir=0: Hi-Z)  |   |      
       |      +----------+----------+       +------------------------------+   |
       |                 ^                                 |                   |
       |                 |                                 |                   |
       |                 +---------------------------------+                   |
       |                          (Read Back Logic)                            |
       +-----------------------------------------------------------------------+
```


## 4. Software Programming Model

### How Software Controls the IP
The GPIO IP acts as a memory-mapped peripheral. The CPU controls the physical pins by reading and writing to specific 32-bit addresses allocated to the IP on the system bus.
* **Direction Control:** Software determines if a pin drives a signal or listens for one by writing to the Direction Register (`GPIO_DIR`).
* **Drive State:** When configured as an output, writing to the Data Register (`GPIO_DATA`) drives the pins High (1) or Low (0).
* **Read State:** Software reads the current voltage level of the external pins via the Read Register (`GPIO_READ`).

### Typical Initialization Sequence
To ensure safe operation and prevent electrical contention, the driver should follow this sequence:
1. **Define Base Address:** Ensure the software pointer matches the hardware base address (e.g., `0x400000`).
2. **Set Initial State:** If pins are outputs, write the safe default value (e.g., `0x0`) to `GPIO_DATA` before enabling the output driver.
3. **Configure Direction:** Write to `GPIO_DIR` to set specific pins as Input (0) or Output (1).
4. **Begin Operation:** The IP is now ready for active reading or writing.

### Polling vs. Status Checking
Since this IP does not support interrupts, the CPU must actively monitor the IP to detect changes on input pins.
* **Polling (Required):** The software must implement a loop that continuously reads the `GPIO_READ` register to check if an input signal has changed (e.g., a button press).
* **Status Checking:** Unlike complex IPs with "Done" or "Busy" flags, this IP is instantaneous. There is no status register to check for completion; writes take effect immediately on the next clock cycle.

