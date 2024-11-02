<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>OTP Key Management</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Poppins', sans-serif;
        }

        body {
            background: #f4f7fe;
            min-height: 100vh;
        }

        .layout-container {
            display: flex;
            min-height: 100vh;
        }

        .sidebar {
            width: 280px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: #fff;
            transition: all 0.3s ease;
            position: fixed;
            height: 100vh;
            z-index: 1000;
            box-shadow: 4px 0 10px rgba(0, 0, 0, 0.1);
        }

        .sidebar-header {
            padding: 30px 20px;
            text-align: center;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        }

        .logo-container {
            margin-bottom: 10px;
        }

        .logo {
            width: 50px;
            height: 50px;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 12px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            margin-bottom: 10px;
        }

        .logo span {
            font-size: 24px;
        }

        .sidebar-menu {
            padding: 20px 0;
        }

        .menu-item {
            padding: 15px 25px;
            display: flex;
            align-items: center;
            color: #fff;
            text-decoration: none;
            transition: all 0.3s;
            margin: 4px 8px;
            border-radius: 10px;
        }

        .menu-item:hover {
            background: rgba(255, 255, 255, 0.1);
            transform: translateX(5px);
        }

        .menu-item.active {
            background: rgba(255, 255, 255, 0.2);
        }

        .menu-item i {
            margin-right: 12px;
            font-size: 20px;
        }

        .main-content {
            flex: 1;
            margin-left: 280px;
            padding: 30px;
            transition: margin-left 0.3s ease;
            background: #f4f7fe;
        }

        .card {
            background: white;
            border-radius: 20px;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.05);
            padding: 25px;
            margin-bottom: 25px;
        }

        .card:hover {
            transform: translateY(-5px);
            transition: transform 0.3s ease;
        }

        .card h2 {
            color: #2d3748;
            font-size: 24px;
            margin-bottom: 20px;
            font-weight: 600;
        }

        .form-group {
            margin-bottom: 20px;
        }

        label {
            display: block;
            color: #4a5568;
            font-size: 14px;
            font-weight: 500;
            margin-bottom: 8px;
        }

        input[type="text"] {
            width: 100%;
            padding: 12px 20px;
            border: 2px solid #e2e8f0;
            border-radius: 10px;
            font-size: 14px;
            transition: all 0.3s ease;
        }

        input[type="text"]:focus {
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
            outline: none;
        }

        .file-upload {
            border: 2px dashed #e2e8f0;
            border-radius: 10px;
            padding: 20px;
            text-align: center;
            transition: all 0.3s ease;
            margin: 15px 0;
            background: #f8fafc;
        }

        .file-upload:hover {
            border-color: #667eea;
        }

        .file-upload input[type="file"] {
            display: none;
        }

        .file-upload-btn {
            display: inline-block;
            padding: 10px 20px;
            background: #e2e8f0;
            border-radius: 8px;
            color: #4a5568;
            cursor: pointer;
            transition: all 0.3s ease;
            font-weight: 500;
        }

        .file-upload-btn:hover {
            background: #cbd5e0;
        }

        .file-name {
            color: #718096;
            margin-top: 10px;
            font-size: 0.9em;
        }

        .preview-image {
            max-width: 150px;
            max-height: 150px;
            margin: 10px auto 0;
            display: none;
            border-radius: 8px;
        }

        #searchInput {
            width: 100%;
            padding: 12px 20px;
            border: 2px solid #e2e8f0;
            border-radius: 10px;
            font-size: 14px;
            transition: all 0.3s ease;
            margin-bottom: 20px;
        }

        #searchInput:focus {
            border-color: #667eea;
            box-shadow: 0 5px 15px rgba(102, 126, 234, 0.1);
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

        .countdown-container {
            position: relative;
            width: 50px;
            height: 50px;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .countdown-number {
            font-size: 16px;
            font-weight: 500;
            color: #6c757d;
            z-index: 2;
        }

        .circle-progress {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
        }

        .circle-progress circle {
            fill: none;
            stroke-width: 3;
            stroke-linecap: round;
            transform: rotate(-90deg);
            transform-origin: center;
            transition: stroke-dashoffset 1s linear;
        }

        .circle-bg {
            stroke: #e2e8f0;
        }

        .progress-circle {
            stroke: #667eea;
        }

        button {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            padding: 12px 25px;
            border-radius: 10px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        button:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(102, 126, 234, 0.4);
        }

        .delete-btn {
            background-color: #dc3545;
            padding: 6px 12px;
            font-size: 14px;
        }

        .delete-btn:hover {
            background-color: #c82333;
        }

        @media (max-width: 768px) {
            .sidebar {
                transform: translateX(-280px);
            }

            .main-content {
                margin-left: 0;
                padding: 20px;
            }

            table {
                display: block;
                overflow-x: auto;
                white-space: nowrap;
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

        /* 添加新的样式 */
        .export-btn {
            background: linear-gradient(135deg, #28a745 0%, #218838 100%);
            margin-left: 10px;
        }

        .export-btn:hover {
            background: linear-gradient(135deg, #218838 0%, #1e7e34 100%);
        }

        .paste-zone {
            border: 2px dashed #e2e8f0;
            border-radius: 10px;
            padding: 20px;
            margin: 15px 0;
            background: #f8fafc;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .paste-zone:hover {
            border-color: #667eea;
            background: #f0f4ff;
        }

        .paste-zone.dragover {
            border-color: #667eea;
            background: #f0f4ff;
        }

        .button-group {
            display: flex;
            gap: 10px;
            margin-bottom: 20px;
        }
    </style>
</head>
<body>
<div class="layout-container">
    <aside class="sidebar">
        <div class="sidebar-header">
            <div class="logo-container">
                <div class="logo">
                    <span>🔐</span>
                </div>
                <h2>OTP Management</h2>
            </div>
        </div>
        <nav class="sidebar-menu">
            <a href="#" class="menu-item active">
                <i>🔑</i>
                MFA Management
            </a>
            <a href="/settings" class="menu-item">
                <i>☁️</i>
                Sync Cloud Settings
            </a>
        </nav>
    </aside>

    <main class="main-content">
        <div class="card">
            <h2>Add New Key</h2>
            <form action="/save-secret" method="post" enctype="multipart/form-data" id="keyForm">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                <div class="form-group">
                    <label for="keyName">Key Name:</label>
                    <input type="text" id="keyName" name="keyName" required placeholder="Enter a name for this key">
                </div>
                <div class="form-group">
                    <label for="secretKey">Secret Key:</label>
                    <input type="text" id="secretKey" name="secretKey" required placeholder="Enter secret key or upload QR code">
                </div>
                <div class="file-upload" id="pasteZone">
                    <label class="file-upload-btn">
                        Upload QR Code
                        <input type="file" id="qrCode" name="qrCode" accept="image/*">
                    </label>
                    <div id="fileName">No file chosen</div>
                    <img id="previewImage" class="preview-image" alt="QR Code preview">
                    <div class="paste-zone" id="pasteArea">
                        Click or paste image here
                    </div>
                </div>
                <button type="submit">Save Key</button>
            </form>
        </div>

        <div class="card">
            <h2>Key Management</h2>
            <input type="text" id="searchInput" placeholder="Search keys..." onkeyup="searchKeys()">
            <button onclick="exportData()" class="export-btn">Export All Data</button>
            <table>
                <thead>
                <tr>
                    <th>Key Name</th>
                    <th>Key Issuer</th>
                    <th>Secret Key</th>
                    <th>QR Code</th>
                    <th>OTP Code</th>
                    <th>Create Time</th>
                    <th>Actions</th>
                </tr>
                </thead>
                <tbody>
                <#if otpKeys?? && (otpKeys?size > 0)>
                    <#list otpKeys as otpKey>
                        <tr>
                            <td>${otpKey.keyName}</td>
                            <td>${otpKey.issuer!'default'}</td>
                            <td class="masked" data-secret-key="${otpKey.secretKey}">******</td>
                            <td class="qr-code">
                                <img src="data:image/png;base64,${otpKey.qrCode}" alt="QR Code" onclick="enlargeQrCode(this)">
                            </td>
                            <td class="otp-code" data-secret-key="${otpKey.secretKey!''}">
                                <span class="otp-value">Loading...</span>
                                <div class="countdown-container">
                                    <div class="countdown-number">30</div>
                                    <svg class="circle-progress">
                                        <circle class="circle-bg" cx="25" cy="25" r="22"></circle>
                                        <circle class="progress-circle" cx="25" cy="25" r="22"></circle>
                                    </svg>
                                </div>
                            </td>
                            <td>${otpKey.createTime!'default'}</td>
                            <td>
                                <button class="delete-btn" onclick="deleteKey('${otpKey.keyName}')">Delete</button>
                            </td>
                        </tr>
                    </#list>
                <#else>
                    <tr>
                        <td colspan="6" style="text-align: center">No OTP keys available</td>
                    </tr>
                </#if>
                </tbody>
            </table>
        </div>
    </main>
</div>

<script>
    // 全局变量
    let globalUpdateTimer = null;

    // OTP代码批量更新函数
    async function updateOtpCodes() {
        const otpElements = document.querySelectorAll('.otp-code');
        if (otpElements.length === 0) return;

        const secretKeys = Array.from(otpElements)
            .map(element => element.getAttribute('data-secret-key'))
            .filter(key => key && key.trim() !== '');

        try {
            const csrfToken = document.querySelector('input[name="${_csrf.parameterName}"]').value;
            const response = await fetch('/generate-otp-batch', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRF-TOKEN': csrfToken
                },
                body: JSON.stringify({ secretKeys })
            });

            if (!response.ok) {
                throw new Error('HTTP error! status: ' + response.status);
            }

            const otpResponses = await response.json();

            // 使用Map来存储secretKey到otpCode的映射
            const otpMap = new Map(
                otpResponses.map(response => [response.secretKey, response.otpCode])
            );

            // 更新每个OTP显示
            otpElements.forEach(element => {
                const secretKey = element.getAttribute('data-secret-key');
                const otpValueElement = element.querySelector('.otp-value');
                if (otpValueElement) {
                    otpValueElement.textContent = otpMap.get(secretKey) || 'Error';
                }
            });
        } catch (error) {
            console.error('Error fetching OTP codes:', error);
            otpElements.forEach(element => {
                const otpValueElement = element.querySelector('.otp-value');
                if (otpValueElement) {
                    otpValueElement.textContent = 'Error';
                }
            });
        }
    }

    // 统一的倒计时处理函数
    function initializeCountdown() {
        const updateAllCircles = () => {
            const FULL_DASH_ARRAY = 2 * Math.PI * 22;
            const timeLeft = 30 - (Math.floor(Date.now() / 1000) % 30);

            document.querySelectorAll('.otp-code').forEach(element => {
                const numberElement = element.querySelector('.countdown-number');
                const circle = element.querySelector('.progress-circle');

                if (numberElement && circle) {
                    const progress = (timeLeft / 30) * FULL_DASH_ARRAY;
                    circle.style.strokeDasharray = FULL_DASH_ARRAY;
                    circle.style.strokeDashoffset = FULL_DASH_ARRAY - progress;
                    numberElement.textContent = timeLeft;
                }
            });

            // 当倒计时到达0时更新所有 OTP 码
            if (timeLeft === 30) {
                updateOtpCodes();
            }
        };

        // 清除可能存在的旧计时器
        if (globalUpdateTimer) {
            clearInterval(globalUpdateTimer);
        }

        // 立即执行一次
        updateAllCircles();
        // 设置新的计时器
        globalUpdateTimer = setInterval(updateAllCircles, 1000);
    }

    // 搜索功能
    function searchKeys() {
        const searchTerm = document.getElementById('searchInput').value.toLowerCase();
        const rows = document.querySelectorAll('tbody tr');

        rows.forEach(row => {
            const keyName = row.querySelector('td:first-child')?.textContent.toLowerCase();
            const shouldShow = keyName && keyName.includes(searchTerm);
            row.style.display = shouldShow ? '' : 'none';
        });
    }

    // 文件上传处理
    document.getElementById('qrCode').addEventListener('change', function(e) {
        const file = e.target.files[0];
        if (file) {
            document.getElementById('fileName').textContent = file.name;
            const reader = new FileReader();
            reader.onload = function(e) {
                const preview = document.getElementById('previewImage');
                preview.src = e.target.result;
                preview.style.display = 'block';
            }
            reader.readAsDataURL(file);
            document.getElementById('secretKey').value = '';
            document.getElementById('secretKey').readOnly = true;
        } else {
            document.getElementById('fileName').textContent = 'No file chosen';
            document.getElementById('previewImage').style.display = 'none';
            document.getElementById('secretKey').readOnly = false;
        }
    });

    // 密钥显示切换
    document.querySelectorAll('.masked').forEach(element => {
        element.addEventListener('click', function() {
            if (this.textContent === '******') {
                this.textContent = this.getAttribute('data-secret-key');
            } else {
                this.textContent = '******';
            }
        });
    });

    // 删除密钥
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
                    body: JSON.stringify({ keyName: keyName })
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

    // QR码放大显示
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

    // 页面初始化
    window.addEventListener('load', () => {
        // 初始化时获取一次 OTP 码
        updateOtpCodes();
        // 启动统一的倒计时
        initializeCountdown();
    });

    // 页面卸载时清理
    window.addEventListener('beforeunload', () => {
        if (globalUpdateTimer) {
            clearInterval(globalUpdateTimer);
        }
    });


    //文件处理
    function exportData() {
        try {
            // 获取表格数据
            const rows = [];
            const headers = ['Key Name', 'Issuer', 'Secret Key'];
            rows.push(headers);

            // 获取表格中的所有行
            document.querySelectorAll('tbody tr').forEach(function(row) {
                // 跳过"No OTP keys available"的行
                if (row.cells.length < 3) return;

                const rowData = [
                    row.cells[0].textContent,                              // Key Name
                    row.cells[1].textContent,                              // Issuer
                    row.cells[2].getAttribute('data-secret-key') || ''
                ];
                rows.push(rowData);
            });

            // 处理CSV中的特殊字符
            function processCell(cell) {
                if (cell == null) {
                    return '';
                }
                cell = cell.toString();
                if (cell.indexOf(',') >= 0 || cell.indexOf('"') >= 0 || cell.indexOf('\n') >= 0) {
                    cell = cell.replace(/"/g, '""');
                    cell = '"' + cell + '"';
                }
                return cell;
            }

            // 生成CSV内容
            const csvContent = rows
                .map(function(row) {
                    return row.map(processCell).join(',');
                })
                .join('\n');

            // 创建并下载CSV文件
            const blob = new Blob(['\ufeff' + csvContent], { type: 'text/csv;charset=utf-8' });
            const url = window.URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;

            // 生成带时间戳的文件名
            const date = new Date();
            const timestamp = date.getFullYear() + '-' +
                (date.getMonth() + 1) + '-' +
                date.getDate() + '-' +
                date.getHours() + '-' +
                date.getMinutes() + '-' +
                date.getSeconds();
            a.download = 'otp_keys_export_' + timestamp + '.csv';

            document.body.appendChild(a);
            a.click();
            window.URL.revokeObjectURL(url);
            document.body.removeChild(a);
        } catch (error) {
            console.error('Export failed:', error);
            alert('Failed to export data. Please try again.');
        }
    }

    // 添加粘贴功能
    document.addEventListener('DOMContentLoaded', function() {
        const pasteArea = document.getElementById('pasteArea');
        const previewImage = document.getElementById('previewImage');
        const fileName = document.getElementById('fileName');
        const secretKeyInput = document.getElementById('secretKey');

        // 处理粘贴事件
        document.addEventListener('paste', function(e) {
            if (e.clipboardData && e.clipboardData.items) {
                const items = e.clipboardData.items;
                for (let i = 0; i < items.length; i++) {
                    if (items[i].type.indexOf('image') !== -1) {
                        const file = items[i].getAsFile();
                        handlePastedFile(file);
                        e.preventDefault();
                        break;
                    }
                }
            }
        });

        // 处理拖放事件
        pasteArea.addEventListener('dragover', function(e) {
            e.preventDefault();
            pasteArea.classList.add('dragover');
        });

        pasteArea.addEventListener('dragleave', function(e) {
            e.preventDefault();
            pasteArea.classList.remove('dragover');
        });

        pasteArea.addEventListener('drop', function(e) {
            e.preventDefault();
            pasteArea.classList.remove('dragover');
            if (e.dataTransfer.files && e.dataTransfer.files[0]) {
                handlePastedFile(e.dataTransfer.files[0]);
            }
        });

        function handlePastedFile(file) {
            if (file && file.type.indexOf('image') !== -1) {
                const reader = new FileReader();
                reader.onload = function(e) {
                    previewImage.src = e.target.result;
                    previewImage.style.display = 'block';
                    fileName.textContent = file.name || 'Pasted image';
                    secretKeyInput.value = '';
                    secretKeyInput.readOnly = true;
                }
                reader.readAsDataURL(file);

                // 创建一个新的File对象并设置到input[type=file]
                const container = new DataTransfer();
                container.items.add(file);
                document.getElementById('qrCode').files = container.files;
            }
        }

        // 点击粘贴区域触发粘贴对话框
        pasteArea.addEventListener('click', function() {
            navigator.clipboard.read().then(clipboardItems => {
                for (const clipboardItem of clipboardItems) {
                    for (const type of clipboardItem.types) {
                        if (type.startsWith('image/')) {
                            clipboardItem.getType(type).then(blob => {
                                handlePastedFile(new File([blob], "pasted-image.png", { type: blob.type }));
                            });
                        }
                    }
                }
            }).catch(err => {
                console.log('Failed to read clipboard:', err);
            });
        });
    });
</script>
</body>
</html>
