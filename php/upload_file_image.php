<?php
header('Content-Type: multipart/form-data');

$filename = $_FILES["image"]["name"];
$tempname = $_FILES["image"]["tmp_name"];
$fileerror = $_FILES["image"]["error"];
$folder = "images/";

$year = date("Y");
$month = date("m");
$day = date("d");

// var_dump($year);
// var_dump($month);
// var_dump($day);


if(isset($_FILES['image'])){

    try {

        $year_folder = $folder . $year;
        //check if year folder exist
        if(!is_dir($year_folder)){//images/2024
            mkdir($year_folder, 0777, true);
        }

        $month_folder = $folder . $year . '/' . $month;
        //check if month folder exist
        if(!is_dir($month_folder)){//images/2024/01
            mkdir($month_folder, 0777, true);
        }

        $day_folder = $folder . $year . '/' . $month . '/' . $day;
        //check if day folder exist
        if(!is_dir($day_folder)){//images/2024/01/24
            mkdir($day_folder, 0777, true);
        }

        $uploaded = move_uploaded_file($tempname, $day_folder .'/'. $filename); //images/2024/01/24/20240124110615.jpg
        echo json_encode(array('uploaded'=>$uploaded));

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

