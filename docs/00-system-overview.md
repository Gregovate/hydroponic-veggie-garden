# Hydroponics Veggie Garden System Overview

**Revision:** 1.0
**Last Updated:** 2026-06-28
**Project Status:** Active Development

---

# Purpose

The Hydroponics Veggie Garden project is an outdoor hydroponic vegetable production system designed to automate nutrient management while collecting long-term operational and crop production data.

The project began as a simple water level monitor using a Wemos D1 Mini and has evolved into a complete monitoring, automation, and data collection platform consisting of:

* ESPHome firmware
* Home Assistant
* Node-RED
* MariaDB
* KiCad hardware design
* Engineering documentation

The long-term objective is to reduce manual maintenance while improving crop production through measurement, automation, and historical analysis.

---

# System Objectives

The system is designed to:

* Monitor reservoir volume
* Automatically refill the nutrient tank
* Maintain nutrient concentration (EC)
* Monitor system flow rates
* Record maintenance and operational events
* Track nutrient inventory
* Track seasonal crop layouts
* Record harvests and waste
* Calculate production costs
* Analyze long-term system performance

Rather than simply automating pumps, the project is intended to become a complete hydroponic crop management system.

---

# Major Components

## ESPHome Controller

The ESP32 controller performs the real-time monitoring and control functions.

Major functions include:

* Reservoir volume measurement (HX711 load cells)
* Water temperature monitoring
* Flow monitoring
* Pump control
* Solenoid valve control
* EC/TDS probe monitoring
* Local safety logic
* Communication with Home Assistant

The controller is intentionally responsible only for low-level hardware control.

---

## Home Assistant

Home Assistant provides the operational user interface.

Responsibilities include:

* Dashboard presentation
* User configuration
* Manual controls
* Notifications
* Helper entities
* Automation coordination
* Device status

The dashboard is designed for day-to-day operation rather than engineering diagnostics.

---

## Node-RED

Node-RED performs higher-level automation and data processing.

Current responsibilities include:

* Nutrient dosing logic
* Event logging
* EC reference capture
* Database writes
* Inventory calculations
* Batch management

As the project grows, Node-RED will become the primary workflow engine.

---

## MariaDB

MariaDB serves as the permanent historical record for the system.

The database stores:

* Fill events
* Dosing events
* EC reference measurements
* Nutrient inventory
* Stock solution batches
* Seasonal planting information
* Harvest data
* Waste tracking
* Operational history

The database allows long-term analysis that cannot be performed using Home Assistant history alone.

---

# Project Organization

The repository is organized into several major components.

| Folder         | Purpose                            |
| -------------- | ---------------------------------- |
| docs           | Engineering documentation          |
| esphome        | ESPHome firmware                   |
| home-assistant | Home Assistant packages            |
| node-red       | Automation flows                   |
| sql            | Database schema and supporting SQL |
| hardware       | BOM and enclosure documentation    |
| schematic      | KiCad schematic and PCB files      |

---

# Engineering Philosophy

The project is designed around a layered architecture.

```
Hardware
        │
        ▼
ESPHome
        │
        ▼
Home Assistant
        │
        ▼
Node-RED
        │
        ▼
MariaDB
        │
        ▼
Analysis & Reporting
```

Each layer has a clearly defined responsibility.

Keeping responsibilities separated makes the system easier to maintain and expand.

## Home Assistant Package Organization

Home Assistant packages are organized by **functional responsibility** rather than by entity type.

Each package owns a specific portion of the hydroponic system and should contain
the helpers, template entities, sensors, automations, and supporting logic
required for that responsibility.

### patio_system_constants.yaml

Owns the physical characteristics and operating parameters of the patio
hydroponic system.

Examples include:

- Tank capacity and operating limits
- HX711 calibration
- Flow calibration
- Pump calibration
- Auto-fill operating parameters
- System-specific constants

These values describe the physical system and may differ for each hydroponic
installation.

### patio_dosing_controls.yaml

Owns the routine nutrient maintenance strategy.

Examples include:

- Maintenance dose thresholds
- Target and hard-stop voltages
- Maximum maintenance step size
- Inventory lockout limits
- Maintenance timing
- Maximum maintenance cycles
- Automatic nutrient dosing logic

Separating system constants from dosing control allows future hydroponic
controllers, such as a basement system, to maintain independent hardware
configuration while reusing the same nutrient management architecture.

---

# Future Development

Current development is focused on expanding the system from automation into production management.

Major planned capabilities include:

* Seasonal crop management
* Plant position tracking
* Harvest recording
* Waste recording
* Production cost analysis
* Yield by variety
* Yield by channel position
* Nutrient consumption analysis
* Predictive inventory management
* Dashboard history and reporting

The long-term goal is to understand not only **how** the hydroponic system operates, but **why** certain growing conditions produce better results.

---

# Related Documentation

This document provides the overall project overview.

Additional documentation describes specific portions of the system.

| Document | Description |
|----------|-------------|
| [01 – Database Design](01-database-design.md) | Database schema, normalization, and engineering philosophy. |
| [02 – Season & Layout](02-season-and-layout.md) | Seasonal crop layouts and planting locations. |
| [03 – Harvest & Waste Tracking](03-harvest-and-waste-tracking.md) | Harvest recording, waste tracking, and production analysis. |
| [04 – Dashboard & History Design](04-dashboard-history-design.md) | Dashboard philosophy, Hydro-History, and operator workflows. |
| 05 – Nutrient Management & EC Control *(In Development)* | Automatic nutrient management, EC control strategy, and dosing workflows. |
| 06 – Monitoring & Notification System *(Planned)* | System monitoring, alarms, and notification strategy. |
| 07 – Nutrient Inventory Management *(Planned)* | Dry inventory, stock solution inventory, and batch management. |
| [ESP32 Controller](hardware/esp_32_controller_readme.md) | ESP32 controller hardware and firmware overview. |
| [HX711 Calibration](hardware/calibration-process-hx711.md) | Tank calibration procedure using Home Assistant interpolation. |
| [Alternate Pressure Sensor](hardware/alternate-pressure-sensor.md) | Alternative tank level sensing using a pressure transducer. |
| [Voltage Divider Reference](hardware/voltage_divider_explained.md) | Analog input protection and voltage divider design. |
| [Nutrient Solution Mixing SOP](sop/hydroponics-nutrient-solution-mixing.md) | Printable procedure for preparing Part A and Part B stock solutions. |

---

# Revision History

| Date       | Revision | Description                                                                                                                     |
| ---------- | -------- | ------------------------------------------------------------------------------------------------------------------------------- |
| 2026-06-28 | 1.0      | Initial system overview documenting the transition from a controller project to a complete hydroponic crop management platform. |

---

## Navigation

**Next:** [01 – Database Design](01-database-design.md)

**Related:**

- [ESP32 Controller](hardware/esp_32_controller_readme.md)
- [HX711 Calibration](hardware/calibration-process-hx711.md)
- [Nutrient Solution Mixing SOP](sop/hydroponics-nutrient-solution-mixing.md)