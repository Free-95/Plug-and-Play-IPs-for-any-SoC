# Example Usage
Here, we'll integrate the IP within a RISC-V SoC module present in the directory `basicRISCV/rtl`.

## 1. C Driver Macros
Include these definitions in your `io.h` or main file to interact with the IP.

Here, `io.h` is present in `basicRISCV/software/common`.

```c
#include <stdint.h>

#define IO_BASE      0x400000 // IO Base Address

// PWM  Offsets
#define PWM_CTRL     0x20
#define PWM_PERIOD   0x24
#define PWM_DUTY     0x28
#define PWM_STATUS   0x2C

// Access Macros
#define IO_IN(offset)     (*(volatile uint32_t*)(IO_BASE + (offset)))
#define IO_OUT(offset,val) (*(volatile uint32_t*)(IO_BASE + (offset)) = (val))
```

## 2. Breathing LED Example
This code configures the PWM for a 1kHz signal (assuming 1MHz clock) and smoothly fades the LED on and off. Also demonstrates polarity inversion.

```c
#include "../../../basicRISCV/software/common/io.h"
#include "../../../basicRISCV/software/common/uart.h" // Custom UART Header File

// Delay function
void delay(int cycles) {
    for (volatile int i = 0; i < cycles; i++);
}

void main() {
    uprint("\n\t\t\t\t--- PWM IP Test ---\n");    

    // Configure PWM
    int polarity = 0;                          // Polarity = 0 (Active HIGH)
    const char *mode = (polarity == 1) ? "Active LOW" : "Active HIGH";
    IO_OUT(PWM_PERIOD, 1000);                  // Set Period to 1000 ticks
    IO_OUT(PWM_CTRL, polarity * 2 + 1);        // Enable = 1 
    uprint("\nConfiguring PWM: Period=%d, Mode=%s\n", 1000, mode);

    uint32_t status = IO_IN(PWM_STATUS);
    uprint("PWM Enabled. Current Status: 0x%x\n", status);

    // Breathe LED effect
    int duty = 0;
    int direction = 1;
    int count = 0;

    jump:
    while (count < 3) { // Breathe 3 times 
        // Update Duty Cycle
        IO_OUT(PWM_DUTY, duty);
        delay(10000); // Wait a bit so changes are visible

        if (direction) {
            duty += 10;
            if (duty >= 1000) direction = 0;
        } else {
            duty -= 10;
            if (duty <= 0) { direction = 1; count++; }
        }
    }
    
    // Disable PWM
    IO_OUT(PWM_CTRL, 0);
    status = IO_IN(PWM_STATUS);
    uprint("\nPWM Disabled. Current Status: 0x%x\n", status);
    delay(500000); // Wait for few seconds to observe disability

    // Invert the polarity
    count = 0;
    polarity = (polarity + 1) % 2;
    mode = (polarity == 1) ? "Active LOW" : "Active HIGH";
    IO_OUT(PWM_CTRL, polarity * 2 + 1);
    status = IO_IN(PWM_STATUS);
    uprint("\nPolarity Inverted. Current Status: 0x%x. Mode=%s\n", status, mode);

    goto jump;    // Repeat the same process  
}
```

**Path**: `ip/pwm/software`

## 3. RTL Simulation

1. Reduce the delay in software application `pwm_test.c` to speed up the simulation.
2. Convert `pwm_test.c` to a `.hex` file.
	```bash
    cd ./basicRISCV/software
    cp ../../ip/pwm/software/pwm_test.c .
 	make pwm_test.bram.hex
 	```
3. Simulate the SoC.
   	```bash
    cd ../RTL
    iverilog -D BENCH -o pwm_test tb.v riscv.v sim_cells.v 
    vvp pwm_test
    ```

    **Expected Output:**
   	<img width="974" height="360" alt="pwm_output" src="https://github.com/user-attachments/assets/77096d91-a8d0-4cf7-b1ea-2b39b5571999" />

4. Observe the waveform.
   ```bash
   gtkwave test.vcd
   ```

   <img width="1582" height="191" alt="pwm_waveform" src="https://github.com/user-attachments/assets/8fafaa1e-b362-4f69-8972-17335cce0dfc" />


## 4. Hardware Validation

1. Turn back delay in software application `pwm_test.c` to original values and rewrite the `pwm_test.bram.hex` file. This delay facilitates visible changes over the hardware.
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
