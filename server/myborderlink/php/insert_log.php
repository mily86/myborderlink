<?php

header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Content-Type');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Content-Type: application/json');

include_once('dbconnect.php');

$data = json_decode(file_get_contents('php://input'), true);

if (
    !isset($data['officer_id']) ||
    !isset($data['date']) ||
    !isset($data['vehicle_plate']) ||
    !isset($data['inspection_type']) ||
    !isset($data['findings']) ||
    !isset($data['location'])
) {
    sendJsonResponse(['status' => 'failed', 'message' => 'Missing required fields']);
    exit;
}

$officer_id = $data['officer_id'];
$date = $data['date'];
$vehicle_plate = $data['vehicle_plate'];
$inspection_type = $data['inspection_type'];
$findings = $data['findings'];
$location = $data['location'];

$stmt = $conn->prepare("INSERT INTO tbl_logs (officer_id, date, vehicle_plate, inspection_type, findings, location) VALUES (?, ?, ?, ?, ?, ?)");
$stmt->bind_param("isssss", $officer_id, $date, $vehicle_plate, $inspection_type, $findings, $location);

if ($stmt->execute()) {
    sendJsonResponse(['status' => 'success', 'message' => 'Log inserted successfully.']);
} else {
    sendJsonResponse(['status' => 'failed', 'message' => 'Insert failed: ' . $stmt->error]);
}
$stmt->close();
$conn->close();

function sendJsonResponse($response) {
    echo json_encode($response);
}
?>
