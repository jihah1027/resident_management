<?php
// Set error reporting to 0 for production, or E_ALL for debugging
error_reporting(E_ALL); 
ini_set('display_errors', 1);

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

include_once("dbconnect.php");

if ($_SERVER['REQUEST_METHOD'] === 'POST') {

    // DEBUGGING: This creates a file named 'debug_log.txt' on your server.
    // Check this file to see exactly what your Flutter app is sending.
    file_put_contents("debug_log.txt", "Received POST data: " . print_r($_POST, true));

    // 1. Validate the Resident ID
    // Note: If your app sends 'resident_id' instead of 'id', change this line.
    if (!isset($_POST['id']) || empty($_POST['id'])) {
        echo json_encode(array("status" => "failed", "message" => "Missing resident ID"));
        die;
    }

    $id = intval($_POST['id']);
    $name = $_POST['name'] ?? '';
    $age = intval($_POST['age'] ?? 0);
    $phone = $_POST['phone'] ?? '';
    $address = $_POST['address'] ?? '';
    $incomeRange = $_POST['incomeRange'] ?? '';
    $mukim = $_POST['mukim'] ?? '';
    $kampung = $_POST['kampung'] ?? '';
    $bantuan = $_POST['bantuan'] ?? '';
    $lastUpdate = date("Y-m-d");

    // Handle household JSON
    $household_json = isset($_POST['household']) ? $_POST['household'] : '[]'; 
    $household_members = json_decode(stripslashes($household_json), true);

    $conn->begin_transaction();

    try {
        // 2. Update the main Resident (KIR) using Prepared Statements
        $sql = "UPDATE `residents` SET 
                `name` = ?, 
                `age` = ?, 
                `phone` = ?, 
                `address` = ?, 
                `incomeRange` = ?, 
                `mukim` = ?, 
                `kampung` = ?, 
                `bantuan` = ?, 
                `lastUpdate` = ? 
                WHERE `id` = ?";

        $stmt = $conn->prepare($sql);
        $stmt->bind_param("sisssssssi", 
            $name, 
            $age, 
            $phone, 
            $address, 
            $incomeRange, 
            $mukim, 
            $kampung, 
            $bantuan, 
            $lastUpdate, 
            $id
        );

        if (!$stmt->execute()) {
            throw new Exception("Update KIR failed: " . $stmt->error);
        }

        // 3. Sync Household Members
        // First delete existing ones
        $sql_delete = "DELETE FROM `household_members` WHERE `resident_id` = ?";
        $stmt_del = $conn->prepare($sql_delete);
        $stmt_del->bind_param("i", $id);
        $stmt_del->execute();

        // Then insert new list (Secure Loop)
        if (!empty($household_members) && is_array($household_members)) {
            $sql_member = "INSERT INTO `household_members`(`resident_id`, `name`, `relation`, `age`, `status`) VALUES (?, ?, ?, ?, ?)";
            $stmt_m = $conn->prepare($sql_member);

            foreach ($household_members as $member) {
                $m_name = $member['name'] ?? '';
                $m_relation = $member['relation'] ?? '';
                $m_age = $member['age'] ?? '';
                $m_status = $member['status'] ?? '';

                $stmt_m->bind_param("issss", $id, $m_name, $m_relation, $m_age, $m_status);
                
                if (!$stmt_m->execute()) {
                    throw new Exception("Failed to insert household member: " . $stmt_m->error);
                }
            }
        }

        $conn->commit();
        echo json_encode(array("status" => "success", "message" => "Update successful"));

    } catch (Exception $e) {
        $conn->rollback();
        echo json_encode(array("status" => "failed", "message" => $e->getMessage()));
    }

} else {
    echo json_encode(array("status" => "failed", "message" => "Invalid request method"));
}
?>