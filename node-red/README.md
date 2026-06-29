# Node-RED Flows

Node-RED performs workflow logic for the hydroponics system.

The dashboard and ESPHome devices trigger events. Node-RED validates the event data, builds database records, and writes permanent history to MariaDB.

---

## Flow Inventory

| Flow File                        | Status       | Purpose                                                                         |
| -------------------------------- | ------------ | ------------------------------------------------------------------------------- |
| `Hydroponics_Cycle_Manager.json` | ✅ Production | Logs fill/dose maintenance cycles from ESPHome switch activity.                 |
| `TDS_Reference.json`             | ✅ Production | Logs handheld EC/TDS reference checks from the Home Assistant Measure EC popup. |

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

## Change Log

| Date       | Flow                             | Change                                                                                                        |
| ---------- | -------------------------------- | ------------------------------------------------------------------------------------------------------------- |
| 2026-06-28 | `Hydroponics_Cycle_Manager.json` | Repaired mode/event logging. Mode now comes from Home Assistant control mode. Fill+dose cycles log as `FILL`. |
| 2026-06-28 | `TDS_Reference.json`             | Added production EC reference capture workflow from Home Assistant popup to MariaDB.                          |
