/*
 * Outside Hydroponics 2026 Season and Planting Layout
 *
 * Purpose:
 *   Seed the 2026 outside growing season and all thirteen physical positions.
 *
 * Planting date:
 *   2026-06-04
 */

START TRANSACTION;

INSERT INTO hydro_season (
    system_key,
    season_year,
    season_name,
    start_date,
    end_date,
    status,
    notes
)
VALUES (
    'outside',
    2026,
    '2026 Outdoor Garden',
    '2026-06-04',
    NULL,
    'active',
    'Outside hydroponics season planted June 4, 2026.'
)
ON DUPLICATE KEY UPDATE
    season_name = VALUES(season_name),
    start_date = VALUES(start_date),
    end_date = VALUES(end_date),
    status = VALUES(status),
    notes = VALUES(notes);

INSERT INTO hydro_season_planting (
    season_id,
    position_id,
    variety_id,
    plant_count,
    planted_date,
    removed_date,
    status,
    notes
)
SELECT
    s.season_id,
    p.position_id,
    v.variety_id,
    layout.plant_count,
    layout.planted_date,
    NULL,
    layout.planting_status,
    layout.notes
FROM (
    SELECT 'E1' AS position_code, 'Pepper' AS crop_name, 'Sweet Bell' AS variety_name,
           2 AS plant_count, CAST('2026-06-04' AS DATE) AS planted_date,
           'planted' AS planting_status, NULL AS notes
    UNION ALL SELECT 'E2', 'Tomato', 'Lemon Boy', 1, CAST('2026-06-04' AS DATE), 'planted', NULL
    UNION ALL SELECT 'E3', 'Eggplant', 'Whopper', 1, CAST('2026-06-04' AS DATE), 'planted', NULL
    UNION ALL SELECT 'E4', NULL, NULL, 0, NULL, 'empty', NULL
    UNION ALL SELECT 'E5', 'Tomato', 'Wisconsin 55', 1, CAST('2026-06-04' AS DATE), 'planted', NULL
    UNION ALL SELECT 'E6', NULL, NULL, 0, NULL, 'empty', NULL
    UNION ALL SELECT 'E7', 'Tomato', 'Old German', 1, CAST('2026-06-04' AS DATE), 'planted', NULL
    UNION ALL SELECT 'W1', 'Tomato', 'Yellow Pear', 1, CAST('2026-06-04' AS DATE), 'planted', NULL
    UNION ALL SELECT 'W2', NULL, NULL, 0, NULL, 'empty', NULL
    UNION ALL SELECT 'W3', 'Tomato', 'Celebrity', 1, CAST('2026-06-04' AS DATE), 'planted', NULL
    UNION ALL SELECT 'W4', NULL, NULL, 0, NULL, 'empty', NULL
    UNION ALL SELECT 'W5', 'Tomato', 'Early Girl', 2, CAST('2026-06-04' AS DATE), 'planted', NULL
    UNION ALL SELECT 'W6', NULL, NULL, 0, NULL, 'empty', NULL
) AS layout
INNER JOIN hydro_season s
    ON s.system_key = 'outside'
   AND s.season_year = 2026
INNER JOIN hydro_position p
    ON p.system_key = 'outside'
   AND p.position_code = layout.position_code
LEFT JOIN hydro_crop c
    ON c.crop_name = layout.crop_name
LEFT JOIN crop_variety v
    ON v.crop_id = c.crop_id
   AND v.variety_name = layout.variety_name
ON DUPLICATE KEY UPDATE
    variety_id = VALUES(variety_id),
    plant_count = VALUES(plant_count),
    planted_date = VALUES(planted_date),
    removed_date = VALUES(removed_date),
    status = VALUES(status),
    notes = VALUES(notes);

COMMIT;
