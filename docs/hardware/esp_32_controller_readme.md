# Hydroponics ESP32 Full Control System

This document describes the full-featured **ESP32-based hydroponics controller** as part of the Hydroponic Veggie Garden project. This version expands upon the D1 Mini monitoring build to add **automated control**, **ADC sensor support**, and **multiple operational modes** for complete system management.

---

## 🚀 Key Features

- **Three control modes** (Manual Fill, Auto Fill, Bypass)
- Dual **flow sensors** to verify flow integrity
- **HX711 load cell** for real-time tank weight monitoring
- **DS18B20** temperature sensor for water temperature
- **Optional pressure sensor** via ADC (3.3V range)
- **TDS/EC sensor support** via ESP32 analog input
- **Relay control** for:
  - Water fill solenoid
  - Nutrient dosing pump A
  - Nutrient dosing pump B
- Home Assistant integration via MQTT or native API

---

## 🧭 Modes of Operation

### 1. Manual Fill
- User-initiated tank refill
- Dosing logic based on measured refill volume
- Manual logging timestamps and quantities

### 2. Auto Fill
- Automatically triggers refill when tank level drops
- Initiates nutrient dosing cycle after fill
- Flow sensors and weight confirm successful execution

### 3. Bypass Mode
- All automated control disabled
- Useful for maintenance or troubleshooting

---

## 📐 Calibration Strategy

This version uses a **Home Assistant template sensor** to convert raw HX711 values into gallons. This method offers:

- **No need to reflash the microcontroller** when calibrating
- **6-point calibration system** stored in Home Assistant inputs
- Emergency backup calibration with a **5-gallon bucket**
- Offset tare value managed by a Home Assistant `input_number`

Template sensors and automation logic are documented in:
[home-assistant/patio-calibration.yaml](https://github.com/Gregovate/hydroponic-veggie-garden/blob/main/home-assistant/patio-calibration.yaml)

See detailed explanation: [docs/calibration-explained.md](https://github.com/Gregovate/hydroponic-veggie-garden/blob/main/docs/calibration-explained.md)

---

## 📎 ESPHome Configuration

The full working configuration for the ESP32 is stored at:
[esphome/hydroponics-patio-esp32.yaml](https://github.com/Gregovate/hydroponic-veggie-garden/blob/main/esphome/hydroponics-patio-esp32.yaml)

This includes:
- ADC logic for pressure and TDS sensors
- Switch and GPIO mapping
- Flow sensor calibration constants
- Dallas sensor address and pinout
- Web server, captive portal, and OTA support

---

## 📷 Image Assets
Visual reference images and wiring diagrams are in the
[docs/images](https://github.com/Gregovate/hydroponic-veggie-garden/tree/main/docs/images) folder.

---

## 📄 License

This project is provided under a custom personal-use license:

> "For non-commercial use only. All rights reserved."
>
> Engineering Innovations, LLC  
> Greg Liebig — https://engrinnovations.com

---

## 📚 Related Documents

- [README.md (D1 Mini version)](https://github.com/Gregovate/hydroponic-veggie-garden/blob/main/README.md)
- [Calibration Explained](https://github.com/Gregovate/hydroponic-veggie-garden/blob/main/docs/calibration-explained.md)
- [ESP32 Configuration YAML](https://github.com/Gregovate/hydroponic-veggie-garden/blob/main/esphome/hydroponics-patio-esp32.yaml)
- [Images and Diagrams](https://github.com/Gregovate/hydroponic-veggie-garden/tree/main/docs/images)

