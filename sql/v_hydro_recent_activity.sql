/*
View: v_hydro_recent_activity

Purpose:
    Normalizes hydroponics activity records into one dashboard-friendly
    chronological event stream for the Hydro-History browser.

Primary Consumers:
    • Node-RED History Browser
    • Home Assistant Hydro-History dashboard
    • Node-RED "Format Recent Activity" function

Sources:
    • maintenance_log
    • hydro_tds_reference_reading

Measurement Model:
    • maintenance_log contains synchronized before-and-after voltage
      snapshots for A0 and A1.
    • hydro_tds_reference_reading contains one synchronized reference
      snapshot for A0 and A1.
    • meter_value and meter_units contain the handheld reference reading.
    • Analog sensor voltages are not labeled as EC or TDS.

Conductivity Channels:
    • A0 = KEYESTUDIO production/control channel
    • A1 = DFRobot validation/reference channel

Notes:
    • Uses maintenance_log.internal_time for maintenance, fill, and dose
      event ordering.
    • Uses hydro_tds_reference_reading.captured_at for EC reference events.
    • Normalizes differing source-table structures into a common schema.
    • Before-and-after voltage columns apply only to maintenance_log events.
    • Single-point reference voltage columns apply only to EC_REFERENCE events.
    • Missing source-specific values are returned as NULL.
    • The final column named source is retained for compatibility with the
      existing History Browser consumer.

Revision History:

2026-07-21  GAL
    • Replaced legacy tds_before, tds_after, and probe_voltage mappings.
    • Removed incorrect ec_before, ec_after, and tds_voltage aliases.
    • Added separate A0 and A1 raw and filtered voltage fields.
    • Preserved distinct cycle before/after and EC-reference snapshot semantics.
    • Retained meter_value and meter_units as the handheld EC reference.

2026-07-04  GAL
    • Added meter_value and meter_units passthrough columns for EC_REFERENCE
      cards in the Hydro-History "Select Event Below" browser.

2026-07-01  GAL
    • Added operator_note and water_temp_f to support Hydro-History browser
      annotations and temperature-aware EC reference display.

2026-06-30  GAL
    • Switched activity ordering to maintenance_log.internal_time.

2026-06-29  GAL
    • Initial view combining maintenance_log and
      hydro_tds_reference_reading for the Hydro-History dashboard.
*/

CREATE OR REPLACE VIEW v_hydro_recent_activity AS

SELECT
    'maintenance_log' AS activity_source,
    id AS source_id,
    internal_time AS activity_time,
    source AS system_key,
    event_type,
    note,
    operator_note,

    system_gallons AS tank_gallons,
    gallons_added AS fill_gallons,

    /* Cycle conductivity snapshots */
    a0_raw_v_before,
    a0_filtered_v_before,
    a1_raw_v_before,
    a1_filtered_v_before,

    a0_raw_v_after,
    a0_filtered_v_after,
    a1_raw_v_after,
    a1_filtered_v_after,

    /* Single-point EC reference snapshot fields */
    NULL AS a0_raw_v,
    NULL AS a0_filtered_v,
    NULL AS a1_raw_v,
    NULL AS a1_filtered_v,

    /* Handheld EC reference fields */
    NULL AS meter_value,
    NULL AS meter_units,
    NULL AS water_temp_f,

    dose_a_ml,
    dose_b_ml,

    NULL AS east_flow_l_min,
    NULL AS west_flow_l_min,

    device AS source

FROM maintenance_log

WHERE source = 'outside'


UNION ALL


SELECT
    'ec_reference' AS activity_source,
    id AS source_id,
    captured_at AS activity_time,
    system_key,
    'EC_REFERENCE' AS event_type,
    note,
    operator_note,

    tank_gallons,
    NULL AS fill_gallons,

    /* Cycle conductivity snapshots do not apply */
    NULL AS a0_raw_v_before,
    NULL AS a0_filtered_v_before,
    NULL AS a1_raw_v_before,
    NULL AS a1_filtered_v_before,

    NULL AS a0_raw_v_after,
    NULL AS a0_filtered_v_after,
    NULL AS a1_raw_v_after,
    NULL AS a1_filtered_v_after,

    /* Synchronized EC reference snapshot */
    a0_raw_v,
    a0_filtered_v,
    a1_raw_v,
    a1_filtered_v,

    /* Handheld EC reference */
    meter_value,
    meter_units,
    water_temp_f,

    NULL AS dose_a_ml,
    NULL AS dose_b_ml,

    NULL AS east_flow_l_min,
    NULL AS west_flow_l_min,

    'home_assistant' AS source

FROM hydro_tds_reference_reading;