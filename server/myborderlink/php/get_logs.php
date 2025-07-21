<?php
$connection = new mysqli("localhost", "username", "password", "database");

if ($connection->connect_error) {
    die("Connection failed: " . $connection->connect_error);
}

// Use POST instead of GET for security
$officer_id = $_POST['officer_id'];

// Prepare statement to prevent SQL injection
$sql = "SELECT * FROM logs WHERE officer_id = ?";
$stmt = $connection->prepare($sql);

if ($stmt === false) {
    die("Error preparing query: " . $connection->error);
}

// Bind the officer_id to the prepared statement
$stmt->bind_param("s", $officer_id);

// Execute the query
$stmt->execute();

// Get the result
$result = $stmt->get_result();

// Fetch logs as an associative array
$logs = array();
while ($row = $result->fetch_assoc()) {
    $logs[] = $row;
}

// Return logs as a JSON response
echo json_encode($logs);

// Close connection
$stmt->close();
$connection->close();
?>
