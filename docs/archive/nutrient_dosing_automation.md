# Hydroponics Nutrient Dosing Automation Plan

## Purpose

Automate the dosing of Part A and Part B nutrient solutions based on the amount of fresh water added to the hydroponic system. Track usage, stir before dosing, and alert when it’s time to mix more.

---

## Hardware Components

- **3rd Flow Sensor**: Installed upstream of the fill solenoid for fresh water tracking.
- **Solenoid Valve**: Controls tank refill based on HX711 tank weight.
- **HX711 Weight Sensor**: Detects low tank level to start refill; ensures overfill prevention.
- **Two Peristaltic Pumps**: One for each nutrient (Part A and Part B).
- **Two Magnetic Stir Motors**: Controlled by relays to mix solutions before dosing.
- **Two Flow Sensors**: Downstream to verify nutrient delivery to thin-film troughs (already installed).

---

## Home Assistant Entities

### Input Helpers

```yaml
input_number:
  fresh_water_added_gallons:
    name: Fresh Water Added
    min: 0
    max: 50
    step: 1
    unit_of_measurement: 'gal'

  nutrient_a_used_ml:
    name: Nutrient A Used
    min: 0
    max: 4000
    step: 10
    unit_of_measurement: "ml"

  nutrient_b_used_ml:
    name: Nutrient B Used
    min: 0
    max: 4000
    step: 10
    unit_of_measurement: "ml"

input_button:
  dose_nutrients_now:
    name: Dose Nutrients
  reset_nutrient_usage:
    name: Reset Nutrient Usage
```

---

## Automations

### Track Nutrient Dosing

```yaml
alias: Track Nutrient Dosing
trigger:
  - platform: state
    entity_id: input_button.dose_nutrients_now
actions:
  - variables:
      gallons: "{{ states('input_number.fresh_water_added_gallons') | float(0) }}"
      ml: "{{ (gallons * 10) | round(0) }}"
  - alias: "Add to Nutrient A Used"
    service: input_number.set_value
    data:
      entity_id: input_number.nutrient_a_used_ml
      value: "{{ [states('input_number.nutrient_a_used_ml') | float + ml, 4000] | min }}"
  - alias: "Add to Nutrient B Used"
    service: input_number.set_value
    data:
      entity_id: input_number.nutrient_b_used_ml
      value: "{{ [states('input_number.nutrient_b_used_ml') | float + ml, 4000] | min }}"
```

### Reset Nutrient Usage

```yaml
alias: Reset Nutrient Usage
trigger:
  - platform: state
    entity_id: input_button.reset_nutrient_usage
actions:
  - alias: "Reset Part A"
    service: input_number.set_value
    data:
      entity_id: input_number.nutrient_a_used_ml
      value: 0
  - alias: "Reset Part B"
    service: input_number.set_value
    data:
      entity_id: input_number.nutrient_b_used_ml
      value: 0
```

### Notify Low Nutrient Supply

```yaml
alias: Notify Low Nutrient Supply
trigger:
  - platform: numeric_state
    entity_id: input_number.nutrient_a_used_ml
    above: 3500
  - platform: numeric_state
    entity_id: input_number.nutrient_b_used_ml
    above: 3500
actions:
  - alias: "Send Alert"
    service: notify.mobile_app_yourdevice
    data:
      title: "Hydroponics Nutrient Alert"
      message: "Time to mix more Part A or Part B nutrient solution."
```

---

## Next Steps

- Add third flow meter wiring and ESPHome config
- Wire 12V magnetic stir motors to relays
- Calibrate pump output (ml/sec) for precise timing
- Optionally: tie solenoid valve and flow detection into automatic refill logic
- Design dashboard for control panel with:
  - Fresh water input
  - Dose button
  - Used totals
  - Reset usage
  - EC reading (optional)

