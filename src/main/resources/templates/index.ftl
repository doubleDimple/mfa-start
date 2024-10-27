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
            margin: 20px auto;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
        }

        h1, h2 {
            text-align: center;
            color: #333;
            margin-bottom: 20px;
        }

        .add-key-section {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 8px;
            margin-bottom: 30px;
        }

        form {
            display: flex;
            flex-direction: column;
            gap: 15px;
        }

        .form-group {
            display: flex;
            flex-direction: column;
            gap: 5px;
        }

        label {
            font-weight: 500;
            color: #555;
            margin-bottom: 5px;
        }

        input[type="text"] {
            padding: 10px;
            font-size: 16px;
            border: 1px solid #ddd;
            border-radius: 4px;
            outline: none;
            transition: border-color 0.3s;
        }

        input[type="text"]:focus {
            border-color: #007bff;
        }

        .file-upload {
            position: relative;
            display: flex;
            flex-direction: column;
            gap: 10px;
            padding: 15px;
            border: 2px dashed #ddd;
            border-radius: 8px;
            text-align: center;
            transition: border-color 0.3s;
        }

        .file-upload:hover {
            border-color: #007bff;
        }

        .file-upload input[type="file"] {
            display: none;
        }

        .file-upload-btn {
            display: inline-block;
            padding: 8px 16px;
            background-color: #e9ecef;
            color: #495057;
            border-radius: 4px;
            cursor: pointer;
            transition: all 0.3s;
        }

        .file-upload-btn:hover {
            background-color: #dde2e6;
        }

        .file-name {
            color: #6c757d;
            font-size: 0.9em;
            margin-top: 5px;
        }

        .preview-image {
            max-width: 150px;
            max-height: 150px;
            margin: 10px auto 0;
            display: none;
            border-radius: 4px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }

        button {
            background-color: #007bff;
            color: #fff;
            border: none;
            padding: 12px;
            border-radius: 4px;
            font-size: 16px;
            cursor: pointer;
            transition: background-color 0.3s;
        }

        button:hover {
            background-color: #0056b3;
        }

        .search-form {
            margin: 20px 0;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
            background-color: #fff;
        }

        th, td {
            padding: 12px;
            text-align: center;
            border: 1px solid #dee2e6;
        }

        th {
            background-color: #f8f9fa;
            font-weight: 600;
            color: #495057;
        }

        .masked {
            cursor: pointer;
            user-select: none;
        }

        .qr-code img {
            width: 50px;
            height: 50px;
            cursor: pointer;
            transition: transform 0.3s;
        }

        .qr-code img:hover {
            transform: scale(1.1);
        }

        .otp-code {
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 5px;
        }

        .otp-value {
            font-size: 18px;
            font-weight: 700;
            color: #28a745;
            font-family: monospace;
        }

        .countdown {
            font-size: 12px;
            color: #6c757d;
        }

        .delete-btn {
            background-color: #dc3545;
            padding: 6px 12px;
            font-size: 14px;
        }

        .delete-btn:hover {
            background-color: #c82333;
        }

        .empty-message {
            text-align: center;
            padding: 20px;
            color: #6c757d;
            font-style: italic;
        }

        @media (max-width: 768px) {
            .container {
                width: 95%;
                padding: 15px;
            }

            th, td {
                padding: 8px;
                font-size: 14px;
            }

            .qr-code img {
                width: 40px;
                height: 40px;
            }
        }
    </style>
</head>
<body>
<div class="container">
    <h1>OTP Key Management</h1>

    <div class="add-key-section">
        <h2>Add New Key</h2>
        <form action="/save-secret" method="post" enctype="multipart/form-data" id="keyForm">
            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>

            <div class="form-group">
                <label for="keyName">Key Name:</label>
                <input type="text" id="keyName" name="keyName" required
                       placeholder="Enter a name for this key">
            </div>

            <div class="form-group">
                <label for="secretKey">Secret Key:</label>
                <input type="text" id="secretKey" name="secretKey" required
                       placeholder="Enter secret key or upload QR code">
            </div>

            <div class="file-upload">
                <label class="file-upload-btn">
                    Upload QR Code
                    <input type="file" id="qrCode" name="qrCode" accept="image/*">
                </label>
                <div class="file-name" id="fileName">No file chosen</div>
                <img id="previewImage" class="preview-image" alt="QR Code preview">
            </div>

            <button type="submit">Save Key</button>
        </form>
    </div>

    <div class="search-form">
        <input type="text" id="searchInput" onkeyup="searchKeys()"
               placeholder="Search keys by name...">
    </div>

    <table>
        <thead>
        <tr>
            <th>Key Name</th>
            <th>Secret Key</th>
            <th>QR Code</th>
            <th>OTP Code</th>
            <th>Actions</th>
        </tr>
        </thead>
        <tbody>
        <#if otpKeys?? && (otpKeys?size > 0)>
            <#list otpKeys as otpKey>
                <tr>
                    <td>${otpKey.keyName}</td>
                    <td class="masked" data-secret-key="${otpKey.secretKey}">******</td>
                    <td class="qr-code">
                        <img src="data:image/png;base64,${otpKey.qrCode}"
                             alt="QR Code" onclick="enlargeQrCode(this)">
                    </td>
                    <td class="otp-code" data-secret-key="${otpKey.secretKey!''}">
                        <span class="otp-value">Loading...</span>
                        <span class="countdown">60s</span>
                    </td>
                    <td>
                        <button class="delete-btn" onclick="deleteKey('${otpKey.keyName}')">Delete</button>
                    </td>
                </tr>
            </#list>
        <#else>
            <tr>
                <td colspan="5" class="empty-message">No OTP keys available</td>
            </tr>
        </#if>
        </tbody>
    </table>
</div>

<script>
    document.getElementById('qrCode').addEventListener('change', function(e) {
        const file = e.target.files[0];
        if (file) {
            // 更新文件名显示
            document.getElementById('fileName').textContent = file.name;

            // 显示预览图
            const reader = new FileReader();
            reader.onload = function(e) {
                const preview = document.getElementById('previewImage');
                preview.src = e.target.result;
                preview.style.display = 'block';
            }
            reader.readAsDataURL(file);

            // 禁用 secretKey 输入
            document.getElementById('secretKey').value = '';
            document.getElementById('secretKey').readOnly = true;
        } else {
            // 重置显示
            document.getElementById('fileName').textContent = 'No file chosen';
            document.getElementById('previewImage').style.display = 'none';
            document.getElementById('secretKey').readOnly = false;
        }
    });

    // 保留原有的函数...
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

    async function updateOtpCodes() {
        const otpElements = document.querySelectorAll('.otp-code');
        if (otpElements.length === 0) return;

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
        let countdown = 60;
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

    async function deleteKey(keyName) {
        if (confirm('Are you sure you want to delete the key ' + keyName + '?')) {
            try {
                const csrfToken = document.querySelector('input[name="${_csrf.parameterName}"]').value;
                const response = await fetch('/delete-key', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'X-CSRF-TOKEN': csrfToken
                    },
                    body: JSON.stringify({ keyName: keyName }),
                });
                if (!response.ok) {
                    throw new Error('HTTP error! status: ' + response.status);
                }
                location.reload();
            } catch (error) {
                console.error('Error deleting key:', error);
                alert('Failed to delete the key. Please try again.');
            }
        }
    }

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
        enlargedImg.style.zIndex = '1000';

        const img = document.createElement('img');
        img.src = imgElement.src;
        img.style.width = '300px';
        img.style.height = '300px';
        img.style.backgroundColor = '#fff';
        img.style.padding = '10px';
        img.style.borderRadius = '8px';
        img.style.boxShadow = '0 4px 8px rgba(0, 0, 0, 0.2)';

        enlargedImg.appendChild(img);
        enlargedImg.onclick = () => document.body.removeChild(enlargedImg);
        document.body.appendChild(enlargedImg);
    }

    window.onload = () => {
        document.querySelectorAll('.masked').forEach(element => {
            element.addEventListener('click', toggleSecretKeyVisibility);
        });
        updateOtpCodes();
        setInterval(updateOtpCodes, 60000);
    };
</script>
</body>
</html>