<?php
// Test database connection
$host = $_ENV['DB_HOST'] ?? 'db';
$dbname = $_ENV['DB_NAME'] ?? 'blodtrykk';
$username = $_ENV['DB_USER'] ?? 'rado';
$password = $_ENV['DB_PASS'] ?? '2505';

echo "Host: $host\n";
echo "Database: $dbname\n";
echo "Username: $username\n";
echo "Password: " . (strlen($password) > 0 ? str_repeat('*', strlen($password)) : 'EMPTY') . "\n";

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8mb4", $username, $password);
    echo "Connection successful!";
} catch (PDOException $e) {
    echo "Connection failed: " . $e->getMessage();
}
?>