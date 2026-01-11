# PWM IP User Guide

## 1. Overview
The PWM (Pulse Width Modulation) IP is a peripheral designed to generate precise timing pulses. It is commonly used for motor control, LED dimming, or generating audio tones.

### Key Features
* **Programmable Period:** Define the exact frequency of the signal.
* **Programmable Duty Cycle:** Define the "On" time vs "Off" time.
* **Polarity Control:** Switch between Active High and Active Low output logic.
* **Simple Interface:** 4 Memory-Mapped Registers.

## 2. Block Diagram

```text
       +---------------------------------------+
       |             PWM IP                    |
       |                                       |
       |   +--------------+    +-----------+   |
======>|   | Configuration|    |  Counter  |   |
CPU    |   |  Registers   |===>|     &     |===> pwm_out
Bus    |   +--------------+    | Comparator|   |
======>|          |            +-----------+   |
       |          v                            |
       |     [Read Logic]                      |
       +---------------------------------------+
```

## 3. Software Programming Model

**Initialization Sequence**
To prevent glitches on the output pin, follow this order:
1. **Disable PWM:** Write `0` to the **CTRL** register.
2. **Set Period:** Write the total cycle count (frequency) to **PERIOD**.
3. **Set Duty:** Write the active time count to **DUTY**.
4. **Enable:** Write `1` (plus desired Polarity bit) to **CTRL** to start.

**Output Logic**
* **Active High (Pol=0):** Output is `1` while Counter < Duty.
* **Active Low (Pol=1):** Output is `0` while Counter < Duty.

**Limitations**
* The `counter` resets to 0 immediately if the `PERIOD` register is updated to a value lower than the current counter value, which may cause a shortened cycle during reconfiguration.

