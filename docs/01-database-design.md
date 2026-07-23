# Hydroponics Database Design

**Revision:** 0.4
**Last Updated:** 2026-07-22
**Status:** Active Reference / Partial Implementation
---

# Purpose

The Hydroponics database is the permanent record for the outdoor hydroponic vegetable system.

This document identifies:

* What database objects currently exist
* What each object is used for
* What fields are available
* What writes data to each table
* What reads data from each table
* Which objects are production, partial, planned, or legacy

This document is the database reference.

Workflow implementation details belong in:

* `node-red/README.md`
* `home-assistant/packages/README.md`
* `docs/04-dashboard-history-design.md`

---

# Timestamp Standard

All operational timestamps in the Hydroponics database are stored in **local system time**.

The system is designed for a single physical installation and all history is viewed by the local operator.

Reasons:

- Simplifies SQL queries (`TODAY`, `THIS WEEK`, etc.)
- Dashboard times match the database without conversion
- Correlates directly with maintenance activities, photographs, weather, and inspection notes
- Eliminates unnecessary timezone conversions

UTC timestamps are not used within the Hydroponics database.

If cloud synchronization or multi-site support is implemented in the future, UTC conversion will occur during export rather than storage.

---

# Status Definitions

| Status           | Meaning                                                                |
| ---------------- | ---------------------------------------------------------------------- |
| ✅ Production     | Used during normal operation.                                          |
| 🚧 Partial       | Object exists and may contain useful data, but workflow is incomplete. |
| 🧱 Database Only | Schema exists, but no finished operator workflow exists.               |
| ⏳ Planned        | Designed for a future workflow.                                        |
| ❌ Legacy         | Retained only for historical reference or migration review.            |

---

# Current Production Workflows

| Workflow                       | Status       | Writes To                     | Started From                                     |
| ------------------------------ | ------------ | ----------------------------- | ------------------------------------------------ |
| Fill / Dose Cycle Logging      | ✅ Production | `maintenance_log`             | ESPHome switch activity through Node-RED         |
| EC / TDS Reference Measurement | ✅ Production | `hydro_tds_reference_reading` | Home Assistant Measure EC popup through Node-RED |

---

# Current Object Inventory

## Base Tables

| Table                         | Status         | Purpose                                                                |
| ----------------------------- | -------------- | ---------------------------------------------------------------------- |
| `maintenance_log`             | ✅ Production  | Primary operational event history for fill and dose cycles.            |
| `hydro_tds_reference_reading` | ✅ Production  | Handheld EC/TDS meter checks compared to installed probe voltage.      |
| `ingredients`                 | 🚧 Partial     | Master list of dry nutrient ingredients.                               |
| `purchases`                   | 🚧 Partial     | Purchase header records.                                               |
| `purchase_items`              | 🚧 Partial     | Purchased ingredient line items.                                       |
| `inventory_ledger`            | 🚧 Partial     | Inventory movement history.                                            |
| `nutrient_batches`            | 🚧 Partial     | Nutrient stock batch headers.                                          |
| `nutrient_batch_items`        | 🚧 Partial     | Ingredients used in each nutrient batch.                               |
| `nutrient_stock_solution`     | 🚧 Partial     | Part A / Part B stock solution containers.                             |
| `hydro_season`                | ✅ Implemented | Growing season records.                                                |
| `hydro_position`              | ✅ Production  | Permanent growing positions (E1–E7 and W1–W6).                         |
| `hydro_crop`                  | ✅ Implemented | Master list of crop types (Tomato, Pepper, Eggplant, etc.).            |
| `crop_variety`                | ✅ Implemented | Crop variety master list linked to a crop type.                        |
| `hydro_season_planting`       | ✅ Implemented | Assigns a crop variety to a permanent position for a growing season.   |
| `hydro_harvest`               | ✅ Implemented | Harvest records linked to the originating planting assignment.         |
| `hydro_waste`                 | ✅ Implemented | Waste and crop loss records linked to the originating planting.        |
| `stg_maintenance_csv`         | ❌ Legacy      | CSV import staging table.                                              |
| `purchases_legacy`            | ❌ Legacy      | Earlier purchase table.                                                |
| `dry_chem_purchases_legacy`   | ❌ Legacy      | Earlier dry chemical purchase table.                                   |
| `nutrient_batches_legacy`     | ❌ Legacy      | Earlier nutrient batch table.                                          |

## Views

| View                         | Status                       | Purpose                                                               |
| ---------------------------- | ---------------------------- | --------------------------------------------------------------------- |
| `v_hydro_recent_activity`    | ✅ Production / New           | Timeline view combining maintenance events and EC reference readings. |
| `v_inventory_current`        | 🚧 Partial                   | Current inventory quantity by ingredient.                             |
| `v_inventory_low`            | 🚧 Partial                   | Low inventory warning view.                                           |
| `v_inventory_ledger_detail`  | 🚧 Partial                   | Inventory transaction detail.                                         |
| `v_ingredient_inventory`     | 🚧 Partial                   | Ingredient inventory summary.                                         |
| `v_remaining_batch_capacity` | 🚧 Partial                   | Estimated nutrient batches possible from remaining dry stock.         |
| `v_purchase_costs_ytd`       | 🚧 Partial                   | Year-to-date purchase costs.                                          |
| `v_unit_cost_per_item_ytd`   | 🚧 Partial                   | Unit cost calculations.                                               |
| `v_batch_recipe`             | 🚧 Partial                   | Nutrient batch recipe detail.                                         |
| `v_nutrient_batches_detail`  | 🚧 Partial                   | Nutrient batch detail.                                                |
| `v_harvests`                 | ⏳ Planned / Legacy Dependent | Harvest reporting view.                                               |
| `v_harvest_summary_ytd`      | ⏳ Planned / Legacy Dependent | Year-to-date harvest summary.                                         |
| `dry_chem_purchases`         | ❌ Legacy View                | Old dry chemical purchase view.                                       |
| `hydroponics_outside`        | ❌ Broken Legacy View         | Old view over maintenance data. Do not use.                           |

---

# Active Production Tables

## `maintenance_log`

**Status:** ✅ Production
**Purpose:** Primary operational event history.
**Written By:** Node-RED `Hydroponics_Cycle_Manager.json`
**Read By:** `v_hydro_recent_activity`, future history dashboard.

### Important Rule

`maintenance_log` is the active production event table.

`hydroponics_outside_events` was dropped and is no longer part of the active schema.

### Design Notes

`maintenance_log` records completed operational events for the hydroponics
controller.

Each record captures the controller state at the time the event occurred,
including water movement, nutrient additions, and engineering measurements.

Beginning with the dual-probe measurement architecture, the table stores both
raw and filtered voltages for each analog probe channel. The handheld EC meter
remains the engineering reference standard and is recorded separately in
`hydro_tds_reference_reading`.

### Columns

| Column | Type | Notes |
|----------|------|------|
| `id` | int auto_increment | Primary key |
| `timestamp_utc` | datetime | UTC event timestamp (legacy compatibility) |
| `internal_time` | datetime | Local event timestamp used by dashboards |
| `source` | varchar(32) | Usually `outside` |
| `location` | varchar(64) | Usually `patio` |
| `crop` | varchar(32) | Reserved for future use |
| `variety` | varchar(64) | Reserved for future use |
| `device` | varchar(64) | Source device or workflow |
| `event_type` | enum | `FILL`, `DOSE`, `BATCH`, `PURCHASE`, `NOTE`, `HARVEST`, `ALERT` |
| `mode` | varchar(32) | Controller operating mode |
| `system_gallons` | float | System volume when event began |
| `gallons_added` | float | Water added during fill |
| `dose_a_ml` | float | Nutrient Part A added |
| `dose_b_ml` | float | Nutrient Part B added |
| `a0_raw_v_before` | float | A0 raw voltage before event |
| `a0_filtered_v_before` | float | A0 filtered voltage before event |
| `a1_raw_v_before` | float | A1 raw voltage before event |
| `a1_filtered_v_before` | float | A1 filtered voltage before event |
| `a0_raw_v_after` | float | A0 raw voltage after event |
| `a0_filtered_v_after` | float | A0 filtered voltage after event |
| `a1_raw_v_after` | float | A1 raw voltage after event |
| `a1_filtered_v_after` | float | A1 filtered voltage after event |
| `ec_before` | float | Reserved for future calculated EC |
| `ec_after` | float | Reserved for future calculated EC |
| `plant` | varchar(64) | Reserved for future use |
| `harvest_weight_g` | float | Harvest logging |
| `harvest_count` | int | Harvest logging |
| `harvest_unit` | varchar(16) | Default `item` |
| `cost_usd` | decimal(12,2) | Reserved for future use |
| `note` | text | Automatic event summary generated by Node-RED |
| `operator_note` | text | Optional operator-entered note |
| `raw_message` | text | Raw workflow payload retained for diagnostics |

### Indexes

| Index | Column |
|--------|--------|
| `PRIMARY` | `id` |
| `idx_ml_timestamp` | `timestamp_utc` |
| `idx_ml_source` | `source` |
| `idx_ml_location` | `location` |
| `idx_ml_event_type` | `event_type` |
| `idx_ml_crop` | `crop` |
| `idx_ml_variety` | `variety` |

### Voltage Measurement Fields

Beginning with the dual-probe engineering architecture, `maintenance_log`
stores independent measurements for each analog input channel.

Current assignments are:

| Channel | Current Assignment |
|----------|--------------------|
| **A0** | Original KEYESTUDIO analog probe |
| **A1** | DFRobot Gravity analog probe |

Each channel records both:

- Raw voltage (direct ADC measurement)
- Filtered voltage (used for controller operation and dashboard display)

For events that include post-event measurements (such as automatic fill),
both **Before** and **After** values are recorded.

Events that do not perform a delayed post-event measurement (such as individual
ESP-Override doses) may leave the **After** fields `NULL`.

### Event Notes

`maintenance_log` contains two note fields with different purposes.

#### `note`

Automatically generated by the Hydroponics Cycle Manager.

This field summarizes what occurred during the event and should normally not be edited.

Examples:

- auto FILL: added 5.11 gal water; dose A 51 mL; dose B 51 mL...
- esp-override DOSE: dose A 10 mL...
- manual NOTE: engineering observation...

#### `operator_note`

Optional operator comment added after the event.

Typical uses include:

- equipment failures
- wasted fills
- sensor problems
- calibration observations
- unusual operating conditions

Most events will have a `NULL` `operator_note`.

Example:

```text
Fill wasted due to broken recirculating pump hose clamp. Nutrients discharged
onto the patio instead of remaining in the reservoir.
```

---

## `hydro_tds_reference_reading`

**Status:** ✅ Production
**Purpose:** Stores handheld EC reference measurements synchronized with analog
probe voltages and operating conditions for calibration and engineering analysis.
**Written By:** Node-RED `TDS_Reference.json`
**Started From:** Home Assistant Measure EC popup
**Read By:** `v_hydro_recent_activity`, future EC reference dashboard.

### Design Notes

The handheld EC meter is the engineering reference standard.

Each record captures a synchronized snapshot of:

- Handheld EC measurement
- Analog probe voltages (A0 and A1)
- Water temperature
- Tank volume
- Rainfall and estimated dilution

These records are used to evaluate probe performance, develop EC estimation
models, and validate future automatic dosing algorithms.

### Columns

| Column | Type | Notes |
|--------|------|------|
| `id` | bigint auto_increment | Primary key |
| `captured_at` | datetime | Local reading timestamp |
| `system_key` | varchar(50) | Default `outside` |
| `a0_raw_v` | decimal(6,3) | A0 raw voltage |
| `a0_filtered_v` | decimal(6,3) | A0 filtered voltage |
| `a1_raw_v` | decimal(6,3) | A1 raw voltage |
| `a1_filtered_v` | decimal(6,3) | A1 filtered voltage |
| `meter_value` | decimal(8,2) | Handheld EC meter reading |
| `meter_units` | varchar(20) | Usually `EC` |
| `tank_gallons` | decimal(8,2) | Tank volume at measurement |
| `water_temp_f` | decimal(6,2) | Water temperature |
| `rain_total_in` | decimal(8,3) | Cumulative rainfall |
| `rain_since_last_reference_in` | decimal(8,3) | Rain since previous EC reference |
| `estimated_rain_added_gal` | decimal(8,3) | Estimated rainwater added |
| `note` | varchar(255) | Note entered during EC measurement |
| `operator_note` | varchar(255) | Later engineering annotation |

### Indexes

| Index | Column |
|--------|--------|
| `PRIMARY` | `id` |

### Analog Measurement Channels

Current channel assignments:

| Channel | Assignment |
|----------|------------|
| **A0** | Original KEYESTUDIO analog probe |
| **A1** | DFRobot Gravity analog probe |

Each EC reference captures both the raw ADC voltage and the filtered operating
voltage for each channel.

The filtered values are used by dashboards and engineering analysis, while the
raw values are retained for sensor characterization and future filter
development.

### Rainfall / Dilution Context

Rainfall can dilute the outdoor reservoir because part of the tank is exposed.

Each EC reference records cumulative rainfall at the time of the handheld
measurement. It also calculates rainfall since the previous EC reference and
estimates the amount of rainwater that entered the reservoir.

This allows EC reference measurements to be evaluated together with:

- handheld EC (engineering reference)
- A0 raw and filtered voltage
- A1 raw and filtered voltage
- water temperature
- tank volume
- rainfall since the previous EC reference
- estimated rainwater dilution

The estimated rain volume is calculated from the exposed tank opening defined
in the Home Assistant patio system constants.
---

## `purchases`

**Status:** 🚧 Partial
**Purpose:** Purchase header records for dry ingredients and supplies.
**Written By:** Manual SQL / future purchase workflow.
**Read By:** Purchase cost and inventory workflows.

### Columns

| Column            | Type               | Notes               |
| ----------------- | ------------------ | ------------------- |
| `purchase_id`     | int auto_increment | Primary key         |
| `order_number`    | varchar(50)        | Order number        |
| `purchase_date`   | date               | Purchase date       |
| `vendor`          | varchar(100)       | Default `Amazon`    |
| `total_price_usd` | decimal(10,2)      | Total purchase cost |
| `notes`           | text               | Notes               |
| `created_at`      | timestamp          | Created timestamp   |

### Indexes

| Index     | Column        |
| --------- | ------------- |
| `PRIMARY` | `purchase_id` |

---

## `purchase_items`

**Status:** 🚧 Partial
**Purpose:** Purchased ingredient line items.
**Written By:** Manual SQL / future purchase workflow.
**Read By:** Inventory ledger and purchase cost views.

### Columns

| Column             | Type               | Notes                  |
| ------------------ | ------------------ | ---------------------- |
| `purchase_item_id` | int auto_increment | Primary key            |
| `purchase_id`      | int                | Links to `purchases`   |
| `ingredient_id`    | int                | Links to `ingredients` |
| `quantity_lb`      | decimal(10,3)      | Quantity in pounds     |
| `quantity_g`       | decimal(10,2)      | Quantity in grams      |
| `item_price_usd`   | decimal(10,2)      | Item cost              |
| `notes`            | text               | Notes                  |
| `created_at`       | timestamp          | Created timestamp      |

### Indexes

| Index           | Column             |
| --------------- | ------------------ |
| `PRIMARY`       | `purchase_item_id` |
| `purchase_id`   | `purchase_id`      |
| `ingredient_id` | `ingredient_id`    |

---

## `inventory_ledger`

**Status:** 🚧 Partial
**Purpose:** Tracks dry ingredient inventory changes over time.
**Written By:** Manual SQL / future purchase, batch, and adjustment workflows.
**Read By:** Inventory views.

### Columns

| Column          | Type               | Notes                                     |
| --------------- | ------------------ | ----------------------------------------- |
| `ledger_id`     | int auto_increment | Primary key                               |
| `ledger_date`   | date               | Ledger event date                         |
| `ingredient_id` | int                | Links to `ingredients`                    |
| `event_type`    | enum               | `PURCHASE`, `BATCH_USE`, `RECONCILIATION` |
| `source_table`  | varchar(50)        | Source object name                        |
| `source_id`     | int                | Source record id                          |
| `delta_g`       | decimal(10,2)      | Inventory increase/decrease in grams      |
| `notes`         | text               | Notes                                     |
| `created_at`    | timestamp          | Created timestamp                         |

### Indexes

| Index           | Column          |
| --------------- | --------------- |
| `PRIMARY`       | `ledger_id`     |
| `ingredient_id` | `ingredient_id` |

---

## `nutrient_batches`

**Status:** 🚧 Partial
**Purpose:** Nutrient stock solution batch header.
**Written By:** Manual SQL / future batch-building workflow.
**Read By:** Nutrient batch views and stock solution tracking.

### Columns

| Column            | Type               | Notes             |
| ----------------- | ------------------ | ----------------- |
| `batch_id`        | int auto_increment | Primary key       |
| `batch_code`      | varchar(50)        | Unique batch code |
| `batch_date`      | date               | Batch date        |
| `batch_part`      | enum               | `A` or `B`        |
| `final_volume_ml` | decimal(10,2)      | Default `3785.00` |
| `notes`           | text               | Notes             |
| `created_at`      | timestamp          | Created timestamp |

### Indexes

| Index        | Column       |
| ------------ | ------------ |
| `PRIMARY`    | `batch_id`   |
| `batch_code` | `batch_code` |

---

## `nutrient_batch_items`

**Status:** 🚧 Partial
**Purpose:** Ingredients used in each nutrient batch.
**Written By:** Manual SQL / future batch-building workflow.
**Read By:** Batch recipe and inventory workflows.

### Columns

| Column          | Type               | Notes                       |
| --------------- | ------------------ | --------------------------- |
| `batch_item_id` | int auto_increment | Primary key                 |
| `batch_id`      | int                | Links to `nutrient_batches` |
| `ingredient_id` | int                | Links to `ingredients`      |
| `quantity_g`    | decimal(10,2)      | Quantity used               |
| `notes`         | text               | Notes                       |
| `created_at`    | timestamp          | Created timestamp           |

### Indexes

| Index           | Column          |
| --------------- | --------------- |
| `PRIMARY`       | `batch_item_id` |
| `batch_id`      | `batch_id`      |
| `ingredient_id` | `ingredient_id` |

---

## `nutrient_stock_solution`

**Status:** 🚧 Partial
**Purpose:** Tracks Part A and Part B stock solution container volumes.
**Written By:** Manual SQL / future batch-building and top-off workflows.
**Read By:** Future inventory and dosing dashboards.

### Columns

| Column               | Type               | Notes                         |
| -------------------- | ------------------ | ----------------------------- |
| `stock_solution_id`  | int auto_increment | Primary key                   |
| `stock_part`         | enum               | `A` or `B`                    |
| `created_date`       | date               | Created date                  |
| `source_batch_code`  | varchar(50)        | Source batch                  |
| `starting_volume_ml` | decimal(10,2)      | Starting volume               |
| `current_volume_ml`  | decimal(10,2)      | Current volume                |
| `status`             | enum               | `ACTIVE`, `EMPTY`, `ARCHIVED` |
| `notes`              | text               | Notes                         |
| `created_at`         | timestamp          | Created timestamp             |

### Indexes

| Index     | Column              |
| --------- | ------------------- |
| `PRIMARY` | `stock_solution_id` |

---

# Season, Planting, Harvest, and Waste Tables

## `hydro_season`

**Status:** ⏳ Planned  
**Purpose:** Defines growing seasons.  
**Written By:** Future season setup workflow.  
**Read By:** Planting, harvest, waste, and production reports.

### Columns

| Column | Type | Notes |
|---|---|---|
| `season_id` | int auto_increment | Primary key |
| `system_key` | varchar(50) | Default `outside` |
| `season_year` | int | Season year |
| `season_name` | varchar(100) | Display name |
| `start_date` | date | Start date |
| `end_date` | date | End date |
| `status` | enum | `planned`, `active`, `closed`, `archived` |
| `notes` | text | Notes |
| `created_at` | datetime | Created timestamp |

### Indexes

| Index | Column |
|---|---|
| `PRIMARY` | `season_id` |
| `uq_hydro_season` | `system_key`, `season_year` |

---

## `hydro_position`

**Status:** ✅ Production  
**Purpose:** Defines the permanent physical growing positions within the hydroponics system. Position records are independent of growing seasons and remain constant over time.  
**Written By:** Initial system configuration.  
**Read By:** Season planting, harvest, waste, dashboards, and production reporting.

### Columns

| Column | Type | Notes |
|--------|------|------|
| `position_id` | int auto_increment | Primary key |
| `system_key` | varchar(50) | Hydroponic system identifier. Default `outside`. |
| `channel` | varchar(20) | Growing channel (`East` or `West`) |
| `position_code` | varchar(10) | Permanent position identifier (E1–E7, W1–W6) |
| `position_number` | int | Position number within the channel |
| `flow_order` | int | Order of nutrient flow through the channel |
| `active` | tinyint(1) | Active position flag |
| `notes` | text | Optional notes |

### Relationships

Referenced by:

- `hydro_season_planting.position_id`

### Indexes

| Index | Type | Columns |
|--------|------|---------|
| `PRIMARY` | Primary Key | `position_id` |
| `uq_hydro_position` | Unique | `system_key`, `position_code` |

### Business Rules

- Position identifiers are permanent and never change.
- A position may participate in many growing seasons over time.
- Physical positions are assigned to seasons through `hydro_season_planting`.

---

## `hydro_crop`

**Status:** ✅ Implemented  
**Purpose:** Master list of supported crop types.  
**Written By:** Crop management workflow.  
**Read By:** Crop variety management, planting, harvest, waste, and production reporting.

### Columns

| Column | Type | Notes |
|--------|------|------|
| `crop_id` | int auto_increment | Primary key |
| `crop_name` | varchar(50) | Crop type (Tomato, Pepper, Eggplant, etc.) |
| `active` | tinyint(1) | Active crop flag |
| `notes` | text | Optional notes |
| `created_at` | datetime | Record creation timestamp |

### Relationships

Referenced by:

- `crop_variety.crop_id`

### Indexes

| Index | Type | Columns |
|--------|------|---------|
| `PRIMARY` | Primary Key | `crop_id` |
| `uq_hydro_crop_name` | Unique | `crop_name` |

---

## `crop_variety`

**Status:** ✅ Implemented  
**Purpose:** Stores reusable crop varieties associated with a crop type.  
**Written By:** Crop management workflow.  
**Read By:** Season planting, harvest, waste, and production reporting.

### Columns

| Column | Type | Notes |
|--------|------|------|
| `variety_id` | int auto_increment | Primary key |
| `crop_id` | int | References `hydro_crop` |
| `variety_name` | varchar(100) | Variety or cultivar name |
| `seed_source` | varchar(100) | Optional seed supplier or source |
| `notes` | text | Optional notes |
| `active` | tinyint(1) | Active variety flag |
| `created_at` | datetime | Record creation timestamp |

### Relationships

References:

- `hydro_crop.crop_id`

Referenced by:

- `hydro_season_planting.variety_id`

### Indexes

| Index | Type | Columns |
|--------|------|---------|
| `PRIMARY` | Primary Key | `variety_id` |
| `uq_crop_variety_crop_name` | Unique | `crop_id`, `variety_name` |
| `fk_crop_variety_crop` | Foreign Key | `crop_id` |

---

## `hydro_season_planting`

**Status:** ✅ Implemented  
**Purpose:** Assigns a crop variety to a permanent growing position for a specific growing season. This table forms the central relationship between seasons, positions, and crops.  
**Written By:** Planting workflow.  
**Read By:** Harvest, waste, dashboards, history, and production reporting.

### Columns

| Column | Type | Notes |
|--------|------|------|
| `planting_id` | int auto_increment | Primary key |
| `season_id` | int | References `hydro_season` |
| `position_id` | int | References `hydro_position` |
| `variety_id` | int | References `crop_variety`; `NULL` for empty positions |
| `plant_count` | int | Number of plants at this position |
| `planted_date` | date | Planting date |
| `removed_date` | date | Removal date |
| `status` | enum | `planned`, `planted`, `removed`, `failed`, `empty` |
| `notes` | text | Optional notes |
| `created_at` | datetime | Record creation timestamp |

### Relationships

References:

- `hydro_season.season_id`
- `hydro_position.position_id`
- `crop_variety.variety_id`

Referenced by:

- `hydro_harvest.planting_id`
- `hydro_waste.planting_id`

### Indexes

| Index | Type | Columns |
|--------|------|---------|
| `PRIMARY` | Primary Key | `planting_id` |
| `uq_hydro_season_position` | Unique | `season_id`, `position_id` |
| `fk_hydro_planting_position` | Foreign Key | `position_id` |
| `fk_hydro_planting_variety` | Foreign Key | `variety_id` |

### Business Rules

- Each physical position receives one planting assignment per growing season.
- Empty positions are represented by `status = 'empty'`, `variety_id = NULL`, and `plant_count = 0`.
- Harvest and waste records always reference the planting assignment rather than storing crop, variety, season, or position independently.

---

## `hydro_harvest`

**Status:** ✅ Production  
**Purpose:** Records harvested produce from a planting assignment. Multiple harvests may be recorded for the same planting throughout the growing season.  
**Written By:** Node-RED Harvest workflow.  
**Read By:** Hydro-History, harvest reporting, production analysis, and future cost analysis.

### Columns

| Column | Type | Notes |
|--------|------|------|
| `harvest_id` | int auto_increment | Primary key |
| `planting_id` | int | Required reference to `hydro_season_planting.planting_id` |
| `harvested_at` | datetime | Local harvest timestamp; defaults to the local database time |
| `harvest_count` | int nullable | Optional quantity harvested; stored as `NULL` when count was not entered |
| `harvest_unit` | varchar(20) | Unit associated with `harvest_count`; currently defaults to `item` |
| `total_weight` | decimal(10,3) nullable | Optional total harvested weight; stored as entered by the operator |
| `weight_unit` | enum | Operator-selected weight unit (lb, oz, g, kg); always populated |
| `quality` | enum nullable | Harvest classification: `good`, `mixed`, `poor`, or `waste`; the current Harvest workflow writes `good` |
| `notes` | text nullable | Optional operator note |
| `created_at` | datetime | Local record-creation timestamp; defaults to the local database time |

### Relationships

References:

- `hydro_season_planting.planting_id`

Foreign-key behavior:

- Updates to `planting_id` cascade to related harvest records.
- A planting assignment cannot be deleted while harvest records reference it.

### Indexes

| Index | Type | Columns |
|--------|------|---------|
| `PRIMARY` | Primary Key | `harvest_id` |
| `idx_hydro_harvest_planting` | Index | `planting_id` |
| `idx_hydro_harvest_date` | Index | `harvested_at` |

### Constraints

| Constraint | Type | Columns |
|------------|------|---------|
| `fk_hydro_harvest_planting` | Foreign Key | `planting_id` → `hydro_season_planting.planting_id` |

### Business Rules

- Every harvest belongs to one planting assignment.
- A planting may have multiple harvest records.
- Season, position, crop, and variety are derived through the planting assignment.
- Harvest count and harvest weight are independently optional.
- At least one of `harvest_count` or `total_weight` must be greater than zero before the workflow permits an insert.
- `harvest_unit` applies only to `harvest_count`.
- `weight_unit` applies only to `total_weight`.
- Harvest weight is stored in the unit selected by the operator; the workflow does not convert the value before insertion.
- `weight_unit` is always populated, even when `total_weight` is `NULL`, so the record has a defined unit if weight is added or edited later.
- The Harvest dashboard retains the last-selected weight unit after submission while clearing the planting, count, weight, and note fields.
- All operational timestamps are stored in local system time.

---

## `hydro_waste`

**Status:** ✅ Implemented  
**Purpose:** Records plant material or produce removed without being counted as harvested production.  
**Written By:** Waste tracking workflow.  
**Read By:** Waste reporting and production analytics.

### Columns

| Column | Type | Notes |
|--------|------|------|
| `waste_id` | int auto_increment | Primary key |
| `planting_id` | int | References `hydro_season_planting` |
| `wasted_at` | datetime | Waste timestamp |
| `waste_type` | enum | Classified waste reason |
| `waste_count` | int | Quantity discarded |
| `waste_weight` | decimal(10,3) | Total discarded weight |
| `weight_unit` | enum | `lb`, `oz`, `g`, `kg` |
| `reason` | text | Optional detailed explanation |
| `notes` | text | Optional notes |
| `created_at` | datetime | Record creation timestamp |

### Relationships

References:

- `hydro_season_planting.planting_id`

### Indexes

| Index | Type | Columns |
|--------|------|---------|
| `PRIMARY` | Primary Key | `waste_id` |
| `fk_hydro_waste_planting` | Foreign Key | `planting_id` |
| `idx_hydro_waste_date` | Index | `wasted_at` |
| `idx_hydro_waste_type` | Index | `waste_type` |

### Business Rules

- Every waste record belongs to one planting assignment.
- Season, position, crop, and variety are derived through the planting assignment.
- Waste records complement harvest records when evaluating production efficiency.

---

## `v_hydro_recent_activity`

**Status:** ✅ Production
**Purpose:** Unified recent activity timeline for operator dashboards and engineering history.
**Source:** MariaDB View

### Source Tables

- `maintenance_log`
- `hydro_tds_reference_reading`

### Used By

- Hydroponics History Browser
- Home Assistant Recent Activity dashboard
- Node-RED history readback
- DBeaver troubleshooting
- Future reporting and dashboard development

### Design Notes

`v_hydro_recent_activity` provides a single chronological readback source for
recent hydroponics activity regardless of where the information is stored.

The view normalizes multiple production tables into a common structure so the
dashboard and History Browser can display fills, doses, EC references, notes,
harvests, and future event types without requiring separate queries.

### Time Handling

For records originating from `maintenance_log`:

- `activity_time` is sourced from `internal_time`.

For records originating from `hydro_tds_reference_reading`:

- `activity_time` is sourced from `captured_at`.

Both values represent local operator time for dashboard display.

### Measurement Display

The view exposes engineering measurement fields appropriate for each event type.

Examples include:

- FILL
  - Water added
  - Dose A
  - Dose B
  - A0 Filtered Before → After
  - A1 Filtered Before → After

- DOSE
  - Dose A and/or Dose B
  - A0 Filtered Before
  - A1 Filtered Before

- EC_REFERENCE
  - Handheld EC
  - A0 Filtered
  - A1 Filtered
  - Tank gallons
  - Water temperature

The view intentionally exposes filtered voltages for operator display while raw
analog measurements remain available in the underlying production tables for
engineering analysis.

---

# Views

Views provide simplified readback for dashboards, reporting, and troubleshooting.

Views are not source data. Permanent records belong in the underlying base
tables.

## Operator History

### `v_hydro_recent_activity`

**Status:** ✅ Production  
**Purpose:** Provides the unified chronological activity feed used by the
Hydro-History dashboard.

The view combines supported operational records into one operator-facing
timeline. Applications should use this view whenever a chronological history
display is required rather than querying the underlying source tables
individually.

**Primary Consumers:**

- Home Assistant Hydro-History dashboard
- Node-RED history refresh workflow
- Operator troubleshooting and event review

**Important Rule:**

`v_hydro_recent_activity` is the authoritative readback interface for the
operator activity timeline. The underlying base tables remain the authoritative
source records.

---

## Inventory and Purchasing Views

| View | Status | Purpose |
|---|---|---|
| `v_inventory_current` | 🚧 Partial | Calculates the current quantity of each dry ingredient from inventory ledger activity. |
| `v_inventory_low` | 🚧 Partial | Identifies ingredients below their configured inventory threshold. |
| `v_inventory_ledger_detail` | 🚧 Partial | Provides inventory ledger entries with ingredient names and related detail. |
| `v_ingredient_inventory` | 🚧 Partial | Provides an ingredient-level inventory summary. |
| `v_remaining_batch_capacity` | 🚧 Partial | Estimates the number of nutrient batches that can be produced from current inventory. |
| `v_purchase_costs_ytd` | 🚧 Partial | Summarizes purchase costs for the current year. |
| `v_unit_cost_per_item_ytd` | 🚧 Partial | Calculates year-to-date unit costs from purchase records. |

---

## Nutrient Batch Views

| View | Status | Purpose |
|---|---|---|
| `v_batch_recipe` | 🚧 Partial | Provides the ingredient recipe for each nutrient batch. |
| `v_nutrient_batches_detail` | 🚧 Partial | Provides detailed nutrient batch records with ingredient information. |

---

## Production Reporting Views

| View | Status | Purpose |
|---|---|---|
| `v_harvests` | ⏳ Planned | Provides harvest records with derived season, position, crop, and variety information. |
| `v_harvest_summary_ytd` | ⏳ Planned | Summarizes current-year harvest production by crop and variety. |

The production views must be rebuilt against the normalized relationship:

```text
hydro_crop
    → crop_variety
        → hydro_season_planting
            → hydro_harvest
```

# Workflow Ownership Map

This section identifies the subsystem responsible for initiating and processing
each database-writing workflow.

The database is the permanent system of record. Home Assistant provides the
operator interface, ESPHome performs physical equipment control, and Node-RED
owns workflow validation, database writes, history refresh, and completion
notifications unless otherwise documented.

| Workflow | Initiated By | Processing Owner | Database Objects | Status |
|---|---|---|---|---|
| Fill / Dose Cycle Logging | ESPHome equipment state changes | Node-RED `Hydroponics_Cycle_Manager.json` | `maintenance_log` | ✅ Production |
| EC / TDS Reference Measurement | Home Assistant Measure EC form | Node-RED `TDS_Reference.json` | `hydro_tds_reference_reading` | ✅ Production |
| Equipment Event Entry | Home Assistant dashboard | Node-RED | `maintenance_log` | ⏳ Planned |
| Dry Ingredient Purchase | Home Assistant dashboard | Node-RED | `purchases`, `purchase_items`, `inventory_ledger` | ⏳ Planned |
| Inventory Adjustment | Home Assistant dashboard | Node-RED | `inventory_ledger` | ⏳ Planned |
| Nutrient Batch Building | Home Assistant dashboard | Node-RED | `nutrient_batches`, `nutrient_batch_items`, `inventory_ledger`, `nutrient_stock_solution` | ⏳ Planned |
| Stock Solution Top-Off | Home Assistant dashboard | Node-RED | `nutrient_stock_solution` | ⏳ Planned |
| Crop Management | Home Assistant dashboard | Node-RED | `hydro_crop`, `crop_variety` | ⏳ Planned |
| Season Setup | Home Assistant dashboard | Node-RED | `hydro_season` | ⏳ Planned |
| Planting Assignment | Home Assistant dashboard | Node-RED | `hydro_season_planting` | ⏳ Planned |
| Harvest Entry | Home Assistant dashboard | Node-RED | `hydro_harvest` | ⏳ Planned |
| Waste Entry | Home Assistant dashboard | Node-RED | `hydro_waste` | ⏳ Planned |                                                                           | ⏳ Planned    |

---

# Current Development Priorities

The database schema is largely complete.

Future development should focus on implementing operator workflows rather than adding new tables.

Current priorities are:

1. History Dashboard
2. Equipment Event Entry
3. Dry Ingredient Purchase Workflow
4. Nutrient Batch Building
5. Stock Solution Inventory Management
6. Inventory Adjustment Workflow
7. Season Setup
8. Planting Assignment
9. Harvest Entry
10. Waste Entry

---

# Revision History

| Date | Revision | Description |
|------|----------|-------------|
| 2026-07-22 | 0.4 | Refactored the engineering measurement model to support dual analog probe channels (A0/A1). Updated `maintenance_log`, `hydro_tds_reference_reading`, and `v_hydro_recent_activity` documentation to replace legacy single-probe terminology with raw and filtered voltage measurements. Expanded view documentation, clarified engineering data ownership, and documented the production readback architecture. |
| 2026-07-01 | 0.3 | Added `water_temp_f` and `operator_note` to `hydro_tds_reference_reading`. Updated Hydro-History design to support annotations on EC reference records and unified history browsing across multiple activity sources. |
| 2026-07-01 | 0.3 | Added Hydro-History browser support, documented operator notes, clarified the project timestamp standard, updated `v_hydro_recent_activity` to use local event time for dashboard readback, and corrected timestamp documentation for production workflows. |
| 2026-06-28 | 0.2 | Reorganized the document into a database reference. Added object inventory, table documentation, views, workflow ownership, and development priorities. Updated to reflect `maintenance_log` as the production event table after retirement of `hydroponics_outside_events`. |

---

## Navigation

**Previous:** [00 – System Overview](00-system-overview.md)

**Next:** [02 – Season & Layout](02-season-and-layout.md)