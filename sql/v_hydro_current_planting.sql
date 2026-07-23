/*
 * View: v_hydro_current_planting
 *
 * Purpose:
 *   Provide one current planting read interface for Home Assistant,
 *   Node-RED, harvest entry, waste entry, and dashboard display.
 *
 * Design:
 *   - Returns planting assignments from active growing seasons.
 *   - Includes empty positions so the full physical layout remains visible.
 *   - Exposes planting_id because harvest and waste records reference the
 *     planting assignment rather than storing crop or position separately.
 */

CREATE OR REPLACE VIEW v_hydro_current_planting AS
SELECT
    sp.planting_id,

    s.season_id,
    s.system_key,
    s.season_year,
    s.season_name,
    s.start_date AS season_start_date,
    s.status AS season_status,

    p.position_id,
    p.channel,
    p.position_code,
    p.position_number,
    p.flow_order,

    c.crop_id,
    c.crop_name,

    v.variety_id,
    v.variety_name,

    sp.plant_count,
    sp.planted_date,
    sp.removed_date,
    sp.status AS planting_status,
    sp.notes AS planting_notes,

    CASE
        WHEN sp.planted_date IS NULL THEN NULL
        ELSE DATEDIFF(CURDATE(), sp.planted_date)
    END AS days_growing

FROM hydro_season_planting sp

INNER JOIN hydro_season s
    ON s.season_id = sp.season_id

INNER JOIN hydro_position p
    ON p.position_id = sp.position_id

LEFT JOIN crop_variety v
    ON v.variety_id = sp.variety_id

LEFT JOIN hydro_crop c
    ON c.crop_id = v.crop_id

WHERE s.status = 'active';