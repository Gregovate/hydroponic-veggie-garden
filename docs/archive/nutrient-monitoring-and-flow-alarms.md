
# 🌱 Nutrient Monitoring and Flow Alarms

**Last Updated:** 2025-07-15  
**System Module:** Hydroponics Patio Controller  
**Board:** Wemos D1 Mini (ESP8266)  
**ESPHome Version:** 2025.5.2 or newer  
**Home Assistant Integration:** Yes

---

## 🔍 Purpose

This module tracks real-time water and nutrient flow in the hydroponics system and raises alarms for abnormal conditions. It ensures proper nutrient distribution, detects system faults (like leaks or clogs), and monitors total nutrient usage over time. Designed for reliability and early intervention.

---

## 🧠 Logic Summary

### **Normal Operation**
- East and West flow sensors monitor parallel nutrient outputs.
- Tank weight is monitored via a 4-load-cell HX711 scale.
- A target minimum flow rate of **3 L/min** is required to ensure proper system distribution.
- Nutrient dosing is triggered based on fresh water input and tank conditions.

### **Alarm Conditions**
1. **Flow = 0** on either line:
   - Indicates a **pump failure**, airlock, or clogged line.
2. **Weight dropping, flow normal:**
   - Indicates **downstream leak** or return blockage.
3. **Weight dropping, flow = 0:**
   - Indicates **upstream leak** (e.g., cracked pipe or solenoid stuck).
4. **Weight increasing, flow normal:**
   - May indicate **rain event**, which dilutes nutrients and may require redosing.

---

## 💧 Flow Sensors

| Name        | ESP Pin | Home Assistant Entity ID             |
|-------------|---------|--------------------------------------|
| East Line   | D6      | `sensor.hydroponics_patio_flow_east` |
| West Line   | D7      | `sensor.hydroponics_patio_flow_west` |

Flow rates are reported in L/min using `pulse_counter` sensors.

---

## ⚖️ Tank Weight Sensor

- Load Cell System: HX711 with 4 sensors
- Raw Reading: `sensor.hydroponics_patio_raw_hx711_reading`
- Tared Gallons: `sensor.outside_tank_gallons`

This sensor is used for trend detection and triggering nutrient refills or alarms.

---

## 🧪 Nutrient Usage Tracking

Two resettable sensors track how much nutrient solution has been dispensed:

| Nutrient     | Home Assistant Sensor                |
|--------------|--------------------------------------|
| Part A Total | `sensor.nutrient_part_a_total`       |
| Part B Total | `sensor.nutrient_part_b_total`       |

Resettable via buttons on the **Hydroponic Control Panel**.

---

## ⚠️ Automation & Alarms

### Required Automations
- Flow too low (either line < 3 L/min)
- Flow zero with tank weight dropping
- Flow present but tank weight rising unexpectedly
- Nutrient tanks low (optional future)
- Notification via Home Assistant (mobile + persistent)

---

## 📅 Future Enhancements
- Third flow sensor before solenoid to detect rain fill or source leaks.
- Add magnetic stirrers (12V motor + relay) to Part A and Part B tanks.
- Visual trend graphs of flow vs. weight in Home Assistant.
- Delay-triggered alarms (e.g., 10 seconds of no flow before alarm).
