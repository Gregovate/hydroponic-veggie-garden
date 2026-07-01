# Node-RED Flows

Node-RED performs workflow logic for the hydroponics system.

The dashboard and ESPHome devices trigger events. Node-RED validates the event data, builds database records, and writes permanent history to MariaDB.

---

## Flow Inventory

| Flow File                 | Status         | Purpose                                                                                           |
| ------------------------- | -------------- | ------------------------------------------------------------------------------------------------- |
| `Hydroponics_Cycle_Manager.json` | ✅ Production | Logs fill/dose maintenance cycles from ESPHome switch activity.                                  |
| `TDS_Reference.json`      | ✅ Production  | Logs handheld EC/TDS reference checks from the Home Assistant Measure EC popup.                  |
| `db_history_browser.json` | 🚧 Partial     | Provides the Hydro-History browser, history navigation, event selection, and operator annotation. |

---

## Hydroponics Cycle Manager

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

**Flow File:** `db_history_browser.json`

**Database Target:** `v_hydro_recent_activity`

**Last Updated:** 2026-06-30

### Purpose

Provides the Hydro-History browser displayed in Home Assistant.

The flow retrieves operational history from MariaDB, formats the records for display, and publishes the results to Home Assistant through MQTT.

This allows routine investigation of historical events without opening DBeaver or manually executing SQL queries.

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
* Event selection
* Operator note editing
* Automatic browser refresh after note save

### Home Assistant Helpers

* `input_number.hydro_history_record_offset`
* `input_number.hydro_history_records_per_page`
* `input_text.hydro_history_selected_event_id`
* `input_text.hydro_history_operator_note`
* `input_button.hydro_history_save_operator_note`

### MQTT Topic

```text
hydro/history/recent
```

### Planned Features

* Create standalone field note
* Equipment issue workflow
* Maintenance completed workflow
* Event detail popup
* History filtering
* Search

---


## Change Log

| Date       | Flow                             | Change                                                                                                                                                                                              |
| ---------- | -------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 2026-06-30 | `db_history_browser.json` | Added history navigation, event selection, operator note editing, SQL update workflow, automatic browser refresh, and operator note display support. |
| 2026-06-29 | `db_history_browser.json`        | Initial Hydro-History browser. Added state-driven paging using Home Assistant helpers, MariaDB query of `v_hydro_recent_activity`, Markdown formatting, and MQTT publication for dashboard display. |
| 2026-06-28 | `Hydroponics_Cycle_Manager.json` | Repaired mode/event logging. Mode now comes from Home Assistant control mode. Fill+dose cycles log as `FILL`.                                                                                       |
| 2026-06-28 | `TDS_Reference.json`             | Added production EC reference capture workflow from Home Assistant popup to MariaDB.                                                                                                                |

