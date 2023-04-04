<?php
require 'db_connect.php';
header('Content-Type: application/json; charset=utf-8');

// make input json
$inputJSON = file_get_contents('php://input');
$input = json_decode($inputJSON, TRUE);

if($_SERVER['REQUEST_METHOD'] == 'POST' && array_key_exists('image', $input)){
    $image = $input['image'];
    $name = $input['name'];

    // query insert image
    $sql_insert_image = 'INSERT INTO tbl_image(name, image)
    VALUES (:name,:image)';
    try {
        $insert_image = $conn->prepare($sql_insert_image);
        $insert_image->bindParam(':name', $name, PDO::PARAM_STR);
        $insert_image->bindParam(':image', $image, PDO::PARAM_STR);
        $insert_image->execute();
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