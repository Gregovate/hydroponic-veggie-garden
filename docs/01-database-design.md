# Hydroponics Database Design

**Revision:** 0.3
**Last Updated:** 2026-07-01
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

| Table                         | Status       | Purpose                                                           |
| ----------------------------- | ------------ | ----------------------------------------------------------------- |
| `maintenance_log`             | ✅ Production | Primary operational event history for fill and dose cycles.       |
| `hydro_tds_reference_reading` | ✅ Production | Handheld EC/TDS meter checks compared to installed probe voltage. |
| `ingredients`                 | 🚧 Partial   | Master list of dry nutrient ingredients.                          |
| `purchases`                   | 🚧 Partial   | Purchase header records.                                          |
| `purchase_items`              | 🚧 Partial   | Purchased ingredient line items.                                  |
| `inventory_ledger`            | 🚧 Partial   | Inventory movement history.                                       |
| `nutrient_batches`            | 🚧 Partial   | Nutrient stock batch headers.                                     |
| `nutrient_batch_items`        | 🚧 Partial   | Ingredients used in each nutrient batch.                          |
| `nutrient_stock_solution`     | 🚧 Partial   | Part A / Part B stock solution containers.                        |
| `hydro_season`                | ⏳ Planned    | Growing season records.                                           |
| `hydro_position`              | ⏳ Planned    | Permanent plant positions such as E1–E7 and W1–W6.                |
| `crop_variety`                | ⏳ Planned    | Crop variety master list.                                         |
| `hydro_season_planting`       | ⏳ Planned    | Season, position, and crop variety assignments.                   |
| `hydro_harvest`               | ⏳ Planned    | Harvest records.                                                  |
| `hydro_waste`                 | ⏳ Planned    | Waste and crop loss records.                                      |
| `stg_maintenance_csv`         | ❌ Legacy     | CSV import staging table.                                         |
| `purchases_legacy`            | ❌ Legacy     | Earlier purchase table.                                           |
| `dry_chem_purchases_legacy`   | ❌ Legacy     | Earlier dry chemical purchase table.                              |
| `nutrient_batches_legacy`     | ❌ Legacy     | Earlier nutrient batch table.                                     |

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

### Columns

| Column             | Type               | Notes                                                           |
| ------------------ | ------------------ | --------------------------------------------------------------- |
| `id`               | int auto_increment | Primary key                                                     |
| `timestamp_utc`    | datetime           | UTC event timestamp (legacy compatibility; not used for dashboard readback) |
| `internal_time`    | datetime           | Local event timestamp used by dashboards and history views       |
| `source`           | varchar(32)        | Usually `outside`                                               |
| `location`         | varchar(64)        | Usually `patio`                                                 |
| `crop`             | varchar(32)        | Legacy / future crop context                                    |
| `variety`          | varchar(64)        | Legacy / future variety context                                 |
| `device`           | varchar(64)        | Source device or workflow                                       |
| `event_type`       | enum               | `FILL`, `DOSE`, `BATCH`, `PURCHASE`, `NOTE`, `HARVEST`, `ALERT` |
| `mode`             | varchar(32)        | Auto / Manual / ESP-Override                                    |
| `system_gallons`   | float              | Tank/system gallons at event                                    |
| `gallons_added`    | float              | Water added                                                     |
| `dose_a_ml`        | float              | Nutrient Part A dose                                            |
| `dose_b_ml`        | float              | Nutrient Part B dose                                            |
| `tds_before`       | float              | Probe voltage before                                            |
| `tds_after`        | float              | Probe voltage after                                             |
| `ec_before`        | float              | Future EC value                                                 |
| `ec_after`         | float              | Future EC value                                                 |
| `plant`            | varchar(64)        | Legacy / future crop context                                    |
| `harvest_weight_g` | float              | Legacy harvest field                                            |
| `harvest_count`    | int                | Legacy harvest field                                            |
| `harvest_unit`     | varchar(16)        | Default `item`                                                  |
| `cost_usd`         | decimal(12,2)      | Legacy / future cost field                                      |
| `note`             | text               | Automatic event summary generated by Node-RED                   |
| `operator_note`    | text               | Optional operator-entered explanation for field notes           |
| `raw_message`      | text               | Raw JSON/message from workflow      

### Indexes

| Index               | Column          |
| ------------------- | --------------- |
| `PRIMARY`           | `id`            |
| `idx_ml_timestamp`  | `timestamp_utc` |
| `idx_ml_source`     | `source`        |
| `idx_ml_location`   | `location`      |
| `idx_ml_event_type` | `event_type`    |
| `idx_ml_crop`       | `crop`          |
| `idx_ml_variety`    | `variety`       |

### Event Notes

`maintenance_log` contains two different note fields with different purposes.

#### `note`

Automatically generated by the Hydroponics Cycle Manager.

This field records what occurred during the event and should normally not be edited.

Examples:

- auto FILL: added 11.37 gal water; dose A 114 mL...
- manual DOSE: dose A 90 mL; dose B 90 mL...

#### `operator_note`

Optional operator comment added after the event.

Used only when additional explanation is helpful, such as:

- equipment failures
- wasted fills
- sensor problems
- calibration issues
- unusual operating conditions

Most events will have a NULL `operator_note`.

Example:

```text
Fill wasted due to broken recirculating pump hose clamp. Nutrients discharged onto the patio instead of remaining in the reservoir.
```

---

## `hydro_tds_reference_reading`

**Status:** ✅ Production
**Purpose:** Stores handheld meter checks against installed TDS/EC probe voltage.
**Written By:** Node-RED `TDS_Reference.json`
**Started From:** Home Assistant Measure EC popup
**Read By:** `v_hydro_recent_activity`, future EC reference dashboard.

### Columns

| Column                         | Type                  | Notes                                               |
| ------------------------------ | --------------------- | --------------------------------------------------- |
| `id`                           | bigint auto_increment | Primary key                                         |
| `captured_at`                  | datetime              | Local reading timestamp                             |
| `system_key`                   | varchar(50)           | Default `outside`                                   |
| `probe_voltage`                | decimal(6,3)          | Installed probe voltage                             |
| `meter_value`                  | decimal(8,2)          | Handheld meter reading                              |
| `meter_units`                  | varchar(20)           | Usually `EC`                                        |
| `tank_gallons`                 | decimal(8,2)          | Tank gallons at reading                             |
| `water_temp_f`                 | decimal(6,2)          | Water temperature at reading, if available          |
| `rain_total_in`                | decimal(8,3)          | Cumulative rainfall total at time of EC reference   |
| `rain_since_last_reference_in` | decimal(8,3)          | Rainfall since the previous EC reference            |
| `estimated_rain_added_gal`     | decimal(8,3)          | Estimated rainwater added to reservoir              |
| `note`                         | varchar(255)          | Original EC reference note entered with the reading |
| `operator_note`                | varchar(255)          | Later annotation added from the Hydro-History app   |

### Indexes

| Index     | Column |
| --------- | ------ |
| `PRIMARY` | `id`   |

### Rainfall / Dilution Context

Rainfall can dilute the outdoor reservoir because part of the tank is exposed.

The EC reference workflow records cumulative rainfall at the time of each handheld EC measurement. It also calculates rainfall since the previous EC reference and estimates how many gallons of rainwater entered the reservoir.

This allows EC reference readings to be evaluated with:

- handheld EC
- probe voltage
- water temperature
- tank gallons
- rainfall since the previous EC reference
- estimated rainwater dilution

The estimated rain volume is calculated from the exposed tank opening defined in Home Assistant patio system constants.

# Partial Inventory and Nutrient Tables

## `ingredients`

**Status:** 🚧 Partial
**Purpose:** Master ingredient list for dry nutrients and other inventory items.
**Written By:** Manual SQL / future purchase workflow.
**Read By:** Purchase, inventory, and batch views.

### Columns

| Column            | Type               | Notes        |
| ----------------- | ------------------ | ------------ |
| `ingredient_id`   | int auto_increment | Primary key  |
| `ingredient_key`  | varchar(50)        | Unique key   |
| `ingredient_name` | varchar(100)       | Display name |
| `default_unit`    | varchar(20)        | Default `g`  |

### Indexes

| Index            | Column           |
| ---------------- | ---------------- |
| `PRIMARY`        | `ingredient_id`  |
| `ingredient_key` | `ingredient_key` |

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

**Status:** ⏳ Planned  
**Purpose:** Defines fixed planting positions in the outside hydroponics system.  
**Written By:** Manual setup / future layout workflow.  
**Read By:** Season planting, harvest, and waste workflows.

### Columns

| Column | Type | Notes |
|---|---|---|
| `position_id` | int auto_increment | Primary key |
| `system_key` | varchar(50) | Default `outside` |
| `channel` | varchar(20) | East / West |
| `position_code` | varchar(10) | Example `E1`, `W6` |
| `position_number` | int | Position number within channel |
| `flow_order` | int | Order in flow path |
| `active` | tinyint(1) | Active flag |
| `notes` | text | Notes |

### Indexes

| Index | Column |
|---|---|
| `PRIMARY` | `position_id` |
| `uq_hydro_position` | `system_key`, `position_code` |

---

## `crop_variety`

**Status:** ⏳ Planned  
**Purpose:** Master crop variety list.  
**Written By:** Future crop variety setup workflow.  
**Read By:** Season planting, harvest, and production reports.

### Columns

| Column | Type | Notes |
|---|---|---|
| `variety_id` | int auto_increment | Primary key |
| `crop_type` | varchar(50) | Example tomato, pepper |
| `variety_name` | varchar(100) | Variety name |
| `seed_source` | varchar(100) | Seed/source |
| `notes` | text | Notes |
| `active` | tinyint(1) | Active flag |
| `created_at` | datetime | Created timestamp |

### Indexes

| Index | Column |
|---|---|
| `PRIMARY` | `variety_id` |
| `uq_crop_variety` | `crop_type`, `variety_name` |

## `hydro_season_planting`

**Status:** ⏳ Planned  
**Purpose:** Assigns a crop variety to a specific planting position for a season.  
**Written By:** Future planting workflow.  
**Read By:** Harvest, waste, and production reporting.

### Relationships

- `season_id` → `hydro_season`
- `position_id` → `hydro_position`
- `variety_id` → `crop_variety`

### Columns

| Column | Type | Notes |
|---|---|---|
| `planting_id` | int auto_increment | Primary key |
| `season_id` | int | Growing season |
| `position_id` | int | Plant position |
| `variety_id` | int | Crop variety |
| `plant_count` | int | Normally 1 |
| `planted_date` | date | Date planted |
| `removed_date` | date | Date removed |
| `status` | enum | `planned`, `planted`, `removed`, `failed`, `empty` |
| `notes` | text | Notes |
| `created_at` | datetime | Created timestamp |

### Indexes

| Index | Column |
|---|---|
| `PRIMARY` | `planting_id` |
| `uq_season_position` | `season_id`, `position_id` |
| `fk_planting_position` | `position_id` |
| `fk_planting_variety` | `variety_id` |

### Business Rules

- A planting position may only be used once within a season.
- Historical plantings are never overwritten.

---

## `hydro_harvest`

**Status:** ⏳ Planned  
**Purpose:** Records harvested produce.  
**Written By:** Future harvest workflow.  
**Read By:** Harvest history, production reports, and cost analysis.

### Relationships

- `season_id` → `hydro_season`
- `planting_id` → `hydro_season_planting`

### Columns

| Column | Type | Notes |
|---|---|---|
| `harvest_id` | int auto_increment | Primary key |
| `season_id` | int | Growing season |
| `planting_id` | int | Plant harvested |
| `harvested_at` | datetime | Harvest date/time |
| `harvest_count` | int | Quantity harvested |
| `harvest_unit` | varchar(20) | Default `item` |
| `total_weight` | decimal | Total weight |
| `weight_unit` | enum | `lb`, `oz`, `g`, `kg` |
| `quality` | enum | `good`, `mixed`, `poor`, `waste` |
| `notes` | text | Notes |
| `created_at` | datetime | Created timestamp |

### Indexes

| Index | Column |
|---|---|
| `PRIMARY` | `harvest_id` |
| `fk_harvest_season` | `season_id` |
| `fk_harvest_planting` | `planting_id` |
| `idx_harvest_date` | `harvested_at` |

### Business Rules

- Every harvest belongs to one planting.
- Multiple harvests may exist for the same planting.

---

## `hydro_waste`

**Status:** ⏳ Planned  
**Purpose:** Records crop losses and discarded produce.  
**Written By:** Future waste workflow.  
**Read By:** Waste reports and production analytics.

### Relationships

- `season_id` → `hydro_season`
- `planting_id` → `hydro_season_planting`

### Columns

| Column | Type | Notes |
|---|---|---|
| `waste_id` | int auto_increment | Primary key |
| `season_id` | int | Growing season |
| `planting_id` | int | Optional planting reference |
| `wasted_at` | datetime | Date/time |
| `waste_type` | enum | `fruit_loss`, `plant_loss`, `disease`, `pest`, `damage`, `other` |
| `waste_count` | int | Quantity |
| `waste_weight` | decimal | Weight discarded |
| `weight_unit` | enum | `lb`, `oz`, `g`, `kg` |
| `reason` | text | Reason for loss |
| `notes` | text | Notes |
| `created_at` | datetime | Created timestamp |

### Indexes

| Index | Column |
|---|---|
| `PRIMARY` | `waste_id` |
| `fk_waste_season` | `season_id` |
| `fk_waste_planting` | `planting_id` |
| `idx_waste_date` | `wasted_at` |

### Business Rules

- Waste may be associated with a planting or recorded as a general system loss.
- Waste records should complement harvest records to support production efficiency analysis.

# Views

Views are used to simplify dashboard readback, reporting, and troubleshooting.

Views should not be treated as source data. Source data belongs in the base tables.

---

## `v_hydro_recent_activity`

**Status:** ✅ Production / New  
**Purpose:** Recent system activity timeline.

### Source Tables

- `maintenance_log`
- `hydro_tds_reference_reading`

### Used By

- Future Recent Activity dashboard
- DBeaver troubleshooting
- History readback

### Notes

This view is the current readback source for recent fill, dose, and EC reference activity.

For `maintenance_log`, `activity_time` is sourced from `internal_time` to provide local operator time.

---

## Inventory Views

| View | Status | Source Tables | Purpose |
|---|---|---|---|
| `v_inventory_current` | 🚧 Partial | `ingredients`, `inventory_ledger` | Current ingredient quantity. |
| `v_inventory_low` | 🚧 Partial | `v_inventory_current` | Low inventory warning. |
| `v_inventory_ledger_detail` | 🚧 Partial | `inventory_ledger`, `ingredients` | Ledger detail with ingredient names. |
| `v_ingredient_inventory` | 🚧 Partial | `ingredients`, `inventory_ledger` | Ingredient inventory summary. |
| `v_remaining_batch_capacity` | 🚧 Partial | `v_inventory_current` | Estimated nutrient batches possible. |

---

## Purchase Views

| View | Status | Purpose |
|---|---|---|
| `v_purchase_costs_ytd` | 🚧 Partial | Year-to-date purchase cost summary. |
| `v_unit_cost_per_item_ytd` | 🚧 Partial | Unit cost calculations. |
| `dry_chem_purchases` | ❌ Legacy | Old dry chemical purchase view. |

---

## Nutrient Batch Views

| View | Status | Source Tables | Purpose |
|---|---|---|---|
| `v_batch_recipe` | 🚧 Partial | `nutrient_batches`, `nutrient_batch_items`, `ingredients` | Batch recipe detail. |
| `v_nutrient_batches_detail` | 🚧 Partial | `nutrient_batches`, `nutrient_batch_items`, `ingredients` | Nutrient batch detail. |

---

## Production Views

| View | Status | Purpose |
|---|---|---|
| `v_harvests` | ⏳ Planned / Legacy Dependent | Harvest reporting. |
| `v_harvest_summary_ytd` | ⏳ Planned / Legacy Dependent | Year-to-date harvest summary. |

---

## Legacy Views

| View | Status | Notes |
|---|---|---|
| `hydroponics_outside` | ❌ Broken Legacy | Old view over maintenance data. Do not use for new dashboards or workflows. |

# Workflow Map

This section identifies which subsystem owns each workflow and which database objects it writes.

| Workflow                       | Started From                    | Processed By                              | Database Objects                                                                          | Status       |
| ------------------------------ | ------------------------------- | ----------------------------------------- | ----------------------------------------------------------------------------------------- | ------------ |
| Fill / Dose Cycle Logging      | ESPHome switch state changes    | Node-RED `Hydroponics_Cycle_Manager.json` | `maintenance_log`                                                                         | ✅ Production |
| EC / TDS Reference Measurement | Home Assistant Measure EC popup | Node-RED `TDS_Reference.json`             | `hydro_tds_reference_reading`                                                             | ✅ Production |
| Equipment Event Entry          | Home Assistant dashboard        | Future Node-RED workflow                  | `maintenance_log`                                                                         | ⏳ Planned    |
| Dry Ingredient Purchase        | Home Assistant dashboard        | Future Node-RED workflow                  | `purchases`, `purchase_items`, `inventory_ledger`                                         | ⏳ Planned    |
| Inventory Adjustment           | Home Assistant dashboard        | Future Node-RED workflow                  | `inventory_ledger`                                                                        | ⏳ Planned    |
| Nutrient Batch Building        | Home Assistant dashboard        | Future Node-RED workflow                  | `nutrient_batches`, `nutrient_batch_items`, `inventory_ledger`, `nutrient_stock_solution` | ⏳ Planned    |
| Stock Solution Top-Off         | Home Assistant dashboard        | Future Node-RED workflow                  | `nutrient_stock_solution`                                                                 | ⏳ Planned    |
| Season Setup                   | Home Assistant dashboard        | Future Node-RED workflow                  | `hydro_season`                                                                            | ⏳ Planned    |
| Planting Assignment            | Home Assistant dashboard        | Future Node-RED workflow                  | `hydro_season_planting`                                                                   | ⏳ Planned    |
| Harvest Entry                  | Home Assistant dashboard        | Future Node-RED workflow                  | `hydro_harvest`                                                                           | ⏳ Planned    |
| Waste Entry                    | Home Assistant dashboard        | Future Node-RED workflow                  | `hydro_waste`                                                                             | ⏳ Planned    |

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

| Date       | Revision | Description                                                                                                                                                                                                                                                                      |
| ---------- | -------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 2026-07-01 | 0.3 | Added `water_temp_f` and `operator_note` to `hydro_tds_reference_reading`. Updated Hydro-History design to support annotations on EC reference records and unified history browsing across multiple activity sources. |
| 2026-07-01 | 0.3      | Added Hydro-History browser support, documented operator notes, clarified the project timestamp standard, updated `v_hydro_recent_activity` to use local event time for dashboard readback, and corrected timestamp documentation for production workflows. |
| 2026-06-28 | 0.2      | Reorganized the document into a database reference. Added object inventory, table documentation, views, workflow ownership, and development priorities. Updated to reflect `maintenance_log` as the production event table after retirement of `hydroponics_outside_events`. |

---

## Navigation

**Previous:** [00 – System Overview](00-system-overview.md)

**Next:** [02 – Season & Layout](02-season-and-layout.md)