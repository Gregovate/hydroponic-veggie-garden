# Hydroponics Database Design

**Revision:** 0.1
**Last Updated:** 2026-06-28
**Status:** Active Design / Partial Implementation

---

# Purpose

The Hydroponics database is intended to become the permanent record for the outdoor hydroponic vegetable system.

The database should eventually support:

* System event history
* Fill and dosing history
* EC/TDS reference checks
* Nutrient stock solution inventory
* Dry ingredient inventory
* Batch building
* Seasonal crop layouts
* Planting positions
* Harvest tracking
* Waste tracking
* Cost analysis
* Long-term production analysis

At the time of this revision, the database contains several useful tables, but the system is not yet fully integrated. Some tables are active and working, while others exist but do not yet have reliable Home Assistant or Node-RED workflows for entering and reviewing data.

The goal of this document is to describe what exists, what works, what does not work yet, and what direction the database should move toward.

---

## Development Status

| Component                 | Status             | First Working | Last Updated |
| ------------------------- | ------------------ | ------------- | ------------ |
| Controller Event Logging  | ✅ Production       | 2026-06-26    | 2026-06-28   |
| EC Reference Measurements | ✅ Production       | 2026-06-28    | 2026-06-28   |
| Dry Ingredient Purchases  | 🧱 Database Only   | —             | 2026-06-28   |
| Batch Building            | 🟨 Manual Workflow | —             | 2026-06-28   |
| Inventory Management      | 🚧 Partial         | —             | 2026-06-28   |
| History Dashboard         | ⏳ Planned          | —             | 2026-06-28   |
| Season Management         | ⏳ Planned          | —             | 2026-06-28   |
| Harvest Tracking          | ⏳ Planned          | —             | 2026-06-28   |
| Waste Tracking            | ⏳ Planned          | —             | 2026-06-28   |
| Production Analytics      | ⏳ Planned          | —             | 2026-06-28   |

### Status Definitions

| Status                 | Description                                                                                                            |
| ---------------------- | ---------------------------------------------------------------------------------------------------------------------- |
| ✅ **Production**       | Fully implemented, tested, and used during normal operation.                                                           |
| 🚧 **Partial**         | Operational, but incomplete or requiring some manual intervention.                                                     |
| 🟨 **Manual Workflow** | Workflow is defined and usable, but still depends on manual operator steps.                                            |
| 🧱 **Database Only**   | Database schema exists, but no finished Home Assistant or Node-RED workflow exists for entering or reviewing the data. |
| ⏳ **Planned**          | Feature has been designed but has not yet been implemented.                                                            |
| ❌ **Retired**          | Legacy feature retained for historical reference only and should not be used for future development.                   |

---

# Current Working Features

Only two database workflows are currently considered working.

## 1. System Mode / Controller Events

The system can log operational events related to the patio hydroponics controller.

These events are stored in:

```sql
hydroponics_outside_events
```

This table is intended to become the active system event log for the outside hydroponics system.

It currently supports fields for:

* Event time
* System name
* Event type
* Notes
* Tank gallons
* Fill gallons
* EC before / after
* TDS voltage
* Dose A / B amounts
* Pump runtimes
* East and West flow rates
* HX711 raw value
* Event source

This table is the best current candidate for long-term system event logging.

---

## 2. EC/TDS Reference Measurements

The system can record manual handheld meter checks against the installed probe voltage.

These readings are stored in:

```sql
hydro_tds_reference_reading
```

This workflow is triggered from Home Assistant using the **Measure EC** dashboard button.

The workflow records:

* Timestamp
* System key
* Probe voltage
* Handheld meter value
* Meter units
* Tank gallons
* Water temperature
* Note

This table is used to validate whether the probe voltage continues to reasonably match handheld EC/TDS meter readings over time.

This is not a full calibration routine. It is a spot-check history used to detect drift or unexpected changes.

---

# Partially Built Areas

Several database areas exist, but are not yet fully integrated into the operating workflow.

## Dry Ingredient Purchases

Tables exist for purchase and ingredient tracking.

Current related tables include:

```sql
ingredients
purchases
purchase_items
dry_chem_purchases
dry_chem_purchases_legacy
purchases_legacy
```

The intent is to track the cost and quantity of dry nutrients such as:

* MasterBlend 4-18-38
* Calcium nitrate
* Magnesium sulfate / Epsom salt

However, there is not yet a clean Home Assistant or Node-RED workflow for entering new purchases.

Current status:

```text
Tables exist.
Some historical data may exist.
No finished operator workflow exists.
```

---

## Nutrient Batch Building

Tables exist for nutrient batch tracking.

Current related tables include:

```sql
nutrient_batches
nutrient_batch_items
nutrient_batches_legacy
nutrient_stock_solution
```

The intent is to track:

* When Part A and Part B stock solutions are mixed
* Which dry ingredients were consumed
* How much solution was produced
* How much stock solution remains
* Batch cost

However, batch creation is not yet a complete guided workflow.

Current status:

```text
Tables exist.
Some batch data exists.
Manual database work is still required.
```

---

## Inventory Ledger

The database includes an inventory ledger.

Current related table:

```sql
inventory_ledger
```

Supporting views include:

```sql
v_inventory_current
v_inventory_ledger_detail
v_inventory_low
v_ingredient_inventory
v_remaining_batch_capacity
```

The intent is to track inventory movement instead of directly editing remaining quantities.

Inventory should eventually be updated by events such as:

* Purchase
* Batch mixed
* Stock solution used
* Adjustment
* Waste / loss

Current status:

```text
Ledger structure exists.
Views exist.
Operator workflows are incomplete.
```

---

# Legacy / Historical Tables

## maintenance_log

The table:

```sql
maintenance_log
```

was an earlier attempt to create a general-purpose system history table.

It contains fields for:

* Fill events
* Dose events
* Batch events
* Purchase events
* Notes
* Harvest events
* Alerts

This table contains historical data, but it mixes too many concepts into one structure.

Current decision:

```text
Do not expand this table.
Do not use it as the future design.
Keep it as historical reference for now.
```

Future work may migrate useful rows into newer event or production tables.

---

## hydroponics_outside

The database object:

```sql
hydroponics_outside
```

is currently a broken legacy view referencing `maintenance_log`.

Current decision:

```text
Do not use this view for new work.
Replace or remove after new timeline views are created.
```

---

# Crop Management Direction

The project is expanding beyond controller automation.

The database needs to support crop production management by season.

New crop management tables have been started or planned:

```sql
hydro_season
crop_variety
hydro_position
hydro_season_planting
hydro_harvest
hydro_waste
```

These tables are intended to support:

* Growing seasons
* Physical plant positions
* East and West channel layouts
* Crop varieties
* Plant counts
* Harvest quantity
* Harvest weight
* Waste / plant loss
* Yield comparison by position
* Yield comparison by variety

This work is still early design and should not be treated as complete.

---

# Design Philosophy

The database should not just store raw logs.

It should support decisions.

The system should eventually answer questions such as:

* When was the last fill?
* When was the last dose?
* Why did the system dose?
* What were the system conditions at that time?
* Is the EC probe drifting?
* How fast are nutrients being consumed?
* How much stock solution remains?
* When will another nutrient batch be needed?
* What plants are growing in each position?
* Which plant varieties produced the most?
* Did East or West channel perform better?
* Did downstream plants underperform?
* What was the cost per pound harvested?

---

# Target Architecture

The long-term architecture should separate the system into major data areas.

## System Events

Operational events from the controller.

Examples:

* Auto dose
* Manual dose
* Fill
* Mode change
* Flow alarm
* Equipment problem
* EC reference check

Primary tables:

```sql
hydroponics_outside_events
hydro_tds_reference_reading
```

Future view:

```sql
v_hydro_system_timeline
```

---

## Inventory

Dry ingredients, purchases, stock solution batches, and usage.

Examples:

* Purchase MasterBlend
* Purchase calcium nitrate
* Mix Part A
* Mix Part B
* Use stock solution during dosing
* Adjust inventory after a spill or failed hose clamp

Primary tables:

```sql
ingredients
purchases
purchase_items
inventory_ledger
nutrient_batches
nutrient_batch_items
nutrient_stock_solution
```

---

## Crop Season

The crop layout for a growing season.

Examples:

* 2026 outside hydroponics season
* East Channel position E1
* West Channel position W5
* Empty positions
* Plant variety assignments

Primary tables:

```sql
hydro_season
hydro_position
crop_variety
hydro_season_planting
```

---

## Production

Harvests and waste.

Examples:

* Harvest 7 tomatoes from E5
* Total harvest weight 3.4 lb
* Discard 2 split tomatoes
* Remove failed plant

Primary tables:

```sql
hydro_harvest
hydro_waste
```

---

# Immediate Gaps

The database currently lacks complete operator workflows for several important tasks.

## Missing Workflows

The following workflows are needed:

```text
1. Enter dry ingredient purchase
2. Build nutrient batch
3. Top off stock solution container
4. Record inventory adjustment
5. Record equipment/problem event
6. View recent system history
7. View EC reference history
8. Create active season
9. Assign plants to positions
10. Record harvest
11. Record waste
```

Without these workflows, the database will continue to feel disjointed because data exists in tables but cannot be easily entered or reviewed.

---

# Dashboard Requirements

Home Assistant should not expose raw database tables.

The dashboard should provide task-based workflows.

Examples:

* Measure EC
* Log Event
* Mix Batch
* Add Purchase
* Record Harvest
* Record Waste
* View History
* View Inventory
* View Season Layout

The dashboard should make normal operation possible without opening DBeaver.

---

# Node-RED Requirements

Node-RED should become the workflow engine that writes to the database.

Node-RED should handle:

* Reading Home Assistant helper values
* Validating data
* Building SQL inserts
* Updating inventory ledgers
* Writing event records
* Publishing summary data back to Home Assistant

This keeps SQL logic out of the dashboard and makes workflows easier to debug.

---

# Recommended Implementation Order

The next work should focus on making the existing database usable before adding more analysis.

## Phase 1 — History Readback

Create a dashboard-accessible history view for:

* Recent system events
* Recent EC reference readings

Goal:

```text
Stop using DBeaver for routine history review.
```

---

## Phase 2 — Event Logging

Create a general event entry workflow for problems and manual notes.

This is needed for events such as:

* Hose clamp failure
* Bad dose
* Manual correction
* Equipment repair
* Unusual plant symptoms

Goal:

```text
Make important events easy to record when they happen.
```

---

## Phase 3 — Inventory Entry

Create workflows for:

* Purchase entry
* Batch building
* Stock solution tracking
* Inventory adjustment

Goal:

```text
Make dry ingredient and nutrient stock data trustworthy.
```

---

## Phase 4 — Season Layout

Create workflows for:

* Active season
* Plant positions
* Crop varieties
* Plant assignments

Goal:

```text
Connect production data to physical plant locations.
```

---

## Phase 5 — Harvest and Waste

Create workflows for:

* Harvest count
* Total harvest weight
* Waste count
* Waste weight
* Notes

Goal:

```text
Start tracking production and cost per pound.
```

---

## Phase 6 — Analytics

Create reports and dashboards for:

* Water usage
* Nutrient usage
* EC drift
* Inventory forecast
* Yield by variety
* Yield by channel
* Yield by position
* Cost per pound

Goal:

```text
Use the database to improve the system over future seasons.
```

---

# Current Conclusion

The database is not yet a complete system.

It contains several useful pieces, but only two workflows are currently reliable:

```text
1. Controller/system event logging
2. EC reference measurements
```

The rest of the database should be treated as a partially implemented foundation.

The next priority is not to add more tables. The next priority is to create reliable workflows for entering and viewing the data already modeled.

Once those workflows exist, the database can become the central management system for the hydroponic garden.
