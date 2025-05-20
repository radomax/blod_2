<?php
// Database initialization script for Railway
// Run this once after deployment to create tables

// Get database connection from environment
$host = $_ENV['MYSQLHOST'] ?? $_ENV['DB_HOST'] ?? 'localhost';
$port = $_ENV['MYSQLPORT'] ?? $_ENV['DB_PORT'] ?? '3306';
$dbname = $_ENV['MYSQLDATABASE'] ?? $_ENV['DB_NAME'] ?? 'blodtrykk';
$username = $_ENV['MYSQLUSER'] ?? $_ENV['DB_USER'] ?? 'root';
$password = $_ENV['MYSQLPASSWORD'] ?? $_ENV['DB_PASSWORD'] ?? '';

try {
    $pdo = new PDO("mysql:host=$host;port=$port;dbname=$dbname;charset=utf8mb4", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // Create blood_pressure_measurements table
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
        registered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        INDEX idx_patient_id (patient_id),
        INDEX idx_measurement_date (measurement_date),
        INDEX idx_registered_at (registered_at)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci";

    $pdo->exec($sql);

    // Create users table
    $sql = "CREATE TABLE IF NOT EXISTS users (
        id INT AUTO_INCREMENT PRIMARY KEY,
        username VARCHAR(50) UNIQUE NOT NULL,
        password_hash VARCHAR(255) NOT NULL,
        role ENUM('admin', 'user') DEFAULT 'user',
        full_name VARCHAR(100),
        email VARCHAR(100),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        last_login TIMESTAMP NULL,
        active BOOLEAN DEFAULT TRUE,
        INDEX idx_username (username),
        INDEX idx_role (role)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci";

    $pdo->exec($sql);

    // Insert default users
    $adminHash = password_hash('admin123', PASSWORD_DEFAULT);
    $userHash = password_hash('user123', PASSWORD_DEFAULT);

    $stmt = $pdo->prepare("INSERT INTO users (username, password_hash, role, full_name) VALUES (?, ?, ?, ?) ON DUPLICATE KEY UPDATE id=id");
    $stmt->execute(['admin', $adminHash, 'admin', 'Administrator']);
    $stmt->execute(['ansatt', $userHash, 'user', 'Ansatt']);

    echo json_encode(['success' => true, 'message' => 'Database initialized successfully']);

} catch (PDOException $e) {
    echo json_encode(['success' => false, 'message' => 'Database error: ' . $e->getMessage()]);
}
?>