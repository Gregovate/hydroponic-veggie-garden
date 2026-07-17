# Nutrient Management and EC Control

Revision: 0.2
Last Updated: 2026-07-06
Status: Draft

---

# Purpose

This document describes the nutrient management strategy used by the hydroponic vegetable garden.

It documents how nutrient concentration is measured, maintained, validated, and recorded while defining the engineering philosophy behind automatic nutrient dosing and long-term EC control.

Unlike the stock solution mixing procedure, this document focuses on **system operation** rather than chemical preparation.

---

# Design Goals

The nutrient management system is intended to:

- Maintain healthy nutrient concentrations
- Automatically replace nutrients lost during refill events
- Maintain EC during normal circulation
- Prevent over-dosing
- Record all nutrient additions
- Validate sensor performance using handheld measurements
- Support long-term calibration of the installed probe
- Build a historical database for future analysis

---

# Nutrient Management Philosophy

The nutrient management system is designed to maintain healthy nutrient
concentrations while minimizing operator intervention and preventing
over-dosing.

Unlike traditional hydroponic controllers that rely on calibrated EC probes and
PID control, this system uses a staged engineering approach centered around a
continuously monitored analog conductivity probe, periodic handheld EC
validation, and conservative proportional maintenance dosing.

## Design Objectives

The controller is intended to:

- Maintain stable nutrient concentration during normal operation.
- Automatically replace nutrients added during refill events.
- Gradually restore nutrient concentration during circulation when EC declines.
- Prevent excessive nutrient additions.
- Record every nutrient addition for historical analysis.
- Continuously improve probe calibration using field data.

## Configurable Maintenance Timing

Routine maintenance dosing uses several configurable timing parameters to allow
the controller behavior to be tuned without modifying automation logic.

### Maintenance Debounce

Defines how long the probe voltage must remain below the maintenance threshold
before a maintenance dose cycle is permitted to begin.

This prevents transient voltage changes from initiating unnecessary nutrient
corrections.

### Mixing Time

Defines how long the circulation system is allowed to mix newly added nutrients
before the post-dose TDS measurement is evaluated.

This value may require adjustment if tank volume or circulation flow rates are
changed.

### Next Maintenance Dose Offset

Defines the minimum time that must elapse after completion of the mixing period
before another automatic maintenance dose may begin.

This provides a short stabilization period between consecutive maintenance dose
cycles while allowing the controller to continue correcting nutrient levels if
required.

### Maximum Maintenance Cycles

Defines the maximum number of consecutive automatic maintenance correction
cycles permitted during a single maintenance event.

This prevents repeated nutrient additions caused by abnormal sensor behavior or
unexpected system faults while still allowing gradual correction toward the
target operating range.

## Fill-Based Nutrient Replacement

Whenever water is added to the system, the controller measures the actual gallons
added.

The patio_controller automatically calculates the required Part A and Part B
nutrient additions using the configured nutrient ratio and injects both parts
without operator intervention.

This provides repeatable nutrient replacement after every fill event.

## Maintenance Nutrient Control

During normal circulation, plants continuously consume nutrients while water
volume changes more slowly.

The installed conductivity probe is continuously monitored for changes in raw
probe voltage.

When the measured voltage falls below the configured maintenance threshold, the
controller performs a small maintenance dose.

Rather than using a fixed maintenance dose, the controller uses **proportional
step dosing**.

The requested maintenance dose is scaled according to the difference between:

- Current probe voltage
- Target probe voltage

This provides larger corrections when nutrient concentration is significantly
low while automatically reducing the correction size as the target is
approached.

### Proportional Step Dosing

Maintenance dosing uses a proportional step algorithm rather than a fixed dose.

Three configurable voltage limits define the controller behavior:

- **Low Trigger Voltage** – begins maintenance dosing.
- **Target Voltage** – desired operating voltage after maintenance.
- **Hard Stop Voltage** – prevents additional nutrient additions.

When the measured probe voltage falls below the Low Trigger Voltage, the
controller calculates a maintenance dose proportional to the voltage error:

```
Voltage Error = Target Voltage − Current Voltage
```

The requested maintenance dose is then calculated as:

```
Requested Dose =
Tank Gallons × Maximum Step mL/Gallon × Correction Ratio
```

where the Correction Ratio is limited between 0 and 1.

As the measured voltage approaches the Target Voltage, the requested dose
becomes progressively smaller.

This proportional approach provides smooth correction while reducing the
likelihood of overshoot without requiring the complexity of a PID controller.

## Safety Philosophy

Several independent limits prevent excessive nutrient additions.

Maintenance dosing is permitted only when:

- Outside Controller Mode is Auto Fill - Auto Dose.
- The circulation system is operating normally.
- Inventory is above the configured reserve level.
- Tank volume is valid.
- Fill and manual dosing are not active.
- Probe voltage remains below the maintenance target.
- Probe voltage is below the configured hard-stop limit.

Maintenance dosing immediately stops when any safety condition is violated.

Maintenance dosing is additionally limited by a configurable maximum number of
successive correction cycles to prevent repeated dosing caused by abnormal
sensor behavior or unexpected system faults.

## Continuous Monitoring

The installed probe is used as a **process control sensor**, not a laboratory
instrument.

Its purpose is to detect relative changes in nutrient concentration during daily
operation.

Because probe characteristics may change over time due to temperature,
installation, fouling, or aging, the system does not rely solely on calculated
EC values.

## Long-Term Calibration Strategy

The production reference remains the handheld EC meter.

Periodic reference measurements record:

- Raw probe voltage
- Handheld EC
- Water temperature
- Tank volume
- Environmental conditions
- Operator notes

These measurements are stored in the historical database and used to refine the
voltage-to-EC conversion model over time.

Estimated Tank EC is therefore considered an engineering estimate rather than a
primary control variable until sufficient historical calibration data has been
collected.

---

# EC Measurement Strategy

(TODO)

Describe the measurement methods currently used.

Topics:

- Installed analog conductivity probe
- Probe voltage
- Handheld EC meter
- Water temperature
- Manual reference measurements

---

# Probe Voltage vs. EC

The installed probe currently measures analog voltage rather than true EC.

Discuss:

- Probe voltage characteristics
- Temperature influence
- Probe aging
- Installation effects
- Why voltage should not be interpreted as calibrated EC

### Future Validation

Current engineering observations indicate that probe voltage is influenced by
more than nutrient concentration alone.

Ongoing investigation includes:

- Probe installation location within the reservoir.
- Water circulation and local mixing effects.
- Tank volume.
- Water temperature.
- Probe aging and fouling.
- Rainfall and dilution effects.

The analog TDS interface board is currently powered from the 5 V supply while
the ADS1115 ADC operates from the 3.3 V supply.

Future increases in target EC during heavy fruit production should include
validation of the maximum analog output voltage produced by the TDS interface
board to ensure the signal remains within the safe operating range of the
ADS1115 while providing adequate measurement resolution.

These validation steps should be completed before implementing a final
voltage-to-EC calibration model.

---

# Handheld EC Reference Measurements

(TODO)

Describe the production workflow.

Topics:

- Measure EC
- Record probe voltage
- Record water temperature
- Record tank volume
- Record operator notes

Explain how these measurements will be used to improve calibration over time.

---

## Controller Operating Modes

The outside hydroponics controller supports three operating modes. Each mode
defines who is responsible for controlling water and nutrient addition.

### 🤖 Auto Fill - Auto Dose

**Purpose**

Fully automatic operation.

**Operator Responsibilities**

- Configure the Auto Fill Threshold.
- Configure the Tank Full Target.

**Controller Responsibilities**

- Detect low tank level.
- Wait for the debounce period.
- Schedule the automatic fill.
- Fill the tank to the configured target.
- Calculate nutrient requirements based on water added.
- Automatically dose Parts A and B.
- Record the completed cycle.
- Generate notifications.

---

### 🧪 Manual Fill - Auto Dose

**Purpose**

Semi-automatic operation.

The operator decides how much water to add. The controller automatically
calculates and injects the required nutrients.

**Operator Responsibilities**

- Specify the desired fill amount.
- Start the fill.

**Controller Responsibilities**

- Measure water added.
- Calculate nutrient requirements.
- Automatically dose Parts A and B.
- Record the completed cycle.
- Generate notifications.

---

### 🟥 ESP-Override

**Purpose**

Manual service and maintenance mode.

Automation is intentionally bypassed. The controller functions only as a
hardware interface while providing operator decision support.

**Operator Responsibilities**

- Specify the desired fill amount, if applicable.
- Review the recommended nutrient dose calculated by the **🧮 ESP-Override Dose Recommendation Calculator** automation.
- Decide whether to use the recommended dose or a different amount.
- Start and stop fills.
- Manually dose Part A.
- Manually dose Part B.
- Determine all quantities and timing.

**System Responsibilities**

- The **🧮 ESP-Override Dose Recommendation Calculator** automation calculates and displays a recommended nutrient dose based on the specified fill amount.
- The patio_controller operates pumps and valves only when commanded by the operator.
- The patio_controller records manual execution events when appropriate.

---

### Summary

| Mode | Water Control | Nutrient Control | Typical Use |
|------|---------------|------------------|-------------|
| **Auto Fill - Auto Dose** | Automatic | Automatic | Normal operation |
| **Manual Fill - Auto Dose** | Manual | Automatic | Partial refills |
| **ESP-Override** | Manual | Manual | Service, testing, calibration |

---

# EC Reference Data Collection

(TODO)

Describe how operational data is collected.

Examples:

- Date
- Probe voltage
- Handheld EC
- Water temperature
- Tank gallons
- Operator notes

Explain how this database supports future calibration.

---

# Dashboard Integration

(TODO)

Planned dashboard features include:

- Current probe voltage
- Estimated EC
- Last handheld measurement
- Last automatic dose
- Last manual dose
- Auto-dose status
- Dosing history

---

# Database Design

(TODO)

Reference related database objects.

Examples:

- maintenance_log
- hydro_tds_reference_reading
- nutrient_batches
- inventory_ledger

Implementation details are documented in:

- 01-database-design.md

---

# Future Enhancements

(TODO)

Potential future capabilities include:

- Dynamic voltage-to-EC calibration
- Temperature compensation
- Closed-loop EC control
- Adaptive dosing algorithms
- Nutrient consumption analysis
- Crop-specific EC targets
- Predictive nutrient management

---

# Navigation

**Previous**

- [04 – Dashboard & History Design](04-dashboard-history-design.md)

**Next**

- [06 – Monitoring & Notification System](06-monitoring-and-notification-system.md)

**Related Documentation**

- [00 – System Overview](00-system-overview.md)
- [01 – Database Design](01-database-design.md)
- [Nutrient Solution Mixing SOP](sop/hydroponics-nutrient-solution-mixing.md)

---

# Revision History

| Date       | Revision | Description |
| ---------- | -------- | ----------- |
| 2026-07-01 | 0.1 | Initial document outline. |
| 2026-07-06 | 0.2 | Added nutrient management philosophy, operating modes, and maintenance dosing strategy. |