#!/bin/bash

# 配置变量
BASE_DIR="/root/mfa-start"
JAR_PATH="$BASE_DIR/mfa-start-release.jar"
CONFIG_FILE="$BASE_DIR/mfa-start.yml"
LOG_FILE="$BASE_DIR/mfa-start.log"
PID_FILE="$BASE_DIR/mfa-start.pid"
PASSWORD_FILE="$BASE_DIR/.mfa-password"

# 下载链接配置
JAR_DOWNLOAD_URL="https://github.com/doubleDimple/mfa-start/releases/latest/download/mfa-start-release.jar"
CONFIG_DOWNLOAD_URL="https://github.com/doubleDimple/mfa-start/releases/latest/download/mfa-start.yml"

# 创建基础目录
create_base_dir() {
    if [ ! -d "$BASE_DIR" ]; then
        mkdir -p "$BASE_DIR"
        echo "Created directory: $BASE_DIR"
    fi
}

# 生成随机密码
generate_password() {
    openssl rand -base64 12 | tr -d "=+/" | cut -c1-12
}

# 下载JAR包
download_jar() {
    echo "Downloading latest JAR package..."
    if command -v wget >/dev/null 2>&1; then
        wget -O "$JAR_PATH.tmp" "$JAR_DOWNLOAD_URL"
    elif command -v curl >/dev/null 2>&1; then
        curl -L -o "$JAR_PATH.tmp" "$JAR_DOWNLOAD_URL"
    else
        echo "Error: Neither wget nor curl is available for downloading"
        return 1
    fi

    if [ $? -eq 0 ] && [ -f "$JAR_PATH.tmp" ]; then
        mv "$JAR_PATH.tmp" "$JAR_PATH"
        echo "JAR package downloaded successfully"
        return 0
    else
        echo "Error: Failed to download JAR package"
        rm -f "$JAR_PATH.tmp"
        return 1
    fi
}

# 下载配置文件模板
download_config_template() {
    echo "Downloading configuration template..."
    if command -v wget >/dev/null 2>&1; then
        wget -O "$CONFIG_FILE.template" "$CONFIG_DOWNLOAD_URL"
    elif command -v curl >/dev/null 2>&1; then
        curl -L -o "$CONFIG_FILE.template" "$CONFIG_DOWNLOAD_URL"
    else
        echo "Error: Neither wget nor curl is available for downloading"
        return 1
    fi

    if [ $? -eq 0 ] && [ -f "$CONFIG_FILE.template" ]; then
        echo "Configuration template downloaded successfully"
        return 0
    else
        echo "Error: Failed to download configuration template"
        rm -f "$CONFIG_FILE.template"
        return 1
    fi
}

# 初始化配置文件（仅首次安装）
init_config() {
    local username="mfa-start-user"
    local password
    local is_first_install=false

    # 检查是否是第一次安装（既没有密码文件也没有配置文件）
    if [ ! -f "$PASSWORD_FILE" ] && [ ! -f "$CONFIG_FILE" ]; then
        is_first_install=true
        password=$(generate_password)
        echo "$password" > "$PASSWORD_FILE"
        chmod 600 "$PASSWORD_FILE"
        echo "========================================="
        echo "FIRST INSTALLATION - CREDENTIALS GENERATED"
        echo "========================================="
        echo "Username: $username"
        echo "Password: $password"
        echo "========================================="
        echo "Please save these credentials!"
        echo "Password also saved to: $PASSWORD_FILE"
        echo "========================================="
    else
        # 如果有密码文件，读取现有密码
        if [ -f "$PASSWORD_FILE" ]; then
            password=$(cat "$PASSWORD_FILE")
            echo "Using existing credentials for user: $username"
        else
            # 如果只有配置文件没有密码文件，从配置文件读取密码
            if [ -f "$CONFIG_FILE" ]; then
                password=$(grep -A4 "security:" "$CONFIG_FILE" | grep "password:" | awk '{print $2}')
                if [ -n "$password" ]; then
                    echo "$password" > "$PASSWORD_FILE"
                    chmod 600 "$PASSWORD_FILE"
                    echo "Extracted existing password from config file"
                else
                    echo "Error: Could not extract password from existing config file"
                    exit 1
                fi
            fi
        fi
    fi

    # 创建或更新配置文件
    if [ -f "$CONFIG_FILE.template" ]; then
        # 使用模板并替换用户名密码
        sed -e "s/{{USERNAME}}/$username/g" -e "s/{{PASSWORD}}/$password/g" "$CONFIG_FILE.template" > "$CONFIG_FILE"
        rm -f "$CONFIG_FILE.template"
    else
        # 创建默认配置文件
        cat > "$CONFIG_FILE" << EOF
server:
  port: 9999

spring:
  security:
    user:
      name: $username
      password: $password

logging:
  level:
    root: INFO
  file:
    name: $LOG_FILE
EOF
    fi

    if [ "$is_first_install" = true ]; then
        echo "Configuration file created with generated credentials: $CONFIG_FILE"
    else
        echo "Configuration file updated: $CONFIG_FILE"
    fi
}

# 更新配置文件（仅更新模板，不修改用户名密码）
update_config() {
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "Configuration file not found, creating new one..."
        init_config
        return
    fi

    # 保存现有的用户名和密码
    local existing_username=$(grep -A3 "security:" "$CONFIG_FILE" | grep "name:" | awk '{print $2}')
    local existing_password=$(grep -A4 "security:" "$CONFIG_FILE" | grep "password:" | awk '{print $2}')

    if [ -z "$existing_username" ] || [ -z "$existing_password" ]; then
        echo "Warning: Could not extract existing credentials, keeping current config unchanged"
        return
    fi

    # 如果有新的配置模板，使用现有用户名密码更新
    if [ -f "$CONFIG_FILE.template" ]; then
        echo "Updating configuration with new template (preserving credentials)..."
        sed -e "s/{{USERNAME}}/$existing_username/g" -e "s/{{PASSWORD}}/$existing_password/g" "$CONFIG_FILE.template" > "$CONFIG_FILE.new"

        # 如果新配置文件创建成功，替换旧的
        if [ -f "$CONFIG_FILE.new" ]; then
            mv "$CONFIG_FILE.new" "$CONFIG_FILE"
            rm -f "$CONFIG_FILE.template"
            echo "Configuration updated with new template (credentials preserved)"
        else
            echo "Failed to create new configuration, keeping existing one"
            rm -f "$CONFIG_FILE.template"
        fi
    else
        echo "No configuration template found, keeping existing configuration"
    fi
}

# 检查文件是否存在，不存在则下载
ensure_files() {
    create_base_dir

    if [ ! -f "$JAR_PATH" ]; then
        echo "JAR file not found, downloading..."
        download_jar || exit 1
    fi

    if [ ! -f "$CONFIG_FILE" ]; then
        echo "Configuration file not found, initializing..."
        download_config_template  # 尝试下载模板，失败也没关系
        init_config
    fi
}

# 启动应用
start() {
    ensure_files

    # 检查应用是否已经在运行
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        if ps -p $PID > /dev/null 2>&1; then
            echo "Application is already running with PID: $PID"
            exit 0
        else
            echo "Stale PID file found, removing..."
            rm -f "$PID_FILE"
        fi
    fi

    # 显示当前配置的用户信息
    if [ -f "$CONFIG_FILE" ]; then
        username=$(grep -A3 "security:" "$CONFIG_FILE" | grep "name:" | awk '{print $2}')
        echo "Starting application with user: $username"
        if [ -f "$PASSWORD_FILE" ]; then
            echo "Password can be found in: $PASSWORD_FILE"
        fi
    fi

    # 启动JAR包
    echo "Starting application..."
    nohup java -jar "$JAR_PATH" --spring.config.additional-location="$CONFIG_FILE" > "$LOG_FILE" 2>&1 &

    # 获取PID并输出
    PID=$!
    echo "Application started with PID: $PID"
    echo "Log file: $LOG_FILE"

    # 保存PID到文件
    echo $PID > "$PID_FILE"

    # 等待一下检查启动是否成功
    sleep 3
    if ps -p $PID > /dev/null 2>&1; then
        echo "Application started successfully!"
    else
        echo "Warning: Application may have failed to start. Check log file: $LOG_FILE"
        rm -f "$PID_FILE"
    fi
}

# 停止应用
stop() {
    if [ ! -f "$PID_FILE" ]; then
        echo "PID file not found. Is the application running?"
        return 1
    fi

    PID=$(cat "$PID_FILE")
    if ps -p $PID > /dev/null 2>&1; then
        echo "Stopping application with PID: $PID"
        kill $PID

        # 等待进程优雅关闭
        local count=0
        while ps -p $PID > /dev/null 2>&1 && [ $count -lt 10 ]; do
            sleep 1
            count=$((count + 1))
        done

        if ps -p $PID > /dev/null 2>&1; then
            echo "Application did not stop gracefully, forcing shutdown..."
            kill -9 $PID
            sleep 1
        fi

        echo "Application stopped."
    else
        echo "No process found with PID: $PID"
    fi

    rm -f "$PID_FILE"
}

# 重启应用
restart() {
    echo "Restarting application..."
    stop
    sleep 2
    start
}

# 更新JAR包和配置
update() {
    echo "Updating application..."

    # 停止应用（如果正在运行）
    local was_running=false
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        if ps -p $PID > /dev/null 2>&1; then
            was_running=true
            echo "Stopping application for update..."
            stop
        fi
    fi

    # 备份当前JAR文件
    if [ -f "$JAR_PATH" ]; then
        cp "$JAR_PATH" "$JAR_PATH.backup.$(date +%Y%m%d_%H%M%S)"
        echo "Current JAR backed up"
    fi

    # 下载新的JAR包
    if download_jar; then
        echo "JAR package updated successfully"

        # 更新配置文件（保持用户名密码）
        download_config_template  # 尝试下载新模板
        update_config

        # 如果之前在运行，则重新启动
        if [ "$was_running" = true ]; then
            echo "Restarting application with updated files..."
            start
        else
            echo "Update completed. Use 'start' to run the updated application."
        fi
    else
        echo "Update failed. Restoring backup if available..."
        # 检查是否有备份文件
        backup_found=false
        for backup_file in "$JAR_PATH.backup."*; do
            if [ -f "$backup_file" ]; then
                backup_found=true
                latest_backup="$backup_file"
                break
            fi
        done

        if [ "$backup_found" = true ]; then
            # 找到最新的备份文件
            for backup_file in "$JAR_PATH.backup."*; do
                if [ -f "$backup_file" ] && [ "$backup_file" -nt "$latest_backup" ]; then
                    latest_backup="$backup_file"
                fi
            done
            cp "$latest_backup" "$JAR_PATH"
            echo "Backup restored: $latest_backup"
        else
            echo "No backup files found"
        fi

        if [ "$was_running" = true ]; then
            echo "Restarting application with original files..."
            start
        fi
        exit 1
    fi
}

# 查看状态
status() {
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        if ps -p $PID > /dev/null 2>&1; then
            echo "Application is running with PID: $PID"
            if [ -f "$CONFIG_FILE" ]; then
                username=$(grep -A3 "security:" "$CONFIG_FILE" | grep "name:" | awk '{print $2}')
                echo "Username: $username"
            fi
            if [ -f "$LOG_FILE" ]; then
                echo "Log file: $LOG_FILE"
            fi
        else
            echo "PID file found but no process is running with PID: $PID"
            echo "Cleaning up stale PID file..."
            rm -f "$PID_FILE"
        fi
    else
        echo "Application is not running."
    fi
}

# 显示密码
show_password() {
    if [ -f "$CONFIG_FILE" ]; then
        username=$(grep -A3 "security:" "$CONFIG_FILE" | grep "name:" | awk '{print $2}')
        password=""

        # 优先从密码文件读取
        if [ -f "$PASSWORD_FILE" ]; then
            password=$(cat "$PASSWORD_FILE")
        else
            # 从配置文件读取
            password=$(grep -A4 "security:" "$CONFIG_FILE" | grep "password:" | awk '{print $2}')
        fi

        if [ -n "$username" ] && [ -n "$password" ]; then
            echo "========================================="
            echo "CURRENT CREDENTIALS"
            echo "========================================="
            echo "Username: $username"
            echo "Password: $password"
            echo "========================================="
            echo "Password file: $PASSWORD_FILE"
            echo "========================================="
        else
            echo "Error: Could not retrieve credentials from configuration"
        fi
    else
        echo "Error: Configuration file not found. Please run 'start' first."
    fi
}

# 修改用户名和密码
change_credentials() {
    local new_username="$1"
    local new_password="$2"

    # 检查参数
    if [ -z "$new_username" ] && [ -z "$new_password" ]; then
        echo "Error: Please provide username and/or password"
        echo "Usage:"
        echo "  $0 passwd <username> <password>     - Change both username and password"
        echo "  $0 passwd <username>                - Change only username"
        echo "  $0 passwd \"\" <password>             - Change only password"
        exit 1
    fi

    # 检查配置文件是否存在
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "Error: Configuration file not found. Please run 'start' first to initialize."
        exit 1
    fi

    # 获取当前凭据
    local current_username=$(grep -A3 "security:" "$CONFIG_FILE" | grep "name:" | awk '{print $2}')
    local current_password=$(grep -A4 "security:" "$CONFIG_FILE" | grep "password:" | awk '{print $2}')

    # 确定新的用户名和密码
    local final_username="${new_username:-$current_username}"
    local final_password="${new_password:-$current_password}"

    # 如果没有提供密码且当前配置中也没有密码，则生成新密码
    if [ -z "$final_password" ]; then
        final_password=$(generate_password)
        echo "No password provided, generated new password: $final_password"
    fi

    echo "Updating credentials..."
    echo "Old username: $current_username"
    echo "New username: $final_username"
    echo "Password: [UPDATED]"

    # 检查应用是否正在运行
    local was_running=false
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        if ps -p $PID > /dev/null 2>&1; then
            was_running=true
            echo "Application is running, will restart after credential update..."
            stop
        fi
    fi

    # 更新配置文件中的用户名和密码
    sed -i "s/name:.*/name: $final_username/" "$CONFIG_FILE"
    sed -i "s/password:.*/password: $final_password/" "$CONFIG_FILE"

    # 更新密码文件
    echo "$final_password" > "$PASSWORD_FILE"
    chmod 600 "$PASSWORD_FILE"

    echo "========================================="
    echo "CREDENTIALS UPDATED SUCCESSFULLY"
    echo "========================================="
    echo "Username: $final_username"
    echo "Password: $final_password"
    echo "========================================="
    echo "Credentials saved to configuration file"
    echo "Password also saved to: $PASSWORD_FILE"
    echo "========================================="

    # 如果之前在运行，重新启动应用
    if [ "$was_running" = true ]; then
        echo "Restarting application with new credentials..."
        start
    else
        echo "Credential update completed. Use 'start' to run the application."
    fi
}

# 查看日志
logs() {
    if [ -f "$LOG_FILE" ]; then
        if [ "$2" = "-f" ]; then
            tail -f "$LOG_FILE"
        else
            tail -n 50 "$LOG_FILE"
        fi
    else
        echo "Log file not found: $LOG_FILE"
    fi
}

# 显示帮助信息
show_help() {
    echo "========================================="
    echo "MFA-START 应用管理脚本 / MFA-START Application Management Script"
    echo "========================================="
    echo ""
    echo "用法 / Usage: $0 {start|stop|restart|update|status|password|logs|help}"
    echo ""
    echo "命令说明 / Commands:"
    echo "  start                              - 启动应用 (如需要会自动下载) / Start the application (auto-download if needed)"
    echo "  stop                               - 停止应用 / Stop the application"
    echo "  restart                            - 重启应用 / Restart the application"
    echo "  update                             - 更新JAR包并重启 (如果正在运行) / Update JAR package and restart if running"
    echo "  status                             - 显示应用状态 / Show application status"
    echo "  password                           - 显示当前用户名和密码 / Show current username and password"
    echo "  password <username> <password>     - 修改用户名和密码 / Change both username and password"
    echo "  password <username>                - 仅修改用户名 (保持当前密码) / Change only username (keep current password)"
    echo "  password \"\" <password>             - 仅修改密码 (保持当前用户名) / Change only password (keep current username)"
    echo "  logs [-f]                          - 显示最近日志 (使用-f实时跟踪) / Show recent logs (use -f to follow)"
    echo "  help                               - 显示此帮助信息 / Show this help message"
    echo ""
    echo "使用示例 / Examples:"
    echo "  $0 start                           - 启动应用 / Start application"
    echo "  $0 password                        - 查看凭据 / View credentials"
    echo "  $0 password admin newpass123       - 设置用户名为'admin'，密码为'newpass123' / Set username to 'admin' and password to 'newpass123'"
    echo "  $0 password newuser                - 将用户名改为'newuser'，保持当前密码 / Change username to 'newuser', keep current password"
    echo "  $0 password \"\" secretpass          - 保持当前用户名，密码改为'secretpass' / Keep current username, change password to 'secretpass'"
    echo "  $0 logs -f                         - 实时查看日志 / View logs in real-time"
    echo "  $0 update                          - 更新到最新版本 / Update to latest version"
    echo ""
    echo "首次运行特性 / First Run Features:"
    echo "  - 创建用户 'mfa-start-user' 并生成随机密码 / Create user 'mfa-start-user' with random password"
    echo "  - 自动下载最新的JAR包和配置文件 / Auto-download latest JAR and config files"
    echo "  - 显示生成的登录凭据 / Display generated login credentials"
    echo ""
    echo "文件位置 / File Locations:"
    echo "  JAR文件 / JAR File:        $JAR_PATH"
    echo "  配置文件 / Config File:    $CONFIG_FILE"
    echo "  日志文件 / Log File:       $LOG_FILE"
    echo "  密码文件 / Password File:  $PASSWORD_FILE"
    echo "  PID文件 / PID File:        $PID_FILE"
    echo ""
    echo "注意事项 / Notes:"
    echo "  - 修改凭据时会自动重启应用 (如果正在运行) / Credential changes will restart the app (if running)"
    echo "  - 更新功能会保持现有用户名和密码不变 / Update function preserves existing username and password"
    echo "  - 所有操作都有中文提示和详细日志 / All operations have Chinese prompts and detailed logs"
    echo "========================================="
}

# 主命令处理
case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    restart)
        restart
        ;;
    update)
        update
        ;;
    status)
        status
        ;;
    password|passwd)
        if [ -n "$2" ]; then
            # 修改凭据模式
            change_credentials "$2" "$3"
        else
            # 显示凭据模式
            show_password
        fi
        ;;
    logs)
        logs "$@"
        ;;
    help)
        show_help
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|update|status|password|logs|help}"
        echo ""
        echo "Commands:"
        echo "  start                              - Start the application (auto-download if needed)"
        echo "  stop                               - Stop the application"
        echo "  restart                            - Restart the application"
        echo "  update                             - Update JAR package and restart if running"
        echo "  status                             - Show application status"
        echo "  password                           - Show current username and password"
        echo "  password <username> <password>     - Change both username and password"
        echo "  password <username>                - Change only username (keep current password)"
        echo "  password \"\" <password>             - Change only password (keep current username)"
        echo "  logs [-f]                          - Show recent logs (use -f to follow)"
        echo "  help                               - Show this help message"
        echo ""
        echo "Examples:"
        echo "  $0 password admin newpass123       - Set username to 'admin' and password to 'newpass123'"
        echo "  $0 password newuser                - Change username to 'newuser', keep current password"
        echo "  $0 password \"\" secretpass          - Keep current username, change password to 'secretpass'"
        echo ""
        echo "First run will:"
        echo "  - Create user 'mfa-start-user' with random password"
        echo "  - Download latest JAR and config files"
        echo "  - Display generated credentials"
        echo ""
        echo "For more information, use: $0 help"
        exit 1
        ;;
esac

exit 0