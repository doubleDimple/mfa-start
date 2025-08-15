<!-- 公共侧边栏组件 sidebar.ftl -->
<style>
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
        display: flex;
        flex-direction: column;
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
        flex: 1;
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

    /* 侧边栏底部区域 */
    .sidebar-footer {
        padding: 20px;
        border-top: 1px solid rgba(255, 255, 255, 0.1);
        margin-top: auto;
    }

    /* 退出按钮样式 */
    .logout-btn {
        width: 100%;
        background: rgba(220, 53, 69, 0.2);
        color: #fff;
        border: 2px solid rgba(220, 53, 69, 0.3);
        padding: 12px 20px;
        border-radius: 10px;
        font-weight: 600;
        cursor: pointer;
        transition: all 0.3s ease;
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 8px;
        text-decoration: none;
        font-size: 14px;
    }

    .logout-btn:hover {
        background: rgba(220, 53, 69, 0.3);
        border-color: rgba(220, 53, 69, 0.5);
        transform: translateY(-2px);
        box-shadow: 0 5px 15px rgba(220, 53, 69, 0.3);
    }

    .logout-btn:active {
        transform: translateY(0);
    }

    /* 响应式设计 */
    @media (max-width: 768px) {
        .sidebar {
            transform: translateX(-280px);
        }

        .sidebar.mobile-open {
            transform: translateX(0);
        }
    }

    /* 移动端汉堡菜单按钮 */
    .mobile-menu-toggle {
        display: none;
        position: fixed;
        top: 20px;
        left: 20px;
        z-index: 1001;
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: white;
        border: none;
        padding: 10px 12px;
        border-radius: 8px;
        cursor: pointer;
        font-size: 18px;
        box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
    }

    @media (max-width: 768px) {
        .mobile-menu-toggle {
            display: block;
        }
    }
</style>

<!-- 移动端菜单切换按钮 -->
<button class="mobile-menu-toggle" onclick="toggleMobileSidebar()">
    <i class="fas fa-bars"></i>
</button>

<aside class="sidebar" id="sidebar">
    <div class="sidebar-header">
        <div class="logo-container">
            <div class="logo">
                <span>🔐</span>
            </div>
            <h2>OTP 管理</h2>
        </div>
    </div>

    <nav class="sidebar-menu">
        <a href="/" class="menu-item" data-page="index">
            <i class="fas fa-key"></i>
            MFA 管理
        </a>
        <a href="/settings" class="menu-item" data-page="settings">
            <i class="fas fa-cog"></i>
            同步设置
        </a>
    </nav>

    <div class="sidebar-footer">
        <form action="/perform_logout" method="post" style="margin: 0;">
            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
            <button type="submit" class="logout-btn">
                <i class="fas fa-sign-out-alt"></i>
                退出登录
            </button>
        </form>
    </div>
</aside>

<script>
    // 设置当前活动的菜单项
    function setActiveMenuItem(currentPage) {
        // 移除所有活动状态
        document.querySelectorAll('.menu-item').forEach(item => {
            item.classList.remove('active');
        });

        // 根据当前页面设置活动状态
        const activeItem = document.querySelector(`[data-page="`+ currentPage+`"]`);
        if (activeItem) {
            activeItem.classList.add('active');
        }
    }

    // 移动端侧边栏切换
    function toggleMobileSidebar() {
        const sidebar = document.getElementById('sidebar');
        sidebar.classList.toggle('mobile-open');
    }

    // 点击页面其他地方关闭移动端侧边栏
    document.addEventListener('click', function(e) {
        const sidebar = document.getElementById('sidebar');
        const toggle = document.querySelector('.mobile-menu-toggle');

        if (window.innerWidth <= 768 &&
            !sidebar.contains(e.target) &&
            !toggle.contains(e.target) &&
            sidebar.classList.contains('mobile-open')) {
            sidebar.classList.remove('mobile-open');
        }
    });

    // 响应式处理
    window.addEventListener('resize', function() {
        const sidebar = document.getElementById('sidebar');
        if (window.innerWidth > 768) {
            sidebar.classList.remove('mobile-open');
        }
    });
</script>