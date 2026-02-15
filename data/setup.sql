-- database/setup.sql
-- Football League Management System Database

CREATE DATABASE IF NOT EXISTS football_league CHARACTER SET utf8mb4 COLLATE utf8mb4_persian_ci;
USE football_league;

-- Teams Table
CREATE TABLE IF NOT EXISTS teams (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    logo TEXT,
    manager VARCHAR(255),
    stadium VARCHAR(255),
    founded INT,
    city VARCHAR(255),
    budget BIGINT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_persian_ci;

-- Players Table
CREATE TABLE IF NOT EXISTS players (
    id INT AUTO_INCREMENT PRIMARY KEY,
    team_id INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    position ENUM('GK', 'DF', 'MF', 'FW') NOT NULL,
    number INT,
    age INT,
    nationality VARCHAR(100),
    overall INT DEFAULT 60,
    pace INT DEFAULT 60,
    shooting INT DEFAULT 60,
    passing INT DEFAULT 60,
    dribbling INT DEFAULT 60,
    defending INT DEFAULT 60,
    physical INT DEFAULT 60,
    goals INT DEFAULT 0,
    assists INT DEFAULT 0,
    yellow_cards INT DEFAULT 0,
    red_cards INT DEFAULT 0,
    image TEXT,
    market_value BIGINT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (team_id) REFERENCES teams(id) ON DELETE CASCADE,
    INDEX idx_team (team_id),
    INDEX idx_position (position),
    INDEX idx_overall (overall)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_persian_ci;

-- Matches Table
CREATE TABLE IF NOT EXISTS matches (
    id INT AUTO_INCREMENT PRIMARY KEY,
    home_team_id INT NOT NULL,
    away_team_id INT NOT NULL,
    home_score INT DEFAULT 0,
    away_score INT DEFAULT 0,
    match_date DATETIME NOT NULL,
    stadium VARCHAR(255),
    status ENUM('scheduled', 'live', 'finished', 'postponed') DEFAULT 'scheduled',
    week_number INT,
    season VARCHAR(50),
    referee VARCHAR(255),
    attendance INT,
    match_stats JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (home_team_id) REFERENCES teams(id) ON DELETE CASCADE,
    FOREIGN KEY (away_team_id) REFERENCES teams(id) ON DELETE CASCADE,
    INDEX idx_date (match_date),
    INDEX idx_status (status),
    INDEX idx_season (season)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_persian_ci;

-- Transfers Table
CREATE TABLE IF NOT EXISTS transfers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    player_id INT NOT NULL,
    from_team_id INT,
    to_team_id INT NOT NULL,
    amount BIGINT NOT NULL,
    transfer_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    status ENUM('pending', 'approved', 'rejected') DEFAULT 'pending',
    transfer_type ENUM('buy', 'loan', 'free') DEFAULT 'buy',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (player_id) REFERENCES players(id) ON DELETE CASCADE,
    FOREIGN KEY (from_team_id) REFERENCES teams(id) ON DELETE SET NULL,
    FOREIGN KEY (to_team_id) REFERENCES teams(id) ON DELETE CASCADE,
    INDEX idx_status (status),
    INDEX idx_date (transfer_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_persian_ci;

-- Budgets Table
CREATE TABLE IF NOT EXISTS budgets (
    id INT AUTO_INCREMENT PRIMARY KEY,
    team_id INT NOT NULL UNIQUE,
    amount BIGINT NOT NULL DEFAULT 0,
    initial_budget BIGINT NOT NULL DEFAULT 0,
    total_spent BIGINT DEFAULT 0,
    total_earned BIGINT DEFAULT 0,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (team_id) REFERENCES teams(id) ON DELETE CASCADE,
    INDEX idx_team (team_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_persian_ci;

-- Lineups Table
CREATE TABLE IF NOT EXISTS lineups (
    id INT AUTO_INCREMENT PRIMARY KEY,
    team_id INT NOT NULL,
    formation VARCHAR(20) NOT NULL,
    lineup_data JSON NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (team_id) REFERENCES teams(id) ON DELETE CASCADE,
    INDEX idx_team (team_id),
    INDEX idx_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_persian_ci;

-- Notifications Table
CREATE TABLE IF NOT EXISTS notifications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    text TEXT NOT NULL,
    type ENUM('info', 'success', 'warning', 'error') DEFAULT 'info',
    related_team_id INT,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (related_team_id) REFERENCES teams(id) ON DELETE SET NULL,
    INDEX idx_read (is_read),
    INDEX idx_date (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_persian_ci;

-- Settings Table
CREATE TABLE IF NOT EXISTS settings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    setting_key VARCHAR(255) NOT NULL UNIQUE,
    setting_value TEXT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_key (setting_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_persian_ci;

-- User Sessions Table
CREATE TABLE IF NOT EXISTS user_sessions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(255) NOT NULL,
    role ENUM('admin', 'team', 'viewer') NOT NULL,
    team_id INT,
    session_token VARCHAR(255) NOT NULL UNIQUE,
    last_activity TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (team_id) REFERENCES teams(id) ON DELETE SET NULL,
    INDEX idx_token (session_token),
    INDEX idx_username (username)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_persian_ci;

-- Insert Default Settings
INSERT INTO settings (setting_key, setting_value) VALUES
('league_name', 'لیگ برتر فوتبال'),
('season', '2024-2025'),
('default_budget', '50000000000'),
('transfer_window_open', 'true'),
('admin_password', 'admin123'),
('allow_viewer', 'true')
ON DUPLICATE KEY UPDATE setting_value=setting_value;
