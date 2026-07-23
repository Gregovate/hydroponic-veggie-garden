/*
 * Hydroponics Crop and Variety Reference Data
 *
 * Purpose:
 *   Seed crop and crop-variety reference tables used by planting,
 *   harvest, and waste workflows.
 */

START TRANSACTION;

INSERT INTO hydro_crop (crop_name, active, notes)
VALUES
    ('Tomato', 1, NULL),
    ('Pepper', 1, NULL),
    ('Eggplant', 1, NULL)
ON DUPLICATE KEY UPDATE
    active = VALUES(active);

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
    UNION ALL SELECT 'Tomato', 'Wisconsin 55'
    UNION ALL SELECT 'Tomato', 'Old German'
    UNION ALL SELECT 'Tomato', 'Yellow Pear'
    UNION ALL SELECT 'Tomato', 'Celebrity'
    UNION ALL SELECT 'Tomato', 'Early Girl'
    UNION ALL SELECT 'Pepper', 'Sweet Bell'
    UNION ALL SELECT 'Eggplant', 'Whopper'
) AS seed
INNER JOIN hydro_crop c
    ON c.crop_name = seed.crop_name
ON DUPLICATE KEY UPDATE
    active = VALUES(active);

COMMIT;
