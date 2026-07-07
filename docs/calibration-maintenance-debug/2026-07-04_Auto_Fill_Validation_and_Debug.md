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

## Fill Cycle Entity Inventory

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

### Critical Observation - ESP Reboot Clears Cycle History

After ESP reboot/reflash, dashboard values sourced from ESPHome sensors lost their previous cycle history.

Affected values included:

- Last fill gallons
- Dose A amount
- Dose B amount
- Pump A runtime
- Pump B runtime
- Some dose/fill display values

Conclusion:

ESPHome sensors must be treated as live/current-cycle values only.

Persistent “last completed cycle” values need to be stored in Home Assistant helpers and displayed through read-only template sensors.

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

### Status

VERIFIED - CLOSED

All functional defects identified in ISSUE-002 have been corrected and
verified during the 2026-07-06 production Auto Fill - Auto Dose cycle.

Remaining enhancements have been moved to new iISSUE-008 to keep this issue
focused on notification correctness and fill-cycle reporting.

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

## ISSUE-005 - Controller State Visibility

Priority: HIGH

Current dashboard does not indicate controller execution state.

Need visible controller states such as:

- Idle
- Waiting 5 Minutes
- Auto Fill Scheduled
- Waiting 30 Minutes
- Filling
- Pre-Fill Dosing
- Mixing
- Maintenance Dosing
- Complete
- Cancelled
- Fault

Dashboard should always indicate current controller state and right now the status cards do not reflect actual controller state.

Examples observed:

- Auto Dose card indicated ON while automation was disabled.
- Controller appeared idle while actually waiting 30 minutes.
- Difficult to determine controller state at a glance.

Need dashboard state redesign.


Status: OPEN

---

## ISSUE-006 - Maintenance Auto Dose

**Priority:** HIGH

### Current State

The **Outside TDS Maintenance Auto Dose** automation has been **disabled**.

### Reason

During maintenance dosing, the automation changed:

`Hydroponics Outside Control Mode` → **ESP Override**

This unexpectedly cancelled the pending **Auto Fill** sequence, leaving the system in an incorrect operating state.

Because both the Maintenance Auto Dose automation and the Auto Fill controller use the same global Outside Control Mode for ownership, they can interfere with one another when either changes the mode.

## Root Cause

The disabled maintenance dosing automation directly changes the global Outside Control Mode from `Auto` to `ESP-Override` in order to run the dose pump buttons.

This temporarily removes ownership from the Auto controller and can interrupt or cancel an active or scheduled Auto Fill cycle.

Maintenance dosing should not change the global control mode.

### Required Redesign

The maintenance dosing controller must be redesigned so it:

- Maintains minimum nutrient concentration while circulation is running.
- Does **not** change the global Control Mode.
- Operates independently of Auto Fill.
- Can coexist safely with scheduled fills.
- Coordinates ownership with the Auto Fill controller so fill and maintenance dosing cannot conflict or interrupt one another.
- Preserves all existing safety interlocks (tank level, inventory, maximum TDS voltage, etc.).

## Corrected Design Direction

There is no separate maintenance controller.

Maintenance Auto Dose should become another command path into the existing `patio_controller`.

HA detects low TDS voltage
HA sets requested A/B dose amount
HA presses "maintenance dose request"
patio_controller checks:
  - system enabled
  - mode is Auto
  - fill not active
  - dose pumps off
  - tank volume valid
  - inventory OK
  - TDS below low threshold
  - TDS below hard stop
patio_controller runs A then B
HA waits/mixes/rechecks

Home Assistant may detect that maintenance dosing is needed, calculate/request the step dose amount, and start the maintenance cycle, but it should not take direct control of the system by switching to `ESP-Override`.

The `patio_controller` must remain the single execution authority for all physical outputs.

### Implementation Status

- HA automation Outside TDS Maintenance Auto Dose updated but remains disabled.
- `patio_dosing_controls.yaml` updated and Home Assistant reloaded.
- Maintenance dose request helpers added to patio_dosing_controls.yaml
- Automation no longer switches Outside Control Mode to `ESP-Override`.
- ESPHome `patio_controller` maintenance dose request handler still needs to be added and validated.

### Status

Automation remains **disabled** until the maintenance dosing architecture is redesigned and validated.

---


## ISSUE-007 - Event Notes

Priority: MEDIUM

Field Notes were added to preserve engineering observations.

Need improvements:

- easier note entry
- notes displayed cleanly
- notes separated from fill-specific fields

Status: OPEN

---

# Inventory Recovery

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

## ISSUE-008 - Auto Fill Cycle State Machine

### Follow-Up UI Issue

During an active fill, the Fill Duration display should avoid showing a negative value when the fill stop timestamp still belongs to the previous cycle.

Possible fix:

- If `outside_tank_fill_stopped` is older than `outside_tank_fill_started`, show:
  - `Filling...`
  - or current elapsed time since fill start
  - or `unknown`

Do not calculate duration using a stop timestamp from the previous fill.

### Remaining Improvement - Auto Fill Cycle State Visibility

During Auto Fill - Auto Dose, there is no clear operator feedback between:

- fill completed
- auto-dose started/completed
- mixing dwell in progress
- final TDS summary ready

Needed:

A visible cycle state such as:

- Idle
- Auto Fill Scheduled
- Filling
- Fill Complete - Dosing
- Mixing / Waiting for TDS Stabilization
- Cycle Complete
- Fault / Interrupted

Short-term improvement:

Send one notification when fill completes:

`Auto Fill Complete - Mixing`

Example:

```text
Auto Fill completed.
Water Added: 4.28 gal
Dose A/B started or completed.
Waiting 10 minutes for mixing before final cycle summary.
```