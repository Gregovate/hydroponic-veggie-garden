# Understanding the Voltage Divider

This guide explains how a voltage divider works, specifically in the context of safely reducing a 5V sensor signal to 3.3V (or lower) for an ESP32 or ESP8266 analog input.
![Voltage Divider](https://github.com/Gregovate/hydroponic-veggie-garden/raw/main/docs/images/voltage-divider.png)



---

## Purpose

Some analog sensors output a voltage in the range of 0–5V. However:

- The **ESP32** ADC input only tolerates up to **3.3V**
- The **ESP8266 (D1 Mini)** ADC pin (`A0`) tolerates only **0–1.0V**

Connecting a 5V signal directly to these analog inputs can **permanently damage the microcontroller**. A **voltage divider** solves this by scaling down the voltage using just two resistors.

---

## How It Works

A voltage divider is a simple circuit made from two resistors:

```
      Sensor Output (5V)
         |
        R2
         |
        +----> Vout (to analog input)
         |
        R1
         |
        GND
```

The formula for the output voltage is:

```
Vout = Vin * (R1 / (R1 + R2))
```

Where:

- **Vin** is the sensor voltage (e.g. 5V)
- **R1** is the resistor from the middle point to ground
- **R2** is the resistor from Vin to the middle point

---

## Example: Scaling 5V to \~3.3V

Let’s say the sensor outputs up to **5V**, and we want **Vout ≈ 3.3V**.

Choose:

- **R2 = 10kΩ** (top resistor)
- **R1 = 5.1kΩ** (bottom resistor)

Then:

```
Vout = 5 * (5.1 / (10 + 5.1)) ≈ 3.3V
```

This is perfect for safe use with the ESP32’s ADC.

---

## For ESP8266 (A0 Only Allows 1.0V)

If you're using a D1 Mini (ESP8266), you'll need **further voltage reduction**. Here’s one working pair:

- **R2 = 100kΩ**
- **R1 = 20kΩ**

Result:

```
Vout = 5 * (20 / 120) ≈ 0.83V (safe for A0)
```

---

## Notes

- Use precision resistors (±1% tolerance if available)
- Always connect sensor ground to the ESP ground
- You can use any resistor values as long as their **ratio** gives the correct output
- Keep resistor values reasonably high (to avoid unnecessary power draw)

---

## Summary

- A voltage divider is essential when using 5V analog sensors with 3.3V (or 1.0V) microcontrollers.
- Two resistors scale the signal safely to the desired range.
- The resistor values you choose depend on your target voltage and the microcontroller’s limits.

By wiring your voltage divider as shown above and selecting the correct resistor pair, you can safely read tank level data from a 5V sensor using ESPHome. Just be sure to check your voltages before connecting to your micro controller!


