# MFA-START

一个用于管理和验证 MFA（多因素认证）密钥的开源工具

## 📌 重要说明

> **⚠️ 注意：** 密码和数据都存储在部署服务器上的 H2 数据库中，您可以随时关闭服务。如果介意数据存储位置，请勿使用本工具，谢谢。

### 主要功能
- ✅ MFA 密钥验证
- ✅ 密钥存储管理
- ✅ 密钥导出功能
- ✅ Web 界面管理

### 使用说明
此程序**完全免费开源**，仅可用于**测试和学习**目的，**禁止用于任何商业或非法用途**。

## ⚖️ 免责声明

> **请仔细阅读以下免责条款：**

1. 本仓库发布的项目中涉及的任何脚本，仅用于测试和学习研究，禁止用于商业用途，不能保证其合法性、准确性、完整性和有效性，请根据情况自行判断。

2. 所有使用者在使用项目的任何部分时，需先遵守法律法规。对于一切使用不当所造成的后果，需自行承担。对任何脚本问题概不负责，包括但不限于由任何脚本错误导致的任何损失或损害。

3. 如果任何单位或个人认为该项目可能涉嫌侵犯其权利，则应及时通知并提供身份证明、所有权证明，我们将在收到认证文件后删除相关文件。

4. 任何以任何方式查看此项目的人或直接或间接使用该项目的任何脚本的使用者都应仔细阅读此声明。本人保留随时更改或补充此免责声明的权利。一旦使用并复制了任何相关脚本或本项目的规则，则视为您已接受此免责声明。

5. **您必须在下载后的 24 小时内从计算机或手机中完全删除以上内容。**

6. 您使用或者复制了本仓库且本人制作的任何脚本，则视为已接受此声明，请仔细阅读。

## 🔧 环境要求

- **操作系统**：Linux (推荐 CentOS/Ubuntu)
- **Java 版本**：JDK 8+ 
- **用户权限**：需要 root 权限
- **网络要求**：能够访问 GitHub 下载资源

## 📦 部署步骤

### 1. 登录服务器
```bash
# 切换到 root 用户
sudo su - root
```

### 2. 创建目录
```bash
# 创建应用目录并进入
mkdir -p /root/mfa-start && cd /root/mfa-start
```

### 3. 下载部署脚本
```bash
# 下载管理脚本并赋予执行权限
wget -O mfa-start.sh https://raw.githubusercontent.com/doubleDimple/shell-tools/master/mfa-start.sh && chmod +x mfa-start.sh
```

## 🚀 使用指南

### 基本命令

#### 1️⃣ 启动应用
```bash
./mfa-start.sh start
```
> 首次启动会自动下载所需文件并生成登录凭据

#### 2️⃣ 停止应用
```bash
./mfa-start.sh stop
```

#### 3️⃣ 重启应用
```bash
./mfa-start.sh restart
```

#### 4️⃣ 查看状态
```bash
./mfa-start.sh status
```

#### 5️⃣ 更新应用
```bash
./mfa-start.sh update
```
> 更新到最新版本，保留现有配置和凭据

#### 7️⃣ 修改凭据

**同时修改用户名和密码：**
```bash
./mfa-start.sh password admin mypassword123
```

**只修改用户名（保持原密码）：**
```bash
./mfa-start.sh password newadmin
```

**只修改密码（保持原用户名）：**
```bash
./mfa-start.sh password "" newpassword456
```

## 📋 快速开始示例

```bash
# 1. 创建目录
mkdir -p /root/mfa-start && cd /root/mfa-start

# 2. 下载脚本
wget -O mfa-start.sh https://raw.githubusercontent.com/doubleDimple/shell-tools/master/mfa-start.sh
chmod +x mfa-start.sh

# 3. 启动应用（首次会自动生成凭据）
./mfa-start.sh start

# 4. 查看生成的凭据
./mfa-start.sh password

# 5. 访问 Web 界面
# 浏览器访问: http://服务器IP:9999
# 使用上面显示的用户名和密码登录
```

## 📁 文件结构

```
/root/mfa-start/
├── mfa-start.sh                 # 管理脚本
├── mfa-start-release.jar        # 主程序
├── mfa-start.yml                # 配置文件
├── .mfa-password                # 密码文件（自动生成）
└── data/                        # 数据目录
    └── mfa.mv.db               # H2 数据库文件
```

## 🔐 安全建议

1. **修改默认密码**：首次启动后请立即修改默认生成的密码
2. **限制访问**：建议配置防火墙，仅允许可信 IP 访问 9999 端口
3. **定期备份**：重要数据请定期备份 `data` 目录
4. **HTTPS 访问**：生产环境建议配置反向代理启用 HTTPS

## ❓ 常见问题

### Q: 忘记密码怎么办？
A: 可以通过 `./mfa-start.sh password` 查看当前密码，或使用 `./mfa-start.sh password "" 新密码` 重置密码。

### Q: 如何修改默认端口？
A: 编辑 `mfa-start.yml` 文件，修改 `server.port` 配置项，然后重启应用。

### Q: 数据存储在哪里？
A: 所有数据存储在 `data` 目录下的 H2 数据库文件中。

### Q: 如何完全卸载？
A: 停止服务后，删除整个 `/root/mfa-start` 目录即可。

## 📝 许可证

本项目采用开源许可，仅供学习和测试使用，禁止商业用途。

## 📞 联系方式

如有问题，请在 GitHub 上提交 Issue。
