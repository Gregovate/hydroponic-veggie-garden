# Hydroponics Patio Controller (Outside System)

📅 **Last Updated: 2025-07-16**

This project monitors and controls an outdoor hydroponics system using a Wemos D1 Mini (ESP8266) running ESPHome, integrated with Home Assistant. It includes weight-based tank volume monitoring, temperature sensing, flow sensors, and relay control for pumps and solenoids. The system was rebuilt in July 2025 following a sensor wiring issue.

---
[![ESPHome](https://img.shields.io/badge/ESPHome-2025.7.0-blue.svg)](https://esphome.io/)
[![Home Assistant](https://img.shields.io/badge/Home_Assistant-Compatible-brightgreen.svg)](https://www.home-assistant.io/)

---

## 📌 Overview

This project implements a 4-load-cell digital weighing platform using an HX711 amplifier, CAT5 breakout connectors, and ESPHome-based control logic. The system provides real-time water level readings in gallons for a hydroponics nutrient tank and integrates seamlessly with Home Assistant.

---

## 📦 Hardware Overview

### Microcontroller
- **Wemos D1 Mini (ESP8266)** – main controller works well with HX711 Load Cells
- **Optional Mini ESP32** - Alternate when using a pressure sensor for tank volume

### Load Cell Platform
- **4x 50kg Load Cells (Wishiot)**
- **1x HX711 ADC Module**
- Diagonal Wheatstone Bridge layout using:
  - Sensors numbered clockwise: 1 → 2 → 4 → 3
  - Diagonals:
    - Sensor 1 & 4 → A+
    - Sensor 2 & 3 → A-
- **HX711 Powered at 3.3V** for compatibility
- Load cells mounted on a wooden frame

---

## 🔌 RJ45 Wiring (Cat5 Breakout)

### HX711 Box RJ45 Wiring (Applies to both ends)

| Pin | Function                                |
|-----|-----------------------------------------|
| 1   | 3.3V (Red, DS18B20 VCC + 4.7kΩ pull-up) |
| 2   | GND (Black, DS18B20 GND)                |
| 3   | —                                       |
| 4   | HX711 DT (Blue)                         |
| 5   | —                                       |
| 6   | HX711 SCK (Green)                       |
| 7   | DS18B20 Signal (Yellow, w/ pull-up)     |
| 8   | —                                       |

---

## 🌡️ Sensors

- **HX711 Raw Scale**
  - Filtered using `sliding_window_moving_average`
  - Passed to HA for conversion to gallons
- **Outside Tank Gallons**
  - Template sensor using 6-point calibration curve
  - Skips calibration pairs where raw == 0
- **DS18B20 Temperature Sensor**
  - Mounted in HX711 box
- **DIGITEN Flow Sensors**
  - East: GPIO12 (D6), West: GPIO13 (D7)
  - Formula: `x * 0.002235` for LPM
- **RESTMO Inline Water Meter**
  - Manual calibration tool

---

## 💡 Relay Outputs

| Name                | GPIO | Behavior          |
|---------------------|------|-------------------|
| Water Fill Solenoid | D3   | Normal HIGH relay |
| Nutrient Pump A     | D8   | Active LOW relay  |
| Nutrient Pump B     | D0   | Normal HIGH relay |

---

## 🔧 ESPHome Configuration

This project supports both ESP8266 and ESP32:

- [hydroponics-d1mini.yaml](https://github.com/Gregovate/hydroponic-veggie-garden/blob/main/esphome/hydroponics-d1mini.yaml)
- [hydroponics-esp32mini.yaml](https://github.com/Gregovate/hydroponic-veggie-garden/blob/main/esphome/hydroponics-esp32mini.yaml)

These files are the authoritative source. Please do not rely on outdated YAML in the README.

## 🏠 Home Assistant Integration

All Home Assistant sensors, template logic, and calibration data live in:

- [home-assistant folder](https://github.com/Gregovate/hydroponic-veggie-garden/tree/main/home-assistant)

## ⚙️ Home Assistant Entities

- `sensor.hydroponics_patio_raw_hx711_sensor`
- `sensor.outside_tank_gallons`
- `sensor.outside_tank_temp`
- `sensor.outside_east_channel_flow`
- `sensor.outside_west_channel_flow`
- `input_number.raw_00_gallons` to `raw_25_gallons`
- `input_boolean.hydroponics_outside`

---

## 📐 Calibration

📖 [Learn more about the calibration process and why it's handled in Home Assistant](docs/calibration-process-hx711.md)

---

## 🔍 HX711 Testing Notes

- **Idle (no load)**: A+ − A− ≈ 0mV
- **With load**: Shift ~±0.4mV
- Red–Black ≈ 1kΩ
- Red–Signal or Black–Signal ≈ 2kΩ
- Signal voltage with load should change ±100–200mV

---

## 🌱 Future Enhancements

- Add auto-fill using solenoid valve
- Add 2x 12V peristaltic nutrient pumps
- Track cumulative nutrient use and refill threshold
- Add magnetic stirrer control before dosing
- Consider tank shape compensation at low volumes

---

## 🧾 Documentation Tasks

- [ ] Upload final KiCad schematic
- [ ] Finalize polarity test procedure
- [X] Document HA automation for calibration
