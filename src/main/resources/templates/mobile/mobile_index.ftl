<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no, maximum-scale=1.0">
    <title>MFA 管理</title>
    <script src="https://unpkg.com/html5-qrcode/html5-qrcode.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            -webkit-tap-highlight-color: transparent;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
            background: #f8f9fa;
            min-height: 100vh;
            overflow-x: hidden;
        }

        /* 头部导航 */
        .header {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            height: 56px;
            background: white;
            display: flex;
            align-items: center;
            padding: 0 16px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.08);
            z-index: 1000;
        }

        .menu-btn {
            background: none;
            border: none;
            width: 40px;
            height: 40px;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            border-radius: 50%;
            transition: background 0.2s;
        }

        .menu-btn:active {
            background: rgba(0,0,0,0.05);
        }

        .menu-icon {
            width: 24px;
            height: 24px;
            position: relative;
        }

        .menu-icon span {
            position: absolute;
            width: 20px;
            height: 2px;
            background: #5f6368;
            left: 2px;
            transition: 0.3s;
        }

        .menu-icon span:nth-child(1) { top: 6px; }
        .menu-icon span:nth-child(2) { top: 11px; }
        .menu-icon span:nth-child(3) { top: 16px; }

        .app-title {
            flex: 1;
            font-size: 20px;
            font-weight: 400;
            color: #202124;
            padding-left: 16px;
        }

        .app-title .google {
            color: #4285f4;
        }

        .user-menu {
            position: relative;
        }

        .user-avatar {
            width: 32px;
            height: 32px;
            border-radius: 50%;
            background: #4285f4;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 14px;
            font-weight: 500;
            cursor: pointer;
            transition: transform 0.2s;
        }

        .user-avatar:active {
            transform: scale(0.95);
        }

        /* 用户菜单下拉 */
        .dropdown-menu {
            position: absolute;
            top: 40px;
            right: 0;
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.2);
            min-width: 120px;
            display: none;
            z-index: 1001;
            overflow: hidden;
        }

        .dropdown-menu.show {
            display: block;
            animation: dropdownShow 0.2s ease;
        }

        .dropdown-item {
            padding: 12px 16px;
            color: #202124;
            cursor: pointer;
            transition: background 0.2s;
            border: none;
            background: none;
            width: 100%;
            text-align: left;
            font-size: 14px;
        }

        .dropdown-item:hover {
            background: #f8f9fa;
        }

        .dropdown-item:active {
            background: #e8eaed;
        }

        @keyframes dropdownShow {
            from {
                opacity: 0;
                transform: translateY(-10px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        /* 主内容区 */
        .main-content {
            padding-top: 56px;
            padding-bottom: 80px;
            min-height: 100vh;
        }

        /* 搜索框 */
        .search-container {
            padding: 12px 16px;
            background: white;
            border-bottom: 1px solid #e8eaed;
        }

        .search-box {
            background: #f1f3f4;
            border-radius: 8px;
            padding: 10px 16px;
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .search-icon {
            color: #5f6368;
            width: 20px;
            height: 20px;
        }

        .search-input {
            flex: 1;
            background: none;
            border: none;
            outline: none;
            font-size: 16px;
            color: #202124;
        }

        .search-input::placeholder {
            color: #80868b;
        }

        /* OTP列表 */
        .otp-list {
            background: white;
            min-height: calc(100vh - 140px);
        }

        .otp-item {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 16px;
            border-bottom: 1px solid #e8eaed;
            cursor: pointer;
            transition: background 0.2s;
            position: relative;
            transform: translateX(0); /* 初始位置 */
            transition: transform 0.3s ease-out; /* 增加过渡效果 */
        }

        .otp-item:active {
            background: #f8f9fa;
        }

        .otp-info-and-code {
            flex-grow: 1;
            flex-shrink: 1;
            overflow: hidden;
            padding-right: 16px;
        }

        .otp-account-full {
            font-size: 16px;
            color: #202124;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            margin-bottom: 8px;
        }

        .otp-code {
            font-size: 24px;
            font-weight: 500;
            color: var(--otp-code-color, #1a73e8);
            letter-spacing: 2px;
            font-family: 'Roboto Mono', monospace;
            cursor: pointer;
            user-select: none;
            transition: color 0.3s ease;
        }

        .countdown-container {
            position: relative;
            width: 32px;
            height: 32px;
            flex-shrink: 0;
        }

        .countdown-circle {
            transform: rotate(-90deg);
        }

        .countdown-bg {
            stroke: #e8eaed;
            stroke-width: 2;
            fill: none;
        }

        .countdown-progress {
            stroke: #1a73e8;
            stroke-width: 2;
            fill: none;
            stroke-linecap: round;
            stroke-dasharray: 88;
            stroke-dashoffset: 0;
            transition: stroke-dashoffset 1s linear;
        }

        .countdown-text {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            font-size: 12px;
            font-weight: 500;
            color: #5f6368;
        }

        /* 添加按钮 (FAB) - 确保显示 */
        .fab {
            position: fixed;
            bottom: 24px;
            right: 24px;
            width: 56px;
            height: 56px;
            border-radius: 50%;
            background: #1a73e8;
            box-shadow: 0 4px 8px rgba(0,0,0,0.3);
            border: none;
            color: white;
            font-size: 24px;
            display: flex !important;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            transition: transform 0.2s, box-shadow 0.2s;
            z-index: 999;
        }

        .fab:active {
            transform: scale(0.95);
            box-shadow: 0 2px 4px rgba(0,0,0,0.3);
        }

        /* 空状态 */
        .empty-state {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            padding: 80px 32px;
            text-align: center;
        }

        .empty-icon {
            width: 120px;
            height: 120px;
            background: #f8f9fa;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 48px;
            margin-bottom: 24px;
        }

        .empty-title {
            font-size: 20px;
            color: #202124;
            margin-bottom: 8px;
        }

        .empty-text {
            font-size: 14px;
            color: #5f6368;
            line-height: 20px;
        }

        /* 模态框 */
        .modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: rgba(0,0,0,0.5);
            z-index: 2000;
            animation: fadeIn 0.3s;
        }

        .modal.show {
            display: flex;
            align-items: flex-end;
            justify-content: center;
        }

        .modal-content {
            background: white;
            width: 100%;
            max-height: 90vh;
            border-radius: 16px 16px 0 0;
            animation: slideUp 0.3s;
            overflow: hidden;
        }

        .modal-header {
            padding: 20px;
            border-bottom: 1px solid #e8eaed;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .modal-title {
            font-size: 18px;
            font-weight: 400;
            color: #202124;
        }

        .modal-close {
            background: none;
            border: none;
            width: 40px;
            height: 40px;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            border-radius: 50%;
            transition: background 0.2s;
            color: #5f6368;
            font-size: 24px;
        }

        .modal-close:hover {
            background: #f8f9fa;
        }

        .modal-body {
            padding: 20px;
            overflow-y: auto;
            max-height: 70vh;
        }

        .form-group {
            margin-bottom: 24px;
        }

        .form-label {
            display: block;
            margin-bottom: 8px;
            font-size: 14px;
            color: #5f6368;
            font-weight: 500;
        }

        .form-input {
            width: 100%;
            padding: 12px;
            border: 1px solid #dadce0;
            border-radius: 8px;
            font-size: 16px;
            outline: none;
            transition: border-color 0.2s;
        }

        .form-input:focus {
            border-color: #1a73e8;
            border-width: 2px;
            padding: 11px;
        }

        .add-methods {
            display: flex;
            gap: 12px;
            margin-bottom: 24px;
        }

        .method-btn {
            flex: 1;
            padding: 16px;
            border: 1px solid #dadce0;
            border-radius: 8px;
            background: white;
            cursor: pointer;
            transition: all 0.2s;
            text-align: center;
        }

        .method-btn:active {
            transform: scale(0.98);
        }

        .method-btn.active {
            border-color: #1a73e8;
            background: #e8f0fe;
        }

        .method-icon {
            font-size: 24px;
            margin-bottom: 8px;
            display: block;
        }

        .method-label {
            font-size: 12px;
            color: #5f6368;
        }

        /* 扫码区域 - 修复的样式 */
        #qr-reader {
            width: 100%;
            margin: 20px auto;
            background: #000;
            border-radius: 8px;
            overflow: hidden;
            min-height: 350px;
            max-height: 400px;
            position: relative;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        /* 扫描动画覆盖层 */
        .scan-overlay {
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            z-index: 10;
            pointer-events: none;
            display: none;
            background: rgba(0, 0, 0, 0.5);
        }

        .scan-overlay.active {
            display: block;
        }

        /* 扫描框 */
        .scan-box {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            width: 250px;
            height: 250px;
            border: 1px solid rgba(255, 255, 255, 0.4);
        }

        /* 扫描框四个角 */
        .scan-corner {
            position: absolute;
            width: 25px;
            height: 25px;
            border: 3px solid #10b981;
        }

        .scan-corner.top-left {
            top: -3px;
            left: -3px;
            border-right: none;
            border-bottom: none;
        }

        .scan-corner.top-right {
            top: -3px;
            right: -3px;
            border-left: none;
            border-bottom: none;
        }

        .scan-corner.bottom-left {
            bottom: -3px;
            left: -3px;
            border-right: none;
            border-top: none;
        }

        .scan-corner.bottom-right {
            bottom: -3px;
            right: -3px;
            border-left: none;
            border-top: none;
        }

        /* 扫描线动画 */
        .scan-line {
            position: absolute;
            left: 0;
            right: 0;
            height: 2px;
            background: linear-gradient(180deg, transparent, #10b981, transparent);
            top: 0;
            animation: scanLineMove 2s cubic-bezier(0.65, 0.05, 0.36, 1) infinite;
            box-shadow: 0 0 10px #10b981;
        }

        @keyframes scanLineMove {
            0% {
                top: 0;
            }
            100% {
                top: 100%;
            }
        }

        /* 扫描提示文字 */
        .scan-tip {
            position: absolute;
            bottom: -40px;
            left: 50%;
            transform: translateX(-50%);
            color: white;
            font-size: 14px;
            text-align: center;
            text-shadow: 0 1px 2px rgba(0,0,0,0.8);
            white-space: nowrap;
        }

        /* 确保扫描器容器有正确的尺寸 */
        #qr-reader > div {
            width: 100% !important;
            max-width: 100% !important;
        }

        /* 扫描框样式优化 */
        #qr-reader video {
            width: 100% !important;
            height: auto !important;
            max-height: 350px !important;
            border-radius: 8px;
            object-fit: contain;
            background-color: #000;
        }

        /* 扫描器UI优化 */
        #qr-reader__camera_selection {
            margin-bottom: 10px;
        }

        #qr-reader__scan_region {
            background: #000;
            border-radius: 8px;
            overflow: hidden;
            display: flex !important;
            align-items: center !important;
            justify-content: center !important;
            position: relative;
        }

        #qr-reader__dashboard {
            padding: 10px;
        }

        #qr-reader-results {
            padding: 12px;
            background: #e8f5e8;
            border: 1px solid #4caf50;
            border-radius: 8px;
            margin-bottom: 20px;
            display: none;
            color: #2e7d32;
        }

        /* 摄像头控制按钮 */
        .camera-controls {
            display: flex;
            gap: 8px;
            margin-bottom: 12px;
        }

        .camera-btn {
            flex: 1;
            padding: 8px 12px;
            background: #f1f3f4;
            border: 1px solid #dadce0;
            border-radius: 6px;
            font-size: 14px;
            cursor: pointer;
            transition: all 0.2s;
        }

        .camera-btn.active {
            background: #1a73e8;
            color: white;
            border-color: #1a73e8;
        }

        .camera-btn:hover {
            background: #e8eaed;
        }

        .camera-btn.active:hover {
            background: #1557b0;
        }

        .scan-btn {
            width: 100%;
            padding: 12px;
            background: #34a853;
            color: white;
            border: none;
            border-radius: 8px;
            font-size: 16px;
            font-weight: 500;
            cursor: pointer;
            margin-bottom: 12px;
        }

        .scan-btn:active {
            background: #2d8e47;
        }

        .scan-btn:disabled {
            background: #dadce0;
            color: #80868b;
            cursor: not-allowed;
        }

        .submit-btn {
            width: 100%;
            padding: 12px;
            background: #1a73e8;
            color: white;
            border: none;
            border-radius: 8px;
            font-size: 16px;
            font-weight: 500;
            cursor: pointer;
            transition: background 0.2s;
        }

        .submit-btn:active {
            background: #1557b0;
        }

        .submit-btn:disabled {
            background: #dadce0;
            color: #80868b;
            cursor: not-allowed;
        }

        /* Loading动画 */
        .loading {
            display: inline-block;
            width: 18px;
            height: 18px;
            border: 2px solid #e8eaed;
            border-top-color: #1a73e8;
            border-radius: 50%;
            animation: spin 1s linear infinite;
        }

        @keyframes spin {
            to { transform: rotate(360deg); }
        }

        /* 滑动删除 */
        .swipe-delete {
            position: absolute;
            right: 0;
            top: 0;
            bottom: 0;
            width: 80px;
            background: #ea4335;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 14px;
            transform: translateX(100%);
            transition: transform 0.3s ease-out;
        }

        .otp-item.swiped .swipe-delete {
            transform: translateX(0);
        }
    </style>
</head>
<body>
<div class="header">
    <button class="menu-btn">
        <div class="menu-icon">
            <span></span>
            <span></span>
            <span></span>
        </div>
    </button>
    <div class="app-title">
        <span class="mfa-start">OTP</span> Authenticator
    </div>
    <div class="user-menu">
        <div class="user-avatar" onclick="toggleUserMenu()">My</div>
        <div class="dropdown-menu" id="userDropdown">
            <form action="/perform_logout" method="post" style="margin: 0;">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                <button type="submit" class="dropdown-item">
                    退出登录
                </button>
            </form>
        </div>
    </div>
</div>

<div class="main-content">
    <div class="search-container">
        <div class="search-box">
            <svg class="search-icon" viewBox="0 0 24 24" fill="currentColor">
                <path d="M15.5 14h-.79l-.28-.27A6.471 6.471 0 0 0 16 9.5 6.5 6.5 0 1 0 9.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z"/>
            </svg>
            <input type="text" class="search-input" placeholder="搜索..." id="searchInput" onkeyup="searchKeys()">
        </div>
    </div>

    <div class="otp-list" id="otpList">
    </div>

    <div class="empty-state" id="emptyState" style="display: none;">
        <div class="empty-icon">🔐</div>
        <div class="empty-title">开始使用</div>
        <div class="empty-text">点击 + 按钮添加账号</div>
    </div>
</div>

<button class="fab" onclick="openAddKeyModal()">+</button>

<div class="modal" id="addKeyModal">
    <div class="modal-content">
        <div class="modal-header">
            <h3 class="modal-title">输入账号详情</h3>
            <button class="modal-close" onclick="closeAddKeyModal()">×</button>
        </div>
        <div class="modal-body">
            <div class="add-methods">
                <div class="method-btn active" id="manualMethod" onclick="selectMethod('manual')">
                    <span class="method-icon">⌨️</span>
                    <span class="method-label">输入设置密钥</span>
                </div>
                <div class="method-btn" id="scanMethod" onclick="selectMethod('scan')">
                    <span class="method-icon">📷</span>
                    <span class="method-label">扫描二维码</span>
                </div>
            </div>

            <form id="keyForm" onsubmit="submitKeyForm(event)">
                <div class="form-group">
                    <label class="form-label">账号</label>
                    <input type="text" class="form-input" id="keyName" name="keyName" required placeholder="您的账号">
                </div>

                <div class="form-group" id="secretKeyGroup">
                    <label class="form-label">您的密钥</label>
                    <input type="text" class="form-input" id="secretKey" name="secretKey" required placeholder="输入您的密钥">
                </div>

                <div id="scanArea" style="display: none;">
                    <div class="camera-controls">
                        <button type="button" class="camera-btn active" id="backCameraBtn" onclick="switchCamera('back')">后置摄像头</button>
                        <button type="button" class="camera-btn" id="frontCameraBtn" onclick="switchCamera('front')">前置摄像头</button>
                    </div>
                    <div id="qr-reader">
                        <div class="scan-overlay" id="scanOverlay">
                            <div class="scan-box">
                                <div class="scan-corner top-left"></div>
                                <div class="scan-corner top-right"></div>
                                <div class="scan-corner bottom-left"></div>
                                <div class="scan-corner bottom-right"></div>
                                <div class="scan-line"></div>
                                <div class="scan-tip">请将二维码放入框内</div>
                            </div>
                        </div>
                    </div>
                    <div id="qr-reader-results">
                        <small>扫描结果：<span id="scan-result"></span></small>
                    </div>
                    <button type="button" class="scan-btn" onclick="startScanning()" id="startScanBtn">开始扫描</button>
                    <button type="button" class="scan-btn" onclick="stopScanning()" style="display:none;background: #ea4335;" id="stopScanBtn">停止扫描</button>
                </div>

                <button type="submit" class="submit-btn" id="submitBtn">添加</button>
            </form>
        </div>
    </div>
</div>

<script data-csrf-token="${_csrf.token}" data-csrf-param="${_csrf.parameterName}"></script>

<script>
    // 全局变量
    let globalUpdateTimer = null;
    let currentMethod = 'manual';
    let csrfToken = '';
    let html5QrcodeScanner = null;
    let otpKeysData = [];
    let availableCameras = [];
    let currentCameraType = 'back'; // 'back' 或 'front'
    let isScanning = false;

    // 初始化
    document.addEventListener('DOMContentLoaded', function() {
        const csrfScript = document.querySelector('script[data-csrf-token]');
        if (csrfScript) {
            csrfToken = csrfScript.getAttribute('data-csrf-token');
        }
        loadOTPKeys();
    });

    // 通用的fetch请求函数，包含错误处理和CSRF头
    async function fetchWithCsrf(url, method, body) {
        const headers = {
            'Content-Type': 'application/json',
            'X-CSRF-TOKEN': csrfToken
        };
        const options = {
            method: method,
            headers: headers
        };
        if (body) {
            options.body = JSON.stringify(body);
        }

        try {
            const response = await fetch(url, options);
            if (!response.ok) {
                const errorText = await response.text();
                throw new Error(errorText || `HTTP error! status: `+ response.status+``);
            }
            return response;
        } catch (error) {
            console.error(`Fetch error for `+ url+`:`, error);
            throw error;
        }
    }

    // 加载OTP密钥
    async function loadOTPKeys() {
        try {
            const response = await fetch('/api/otpKeys');
            if (!response.ok) {
                throw new Error('Failed to fetch OTP keys');
            }
            otpKeysData = await response.json();
            renderOTPList();
        } catch (error) {
            console.error('Error loading OTP keys:', error);
            Swal.fire({
                icon: 'error',
                title: '加载失败',
                text: '加载密钥失败，请刷新重试。'
            });
        }
    }

    // 渲染OTP列表
    function renderOTPList() {
        const otpList = document.getElementById('otpList');
        const emptyState = document.getElementById('emptyState');

        if (!otpKeysData || otpKeysData.length === 0) {
            otpList.style.display = 'none';
            emptyState.style.display = 'flex';
            return;
        }

        otpList.style.display = 'block';
        emptyState.style.display = 'none';
        let html_content = '';
        otpKeysData.forEach(key => {
            const keyName = key.keyName || '';
            const issuer = key.issuer || 'default';
            const secretKey = key.secretKey || '';

            html_content += `
                    <div class="otp-item" data-key="`+ keyName+`" data-secret="`+ secretKey+`">
                        <div class="otp-info-and-code" onclick="copyOTPCode(this, '`+ secretKey+`')">
                            <div class="otp-account-full">`+ issuer+`: `+ keyName+`</div>
                            <div class="otp-code">
                                <span class="otp-value">------</span>
                            </div>
                        </div>
                        <div class="countdown-container">
                            <svg class="countdown-circle" width="32" height="32">
                                <circle class="countdown-bg" cx="16" cy="16" r="14"></circle>
                                <circle class="countdown-progress" cx="16" cy="16" r="14"></circle>
                            </svg>
                            <div class="countdown-text">30</div>
                        </div>
                        <div class="swipe-delete">
                            🗑️
                        </div>
                    </div>
                `;
        });

        otpList.innerHTML = html_content;
        updateOtpCodes();
        initializeCountdown();
    }

    // 批量更新OTP代码
    async function updateOtpCodes() {
        const otpItems = document.querySelectorAll('.otp-item');
        if (otpItems.length === 0) return;

        const secretKeys = Array.from(otpItems)
            .map(item => item.getAttribute('data-secret'))
            .filter(key => key && key.trim() !== '');
        if (secretKeys.length === 0) return;

        try {
            const response = await fetchWithCsrf('/generate-otp-batch', 'POST', { secretKeys });
            const otpResponses = await response.json();
            const otpMap = new Map(
                otpResponses.map(response => [response.secretKey, response.otpCode])
            );
            otpItems.forEach(item => {
                const secretKey = item.getAttribute('data-secret');
                const otpValue = item.querySelector('.otp-value');
                if (otpValue && otpMap.has(secretKey)) {
                    const code = otpMap.get(secretKey);
                    otpValue.textContent = formatCode(code);
                }
            });
        } catch (error) {
            console.error('Error updating OTP codes:', error);
        }
    }

    // 格式化验证码显示
    function formatCode(code) {
        if (!code || code.length !== 6) return code;
        return code.substring(0, 3) + ' ' + code.substring(3);
    }

    // 倒计时
    function initializeCountdown() {
        const updateAllCircles = () => {
            const FULL_DASH_ARRAY = 2 * Math.PI * 14;
            const timeLeft = 30 - (Math.floor(Date.now() / 1000) % 30);
            document.querySelectorAll('.countdown-container').forEach(container => {
                const text = container.querySelector('.countdown-text');
                const circle = container.querySelector('.countdown-progress');
                const otpCode = container.closest('.otp-item').querySelector('.otp-code');

                if (text && circle) {
                    const progress = (timeLeft / 30) * FULL_DASH_ARRAY;
                    circle.style.strokeDasharray = FULL_DASH_ARRAY;
                    circle.style.strokeDashoffset = FULL_DASH_ARRAY - progress;
                    text.textContent = timeLeft;

                    if (timeLeft <= 10) {
                        otpCode.style.color = '#dc3545';
                    } else {
                        otpCode.style.color = '#1a73e8';
                    }
                }
            });
            if (timeLeft === 30) {
                updateOtpCodes();
            }
        };

        if (globalUpdateTimer) {
            clearInterval(globalUpdateTimer);
        }

        updateAllCircles();
        globalUpdateTimer = setInterval(updateAllCircles, 1000);
    }

    // 复制OTP代码
    async function copyOTPCode(element, secretKey) {
        const otpValue = element.querySelector('.otp-value');
        const code = otpValue.textContent.replace(/\s/g, '');

        try {
            await navigator.clipboard.writeText(code);
            Swal.fire({
                toast: true,
                position: 'bottom',
                icon: 'success',
                title: '验证码已复制',
                showConfirmButton: false,
                timer: 2000
            });
        } catch (error) {
            Swal.fire({
                toast: true,
                position: 'bottom',
                icon: 'error',
                title: '复制失败',
                showConfirmButton: false,
                timer: 2000
            });
        }
    }

    // 搜索功能
    function searchKeys() {
        const searchTerm = document.getElementById('searchInput').value.toLowerCase();
        const items = document.querySelectorAll('.otp-item');

        items.forEach(item => {
            const text = item.textContent.toLowerCase();
            item.style.display = text.includes(searchTerm) ? 'flex' : 'none';
        });
    }

    // 用户菜单
    function toggleUserMenu() {
        const dropdown = document.getElementById('userDropdown');
        dropdown.classList.toggle('show');

        setTimeout(() => {
            document.addEventListener('click', closeUserMenu);
        }, 100);
    }

    function closeUserMenu(e) {
        const dropdown = document.getElementById('userDropdown');
        const userMenu = document.querySelector('.user-menu');

        if (!userMenu.contains(e.target)) {
            dropdown.classList.remove('show');
            document.removeEventListener('click', closeUserMenu);
        }
    }

    // 打开添加密钥模态框
    function openAddKeyModal() {
        document.getElementById('addKeyModal').classList.add('show');
        document.body.style.overflow = 'hidden';
    }

    // 关闭添加密钥模态框
    function closeAddKeyModal() {
        document.getElementById('addKeyModal').classList.remove('show');
        document.body.style.overflow = 'auto';
        stopScanning();
        resetForm();
        // 隐藏扫描结果
        const resultsDiv = document.getElementById('qr-reader-results');
        if (resultsDiv) {
            resultsDiv.style.display = 'none';
        }
    }

    // 重置表单
    function resetForm() {
        document.getElementById('keyForm').reset();
        document.getElementById('secretKey').readOnly = false;
        selectMethod('manual');
    }

    // 选择添加方式
    function selectMethod(method) {
        currentMethod = method;
        const manualBtn = document.getElementById('manualMethod');
        const scanBtn = document.getElementById('scanMethod');
        const secretKeyGroup = document.getElementById('secretKeyGroup');
        const scanArea = document.getElementById('scanArea');
        const submitBtn = document.getElementById('submitBtn');

        if (method === 'scan') {
            manualBtn.classList.remove('active');
            scanBtn.classList.add('active');
            secretKeyGroup.style.display = 'none';
            scanArea.style.display = 'block';
            submitBtn.style.display = 'none';
            // 自动启动扫描
            setTimeout(() => {
                startScanning();
            }, 300);
        } else {
            manualBtn.classList.add('active');
            scanBtn.classList.remove('active');
            secretKeyGroup.style.display = 'block';
            scanArea.style.display = 'none';
            submitBtn.style.display = 'block';
            stopScanning();
        }
    }

    // 获取可用摄像头
    async function getCameras() {
        try {
            const devices = await Html5Qrcode.getCameras();
            availableCameras = devices;
            console.log('可用摄像头:', devices);
            return devices;
        } catch (err) {
            console.error('获取摄像头列表失败:', err);
            return [];
        }
    }

    // 切换摄像头
    function switchCamera(type) {
        currentCameraType = type;
        // 更新按钮状态
        document.getElementById('backCameraBtn').classList.toggle('active', type === 'back');
        document.getElementById('frontCameraBtn').classList.toggle('active', type === 'front');
        // 如果正在扫描，重新启动扫描
        if (isScanning) {
            stopScanning();
            setTimeout(() => {
                startScanning();
            }, 500);
        }
    }

    // 根据类型选择摄像头
    function selectCameraByType(cameras, type) {
        if (!cameras || cameras.length === 0) return null;
        if (type === 'back') {
            // 查找后置摄像头
            const backCamera = cameras.find(camera => {
                const label = camera.label.toLowerCase();
                return label.includes('back') || label.includes('rear') ||
                    label.includes('环境') || label.includes('后') ||
                    !label.includes('front') && !label.includes('前');
            });
            return backCamera || cameras[0];
        } else {
            // 查找前置摄像头
            const frontCamera = cameras.find(camera => {
                const label = camera.label.toLowerCase();
                return label.includes('front') || label.includes('前') || label.includes('user');
            });
            return frontCamera || cameras[cameras.length - 1];
        }
    }

    // 开始扫描二维码
    // 开始扫描二维码
    async function startScanning() {
        const startBtn = document.getElementById('startScanBtn');
        const stopBtn = document.getElementById('stopScanBtn');
        const qrReaderDiv = document.getElementById('qr-reader');

        if (isScanning) {
            console.log('扫描已在进行中');
            return;
        }

        if (!startBtn || !stopBtn || !qrReaderDiv) {
            Swal.fire({
                icon: 'error',
                title: '错误',
                text: '扫描器容器或按钮不存在，请刷新页面。'
            });
            return;
        }

        startBtn.style.display = 'none';
        startBtn.disabled = true;
        stopBtn.style.display = 'block';
        isScanning = true;

        // 在启动扫描前，动态插入扫描动画覆盖层
        const scanOverlayHtml = `
        <div class="scan-overlay active" id="scanOverlay">
            <div class="scan-box">
                <div class="scan-corner top-left"></div>
                <div class="scan-corner top-right"></div>
                <div class="scan-corner bottom-left"></div>
                <div class="scan-corner bottom-right"></div>
                <div class="scan-line"></div>
                <div class="scan-tip">请将二维码放入框内</div>
            </div>
        </div>
    `;
        qrReaderDiv.insertAdjacentHTML('afterbegin', scanOverlayHtml);

        try {
            const cameras = await getCameras();
            if (!cameras || cameras.length === 0) {
                Swal.fire({
                    icon: 'error',
                    title: '错误',
                    text: '未找到可用摄像头'
                });
                resetScanButtons();
                return;
            }

            const selectedCamera = selectCameraByType(cameras, currentCameraType);
            if (!selectedCamera) {
                Swal.fire({
                    icon: 'error',
                    title: '错误',
                    text: '未找到指定类型的摄像头'
                });
                resetScanButtons();
                return;
            }

            html5QrcodeScanner = new Html5Qrcode('qr-reader');
            const config = {
                fps: 10,
                qrbox: { width: 250, height: 250 },
                aspectRatio: 1.0,
                showTorchButtonIfSupported: true,
                showZoomSliderIfSupported: true,
                defaultZoomValueIfSupported: 2,
                supportedScanTypes: [Html5QrcodeScanType.SCAN_TYPE_CAMERA]
            };

            await html5QrcodeScanner.start(
                selectedCamera.id,
                config,
                (decodedText, decodedResult) => {
                    handleQRCodeSuccess(decodedText);
                },
                (errorMessage) => {
                    // 扫描错误（正常情况，不需要处理）
                }
            );
        } catch (error) {
            Swal.fire({
                icon: 'error',
                title: '启动失败',
                text: '启动扫描失败，请检查摄像头权限。'
            });
            resetScanButtons();
        }
    }

    // 重置扫描按钮状态
    function resetScanButtons() {
        const startBtn = document.getElementById('startScanBtn');
        const stopBtn = document.getElementById('stopScanBtn');
        const scanOverlay = document.getElementById('scanOverlay');

        if (startBtn) {
            startBtn.style.display = 'block';
            startBtn.disabled = false;
        }
        if (stopBtn) {
            stopBtn.style.display = 'none';
        }
        if (scanOverlay) {
            scanOverlay.classList.remove('active');
        }
        isScanning = false;
    }

    // 停止扫描
    function stopScanning() {
        if (!isScanning) {
            return;
        }

        if (html5QrcodeScanner) {
            html5QrcodeScanner.stop().then(() => {
                html5QrcodeScanner.clear();
                html5QrcodeScanner = null;
                resetScanButtons();
            }).catch((err) => {
                console.error('停止扫描失败: ' + err);
                html5QrcodeScanner = null;
                resetScanButtons();
            });
        } else {
            resetScanButtons();
        }
    }

    // 处理扫描成功
    async function handleQRCodeSuccess(decodedText) {
        stopScanning();
        const resultsDiv = document.getElementById('qr-reader-results');
        if (resultsDiv) {
            resultsDiv.style.display = 'block';
            document.getElementById('scan-result').textContent = decodedText.length > 50 ?
                decodedText.substring(0, 50) + '...' : decodedText;
        }

        Swal.fire({
            title: '已识别二维码',
            text: '正在处理，请稍候...',
            icon: 'info',
            showConfirmButton: false,
            didOpen: () => {
                Swal.showLoading();
            }
        });

        try {
            // 提交给后端处理，使用 fetchWithCsrf
            const response = await fetchWithCsrf('/save-secret', 'POST', { qrContent: decodedText });
            if (response.ok) {
                Swal.fire({
                    icon: 'success',
                    title: '添加成功',
                    text: '账号已成功添加！'
                });
                closeAddKeyModal();
                loadOTPKeys();
            } else {
                const errorText = await response.text();
                throw new Error(errorText || '服务器返回错误');
            }
        } catch (error) {
            Swal.fire({
                icon: 'error',
                title: '处理失败',
                text: '处理二维码失败，请检查二维码格式。'
            });
        }
    }

    // 提交表单（仅用于手动输入）
    async function submitKeyForm(event) {
        event.preventDefault();
        const submitBtn = document.getElementById('submitBtn');
        submitBtn.disabled = true;
        submitBtn.innerHTML = '<span class="loading"></span>';

        const formData = new FormData();
        const keyName = document.getElementById('keyName').value;
        const secretKey = document.getElementById('secretKey').value;

        formData.append('keyName', keyName);
        formData.append('secretKey', secretKey);

        // 从 data 属性获取 CSRF 参数名，并将其和令牌一起添加到 FormData 中
        const csrfParam = document.querySelector('script[data-csrf-param]').getAttribute('data-csrf-param');
        formData.append(csrfParam, csrfToken);

        try {
            // 使用标准的 fetch API，并传递 FormData 对象
            const response = await fetch('/save-secret', {
                method: 'POST',
                body: formData
            });

            if (response.ok) {
                Swal.fire({
                    icon: 'success',
                    title: '添加成功',
                    showConfirmButton: false,
                    timer: 1500
                });
                closeAddKeyModal();
                loadOTPKeys();
            } else {
                const errorText = await response.text();
                throw new Error(errorText || '服务器返回错误');
            }
        } catch (error) {
            console.error('Error:', error);
            Swal.fire({
                icon: 'error',
                title: '添加失败',
                text: '添加失败，请检查输入或重试。'
            });
        } finally {
            submitBtn.disabled = false;
            submitBtn.textContent = '添加';
        }
    }

    // 删除密钥
    async function deleteKey(keyName) {
        Swal.fire({
            title: '确定要删除吗?',
            text: `您将删除账号 "`+ keyName+`"，此操作无法撤销。`,
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#d33',
            cancelButtonColor: '#3085d6',
            confirmButtonText: '确定删除',
            cancelButtonText: '取消'
        }).then(async (result) => {
            if (result.isConfirmed) {
                try {
                    // 使用 fetchWithCsrf
                    const response = await fetchWithCsrf('/delete-key', 'POST', { keyName: keyName });
                    if (response.ok) {
                        Swal.fire({
                            icon: 'success',
                            title: '删除成功',
                            showConfirmButton: false,
                            timer: 1500
                        });
                        loadOTPKeys();
                    } else {
                        throw new Error('删除失败');
                    }
                } catch (error) {
                    console.error('Error:', error);
                    Swal.fire({
                        icon: 'error',
                        title: '删除失败',
                        text: '删除失败，请重试。'
                    });
                }
            }
        });
    }

    // 模态框背景点击关闭
    document.getElementById('addKeyModal').addEventListener('click', function(e) {
        if (e.target === this) {
            closeAddKeyModal();
        }
    });

    // 滑动删除功能
    let touchStartX = 0;
    let currentSwipedItem = null;

    // 使用事件委托，为所有 .otp-item 元素处理 touchstart 事件
    document.getElementById('otpList').addEventListener('touchstart', function(e) {
        const otpItem = e.target.closest('.otp-item');
        if (!otpItem) return;

        // 如果之前有被滑动的项目，先将其复位
        if (currentSwipedItem && currentSwipedItem !== otpItem) {
            currentSwipedItem.classList.remove('swiped');
            currentSwipedItem.style.transform = 'translateX(0)';
        }

        touchStartX = e.touches[0].clientX;
        currentSwipedItem = otpItem;
    });

    // 使用事件委托，为所有 .otp-item 元素处理 touchmove 和 touchend
    document.getElementById('otpList').addEventListener('touchmove', function(e) {
        if (!currentSwipedItem) return;

        const currentX = e.touches[0].clientX;
        const diff = touchStartX - currentX;
        const deleteBtnWidth = 80; // 删除按钮的固定宽度

        // 防止向右滑动时过度移动
        const swipeDistance = Math.max(0, diff);

        // 控制元素向左移动的距离，最大不超过删除按钮的宽度
        const transformX = Math.min(swipeDistance, deleteBtnWidth);

        currentSwipedItem.style.transform = `translateX(-`+transformX +`px)`;

        // 根据滑动距离的阈值来控制 'swiped' class
        if (swipeDistance > 10) {
            currentSwipedItem.classList.add('swiped');
        } else {
            currentSwipedItem.classList.remove('swiped');
        }
    });

    document.getElementById('otpList').addEventListener('touchend', function(e) {
        if (!currentSwipedItem) return;

        const touchendX = e.changedTouches[0].clientX;
        const diff = touchStartX - touchendX;
        const deleteBtnWidth = 80; // 删除按钮的固定宽度

        // 如果滑动距离超过阈值（例如，删除按钮宽度的一半），则保持显示
        if (diff > deleteBtnWidth / 2) {
            currentSwipedItem.style.transform = `translateX(-`+ deleteBtnWidth+`px)`;
        } else {
            // 否则，隐藏删除按钮
            currentSwipedItem.classList.remove('swiped');
            currentSwipedItem.style.transform = `translateX(0)`;
        }

        currentSwipedItem = null;
    });

    // 使用事件委托，为所有 .swipe-delete 元素添加点击事件
    document.getElementById('otpList').addEventListener('click', function(e) {
        const swipeDeleteBtn = e.target.closest('.swipe-delete');
        if (swipeDeleteBtn) {
            e.stopPropagation(); // 阻止事件冒泡到父元素
            const otpItem = swipeDeleteBtn.closest('.otp-item');
            if (otpItem) {
                const keyName = otpItem.getAttribute('data-key');
                deleteKey(keyName);
            }
        }
    });

    // 页面卸载时清理
    window.addEventListener('beforeunload', function() {
        if (globalUpdateTimer) {
            clearInterval(globalUpdateTimer);
        }
        stopScanning();
    });
</script>
</body>
</html>