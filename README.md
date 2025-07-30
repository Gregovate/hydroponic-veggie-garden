# Hydroponics Veggie Garden

An ESPHome + Home Assistant–based smart hydroponics system with two controller options:

---

## 🧠 1. Monitoring Controller (ESP8266 / D1 Mini)

Designed for lightweight monitoring:
- HX711 scale for tank level
- Dual DIGITEN flow sensors
- DS18B20 temperature probe
- Home Assistant integration for real-time data and alerts

📄 [Read the D1 Mini Monitoring Controller Overview](docs/d1mini_controller_readme.md)

---

## 🛠️ 2. Full Control Controller (ESP32 Mini)

Full-featured automation and dosing system:
- Load cell scale + optional pressure sensor
- Flow-based auto-fill system
- Dual peristaltic pumps for nutrients
- Multiple control modes (Auto, Manual, Override)
- Optional future TDS/EC monitoring

📄 [Read the ESP32 Full Control System Overview](docs/esp32_controller_readme.md)

---

## 📂 Repository Structure

| Folder            | Purpose                                     |
|-------------------|---------------------------------------------|
| `/esphome`        | ESPHome YAML files for both controllers     |
| `/home-assistant` | Home Assistant sensors, templates, automations |
| `/docs`           | Supporting documentation, images, calibration |
| `.gitignore`      | Prevents temporary and local config files from syncing |

---

## 🧪 Calibration Reference

Volume calibration is performed in Home Assistant using a 6-point interpolation table. For emergency recalibration, a 5-gallon bucket method is supported.

📘 [Learn about the HX711 calibration process](docs/calibration-process-hx711.md)

---

## 📜 License

This project is licensed for **non-commercial personal use** by:

**It Engineering Innovations, LLC — Greg Liebig**  
🔗 [https://engrinnovations.com](https://engrinnovations.com)
