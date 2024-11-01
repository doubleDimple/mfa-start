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

        /* 布局容器 */
        .layout-container {
            display: flex;
            min-height: 100vh;
        }

        /* 侧边栏样式 */
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

        /* 主内容区 */
        .main-content {
            flex: 1;
            margin-left: 280px;
            padding: 30px;
            transition: margin-left 0.3s ease;
            background: #f4f7fe;
        }

        /* 切换按钮 */
        .toggle-sidebar {
            position: fixed;
            left: 280px;
            top: 20px;
            background: #764ba2;
            color: white;
            border: none;
            width: 35px;
            height: 35px;
            border-radius: 0 10px 10px 0;
            cursor: pointer;
            transition: all 0.3s ease;
            z-index: 1001;
            display: none;
            align-items: center;
            justify-content: center;
            box-shadow: 4px 0 10px rgba(0, 0, 0, 0.1);
        }

        .toggle-sidebar:hover {
            background: #667eea;
        }

        /* 卡片样式 */
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

        /* 表单元素样式 */
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

        /* 文件上传区域样式 */
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

        /* 搜索框样式 */
        .search-form {
            margin-bottom: 20px;
        }

        #searchInput {
            width: 100%;
            padding: 12px 20px;
            border: 2px solid #e2e8f0;
            border-radius: 10px;
            font-size: 14px;
            transition: all 0.3s ease;
        }

        #searchInput:focus {
            border-color: #667eea;
            box-shadow: 0 5px 15px rgba(102, 126, 234, 0.1);
        }

        /* 表格样式 */
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

        /* QR码样式 */
        .qr-code img {
            width: 50px;
            height: 50px;
            cursor: pointer;
            transition: transform 0.3s;
        }

        .qr-code img:hover {
            transform: scale(1.1);
        }

        /* OTP代码样式 */
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

        /* 按钮样式 */
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

        /* 删除按钮样式 */
        .delete-btn {
            background-color: #dc3545;
            padding: 6px 12px;
            font-size: 14px;
        }

        .delete-btn:hover {
            background-color: #c82333;
        }

        /* 空消息样式 */
        .empty-message {
            text-align: center;
            padding: 20px;
            color: #6c757d;
            font-style: italic;
        }

        /* 遮罩层 */
        .overlay {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: rgba(0, 0, 0, 0.5);
            z-index: 999;
            backdrop-filter: blur(2px);
        }

        .overlay.active {
            display: block;
        }

        /* 响应式设计 */
        @media (max-width: 768px) {
            .toggle-sidebar {
                display: flex;
                left: 0;
            }

            .toggle-sidebar.active {
                left: 280px;
            }

            .sidebar {
                transform: translateX(-280px);
            }

            .sidebar.active {
                transform: translateX(0);
            }

            .main-content {
                margin-left: 0;
                padding: 20px;
            }

            th, td {
                padding: 8px;
                font-size: 14px;
            }

            .qr-code img {
                width: 40px;
                height: 40px;
            }

            table {
                display: block;
                overflow-x: auto;
                white-space: nowrap;
            }
        }

        @media (min-width: 769px) {
            .toggle-sidebar {
                display: none;
            }

            .sidebar {
                transform: none;
            }

            .main-content {
                margin-left: 280px;
            }

            .overlay {
                display: none !important;
            }
        }

        /* 在原有样式的基础上添加 */
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

        .paste-tip {
            color: #718096;
            margin-top: 10px;
            font-size: 0.9em;
            font-style: italic;
        }

        .file-upload.dragover {
            border-color: #667eea;
            background: rgba(102, 126, 234, 0.05);
        }
    </style>
</head>
<body>
<div class="layout-container">
    <!-- 侧边栏 -->
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
            <a href="#" class="menu-item">
                <i>⚙️</i>
                System Settings
            </a>
        </nav>
    </aside>

    <!-- 切换按钮 -->
    <button class="toggle-sidebar">
        ➡️
    </button>

    <!-- 遮罩层 -->
    <div class="overlay"></div>

    <!-- 主内容区 -->
    <main class="main-content">
        <!-- 添加密钥卡片 -->
        <div class="card">
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

                <div class="file-upload" id="pasteZone">
                    <label class="file-upload-btn">
                        Upload QR Code
                        <input type="file" id="qrCode" name="qrCode" accept="image/*">
                    </label>
                    <div class="paste-tip">Or paste the image directly (Ctrl+V) / drag the image here</div>
                    <div id="fileName">No file chosen</div>
                    <img id="previewImage" class="preview-image" alt="QR Code preview">
                </div>

                <button type="submit">Save Key</button>
            </form>
        </div>

        <!-- 密钥列表卡片 -->
        <div class="card">
            <h2>Key Management</h2>
            <input type="text" id="searchInput" placeholder="Search keys..." onkeyup="searchKeys()">

            <table>
                <thead>
                <tr>
                    <th>Key Name</th>
                    <th>Key Issuer</th>
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
                            <td>${otpKey.issuer!'default'}</td>
                            <td class="masked" data-secret-key="${otpKey.secretKey}">******</td>
                            <td class="qr-code">
                                <img src="data:image/png;base64,${otpKey.qrCode}"
                                     alt="QR Code" onclick="enlargeQrCode(this)">
                            </td>
                            <!-- 找到 OTP Code 这一列，将其改为： -->
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
    // 侧边栏控制
    const sidebar = document.querySelector('.sidebar');
    const mainContent = document.querySelector('.main-content');
    const toggleBtn = document.querySelector('.toggle-sidebar');
    const overlay = document.querySelector('.overlay');

    function toggleSidebar() {
        if (window.innerWidth <= 768) {
            sidebar.classList.toggle('active');
            toggleBtn.classList.toggle('active');
            overlay.classList.toggle('active');
            toggleBtn.innerHTML = sidebar.classList.contains('active') ? '⬅️' : '➡️';
        }
    }

    toggleBtn.addEventListener('click', toggleSidebar);
    overlay.addEventListener('click', toggleSidebar);

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

    // 搜索功能
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

    // OTP代码更新
    async function updateOtpCodes() {
        const otpElements = document.querySelectorAll('.otp-code');
        if (otpElements.length === 0) return;

        for (const element of otpElements) {
            const secretKey = element.getAttribute('data-secret-key');
            if (secretKey && secretKey.trim() !== '') {
                try {
                    const response = await fetch('/generate-otp?secretKey=' + encodeURIComponent(secretKey));
                    if (!response.ok) {
                        throw new Error('HTTP error! status: ' + response.status);
                    }
                    const data = await response.json();
                    const otpValueElement = element.querySelector('.otp-value');
                    if (otpValueElement) {
                        otpValueElement.textContent = data.otpCode;
                    }
                } catch (error) {
                    console.error('Error fetching OTP code:', error);
                    const otpValueElement = element.querySelector('.otp-value');
                    if (otpValueElement) {
                        otpValueElement.textContent = 'Error';
                    }
                }
            }
        }
    }



    // 密钥显示切换
    function toggleSecretKeyVisibility(event) {
        const element = event.target;
        if (element.textContent === '******') {
            element.textContent = element.getAttribute('data-secret-key');
        } else {
            element.textContent = '******';
        }
    }

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
    // 页面初始化
    window.addEventListener('load', () => {
        // 先获取一次验证码
        updateOtpCodes();

        // 启动倒计时
        document.querySelectorAll('.otp-code').forEach(element => {
            startCountdown(element);
        });

        // 其他事件监听...
        document.querySelectorAll('.masked').forEach(element => {
            element.addEventListener('click', toggleSecretKeyVisibility);
        });
    });

    // 添加到现有 script 标签中
    // 粘贴处理
    document.addEventListener('paste', function(event) {
        const items = event.clipboardData.items;
        for (let i = 0; i < items.length; i++) {
            if (items[i].type.indexOf('image') !== -1) {
                const file = items[i].getAsFile();
                handleImageFile(file);
                break;
            }
        }
    });

    // 拖拽处理
    const pasteZone = document.getElementById('pasteZone');

    pasteZone.addEventListener('dragover', function(e) {
        e.preventDefault();
        e.stopPropagation();
        this.classList.add('dragover');
    });

    pasteZone.addEventListener('dragleave', function(e) {
        e.preventDefault();
        e.stopPropagation();
        this.classList.remove('dragover');
    });

    pasteZone.addEventListener('drop', function(e) {
        e.preventDefault();
        e.stopPropagation();
        this.classList.remove('dragover');

        const files = e.dataTransfer.files;
        if (files.length > 0 && files[0].type.indexOf('image') !== -1) {
            handleImageFile(files[0]);
        }
    });

    function handleImageFile(file) {
        document.getElementById('fileName').textContent = file.name || 'Pasted image';
        const reader = new FileReader();
        reader.onload = function(e) {
            const preview = document.getElementById('previewImage');
            preview.src = e.target.result;
            preview.style.display = 'block';
        }
        reader.readAsDataURL(file);

        const fileInput = document.getElementById('qrCode');
        const dataTransfer = new DataTransfer();
        dataTransfer.items.add(file);
        fileInput.files = dataTransfer.files;

        document.getElementById('secretKey').value = '';
        document.getElementById('secretKey').readOnly = true;
    }

    // 修改倒计时函数
    function startCountdown(element) {
        const numberElement = element.querySelector('.countdown-number');
        const circle = element.querySelector('.progress-circle');
        const FULL_DASH_ARRAY = 2 * Math.PI * 22;

        // 获取当前的时间点对应的剩余秒数
        let timeLeft = 30 - (Math.floor(Date.now() / 1000) % 30);
        let lastTimeLeft = timeLeft; // 记录上一次的时间，用于检测是否到达0

        circle.style.strokeDasharray = FULL_DASH_ARRAY;

        // 清除之前的定时器
        if (element._countdownTimer) {
            clearInterval(element._countdownTimer);
        }

        async function updateProgress() {
            // 更新上一次的时间
            lastTimeLeft = timeLeft;
            // 计算剩余时间
            timeLeft = 30 - (Math.floor(Date.now() / 1000) % 30);

            const progress = (timeLeft / 30) * FULL_DASH_ARRAY;
            circle.style.strokeDashoffset = FULL_DASH_ARRAY - progress;
            numberElement.textContent = timeLeft;

            // 检测是否经过了0点（从29秒到0秒的转换）
            if (lastTimeLeft < timeLeft) {
                await updateOtpCodes(); // 请求新的验证码
            }
        }

        // 立即开始倒计时
        updateProgress();

        // 设置定时器，每秒更新
        element._countdownTimer = setInterval(updateProgress, 1000);

        // 额外确保每30秒调用一次
        if (!window._globalOtpTimer) {
            window._globalOtpTimer = setInterval(updateOtpCodes, 30000);
        }
    }

    // 页面加载时初始化
    window.addEventListener('load', () => {
        // 先获取一次验证码
        updateOtpCodes();

        // 启动倒计时
        document.querySelectorAll('.otp-code').forEach(element => {
            startCountdown(element);
        });

        // 清理函数
        window.addEventListener('beforeunload', () => {
            if (window._globalOtpTimer) {
                clearInterval(window._globalOtpTimer);
            }
        });
    });



</script>
</body>
</html>