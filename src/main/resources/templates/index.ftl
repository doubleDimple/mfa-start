<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>OTP Key Management</title>
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;500;700&display=swap" rel="stylesheet">
    <style>
        body {
            font-family: 'Roboto', sans-serif;
            background-color: #f4f4f4;
            margin: 0;
            padding: 0;
            display: flex;
            flex-direction: column;
            align-items: center;
        }

        .container {
            width: 90%;
            max-width: 800px;
            background: #fff;
            margin-top: 20px;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
        }

        h1 {
            text-align: center;
            color: #333;
        }

        form, .search-form {
            display: flex;
            flex-direction: column;
            gap: 10px;
            margin-bottom: 20px;
        }

        label {
            font-weight: 500;
        }

        input[type="text"] {
            padding: 10px;
            font-size: 16px;
            border: 1px solid #ddd;
            border-radius: 4px;
            outline: none;
        }

        button {
            background-color: #007bff;
            color: #fff;
            border: none;
            padding: 10px;
            border-radius: 4px;
            font-size: 16px;
            cursor: pointer;
            transition: background-color 0.3s ease;
        }

        button:hover {
            background-color: #0056b3;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }

        table, th, td {
            border: 1px solid #ddd;
        }

        th, td {
            padding: 12px;
            text-align: center;
        }

        th {
            background-color: #f4f4f4;
            font-weight: 700;
        }

        .qr-code img {
            width: 100px;
            height: 100px;
            object-fit: cover;
        }

        .export-link {
            display: inline-block;
            margin-top: 20px;
            text-decoration: none;
            background-color: #28a745;
            color: #fff;
            padding: 10px 20px;
            border-radius: 4px;
            transition: background-color 0.3s ease;
        }

        .export-link:hover {
            background-color: #218838;
        }

        .otp-code {
            font-size: 20px;
            font-weight: 700;
            color: #d9534f;
            position: relative;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .countdown {
            font-size: 14px;
            color: #6c757d;
            display: inline-block;
            width: 40px;
        }

        .clock {
            width: 20px;
            height: 20px;
            border: 2px solid #333;
            border-radius: 50%;
            position: relative;
        }

        .clock::after {
            content: '';
            position: absolute;
            top: 50%;
            left: 50%;
            width: 8px;
            height: 1px;
            background: #333;
            transform-origin: 0 50%;
            animation: rotate 20s linear infinite;
        }

        @keyframes rotate {
            0% {
                transform: rotate(0deg);
            }
            100% {
                transform: rotate(360deg);
            }
        }

        .masked {
            cursor: pointer;
        }

        .delete-btn {
            background-color: #dc3545;
            color: white;
            border: none;
            padding: 5px 10px;
            border-radius: 4px;
            cursor: pointer;
        }

        .delete-btn:hover {
            background-color: #c82333;
        }

        @media (max-width: 600px) {
            th, td {
                font-size: 14px;
                padding: 8px;
            }

            .qr-code img {
                width: 80px;
                height: 80px;
            }
        }
    </style>
    <script>
        async function updateOtpCodes() {
            const otpElements = document.querySelectorAll('.otp-code');
            if (otpElements.length === 0) {
                return;
            }
            for (const element of otpElements) {
                const secretKey = element.getAttribute('data-secret-key');
                if (secretKey && secretKey.trim() !== '') {
                    try {
                        const response = await fetch('/generate-otp?secretKey=' + secretKey);
                        if (!response.ok) {
                            throw new Error('HTTP error! status: ' + response.status);
                        }
                        const data = await response.json();
                        element.querySelector('.otp-value').textContent = data.otpCode;
                        startCountdown(element.querySelector('.countdown'));
                    } catch (error) {
                        console.error('Error fetching OTP code:', error);
                    }
                }
            }
        }

        function startCountdown(countdownElement) {
            let countdown = 20;
            countdownElement.textContent = countdown + 's';

            const interval = setInterval(() => {
                countdown--;
                countdownElement.textContent = countdown + 's';
                if (countdown === 0) {
                    clearInterval(interval);
                }
            }, 1000);
        }

        function toggleSecretKeyVisibility(event) {
            const element = event.target;
            if (element.textContent === '******') {
                element.textContent = element.getAttribute('data-secret-key');
            } else {
                element.textContent = '******';
            }
        }

        function searchKeys() {
            const searchTerm = document.getElementById('searchInput').value.toLowerCase();
            const rows = document.querySelectorAll('tbody tr');
            rows.forEach(row => {
                const keyName = row.querySelector('td:first-child').textContent.toLowerCase();
                if (keyName.includes(searchTerm)) {
                    row.style.display = '';
                } else {
                    row.style.display = 'none';
                }
            });
        }

        async function deleteKey(keyName) {
            if (confirm('Are you sure you want to delete the key '+keyName+'?')) {
                try {
                    const csrfToken = document.querySelector('input[name="${_csrf.parameterName}"]').value;
                    const response = await fetch('/delete-key', {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/json',
                            'X-CSRF-TOKEN': csrfToken
                        },
                        body: JSON.stringify({ keyName: keyName}),
                    });
                    if (!response.ok) {
                        throw new Error('HTTP error! status: ' + response.status);
                    }
                    // Reload the page or update the table
                    location.reload();
                } catch (error) {
                    console.error('Error deleting key:', error);
                    alert('Failed to delete the key. Please try again.');
                }
            }
        }

        window.onload = () => {
            document.querySelectorAll('.masked').forEach(element => {
                element.addEventListener('click', toggleSecretKeyVisibility);
            });
            updateOtpCodes();
            setInterval(updateOtpCodes, 20000);
        };


        function enlargeQrCode(imgElement) {
            const enlargedImg = document.createElement('div');
            enlargedImg.style.position = 'fixed';
            enlargedImg.style.top = '0';
            enlargedImg.style.left = '0';
            enlargedImg.style.width = '100%';
            enlargedImg.style.height = '100%';
            enlargedImg.style.backgroundColor = 'rgba(0, 0, 0, 0.8)';
            enlargedImg.style.display = 'flex';
            enlargedImg.style.alignItems = 'center';
            enlargedImg.style.justifyContent = 'center';
            enlargedImg.style.cursor = 'pointer';

            const img = document.createElement('img');
            img.src = imgElement.src;
            img.style.width = '300px';
            img.style.height = '300px';
            img.style.backgroundColor = '#fff';
            img.style.padding = '10px';
            img.style.boxShadow = '0 4px 8px rgba(0, 0, 0, 0.2)';

            enlargedImg.appendChild(img);
            enlargedImg.onclick = () => document.body.removeChild(enlargedImg);
            document.body.appendChild(enlargedImg);
        }
    </script>
</head>
<body>
<div class="container">
    <h1>OTP Key Management</h1>

    <form action="/save-secret" method="post">
        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
        <label for="keyName">Key Name:</label>
        <input type="text" id="keyName" name="keyName" required>
        <label for="secretKey">Secret Key:</label>
        <input type="text" id="secretKey" name="secretKey" required>
        <button type="submit">Save Secret Key</button>
    </form>

    <div class="search-form">
        <label for="searchInput">Search by Key Name:</label>
        <input type="text" id="searchInput" onkeyup="searchKeys()" placeholder="Enter key name...">
    </div>

    <h2>All OTP Keys</h2>
    <table>
        <thead>
        <tr>
            <th>Key Name</th>
            <th>Secret Key</th>
            <th>Qr Code</th>
            <th>OTP Code</th>
            <th>操作</th>
        </tr>
        </thead>
        <tbody>
        <#if otpKeys?? && (otpKeys?size > 0)>
            <#list otpKeys as otpKey>
                <tr>
                    <td>${otpKey.keyName}</td>
                    <td class="masked" data-secret-key="${otpKey.secretKey}">******</td>
                    <td>
                        <img src="data:image/png;base64,${otpKey.qrCode}" alt="QR Code" style="width: 50px; height: 50px; cursor: pointer;" onclick="enlargeQrCode(this)">
                    </td>
                    <td class="otp-code" data-secret-key="${otpKey.secretKey!''}" style="display: flex; flex-direction: column; align-items: center; justify-content: center;">
                        <span class="otp-value">Loading...</span>
                        <#--<div class="clock"></div>-->
                        <span class="countdown">20s</span>
                    </td>
                    <td>
                        <button class="delete-btn" onclick="deleteKey('${otpKey.keyName}')">Delete</button>
                    </td>
                </tr>
            </#list>
        <#else>
            <tr>
                <td colspan="5">No OTP keys available</td>
            </tr>
        </#if>
        </tbody>
    </table>

    <a href="/export" class="export-link">Export All OTP Keys as CSV</a>
</div>
</body>
</html>
