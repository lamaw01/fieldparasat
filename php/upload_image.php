<?php
require '../db_connect.php';
header('Content-Type: application/json; charset=utf-8');

// make input json
$inputJSON = file_get_contents('php://input');
$input = json_decode($inputJSON, TRUE);

if($_SERVER['REQUEST_METHOD'] == 'POST' && array_key_exists('employee_id', $input)){
    $employee_id = $input['employee_id'];
    // var_dump($employee_id);
    $latlng = $input['latlng'];
    $address = $input['address'];
    $is_selfie = $input['is_selfie'];
    $department = $input['department'];
    $team = $input['team'];
    $selfie_timestamp = $input['selfie_timestamp'];
    $log_type = $input['log_type'];
    $device_id = $input['device_id'];
    $app = $input['app'];
    $version = $input['version'];
    $image_path = $input['image_path'];
    $foldername = "images/";    

    // query insert image
    $sql_insert_image = 'INSERT INTO tbl_logs(employee_id, latlng, address, is_selfie, department, team, selfie_timestamp, log_type, device_id, app, version, image_path)
    VALUES (:employee_id,:latlng,:address,:is_selfie,:department,:team,:selfie_timestamp,:log_type,:device_id,:app,:version,:image_path)';
    try {
        // loop array of id
        foreach ($employee_id as $id) {
            $path_file = $foldername . $id . '/' . $image_path;

            $insert_image = $conn->prepare($sql_insert_image);
            $insert_image->bindParam(':employee_id', $id, PDO::PARAM_STR);
            $insert_image->bindParam(':latlng', $latlng, PDO::PARAM_STR);
            $insert_image->bindParam(':address', $address, PDO::PARAM_STR);
            $insert_image->bindParam(':is_selfie', $is_selfie, PDO::PARAM_BOOL);
            $insert_image->bindParam(':department', $department, PDO::PARAM_STR);
            $insert_image->bindParam(':team', $team, PDO::PARAM_STR);
            $insert_image->bindParam(':selfie_timestamp', $selfie_timestamp, PDO::PARAM_STR);
            $insert_image->bindParam(':log_type', $log_type, PDO::PARAM_STR);
            $insert_image->bindParam(':device_id', $device_id, PDO::PARAM_STR);
            $insert_image->bindParam(':app', $app, PDO::PARAM_STR);
            $insert_image->bindParam(':version', $version, PDO::PARAM_STR);
            $insert_image->bindParam(':image_path', $path_file, PDO::PARAM_STR);
            $insert_image->execute();
        }
        echo json_encode(array('success'=>true,'message'=>'Ok'));
    } catch (PDOException $e) {
        echo json_encode(array('success'=>false,'message'=>$e->getMessage()));
    } finally{
        // Closing the connection.
        $conn = null;
    }
}else{
    echo json_encode(array('success'=>false,'message'=>'Error input'));
    die();
}

?>