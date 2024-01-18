<?php
header('Content-Type: multipart/form-data');

$employee_id = $_POST['employee_id'];
$filename = $_FILES["image"]["name"];
$tempname = $_FILES["image"]["tmp_name"];
$fileerror = $_FILES["image"]["error"];
$folder = "images/";

if(isset($_POST["employee_id"])){

    $arrays = explode(',', $_POST['employee_id']);

    try {
        
        foreach($arrays as $key=>$value) {
            if(!is_dir($folder . $value)){
                mkdir($folder . $value, 0777, true);
            }
            if($key == 0){
                $uploaded = move_uploaded_file($tempname, $folder . $value .'/'. $filename);
                echo json_encode(array('uploaded'=>$uploaded,'key'=>$key));
            }else{
                $uploaded = copy($folder . $arrays[0] .'/'. $filename,  $folder . $value . '/' . $filename);
                echo json_encode(array('uploaded'=>$uploaded,'key'=>$key));
            }
        }
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

