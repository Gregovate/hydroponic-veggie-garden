**Using a Submersible Liquid Level Pressure Sensor with ESPHome**

This guide explains how to replace an HX711 load cell system with a submersible hydrostatic pressure sensor (e.g., 1m range, 5m cable) for use with ESPHome on an ESP8266 (D1 Mini) or ESP32 Mini board.

---

## 1. Overview

Submersible liquid level sensors measure pressure at the bottom of a tank and convert it to voltage. This voltage is proportional to the liquid height. These sensors are ideal for large tanks where load cells are impractical.

---

## 2. Typical Sensor Wiring

Most submersible hydrostatic sensors have three wires:

| Wire Color | Function             |
| ---------- | -------------------- |
| Red        | VCC (typically 5V)   |
| Black      | GND                  |
| Yellow     | Analog Signal (0-5V) |

**Note:** Confirm your sensor's wiring and voltage range before connecting.

---

## 3. Using with D1 Mini (ESP8266)

### ⚠ Important:

- The ESP8266 analog pin (A0) only accepts **0–1.0V**.
- Most sensors output **0–5V**, so a voltage divider is required.

### Voltage Divider Example (5V to 1V):

Use two resistors:

- R1 = 20kΩ (connects sensor output to A0)
- R2 = 5kΩ (connects A0 to GND)

This reduces 5V to 1V at full scale:

```
Vout = Vin * (R2 / (R1 + R2)) = 5V * (5k / 25k) = 1V
```

### Wiring Table:

| Sensor Wire | Connects To                  |
| ----------- | ---------------------------- |
| Red         | 5V (D1 Mini VCC or external) |
| Black       | GND                          |
| Yellow      | Voltage divider → A0         |

---

## 4. Using with Mini ESP32

- The ESP32 supports **true 0–3.3V** analog readings on many ADC pins (e.g., GPIO34, GPIO35).
- No voltage divider is needed if the sensor outputs **≤3.3V**.
- If using a 5V output sensor, **a voltage divider is still required**.

### ESP32 Example Wiring (Sensor outputs 0–3.3V):

| Sensor Wire | Connects To             |
| ----------- | ----------------------- |
| Red         | 5V or 3.3V (check spec) |
| Black       | GND                     |
| Yellow      | GPIO34                  |

---

## 5. ESPHome Configuration

### For D1 Mini (A0):

```yaml
sensor:
  - platform: adc
    pin: A0
    name: "Tank Pressure (Raw)"
    update_interval: 10s
    filters:
      - calibrate_linear:
          - 0.10 -> 0    # Voltage at empty
          - 0.90 -> 40   # Voltage at full (in inches, cm, etc.)
    unit_of_measurement: "in"
    id: tank_level_sensor
```

### For ESP32 (GPIO34):

```yaml
sensor:
  - platform: adc
    pin: GPIO34
    name: "Tank Pressure (Raw)"
    update_interval: 10s
    attenuation: 11db  # Enables full 3.3V range
    filters:
      - calibrate_linear:
          - 0.1 -> 0
          - 2.5 -> 40
    unit_of_measurement: "in"
    id: tank_level_sensor
```

### Convert to Gallons (Template Sensor):

```yaml
  - platform: template
    name: "Tank Gallons"
    unit_of_measurement: "gal"
    lambda: |-
      return id(tank_level_sensor).state * 5.1;  // Replace with correct factor
    update_interval: 10s
```

---

## 6. Benefits and Limitations

### Benefits:

- No weight limitation (great for 200+ gallon tanks)
- Simple installation (drop-in sensor)
- Fewer moving parts

### Limitations:

- Requires analog input
- Must calibrate accurately
- Some sensors require 12V (check datasheet)

---

## 7. Summary

| Feature                | HX711 Load Cell      | Submersible Pressure Sensor  |
| ---------------------- | -------------------- | ---------------------------- |
| Measures               | Weight               | Water pressure (height)      |
| ESP Pin Type           | Digital (HX711)      | Analog (ADC)                 |
| Calibration Complexity | Moderate             | Easy with `calibrate_linear` |
| Best Use Case          | Small tanks, precise | Large tanks (e.g., 200 gal)  |

---

For tanks too large to be measured accurately with a platform scale, this hydrostatic solution offers a clean, scalable, and ESPHome-compatible option.

