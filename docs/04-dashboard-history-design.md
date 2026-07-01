# Dashboard and History Design

**Revision:** 0.3
**Last Updated:** 2026-07-01
**Status:** Active Design / Partial Implementation

---

# Purpose

The Home Assistant dashboard is intended to be the primary operator interface for the hydroponic vegetable garden.

Its purpose is to provide simple, task-oriented workflows for operating, monitoring, and maintaining the hydroponic system.

Routine operation should not require opening Node-RED, DBeaver, or MariaDB. Those tools are intended for development, engineering, and troubleshooting.

---

# Development Status

| Component                 | Status           | First Working | Last Updated |
| ------------------------- | ---------------- | ------------- | ------------ |
| Current Status Dashboard  | 🚧 Partial       | 2026-06-26    | 2026-06-28   |
| Controller Mode Selection | ✅ Production    | 2026-06-26    | 2026-06-28   |
| EC Reference Measurement  | ✅ Production    | 2026-06-28    | 2026-06-28   |
| Hydro-History Browser     | 🚧 Partial       | 2026-06-29    | 2026-07-01   |
| Event Annotation          | ✅ Production    | 2026-06-30    | 2026-07-01   |
| Inventory Dashboard       | ⏳ Planned       | —             | 2026-06-28   |
| Batch Building Workflow   | ⏳ Planned       | —             | 2026-06-28   |
| Harvest Dashboard         | ⏳ Planned       | —             | 2026-06-28   |

---

# Dashboard Philosophy

Every dashboard should answer three questions.

## 1. What is happening now?

Current operating conditions.

Examples:

* Tank volume
* Estimated EC
* Probe voltage
* Water temperature
* Flow rates
* Controller mode
* Pump status
* Automation status

---

## 2. What just happened?

Recent operational history.

Examples:

* Last fill
* Last nutrient dose
* Last EC reference check
* Last equipment event
* Last manual operation

The operator should never need DBeaver simply to determine recent system activity.

---

## 3. What needs attention?

The dashboard should highlight exceptions rather than overwhelming the operator with raw data.

Examples:

* Low inventory
* Batch nearly empty
* Flow alarm
* Sensor failure
* Equipment issue
* EC drift
* Upcoming nutrient batch requirement

---

# Dashboard Sections

The dashboard is expected to evolve into several functional areas.

## System Status

Daily operating information.

Examples:

* Tank level
* Estimated gallons
* Estimated EC
* Water temperature
* Flow rates
* Controller mode
* Pump status

---

## Recent Activity

Displays the most recent operational history.

Examples:

* Fill
* Dose
* Mode change
* EC reference measurement
* Equipment event
* Manual note

Initial implementation consists of a dedicated Hydro-History dashboard.

The History dashboard will be driven by Node-RED, which queries
`v_hydro_recent_activity`, formats the results, and provides them to
Home Assistant for display.

Planned capabilities include:

• Browse newest to oldest events
• Page forward/back through history
• Select an individual event
• Display complete event details
• Launch operator workflows from the selected event

---

## Event Details

Selecting an event should display all recorded information associated with that event.

Examples:

* Date and time
* Event type
* Tank gallons
* Fill amount
* Nutrient dose
* Probe voltage
* Estimated EC
* Water temperature
* Flow readings
* Notes

This allows investigation without manually querying the database.

# History Browser Roadmap

The Hydro-History dashboard is being implemented in stages.

## Phase 1 — Database Connectivity

* Verify Home Assistant connectivity to MariaDB.
* Verify `v_hydro_recent_activity` can be queried.
* Verify Node-RED can retrieve and format recent activity.

Status: ✅ Complete

---

## Phase 2 — History Browser

* Display recent activity in Home Assistant.
* Browse newer and older history.
* Select an event.
* Display complete event details.


## Phase 2a — Event Selection

* Browse recent history
* Page forward/back through history
* Step forward/back one record
* Select a source-aware activity record
* Populate operator editing controls
* Edit existing operator notes
* Save annotation back to the correct source table
* Automatically refresh the browser after save
  
Status: ✅ Complete

---

## Phase 3 — Operator Workflows

Selected events may initiate workflows such as:

* Create standalone field note
* Optional field note date override
* Field note location/area context
* Equipment issue workflow
* Maintenance completed workflow
* Event detail popup (optional)
  
Status: 🚧 Partial (Field Notes complete; additional workflows pending)

---

# Operator Workflows

The dashboard should guide the operator through common hydroponic tasks.

Implementation details are documented separately in:

* `node-red/README.md`
* `home-assistant/packages/README.md`
* `docs/01-database-design.md`

## Current Production Workflows

| Workflow                      | Status       | Purpose                                                                                     |
| ----------------------------- | ------------ | ------------------------------------------------------------------------------------------- |
| Measure EC                    | ✅ Production | Records a handheld EC/TDS reference measurement for comparison with the installed probe.    |
| Automatic Fill / Dose Logging | ✅ Production | Automatically records completed fill and nutrient dosing cycles in the maintenance history. |
| Standalone Field Note | ✅ Production | Creates a standalone NOTE event in `maintenance_log` with optional date and location context. |

## Planned Workflows

| Workflow             | Purpose                                                       |
| -------------------- | ------------------------------------------------------------- |
| Equipment Event      | Record maintenance, repairs, leaks, and equipment failures.   |
| Record Purchase      | Record nutrient purchases and automatically update inventory. |
| Build Nutrient Batch | Create stock solution batches and update inventory.           |
| Harvest Entry        | Record harvested produce by season and planting position.     |
| Waste Entry          | Record crop losses and discarded produce.                     |

---

# Event Annotation

Operator notes may be attached to supported Hydro-History activity records, including `maintenance_log` records and EC reference records from `hydro_tds_reference_reading`.

The selected activity stores both the activity source and source ID, such as `maintenance_log:52` or `ec_reference:5`, so notes are written back to the correct database table.

Operational events record **what** happened.

They do not always explain **why** it happened.

Example:

Two fill events occurring within a few minutes of each other may indicate an equipment problem.

The dashboard should allow additional information to be attached after the event has occurred.

Examples:

* Hose clamp failure
* Pump tubing slipped
* Sensor cleaned
* Leak repaired
* Incorrect manual dose
* Equipment replaced

The original operational event remains unchanged.

Only the dedicated operator_note field may be edited after the event has been recorded.

This preserves the measured operational data while allowing additional human context to be attached later.

Instead, they become additional historical information linked to that event.

---

# Example Investigation

Observed history:

```text
08:10  Fill
08:14  Fill
```

The operator recognizes that two fills should never occur within such a short period.

Selecting either event allows additional context to be recorded.

Example:

```text
Equipment Failure

The circulating pump hose clamp failed.

The system correctly performed two fill-and-dose operations; however, the failed hose clamp allowed the water and nutrients to be pumped onto the ground instead of remaining in circulation.

Both fill-and-dose cycles were therefore lost.

The hose clamp was replaced and normal operation resumed.
```

The explanation is stored in the `operator_note` field associated with the selected activity record and is displayed alongside the event within the Hydro-History browser.

Depending on the selected activity, the note may be stored in either `maintenance_log` or `hydro_tds_reference_reading`.
This preserves both:

* The original measurements
* The explanation discovered during troubleshooting

# Field Notes

Not all operator notes are tied to a specific event.

Some notes document general field observations, maintenance actions, crop conditions, or system changes that are useful to the season history.

Examples:

* Added another layer of support netting
* Plants outgrew first trellis layer
* Cleaned sensor probes
* Replaced pump tubing
* Adjusted plant spacing
* Observed pest pressure
* Noted heat stress
* Repaired leak before next cycle

Field notes should be recorded as their own `NOTE` events in `maintenance_log`.

Unlike event annotations, field notes do not need to reference an existing fill, dose, harvest, or purchase event.

This allows the history dashboard to show both:

* automated system events
* operator-entered observations

Together, they provide a more complete operating history than automation alone.

---

# Design Goals

The dashboard should allow the operator to answer questions such as:

* What happened today?
* Why did the system fill?
* Why did it dose?
* When was the last EC reference check?
* Is inventory running low?
* What equipment problems have occurred?
* Which nutrient batch is currently in use?
* Which crops are producing the most?

without writing SQL or opening database tools.

---

# Long-Term Vision

The dashboard should evolve from a collection of sensor cards into a complete hydroponic management interface.

Nearly every routine interaction with the hydroponic system should eventually occur through Home Assistant.

ESPHome will continue to provide real-time controller logic, Node-RED will execute workflow automation, and MariaDB will maintain the permanent historical record.

Direct database access should rarely be necessary outside of engineering, development, or troubleshooting.

---

# Revision History

| Date       | Revision | Description                                                                                                                                                                                                  |
| ---------- | -------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| 2026-07-01 | 0.3 | Added Hydro-History browser enhancements including source-aware activity selection, operator notes for both maintenance and EC reference records, standalone field notes with optional date/location context, EC reference water temperature display, and updated workflow documentation. |
| 2026-06-28 | 0.2      | Reorganized document around dashboard functionality, operator workflows, event history, and long-term design. Removed implementation details that are documented in the Node-RED and Home Assistant READMEs. |
