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

# Automatic Fill Dosing

(TODO)

Describe the automatic nutrient replacement performed after a refill event.

Topics:

- Calculate gallons added
- Calculate nutrient dose
- Dose Part A
- Dose Part B
- Mixing delay
- Event logging

---

# Automatic EC Maintenance Dosing

(TODO)

Describe the maintenance dosing algorithm.

Topics:

- Monitor probe voltage
- Minimum threshold
- Dose increment
- Mixing period
- Recheck
- Repeat if necessary
- Maximum safe limit
- Stop conditions

---

# Manual Dosing

(TODO)

Describe manual nutrient additions.

Topics:

- Manual override
- Maintenance operations
- Initial startup
- Emergency correction

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