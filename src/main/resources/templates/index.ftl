<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>OTP Key Management</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">

    <!-- 在 <head> 中添加 SweetAlert2 -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/sweetalert2/11.7.32/sweetalert2.min.js"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/sweetalert2/11.7.32/sweetalert2.min.css">


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

        .modal {
            display: none;
            position: fixed;
            z-index: 10000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.5);
            backdrop-filter: blur(5px);
            animation: fadeIn 0.3s ease;
        }

        .modal.show {
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .modal-content {
            background: white;
            border-radius: 20px;
            padding: 30px;
            width: 90%;
            max-width: 600px;
            max-height: 90vh;
            overflow-y: auto;
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
            transform: scale(0.8);
            animation: modalSlideIn 0.3s ease forwards;
        }

        .modal-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 25px;
            padding-bottom: 15px;
            border-bottom: 2px solid #e2e8f0;
        }

        .modal-title {
            color: #2d3748;
            font-size: 24px;
            font-weight: 600;
            margin: 0;
        }

        .close-btn {
            background: none;
            border: none;
            font-size: 24px;
            color: #718096;
            cursor: pointer;
            padding: 5px;
            border-radius: 50%;
            width: 40px;
            height: 40px;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.3s ease;
        }

        .close-btn:hover {
            background: #f7fafc;
            color: #2d3748;
            transform: none;
            box-shadow: none;
        }

        .add-key-btn {
            background: linear-gradient(135deg, #38a169 0%, #2f855a 100%);
            margin-right: 10px;
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }

        .add-key-btn:hover {
            background: linear-gradient(135deg, #2f855a 0%, #276749 100%);
        }

        .export-btn {
            background: linear-gradient(135deg, #28a745 0%, #218838 100%);
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

        .header-controls {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }

        .modal-footer {
            display: flex;
            justify-content: flex-end;
            gap: 10px;
            margin-top: 25px;
            padding-top: 20px;
            border-top: 2px solid #e2e8f0;
        }

        .cancel-btn {
            background: #e2e8f0;
            color: #4a5568;
        }

        .cancel-btn:hover {
            background: #cbd5e0;
            transform: translateY(-2px);
        }

        @keyframes fadeIn {
            from { opacity: 0; }
            to { opacity: 1; }
        }

        @keyframes modalSlideIn {
            from {
                transform: scale(0.8) translateY(20px);
                opacity: 0;
            }
            to {
                transform: scale(1) translateY(0);
                opacity: 1;
            }
        }

        @media (max-width: 768px) {
            .main-content {
                margin-left: 0;
                padding: 20px;
            }

            .modal-content {
                width: 95%;
                padding: 20px;
                margin: 10px;
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

            .button-group {
                flex-direction: column;
            }
        }

        .import-btn {
            background: linear-gradient(135deg, #3182ce 0%, #2c5282 100%);
            margin-right: 10px;
        }

        .import-btn:hover {
            background: linear-gradient(135deg, #2c5282 0%, #2a4365 100%);
        }
    </style>
</head>
<body>
<div class="layout-container">
    <!-- 引入公共侧边栏 -->
    <#include "common/sidebar.ftl">

    <main class="main-content">
        <div class="card">
            <div class="header-controls">
                <h2>密钥管理</h2>
                <div class="button-group">
                    <button class="add-key-btn" onclick="openAddKeyModal()">
                        <i class="fas fa-plus"></i>
                        添加密钥
                    </button>
                    <button onclick="openImportModal()" class="import-btn">
                        <i class="fas fa-upload"></i>
                        导入
                    </button>
                    <button onclick="exportData()" class="export-btn">
                        <i class="fas fa-download"></i>
                        导出
                    </button>
                </div>
            </div>

            <input type="text" id="searchInput" placeholder="搜索密钥..." onkeyup="searchKeys()">

            <table>
                <thead>
                <tr>
                    <th>密钥名称</th>
                    <th>密钥信息</th>
                    <th>密钥</th>
                    <th>二维码</th>
                    <th>验证码</th>
                    <th>创建时间</th>
                    <th>操作</th>
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
                                <#if otpKey.qrCode??>
                                    <img src="data:image/png;base64,${otpKey.qrCode}" alt="QR Code" onclick="enlargeQrCode(this)">
                                <#else>
                                    <span style="color: #999;">无二维码</span>
                                </#if>
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
                            <td>${otpKey.formattedCreateTime!'default'}</td>
                            <td>
                                <button class="delete-btn" onclick="deleteKey('${otpKey.keyName}')">删除</button>
                            </td>
                        </tr>
                    </#list>
                <#else>
                    <tr>
                        <td colspan="7" style="text-align: center; color: #718096; padding: 40px;">暂无OTP密钥</td>
                    </tr>
                </#if>
                </tbody>
            </table>
        </div>
    </main>
</div>

<!-- 添加密钥模态框 -->
<div id="addKeyModal" class="modal">
    <div class="modal-content">
        <div class="modal-header">
            <h3 class="modal-title">添加密钥</h3>
            <button class="close-btn" onclick="closeAddKeyModal()">
                <i class="fas fa-times"></i>
            </button>
        </div>

        <form action="/save-secret" method="post" enctype="multipart/form-data" id="keyForm">
            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>

            <div class="form-group">
                <label for="keyName">密钥名称:</label>
                <input type="text" id="keyName" name="keyName" required placeholder="请输入密钥名称">
            </div>

            <div class="form-group">
                <label for="secretKey">密钥:</label>
                <input type="text" id="secretKey" name="secretKey" required placeholder="请输入密钥或上传二维码">
            </div>

            <div class="file-upload" id="pasteZone">
                <label class="file-upload-btn">
                    上传密钥二维码
                    <input type="file" id="qrCode" name="qrCode" accept="image/*">
                </label>
                <div id="fileName">暂无文件</div>
                <img id="previewImage" class="preview-image" alt="QR Code preview">
                <div class="paste-zone" id="pasteArea">
                    此处点击上传和粘贴文件
                </div>
            </div>

            <div class="modal-footer">
                <button type="button" class="cancel-btn" onclick="closeAddKeyModal()">取消</button>
                <button type="submit">保存</button>
            </div>
        </form>
    </div>
</div>

<!-- 导入密钥模态框 -->
<div id="importModal" class="modal">
    <div class="modal-content">
        <div class="modal-header">
            <h3 class="modal-title">导入密钥</h3>
            <button class="close-btn" onclick="closeImportModal()">
                <i class="fas fa-times"></i>
            </button>
        </div>

        <form action="/import-keys" method="post" enctype="multipart/form-data" id="importForm">
            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>

            <div class="form-group">
                <label for="csvFile">选择CSV文件:</label>
                <div class="file-upload">
                    <label class="file-upload-btn">
                        选择文件
                        <input type="file" id="csvFile" name="csvFile" accept=".csv" required>
                    </label>
                    <div id="csvFileName">暂无文件</div>
                </div>
                <small class="form-text text-muted">支持从导出的CSV文件导入密钥数据</small>
            </div>

            <div class="modal-footer">
                <button type="button" class="cancel-btn" onclick="closeImportModal()">取消</button>
                <button type="submit">导入</button>
            </div>
        </form>
    </div>
</div>

<script>
    // 设置当前页面
    document.addEventListener('DOMContentLoaded', function() {
        setActiveMenuItem('index');
    });

    // 全局变量
    let globalUpdateTimer = null;

    // 模态框控制函数
    function openAddKeyModal() {
        const modal = document.getElementById('addKeyModal');
        modal.classList.add('show');
        document.body.style.overflow = 'hidden';
        resetForm();
    }

    function closeAddKeyModal() {
        const modal = document.getElementById('addKeyModal');
        modal.classList.remove('show');
        document.body.style.overflow = 'auto';
        resetForm();
    }

    function resetForm() {
        document.getElementById('keyForm').reset();
        document.getElementById('fileName').textContent = '暂无文件';
        document.getElementById('previewImage').style.display = 'none';
        document.getElementById('secretKey').readOnly = false;
    }

    // 点击模态框背景关闭
    document.getElementById('addKeyModal').addEventListener('click', function(e) {
        if (e.target === this) {
            closeAddKeyModal();
        }
    });

    // ESC键关闭模态框
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') {
            closeAddKeyModal();
        }
    });

    // OTP代码批量更新函数
    async function updateOtpCodes() {
        const otpElements = document.querySelectorAll('.otp-code');
        if (otpElements.length === 0) return;

        const secretKeys = Array.from(otpElements)
            .map(element => element.getAttribute('data-secret-key'))
            .filter(key => key && key.trim() !== '');

        try {
            const csrfToken = document.querySelector('input[name="${_csrf.parameterName}"]')?.value || '';
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
            const otpMap = new Map(
                otpResponses.map(response => [response.secretKey, response.otpCode])
            );

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
            document.getElementById('fileName').textContent = '暂无文件';
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
        const result = await Swal.fire({
            title: '确认删除',
            text: `确定要删除密钥 "`+ keyName+`" 吗？`,
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#dc3545',
            cancelButtonColor: '#6c757d',
            confirmButtonText: '删除',
            cancelButtonText: '取消',
            reverseButtons: true
        });

        if (result.isConfirmed) {
            try {
                const csrfToken = document.querySelector('input[name="${_csrf.parameterName}"]')?.value || '';
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

                await Swal.fire({
                    title: '删除成功',
                    text: '密钥已成功删除',
                    icon: 'success',
                    timer: 1500,
                    showConfirmButton: false
                });

                location.reload();
            } catch (error) {
                console.error('Error deleting key:', error);
                await Swal.fire({
                    title: '删除失败',
                    text: '删除密钥时发生错误，请重试',
                    icon: 'error',
                    confirmButtonText: '确定'
                });
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
        enlargedImg.style.zIndex = '10001';

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

    // 导出数据函数
    function exportData() {
        try {
            const rows = [];
            const headers = ['Key Name', 'Issuer', 'Secret Key'];
            rows.push(headers);

            document.querySelectorAll('tbody tr').forEach(function(row) {
                if (row.cells.length < 3) return;

                const rowData = [
                    row.cells[0].textContent,
                    row.cells[1].textContent,
                    row.cells[2].getAttribute('data-secret-key') || ''
                ];
                rows.push(rowData);
            });

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

            const csvContent = rows
                .map(function(row) {
                    return row.map(processCell).join(',');
                })
                .join('\n');

            const blob = new Blob(['\ufeff' + csvContent], { type: 'text/csv;charset=utf-8' });
            const url = window.URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;

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
            Swal.fire({
                title: '导出失败',
                text: '导出数据时发生错误，请重试',
                icon: 'error',
                confirmButtonText: '确定'
            });
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

    // 页面初始化
    window.addEventListener('load', () => {
        updateOtpCodes();
        initializeCountdown();
    });

    // 页面卸载时清理
    window.addEventListener('beforeunload', () => {
        if (globalUpdateTimer) {
            clearInterval(globalUpdateTimer);
        }
    });

    // 导入模态框控制
    function openImportModal() {
        const modal = document.getElementById('importModal');
        modal.classList.add('show');
        document.body.style.overflow = 'hidden';
        resetImportForm();
    }

    function closeImportModal() {
        const modal = document.getElementById('importModal');
        modal.classList.remove('show');
        document.body.style.overflow = 'auto';
        resetImportForm();
    }

    function resetImportForm() {
        document.getElementById('importForm').reset();
        document.getElementById('csvFileName').textContent = '暂无文件';
    }

    // CSV文件选择处理
    document.getElementById('csvFile').addEventListener('change', function(e) {
        const file = e.target.files[0];
        if (file) {
            document.getElementById('csvFileName').textContent = file.name;
        } else {
            document.getElementById('csvFileName').textContent = '暂无文件';
        }
    });

    // 导入模态框点击背景关闭
    document.getElementById('importModal').addEventListener('click', function(e) {
        if (e.target === this) {
            closeImportModal();
        }
    });
</script>
</body>
</html>