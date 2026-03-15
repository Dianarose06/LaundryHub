<?php
// Load .env file
$env_file = '.env';
if (file_exists($env_file)) {
    $lines = file($env_file, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
    foreach ($lines as $line) {
        if (strpos($line, '=') !== false && $line[0] !== '#') {
            list($key, $value) = explode('=', $line, 2);
            putenv(trim($key) . '=' . trim($value));
        }
    }
}

$conn = new mysqli(
    getenv('DB_HOST'),
    getenv('DB_USERNAME'),
    getenv('DB_PASSWORD'),
    getenv('DB_DATABASE'),
    getenv('DB_PORT')
);
if ($conn->connect_error) die('Connection failed: ' . $conn->connect_error);

echo "=== ORDERS TABLE SCHEMA ===\n";
$result = $conn->query('DESCRIBE orders');
while ($row = $result->fetch_assoc()) {
  echo $row['Field'] . ' | ' . $row['Type'] . " | Null: " . $row['Null'] . "\n";
}

echo "\n=== ACTIVE SERVICES ===\n";
$result = $conn->query('SELECT id, name, price_per_kg FROM services WHERE is_active = 1 ORDER BY id');
while ($row = $result->fetch_assoc()) {
  echo $row['id'] . ' | ' . $row['name'] . ' | ₱' . $row['price_per_kg'] . "\n";
}

echo "\n=== RECENT ORDER SAMPLE ===\n";
$result = $conn->query('SELECT id, service_id, weight_kg, total_price, delivery_type, status FROM orders ORDER BY id DESC LIMIT 3');
while ($row = $result->fetch_assoc()) {
  echo "ID: " . $row['id'] . " | Service: " . $row['service_id'] . " | Weight: " . $row['weight_kg'] . "kg | Price: ₱" . $row['total_price'] . " | Type: " . $row['delivery_type'] . " | Status: " . $row['status'] . "\n";
}

$conn->close();
?>
