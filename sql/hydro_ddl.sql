CREATE TABLE hydro_season (
    season_id INT AUTO_INCREMENT PRIMARY KEY,
    system_key VARCHAR(50) NOT NULL DEFAULT 'outside',
    season_year INT NOT NULL,
    season_name VARCHAR(100) NOT NULL,
    start_date DATE NULL,
    end_date DATE NULL,
    status ENUM('planned','active','closed','archived') NOT NULL DEFAULT 'active',
    notes TEXT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_hydro_season (system_key, season_year)
);

CREATE TABLE crop_variety (
    variety_id INT AUTO_INCREMENT PRIMARY KEY,
    crop_type VARCHAR(50) NOT NULL,
    variety_name VARCHAR(100) NOT NULL,
    seed_source VARCHAR(100) NULL,
    notes TEXT NULL,
    active TINYINT(1) NOT NULL DEFAULT 1,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_crop_variety (crop_type, variety_name)
);

CREATE TABLE hydro_position (
    position_id INT AUTO_INCREMENT PRIMARY KEY,
    system_key VARCHAR(50) NOT NULL DEFAULT 'outside',
    channel VARCHAR(20) NOT NULL,
    position_code VARCHAR(10) NOT NULL,
    position_number INT NOT NULL,
    flow_order INT NOT NULL,
    active TINYINT(1) NOT NULL DEFAULT 1,
    notes TEXT NULL,
    UNIQUE KEY uq_hydro_position (system_key, position_code)
);

CREATE TABLE hydro_season_planting (
    planting_id INT AUTO_INCREMENT PRIMARY KEY,
    season_id INT NOT NULL,
    position_id INT NOT NULL,
    variety_id INT NULL,
    plant_count INT NOT NULL DEFAULT 1,
    planted_date DATE NULL,
    removed_date DATE NULL,
    status ENUM('planned','planted','removed','failed','empty') NOT NULL DEFAULT 'planted',
    notes TEXT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE hydro_season_planting
ADD UNIQUE KEY uq_season_position (season_id, position_id);
ALTER TABLE hydro_season_planting
ADD CONSTRAINT fk_planting_season
FOREIGN KEY (season_id) REFERENCES hydro_season(season_id);

ALTER TABLE hydro_season_planting
ADD CONSTRAINT fk_planting_position
FOREIGN KEY (position_id) REFERENCES hydro_position(position_id);

ALTER TABLE hydro_season_planting
ADD CONSTRAINT fk_planting_variety
FOREIGN KEY (variety_id) REFERENCES crop_variety(variety_id);


CREATE TABLE hydro_harvest (
    harvest_id INT AUTO_INCREMENT PRIMARY KEY,
    season_id INT NOT NULL,
    planting_id INT NOT NULL,
    harvested_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    harvest_count INT NULL,
    harvest_unit VARCHAR(20) NOT NULL DEFAULT 'item',
    total_weight DECIMAL(10,3) NULL,
    weight_unit ENUM('lb','oz','g','kg') NOT NULL DEFAULT 'lb',
    quality ENUM('good','mixed','poor','waste') NULL,
    notes TEXT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE hydro_harvest
ADD INDEX idx_harvest_date (harvested_at);

ALTER TABLE hydro_harvest
ADD CONSTRAINT fk_harvest_season
FOREIGN KEY (season_id) REFERENCES hydro_season(season_id);

ALTER TABLE hydro_harvest
ADD CONSTRAINT fk_harvest_planting
FOREIGN KEY (planting_id) REFERENCES hydro_season_planting(planting_id);


CREATE TABLE hydro_waste (
    waste_id INT AUTO_INCREMENT PRIMARY KEY,
    season_id INT NOT NULL,
    planting_id INT NULL,
    wasted_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    waste_type ENUM(
        'fruit_loss',
        'plant_loss',
        'disease',
        'pest',
        'damage',
        'other'
    ) NOT NULL DEFAULT 'other',
    waste_count INT NULL,
    waste_weight DECIMAL(10,3) NULL,
    weight_unit ENUM('lb','oz','g','kg') NOT NULL DEFAULT 'lb',
    reason TEXT NULL,
    notes TEXT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE hydro_waste
ADD INDEX idx_waste_date (wasted_at);

ALTER TABLE hydro_waste
ADD CONSTRAINT fk_waste_season
FOREIGN KEY (season_id)
REFERENCES hydro_season(season_id);

ALTER TABLE hydro_waste
ADD CONSTRAINT fk_waste_planting
FOREIGN KEY (planting_id)
REFERENCES hydro_season_planting(planting_id);



INSERT INTO hydro_position
(system_key, channel, position_code, position_number, flow_order, active)
VALUES
('outside','East','E1',1,1,1),
('outside','East','E2',2,2,1),
('outside','East','E3',3,3,1),
('outside','East','E4',4,4,1),
('outside','East','E5',5,5,1),
('outside','East','E6',6,6,1),
('outside','East','E7',7,7,1),
('outside','West','W1',1,1,1),
('outside','West','W2',2,2,1),
('outside','West','W3',3,3,1),
('outside','West','W4',4,4,1),
('outside','West','W5',5,5,1),
('outside','West','W6',6,6,1);