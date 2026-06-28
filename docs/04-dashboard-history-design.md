# Dashboard and History Design

**Revision:** 0.1
**Last Updated:** 2026-06-28
**Status:** Active Design

---

# Purpose

The Home Assistant dashboard is intended to be the primary operator interface for the hydroponic vegetable garden.

Its purpose is not to expose database tables or engineering data. Instead, it should provide simple workflows for operating, monitoring, and maintaining the hydroponic system.

Whenever possible, routine operation should be possible without opening Node-RED, DBeaver, or MariaDB.

---

## Development Status

| Component                 | Status       | First Working | Last Updated |
| ------------------------- | ------------ | ------------- | ------------ |
| Current Status Dashboard  | 🚧 Partial   | 2026-06-26    | 2026-06-28   |
| Controller Mode Selection | ✅ Production | 2026-06-26    | 2026-06-28   |
| EC Reference Measurement  | ✅ Production | 2026-06-28    | 2026-06-28   |
| History Dashboard         | ⏳ Planned    | —             | 2026-06-28   |
| Event Annotation          | ⏳ Planned    | —             | 2026-06-28   |
| Inventory Dashboard       | ⏳ Planned    | —             | 2026-06-28   |
| Batch Building Workflow   | ⏳ Planned    | —             | 2026-06-28   |
| Harvest Dashboard         | ⏳ Planned    | —             | 2026-06-28   |

---

# Dashboard Philosophy

The dashboard should answer three questions.

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

Recent history.

Examples:

* Last fill
* Last nutrient dose
* Last EC reference check
* Last manual event
* Last alert

The operator should not need DBeaver to answer these questions.

---

## 3. What needs attention?

Examples:

* Low inventory
* Batch nearly empty
* Flow alarm
* Failed sensor
* Equipment issue
* EC drift
* Upcoming batch requirement

The dashboard should focus attention on exceptions instead of raw data.

---

# Dashboard Sections

The dashboard is expected to grow into several functional areas.

## System Status

Daily operating information.

Examples:

* Tank level
* Estimated gallons
* EC estimate
* Water temperature
* Flow rates
* Controller mode
* Pump status

---

## Recent Activity

Displays the most recent operational events.

Examples:

* Fill
* Dose
* Mode change
* EC reference measurement
* Manual note
* Equipment event

Initial display should show approximately the five most recent events.

Future versions should allow paging through older history.

---

## Event Details

Selecting an event should display all recorded information.

Examples:

* Time
* Event type
* Tank gallons
* Fill amount
* Dose amount
* Probe voltage
* Estimated EC
* Water temperature
* Flow rates
* Notes

This allows investigation without manually querying the database.

---

# Event Annotation

Operational events record what occurred.

However, they do not always explain why something happened.

Example:

Two fill events occurring within a few minutes of each other may indicate a problem.

The dashboard should allow an operator to attach additional information after the event has occurred.

Examples:

* Hose clamp failure
* Pump tubing slipped
* Sensor cleaned
* Leak repaired
* Incorrect manual dose
* Equipment replaced

These annotations provide context that may not have been available when the original event was recorded.

Annotations should never overwrite the original event record.

Instead, they become additional historical information linked to that event.

---

# Example Investigation

Observed history:

```text
08:10 Fill
08:14 Fill
```

The operator recognizes that two fills should never occur within such a short period.

Selecting either event should allow additional context to be recorded.

Example annotation:

```text
Equipment Failure

The circulating pump hose clamp failed.

The system correctly performed two fill-and-dose operations; however, due to the failed circulating pump hose clamp, the water and nutrients were pumped onto the ground instead of remaining in circulation.

The reservoir did not retain the intended water or nutrients, resulting in the loss of both fill-and-dose cycles.

The hose clamp was replaced and the system returned to normal operation.
```

This preserves both:

* the original measurements
* the explanation discovered later

---

# Operator Workflows

The dashboard should eventually provide simple workflows for common operations.

## Measure EC

Current status:

✅ Implemented

Workflow:

Measure EC

↓

Enter handheld meter reading

↓

Save reference

---

## Log Equipment Event

Future workflow.

Examples:

* Leak
* Broken hose
* Failed pump
* Sensor replacement
* Repair

---

## Record Purchase

Future workflow.

Examples:

* MasterBlend
* Calcium nitrate
* Magnesium sulfate

The workflow should update inventory without requiring SQL.

---

## Build Nutrient Batch

Future workflow.

Examples:

* Select recipe
* Verify inventory
* Record batch
* Update stock solution inventory

---

## Record Harvest

Future workflow.

Examples:

* Select season
* Select planting position
* Enter quantity
* Enter total weight
* Save harvest

---

## Record Waste

Future workflow.

Examples:

* Plant loss
* Fruit loss
* Disease
* Pest damage
* Mechanical damage

---

# Design Goals

The dashboard should make routine operation simple.

The operator should be able to answer questions such as:

* What happened today?
* Why did the system fill?
* Why did it dose?
* When was the last EC check?
* Is inventory running low?
* What equipment problems have occurred?
* Which nutrient batch is currently in use?
* What plants are producing the most?

without using DBeaver or writing SQL.

---

# Long-Term Vision

The dashboard should evolve from a collection of sensor cards into a complete hydroponic management interface.

Eventually, nearly every interaction with the hydroponic system should occur through Home Assistant, with Node-RED performing workflow automation and MariaDB maintaining the permanent historical record.

The operator should rarely need direct access to the database except for engineering or troubleshooting purposes.

---

# Revision History

| Date       | Revision | Description                                                                                                                               |
| ---------- | -------- | ----------------------------------------------------------------------------------------------------------------------------------------- |
| 2026-06-28 | 0.1      | Initial dashboard and history design document. Defines dashboard philosophy, history review, operator workflows, and long-term direction. |
