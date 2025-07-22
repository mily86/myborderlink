<?php

header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Content-Type');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Content-Type: application/json');

include_once('dbconnect.php');

$data = json_decode(file_get_contents('php://input'), true);

if (!isset($data['officer_id'])) {
    sendJsonResponse(['status' => 'failed', 'message' => 'Officer ID required.']);
    exit;
}

$officer_id = $data['officer_id'];

$stmt = $conn->prepare("SELECT id, date, vehicle_plate, inspection_type, findings, location FROM tbl_logs WHERE officer_id = ? ORDER BY date DESC");
$stmt->bind_param("i", $officer_id);
$stmt->execute();
$result = $stmt->get_result();

$logs = [];
while ($row = $result->fetch_assoc()) {
    $logs[] = $row;
}

sendJsonResponse(['status' => 'success', 'logs' => $logs]);

$stmt->close();
$conn->close();

function sendJsonResponse($response) {
    echo json_encode($response);
}
?>
