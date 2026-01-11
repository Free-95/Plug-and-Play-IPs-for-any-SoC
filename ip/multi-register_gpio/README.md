# GPIO Control IP

## What is this IP?
This is a 4-channel, memory-mapped GPIO controller designed for VSDSquadron FPGA and RISC-V SoCs.
* **Function:** Drive digital outputs (LEDs) or read digital inputs (Buttons).
* **Interface:** Standard 32-bit APB-style bus.
* **Key Feature:** Simple direct register access (Data, Direction, Read).

## How to Integrate
1. **Add Source:** Include `rtl/gpio_control_ip.v` in your project.
2. **Instantiate:** Connect it to your SoC wrapper.
	```verilog
	gpio_control_ip u_gpio (
	    .clk(clk),
	    .resetn(resetn),
	    .i_sel(gpio_select),  // Chip Select
	    .i_we(we),            // Write Enable
	    .i_addr(addr[3:0]),   // Address
	    .i_wdata(wdata),      // Write Data
	    .o_rdata(rdata),      // Read Data
	    .gpio_pins(gpio_pins) // Inout Ports
	);
	```
3. **Map Address:** Recommended Base Address is `0x400000`.

## Documentation
Detailed guides are located in the `docs/` folder:
* [**User Guide**](docs/IP_User_Guide.md) – Overview, block diagram, and specs.
* [**Integration Guide**](docs/Integration_Guide.md) – Step-by-step RTL setup and `.pcf` constraints.
* [**Register Map**](docs/Register_Map.md) – Address offsets and bit definitions.
* [**Example Usage**](docs/Example_Usage.md) – C driver code snippets.

## How to Test
A reference C application is provided in `software/gpio_test.c`.
* **What it does:** It blinks the LEDs (GPIO pins) in a pattern representing multiples of "3" and prints the binary status to UART.
* **Expected Output:**
	* **UART:** Messages from software application `gpio_test.c`.
	* **LEDs:** Toggling pattern on the connected pins.
* **Run it:** Compile `gpio_test.c` using your standard RISC-V toolchain and load the hex file into the SoC memory.

