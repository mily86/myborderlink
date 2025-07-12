<?php

header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Content-Type');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Content-Type: application/json');

include_once('dbconnect.php');

$data = json_decode(file_get_contents("php://input"), true);

// ✅ Check for required fields, including officer_id
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

$officer_id = $data['officer_id'];
$full_name = $data['full_name'];
$email = $data['email'];
$password = $data['password'];
$checkpoint = $data['checkpoint_location'];
$password_hash = password_hash($password, PASSWORD_DEFAULT);

// ✅ Check if officer_id or email already exists
$checkSql = "SELECT officer_id FROM tbl_officers WHERE officer_id = ? OR officer_email = ?";
$checkStmt = $conn->prepare($checkSql);
$checkStmt->bind_param("ss", $officer_id, $email);
$checkStmt->execute();
$checkStmt->store_result();

if ($checkStmt->num_rows > 0) {
    sendJsonResponse(['status' => 'failed', 'message' => 'Officer ID or Email already registered']);
    exit;
}

// ✅ Insert officer data into database
$sql = "INSERT INTO tbl_officers (officer_id, officer_fullname, officer_email, officer_password, officer_checkpoint)
        VALUES (?, ?, ?, ?, ?)";
$stmt = $conn->prepare($sql);
$stmt->bind_param("sssss", $officer_id, $full_name, $email, $password_hash, $checkpoint);

if ($stmt->execute()) {
    sendJsonResponse(['status' => 'success', 'message' => 'Registration successful']);
} else {
    sendJsonResponse(['status' => 'failed', 'message' => 'Database error: ' . $stmt->error]);
}

function sendJsonResponse($response) {
    echo json_encode($response);
}
?>


