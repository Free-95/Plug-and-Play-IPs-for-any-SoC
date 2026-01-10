# GPIO IP Register Map

**Base Address:** User Configurable (Default in this repo: `0x400000`)
**Register Width:** 32-bit (Only lower 4 bits are active)

| Offset | Name       | R/W | Description                                      |
|:------:|:----------:|:---:|:-------------------------------------------------|
| `0x00` | GPIO_DATA  | R/W | Output Data Register.                            |
| `0x04` | GPIO_DIR   | R/W | Direction Control Register (1=Output, 0=Input).  |
| `0x08` | GPIO_READ  | R   | Read Pin Status (returns actual level on pin).   |

## Register Details

### 1. GPIO_DATA (Offset 0x00)
Stores the value to be driven to the pins when in Output Mode.
* **Bits [31:4]:** Reserved/Ignored.
* **Bits [3:0]:** Output value for Pins 3 to 0.

### 2. GPIO_DIR (Offset 0x04)
Controls the direction of the IO pads.
* **Bits [31:4]:** Reserved/Ignored.
* **Bits [3:0]:** Direction for Pins 3 to 0.
    * `1`: Output Mode (Drive pin).
    * `0`: Input Mode (High Impedance).

### 3. GPIO_READ (Offset 0x08)
Reads the live status of the physical pin, regardless of direction.
* **Bits [31:4]:** Always 0.
* **Bits [3:0]:** Current logic level present on Pins 3 to 0.
