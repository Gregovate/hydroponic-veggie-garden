# Nutrient Management and EC Control

**Revision:** 0.1  
**Last Updated:** 2026-07-01  
**Status:** Outline

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

(TODO)

Describe the overall nutrient management strategy.

Topics:

- Why EC matters
- Plant nutrient requirements
- Relationship between water volume and nutrient concentration
- Continuous monitoring versus periodic validation
- Long-term data collection

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

(TODO)

The installed probe currently measures analog voltage rather than true EC.

Discuss:

- Probe voltage characteristics
- Temperature influence
- Probe aging
- Installation effects
- Why voltage should not be interpreted as calibrated EC

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
hardware interface.

**Operator Responsibilities**

- Start and stop fills.
- Manually dose Part A.
- Manually dose Part B.
- Determine all quantities and timing.

**Controller Responsibilities**

- Operate pumps and valves.
- Record manual events when appropriate.

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

| Date | Revision | Description |
|------|----------|-------------|
| 2026-07-01 | 0.1 | Initial document outline. |