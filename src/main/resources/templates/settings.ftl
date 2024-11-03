<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>System Settings - OTP Management</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <style>
        /* 基础样式保持不变 */
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
            .sidebar {
                transform: translateX(-280px);
            }

            .main-content {
                margin-left: 0;
                padding: 20px;
            }
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
            <a href="/" class="menu-item">
                <i>🔑</i>
                MFA Management
            </a>
            <a href="/settings" class="menu-item active">
                <i>☁️️</i>
                Sync Cloud Settings
            </a>
        </nav>
    </aside>

    <main class="main-content">
        <div class="card">
            <h2>Sync Settings</h2>

            <!-- Alist配置 -->
            <div class="settings-section">
                <div class="settings-header">Alist Configuration</div>
                <form id="settingsForm" onsubmit="return false;">
                    <div class="form-group">
                        <label class="toggle-container">
                            <label class="switch">
                                <input type="checkbox" id="enableSync" onchange="validateForm()">
                                <span class="slider"></span>
                            </label>
                            <span>Enable Alist Sync</span>
                        </label>
                    </div>

                    <div class="form-group">
                        <label for="alistUrl">Alist Server URL</label>
                        <input type="text" id="alistUrl" class="form-control"
                               placeholder="https://your-alist-server.com"
                               onchange="validateForm()">
                        <small class="form-text text-muted">Enter your Alist server URL</small>
                    </div>

                    <div class="form-group">
                        <label for="userName">AList UserName</label>
                        <input type="text" id="userName" class="form-control"
                               placeholder="Enter your AList Login UserName"
                               onchange="validateForm()">
                        <small class="form-text text-muted">Your AList userName</small>
                    </div>

                    <div class="form-group">
                        <label for="password">AList Password</label>
                        <input type="password" id="password" class="form-control"
                               placeholder="Enter your AList Login Password"
                               onchange="validateForm()">
                        <small class="form-text text-muted">Your AList Login Password</small>
                    </div>

                    <div class="form-group">
                        <label for="backupPath">Backup Path</label>
                        <input type="text" id="backupPath" class="form-control"
                               placeholder="/backup/otp"
                               onchange="validateForm()">
                        <small class="form-text text-muted">Path where backups will be stored</small>
                    </div>

                    <div class="form-group">
                        <label for="syncInterval">Sync Interval</label>
                        <select id="syncInterval" class="form-control" onchange="validateForm()">
                            <option value="1">Every Day</option>
                            <option value="7">Every Week</option>
                            <option value="14">Every Two Weeks</option>
                            <option value="30">Every Month</option>
                        </select>
                    </div>

                    <div class="button-group">
                        <button type="button" id="saveButton" class="btn btn-primary"
                                onclick="saveSettings()">Save Settings</button>
                        <button type="button" class="btn btn-secondary test-btn"
                                onclick="testConnection()">Test Connection</button>
                        <button type="button" class="btn btn-info sync-btn"
                                onclick="syncNow()">Sync Now</button>
                    </div>
                </form>

                <div id="statusMessage" class="settings-status mt-3"></div>
            </div>

            <!-- 同步历史 -->
            <div class="settings-section">
                <div class="settings-header">Sync History</div>
                <div class="sync-history">
                    <table>
                        <thead>
                        <tr>
                            <th>Time</th>
                            <th>Status</th>
                            <th>Details</th>
                            <th>Size</th>
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
                updateStatus('Please enter URL and Token first', 'status-error');
                return;
            }

            updateStatus('Testing connection...', 'status-pending');

            const response = await fetch('/api/test-connection', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRF-TOKEN': csrf_value
                },
                body: JSON.stringify({ url, password,backupPath,userName })
            });

            const result = await response.json();
            updateStatus(
                result.success ? 'Connection successful!' : 'Connection failed: ' + result.message,
                result.success ? 'status-success' : 'status-error'
            );
        } catch (error) {
            console.error('Test connection failed:', error);
            updateStatus('Connection test failed: ' + error.message, 'status-error');
        }
    }

    // 保存设置
    async function saveSettings() {
        if (!validateForm()) {
            updateStatus('Please fill in all required fields', 'status-error');
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
            updateStatus('Saving settings...', 'status-pending');

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
                updateStatus('Settings saved successfully', 'status-success');
                loadHistory();
            } else {
                updateStatus('Failed to save settings: ' + result.message, 'status-error');
            }
        } catch (error) {
            console.error('Failed to save settings:', error);
            updateStatus('Failed to save settings: ' + error.message, 'status-error');
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
                    const statusText = record.success ? 'Success' : 'Failed';
                    const size = formatSize(record.size);

                    html += '<tr>';
                    html += '<td>' + time + '</td>';
                    html += '<td class="' + statusClass + '">' + statusText + '</td>';
                    html += '<td>' + record.details + '</td>';
                    html += '<td>' + size + '</td>';
                    html += '</tr>';
                });
            } else {
                html = '<tr><td colspan="4" style="text-align: center">No sync history available</td></tr>';
            }

            historyTable.innerHTML = html;
        } catch (error) {
            console.error('Failed to load history:', error);
            const historyTable = document.getElementById('historyTable');
            historyTable.innerHTML = '<tr><td colspan="4" style="text-align: center; color: #f56565;">Failed to load sync history</td></tr>';
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
            // 如果未启用同步，允许保存
            saveButton.disabled = false;
            return true;
        }

        // 获取所有必填字段的值
        const url = document.getElementById('alistUrl').value.trim();
        const userName = document.getElementById('userName').value.trim();
        const password = document.getElementById('password').value.trim();
        const path = document.getElementById('backupPath').value.trim();

        // 验证必填字段
        const isValid = url && userName && password && path;

        // 更新保存按钮状态
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

                // 添加最后同步时间显示
                if (settings.lastSyncTime) {
                    const lastSyncDate = new Date(settings.lastSyncTime);
                    updateStatus('Last sync: ' + lastSyncDate.toLocaleString(), 'status-success');
                }

                validateForm();
            }
        } catch (error) {
            console.error('Failed to load settings:', error);
            updateStatus('Failed to load settings', 'status-error');
        }
    }

    // 页面加载时初始化
    document.addEventListener('DOMContentLoaded', function() {
        loadSettings();
        loadHistory();
    });

    // 添加立即同步功能
    async function syncNow() {
        try {
            const enabled = document.getElementById('enableSync').checked;
            if (!enabled) {
                updateStatus('Please enable sync first', 'status-error');
                return;
            }

            if (!validateForm()) {
                updateStatus('Please fill in all required fields before syncing', 'status-error');
                return;
            }

            updateStatus('Starting sync...', 'status-pending');

            const response = await fetch('/api/sync-now', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRF-TOKEN': csrf_value
                }
            });

            const result = await response.json();

            if (result.success) {
                updateStatus('Sync completed successfully', 'status-success');
                // 更新同步历史
                await loadHistory();
                // 重新加载设置以更新最后同步时间
                await loadSettings();
            } else {
                updateStatus('Sync failed: ' + (result.message || 'Unknown error'), 'status-error');
            }
        } catch (error) {
            console.error('Sync failed:', error);
            updateStatus('Sync failed: ' + error.message, 'status-error');
        }
    }
</script>
</body>
</html>