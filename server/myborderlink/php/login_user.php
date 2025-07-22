<?php

header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Content-Type');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Content-Type: application/json');

include_once('dbconnect.php');

$data = json_decode(file_get_contents('php://input'), true);

if (
    !isset($data['officer_id']) ||
    !isset($data['password'])
) {
    sendJsonResponse(['status' => 'failed', 'message' => 'Missing required fields']);
    exit;
}

$id = $data[ 'officer_id' ];
$password = $data[ 'password' ];

$sqllogin = "SELECT * FROM `tbl_officers` WHERE officer_id = ?";
$stmt = $conn->prepare($sqllogin);
$stmt->bind_param("s", $id);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    $row = $result->fetch_assoc();
    // Verify the password using password_verify
    if (password_verify($password, $row['officer_password'])) {
        unset($row['officer_password']);
        $response = array('status' => 'success', 'data' => [$row]);
        sendJsonResponse($response);
    } else {
        $response = array('status' => 'failed', 'message' => 'Invalid password');
        sendJsonResponse($response);
    }
} else {
    $response = array('status' => 'failed', 'message' => 'Officer not found');
    sendJsonResponse($response);
}

function sendJsonResponse( $response )
 {
    header( 'Content-Type: application/json' );
    echo json_encode( $response );
}

?>
