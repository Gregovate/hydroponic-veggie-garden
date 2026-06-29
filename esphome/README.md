# ESPHome Controller

## Purpose

The ESPHome controller performs the real-time hydroponics control work. It directly interfaces with the sensors, relays, pumps, solenoid, and local controller logic.

Home Assistant and Node-RED supervise and log the system, but the ESPHome controller performs most of the physical control.

## Main File

| File | Purpose |
|---|---|
| `hydroponics-patio-esp32.yaml` | Active ESP32 patio controller firmware. |
| `d1mini.yaml` | Older/monitoring controller reference. |

## Responsibilities

- Read tank volume sensors
- Read water temperature
- Read EC/TDS probe voltage
- Track fill gallons
- Track dose amounts
- Control water fill solenoid
- Control nutrient Pump A
- Control nutrient Pump B
- Expose sensors and switches to Home Assistant
- Provide the physical signals used by Node-RED cycle logging

## Important Entities

| Entity | Purpose |
|---|---|
| `switch.hydroponics_patio_esp32_water_fill_solenoid` | Water fill solenoid control |
| `switch.hydroponics_patio_esp32_nutrient_pump_a` | Nutrient Part A pump |
| `switch.hydroponics_patio_esp32_nutrient_pump_b` | Nutrient Part B pump |
| `sensor.hydroponics_patio_esp32_fill_gallons` | Gallons added during fill |
| `sensor.hydroponics_patio_esp32_dose_a_ml` | Pump A dose volume |
| `sensor.hydroponics_patio_esp32_dose_b_ml` | Pump B dose volume |
| `sensor.hydroponics_patio_esp32_tds_raw` | Raw EC/TDS probe voltage |
| `sensor.hydroponics_patio_esp32_tank_temp` | Tank water temperature |
| `sensor.outside_tank_gallons` | Current tank volume |

## Downstream Consumers

| Consumer | Uses |
|---|---|
| Home Assistant | Dashboard display and control |
| Node-RED Cycle Manager | Watches switch state changes and logs fill/dose events |
| Node-RED TDS Reference | Captures probe voltage, tank volume, and water temperature |
| MariaDB | Stores permanent event and reference history |

## Change Log

| Date | Change |
|---|---|
| 2026-06-28 | Documented ESPHome controller role as the primary physical control layer. |