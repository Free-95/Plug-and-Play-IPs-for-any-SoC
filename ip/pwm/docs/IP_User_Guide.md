# PWM IP User Guide

## 1. Overview

### Purpose
The PWM (Pulse Width Modulation) IP is a single-channel, memory-mapped peripheral designed for a VSDSquadron SoC. It serves as a timing generator that produces a square wave with variable frequency and duty cycle, suitable for controlling motors, LEDs, or generating audio tones.

### Why use this IP?
You should use this IP when you need precise, hardware-timed signals without burdening the CPU. Unlike software-based loops, this IP runs independently once configured, allowing the processor to perform other tasks while the signal is generated.

### Typical Use Cases
* **LED Dimming:** Varying the brightness of an LED by changing the duty cycle (e.g., "Breathing" LED effect).
* **Motor Control:** Controlling the speed of a DC motor.
* **Audio Generation:** Generating simple square-wave tones (beeps) by adjusting the period (frequency).


## 2. Feature Summary

### Key Features
* **Configurable Period:** 32-bit register defines the total signal frequency.
* **Configurable Duty Cycle:** 32-bit register defines the "Active" pulse width.
* **Polarity Control:** Supports both Active High (standard) and Active Low (inverted) output logic.
* **Interface:** 32-bit Memory-Mapped (APB-style) bus interface.

### Clock Assumptions
* **Domain:** Fully synchronous to the system bus clock (`clk`).
* **Frequency:** The output frequency is a direct division of the system clock.
* *Formula:* `Output_Freq = System_Clock_Freq / PERIOD_Reg_Value`

### Limitations
* **Single Channel:** This IP controls only one physical output pin.
* **Counter Reset on Update:** If the `PERIOD` is updated to a value smaller than the current internal counter, the counter resets to 0 immediately to prevent undefined behavior.
* **No Prescaler:** The counter always runs at the system clock rate, so very low frequencies may require large period values.


## 3. Block Diagram

```text
       +---------------------------------------------------------------------------+
       |                                Top-level SoC                              |
       |                                                                           |
       |                                +--------------------------------------+   |
       |                                |                PWM IP                |   |
       |                                |                                      |   |
       |      +---------------------+   |   +------------------------------+   |   |
       |      |    Write Decoder    |-->|==>|       Config Registers       |   |   |
CPU    |      |   (i_sel && i_we)   |   |   |     (CTRL, PERIOD, DUTY)     |   |   |
BUS    |      +----------+----------+   |   +--------------+---------------+   |   |
======>|                 |              |                  |                   |   |
i_wdata|                 |              |                  v                   |   |
i_addr |                 |              |   +------------------------------+   |   |
i_we   |                 +------------->|==>|        PWM Core Logic        |   |   |
i_sel  |                                |   |    (Counter & Comparator)    |   |   |
       |                                |   +--------------+---------------+   |   |
       |                                |                  |                   |   |
       |                                |                  v                   |   |
       |      +---------------------+   |   +------------------------------+   |   |
<======|<-----|   Read Multiplexer  |<--|<==|      Output Driver Logic     |==>|-->|==> pwm_out
o_rdata|      |   (Selects Source)  |   |   |  (Applies Enable & Polarity) |   |   |
       |      +----------+----------+   |   +------------------------------+   |   |
       |                                +--------------------------------------+   |
       |                                                                           |
       |                                                                           |
       +---------------------------------------------------------------------------+
```


## 4. Software Programming Model

### How Software Controls the IP
The PWM IP operates as a hardware accelerator. Instead of the CPU manually toggling a pin, which consumes significant processing power, the software delegates this task to the IP.
* **Memory-Mapped Interface:** The CPU interacts with the PWM block by writing to specific memory addresses. It treats the IP settings just like standard variables in memory.
* **Configuration Flow:** The software first defines the waveform shape by writing integer values for the Frequency (Period) and Pulse Width (Duty Cycle).
* **Autonomous Operation:** Once configured, the software sends a simple "Enable" command. The IP then takes over, running its internal counters and driving the physical output pin independently. This frees the CPU to perform other tasks while the signal is generated.
* **Dynamic Control:** The software can update the Duty Cycle on-the-fly (e.g., to dim an LED) without needing to stop or reset the IP.

### Typical Initialization Sequence
To generate a clean signal without glitches, follow this sequence:
1. **Define Base Address:** Ensure your pointer matches the hardware base address (e.g., `0x400000`).
2. **Disable IP:** Write `0x0` to `PWM_CTRL` to ensure the block is stopped during setup.
3. **Set Period:** Write the desired total cycle count to `PWM_PERIOD` (e.g., `1000` for a 1kHz signal on a 1MHz clock).
4. **Set Duty Cycle:** Write the active time count to `PWM_DUTY` (e.g., `500` for 50% duty cycle).
5. **Enable IP:** Write `0x1` (Enable) or `0x3` (Enable + Inverted Polarity) to `PWM_CTRL` to start output generation.

### Polling vs. Status Checking
* **Status Checking:** Software can read the `PWM_STATUS` register to verify if the IP is currently enabled (Bit 0) or to read the live counter value (Bits [15:0]) for debugging.
* **No Polling Required:** Once enabled, the PWM IP runs autonomously. The software does not need to poll any register to keep the signal generating; it only needs to write new values if it wants to change the frequency or duty cycle dynamically.
