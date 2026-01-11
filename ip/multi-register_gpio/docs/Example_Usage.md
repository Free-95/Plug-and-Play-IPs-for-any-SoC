# Example Usage
Here, we'll integrate the IP within a RISC-V SoC module present in the directory `basicRISCV/rtl`.

## 1. C Driver Macros
Include these definitions in your `io.h` or main file to interact with the IP.

Here, `io.h` is present in `basicRISCV/software/common`.

```c
#include <stdint.h>

#define IO_BASE    0x400000
#define GPIO_DATA  0x00
#define GPIO_DIR   0x04
#define GPIO_READ  0x08

// Access Macros
#define IO_IN(offset)     (*(volatile uint32_t*)(IO_BASE + (offset)))
#define IO_OUT(offset,val) (*(volatile uint32_t*)(IO_BASE + (offset)) = (val))
```

## 2. Example Program
A program to display multiples of a specified positive integer.

```c
// --- Program to display multiples of a specified positive integer ---
#include <stdint.h>
#include "../../../basicRISCV/software/common/io.h"
#define NUM 3 // Specified integer

// Function to transmit message through UART
void print_uart(const char *str) {
    while (*str) {
        while (IO_IN(UART_CNTL));
        IO_OUT(UART_DATA, *str++);
    }
}

// Simple delay function
void delay(int cycles) {
    volatile int i;
    for (i = 0; i < cycles; i++);
}

// Counter increment function
void inc(int* counter) {
    (*counter)++;
    if (*counter > 15) *counter = 0;
}

void main() {
    delay(5000000);
    print_uart("\n--- Multi-Register GPIO IP Test ---\n");
    print_uart("\nGuess the integer whose multiples are being displayed in binary below:\n");

    int counter = 0;
    while (1) {
        // Configure pin directions (1 - Output, 0 - Input)
        if ((counter % NUM) == 0) {
            IO_OUT(GPIO_DIR, 0xF); // 1111
        } else {
            IO_OUT(GPIO_DIR, 0x0); // 0000
            inc(&counter);
            continue;
        }

        // Write data to register
        IO_OUT(GPIO_DATA, counter & 0xF);

        // Read back from register
        uint32_t read_val = IO_IN(GPIO_READ);

        // Send status through UART
        if (read_val & 0x8) print_uart("1"); else print_uart("0");
        if (read_val & 0x4) print_uart("1"); else print_uart("0");
        if (read_val & 0x2) print_uart("1"); else print_uart("0");
        if (read_val & 0x1) print_uart("1\n"); else print_uart("0\n");

        // Increment counter
        inc(&counter);

        delay(500000); // Delay for visual blink
    }
}
```

**Path**: `ip/multi-register_gpio/software`

## 3. RTL Simulation

1. [Optional] Comment out the delay function calls in software application `gpio_test.c` to speed up the simulation.
2. Convert it to a `.hex` file.
	```bash
    cd ./basicRISCV/software
    cp ../../ip/multi-register_gpio/software/gpio_test.c .
 	make gpio_test.bram.hex
 	```
3. Simulate the SoC.
   	```bash
    cd ../RTL
    iverilog -D BENCH -o gpio_test tb.v riscv.v sim_cells.v 
    vvp gpio_test
    ```

    **Expected Output:**
    <img width="927" height="374" alt="gpio_output" src="https://github.com/user-attachments/assets/07030407-b259-4da3-9706-ed4b70d1c6db" />


4. Observe the waveform.
   ```bash
   gtkwave test.vcd
   ```

   <img width="1592" height="190" alt="gpio_waveform" src="https://github.com/user-attachments/assets/07d9f069-71f3-40c0-be21-dabe1b7a98e9" />


## 4. Hardware Validation

1. Uncomment the delay function calls in software application `gpio_test.c` if you commented them out during simulation and rewrite the `gpio_test.bram.hex` file. This delay facilitates visible changes over the hardware.
2. Perform the Synthesis & Flash through `Yosys (Synth) → Nextpnr (Place & Route) → Icepack (Bitstream)`. The commands for which are written in the `Makefile` in `basicRISCV/rtl` directory.
   ```bash
   make build
   make flash
   ```
3. Make the physical connections and observe the output.
4. Observe the output received through UART on console.
   ```bash
   make terminal
   ```
