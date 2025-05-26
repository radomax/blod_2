<?php
// Database setup script - save as app/setup_db.php

// Railway database connection
$host = $_ENV['MYSQLHOST'] ?? 'localhost';
$port = $_ENV['MYSQLPORT'] ?? '3306';
$dbname = $_ENV['MYSQLDATABASE'] ?? 'railway';
$username = $_ENV['MYSQLUSER'] ?? 'root';
$password = $_ENV['MYSQLPASSWORD'] ?? '';

try {
    $pdo = new PDO("mysql:host=$host;port=$port;dbname=$dbname;charset=utf8mb4", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // Create blood pressure measurements table
    $sql = "CREATE TABLE IF NOT EXISTS blood_pressure_measurements (
        id INT AUTO_INCREMENT PRIMARY KEY,
        patient_id VARCHAR(100) NOT NULL,
        patient_age INT,
        patient_gender ENUM('male', 'female', 'other'),
        measurement_date DATE NOT NULL,
        measurement_time TIME,
        referral_source ENUM('maja', 'self', 'doctor', 'other') DEFAULT 'other',
        measurement1_sys INT,
        measurement1_dia INT,
        measurement2_sys INT NOT NULL,
        measurement2_dia INT NOT NULL,
        measurement3_sys INT NOT NULL,
        measurement3_dia INT NOT NULL,
        average_sys INT NOT NULL,
        average_dia INT NOT NULL,
        equipment VARCHAR(100),
        cuff_size ENUM('S', 'M/L', 'L/XL') DEFAULT 'M/L',
        arm_used ENUM('left', 'right') NOT NULL,
        notes TEXT,
        registered_by VARCHAR(100),
        registered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )";
    $pdo->exec($sql);

    // Create users table
    $sql = "CREATE TABLE IF NOT EXISTS users (
        id INT AUTO_INCREMENT PRIMARY KEY,
        username VARCHAR(50) UNIQUE NOT NULL,
        password_hash VARCHAR(255) NOT NULL,
        role ENUM('admin', 'user') DEFAULT 'user',
        full_name VARCHAR(100),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )";
    $pdo->exec($sql);

    // Insert default admin user
    $adminHash = password_hash('admin123', PASSWORD_DEFAULT);
    $stmt = $pdo->prepare("INSERT IGNORE INTO users (username, password_hash, role, full_name) VALUES (?, ?, ?, ?)");
    $stmt->execute(['admin', $adminHash, 'admin', 'Administrator']);

    // Insert sample blood pressure record
    $stmt = $pdo->prepare("INSERT IGNORE INTO blood_pressure_measurements 
        (patient_id, patient_age, patient_gender, measurement_date, 
         measurement2_sys, measurement2_dia, measurement3_sys, measurement3_dia, 
         average_sys, average_dia, arm_used, registered_by) 
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
    $stmt->execute(['DEMO001', 45, 'male', '2025-05-20', 135, 88, 138, 85, 137, 87, 'left', 'System']);

    echo json_encode([
        'success' => true,
        'message' => 'Database setup completed!',
        'tables' => ['blood_pressure_measurements', 'users'],
        'sample_data' => 'Demo record added'
    ]);

} catch (PDOException $e) {
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
}
?>