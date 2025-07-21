<?php
error_reporting(E_ALL);
header('Access-Control-Allow-Origin: *'); 

// Check if POST data is available
if (!isset($_POST['date'], $_POST['vehicle'], $_POST['inspection_type'], $_POST['findings'], $_POST['location'], $_POST['officer_id'])) {
    echo json_encode(["success" => false, "message" => "Missing required fields"]);
    exit();
}

// Include database connection
include_once('dbconnect.php');

// Retrieve POST data
$date = $_POST['date'];
$vehicle = $_POST['vehicle'];
$inspection_type = $_POST['inspection_type'];
$findings = $_POST['findings'];
$location = $_POST['location'];
$officer_id = $_POST['officer_id'];

// Validate required fields
if (empty($date) || empty($vehicle) || empty($inspection_type) || empty($findings) || empty($location) || empty($officer_id)) {
    echo json_encode(["success" => false, "message" => "All fields are required"]);
    exit();
}


// Prepare the SQL statement to insert the data securely
$sqlinsert = "INSERT INTO tbl_logs (log_date, vehicle_plate_number, inspection_type, findings, location, officer_id) 
              VALUES (?, ?, ?, ?, ?, ?)";

// Prepare the statement
$stmt = $conn->prepare($sqlinsert);

// Check for errors in the prepared statement
if ($stmt === false) {
    echo json_encode(["success" => false, "message" => "Error preparing the SQL query: " . $conn->error]);
    exit();
}

// Bind parameters to the prepared statement
$stmt->bind_param("sssssi", $date, $vehicle, $inspection_type, $findings, $location, $officer_id);

// Execute the statement
try {
    if ($stmt->execute()) {
        echo json_encode(["success" => true, "message" => "Log added successfully."]);
    } else {
        echo json_encode(["success" => false, "message" => "Error executing query: " . $stmt->error]);
    }
} catch (Exception $e) {
    echo json_encode(["success" => false, "message" => "Exception: " . $e->getMessage()]);
    die();
}

// Close the statement and connection
$stmt->close();
$conn->close();

// Function to send a JSON response
function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}
?>
