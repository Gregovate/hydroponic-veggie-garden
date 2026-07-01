# Hydroponics Veggie Garden

A modular hydroponic automation platform built around **ESPHome**, **Home Assistant**, **Node-RED**, and **MariaDB**.

The project has evolved from a simple monitoring controller into a complete hydroponic management system capable of:

* Automated reservoir refill
* Automatic nutrient dosing
* EC monitoring and reference measurements
* Historical event logging
* Seasonal crop management
* Nutrient inventory tracking
* Dashboard-based operation
* Long-term production analysis

The repository contains the firmware, automation workflows, database schema, hardware design, and engineering documentation required to operate, maintain, and rebuild the system.

---

# System Architecture

```text
ESPHome Controller
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
Dashboard • History • Reporting
```

Each layer has a well-defined responsibility.

* **ESPHome** provides hardware monitoring and low-level control.
* **Home Assistant** provides the operator interface and configuration.
* **Node-RED** performs workflow automation and business logic.
* **MariaDB** stores the permanent operational history.

---

# Engineering Documentation

The engineering manual is located in the **docs** folder.

| Document                           | Description                                                                 |
| ---------------------------------- | --------------------------------------------------------------------------- |
| `00-system-overview.md`            | Overall project architecture and design philosophy.                         |
| `01-database-design.md`            | Database schema, normalization, and design decisions.                       |
| `02-season-and-layout.md`          | Seasonal crop layouts and planting management.                              |
| `03-harvest-and-waste-tracking.md` | Harvest, waste, and production history.                                     |
| `04-dashboard-history-design.md`   | Home Assistant dashboard philosophy, Hydro-History, and operator workflows. |

Additional engineering documents will continue to be added as the project evolves.

---

# Standard Operating Procedures

Routine operating procedures are located in:

```text
docs/sop/
```

Current SOPs include:

* `hydroponics-nutrient-solution-mixing.md`

These documents are intended to be printable field procedures.

---

# Hardware Documentation

Controller and hardware reference documentation is located in:

```text
docs/hardware/
```

Including:

* ESP32 controller
* HX711 calibration
* Alternate pressure sensor
* Voltage divider reference

---

# Repository Layout

```text
credentials/         Local credentials (not committed)

docs/                Engineering documentation
  archive/           Historical documents
  hardware/          Hardware reference
  images/            Documentation images
  sop/               Standard operating procedures

esphome/             ESPHome firmware

hardware/            Bill of materials and enclosure information

home-assistant/
  packages/          Home Assistant packages

node-red/            Production Node-RED flows

schematic/           KiCad schematic and PCB project

sql/                 Database schema and SQL objects
```

---

# Development Philosophy

The project follows a layered architecture.

* Keep hardware logic inside ESPHome.
* Keep operator interaction inside Home Assistant.
* Keep workflow automation inside Node-RED.
* Keep long-term historical data inside MariaDB.

This separation simplifies maintenance, troubleshooting, future expansion, and disaster recovery.

---

# Disaster Recovery

One objective of this repository is complete system reproducibility.

The combination of:

* engineering documentation
* firmware
* Home Assistant packages
* Node-RED flows
* SQL schema
* hardware design files

should allow the hydroponic system to be rebuilt from scratch following a major hardware or software failure.

---

# License

See the `LICENSE` file for licensing information.
