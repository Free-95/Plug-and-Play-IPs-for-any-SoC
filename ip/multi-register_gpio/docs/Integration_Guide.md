# Integration Guide

## 1. RTL Instantiation
Add `gpio_control_ip.v` to your project source list. Instantiate the module in your top-level SoC wrapper (e.g., `riscv.v`) as follows:

```verilog
gpio_control_ip u_gpio (
    .clk(clk),
    .resetn(resetn),
    .i_sel(gpio_select),      // Active HIGH Select Signal from Decoder
    .i_we(mem_write_enable),  // Write Enable from CPU
    .i_addr(mem_addr[3:0]),   // Address Offset (Lower 4 bits)
    .i_wdata(mem_wdata),      // Write Data from CPU
    .o_rdata(gpio_rdata),     // Read Data to CPU
    .gpio_pins(gpio_pins)     // Connect to Top-Level Inout Port
);
```

## 2. Address Decoding
You must generate the `gpio_select` signal based on your SoC's memory map.
* **Recommended Logic:** Map to Base Address `0x400000` for IO & Base Offset `0x00` for IP.
* **Verilog Snippet:**
    ```verilog
    wire isIO = mem_addr[22]; // Base Address: 0x400000
    wire gpio_select = isIO & (mem_addr[7:4] == 4'h0); // Base Offset: 0x00
    ```

## 3. FPGA Constraints (VSDSquadron)
Map the `gpio_pins` port to physical pins in your `.pcf` file.
* **Example Mapping:**
    ```text
    set_io gpio_pins[0] 38  # LED 0
    set_io gpio_pins[1] 43  # LED 1
    set_io gpio_pins[2] 45  # Button Input
    set_io gpio_pins[3] 47  # Header Pin
    ```

