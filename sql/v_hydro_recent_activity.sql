/*
View: v_hydro_recent_activity

Purpose:
    Provides a unified chronological activity stream for the Hydro-History
    dashboard by combining automated maintenance events and operator EC
    reference readings.
/*
View: v_hydro_recent_activity

Purpose:
    Normalizes hydroponics activity records into one dashboard-friendly
    event stream for the Hydro-History browser.

Primary Consumers:
    • Node-RED History Browser
    • Home Assistant Hydro-History dashboard
    • Node-RED "Format Recent Activity" function

Sources:
    • maintenance_log
    • hydro_tds_reference_reading

Notes:
    • Uses maintenance_log.internal_time for maintenance/fill/dose event ordering.
    • Uses hydro_tds_reference_reading.captured_at for EC reference events.
    • Normalizes differing table structures into a common dashboard schema.
    • water_temp_f is populated only for EC reference records.
    • operator_note may be populated by either maintenance_log or EC reference records.
    • meter_value and meter_units are populated only for EC reference records.
    • These columns are required by the "Select Event Below" history cards.

Revision History:

2026-07-04  GAL
    Added meter_value and meter_units passthrough columns for EC_REFERENCE
    cards in the Hydro-History "Select Event Below" browser.

2026-07-01  GAL
    Added operator_note and water_temp_f to support Hydro-History browser
    annotations and temperature-aware EC reference display.

2026-06-30  GAL
    Switched activity ordering to maintenance_log.internal_time.

2026-06-29  GAL
    Initial view combining maintenance_log and
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
    tds_before AS ec_before,
    tds_after AS ec_after,
    tds_after AS tds_voltage,
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
    NULL AS ec_before,
    meter_value AS ec_after,
    probe_voltage AS tds_voltage,
    meter_value,
    meter_units,
    water_temp_f,
    NULL AS dose_a_ml,
    NULL AS dose_b_ml,
    NULL AS east_flow_l_min,
    NULL AS west_flow_l_min,
    'home_assistant' AS source
FROM hydro_tds_reference_reading;