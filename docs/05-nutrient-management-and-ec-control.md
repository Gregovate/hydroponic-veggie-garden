# Nutrient Management and EC Control

Revision: 0.3
Last Updated: 2026-07-20
Status: Draft

---

# Purpose

This document describes the nutrient management strategy used by the hydroponic vegetable garden.

It documents how nutrient concentration is measured, maintained, validated, and recorded while defining the engineering philosophy behind automatic nutrient dosing and long-term EC control.

Unlike the stock solution mixing procedure, this document focuses on **system operation** rather than chemical preparation.

---

# Design Goals

The nutrient management system is intended to:

- Maintain healthy nutrient concentrations.
- Automatically replace nutrients lost during refill events.
- Maintain nutrient concentration during normal circulation.
- Prevent over-dosing.
- Record all nutrient additions.
- Validate sensor performance using independent handheld and installed sensor measurements.
- Compare multiple installed conductivity sensors under identical operating conditions.
- Support long-term calibration and evaluation of installed conductivity sensors.
- Separate raw conductivity measurement from calculated EC estimation.
- Build a historical database for long-term engineering analysis and future controller improvements.

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

The installed conductivity sensors are used as **process measurement sensors**, not laboratory instruments.

Their purpose is to detect relative changes in nutrient concentration during normal system operation while providing continuous measurements that can be compared against periodic handheld EC reference readings.

The current measurement architecture consists of:

- **KEYESTUDIO Analog TDS Sensor** — The production process measurement sensor used by the automatic maintenance dosing system.
- **DFRobot Gravity Analog TDS Sensor** — An independent validation sensor operated in parallel with the production sensor for long-term performance evaluation.
- **Bluelab Truncheon EC Meter** — The production reference instrument used for periodic verification of the installed sensors.
- **Estimated EC** — A calculated engineering estimate generated by Home Assistant from the measured sensor voltage. This is a derived value rather than a direct measurement.

Each measurement source serves a different purpose and should not be considered interchangeable.

Because conductivity measurements may be influenced by temperature, probe placement, water circulation, fouling, aging, electronics, and other environmental factors, the system does not rely on a single sensor or calculated EC value.

Instead, long-term confidence is established by comparing multiple measurement sources under identical operating conditions and preserving those measurements for historical analysis while the system is under development.

## Long-Term Calibration Strategy

The production reference remains the handheld EC meter.

Periodic reference measurements record:

- KEYESTUDIO analog sensor voltage
- DFRobot analog sensor voltage
- Handheld EC measurement
- Estimated Tank EC
- Water temperature
- Tank volume
- Rainfall and estimated dilution
- Environmental conditions
- Operator notes

These synchronized measurements are stored in the historical database and used to:

- Compare the performance of both installed analog sensors.
- Identify sensor drift, fouling, or installation effects.
- Evaluate the accuracy of the Estimated Tank EC calculation.
- Improve the voltage-to-EC estimation model over time.
- Build confidence in long-term unattended controller operation.

Estimated Tank EC is therefore considered an engineering estimate rather than a primary control variable until sufficient historical validation data has been collected.

---

# EC Measurement Strategy

The outdoor hydroponics system uses multiple independent measurement sources to monitor nutrient concentration. Each source serves a specific purpose within the overall measurement strategy.

No single measurement is assumed to be the absolute truth. Instead, measurements are compared and evaluated together to improve confidence in system performance and to identify sensor drift or abnormal operating conditions.

## Production Process Sensor

The KEYESTUDIO analog TDS sensor is the production process measurement used by the automatic maintenance dosing system.

Its primary purpose is to detect relative changes in nutrient concentration rather than provide a laboratory-grade EC measurement.

The production sensor remains unchanged while additional measurement methods are validated.

## Validation Sensor

The DFRobot Gravity analog TDS sensor operates in parallel with the production sensor.

It is used to:

- Compare long-term stability.
- Detect sensor drift.
- Evaluate installation effects.
- Confirm repeatability under identical operating conditions.

The validation sensor does not participate in automatic nutrient dosing while the measurement system is under development.

## Handheld EC Reference

The handheld EC meter remains the production reference instrument.

Periodic handheld measurements provide an independent verification of nutrient concentration and are used to evaluate the performance of the installed analog sensors.

## Estimated Tank EC

Estimated Tank EC is calculated by Home Assistant using the measured analog sensor voltage and the current engineering estimation model.

Estimated Tank EC is intended to provide a convenient operator-facing value for monitoring system performance.

Because the estimation model will continue to evolve as additional validation data is collected, Estimated Tank EC is considered an engineering estimate rather than a laboratory measurement.

## Supporting Measurements

Additional operating conditions are recorded whenever practical to improve interpretation of conductivity measurements.

These include:

- Water temperature
- Tank volume
- Rainfall since the previous reference measurement
- Estimated rainwater dilution
- Operator observations

Together, these measurements provide the engineering context needed to evaluate long-term sensor performance and improve future EC estimation models.
---

# Probe Voltage vs. EC

Neither installed analog sensor measures electrical conductivity (EC) directly. Instead, each sensor produces an analog output voltage that varies with the conductivity of the solution.

The relationship between sensor voltage and actual EC is influenced by multiple factors and should not be assumed to be constant under all operating conditions.

Engineering observations have shown that analog sensor voltage may be affected by:

- Nutrient concentration
- Water temperature
- Probe location within the reservoir
- Water circulation and local mixing
- Tank volume
- Rainfall and dilution
- Probe fouling or aging
- Sensor-to-sensor variation
- Electronic component tolerances

Because of these influences, raw sensor voltage should be treated as a process measurement rather than a calibrated EC value.

The installed analog sensors are intended to detect relative changes in nutrient concentration during normal operation. Absolute nutrient concentration is verified through periodic handheld EC reference measurements.

The long-term objective is to develop an engineering estimation model that provides a useful approximation of tank EC while preserving the original raw sensor measurements for future analysis and model refinement.

Until sufficient validation data has been collected, automatic maintenance dosing will continue to be based on the proven production sensor, while additional sensors and estimation models are evaluated in parallel.

### Future Validation

Current engineering observations indicate that analog sensor voltage is influenced by more than nutrient concentration alone.

Ongoing investigation includes:

- Sensor installation location within the reservoir.
- Water circulation and local mixing effects.
- Tank volume.
- Water temperature.
- Probe fouling and long-term aging.
- Rainfall and dilution effects.
- Sensor-to-sensor repeatability.
- Long-term stability of the KEYESTUDIO and DFRobot analog sensors.
- Accuracy of the Estimated Tank EC calculation.

Additional validation is planned to determine the most suitable long-term measurement strategy for unattended controller operation.

The analog sensor interface boards are currently powered from the 5 V supply while the ADS1115 analog-to-digital converter operates from the 3.3 V supply.

Future increases in target EC during heavy fruit production should include validation of the maximum analog output voltage produced by each analog sensor interface to ensure the signals remain within the safe operating range of the ADS1115 while providing adequate measurement resolution.

These validation activities should be completed before modifying the production automatic maintenance dosing strategy or implementing a final voltage-to-EC estimation model.

---

# Handheld EC Reference Measurements

The handheld EC reference workflow provides the production reference measurement for evaluating the installed analog conductivity sensors.

Reference measurements are initiated from the Home Assistant **Measure EC** workflow after the reservoir has reached a stable operating condition.

Each reference measurement records:

- KEYESTUDIO analog sensor voltage
- DFRobot analog sensor voltage (during the current validation phase)
- Handheld EC measurement
- Estimated Tank EC
- Water temperature
- Tank volume
- Rainfall and estimated dilution
- Environmental conditions
- Operator notes

These measurements are captured as a synchronized snapshot and stored in the historical database.

Handheld reference measurements are typically performed:

- During routine system inspections.
- After significant water additions.
- After nutrient adjustments.
- During sensor validation and troubleshooting.
- Whenever abnormal controller behavior is observed.

The historical reference data is used to:

- Compare the performance of the installed analog sensors.
- Identify long-term sensor drift or fouling.
- Evaluate the accuracy of the Estimated Tank EC calculation.
- Improve the voltage-to-EC estimation model.
- Verify that the automatic maintenance dosing system continues to operate as expected.

Because all measurements are recorded at the same point in time, the historical database provides an engineering record that supports both routine operation and future refinement of the nutrient management system.

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

Each handheld EC reference measurement is permanently stored in the historical database as an engineering reference record.

The database is intended to preserve both the measured values and the operating conditions under which they were obtained, allowing historical analysis long after the individual measurements were taken.

Typical recorded information includes:

- Date and time
- KEYESTUDIO analog sensor voltage
- DFRobot analog sensor voltage (during validation)
- Handheld EC measurement
- Estimated Tank EC
- Water temperature
- Tank volume
- Rainfall and estimated dilution
- Environmental conditions
- Operator notes

Collecting complete operating context allows historical measurements to be interpreted correctly and compared under similar operating conditions.

The historical database supports:

- Long-term evaluation of installed sensor performance.
- Identification of sensor drift and fouling.
- Comparison of multiple analog sensor technologies.
- Validation of the Estimated Tank EC calculation.
- Refinement of future voltage-to-EC estimation models.
- Engineering analysis of nutrient management performance over multiple growing seasons.

The historical database is intended to serve as the permanent engineering record for development, validation, and continuous improvement of the outdoor hydroponics nutrient management system.

---

# Dashboard Integration

The Home Assistant dashboard provides the primary operator interface for the outdoor hydroponics controller.

Rather than serving as a simple collection of sensor values, the dashboard presents the current operating state of the nutrient management system and provides access to both manual and automatic controller functions.

Current dashboard features include:

- Live analog sensor voltage
- Estimated Tank EC
- Tank volume
- Water temperature
- Flow rates
- Current controller operating mode
- Automatic maintenance dosing status
- Maintenance dose recommendations
- Fill status and progress
- Last handheld EC reference measurement
- Recent maintenance activity and event history
- Nutrient inventory and cumulative dosing totals
- Rainfall and environmental monitoring

The dashboard also provides operator controls for:

- Automatic maintenance dosing.
- Manual nutrient dosing.
- Manual water fill operations.
- ESP-Override maintenance functions.
- Recording handheld EC reference measurements.
- Entering engineering field notes.

Dashboard information is derived from live ESPHome measurements, Home Assistant calculations, Node-RED workflow status, and historical database records to present a unified view of current system operation.

The dashboard continues to evolve as additional controller capabilities are implemented, with the objective of providing a complete operator interface without requiring direct access to ESPHome logs, Home Assistant traces, Node-RED flows, or database queries.

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

| Date | Revision | Description |
|------|----------|-------------|
| 2026-07-20 | 0.3 | Expanded measurement architecture, EC estimation strategy, sensor validation methodology, handheld reference workflow, dashboard integration, and engineering documentation. |
| 2026-07-06 | 0.2 | Added nutrient management philosophy, operating modes, and maintenance dosing strategy. |
| 2026-07-01 | 0.1 | Initial document outline. |