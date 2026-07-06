# EC / TDS Calibration History

## Purpose

This document is the engineering notebook for calibration of the hydroponics
EC/TDS measurement system.

It records:

- Hardware changes
- Firmware changes affecting EC measurement
- Calibration equations
- Handheld EC reference measurements
- Probe voltage observations
- Temperature effects
- Calibration decisions
- Outstanding questions

Permanent design documents should reference this file rather than duplicate
its contents.

---

# Current ESPHome Calibration

## ADS1115 Configuration

```yaml
# TDS meter input via ADS1115 A0
- platform: ads1115
  ads1115_id: ads1115_outside
  multiplexer: 'A0_GND'
  gain: 4.096          # Updated 2026-07-27 from 2.048
  id: tds_raw
  name: "TDS Raw"
  update_interval: 2s
  accuracy_decimals: 3
  unit_of_measurement: "V"
```

## Current EC Estimation

```cpp
return 0.423 * v * v + 0.132 * v - 0.043;
```

Status:

⚠ Experimental

Purpose:

Dashboard estimate only.

The handheld EC meter remains the calibration standard.

---

# Hardware Changes

## 2026-07-03

### ADS1115 Supply Voltage

Changed ADS1115 VDD:

**5.0 V → 3.3 V**

### Reason

The ADS1115 was changed to operate from the same **3.3 V supply** as the ESP32.

This change was made to improve compatibility between the ADC and ESP32 logic levels and to eliminate the possibility of exposing the ESP32 to voltages above its recommended input range.

### Current Status

The change has **not yet been fully characterized**.

Current observations indicate:

- The TDS probe continues to respond correctly.
- The raw probe voltage changed as expected after the hardware modification.
- Additional handheld EC reference measurements are being collected to determine whether the EC estimation model requires recalibration.

### Open Items

- [ ] Verify the TDS probe output remains within the valid ADS1115 input range.
- [ ] Verify the probe output cannot exceed safe ESP32 voltage limits.
- [ ] Determine whether changing ADS1115 VDD affects the existing EC estimation model.

# Known Characteristics

## Temperature

Current observations indicate:

- Probe voltage changes with water temperature.
- Raw probe voltage is not currently a direct measure of nutrient concentration.
- Temperature compensation is still under investigation.

---

# Calibration Sessions

## 2026-07-04

### Purpose

Validate automatic fill behavior and collect additional EC calibration data.

### Reference Measurements

| Time | Event | Tank | Temp | Probe | Handheld EC |
|------|------|------:|------:|------:|------------:|
|09:10|Before Fill|11.7|73.1°F|1.799|1.70|
|12:59|After Auto Fill|20.6|70.3°F|1.752|1.60|
|13:37|Before Correction|20.6|71.9°F|1.774|1.70|
|14:17|After +50/+50|20.5|73.5°F|1.961|2.00|

### Observations

Automatic fill restored nutrients proportional to the water added.

A manual correction of:

- 50 mL Part A
- 50 mL Part B

returned the tank to:

- Handheld EC = 2.00
- Probe Voltage = 1.961 V

This establishes another calibration reference point.

No changes were made to the ESPHome EC equation.

---

# Open Questions

- Determine temperature compensation.
- Validate EC estimation equation.
- Continue collecting handheld reference data.
- Determine operating voltage range over seasonal temperature changes.