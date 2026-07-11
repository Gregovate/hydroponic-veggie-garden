# Auto Fill Validation & Debug Log
**Date:** 2026-07-04

> **Purpose**
>
> This is a working engineering log. Nothing in this document is considered
> permanent design documentation until the issue is fixed and verified.
> Items are intentionally recorded as observations, theories, bugs, and
> action items. Once verified, the permanent documentation will be updated.

---

# Test Objective

Validate the complete automatic fill cycle after changing the delay from 2 minutes to 30 minutes.

Test included:

- Auto-fill trigger
- 5-minute debounce
- 30-minute dwell
- Automatic fill
- Automatic nutrient dosing
- Notifications
- Event logging
- Inventory tracking
- Manual ESP Override dosing
- EC correction

---

# Successful Results

## PASS - Auto Fill Trigger

- Tank dropped below threshold.
- 5-minute debounce worked.
- Auto Fill Scheduled notification generated.

Status: ✅ VERIFIED

---

## PASS - 30 Minute Delay

- Fill started after approximately 30 minutes.

Status: ✅ VERIFIED

---

## PASS - Automatic Fill

- Fill started automatically.
- Fill stopped correctly.
- Approximately 9.85 gallons added.

Status: ✅ VERIFIED

---

## PASS - Flow Meter Calibration Verification

### Purpose

Verify that reverting the fill flow meter calibration back to **1690 pulses/gal**
corrected the fill volume reporting error discovered during the previous auto-fill.

### Previous Test (2026-06-28)

Tank Volume (start): 10.7 gal

Tank Volume (end): 20.4 gal

Database Record:

- Water Added: 11.37 gal
- Dose A: 114 mL
- Dose B: 114 mL

### Conclusion

Flow meter calibration was determined to be over-reporting the amount of water added.

A separate **1-gallon manual water addition** was performed and confirmed that the
tank volume calculation is reasonable. This isolated the issue to the flow meter
calibration rather than the tank volume calculation.

### Action - Investigate ESPHome Flow Meter Calibration

See:

- `esphome/hydroponics-patio-esp32.yaml`
  - Flow Meter Calibration comments dated **2026-06-28**

### Today's Verification (2026-07-04)

Tank Volume (start): 11.1 gal

Tank Target: 21.0 gal

Expected Fill: 9.9 gal

Flow Meter Recorded: 9.85 gal

Tank Volume (end): 20.6 gal

### Result

✅ **PASS**

The reverted **1690 pulses/gal** calibration produced a measured fill within **0.05 gallons** of the expected fill. The previous calibration issue is considered resolved.

Status: VERIFIED

---

## EC Calibration

During auto-fill validation, additional EC reference data was collected.

See:

`docs/calibration-maintenance-debug/EC_TDS_CALIBRATION_HISTORY.md`

Reason:

The automatic fill dose restored nutrients proportional to the water added but
did not restore the tank to the target EC of 2.0. A manual correction was
required to obtain another calibration reference point.

# Calibration History From This Test

| Time | Event | Tank | Probe | Handheld EC |
|------|------|------:|------:|------------:|
| 09:10 | Before fill | 11.7 gal | 1.799 V | 1.70 |
| 12:59 | After auto fill | 20.6 gal | 1.752 V | 1.60 |
| 13:37 | Before correction | 20.6 gal | 1.774 V | 1.70 |
| 14:17 | After +50/+50 mL | 20.5 gal | 1.961 V | 2.00 |

---

# Decisions Made Today

- Maintenance Auto Dose remains disabled.
- Auto Fill controller successfully completed validation.
- Fill dosing remains proportional to gallons added until further evidence suggests otherwise.
- EC correction should continue using post-fill maintenance dosing.
- Permanent documentation will NOT be updated until all fixes are implemented and verified.

---

# Working Action List

## HIGH

- [ ] Repair Event History Dashboard
- [ ] Fix Auto Fill Logged notification values
- [ ] Fix Maintenance notification tank volume
- [ ] Determine inventory update sequence
- [ ] Redesign Maintenance Auto Dose controller
- [ ] Add Controller State indicator
- [ ] Investigate Manual ESP Override anomaly

## MEDIUM

- [ ] Fix duplicate notifications
- [ ] Improve dashboard status cards
- [ ] Improve Event Notes
- [ ] Improve event rendering by event type

---

# Notes

This document is intentionally a working engineering notebook.

Nothing contained here should be considered permanent design documentation until each issue has been fixed, tested, and verified.

---

# Issues Discovered

## ISSUE-001 - Event History Dashboard / Formatter

### Problem

The Browse for Event cards were using a generic formatter that displayed
irrelevant fields for different event types.

Examples:

- EC_REFERENCE displayed Fill 0.00 gal and Dose 0 mL.
- NOTE events displayed unrelated fill information.
- Event titles did not clearly identify the type of operation performed.

### Changes Made

- Added event-type-specific formatting in the Node-RED
  **Format Recent Activity** function.
- Updated `v_hydro_recent_activity` to expose `meter_value`
  and `meter_units` for EC reference events.
- EC_REFERENCE cards now match the EC Reference History display.
- NOTE events now display only note-related information.

### Enhancement Requested

Improve event titles to identify the operation performed rather than only
displaying the generic event type.

Examples:

Current:

```
#59 — DOSE
```

Preferred:

```
#59 — Auto Fill
#60 — Manual Fill
#61 — ESP-Override Dose
#62 — Auto Maintenance Dose
#63 — EC Reference
#64 — Field Note
```

The event title should immediately identify the workflow that created the
record while preserving the event number.

### Status

🟡 PARTIALLY COMPLETE

Formatting issues have been corrected.

Event title naming remains to be implemented.

---

## ISSUE-002 - Auto Fill Completion Notifications

Priority: HIGH

### Observed

The automatic fill completed successfully, but the completion notifications
contained inconsistent information.

### Notifications Received (Newest First)

#### Maintenance Cycle Complete

(Source: Node-RED Flow-1 Hydroponics Cycle Manager)

```
auto FILL completed

Water Added: 9.85 gal
Dose A: 98 mL
Dose B: 98 mL
System Volume: 11.1 gal
TDS: 1.800 → 1.751
```

Issues:

- Water added is correct.
- Dose A/B values are correct.
- **System Volume is incorrect.**
  - Reported: **11.1 gal**
  - Expected: **20.5–20.6 gal** (post-fill volume)

---

#### 🤖 Auto Fill Logged

```
9.85 gallons filled
Mode: Auto

Dose A: 0.0 mL
Dose B: 0.0 mL
```

Issues:

- Water added is correct.
- Dose values are incorrect.
- This notification may no longer provide useful information now that the
  Maintenance Cycle Complete notification contains more complete information.

---

#### 🤖 Auto Fill Scheduled

```
Tank is low (11.2 gal)...

Auto fill will begin...
```

This notification behaved as expected and should be retained.

### Current Interpretation

The fill itself executed correctly.

The problems appear to be in the notification data rather than the controller.

Evidence suggests different notifications are using different snapshots of the
controller state.

Examples:

- Water Added appears to be correct.
- Dose values are correct in one notification but zero in another.
- System Volume is using the pre-fill value instead of the final tank volume.

This suggests the notifications are being generated at different points in the
workflow or are reading different entities.

### Fill Cycle Entity Inventory

| Entity | Purpose | Current Status | Notes |
|---------|----------|---------------|------|
| sensor.outside_tank_gallons | Current calculated tank volume | ✅ Active | Used before and after fill. |
| sensor.outside_filtered_tank_gallons | Legacy filtered tank volume | ⚠ Investigate | Used last year when the scale was noisy. Current HX711 data appears stable enough that this may no longer be needed. |
| input_number.tank_full_target | Target full tank volume | ✅ Active | Used to determine fill target. |
| input_number.auto_fill_threshold_gallons | Auto-fill trigger threshold | ✅ Active | Starts 5-minute debounce. |
| input_number.outside_manual_fill_gallons | Requested fill amount | ✅ Active | Manual fill target. |
| sensor.hydroponics_patio_esp32_fill_gallons | ESP flow meter total during fill | ✅ Active | Resets after fill. Represents water added. |
| sensor.hydroponics_patio_esp32_last_fill_gallons | Last fill amount | ⚠ Unknown | Lost after ESP reboot. Candidate to replace with HA helper. |
| input_datetime.auto_fill_threshold_crossed_at | Low tank detected | ✅ Active | Used for debounce timing. |
| input_datetime.outside_tank_fill_started | Fill start timestamp | ✅ Active | Last updated 2026-07-04 12:39:07. |
| input_datetime.outside_tank_fill_stopped | Fill stop timestamp | ✅ Active | Last updated 2026-07-04 12:41:07. |
| sensor.outside_tank_last_fill_duration | Last fill duration | ✅ Active | Derived from timestamps. |
| automation.outside_tank_fill_log_and_notify_auto_only | Main Auto Fill workflow | ✅ Active | Primary automation under investigation. |
| automation.pre_fill_manual_dose_a_b_based_on_target_gallons | Pre-fill nutrient dose | ✅ Active | Runs before fill. |
| automation.esp_override_tank_fill_log | ESP Override fill logging | ✅ Active | Manual/ESP override workflow. |
| automation.outside_tank_fill_manual_logging | Manual fill logging | ✅ Active | Separate from Auto mode. |
| automation.cancel_auto_fill_on_mode_change | Cancel pending auto fill | ✅ Active | Cancels scheduled fill if mode changes. |
| input_datetime.tank_refill_completed | Legacy helper | ⚠ Investigate | Last updated 2025-07-13. Appears unused. |

### Observation

The current HX711 tank scale appears sufficiently stable for automatic fill control.

The existing 5-minute low-level debounce provides the necessary protection against transient level changes, reducing the need for a separately filtered tank volume sensor.

The continued need for `sensor.outside_filtered_tank_gallons` should be reevaluated after additional operational testing.

## Fill Cycle Model

The system uses four different gallon values that must not be confused.

1. Starting Tank Volume (`sensor.outside_tank_gallons`)
2. Target Tank Volume (`input_number.tank_full_target`)
3. Water Added (`sensor.hydroponics_patio_esp32_fill_gallons`)
4. Ending Tank Volume (`sensor.outside_tank_gallons` after fill)

Several notification and logging bugs discovered on 2026-07-04 were caused by mixing these values.


### Questions To Investigate

- [x] Which automation generates the **🤖 Auto Fill Logged** notification?
  - `automation.outside_tank_fill_log_and_notify_auto_only`

- [x] Which process generates the **Maintenance Cycle Complete** notification?
  - Node-RED Flow-1 Hydroponics Cycle Manager

- [x] Which process generated the bad legacy CSV row?
  - `automation.outside_tank_fill_log_and_notify_auto_only`

- [ ] Which entity/value supplies **System Volume** in the Node-RED completion notification?
  - Current evidence suggests it is using the pre-fill tank volume.

- [ ] Should Node-RED Flow-1 report both:
  - Starting Volume
  - Final Volume

- [ ] Are any remaining notifications using stale helper values?

### Fixes Applied

- Removed legacy **🤖 Auto Fill Logged** notification from
  `automation.outside_tank_fill_log_and_notify_auto_only`.

- Removed legacy CSV write to `notify.file_2`.

- Fill-stopped branch now only:
  - timestamps fill stop
  - resets `input_boolean.allow_auto_fill`

- Updated Node-RED Flow-1 completion notification.
  - FILL events now distinguish between:
    - Starting Volume
    - Calculated Final Volume
  - DOSE events continue to report System Volume.

### Verification

⏳ Pending next automatic fill cycle.

Expected notification:

auto FILL completed

Water Added: xx.xx gal
Dose A: xx mL
Dose B: xx mL
Starting Volume: xx.x gal
Calculated Final Volume: xx.x gal
TDS: x.xxx → x.xxx

### Remaining Problem

The next automatic fill must verify that the updated Node-RED notification now reports:

- Starting Volume
- Calculated Final Volume

instead of the misleading `System Volume`.

The larger remaining issue is that dashboard values sourced directly from ESPHome sensors are transient and are lost after ESP reboot/reflash.

Persistent “last completed cycle” values need to be stored in Home Assistant helpers and displayed through read-only template sensors.

Status: IMPLEMENTED - pending next fill verification

### ESPHome Helper Naming Fix

Validation passed.

Changed ESPHome post-fill helper writes to:

- `input_datetime.outside_tank_fill_stopped`
- `input_number.outside_tank_last_fill_gallons`

Status: IMPLEMENTED - pending next fill verification



### Verification - 2026-07-06 Short Auto Fill

Chronological test sequence:

1. EC reference before fill:
   - Time: 2026-07-06 08:33
   - EC: 1.70
   - Probe: 1.716 V
   - Tank: 17.8 gal
   - Temp: 67.2°F

2. Auto Fill Scheduled notification:
   - Tank low: 17.8 gal
   - Fill scheduled for 09:00
   - Notification worked, but wording should change from:
     `Turn Off input_boolean.allow_auto_fill`
     to:
     `Turn Off Auto Fill Gate`

3. Auto Fill - Auto Dose completed.

4. Node-RED completion notification reported:
   - Water Added: 4.28 gal
   - Dose A: 43 mL
   - Dose B: 43 mL
   - Starting Volume: 17.7 gal
   - Calculated Final Volume: 22.0 gal
   - TDS: 1.735 → 1.706

5. EC reference after fill:
   - Time: 2026-07-06 09:14
   - EC: 1.70
   - Probe: 1.753 V
   - Tank: 21.1 gal
   - Temp: 67.8°F
   - Note: After maintenance cycle complete on short autofill

### Validation Result

The stale **Auto Fill Logged** notification was successfully removed.

Node-RED notification now correctly distinguishes:

- Water Added
- Starting Volume
- Calculated Final Volume

The notification still needs terminology cleanup:

- Rename title from **Maintenance Cycle Complete**
  to **Auto Fill - Auto Dose Complete** when event type is `FILL`.

The calculated final volume was:

`17.7 + 4.28 = 22.0 gal`

Actual post-fill tank reading was:

`21.1 gal`

This difference should be noted but not treated as a failure yet because the tank scale may not have fully stabilized at notification time or the calculation uses pre-fill + flow-meter value rather than final tank weight.

### Dashboard Observations During 2026-07-06 Auto Fill

Screenshots captured the live dashboard state during the cycle.

Observed sequence:

1. Auto Fill Scheduled notification was correct, but wording should be updated:
   - Current: `turn Off the toggle: input_boolean.allow_auto_fill`
   - Preferred: `turn Off Auto Fill Gate`

2. Fill start timestamp updated correctly at fill start.

3. While filling, Fill Duration temporarily displayed a large negative value because:
   - fill start had updated to the current cycle,
   - fill stop still contained the previous cycle timestamp.

4. After fill completed:
   - Fill Ended updated correctly.
   - Fill Duration corrected to 0.8 min.
   - Gallons Measured showed 4.33 gal.
   - Last Fill Gallons showed 4.28 gal.

5. Auto dose sequence completed:
   - Dose A: 42.79 mL
   - Dose B: 42.79 mL
   - Pump A Runtime eventually showed 26.99 s.
   - Pump B Runtime eventually showed 26.00 s.
   - Last Dose A and Last Dose B updated to 7/6/2026 9:01 AM.

### Status

What was accomplished

Controller Modes

✅ Renamed operating modes to reflect actual behavior:
Auto Fill - Auto Dose
Manual Fill - Auto Dose
ESP-Override
✅ Updated dashboards.
✅ Updated conditional cards.
✅ Updated button-card colors.
✅ Updated Node-RED mode normalization with backward compatibility.

Flow-1 Cycle Manager

✅ Proper documentation added.
✅ Better separation of responsibilities.
✅ Notification titles now driven by controller mode and event type.

Notifications

✅ Removed obsolete Auto Fill notification.
✅ Removed legacy CSV write.
✅ Fixed fill summary to distinguish:
Water Added
Starting Volume
Calculated Final Volume

Persistence

✅ Last fill gallons now stored in a persistent HA helper.
✅ ESPHome helper names corrected.
✅ Identified the next phase of migrating "last completed cycle" values out of transient ESP sensors.

Documentation

✅ Node documentation standardized:
Purpose
Responsibilities (where appropriate)
Revision History
✅ ISSUE-002 is now largely verified with a real production fill.

### Related Files

Required:

- patio_controller.yaml
- patio_dosing_controls.yaml
- db_history_dashboard.yaml

As Needed:

- Home Assistant automations related to Auto Fill and Auto Dose
- Hydroponics_Cycle_Manager.json
- 05-nutrient-management-and-ec-control.md

### Components Affected

- ESPHome
- Home Assistant
- Node-RED
- MariaDB
- Dashboard
- Documentation

### Final Result

The notification redesign was successfully implemented and verified.

Legacy notifications and CSV logging were removed.

Node-RED now reports:

- Water Added
- Starting Volume
- Calculated Final Volume
- Dose A
- Dose B
- TDS Before/After

Remaining enhancements involving persistent dashboard state were moved to ISSUE-008.

### Status

**CLOSED – VERIFIED**

---

## ISSUE-003 - Inventory Synchronization

Priority: MEDIUM

Observed:

Inventory appeared unchanged after fill.

Later inventory reflected approximately:

98 mL Auto Fill
+
50 mL Manual Dose

Need to determine:

- when inventory updates
- who updates inventory
- why update timing is inconsistent

### Inventory Recovery

Container tare (matching container):
190 g

Cap:
6 g

Measured densities:

Part A
241 g / 200 mL = 1.205 g/mL

Part B
233 g / 200 mL = 1.165 g/mL

Gross weights:

Part A = 3500 g

Part B = 3300 g

Current inventory values require verification before permanent correction.

---

### Related Files

Required:

- batch_building.yaml
- patio_controller.yaml
- patio_dosing_controls.yaml
- db_history_dashboard.yaml

As Needed:

- Home Assistant automations related to Auto Fill and Auto Dose
- Hydroponics_Cycle_Manager.json
- 05-nutrient-management-and-ec-control.md

### Components Affected

- ESPHome
- Home Assistant
- Node-RED
- MariaDB
- Dashboard
- Documentation


Status: OPEN

---

## ISSUE-004 - ESP Override Manual Dose Anomaly

Priority: HIGH

### Observed

During an attempted manual ESP Override dose, the system entered an uncertain state.

Sequence:

- User intended to perform a 50 mL Part A manual dose.
- User pressed the **Motor Start/Stop** control instead of the **50 mL Dose** control.
- Dashboard timer continued counting.
- Pump state became questionable.
- Manual switch appeared responsive.
- Laptop/Wi-Fi issue occurred at the same time.
- System was powered down as a precaution.
- After recovery, a verified ESP Override dose was performed successfully.

### Notifications Observed

Unverified / anomaly event:

- ESP Override Dose A Logged
- Timestamp: `2026-07-04 01:12 PM`
- Duplicate notification received.
- Maintenance Cycle Complete also reported an ESP Override dose completion.
- Actual dose completion is uncertain.

Verified recovery event:

- ESP Override Dose A Logged
- Timestamp: `2026-07-04 01:58 PM`
- Dose A: 50.0 mL

- ESP Override Dose B Logged
- Timestamp: `2026-07-04 01:59 PM`
- Dose B: 50.0 mL

- Maintenance Cycle Complete
- System Volume: 20.6 gal
- TDS: 1.778 → 1.940

### Current Interpretation

The duplicate notification may not be a standalone notification bug.

It may have been caused by the same manual dosing anomaly:

- wrong dashboard control used,
- possible Wi-Fi/UI synchronization issue,
- interrupted dose sequence,
- system shutdown during uncertain state.

The important issue is not simply the duplicate notification. The issue is that the controller reported completion for a dose that may not have completed.

### Questions To Investigate

- [ ] Did the Motor Start/Stop control bypass the normal 50 mL dose script?
- [ ] Does the runtime counter continue if the pump is manually stopped?
- [ ] Can the ESPHome script report dose completion after interruption?
- [ ] Can Node-RED log a dose based on planned runtime instead of actual pump runtime?
- [ ] Did Home Assistant or Node-RED send duplicate notifications, or did the same event get emitted twice?
- [ ] Should manual pump start/stop be hidden or protected when dosing automation is active?

### Required Fix / Improvement

Manual pump controls must fail safe.

The system should not report a completed dose unless the dose script actually completed successfully.

If a manual dose is interrupted, the system should record it as:

```text
INTERRUPTED / UNKNOWN DOSE
```

Status: OPEN

---

## ISSUE-005 – Controller State Visibility

**Priority:** HIGH

### Current State

The dashboard does not yet accurately represent what the hydroponics controller
is doing at any given time.

Several independent Home Assistant automations, ESPHome scripts, timers, and
Node-RED flows may be active, but the dashboard currently provides only partial
or misleading status.

As a result, the operator cannot always quickly determine whether the controller
is:

* Idle
* Waiting
* Filling
* Dosing
* Mixing
* Complete
* Blocked
* Faulted

---

### Problems Observed

Examples encountered during development:

* Auto Dose card indicated **ON** while the automation itself was disabled.
* Controller appeared idle while actually waiting for the Auto Fill dwell period.
* Maintenance dosing was executing while the dashboard still showed **Ready**.
* Difficult to distinguish between:

  * Waiting for maintenance debounce
  * Waiting for scheduled fill
  * Waiting for nutrient mixing
  * Waiting before the next maintenance dose
* No indication that ESPHome was actively executing Pump A, Pump B, or a
  maintenance dose request.

---

### Design Goal

Create a single operator-facing controller state that accurately represents what
the hydroponics system is doing at any given time.

The dashboard should answer one question immediately:

> **What is the controller doing right now?**

without requiring the operator to inspect Home Assistant automations, ESPHome
logs, or Node-RED.

---

### Desired Visible States

Examples include:

* Idle
* Waiting for Low-Level Debounce
* Auto Fill Scheduled
* Filling
* Calculating Fill Dose
* Dosing Nutrient A
* Waiting Between Pumps
* Dosing Nutrient B
* Mixing
* Waiting for Maintenance Recheck
* Maintenance Dosing
* Cycle Complete
* Cancelled
* Blocked
* Fault
* Calibration Mode
* ESP-Override

The final state model may change during implementation.

---

### Engineering Decisions

The controller state design must preserve the existing separation of
responsibilities.

#### Home Assistant

Home Assistant owns:

* Operator configuration
* Maintenance dosing coordination
* Auto Fill coordination
* Dashboard presentation
* Controller state visibility
* Adjustable timing parameters

#### ESPHome

ESPHome remains responsible for:

* Physical pump outputs
* Fill solenoid control
* Pump sequencing
* Pump runtime
* Inter-pump delay
* Local execution safety gates

#### Node-RED

Node-RED remains responsible for:

* Completed-cycle logging
* Delayed post-mixing TDS capture
* Database writes
* Completion notifications

A configurable value should have one authoritative owner. Other components
should consume that value rather than defining duplicate independent settings.

---

### Configurable Timing Design

Four operating timing values were identified as operator-configurable.

#### Maintenance Debounce

Defines how long the maintenance-dose conditions must remain continuously valid
before a maintenance dose may begin.

**Default:** 5 minutes

**Owner:** `patio_dosing_controls.yaml`

#### Maintenance Mixing Time

Defines how long newly added nutrients are allowed to circulate before the
post-dose TDS value is evaluated.

This value may require adjustment if tank volume or circulation flow rates are
changed.

**Default:** 10 minutes

**Owner:** `patio_dosing_controls.yaml`

#### Next Maintenance Dose Offset

Defines the additional delay after the mixing period before another automatic
maintenance dose may begin.

**Default:** 60 seconds

**Owner:** `patio_dosing_controls.yaml`

#### Auto Fill Dwell

Defines how long the Auto Fill gate must remain continuously valid before an
automatic fill begins.

This is primarily a system-confidence delay and may be reduced as confidence in
the tank scale and fill controls improves.

**Default:** 30 minutes

**Owner:** `patio_system_constants.yaml`

The following execution timing values remain fixed implementation constants:

* Home Assistant to ESPHome request propagation delay: 2 seconds
* ESPHome Pump A to Pump B separation: 5 seconds

---

### Work Completed

#### Documentation

* Added Home Assistant package ownership guidance to the system overview.
* Added configurable maintenance timing design to the nutrient management
  documentation.
* Confirmed that engineering documents describe design intent while YAML and
  Node-RED files document implementation details.

#### Home Assistant Packages

Added the following helpers to `patio_dosing_controls.yaml`:

* `input_number.outside_maintenance_debounce_minutes`
* `input_number.outside_maintenance_mixing_minutes`
* `input_number.outside_maintenance_next_dose_offset_seconds`

Added the following helper to `patio_system_constants.yaml`:

* `input_number.outside_auto_fill_dwell_minutes`

All four helpers loaded successfully in Home Assistant.

#### Automation Logic

Updated the Outside TDS Maintenance Auto Dose automation to use:

* Configurable Maintenance Mixing Time
* Configurable Next Maintenance Dose Offset

Updated the Outside Maintenance Dose Due binary sensor to use:

* Configurable Maintenance Debounce

Updated the Auto Fill - Auto Dose automation to use:

* Configurable Auto Fill Dwell

#### Dashboard

Added the maintenance timing controls to the Auto-Dose Settings card.

Added the Auto Fill Dwell control to a separate Auto Fill Settings card.

Corrected the maintenance request button entity to:

```text
button.patio_hydroponics_outside_run_maintenance_dose_request
```

---

### Remaining Work

The timing configuration phase is complete.

The remaining ISSUE-005 work is to create the actual controller state machine
and dashboard state presentation.

Remaining tasks include:

* Define the authoritative controller-state entity.
* Track current maintenance cycle count.
* Display the active maintenance cycle as Cycle X of Y.
* Display the maintenance mixing countdown.
* Distinguish between:

  * Waiting for low TDS
  * Maintenance debounce
  * Maintenance dosing
  * Mixing
  * Waiting before the next dose
  * Completed
  * Disabled
  * Blocked
  * Fault
* Reflect active ESPHome pump and fill operation.
* Reflect Auto Fill dwell and scheduled fill state.
* Coordinate the configurable mixing time with the Node-RED delayed TDS capture.
* Update dashboard cards to use the new controller state.
* Perform one final supervised maintenance-dose validation.
* Close ISSUE-006 after delayed TDS-after readings are confirmed accurate.

---

### Related Files

Required:

* `patio_controller.yaml`
* `patio_dosing_controls.yaml`
* `patio_system_constants.yaml`
* `db_history_dashboard.yaml`

As Needed:

* Home Assistant automations related to Auto Fill and Auto Dose
* `Flow-1_Hydroponics_Cycle_Manager.json`
* `05-nutrient-management-and-ec-control.md`
* `00-system-overview.md`

---

### Components Affected

* ESPHome
* Home Assistant
* Node-RED
* MariaDB
* Dashboard
* Documentation

---

### Status

**OPEN – Timing Configuration Complete; Controller State Machine Pending**

---

## ISSUE-006 – Maintenance Auto Dose

**Priority:** HIGH

### Current Status

**Core implementation complete.**

The maintenance dosing architecture has been redesigned and validated.

The patio_controller now supports maintenance dosing as an additional command
path without requiring Home Assistant to change the Outside Control Mode.

The Home Assistant automation remains **disabled** while additional EC/TDS
correlation data is collected before allowing unattended maintenance dosing.

---

## Original Problem

The original maintenance dosing concept temporarily changed the global
Outside Control Mode to **ESP-Override** in order to operate the nutrient
pumps.

This interrupted Auto Fill ownership and could cancel an active or pending
automatic fill cycle.

That design has been retired.

---

## Final Architecture

Maintenance dosing is now implemented as a request into the existing
`patio_controller`.

Home Assistant is responsible only for requesting a maintenance dose.

The `patio_controller` remains the sole authority controlling all physical
outputs.

### Maintenance Dose Sequence

```text
HA detects low TDS voltage
        ↓
HA calculates proportional maintenance dose
        ↓
HA writes:
  outside_maintenance_dose_request_a_ml
  outside_maintenance_dose_request_b_ml
        ↓
HA presses:
  button.hydroponics_patio_esp32_run_maintenance_dose_request
        ↓
patio_controller validates all safety gates
        ↓
Pump A
        ↓
5-second dwell
        ↓
Pump B
        ↓
Node-RED logs completed cycle
        ↓
HA waits 10-minute mixing period
        ↓
HA evaluates whether another maintenance cycle is required
```

I also recommend changing the issue title itself from **"Maintenance Auto Dose"** to **"Closed-Loop Maintenance Dose Automation"** once you enable it. At that point, the architectural work (ISSUE-006) will be complete, and the remaining work will be about tuning the automatic control algorithm rather than implementing the feature.

### Related Files

Required:

- 01-database-design.md
- db_history_dashboard.yaml

As Needed:

- Hydroponics_Cycle_Manager.json
- Node-RED history logging flow
- maintenance_log table definition
- v_hydro_recent_activity view

### Components Affected

- ESPHome
- Home Assistant
- Node-RED
- MariaDB
- Dashboard
- Documentation

---


## ISSUE-007 – History / Logging Improvements

**Priority:** MEDIUM

### Scope

Improve the usability and completeness of the Hydroponics history system.

### Logging Improvements

- Improve engineering field note entry.
- Display notes more cleanly in the history browser.
- Separate engineering notes from fill-specific information.
- Continue improving history browsing and filtering.

### History Display Improvements

- Include the year in timestamps.

Current:

Mon, Jul 6, 2:09 PM

Desired:

Mon, Jul 6, 2026, 2:09 PM

### Related Files

Required:

- 01-database-design.md
- db_history_dashboard.yaml

As Needed:

- Hydroponics_Cycle_Manager.json
- Node-RED history logging flow
- maintenance_log table definition
- v_hydro_recent_activity view

### Components Affected

- ESPHome
- Home Assistant
- Node-RED
- MariaDB
- Dashboard
- Documentation

### Status

OPEN

---

## ISSUE-008 – Cycle Persistence & Dashboard State

**Priority:** MEDIUM

### Scope

Improve dashboard behavior for completed cycles and controller restarts.

### Current Problems

ESPHome sensors represent only the current execution state.

After an ESP reboot or firmware update, several dashboard values revert to
their defaults because the controller has no knowledge of the previous cycle.

Observed examples:

- Last fill gallons
- Dose A amount
- Dose B amount
- Pump runtimes
- Fill duration
- Other cycle summary values

### Fill Duration Bug

During an active fill, the Fill Duration display should never calculate
against the stop timestamp from the previous fill.

If:

```text
fill_stopped < fill_started
```

display:

- Filling...
- Current elapsed time
- Unknown

instead of a negative duration.

### Design Direction

ESPHome should publish live execution data only.

Completed-cycle values should persist in Home Assistant helpers and be exposed
through read-only template sensors for dashboard use.

### Related Files

Required:

- 01-database-design.md
- db_history_dashboard.yaml

As Needed:

- Hydroponics_Cycle_Manager.json
- Node-RED history logging flow
- maintenance_log table definition
- v_hydro_recent_activity view

### Components Affected

- ESPHome
- Home Assistant
- Node-RED
- MariaDB
- Dashboard
- Documentation

### Status

OPEN

---

# ISSUE-009 – Refactor Nutrient Pump Execution Architecture

**Status:** Proposed  
**Discovered:** 2026-07-07  
**Priority:** Medium  
**Dependencies:** Complete after ISSUE-006

---

# Purpose

Reduce duplicated nutrient pump execution code by separating **dose calculation**
from **pump execution** while preserving all existing functionality.

This refactor will improve maintainability, simplify future enhancements, and
reduce the risk of inconsistencies between Fill, Maintenance, and
ESP-Override dosing.

---

# Current Architecture

Each dosing mode currently performs both:

- Dose calculation
- Pump execution

For example:

## Fill Dose

```text
Determine gallons added
Calculate nutrient mL
Calculate pump runtime
Publish runtime sensors
Turn on pump
```

## ESP-Override Dose

```text
Read operator-entered mL
Calculate pump runtime
Publish runtime sensors
Turn on pump
```

As a result, much of the pump execution logic is duplicated between scripts.

---

# Proposed Architecture

Separate nutrient dosing into two logical layers.

## Layer 1 – Dose Source

Responsible only for determining the requested nutrient amount.

### Fill Dose

```text
Gallons Added
        │
        ▼
Requested Dose (mL)
```

### Maintenance Dose

```text
Maintenance Request
        │
        ▼
Requested Dose (mL)
```

### ESP-Override

```text
Manual A Request
Manual B Request
```

Layer 1 should **never** calculate pump runtimes.

---

## Layer 2 – Pump Execution

Responsible only for executing a requested nutrient dose.

Responsibilities:

- Apply pump calibration
- Calculate runtime
- Publish dose sensors
- Publish runtime sensors
- Set running flags
- Turn on physical pump

Pump execution should not know whether the request originated from:

- Fill replacement
- Maintenance dosing
- ESP-Override
- Future automation

Its only responsibility is:

```text
Dose this pump X milliliters.
```

---

# Pump Calibration

Pump calibration belongs exclusively within the pump execution layer.

Each pump independently converts:

```text
Runtime (seconds) =
Requested Dose (mL)
-------------------
Pump Calibration (mL/sec)
```

Pump A and Pump B intentionally remain independent because their calibrated
flow rates may differ.

---

# Equal-Dose Modes

The following operating modes always request identical nutrient amounts for
both nutrient pumps:

- Auto Fill - Auto Dose
- Manual Fill - Auto Dose
- Maintenance Dose

These modes should calculate a single requested dose value and supply that
same value to both pump execution routines.

---

# Independent-Dose Mode

ESP-Override intentionally allows different requested amounts.

```text
Pump A = Manual A Dose

Pump B = Manual B Dose
```

Because of this, ESP-Override remains a special case.

---

# Benefits

This refactor will:

- Eliminate duplicated runtime calculations.
- Centralize pump calibration logic.
- Improve long-term maintainability.
- Simplify future maintenance dose implementation.
- Reduce future regression risk.
- Keep Fill, Maintenance, and ESP-Override execution consistent.

---

# Design Philosophy

The controller should determine **how much** nutrient is required.

The pump should determine **how long** it must run.

Separating these responsibilities improves readability, testing, and future
extensibility while minimizing duplicated code.

---

# Proposed Script Organization

```text
Fill Dose A
        │
        ▼
Execute Pump A

Fill Dose B
        │
        ▼
Execute Pump B

Maintenance Dose A
        │
        ▼
Execute Pump A

Maintenance Dose B
        │
        ▼
Execute Pump B

ESP-Override Dose A
        │
        ▼
Execute Pump A

ESP-Override Dose B
        │
        ▼
Execute Pump B
```

The pump execution routines become the only location responsible for
calibration and runtime calculations.

---

# Revision History

| Date | Author | Description |
|------|--------|-------------|
| 2026-07-07 | GAL | Initial architecture proposal. |

---

## ISSUE-010 – Improve Field Note Entry

**Priority:** MEDIUM

### Current Status

Functional, but the Home Assistant user interface makes entering engineering field notes cumbersome.

### Current Behavior

Field notes are stored correctly in `maintenance_log` as `NOTE` events.

The current workflow uses:

- `input_text.hydro_history_field_note`
- Browser Mod popup
- Date selector
- Location selector
- Save button

Although the popup improves the workflow, the built-in Home Assistant `input_text` editor only provides a single-line text entry field.

Longer engineering observations require horizontal scrolling, making them difficult to review and edit before saving.

### Desired Behavior

Provide a larger text entry experience suitable for engineering field observations.

Desired capabilities include:

- Multi-line text entry
- Comfortable editing of longer notes
- Ability to review the entire note before saving
- Maintain the existing Browser Mod popup workflow

### Possible Solutions

Evaluate one or more of the following:

- Replace the built-in `input_text` editor with a custom Lovelace textarea component.
- Use a Browser Mod popup containing a custom card that supports multi-line text entry.
- Develop a dedicated Field Note popup modeled after the Measure EC workflow.
- Investigate alternative Home Assistant UI components that provide a true textarea experience.

### Database Impact

None.

`maintenance_log` already supports the required note length.

This issue is strictly a Home Assistant user interface improvement.

### Status

Deferred until higher-priority hydroponics control and EC calibration work is complete.