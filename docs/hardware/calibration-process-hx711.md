# 🧪 Calibration Process: Why Use a Template Sensor

This hydroponics system uses a weight-based method to monitor tank volume via a 4-load-cell platform and HX711 amplifier. While ESPHome supports inline sensor filtering and basic calculations, **precise tank calibration requires greater flexibility** than is practical inside a microcontroller’s firmware.

---

## 🚫 Problem with On-Device Calibration

Originally, calibration was performed directly in ESPHome using a formula like:

```yaml
float gallons = (raw + offset) * scale_factor;
```

However, this approach has two major drawbacks:

1. **Reflashing Required:**  
   Any adjustment to calibration constants (offset or slope) required editing the YAML and reflashing the device — inconvenient for outdoor equipment or remote management.

2. **Limited Flexibility for Multi-Point Calibration:**  
   The true tank behavior is not always linear. A single scale factor is often insufficient, especially near the bottom of the tank where measurement accuracy is most important.

---

## ✅ Why Template Sensor Calibration in Home Assistant

Instead of embedding gallon calculations in ESPHome, we send the raw HX711 value to Home Assistant and use a **template sensor** there.

### Benefits:

- 🔁 **No Reflashing Needed** — Calibration points can be updated from the Home Assistant UI  
- 🔢 **Multi-Point Curve Support** — Uses 6 calibration points from 0 to 25 gallons  
- 📉 **Dynamic Interpolation** — Calculates gallons using linear interpolation between known values  
- 🚨 **Safe Error Handling** — Skips calibration pairs where `raw == 0` to avoid false output

---

## 🪣 Emergency Calibration Procedure (5-Gallon Bucket)

To simplify field recalibration:
- A **5-gallon bucket** is used to fill the tank in increments
- At each 5-gallon mark, the current raw HX711 value is saved into a corresponding `input_number`
- These values are used by the Home Assistant template sensor for interpolation

> This process can be repeated **at any time** with no firmware changes.

---

## 🧾 Summary of Benefits

| Feature                       | ESPHome Inline Logic | Home Assistant Template |
|------------------------------|----------------------|--------------------------|
| Change without reflashing    | ❌                   | ✅                       |
| Support multiple calibration points | ❌           | ✅                       |
| Recalibrate remotely         | ❌                   | ✅                       |
| UI-based fine-tuning         | ❌                   | ✅                       |

---
