<?php
// Database initialization script for Railway deployment
// This script should be run once after deployment to set up the database schema

// Database configuration with Railway support
function getDatabaseConfig() {
    // Check if we have a MYSQL_URL from Railway
    if (isset($_ENV['MYSQL_URL']) && !empty($_ENV['MYSQL_URL'])) {
        $url = parse_url($_ENV['MYSQL_URL']);
        return [
            'host' => $url['host'],
            'port' => $url['port'] ?? 3306,
            'dbname' => ltrim($url['path'], '/'),
            'username' => $url['user'],
            'password' => $url['pass']
        ];
    }
    
    // Fall back to individual environment variables
    return [
        'host' => $_ENV['DB_HOST'] ?? $_ENV['MYSQLHOST'] ?? 'localhost',
        'port' => $_ENV['DB_PORT'] ?? $_ENV['MYSQLPORT'] ?? 3306,
        'dbname' => $_ENV['DB_NAME'] ?? $_ENV['MYSQLDATABASE'] ?? 'blodtrykk',
        'username' => $_ENV['DB_USER'] ?? $_ENV['MYSQLUSER'] ?? 'root',
        'password' => $_ENV['DB_PASS'] ?? $_ENV['MYSQLPASSWORD'] ?? ''
    ];
}

try {
    $config = getDatabaseConfig();
    $dsn = "mysql:host={$config['host']};port={$config['port']};dbname={$config['dbname']};charset=utf8mb4";
    $pdo = new PDO($dsn, $config['username'], $config['password']);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    echo "Connected to database successfully!\n";
    
    // Create blood_pressure_measurements table
    $sql = "CREATE TABLE IF NOT EXISTS blood_pressure_measurements (
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
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci";
    
    $pdo->exec($sql);
    echo "Created blood_pressure_measurements table successfully!\n";
    
    // Create users table
    $sql = "CREATE TABLE IF NOT EXISTS users (
        id INT PRIMARY KEY AUTO_INCREMENT,
        username VARCHAR(50) UNIQUE NOT NULL,
        password_hash VARCHAR(255) NOT NULL,
        role ENUM('user', 'admin') DEFAULT 'user',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        INDEX idx_username (username)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci";
    
    $pdo->exec($sql);
    echo "Created users table successfully!\n";
    
    // Insert default admin user if not exists
    $adminHash = password_hash('admin123', PASSWORD_DEFAULT);
    $stmt = $pdo->prepare("INSERT IGNORE INTO users (username, password_hash, role) VALUES (?, ?, ?)");
    $stmt->execute(['admin', $adminHash, 'admin']);
    echo "Default admin user created (username: admin, password: admin123)\n";
    
    // Create views for statistics
    $sql = "CREATE OR REPLACE VIEW bp_statistics AS
    SELECT 
        COUNT(*) as total_measurements,
        COUNT(CASE WHEN measurement_date = CURDATE() THEN 1 END) as today_measurements,
        COUNT(CASE WHEN average_sys >= 140 OR average_dia >= 90 THEN 1 END) as high_bp_count,
        ROUND(AVG(patient_age)) as avg_patient_age,
        COUNT(CASE WHEN referral_source = 'maja' THEN 1 END) as maja_referrals
    FROM blood_pressure_measurements";
    
    $pdo->exec($sql);
    echo "Created bp_statistics view successfully!\n";
    
    $sql = "CREATE OR REPLACE VIEW bp_categories AS
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
    FROM blood_pressure_measurements";
    
    $pdo->exec($sql);
    echo "Created bp_categories view successfully!\n";
    
    // Insert some sample data for demonstration
    $stmt = $pdo->prepare("INSERT INTO blood_pressure_measurements (
        patient_id, patient_age, patient_gender, measurement_date, measurement_time,
        referral_source, measurement1_sys, measurement1_dia, measurement2_sys, measurement2_dia,
        measurement3_sys, measurement3_dia, average_sys, average_dia, equipment,
        cuff_size, arm_used, notes
    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
    
    $sampleData = [
        ['P001', 45, 'male', date('Y-m-d'), '10:30:00', 'maja', 135, 88, 132, 86, 130, 85, 131, 86, 'microlife-b2', 'M/L', 'left', 'Sample measurement'],
        ['P002', 62, 'female', date('Y-m-d'), '11:15:00', 'self', 165, 95, 162, 93, 160, 92, 161, 93, 'microlife-b6', 'L/XL', 'right', 'High blood pressure'],
        ['P003', 38, 'female', date('Y-m-d'), '14:20:00', 'doctor', 125, 80, 122, 78, 120, 77, 121, 78, 'llp-bt', 'S', 'left', 'Normal reading']
    ];
    
    foreach ($sampleData as $data) {
        $stmt->execute($data);
    }
    
    echo "Inserted sample data successfully!\n";
    echo "\nDatabase initialization completed successfully!\n";
    
} catch (PDOException $e) {
    echo "Database initialization failed: " . $e->getMessage() . "\n";
    exit(1);
}
?>