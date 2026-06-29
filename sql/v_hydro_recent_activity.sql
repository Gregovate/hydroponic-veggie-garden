/*
View: v_hydro_recent_activity

Purpose:
  Provides a read-only recent activity timeline for the outside hydroponics
  system by combining controller events and EC reference measurements.

Notes:
  This is for dashboard display only. It does not modify source records.

Revision History:
2026-06-28  GAL  Initial recent activity view.
*/

CREATE OR REPLACE VIEW v_hydro_recent_activity AS
SELECT
    'maintenance_log' AS activity_source,
    id AS source_id,
    timestamp_utc AS activity_time,
    source AS system_key,
    event_type,
    note,
    system_gallons AS tank_gallons,
    gallons_added AS fill_gallons,
    tds_before AS ec_before,
    tds_after AS ec_after,
    tds_after AS tds_voltage,
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
    tank_gallons,
    NULL AS fill_gallons,
    NULL AS ec_before,
    meter_value AS ec_after,
    probe_voltage AS tds_voltage,
    NULL AS dose_a_ml,
    NULL AS dose_b_ml,
    NULL AS east_flow_l_min,
    NULL AS west_flow_l_min,
    'home_assistant' AS source
FROM hydro_tds_reference_reading;



SHOW FULL TABLES LIKE 'v_hydro_recent_activity';



SELECT *
FROM v_hydro_recent_activity
WHERE system_key = 'outside'
ORDER BY activity_time DESC
LIMIT 20;