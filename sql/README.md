# SQL Database Objects

**Revision:** 1.0  
**Last Updated:** 2026-07-01  
**Status:** Production

---

# Purpose

The `sql` folder contains MariaDB schema and database objects used by the hydroponics system.

MariaDB is the permanent historical record for system operation, nutrient management, inventory, crop production, and dashboard history.

---

# File Inventory

| File | Purpose | Status |
|------|---------|:------:|
| `hydro_ddl.sql` | Main database schema for hydroponics tables. | ✅ Production |
| `v_hydro_recent_activity.sql` | View used by Hydro-History to display recent operational activity. | ✅ Production |
| `README.md` | SQL folder documentation. | ✅ Production |

---

# Responsibilities

The SQL layer is responsible for:

- Database schema definition
- Permanent operational history
- Maintenance event storage
- EC reference history
- Nutrient inventory records
- Batch records
- Seasonal crop records
- Harvest and waste records
- Dashboard query support

The SQL layer is not responsible for:

- Physical hardware control
- Operator interface
- Workflow automation

---

# Database Objects

Current production database objects include:

| Object | Type | Purpose |
|--------|------|---------|
| `maintenance_log` | Table | Stores fill, dose, note, and maintenance events. |
| `hydro_tds_reference_reading` | Table | Stores handheld EC/TDS reference readings. |
| `v_hydro_recent_activity` | View | Provides unified recent activity for Hydro-History. |
| `ingredients` | Table | Stores nutrient ingredient definitions. |
| `inventory_ledger` | Table | Stores inventory transactions. |
| `nutrient_batches` | Table | Stores prepared nutrient stock solution batches. |
| `hydro_season` | Table | Stores growing season records. |
| `hydro_position` | Table | Stores physical planting positions. |
| `hydro_season_planting` | Table | Stores crop planting assignments. |
| `hydro_harvest` | Table | Stores harvest records. |
| `hydro_waste` | Table | Stores crop loss and waste records. |

---

# Usage Notes

Apply SQL files manually through the database administration tool during development.

Production changes should be committed to this folder before being applied to the live MariaDB database.

Schema changes should also be reflected in:

- [Database Design](../docs/01-database-design.md)
- [Dashboard & History Design](../docs/04-dashboard-history-design.md)
- Node-RED flows, when database writes are affected
- Home Assistant SQL sensors, when dashboard queries are affected

---

# Documentation Maintenance

Update this README whenever changes affect:

- SQL file inventory
- Table structure
- Views
- Stored procedures
- Database import order
- Dashboard query dependencies
- Node-RED database writes

---

# Revision History

| Date | Revision | Description |
|------|:--------:|-------------|
| 2026-07-01 | 1.0 | Initial SQL folder documentation. |

---

# Navigation

## Engineering Manual

- [System Overview](../docs/00-system-overview.md)
- [Database Design](../docs/01-database-design.md)
- [Dashboard & History Design](../docs/04-dashboard-history-design.md)

## Component Documentation

- [ESPHome](../esphome/README.md)
- [Home Assistant Packages](../home-assistant/packages/README.md)
- [Node-RED](../node-red/README.md)