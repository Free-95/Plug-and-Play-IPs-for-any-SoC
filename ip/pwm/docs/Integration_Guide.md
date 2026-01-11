# Integration Guide

## 1. RTL Instantiation
Add `pwm_ip.v` to your project source list. Instantiate the module in your top-level SoC wrapper (`riscv.v`) as follows:

```verilog
pwm_ip u_pwm (
    .clk(clk),
    .resetn(resetn),
    // Bus Interface
    .i_sel(pwm_select),       // Active HIGH Select Signal
    .i_we(mem_write_enable),  // Write Enable from CPU
    .i_addr(mem_addr[3:0]),   // Address Offset
    .i_wdata(mem_wdata),      // Write Data from CPU
    .o_rdata(pwm_rdata),      // Read Data to CPU
    // External Output
    .pwm_out(pwm_pad)         // Connect to IO Pad
);
```

## 2. Address Decoding
Generate the `pwm_select` signal based on your SoC's memory map.
* **Example Logic:**
	```verilog
	wire isIO = mem_addr[22];
	// Example Base: 0x800000
	wire pwm_select = isIO & (mem_addr[7:4] == 4'h8); 
	```

## 3. FPGA Constraints
Map the `pwm_out` port to a physical pin in your `.pcf` file.
* **Example (VSDSquadron):**
	```text
	set_io pwm_pad 46  # Example Pin
	```

