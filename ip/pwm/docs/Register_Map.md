# PWM Register Map

**Base Address:** `0x400000` (User Defined)

| Offset | Name | Type | Reset | Description |
| :----: | :--: | :--: | :---: | :---------: |
| `0x00` | **CTRL** | R/W | `0x00` | Control Register (Enable & Polarity) |
| `0x04` | **PERIOD** | R/W | `0x01` | Period Register (Total Ticks) |
| `0x08` | **DUTY** | R/W | `0x00` | Duty Cycle Register (Active Ticks) |
| `0x0C` | **STATUS** | R | `0x00` | Status Register (Counter & Running) |

## Register Descriptions

### 1. CTRL (Offset `0x00`)
Controls the main operation of the PWM block.
* **Bit 0 (EN):** Enable PWM. `1` = Run, `0` = Stop (Output forced to inactive state).
* **Bit 1 (POL):** Polarity.
    * `0`: Active High (Default).
    * `1`: Active Low (Inverts output logic).
* **Bits [31:2]:** Reserved.

### 2. PERIOD (Offset `0x04`)
Defines the frequency of the PWM signal.
* **Bits [31:0]:** Number of clock cycles for one full PWM period.
* *Note:* `Frequency = System_Clock / Register_Value`.

### 3. DUTY (Offset `0x08`)
Defines the pulse width.
* **Bits [31:0]:** Number of clock cycles the signal remains active.
* *Note:* Ensure `DUTY <= PERIOD`.

### 4. STATUS (Offset `0x0C`)
Read-only status for debugging.
* **Bit 0:** Run Status (Mirror of CTRL Enable bit).
* **Bits [31:16]:** Current internal 16-bit counter value (Lower bits of 32-bit counter).
