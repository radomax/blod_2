-- Database schema for blood pressure measurements system


CREATE DATABASE IF NOT EXISTS blood_pressure_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE blood_pressure_db;

-- Table for storing blood pressure measurements
CREATE TABLE blood_pressure_measurements (
    id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id VARCHAR(50) NOT NULL,
    patient_age INT NOT NULL,
    patient_gender ENUM('male', 'female', 'other') NOT NULL,
    measurement_date DATE NOT NULL,
    measurement_time TIME NOT NULL,
    referral_source ENUM('maja', 'self', 'doctor', 'other') NOT NULL,
    measurement1_sys INT NULL,
    measurement1_dia INT NULL,
    measurement2_sys INT NOT NULL,
    measurement2_dia INT NOT NULL,
    measurement3_sys INT NOT NULL,
    measurement3_dia INT NOT NULL,
    average_sys INT NOT NULL,
    average_dia INT NOT NULL,
    equipment VARCHAR(50) DEFAULT 'microlife-b2',
    cuff_size ENUM('S', 'M/L', 'L/XL') DEFAULT 'M/L',
    arm_used ENUM('left', 'right') NOT NULL,
    notes TEXT,
    registered_by VARCHAR(100) DEFAULT 'System',
    registered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_patient_id (patient_id),
    INDEX idx_measurement_date (measurement_date),
    INDEX idx_registered_at (registered_at)
);

-- Table for user authentication (optional)
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('user', 'admin') DEFAULT 'user',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert sample admin user (password: 'admin123')
INSERT INTO users (username, password_hash, role) 
VALUES ('admin', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin');

-- Views for easy data analysis
CREATE VIEW bp_statistics AS
SELECT 
    COUNT(*) as total_measurements,
    COUNT(CASE WHEN measurement_date = CURDATE() THEN 1 END) as today_measurements,
    COUNT(CASE WHEN average_sys >= 140 OR average_dia >= 90 THEN 1 END) as high_bp_count,
    ROUND(AVG(patient_age)) as avg_patient_age,
    COUNT(CASE WHEN referral_source = 'maja' THEN 1 END) as maja_referrals
FROM blood_pressure_measurements;

CREATE VIEW bp_categories AS
SELECT 
    id,
    patient_id,
    average_sys,
    average_dia,
    CASE 
        WHEN average_sys < 130 AND average_dia < 85 THEN 'Normal'
        WHEN average_sys < 140 AND average_dia < 90 THEN 'High Normal'
        WHEN average_sys < 180 AND average_dia < 110 THEN 'High'
        ELSE 'Very High'
    END as bp_category,
    measurement_date
FROM blood_pressure_measurements;