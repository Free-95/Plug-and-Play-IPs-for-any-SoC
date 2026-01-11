# PWM IP

## What is this IP?
This is a Single-channel, memory-mapped Pulse Width Modulation (PWM) controller.
* **Function:** Generates a square wave with variable pulse width (Duty Cycle).
* **Interface:** Standard 32-bit APB-style bus.
* **Key Feature:** Supports "Active High" and "Active Low" polarity modes.

## How to Integrate
1. **Add Source:** Include `rtl/pwm_ip.v` in your project.
2. **Instantiate:** Connect it to your SoC wrapper.
	```verilog
	pwm_ip u_pwm (
	    .clk(clk),
	    .resetn(resetn),
	    .i_sel(pwm_select),   // Chip Select
	    .i_we(we),            // Write Enable
	    .i_addr(addr[3:0]),   // Address
	    .i_wdata(wdata),      // Write Data
	    .o_rdata(rdata),      // Read Data
	    .pwm_out(pwm_pin)     // External Output Pin
	);
	```
3. **Map Address:** Select a base address for Memory-Mapped IO. Recommended Base Address is `0x400000`.

## Documentation
Detailed guides are located in the `docs/` folder:
* [**User Guide**](docs/IP_User_Guide.md) – Overview, block diagram, and specs.
* [**Integration Guide**](docs/Integration_Guide.md) – Step-by-step RTL setup and `.pcf` constraints.
* [**Register Map**](docs/Register_Map.md) – Address offsets and bit definitions.
* [**Example Usage**](docs/Example_Usage.md) – C driver code snippets.

## How to Test
A reference C application is provided in `software/pwm_test.c`.
* **What it does:** Configures the PWM and performs a "breathing LED" effect.
* **Expected Output:**
	* **UART:** PWM and Polarity status messages from software application `pwm_test.c`.
	* **LED:** Exhibiting a "breathe" effect.

	<video src="[user-images.githubusercontent.com](https://github.com/user-attachments/assets/f9b64f7a-3eaf-49b2-b733-5c531b5b4225)" controls width="500">![Demo video](https://github.com/user-attachments/assets/f9b64f7a-3eaf-49b2-b733-5c531b5b4225)</video>

https://github.com/user-attachments/assets/f9b64f7a-3eaf-49b2-b733-5c531b5b4225


