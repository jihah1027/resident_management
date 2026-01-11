<?php
error_reporting(0);
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

include_once("dbconnect.php");

// Query to get residents
$sqlload = "SELECT * FROM `residents` ORDER BY `lastUpdate` DESC";
$result = $conn->query($sqlload);

if ($result->num_rows > 0) {
    $residents = array();
    while ($row = $result->fetch_assoc()) {
        $reslist = array();
        $reslist['id'] = $row['id'];
        $reslist['name'] = $row['name'];
        $reslist['age'] = $row['age'];
        $reslist['phone'] = $row['phone'];
        $reslist['address'] = $row['address'];
        $reslist['incomeRange'] = $row['incomeRange'];
        $reslist['mukim'] = $row['mukim'];
        $reslist['kampung'] = $row['kampung'];
        $reslist['bantuan'] = $row['bantuan'];
        $reslist['lastUpdate'] = $row['lastUpdate'];
        
        // Fetch household members for this specific resident
        $resident_id = $row['id'];
        $sql_members = "SELECT * FROM `household_members` WHERE `resident_id` = '$resident_id'";
        $result_members = $conn->query($sql_members);
        
        $members = array();
        while ($m_row = $result_members->fetch_assoc()) {
            $members[] = $m_row;
        }
        $reslist['household_members'] = $members;
        
        array_push($residents, $reslist);
    }
    $response = array('status' => 'success', 'data' => $residents);
    echo json_encode($response);
} else {
    $response = array('status' => 'failed', 'message' => 'No residents found');
    echo json_encode($response);
}
?>