<?php
error_reporting(0);
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

include_once("dbconnect.php");

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Check if ID is provided
    if (!isset($_POST['id']) || empty($_POST['id'])) {
        echo json_encode(array("status" => "failed", "message" => "Missing resident ID"));
        die;
    }

    $id = intval($_POST['id']);

    // Start Transaction to ensure both deletions happen or none at all
    $conn->begin_transaction();

    try {
        // 1. Delete household members first (Foreign Key constraint safety)
        // We use a prepared statement to securely remove all associated members
        $sql_members = "DELETE FROM `household_members` WHERE `resident_id` = ?";
        $stmt_members = $conn->prepare($sql_members);
        $stmt_members->bind_param("i", $id);
        
        if (!$stmt_members->execute()) {
             throw new Exception("Gagal memadam ahli isi rumah: " . $conn->error);
        }

        // 2. Delete the resident (KIR)
        $sql_resident = "DELETE FROM `residents` WHERE `id` = ?";
        $stmt_resident = $conn->prepare($sql_resident);
        $stmt_resident->bind_param("i", $id);

        if ($stmt_resident->execute()) {
            if ($stmt_resident->affected_rows > 0) {
                // Success - Commit changes to both tables
                $conn->commit();
                $response = array("status" => "success", "message" => "Resident and household members deleted successfully");
            } else {
                // No record found with that ID
                $conn->rollback();
                $response = array("status" => "failed", "message" => "No record found with that ID");
            }
        } else {
            throw new Exception("Delete KIR failed: " . $conn->error);
        }

    } catch (Exception $e) {
        // Rollback on error to prevent partial data loss
        $conn->rollback();
        $response = array("status" => "failed", "message" => $e->getMessage());
    }

    echo json_encode($response);
} else {
    echo json_encode(array("status" => "failed", "message" => "Invalid request method"));
}
?>