# Home Assistant Packages

**Revision:** 1.1
**Last Updated:** 2026-07-01
**Status:** Production

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
        ┌───────────────┼───────────────┐
        │               │               │
        ▼               ▼               ▼
   Helper Entities   Scripts/UI     SQL Sensors
        │               │               │
        └───────────────┼───────────────┘
                        │
                        ▼
                   Node-RED
                Workflow Engine
                        │
                        ▼
                    MariaDB
                        ▲
                        │
                  ESPHome Controller
                        │
                        ▼
                 Physical Hardware
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

| Package | Purpose | Status |
|---------|---------|:------:|
| `global_constants.yaml` | Shared constants used throughout the Home Assistant packages. | ✅ Production |
| `patio_system_constants.yaml` | Outdoor hydroponics system configuration and operating constants. | ✅ Production |
| `patio_controller.yaml` | Primary controller helpers, scripts, template sensors, and dashboard entities. | ✅ Production |
| `patio_dosing_controls.yaml` | Nutrient dosing controls, automatic dosing helpers, and Measure EC workflow support. | ✅ Production |
| `patio_energy_monitoring.yaml` | Electrical monitoring and power consumption. | ✅ Production |
| `db_connect.yaml` | SQL integration and MariaDB connection configuration. | ✅ Production |
| `db_history_dashboard.yaml` | Hydro-History dashboard entities and browser support. | ✅ Production |
| `batch_building.yaml` | Helper entities for nutrient batch creation and inventory workflows. | 🚧 Partial |
| `harvest_inputs.yaml` | Helper entities for seasonal harvest and waste workflows. | 🚧 Partial |
| `obsolete/` | Historical package versions retained for reference only. | ❌ Legacy |

---

# Responsibilities

Home Assistant serves as the supervisory control system and primary operator interface for the hydroponic vegetable garden.

Its responsibilities include:

---

## Operator Interface

Provide the primary interface for day-to-day operation.

Examples:

* System status dashboards
* Controller mode selection
* Manual controls
* Dashboard workflows
* Notifications
* System configuration
* System health

---

## Monitoring

Display current operating conditions.

Examples:

* Reservoir volume
* Probe voltage
* Estimated EC
* Water temperature
* Flow rates
* Fill status
* Dosing status
* Controller status
* Energy monitoring

---

## Operator Workflows

Provide user entry points into production workflows.

Current workflows include:

* Measure EC
* Hydro-History Browser
* Event annotation
* Standalone field notes

Planned workflows include:

* Nutrient batch creation
* Inventory updates
* Harvest entry
* Waste entry

---

## Helper Entities

Provide configurable values without modifying ESPHome firmware.

Examples include:

* Controller mode
* HX711 calibration points
* Target EC
* Fill thresholds
* Dashboard state
* Batch helper values
* Harvest helper values

---

## Scripts

Provide reusable dashboard actions.

Examples include:

* Measure EC
* Event annotation
* Field note entry
* Batch-building workflow
* Harvest workflow

---

## SQL Integration

Retrieve historical information from MariaDB for dashboard presentation.

Examples include:

* Recent activity
* Inventory status
* Event details
* Production statistics
* Future harvest summaries

---

## Node-RED Integration

Provide helper entities and workflow entry points used by Node-RED.

Examples include:

* Control mode
* Dashboard workflow triggers
* Measure EC
* History Browser
* Batch building
* Harvest entry

Node-RED executes workflow automation and writes permanent records to MariaDB.

---

## UI Automations

Some automations currently remain in the Home Assistant UI for:

* Testing
* Trace debugging
* Experimental workflows

Production automations should be migrated into package YAML or Node-RED whenever practical.

---

# Documentation Maintenance

This README describes the current Home Assistant package architecture.

Update this document whenever changes affect:

- Package organization
- Package responsibilities
- Helper entities
- Dashboard workflows
- SQL sensors
- Node-RED integration
- Production automations
- Package dependencies
- System ownership

Routine dashboard layout or cosmetic UI changes do not require updates unless they change system behavior or operator workflows.

---

# Revision History

| Date | Revision | Description |
|------|:--------:|-------------|
| 2026-07-01 | 1.1 | Updated package inventory, added Hydro-History package, revised responsibilities, added navigation, and synchronized documentation with the current repository structure. |
| 2026-06-28 | 1.0 | Initial Home Assistant package architecture documentation. |

---

# Navigation

## Engineering Manual

- [System Overview](../../docs/00-system-overview.md)
- [Database Design](../../docs/01-database-design.md)
- [Dashboard & History Design](../../docs/04-dashboard-history-design.md)

## Component Documentation

- [ESPHome](../../esphome/README.md)
- [Node-RED](../../node-red/README.md)
- [SQL](../../sql/README.md)