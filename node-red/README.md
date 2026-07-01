# Hydroponics Node-RED Workflows

**Revision:** 1.1
**Last Updated:** 2026-07-01
**Status:** Production

---

# Purpose

Node-RED is the workflow automation engine for the hydroponic system.

It receives events from Home Assistant and ESPHome, executes multi-step business logic, validates operational data, and records permanent historical information in MariaDB.

Node-RED coordinates workflows between the operator interface, the ESPHome controller, and the MariaDB database. Physical hardware control remains the responsibility of ESPHome, while Home Assistant provides the primary operator interface.

---

# Responsibilities

Node-RED is responsible for:

- Workflow automation
- Multi-step process execution
- Database transactions
- Hydro-History generation
- Historical event formatting
- MQTT publication
- Business logic
- Operator workflow processing

Node-RED is not responsible for:

- Physical hardware control
- Dashboard presentation
- Long-term data storage

---

## Flow Inventory

| Flow File                                | Status       | Purpose                                                                         |
| ---------------------------------------- | ------------ | ------------------------------------------------------------------------------- |
| `Flow-1_Hydroponics_Cycle_Manager.json`  | ✅ Production | Logs fill/dose maintenance cycles from ESPHome switch activity.                 |
| `Flow-2_TDS_Reference.json`              | ✅ Production | Logs handheld EC/TDS reference checks from the Home Assistant Measure EC popup. |
| `Flow-3_DB_History_Browser.json`         | ✅ Production | Retrieves and formats Hydro-History records for Home Assistant.                 |
| `Flow-4_Add_Note_to_Selected_Event.json` | ✅ Production | Updates operator notes for historical records from supported database sources.  |
| `Flow-5_Insert_Field_Note.json`          | ✅ Production | Creates standalone NOTE events with optional date and location metadata.        |


---

## Hydroponics Cycle Manager

**Flow File:** `Flow-1_Hydroponics_Cycle_Manager.json`
**Database Target:** `maintenance_log`
**Last Updated:** 2026-06-28

### Purpose

Combines these ESPHome switch events into one maintenance cycle record:

* Water fill solenoid
* Nutrient Pump A
* Nutrient Pump B

### Rules

* Control mode comes from `input_select.hydroponics_outside_control_mode`.
* Control mode is not hardcoded in Node-RED.
* If water was added, the cycle logs as `FILL`.
* If no water was added and nutrient pumps ran, the cycle logs as `DOSE`.
* Fill + dose cycles remain `FILL`.

### 2026-06-28 Repair

Fixed bad logging where an automatic fill-and-dose cycle was incorrectly recorded as:

```text
esp-override DOSE
```

The flow now derives:

```text
mode       = Home Assistant control mode
event_type = physical cycle result
```

---

## TDS / EC Reference

**Flow File:** `Flow-2_TDS_Reference.json`
**Database Target:** `hydro_tds_reference_reading`
**Last Updated:** 2026-06-28

### Purpose

Logs handheld EC/TDS reference checks against the installed probe voltage.

This is a validation check, not a full calibration routine.

### Dashboard Entry Point

Home Assistant button:

```text
Measure EC
```

The popup captures:

* Handheld meter reading
* Meter units
* Note
* Current probe voltage
* Tank gallons
* Water temperature, when available

---

## Hydro-History Browser

**Flow File:** `Flow-3_DB_History_Browser.json`
**Database Target:** `v_hydro_recent_activity`
**Last Updated:** 2026-07-01

### Purpose

Provides the Hydro-History browser displayed in Home Assistant.

The flow retrieves operational history from MariaDB, formats the records for display, and publishes the results to Home Assistant through MQTT.

The browser supports browsing operational history from multiple database sources, creating standalone field notes, and adding operator annotations to existing historical records without requiring manual SQL queries.

### Dashboard Entry Point

Home Assistant History Browser

### Current Features

* State-driven browser updates
* Dynamic records per page
* Dynamic record offset
* Single-record forward/back navigation
* Page forward/back navigation
* Automatic SQL query generation
* MariaDB history retrieval
* MQTT publication to Home Assistant
* Multi-source history browser
* Event selection
* Operator note editing
* Standalone field note creation
* Automatic browser refresh after note save
* Water temperature display for EC reference measurements

### Home Assistant Helpers

* `input_number.hydro_history_record_offset`
* `input_number.hydro_history_records_per_page`
* `input_text.hydro_history_selected_event_id`
* `input_text.hydro_history_operator_note`
* `input_text.hydro_history_field_note`
* `input_datetime.hydro_history_field_note_datetime`
* `input_select.hydro_history_field_note_location`
* `input_button.hydro_history_save_operator_note`
* `input_button.hydro_history_create_field_note`

### MQTT Topic

```text
hydro/history/recent
```

---

## Add Note to Selected Event

**Flow File:** `Flow-4_Add_Note_to_Selected_Event.json`

**Database Targets:** `maintenance_log`, `hydro_tds_reference_reading`

**Last Updated:** 2026-07-01

### Purpose

Updates operator annotations for existing Hydro-History records.

The flow determines the source table from the selected source-aware event identifier and updates the appropriate database record.

This allows historical events from multiple database tables to be annotated from a single Home Assistant interface.

### Dashboard Entry Point

Home Assistant History Browser

### Current Features

* Reads selected source-aware event identifier
* Reads operator note from Home Assistant
* Updates `maintenance_log.operator_note`
* Updates `hydro_tds_reference_reading.operator_note`
* Clears operator note helper after save
* Automatically refreshes the Hydro-History browser

### Home Assistant Helpers

* `input_text.hydro_history_selected_event_id`
* `input_text.hydro_history_operator_note`
* `input_button.hydro_history_save_operator_note`

### Supported Record Sources

* `maintenance_log`
* `hydro_tds_reference_reading`

---

## Insert Field Note

**Flow File:** `Flow-5_Insert_Field_Note.json`

**Database Target:** `maintenance_log`

**Last Updated:** 2026-07-01

### Purpose

Creates standalone field notes that are stored as `NOTE` events in the `maintenance_log` table.

Unlike operator notes, field notes create a new historical record that can document observations, maintenance activities, weather conditions, equipment issues, or other operational events not associated with an existing history record.

### Dashboard Entry Point

Home Assistant History Browser

### Current Features

* Creates standalone `NOTE` events
* Optional event date override
* Optional location selection
* Uses current save time for timestamp
* Stores notes in `maintenance_log`
* Clears helper entities after save
* Automatically refreshes the Hydro-History browser

### Home Assistant Helpers

* `input_text.hydro_history_field_note`
* `input_datetime.hydro_history_field_note_datetime`
* `input_select.hydro_history_field_note_location`
* `input_button.hydro_history_create_field_note`

### Default Values

| Field | Default |
| ----- | ------- |
| Source | `outside` |
| Device | `home_assistant` |
| Event Type | `NOTE` |
| Mode | `manual` |

---

# Planned Workflows

* Equipment issue workflow
* Maintenance completed workflow
* Event detail popup
* History filtering
* Search

---

# Revision History

| Date       | Flow                                    | Change |
| ---------- | --------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 2026-07-01 | `Flow-5_Insert_Field_Note.json`         | Initial production workflow. Added standalone field note creation with optional event date, location selection, automatic helper clearing, and Hydro-History browser refresh. |
| 2026-07-01 | `Flow-4_Add_Note_to_Selected_Event.json`| Initial production workflow. Added source-aware operator note updates supporting both `maintenance_log` and `hydro_tds_reference_reading`, automatic helper clearing, and Hydro-History browser refresh. |
| 2026-07-01 | `Flow-3_DB_History_Browser.json`        | Completed Hydro-History browser. Added multi-source history support, source-aware event selection, EC reference integration, water temperature display, standalone field note support, and browser refresh improvements. |
| 2026-06-29 | `Flow-3_DB_History_Browser.json`        | Initial Hydro-History browser. Added state-driven paging using Home Assistant helpers, MariaDB query of `v_hydro_recent_activity`, formatting, and MQTT publication for dashboard display. |
| 2026-06-28 | `Flow-1_Hydroponics_Cycle_Manager.json` | Repaired mode/event logging. Mode now comes from Home Assistant control mode. Fill+dose cycles log as `FILL`. |
| 2026-06-28 | `Flow-2_TDS_Reference.json`             | Added production EC reference capture workflow from the Home Assistant Measure EC popup to MariaDB. |

---

# Navigation

## Engineering Manual

- [System Overview](../docs/00-system-overview.md)
- [Dashboard & History Design](../docs/04-dashboard-history-design.md)
- [Nutrient Management & EC Control](../docs/05-nutrient-management-and-ec-control.md)

## Component Documentation

- [ESPHome](../esphome/README.md)
- [Home Assistant Packages](../home-assistant/packages/README.md)
- [SQL](../sql/README.md)