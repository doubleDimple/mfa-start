#!/bin/bash

# 配置变量
BASE_DIR="/root/mfa-start"
JAR_PATH="$BASE_DIR/mfa-start-release.jar"
CONFIG_FILE="$BASE_DIR/mfa-start.yml"
PASSWORD_FILE="$BASE_DIR/.mfa-password"

# 下载链接配置
JAR_DOWNLOAD_URL="https://github.com/doubleDimple/mfa-start/releases/latest/download/mfa-start-release.jar"
CONFIG_DOWNLOAD_URL="https://raw.githubusercontent.com/doubleDimple/shell-tools/master/mfa-start.yml"

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
            username=$(grep -A3 "security:" "$CONFIG_FILE" | grep "name:" | awk '{print $2}')
            if [ -z "$username" ]; then
                username="mfa-start-user"
            fi
            echo "Using existing credentials for user: $username"
        else
            # 如果只有配置文件没有密码文件，从配置文件读取密码
            if [ -f "$CONFIG_FILE" ]; then
                username=$(grep -A3 "security:" "$CONFIG_FILE" | grep "name:" | awk '{print $2}')
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
        # 读取模板内容并替换占位符
        cp "$CONFIG_FILE.template" "$CONFIG_FILE.tmp"

        # 替换用户名和密码占位符
        sed -i "s/{{USERNAME}}/$username/g" "$CONFIG_FILE.tmp"
        sed -i "s/{{PASSWORD}}/$password/g" "$CONFIG_FILE.tmp"

        # 如果模板中没有占位符，直接修改name和password字段
        sed -i "s/name:.*/name: $username/g" "$CONFIG_FILE.tmp"
        sed -i "s/password:.*/password: $password/g" "$CONFIG_FILE.tmp"

        mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
        rm -f "$CONFIG_FILE.template"
        echo "Configuration file created from template with credentials"
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

        # 创建临时文件
        cp "$CONFIG_FILE.template" "$CONFIG_FILE.tmp"

        # 替换占位符或直接修改字段
        sed -i "s/{{USERNAME}}/$existing_username/g" "$CONFIG_FILE.tmp"
        sed -i "s/{{PASSWORD}}/$existing_password/g" "$CONFIG_FILE.tmp"
        sed -i "s/name:.*/name: $existing_username/g" "$CONFIG_FILE.tmp"
        sed -i "s/password:.*/password: $existing_password/g" "$CONFIG_FILE.tmp"

        # 替换配置文件
        if [ -f "$CONFIG_FILE.tmp" ]; then
            mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
            rm -f "$CONFIG_FILE.template"
            echo "Configuration updated with new template (credentials preserved)"

            # 更新密码文件
            echo "$existing_password" > "$PASSWORD_FILE"
            chmod 600 "$PASSWORD_FILE"
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

    # 先确保JAR文件存在
    if [ ! -f "$JAR_PATH" ]; then
        echo "JAR file not found, downloading..."
        download_jar || exit 1
    fi

    # 再检查配置文件
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "Configuration file not found, initializing..."
        # 尝试下载配置模板
        download_config_template
        # 初始化配置（会生成用户名密码并写入配置文件）
        init_config
    else
        # 如果配置文件存在但密码文件不存在，从配置文件提取密码
        if [ ! -f "$PASSWORD_FILE" ]; then
            password=$(grep -A4 "security:" "$CONFIG_FILE" | grep "password:" | awk '{print $2}')
            if [ -n "$password" ]; then
                echo "$password" > "$PASSWORD_FILE"
                chmod 600 "$PASSWORD_FILE"
                echo "Password file created from existing config"
            fi
        fi
    fi
}

# 检查应用是否正在运行
is_running() {
    pgrep -f "$JAR_PATH" > /dev/null 2>&1
    return $?
}

# 获取进程PID
get_pid() {
    pgrep -f "$JAR_PATH" 2>/dev/null
}

# 启动应用
start() {
    ensure_files

    # 检查应用是否已经在运行
    if is_running; then
        echo "Application is already running with PID: $(get_pid)"
        exit 0
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
    nohup java -jar "$JAR_PATH" --spring.config.additional-location="$CONFIG_FILE" > /dev/null 2>&1 &

    # 等待一下检查启动是否成功
    sleep 3
    if is_running; then
        echo "Application started successfully! PID: $(get_pid)"
    else
        echo "Warning: Application may have failed to start."
    fi
}

# 停止应用
stop() {
    if ! is_running; then
        echo "Application is not running."
        return 1
    fi

    local PID=$(get_pid)
    echo "Stopping application with PID: $PID"
    kill $PID

    # 等待进程优雅关闭
    local count=0
    while is_running && [ $count -lt 10 ]; do
        sleep 1
        count=$((count + 1))
    done

    if is_running; then
        echo "Application did not stop gracefully, forcing shutdown..."
        kill -9 $PID
        sleep 1
    fi

    echo "Application stopped."
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
    if is_running; then
        was_running=true
        echo "Stopping application for update..."
        stop
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

        # 清理备份文件（更新成功后）
        rm -f "$JAR_PATH.backup."*
        echo "Backup files cleaned up after successful update"

        # 如果之前在运行，则重新启动
        if [ "$was_running" = true ]; then
            echo "Restarting application with updated files..."
            start
        else
            echo "Update completed. Use 'start' to run the updated application."
        fi
    else
        echo "Update failed. Restoring backup if available..."
        # 恢复备份
        for backup_file in "$JAR_PATH.backup."*; do
            if [ -f "$backup_file" ]; then
                cp "$backup_file" "$JAR_PATH"
                echo "Backup restored: $backup_file"
                break
            fi
        done

        if [ "$was_running" = true ]; then
            echo "Restarting application with original files..."
            start
        fi
        exit 1
    fi
}

# 查看状态
status() {
    if is_running; then
        local PID=$(get_pid)
        echo "Application is running with PID: $PID"
        if [ -f "$CONFIG_FILE" ]; then
            username=$(grep -A3 "security:" "$CONFIG_FILE" | grep "name:" | awk '{print $2}')
            echo "Username: $username"
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

    # 调试信息
    echo "Debug: Current username from config: '$current_username'"
    echo "Debug: New username parameter: '$new_username'"
    echo "Debug: New password parameter: '$new_password'"

    # 确定新的用户名和密码
    local final_username
    local final_password

    # 处理用户名
    if [ "$new_username" = "" ]; then
        # 空字符串表示保持当前用户名
        final_username="$current_username"
        echo "Keeping current username: $final_username"
    elif [ -z "$new_username" ]; then
        # 真正的空值（没有提供参数）
        final_username="$current_username"
    else
        # 提供了新用户名
        final_username="$new_username"
    fi

    # 处理密码
    if [ -z "$new_password" ]; then
        # 没有提供密码参数，保持当前密码
        final_password="$current_password"
        echo "Keeping current password"
    else
        # 提供了新密码
        final_password="$new_password"
        echo "Setting new password"
    fi

    # 如果最终密码仍为空，生成新密码
    if [ -z "$final_password" ]; then
        final_password=$(generate_password)
        echo "No password found, generated new password: $final_password"
    fi

    echo ""
    echo "Updating credentials..."
    echo "Old username: $current_username"
    echo "New username: $final_username"
    echo "Password will be updated"

    # 检查应用是否正在运行
    local was_running=false
    if is_running; then
        was_running=true
        echo "Application is running, will restart after credential update..."
        stop
    fi

    # 创建临时配置文件
    cp "$CONFIG_FILE" "$CONFIG_FILE.bak"

    # 使用更精确的sed命令更新配置文件
    # 先找到security部分，然后更新name和password
    awk -v user="$final_username" -v pass="$final_password" '
        /^spring:/ { spring=1 }
        /^  security:/ && spring { security=1 }
        /^    user:/ && security { user_section=1 }
        /^      name:/ && user_section {
            print "      name: " user
            next
        }
        /^      password:/ && user_section {
            print "      password: " pass
            next
        }
        { print }
    ' "$CONFIG_FILE.bak" > "$CONFIG_FILE"

    # 验证更新是否成功
    local new_config_username=$(grep -A3 "security:" "$CONFIG_FILE" | grep "name:" | awk '{print $2}')
    local new_config_password=$(grep -A4 "security:" "$CONFIG_FILE" | grep "password:" | awk '{print $2}')

    if [ "$new_config_username" = "$final_username" ] && [ "$new_config_password" = "$final_password" ]; then
        echo "Configuration file updated successfully"
        rm -f "$CONFIG_FILE.bak"

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
    else
        echo "Error: Failed to update configuration file"
        mv "$CONFIG_FILE.bak" "$CONFIG_FILE"
        exit 1
    fi

    # 如果之前在运行，重新启动应用
    if [ "$was_running" = true ]; then
        echo "Restarting application with new credentials..."
        start
    else
        echo "Credential update completed. Use 'start' to run the application."
    fi
}

# 显示帮助信息
show_help() {
    echo "Usage: $0 {start|stop|restart|update|status|password|help}"
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
    echo "  help                               - Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 start                           - Start application"
    echo "  $0 password                        - View credentials"
    echo "  $0 password admin newpass123       - Set username to 'admin' and password to 'newpass123'"
    echo "  $0 password newuser                - Change username to 'newuser', keep current password"
    echo "  $0 password \"\" secretpass          - Keep current username, change password to 'secretpass'"
    echo "  $0 update                          - Update to latest version"
    echo ""
    echo "First Run Features:"
    echo "  - Create user 'mfa-start-user' with random password"
    echo "  - Auto-download latest JAR and config files"
    echo "  - Display generated login credentials"
    echo ""
    echo "File Locations:"
    echo "  JAR File:        $JAR_PATH"
    echo "  Config File:     $CONFIG_FILE"
    echo "  Password File:   $PASSWORD_FILE"
    echo ""
    echo "Notes:"
    echo "  - Credential changes will restart the app (if running)"
    echo "  - Update function preserves existing username and password"
    echo "  - Backup files are automatically cleaned up after successful updates"
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
    help)
        show_help
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|update|status|password|help}"
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
        echo "  help                               - Show this help message"
        echo ""
        echo "For more information, use: $0 help"
        exit 1
        ;;
esac

exit 0