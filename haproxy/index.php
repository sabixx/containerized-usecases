<?php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

// Function to get the certificate data
function get_certificate_data($cert_file) {
    if (!$cert_file) {
        throw new Exception("Certificate file path is empty.");
    }

    $cert_content = file_get_contents($cert_file);
    if ($cert_content === false) {
        throw new Exception("Unable to read certificate file: $cert_file");
    }

    $cert_info = openssl_x509_parse($cert_content);
    if ($cert_info === false) {
        throw new Exception("Unable to parse certificate: $cert_file");
    }

    $valid_from = date_create(date('Y-m-d H:i:s', $cert_info['validFrom_time_t']));
    $valid_to = date_create(date('Y-m-d H:i:s', $cert_info['validTo_time_t']));
    $validity_period = date_diff($valid_from, $valid_to);

    $key_details = openssl_pkey_get_details(openssl_pkey_get_public($cert_content));

    $data = [
        'Serial Number' => $cert_info['serialNumber'],
        'CN' => isset($cert_info['subject']['CN']) ? $cert_info['subject']['CN'] : 'N/A',
        'Location' => isset($cert_info['subject']['L']) ? $cert_info['subject']['L'] : 'N/A',
        'Organizational Unit' => isset($cert_info['subject']['OU']) ? $cert_info['subject']['OU'] : 'N/A',
        'Organization' => isset($cert_info['subject']['O']) ? $cert_info['subject']['O'] : 'N/A',
        'Issuer' => $cert_info['issuer']['CN'],
        'Valid From' => date('Y-m-d H:i:s', $cert_info['validFrom_time_t']),
        'Valid To' => date('Y-m-d H:i:s', $cert_info['validTo_time_t']),
        'Validity Period' => $validity_period->format('%y years, %m months, %d days'),
        'Signature Algorithm' => $cert_info['signatureTypeSN'],
        'Key Size' => $key_details['bits'] . ' bits',
    ];

    if (isset($cert_info['extensions']['subjectAltName'])) {
        $data['Subject Alternative Names'] = $cert_info['extensions']['subjectAltName'];
    }

    return $data;
}

// Get the original port passed by HAProxy
$original_port = $_SERVER['HTTP_X_ORIGINAL_PORT']; 

// Output the original port for debugging purposes (but make it invisible)
echo '<p style="color: #002D72;">Detected Original Port from HAProxy: ' . htmlspecialchars($original_port) . '</p>';

// Construct the certificate file path based on the original port
$cert_file = "/etc/haproxy/certs/haproxy_" . $original_port . ".pem";

// Output the certificate path (but make it invisible)
echo '<p style="color: #002D72;">Certificate Path: ' . htmlspecialchars($cert_file) . '</p>';

// Check if the certificate file exists
if (!file_exists($cert_file)) {
    die("Error: Certificate file not found for port: " . htmlspecialchars($original_port));
}

try {
    $cert_data = get_certificate_data($cert_file);
} catch (Exception $e) {
    die('Error: ' . $e->getMessage());
}
?>

<!DOCTYPE html>
<html>
<head>
    <title>Certificate Information</title>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Mulish:wght@400;600&display=swap');
        body {
            font-family: 'Mulish', sans-serif;
            background-color: #002D72;  /* CyberArk official color */
            color: #333;
            margin: 0;
            padding: 0;
            position: relative;
        }
        .container {
            width: 80%;
            margin: 50px auto;
            background: #fff;
            padding: 20px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
            position: relative;
        }
        h1 {
            text-align: center;
            color: #002D72;  /* CyberArk color */
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin: 20px 0;
        }
        th, td {
            padding: 10px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }
        th {
            background-color: #f8f8f8;
            color: #002D72;  /* CyberArk color */
        }
        tr:hover {
            background-color: #f1f1f1;
        }
        .logo {
            position: absolute;
            max-width: 225px;
            max-height: 225px;
            right: 10px;
            top: 10px;
        }
        .invisible-text {
            color: #002D72;  /* Make the text the same as the background */
        }
        .c-text {
            color: #002D72; /* CyberArk color, effectively invisible */
            display: flex;
            justify-content: center;
            margin-top: 50px;
        }
    </style>
</head>
<body>
    <div class="container">
        <img src="Venafi_CYBR_logo_R.svg" alt="Venafi CYBR Logo" class="logo">
        <h1>HA PROXY CERTIFICATE</h1>
        <table>
            <?php foreach ($cert_data as $key => $value): ?>
                <tr>
                    <th><?php echo htmlspecialchars($key); ?></th>
                    <td><?php echo htmlspecialchars($value); ?></td>
                </tr>
            <?php endforeach; ?>
        </table>
    </div>
    <div class="c-text">(C) 2024 CyberArk jens.sabitzer@cyberark.com</div>
</body>
</html>
