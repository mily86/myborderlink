<?php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Content-Type');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Content-Type: application/json');

include_once('dbconnect.php');

// Decode JSON input
$data = json_decode(file_get_contents("php://input"), true);

// Validate required fields
if (
    !isset($data['officer_id']) ||
    !isset($data['full_name']) ||
    !isset($data['email']) ||
    !isset($data['password']) ||
    !isset($data['checkpoint_location'])
) {
    sendJsonResponse(['status' => 'failed', 'message' => 'Missing required fields']);
    exit;
}

// Assign variables
$officer_id = (int)$data['officer_id']; // Treat as integer
$full_name = $data['full_name'];
$email = $data['email'];
$password = $data['password'];
$checkpoint = $data['checkpoint_location'];
$password_hash = password_hash($password, PASSWORD_DEFAULT);

// Check if email or officer ID already exists
$checkSql = "SELECT officer_id FROM tbl_officers WHERE officer_email = ? OR officer_id = ?";
$checkStmt = $conn->prepare($checkSql);
$checkStmt->bind_param("si", $email, $officer_id); // officer_id as integer
$checkStmt->execute();
$checkStmt->store_result();

if ($checkStmt->num_rows > 0) {
    sendJsonResponse(['status' => 'failed', 'message' => 'Email or Officer ID already registered']);
    exit;
}

// Insert officer data
$sql = "INSERT INTO tbl_officers (officer_id, officer_fullname, officer_email, officer_password, officer_checkpoint)
        VALUES (?, ?, ?, ?, ?)";
$stmt = $conn->prepare($sql);
$stmt->bind_param("issss", $officer_id, $full_name, $email, $password_hash, $checkpoint);

if ($stmt->execute()) {
    sendJsonResponse(['status' => 'success', 'message' => 'Registration successful']);
} else {
    sendJsonResponse(['status' => 'failed', 'message' => 'Database error: ' . $stmt->error]);
}

function sendJsonResponse($response) {
    echo json_encode($response);
}
?>
