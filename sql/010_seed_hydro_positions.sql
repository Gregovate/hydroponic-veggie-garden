/******************************************************************************
 * Hydroponics 2026 Season Seed Data
 *
 * Purpose:
 *   Initialize the normalized crop, variety, season, and planting tables for
 *   the 2026 outside hydroponics growing season.
 *
 * Planting Date:
 *   2026-06-04
 *
 * Notes:
 *   - Existing hydro_position records are referenced by position_code.
 *   - No position IDs, crop IDs, variety IDs, or season IDs are hard-coded.
 *   - Empty physical positions receive explicit planting-assignment records.
 *   - ON DUPLICATE KEY UPDATE allows the script to be safely rerun.
 *   - alt-X to run script
 ******************************************************************************/

START TRANSACTION;


/******************************************************************************
 * 1. Seed crop types
 ******************************************************************************/

INSERT INTO hydro_crop (
    crop_name,
    active,
    notes
)
VALUES
    ('Tomato',  1, NULL),
    ('Pepper',  1, NULL),
    ('Eggplant', 1, NULL)
ON DUPLICATE KEY UPDATE
    active = VALUES(active);


/******************************************************************************
 * 2. Seed crop varieties
 *
 * Crop and variety are stored separately:
 *   Pepper   -> Sweet Bell
 *   Eggplant -> Whopper
 *   Tomato   -> named tomato varieties
 ******************************************************************************/

INSERT INTO crop_variety (
    crop_id,
    variety_name,
    seed_source,
    notes,
    active
)
SELECT
    c.crop_id,
    seed.variety_name,
    NULL,
    NULL,
    1
FROM (
    SELECT 'Tomato' AS crop_name, 'Lemon Boy' AS variety_name
    UNION ALL SELECT 'Tomato',  'Wisconsin 55'
    UNION ALL SELECT 'Tomato',  'Old German'
    UNION ALL SELECT 'Tomato',  'Yellow Pear'
    UNION ALL SELECT 'Tomato',  'Celebrity'
    UNION ALL SELECT 'Tomato',  'Early Girl'
    UNION ALL SELECT 'Pepper',  'Sweet Bell'
    UNION ALL SELECT 'Eggplant', 'Whopper'
) AS seed
INNER JOIN hydro_crop c
    ON c.crop_name = seed.crop_name
ON DUPLICATE KEY UPDATE
    active = VALUES(active);


/******************************************************************************
 * 3. Seed the 2026 growing season
 ******************************************************************************/

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
    start_date  = VALUES(start_date),
    end_date    = VALUES(end_date),
    status      = VALUES(status),
    notes       = VALUES(notes);


/******************************************************************************
 * 4. Seed all 13 season planting assignments
 *
 * Layout:
 *   East: E1-E7
 *   West: W1-W6
 *
 * Empty positions are intentionally recorded rather than omitted.
 ******************************************************************************/

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
    SELECT
        'E1' AS position_code,
        'Pepper' AS crop_name,
        'Sweet Bell' AS variety_name,
        2 AS plant_count,
        CAST('2026-06-04' AS DATE) AS planted_date,
        'planted' AS planting_status,
        NULL AS notes

    UNION ALL SELECT
        'E2', 'Tomato', 'Lemon Boy', 1,
        CAST('2026-06-04' AS DATE), 'planted', NULL

    UNION ALL SELECT
        'E3', 'Eggplant', 'Whopper', 1,
        CAST('2026-06-04' AS DATE), 'planted', NULL

    UNION ALL SELECT
        'E4', NULL, NULL, 0,
        NULL, 'empty', NULL

    UNION ALL SELECT
        'E5', 'Tomato', 'Wisconsin 55', 1,
        CAST('2026-06-04' AS DATE), 'planted', NULL

    UNION ALL SELECT
        'E6', NULL, NULL, 0,
        NULL, 'empty', NULL

    UNION ALL SELECT
        'E7', 'Tomato', 'Old German', 1,
        CAST('2026-06-04' AS DATE), 'planted', NULL

    UNION ALL SELECT
        'W1', 'Tomato', 'Yellow Pear', 1,
        CAST('2026-06-04' AS DATE), 'planted', NULL

    UNION ALL SELECT
        'W2', NULL, NULL, 0,
        NULL, 'empty', NULL

    UNION ALL SELECT
        'W3', 'Tomato', 'Celebrity', 1,
        CAST('2026-06-04' AS DATE), 'planted', NULL

    UNION ALL SELECT
        'W4', NULL, NULL, 0,
        NULL, 'empty', NULL

    UNION ALL SELECT
        'W5', 'Tomato', 'Early Girl', 2,
        CAST('2026-06-04' AS DATE), 'planted', NULL

    UNION ALL SELECT
        'W6', NULL, NULL, 0,
        NULL, 'empty', NULL
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
    variety_id  = VALUES(variety_id),
    plant_count = VALUES(plant_count),
    planted_date = VALUES(planted_date),
    removed_date = VALUES(removed_date),
    status       = VALUES(status),
    notes        = VALUES(notes);


COMMIT;


/******************************************************************************
 * 5. Verification — crop and variety records
 ******************************************************************************/

SELECT
    c.crop_name,
    v.variety_name,
    v.seed_source,
    v.active
FROM crop_variety v
INNER JOIN hydro_crop c
    ON c.crop_id = v.crop_id
ORDER BY
    c.crop_name,
    v.variety_name;


/******************************************************************************
 * 6. Verification — 2026 planting layout
 ******************************************************************************/

SELECT
    s.season_name,
    p.channel,
    p.position_code,
    c.crop_name,
    v.variety_name,
    sp.plant_count,
    sp.planted_date,
    sp.status
FROM hydro_season_planting sp
INNER JOIN hydro_season s
    ON s.season_id = sp.season_id
INNER JOIN hydro_position p
    ON p.position_id = sp.position_id
LEFT JOIN crop_variety v
    ON v.variety_id = sp.variety_id
LEFT JOIN hydro_crop c
    ON c.crop_id = v.crop_id
WHERE
    s.system_key = 'outside'
    AND s.season_year = 2026
ORDER BY
    CASE p.channel
        WHEN 'East' THEN 1
        WHEN 'West' THEN 2
        ELSE 3
    END,
    p.position_number;


/******************************************************************************
 * 7. Verification — expected record counts
 *
 * Expected:
 *   Crops:                 3
 *   Varieties:             8
 *   Seasons for 2026:      1
 *   Planting assignments: 13
 *   Occupied positions:    8
 *   Empty positions:       5
 ******************************************************************************/

SELECT 'Crops' AS object_name, COUNT(*) AS row_count
FROM hydro_crop

UNION ALL

SELECT 'Varieties', COUNT(*)
FROM crop_variety

UNION ALL

SELECT '2026 Seasons', COUNT(*)
FROM hydro_season
WHERE system_key = 'outside'
  AND season_year = 2026

UNION ALL

SELECT '2026 Planting Assignments', COUNT(*)
FROM hydro_season_planting sp
INNER JOIN hydro_season s
    ON s.season_id = sp.season_id
WHERE s.system_key = 'outside'
  AND s.season_year = 2026

UNION ALL

SELECT '2026 Occupied Positions', COUNT(*)
FROM hydro_season_planting sp
INNER JOIN hydro_season s
    ON s.season_id = sp.season_id
WHERE s.system_key = 'outside'
  AND s.season_year = 2026
  AND sp.status = 'planted'

UNION ALL

SELECT '2026 Empty Positions', COUNT(*)
FROM hydro_season_planting sp
INNER JOIN hydro_season s
    ON s.season_id = sp.season_id
WHERE s.system_key = 'outside'
  AND s.season_year = 2026
  AND sp.status = 'empty';