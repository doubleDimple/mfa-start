<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>System Settings - OTP Management</title>
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

        input[type="text"],
        input[type="password"],
        select {
            width: 100%;
            padding: 12px 20px;
            border: 2px solid #e2e8f0;
            border-radius: 10px;
            font-size: 14px;
            transition: all 0.3s ease;
        }

        input[type="text"]:focus,
        input[type="password"]:focus,
        select:focus {
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
            outline: none;
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

        button:disabled {
            background: #cbd5e0;
            cursor: not-allowed;
            transform: none;
            box-shadow: none;
        }

        .settings-section {
            border-bottom: 1px solid #e2e8f0;
            padding-bottom: 20px;
            margin-bottom: 20px;
        }

        .settings-section:last-child {
            border-bottom: none;
            margin-bottom: 0;
        }

        .settings-header {
            font-size: 18px;
            color: #2d3748;
            margin-bottom: 20px;
            font-weight: 600;
        }

        .button-group {
            display: flex;
            gap: 10px;
            margin-top: 20px;
        }

        .test-btn {
            background: linear-gradient(135deg, #48bb78 0%, #38a169 100%);
        }

        .test-btn:hover {
            background: linear-gradient(135deg, #38a169 0%, #2f855a 100%);
        }

        .sync-btn {
            background: linear-gradient(135deg, #3182ce 0%, #2c5282 100%);
        }

        .sync-btn:hover {
            background: linear-gradient(135deg, #2c5282 0%, #2a4365 100%);
        }

        .settings-status {
            margin-top: 15px;
            padding: 15px;
            border-radius: 10px;
            background: #f7fafc;
            font-size: 14px;
            color: #4a5568;
        }

        .status-success {
            background-color: #d4edda;
            color: #155724;
        }

        .status-error {
            background-color: #f8d7da;
            color: #721c24;
        }

        .status-pending {
            background-color: #fff3cd;
            color: #856404;
        }

        .sync-history {
            margin-top: 20px;
        }

        .sync-history table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 10px;
        }

        .sync-history th,
        .sync-history td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #e2e8f0;
        }

        .sync-history th {
            font-weight: 600;
            color: #4a5568;
            background: #f7fafc;
        }

        .sync-history tr:last-child td {
            border-bottom: none;
        }

        .switch {
            position: relative;
            display: inline-block;
            width: 60px;
            height: 34px;
        }

        .switch input {
            opacity: 0;
            width: 0;
            height: 0;
        }

        .slider {
            position: absolute;
            cursor: pointer;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background-color: #cbd5e0;
            transition: .4s;
            border-radius: 34px;
        }

        .slider:before {
            position: absolute;
            content: "";
            height: 26px;
            width: 26px;
            left: 4px;
            bottom: 4px;
            background-color: white;
            transition: .4s;
            border-radius: 50%;
        }

        input:checked + .slider {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }

        input:checked + .slider:before {
            transform: translateX(26px);
        }

        .toggle-container {
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 20px;
        }

        .form-text {
            font-size: 0.875rem;
            color: #6c757d;
            margin-top: 4px;
        }

        @media (max-width: 768px) {
            .main-content {
                margin-left: 0;
                padding: 20px;
            }

            .button-group {
                flex-direction: column;
            }

            .sync-history table {
                display: block;
                overflow-x: auto;
                white-space: nowrap;
            }
        }
    </style>
</head>
<body>
<div class="layout-container">
    <!-- 引入公共侧边栏 -->
    <#include "common/sidebar.ftl">

    <main class="main-content">
        <div class="card">
            <h2>同步设置</h2>

            <!-- Alist配置 -->
            <div class="settings-section">
                <div class="settings-header">Alist 配置</div>
                <form id="settingsForm" onsubmit="return false;">
                    <div class="form-group">
                        <label class="toggle-container">
                            <label class="switch">
                                <input type="checkbox" id="enableSync" onchange="validateForm()">
                                <span class="slider"></span>
                            </label>
                            <span>启用同步</span>
                        </label>
                    </div>

                    <div class="form-group">
                        <label for="alistUrl">Alist 服务地址</label>
                        <input type="text" id="alistUrl" class="form-control"
                               placeholder="https://your-alist-server.com"
                               onchange="validateForm()">
                        <small class="form-text text-muted">输入你的Alist服务地址</small>
                    </div>

                    <div class="form-group">
                        <label for="userName">AList 用户名</label>
                        <input type="text" id="userName" class="form-control"
                               placeholder="Enter your AList Login UserName"
                               onchange="validateForm()">
                        <small class="form-text text-muted">你的Alist用户名</small>
                    </div>

                    <div class="form-group">
                        <label for="password">AList 密码</label>
                        <input type="password" id="password" class="form-control"
                               placeholder="Enter your AList Login Password"
                               onchange="validateForm()">
                        <small class="form-text text-muted">你的AList登录密码</small>
                    </div>

                    <div class="form-group">
                        <label for="backupPath">备份路径</label>
                        <input type="text" id="backupPath" class="form-control"
                               placeholder="/backup/otp"
                               onchange="validateForm()">
                        <small class="form-text text-muted">备份文件存储路径</small>
                    </div>

                    <div class="form-group">
                        <label for="syncInterval">同步设置</label>
                        <select id="syncInterval" class="form-control" onchange="validateForm()">
                            <option value="1">每天</option>
                            <option value="7">每周</option>
                            <option value="14">每两周</option>
                            <option value="30">每个月</option>
                        </select>
                    </div>

                    <div class="button-group">
                        <button type="button" id="saveButton" class="btn btn-primary"
                                onclick="saveSettings()">
                            <i class="fas fa-save"></i>
                            保存设置
                        </button>
                        <button type="button" class="btn btn-secondary test-btn"
                                onclick="testConnection()">
                            <i class="fas fa-plug"></i>
                            测试连接
                        </button>
                        <button type="button" class="btn btn-info sync-btn"
                                onclick="syncNow()">
                            <i class="fas fa-sync-alt"></i>
                            开始备份
                        </button>
                    </div>
                </form>

                <div id="statusMessage" class="settings-status mt-3"></div>
            </div>

            <!-- 同步历史 -->
            <div class="settings-section">
                <div class="settings-header">备份历史</div>
                <div class="sync-history">
                    <table>
                        <thead>
                        <tr>
                            <th>时间</th>
                            <th>状态</th>
                            <th>详细信息</th>
                            <th>备份大小</th>
                        </tr>
                        </thead>
                        <tbody id="historyTable">
                        <!-- 由JavaScript动态填充 -->
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </main>
</div>

<script>
    // 设置当前页面
    document.addEventListener('DOMContentLoaded', function() {
        setActiveMenuItem('settings');
        loadSettings();
        loadHistory();
    });

    // CSRF token
    const csrf_name = "${_csrf.parameterName}";
    const csrf_value = "${_csrf.token}";

    // 测试连接
    async function testConnection() {
        try {
            const url = document.getElementById('alistUrl').value;
            const password = document.getElementById('password').value;
            const userName = document.getElementById('userName').value;
            const backupPath = document.getElementById('backupPath').value;

            if (!url || !password || !userName || !backupPath) {
                updateStatus('请先填写完整的URL和认证信息', 'status-error');
                return;
            }

            updateStatus('正在测试连接...', 'status-pending');

            const response = await fetch('/api/test-connection', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRF-TOKEN': csrf_value
                },
                body: JSON.stringify({ url, password, backupPath, userName })
            });

            const result = await response.json();
            updateStatus(
                result.success ? '连接测试成功！' : '连接失败：' + result.message,
                result.success ? 'status-success' : 'status-error'
            );
        } catch (error) {
            console.error('Test connection failed:', error);
            updateStatus('连接测试失败：' + error.message, 'status-error');
        }
    }

    // 保存设置
    async function saveSettings() {
        if (!validateForm()) {
            updateStatus('请填写所有必需字段', 'status-error');
            return;
        }

        try {
            const settings = {
                enabled: document.getElementById('enableSync').checked,
                alistUrl: document.getElementById('alistUrl').value.trim(),
                userName: document.getElementById('userName').value.trim(),
                password: document.getElementById('password').value.trim(),
                backupPath: document.getElementById('backupPath').value.trim(),
                syncInterval: document.getElementById('syncInterval').value
            };

            console.log('Saving settings:', settings);
            updateStatus('正在保存设置...', 'status-pending');

            const response = await fetch('/api/save-settings', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRF-TOKEN': csrf_value
                },
                body: JSON.stringify(settings)
            });

            const result = await response.json();
            if (result.success) {
                updateStatus('设置保存成功', 'status-success');
                loadHistory();
            } else {
                updateStatus('设置保存失败：' + result.message, 'status-error');
            }
        } catch (error) {
            console.error('Failed to save settings:', error);
            updateStatus('设置保存失败：' + error.message, 'status-error');
        }
    }

    // 更新状态显示
    function updateStatus(message, className) {
        const statusDiv = document.getElementById('statusMessage');
        statusDiv.textContent = message;
        statusDiv.className = 'settings-status ' + className;
    }

    // 加载同步历史
    async function loadHistory() {
        try {
            const response = await fetch('/api/sync-history', {
                headers: {
                    'X-CSRF-TOKEN': csrf_value
                }
            });
            const history = await response.json();

            const historyTable = document.getElementById('historyTable');
            let html = '';

            if (history && history.length > 0) {
                history.forEach(function(record) {
                    const time = new Date(record.time).toLocaleString();
                    const statusClass = record.success ? 'status-success' : 'status-error';
                    const statusText = record.success ? '成功' : '失败';
                    const size = formatSize(record.size);

                    html += '<tr>';
                    html += '<td>' + time + '</td>';
                    html += '<td class="' + statusClass + '">' + statusText + '</td>';
                    html += '<td>' + record.details + '</td>';
                    html += '<td>' + size + '</td>';
                    html += '</tr>';
                });
            } else {
                html = '<tr><td colspan="4" style="text-align: center; color: #718096;">暂无同步历史</td></tr>';
            }

            historyTable.innerHTML = html;
        } catch (error) {
            console.error('Failed to load history:', error);
            const historyTable = document.getElementById('historyTable');
            historyTable.innerHTML = '<tr><td colspan="4" style="text-align: center; color: #f56565;">加载同步历史失败</td></tr>';
        }
    }

    // 格式化文件大小
    function formatSize(bytes) {
        if (!bytes) return '0 B';
        const k = 1024;
        const sizes = ['B', 'KB', 'MB', 'GB'];
        const i = Math.floor(Math.log(bytes) / Math.log(k));
        return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
    }

    // 表单验证
    function validateForm() {
        const enabled = document.getElementById('enableSync').checked;
        const saveButton = document.getElementById('saveButton');

        if (!enabled) {
            saveButton.disabled = false;
            return true;
        }

        const url = document.getElementById('alistUrl').value.trim();
        const userName = document.getElementById('userName').value.trim();
        const password = document.getElementById('password').value.trim();
        const path = document.getElementById('backupPath').value.trim();

        const isValid = url && userName && password && path;
        saveButton.disabled = !isValid;

        return isValid;
    }

    // 加载现有设置
    async function loadSettings() {
        try {
            const response = await fetch('/api/settings', {
                headers: {
                    'X-CSRF-TOKEN': csrf_value
                }
            });
            const settings = await response.json();

            if (settings) {
                document.getElementById('enableSync').checked = settings.enabled;
                document.getElementById('alistUrl').value = settings.alistUrl || '';
                document.getElementById('userName').value = settings.userName || '';
                document.getElementById('password').value = settings.password || '';
                document.getElementById('backupPath').value = settings.backupPath || '';
                document.getElementById('syncInterval').value = settings.syncInterval || '7';

                if (settings.lastSyncTime) {
                    const lastSyncDate = new Date(settings.lastSyncTime);
                    updateStatus('最后同步时间：' + lastSyncDate.toLocaleString(), 'status-success');
                }

                validateForm();
            }
        } catch (error) {
            console.error('Failed to load settings:', error);
            updateStatus('加载设置失败', 'status-error');
        }
    }

    // 立即同步功能
    async function syncNow() {
        try {
            const enabled = document.getElementById('enableSync').checked;
            if (!enabled) {
                updateStatus('请先启用同步功能', 'status-error');
                return;
            }

            if (!validateForm()) {
                updateStatus('请先填写完整配置信息', 'status-error');
                return;
            }

            updateStatus('正在启动同步...', 'status-pending');

            const response = await fetch('/api/sync-now', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRF-TOKEN': csrf_value
                }
            });

            const result = await response.json();

            if (result.success) {
                updateStatus('同步完成', 'status-success');
                await loadHistory();
                await loadSettings();
            } else {
                updateStatus('同步失败：' + (result.message || '未知错误'), 'status-error');
            }
        } catch (error) {
            console.error('Sync failed:', error);
            updateStatus('同步失败：' + error.message, 'status-error');
        }
    }
</script>
</body>
</html>