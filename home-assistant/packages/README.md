# Home Assistant Packages

**Project:** Hydroponics Veggie Garden
**Author:** Greg Liebig
**Last Updated:** 2026-06-28

---

# Purpose

Home Assistant is the supervisory and operator interface for the hydroponics system.

While the ESPHome controller performs most real-time control of the hardware, Home Assistant provides:

* Operator dashboards
* User controls
* Helper entities
* Configuration values
* Scripts
* SQL sensors
* Database integration
* User notifications
* Integration with Node-RED workflows

Home Assistant acts as the interface between the operator, the ESPHome controller, Node-RED, and the MariaDB database.

---

# System Architecture

```text
                 Operator
                     │
                     ▼
        Home Assistant Dashboard
                     │
      ┌──────────────┴──────────────┐
      │                             │
Helper Entities                 Node-RED
Scripts & SQL Sensors      Workflow Automation
      │                             │
      └──────────────┬──────────────┘
                     │
              ESPHome Controller
                     │
                 Physical Hardware

MariaDB provides permanent history and inventory storage for both Home Assistant and Node-RED.
```

---

# System Ownership

| Item                      | Owner          | Notes                                              |
| ------------------------- | -------------- | -------------------------------------------------- |
| Physical sensors          | ESPHome        | Direct hardware interface                          |
| Pump and solenoid control | ESPHome        | Real-time hardware control                         |
| Raw HX711 value           | ESPHome        | Load cell amplifier reading                        |
| Tank gallons              | Home Assistant | Calculated from HX711 calibration points           |
| Control mode              | Home Assistant | Auto / Manual / ESP-Override                       |
| Dashboard helper entities | Home Assistant | Input helpers, scripts, SQL sensors and UI state   |
| Workflow automation       | Node-RED       | Multi-step workflow execution and database logging |
| Maintenance history       | MariaDB        | `maintenance_log`                                  |
| EC reference history      | MariaDB        | `hydro_tds_reference_reading`                      |
| Inventory                 | MariaDB        | Purchases, batches and stock solutions             |
| Harvest history           | MariaDB        | Seasonal production records                        |

---

# Package Inventory

| Package                        | Purpose                                                              | Status       |
| ------------------------------ | -------------------------------------------------------------------- | ------------ |
| `patio_controller.yaml`        | Primary controller helpers, scripts, sensors and dashboard entities. | ✅ Production |
| `patio_dosing_controls.yaml`   | Nutrient dosing controls and Measure EC workflow support.            | ✅ Production |
| `patio_system_constants.yaml`  | Shared constants for the outdoor hydroponics system.                 | ✅ Production |
| `patio_energy_monitoring.yaml` | Electrical monitoring and power usage.                               | ✅ Production |
| `global_constants.yaml`        | Shared constants used by multiple packages.                          | ✅ Production |
| `db_connect.yaml`              | SQL integration and database connection configuration.               | ✅ Production |
| `batch_building.yaml`          | Helper entities for nutrient batch creation.                         | 🚧 Partial   |
| `harvest_inputs.yaml`          | Helper entities for harvest entry workflows.                         | 🚧 Partial   |
| `obsolete/`                    | Historical package versions retained for reference only.             | ❌ Legacy     |

---

# Responsibilities

Home Assistant is responsible for:

## Dashboard Interface

* System monitoring
* Controller mode selection
* Manual controls
* Fill and dose status
* System health
* Recent activity
* Event details and annotations
* Operator field notes
* EC reference entry
* Inventory status
* Future harvest management

---

## Helper Entities

Home Assistant helper entities provide configurable values without modifying ESPHome firmware.

Examples include:

* Control mode
* HX711 calibration points
* Target EC/TDS
* Fill thresholds
* Batch helper values
* Harvest helper values

---

## Scripts

Scripts provide reusable dashboard actions and workflow entry points.

Examples:

* Measure EC
* Event annotation
* Field note entry
* Batch-building workflow
* Harvest workflow

---

## SQL Integration

SQL sensors retrieve historical information from MariaDB for display on dashboards.

Examples:

* Recent maintenance activity
* Inventory status
* Event details
* Production statistics
* Future harvest summaries

---

## Node-RED Integration

Home Assistant provides the operator interface and helper values used by Node-RED.

Examples include:

* Control Mode
* Measure EC workflow
* Manual workflow triggers

Node-RED executes workflow logic and writes permanent records to MariaDB.

---

## UI Automations

Some automations currently remain in the Home Assistant UI for:

* Testing
* Trace debugging
* Experimental workflows

Production automations should be migrated into package YAML whenever practical.

---

# Documentation Rules

Update this README whenever changes affect:

* Package organization
* Helper entities
* Scripts
* SQL sensors
* Dashboard workflows
* Node-RED integration
* Production automations

Visual dashboard layout changes do not require updates unless they change workflow behavior.

---

# Change Log

| Date       | Description                                                                                                                                                 |
| ---------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 2026-06-28 | Initial Home Assistant package architecture documentation. Established package inventory, system ownership, responsibilities, and documentation guidelines. |
