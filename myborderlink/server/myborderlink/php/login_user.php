<?php
error_reporting( 0 );
header( 'Access-Control-Allow-Origin: *' );
// running as crome app

if ( !isset( $_POST ) ) {
    $response = array( 'status' => 'failed', 'data' => null );
    sendJsonResponse( $response );
    die;
}

include_once( 'dbconnect.php' );

$email = $_POST[ 'email' ];
$password = sha1( $_POST[ 'password' ] );

$sqllogin = "SELECT * FROM `tbl_users` WHERE officer_id = '$id' AND officer_password = '$password'";
$result = $conn->query( $sqllogin );
if ( $result->num_rows > 0 ) {
    $sentArray = array();
    while ( $row = $result->fetch_assoc() ) {
        $sentArray[] = $row;
    }
    $response = array( 'status' => 'success', 'data' =>  $sentArray );
    sendJsonResponse( $response );
} else {
    $response = array( 'status' => 'failed', 'data' => null );
    sendJsonResponse( $response );
}

function sendJsonResponse( $response )
 {
    header( 'Content-Type: application/json' );
    echo json_encode( $response );
}

?>
