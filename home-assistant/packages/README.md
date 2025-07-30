# Hydroponics Patio Package
**Author:** Greg  
**Last Updated:** 2025-07-29  

This Home Assistant package monitors and manages an outdoor hydroponics system. It includes:

## 🎯 Core Features
- **Tank Gallon Sensor**  
  Interpolates raw HX711 readings via 6 calibration points stored in `input_number`.

- **Filtered Gallons**  
  Removes jitter using `outlier` and `lowpass` filters to improve UI consistency and statistics.

- **Usage Monitoring**  
  Tracks 6-hour usage average and estimates time remaining before tank is empty.

- **Fill Cycle Tracking**  
  - Start/Stop times: `input_datetime.outside_tank_fill_started/stopped`
  - Duration: `sensor.outside_tank_last_fill_duration`
  - Volume: `input_number.outside_tank_last_fill_gallons`

- **Control Mode**  
  Selectable via `input_select.hydroponics_outside_control_mode` to toggle between:
    - Auto
    - Manual
    - ESP-Override

## 🧠 Dependencies
Ensure the following are defined:
- All `input_number.raw_XX_gallons` calibration points
- `sensor.hydroponics_patio_esp32_raw_hx711_sensor`

## 🧪 Optional Future Additions
- Log and notify on dosing events (like fill cycles)
- Track cumulative dose volumes
- Auto-trigger refill based on `Time to Empty`

## 📝 Notes
- Tank geometry and tare logic are managed in Home Assistant, not ESPHome.
- Works in conjunction with `hydroponics-patio-esp32.yaml`.

---

**Version:** 1.0  
**Location:** `/config/packages/hydroponics/package_hydroponics_patio.yaml`
