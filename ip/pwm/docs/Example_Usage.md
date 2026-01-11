# Example Usage

## 1. C Driver Macros
Include these definitions in your `io.h` to interact with the IP.

```c
#include <stdint.h>

#define PWM_BASE 0x800000 // Update with your actual base address
#define PWM_CTRL   0x00
#define PWM_PERIOD 0x04
#define PWM_DUTY   0x08
#define PWM_STATUS 0x0C

#define IO_WRITE(offset, val) (*(volatile uint32_t*)(PWM_BASE + (offset)) = (val))
#define IO_READ(offset)       (*(volatile uint32_t*)(PWM_BASE + (offset)))
```

## 2. Breathing LED Example
This code configures the PWM for a 1kHz signal (assuming 1MHz clock) and smoothly fades the LED on and off.

```c
void pwm_breathe() {
    // 1. Configure Period (1000 ticks)
    IO_WRITE(PWM_PERIOD, 1000);

    // 2. Enable PWM (Active High)
    // Bit 0 = 1 (Enable), Bit 1 = 0 (Polarity Normal)
    IO_WRITE(PWM_CTRL, 1);

    int duty = 0;
    int direction = 1;

    while(1) {
        // 3. Update Duty Cycle
        IO_WRITE(PWM_DUTY, duty);

        // Logic to fade in and out
        if (direction) {
            duty += 10;
            if (duty >= 1000) direction = 0;
        } else {
            duty -= 10;
            if (duty <= 0) direction = 1;
        }

        // Delay to make the effect visible
        for(volatile int i=0; i<5000; i++);
    }
}
```

## 3. Inverting Polarity
To switch to "Active Low" mode (e.g., for LEDs that turn on when the pin is pulled low):

```c
void set_active_low() {
    // Bit 0 = 1 (Enable)
    // Bit 1 = 1 (Active Low) -> 0x3
    IO_WRITE(PWM_CTRL, 3);
}
```

