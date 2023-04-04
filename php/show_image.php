<?php
require 'db_connect.php';
header("Content-type: image/jpeg");

$id = $_GET['id'];

// query select image
$sql_insert_image = 'SELECT * from tbl_image
WHERE id = :id';

try {
    $insert_image = $conn->prepare($sql_insert_image);
    $insert_image->bindParam(':id', $id, PDO::PARAM_STR);
    $insert_image->execute();
    $result_insert_image = $insert_image->fetch(PDO::FETCH_ASSOC);
    $code_base64 = $result_insert_image['image'];
    $code_base64 = str_replace('data:image/jpeg;base64,','',$code_base64);
    $code_binary = base64_decode($code_base64);
    $image2= imagecreatefromstring($code_binary);
    imagejpeg($image2);
    // imagedestroy($image2);
    // echo base64_decode($image2);
    //  echo '<img src="data:image/jpeg;base64,'. base64_encode($image) .'" />';
    //  echo json_encode(array('success'=>true,'message'=>$name));
} catch (PDOException $e) {
    echo json_encode(array('success'=>false,'message'=>$e->getMessage()));
} finally{
    // Closing the connection.
    $conn = null;
}

?>