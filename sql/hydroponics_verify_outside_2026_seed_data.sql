/*
 * Outside Hydroponics 2026 Seed Data Verification
 */

SELECT
    p.position_code,
    p.channel,
    c.crop_name,
    v.variety_name,
    sp.plant_count,
    sp.planted_date,
    sp.status
FROM hydro_season_planting sp
INNER JOIN hydro_position p
    ON p.position_id = sp.position_id
INNER JOIN hydro_season s
    ON s.season_id = sp.season_id
LEFT JOIN crop_variety v
    ON v.variety_id = sp.variety_id
LEFT JOIN hydro_crop c
    ON c.crop_id = v.crop_id
WHERE s.system_key = 'outside'
  AND s.season_year = 2026
ORDER BY
    CASE p.channel
        WHEN 'East' THEN 1
        WHEN 'West' THEN 2
        ELSE 3
    END,
    p.position_number;

SELECT 'Crops' AS object_name, COUNT(*) AS row_count FROM hydro_crop
UNION ALL
SELECT 'Varieties', COUNT(*) FROM crop_variety
UNION ALL
SELECT '2026 Seasons', COUNT(*)
FROM hydro_season
WHERE system_key = 'outside' AND season_year = 2026
UNION ALL
SELECT '2026 Planting Assignments', COUNT(*)
FROM hydro_season_planting sp
INNER JOIN hydro_season s ON s.season_id = sp.season_id
WHERE s.system_key = 'outside' AND s.season_year = 2026
UNION ALL
SELECT '2026 Occupied Positions', COUNT(*)
FROM hydro_season_planting sp
INNER JOIN hydro_season s ON s.season_id = sp.season_id
WHERE s.system_key = 'outside' AND s.season_year = 2026 AND sp.status = 'planted'
UNION ALL
SELECT '2026 Empty Positions', COUNT(*)
FROM hydro_season_planting sp
INNER JOIN hydro_season s ON s.season_id = sp.season_id
WHERE s.system_key = 'outside' AND s.season_year = 2026 AND sp.status = 'empty';
