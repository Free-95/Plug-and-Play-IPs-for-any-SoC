# Example Usage

## 1. C Driver Macros
Include these definitions in your `io.h` or main file to interact with the IP.

```c
#include <stdint.h>

#define GPIO_BASE 0x400000
#define GPIO_DATA 0x00
#define GPIO_DIR  0x04
#define GPIO_READ 0x08

#define IO_WRITE(offset, val) (*(volatile uint32_t*)(GPIO_BASE + (offset)) = (val))
#define IO_READ(offset)       (*(volatile uint32_t*)(GPIO_BASE + (offset)))
```

## 2. Basic Blink Example (Output)
Configures all 4 pins as outputs and toggles them.

```c
void main() {
    // 1. Set all 4 pins to OUTPUT mode (Binary 1111)
    IO_WRITE(GPIO_DIR, 0xF); 

    int counter = 0;
    while(1) {
        // 2. Write counter value to LEDs
        IO_WRITE(GPIO_DATA, counter & 0xF); 
        
        counter++;
        
        // Simple delay
        for(volatile int i=0; i<100000; i++); 
    }
}
```

## 3. Reading Inputs
Configures Pin 0 as Input and Pin 1 as Output. Pin 1 mirrors the state of Pin 0.

```c
void main() {
    // Pin 0 = Input (0), Pin 1 = Output (1) -> Binary 0010 (0x2)
    IO_WRITE(GPIO_DIR, 0x2);

    while(1) {
        // Read Status
        uint32_t status = IO_READ(GPIO_READ);

        // Check Bit 0
        if (status & 0x1) {
            IO_WRITE(GPIO_DATA, 0x2); // Turn ON Pin 1
        } else {
            IO_WRITE(GPIO_DATA, 0x0); // Turn OFF Pin 1
        }
    }
}
```

