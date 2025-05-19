<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

// Database configuration
$host = 'db';  // Docker service name
$dbname = 'blood_pressure_db';
$username = 'root';
$password = 'rotpassord';

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8mb4", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    error_log("Database connection failed: " . $e->getMessage());
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Database connection failed']);
    exit;
}

// Get request data
$input = json_decode(file_get_contents('php://input'), true);
$action = $input['action'] ?? $_GET['action'] ?? '';

try {
    switch ($action) {
        case 'save':
            $data = $input['data'];
            
            // Insert measurement
            $sql = "INSERT INTO blood_pressure_measurements (
                patient_id, patient_age, patient_gender, measurement_date, measurement_time,
                referral_source, measurement1_sys, measurement1_dia, measurement2_sys, measurement2_dia,
                measurement3_sys, measurement3_dia, average_sys, average_dia, equipment,
                cuff_size, arm_used, notes, registered_by, registered_at
            ) VALUES (
                :patient_id, :patient_age, :patient_gender, :measurement_date, :measurement_time,
                :referral_source, :measurement1_sys, :measurement1_dia, :measurement2_sys, :measurement2_dia,
                :measurement3_sys, :measurement3_dia, :average_sys, :average_dia, :equipment,
                :cuff_size, :arm_used, :notes, :registered_by, NOW()
            )";
            
            $stmt = $pdo->prepare($sql);
            $stmt->execute([
                ':patient_id' => $data['patientId'],
                ':patient_age' => $data['patientAge'],
                ':patient_gender' => $data['patientGender'],
                ':measurement_date' => $data['measurementDate'],
                ':measurement_time' => $data['measurementTime'],
                ':referral_source' => $data['referralSource'],
                ':measurement1_sys' => $data['measurement1Sys'],
                ':measurement1_dia' => $data['measurement1Dia'],
                ':measurement2_sys' => $data['measurement2Sys'],
                ':measurement2_dia' => $data['measurement2Dia'],
                ':measurement3_sys' => $data['measurement3Sys'],
                ':measurement3_dia' => $data['measurement3Dia'],
                ':average_sys' => $data['averageSys'],
                ':average_dia' => $data['averageDia'],
                ':equipment' => $data['equipment'],
                ':cuff_size' => $data['cuffSize'],
                ':arm_used' => $data['armUsed'],
                ':notes' => $data['notes'],
                ':registered_by' => 'System' // You can modify this to use actual user
            ]);
            
            echo json_encode([
                'success' => true,
                'message' => 'Measurement saved successfully',
                'data' => ['id' => $pdo->lastInsertId()]
            ]);
            break;
            
        case 'list':
            $limit = $_GET['limit'] ?? 100;
            $offset = $_GET['offset'] ?? 0;
            $search = $_GET['search'] ?? '';
            
            $where = '';
            $params = [];
            
            if ($search) {
                $where = " WHERE patient_id LIKE :search OR measurement_date LIKE :search";
                $params[':search'] = "%$search%";
            }
            
            $sql = "SELECT * FROM blood_pressure_measurements $where 
                    ORDER BY registered_at DESC LIMIT :limit OFFSET :offset";
            
            $stmt = $pdo->prepare($sql);
            foreach ($params as $key => $value) {
                $stmt->bindValue($key, $value);
            }
            $stmt->bindValue(':limit', (int)$limit, PDO::PARAM_INT);
            $stmt->bindValue(':offset', (int)$offset, PDO::PARAM_INT);
            $stmt->execute();
            
            $measurements = $stmt->fetchAll(PDO::FETCH_ASSOC);
            
            // Convert database field names to frontend format
            $formattedMeasurements = array_map(function($row) {
                return [
                    'id' => $row['id'],
                    'patientId' => $row['patient_id'],
                    'patientAge' => $row['patient_age'],
                    'patientGender' => $row['patient_gender'],
                    'measurementDate' => $row['measurement_date'],
                    'measurementTime' => $row['measurement_time'],
                    'referralSource' => $row['referral_source'],
                    'measurement1Sys' => $row['measurement1_sys'],
                    'measurement1Dia' => $row['measurement1_dia'],
                    'measurement2Sys' => $row['measurement2_sys'],
                    'measurement2Dia' => $row['measurement2_dia'],
                    'measurement3Sys' => $row['measurement3_sys'],
                    'measurement3Dia' => $row['measurement3_dia'],
                    'averageSys' => $row['average_sys'],
                    'averageDia' => $row['average_dia'],
                    'equipment' => $row['equipment'],
                    'cuffSize' => $row['cuff_size'],
                    'armUsed' => $row['arm_used'],
                    'notes' => $row['notes'],
                    'registeredBy' => $row['registered_by'],
                    'registeredAt' => $row['registered_at']
                ];
            }, $measurements);
            
            echo json_encode([
                'success' => true,
                'data' => $formattedMeasurements
            ]);
            break;
            
        case 'get':
            $id = $_GET['id'] ?? $input['id'] ?? null;
            if (!$id) {
                throw new Exception('Measurement ID required');
            }
            
            $stmt = $pdo->prepare("SELECT * FROM blood_pressure_measurements WHERE id = :id");
            $stmt->execute([':id' => $id]);
            $measurement = $stmt->fetch(PDO::FETCH_ASSOC);
            
            if (!$measurement) {
                throw new Exception('Measurement not found');
            }
            
            echo json_encode([
                'success' => true,
                'data' => $measurement
            ]);
            break;
            
        case 'delete':
            $id = $input['id'] ?? null;
            if (!$id) {
                throw new Exception('Measurement ID required');
            }
            
            $stmt = $pdo->prepare("DELETE FROM blood_pressure_measurements WHERE id = :id");
            $stmt->execute([':id' => $id]);
            
            echo json_encode([
                'success' => true,
                'message' => 'Measurement deleted successfully'
            ]);
            break;
            
        case 'statistics':
            // Total measurements
            $stmt = $pdo->query("SELECT COUNT(*) as total FROM blood_pressure_measurements");
            $total = $stmt->fetch(PDO::FETCH_ASSOC)['total'];
            
            // Today's measurements
            $stmt = $pdo->prepare("SELECT COUNT(*) as today FROM blood_pressure_measurements WHERE DATE(measurement_date) = CURDATE()");
            $stmt->execute();
            $today = $stmt->fetch(PDO::FETCH_ASSOC)['today'];
            
            // High BP count
            $stmt = $pdo->query("SELECT COUNT(*) as high_bp FROM blood_pressure_measurements WHERE average_sys >= 140 OR average_dia >= 90");
            $highBP = $stmt->fetch(PDO::FETCH_ASSOC)['high_bp'];
            
            // Average age
            $stmt = $pdo->query("SELECT AVG(patient_age) as avg_age FROM blood_pressure_measurements");
            $avgAge = $stmt->fetch(PDO::FETCH_ASSOC)['avg_age'];
            
            echo json_encode([
                'success' => true,
                'data' => [
                    'total' => $total,
                    'today' => $today,
                    'highBP' => $highBP,
                    'avgAge' => round($avgAge ?? 0)
                ]
            ]);
            break;
            
        default:
            throw new Exception('Invalid action');
    }
} catch (Exception $e) {
    error_log("API Error: " . $e->getMessage());
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}
?>