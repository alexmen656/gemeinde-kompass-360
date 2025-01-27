<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: *');
header('Access-Control-Allow-Methods: *');
header("Content-Type: application/json");

// DB config
define('DB_HOST', 'localhost');
define('DB_NAME', 'gemeinde_api');
define('DB_USER', 'root');
define('DB_PASS', '');
?>