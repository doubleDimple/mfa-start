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

        /* 添加按钮 (FAB) */
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
            display: flex;
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

        /* 扫码区域 */
        #qr-reader {
            width: 100%;
            margin-bottom: 20px;
        }

        #qr-reader-results {
            padding: 12px;
            background: #f8f9fa;
            border-radius: 8px;
            margin-bottom: 20px;
            display: none;
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

        /* Toast提示 */
        .toast {
            position: fixed;
            bottom: 80px;
            left: 50%;
            transform: translateX(-50%);
            background: #323232;
            color: white;
            padding: 12px 24px;
            border-radius: 4px;
            font-size: 14px;
            z-index: 3000;
            animation: toastIn 0.3s;
        }

        @keyframes fadeIn {
            from { opacity: 0; }
            to { opacity: 1; }
        }

        @keyframes slideUp {
            from { transform: translateY(100%); }
            to { transform: translateY(0); }
        }

        @keyframes toastIn {
            from {
                opacity: 0;
                transform: translate(-50%, 20px);
            }
            to {
                opacity: 1;
                transform: translate(-50%, 0);
            }
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
            transform: translateX(100%);
            transition: transform 0.3s;
        }

        .otp-item.swiped .swipe-delete {
            transform: translateX(0);
        }

        /* === 以下为新布局的样式 === */
        .otp-item {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 16px;
            border-bottom: 1px solid #e8eaed;
            cursor: pointer;
            transition: background 0.2s;
            position: relative;
        }

        /* 账户名和验证码的容器 */
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

        /* === 以上为新布局的样式 === */

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
        <div
                class="user-avatar" onclick="toggleUserMenu()">My</div>
        <div class="dropdown-menu" id="userDropdown">
            <#--<button class="dropdown-item" onclick="logout()">退出登录</button>-->

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
                <path d="M15.5 14h-.79l-.28-.27A6.471 6.471 0 0 0 16 9.5 6.5 6.5 0 1
0 9.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z"/>
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
                    <div id="qr-reader"></div>
                    <div id="qr-reader-results">

                        <small>扫描结果：<span id="scan-result"></span></small>
                    </div>
                    <button type="button" class="scan-btn" onclick="startScanning()">开始扫描</button>
                    <button type="button" class="scan-btn" onclick="stopScanning()" style="display:none;
background: #ea4335;" id="stopScanBtn">停止扫描</button>
                </div>

                <button type="submit" class="submit-btn" id="submitBtn">添加</button>
            </form>
        </div>
    </div>
</div>

<script>
    // 全局变量
    let globalUpdateTimer = null;
    let currentMethod = 'manual';
    let csrfToken = '';
    let html5QrcodeScanner = null;
    let otpKeysData
        = [];

    // 初始化
    document.addEventListener('DOMContentLoaded', function() {
        const csrfScript = document.querySelector('script[data-csrf-token]');
        if (csrfScript) {
            csrfToken = csrfScript.getAttribute('data-csrf-token');
        }
        loadOTPKeys();
    });

    // 加载OTP密钥
    async function loadOTPKeys() {
        try {

            const response = await fetch('/', {
                method: 'GET',
                headers: {
                    'X-CSRF-TOKEN': csrfToken
                }
            });

            const html = await response.text();
            const scriptMatch = html.match(/var\s+otpKeys\s*=\s*(\[[\s\S]*?\]);/);
            if (scriptMatch) {
                try {
                    eval('otpKeysData = ' + scriptMatch[1]);
                } catch (e) {
                    console.error('Failed to parse otpKeys data:', e);
                }
            }
            renderOTPList();
        } catch (error) {
            console.error('Error loading OTP keys:', error);
            showToast('加载失败，请刷新重试');
        }
    }

    // 渲染OTP列表
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

            // 使用模板字面量以确保正确的字符串拼接
            html_content += `
                <div class="otp-item" data-key="`+ keyName+`" data-secret="`+ secretKey+`">
                    <div class="otp-info-and-code">
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
            const response = await fetch('/generate-otp-batch', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',

                    'X-CSRF-TOKEN': csrfToken
                },
                body: JSON.stringify({ secretKeys })
            });
            if (!response.ok) throw new Error('Failed to generate OTP codes');

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

                    // 倒计时小于10秒变色
                    if (timeLeft <= 10) {
                        otpCode.style.color = '#dc3545'; // 暗红色
                    } else {
                        otpCode.style.color = '#1a73e8'; // 默认蓝色
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
            otpValue.classList.add('copied');
            showToast('验证码已复制');
            setTimeout(() => {
                otpValue.classList.remove('copied');
            }, 300);
        } catch (error) {
            showToast('复制失败');
        }
    }

    // 搜索功能
    function searchKeys() {
        const searchTerm = document.getElementById('searchInput').value.toLowerCase();
        const items = document.querySelectorAll('.otp-item');

        items.forEach(item => {
            const text = item.textContent.toLowerCase();
            item.style.display = text.includes(searchTerm) ? 'block' : 'none';
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

    // 退出登录
    function logout() {
        window.location.href = '/logout';
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
    }

    // 重置表单
    function resetForm() {
        document.getElementById('keyForm').reset();
        document.getElementById('secretKey').readOnly = false;
        selectMethod('manual');
    }

    // 选择添加方式
    // 选择添加方式
    function selectMethod(method) {
        currentMethod = method;
        const manualBtn = document.getElementById('manualMethod');
        const scanBtn = document.getElementById('scanMethod');
        const secretKeyGroup = document.getElementById('secretKeyGroup');
        const scanArea = document.getElementById('scanArea');
        const keyForm = document.getElementById('keyForm');
        if (method === 'scan') {
            manualBtn.classList.remove('active');
            scanBtn.classList.add('active');
            secretKeyGroup.style.display = 'none';
            scanArea.style.display = 'block';
            keyForm.style.display = 'none'; // 隐藏手动输入表单
            document.getElementById('submitBtn').style.display = 'none';
// 隐藏提交按钮

            // 自动启动摄像头扫描
            startScanning();
        } else {
            manualBtn.classList.add('active');
            scanBtn.classList.remove('active');
            secretKeyGroup.style.display = 'block';
            scanArea.style.display = 'none';
            keyForm.style.display = 'block'; // 显示手动输入表单
            document.getElementById('submitBtn').style.display = 'block';
// 显示提交按钮
            stopScanning();
        }
    }

    // 开始扫描二维码
    function startScanning() {
        const qrReaderDiv = document.getElementById('qr-reader');
        const startBtn = document.querySelector('.scan-btn');
        const stopBtn = document.getElementById('stopScanBtn');

        startBtn.style.display = 'none';
        stopBtn.style.display = 'block';

        html5QrcodeScanner = new Html5Qrcode('qr-reader');
        const config = {
            fps: 10,
            qrbox: { width: 250, height: 250 },
            aspectRatio: 1.0
        };
        html5QrcodeScanner.start(
            { facingMode: "environment" },
            config,
            (decodedText, decodedResult) => {
                // 扫描成功，将原始字符串直接交给后端处理
                handleQRCodeSuccess(decodedText);
            },
            (errorMessage) => {
                // 扫描错误（可以忽略）
            }
        ).catch((err) => {
            console.error(`Unable to start scanning: ` + err + ``);
            showToast('无法访问摄像头，请检查权限设置');
            stopScanning();
        });
    }

    // 停止扫描
    function stopScanning() {
        const startBtn = document.querySelector('.scan-btn');
        const stopBtn = document.getElementById('stopScanBtn');

        if (startBtn) startBtn.style.display = 'block';
        if (stopBtn) stopBtn.style.display = 'none';
        if (html5QrcodeScanner && html5QrcodeScanner.isScanning) {
            html5QrcodeScanner.stop().then(() => {
                html5QrcodeScanner.clear();
                html5QrcodeScanner = null;
            }).catch((err) => {
                console.error(`Failed to stop scanning: ` + err + ``);

            });
        }
    }

    // 处理扫码成功，直接提交给后端
    async function handleQRCodeSuccess(decodedText) {
        console.log(`Scanned QR Code: ` + decodedText + ``);
        stopScanning(); // 停止扫描
        showToast('已识别二维码，正在处理...');

        const submitBtn = document.getElementById('submitBtn');
        const keyForm = document.getElementById('keyForm');
// 创建一个临时的表单来提交数据
        const tempForm = document.createElement('form');
        tempForm.action = '/save-secret';
// 或者新的接口，如 '/save-secret-from-qr'
        tempForm.method = 'POST';
// 将扫码结果和CSRF token添加到临时表单中
        const qrInput = document.createElement('input');
        qrInput.type = 'hidden';
        qrInput.name = 'qrContent';
// 假设后端接口接收一个名为 'qrCodeText' 的参数
        qrInput.value = decodedText;
        tempForm.appendChild(qrInput);

        const csrfInput = document.createElement('input');
        csrfInput.type = 'hidden';
        csrfInput.name = '_csrf';
        csrfInput.value = csrfToken;
        tempForm.appendChild(csrfInput);

        document.body.appendChild(tempForm);
        tempForm.submit();
// 提交表单

        // 如果后端接口是异步的，可以使用 fetch
        /*
        const formData = new FormData();
formData.append('qrContent', decodedText);
        formData.append('_csrf', csrfToken);

        try {
            const response = await fetch('/save-secret-from-qr', {
                method: 'POST',
                body: formData
            });
if (response.ok) {
                showToast('添加成功');
                closeAddKeyModal();
loadOTPKeys();
            } else {
                showToast('添加失败');
}
        } catch (error) {
            console.error('Error:', error);
showToast('添加失败，请重试');
        }
        */
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
        formData.append('_csrf', csrfToken);
        try {
            const response = await fetch('/save-secret', {
                method: 'POST',
                body: formData
            });
            if (response.ok) {
                showToast('添加成功');
                closeAddKeyModal();
                otpKeysData.push({
                    keyName: keyName,
                    secretKey: secretKey,
                    issuer: 'default'
                });
                renderOTPList();
            } else {
                const errorText = await response.text();
                console.error('Server error:', errorText);
                throw new Error('添加失败');
            }
        } catch (error) {
            console.error('Error:', error);
            showToast('添加失败，请重试');
        } finally {
            submitBtn.disabled = false;
            submitBtn.textContent = '添加';
        }
    }

    // 删除密钥
    async function deleteKey(keyName) {
        try {
            const response = await fetch('/delete-key', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRF-TOKEN': csrfToken
                },
                body: JSON.stringify({ keyName: keyName })
            });
            if (response.ok) {
                showToast('删除成功');
                otpKeysData = otpKeysData.filter(key => key.keyName !== keyName);
                renderOTPList();
            } else {
                throw new Error('删除失败');
            }
        } catch (error) {
            console.error('Error:', error);
            showToast('删除失败，请重试');
        }
    }

    // 显示Toast提示
    function showToast(message) {
        const existingToast = document.querySelector('.toast');
        if (existingToast) {
            existingToast.remove();
        }

        const toast = document.createElement('div');
        toast.className = 'toast';
        toast.textContent = message;
        document.body.appendChild(toast);
        setTimeout(() => {
            toast.remove();
        }, 2000);
    }

    // 模态框背景点击关闭
    document.getElementById('addKeyModal').addEventListener('click', function(e) {
        if (e.target === this) {
            closeAddKeyModal();
        }
    });
    // 滑动删除功能
    let touchStartX = 0;
    let touchEndX = 0;
    let currentSwipedItem = null;
    let isSwiping = false;

    document.addEventListener('touchstart', function(e) {
        const otpItem = e.target.closest('.otp-item');
        if (otpItem) {
            if (currentSwipedItem && currentSwipedItem !== otpItem) {
                currentSwipedItem.classList.remove('swiped');
                const deleteBtn = currentSwipedItem.querySelector('.swipe-delete');
                if (deleteBtn) deleteBtn.remove();
            }
            touchStartX = e.touches[0].clientX;
            currentSwipedItem = otpItem;
            isSwiping = false;
        }
    });

    document.addEventListener('touchmove', function(e) {
        if (!currentSwipedItem) return;
        touchEndX = e.touches[0].clientX;
        const diff = touchStartX - touchEndX;

        if (diff > 50) {
            let deleteBtn = currentSwipedItem.querySelector('.swipe-delete');
            if (!deleteBtn) {
                deleteBtn = document.createElement('div');
                deleteBtn.className = 'swipe-delete';
                deleteBtn.innerHTML = '🗑️';
                deleteBtn.onclick = function() {
                    if (currentSwipedItem) {
                        const keyName = currentSwipedItem.getAttribute('data-key');
                        // 弹出确认对话框
                        if (confirm(`确定要删除 "` + keyName + `" 吗？`)) {
                            deleteKey(keyName);
                        }
                    }
                };
                currentSwipedItem.style.position = 'relative';
                currentSwipedItem.appendChild(deleteBtn);
            }
            currentSwipedItem.classList.add('swiped');
            isSwiping = true;
        } else if (diff < -50) {
            currentSwipedItem.classList.remove('swiped');
            setTimeout(() => {
                if (currentSwipedItem) {
                    const deleteBtn = currentSwipedItem.querySelector('.swipe-delete');
                    if (deleteBtn) deleteBtn.remove();
                }
            }, 300);
            isSwiping = false;
        }
    });

    document.addEventListener('touchend', function() {
        if (!isSwiping) {
            currentSwipedItem = null;
        }
        touchStartX = 0;
        touchEndX = 0;
    });
    // 页面卸载时清理
    window.addEventListener('beforeunload', function() {
        if (globalUpdateTimer) {
            clearInterval(globalUpdateTimer);
        }
        stopScanning();
    });
</script>

<script data-csrf-token="${_csrf.token!}">
    var otpKeys = [
        <#list (otpKeys)! as otpKey>
        {
            id: ${otpKey.id},
            keyName: "${otpKey.keyName}",
            secretKey: "${otpKey.secretKey}",
            qrCode: "${otpKey.qrCode!''}",
            issuer: "${otpKey.issuer!''}",
            createTime: "${otpKey.formattedCreateTime}",
            updateTime: "${otpKey.formattedUpdateTime}"
        }<#if otpKey_has_next>,</#if>
        </#list>
    ];
    console.log("后端注入的 otpKeys:", otpKeys);
</script>

</body>
</html>