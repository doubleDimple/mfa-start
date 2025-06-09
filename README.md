一:说明:

密码和数据都在你部署的服务器上的h2数据库里，你可以随时关闭服务。

介意请千万勿使用，谢谢。

以下为 【免责条款】

本仓库发布的项目中涉及的任何脚本，仅用于测试和学习研究，禁止用于商业用途，不能保证其合法性，准确性，完整性和有效性，请根据情况自行判断.

所有使用者在使用项目的任何部分时，需先遵守法律法规。对于一切使用不当所造成的后果，需自行承担。对任何脚本问题概不负责，包括但不限于由任何脚本错误导致的任何损失或损害.

如果任何单位或个人认为该项目可能涉嫌侵犯其权利，则应及时通知并提供身份证明，所有权证明，我们将在收到认证文件后删除相关文件.

任何以任何方式查看此项目的人或直接或间接使用该项目的任何脚本的使用者都应仔细阅读此声明。本人保留随时更改或补充此免责声明的权利。一旦使用并复制了任何相关脚本或本项目的规则，则视为您已接受此免责声明.

您必须在下载后的24小时内从计算机或手机中完全删除以上内容.

您使用或者复制了本仓库且本人制作的任何脚本，则视为已接受此声明，请仔细阅读

    1.1主要功能:提供mfa的秘钥的验证,存储,导出等功能
  
    1.2此程序免费开源,仅可用于测试和学习,不可用于其他所有商业或者非法用途.

二:环境说明: 需要提前安装jdk8+版本

三:部署说明:

      3.1:登录linux服务器,切换到root用户下.
  
      3.2:创建文件夹 
      
      mkdir -p mfa-start && cd mfa-start
      
      mkdir -p data
  
      3.3:下载部署包文件
  
        3.3.1:下载jar包
    
          wget https://github.com/doubleDimple/mfa-start/releases/download/v-0.0.4/mfa-start-release.jar
      
        3.3.2:下载运行脚本
    
          wget https://github.com/doubleDimple/mfa-start/releases/download/v-0.0.3/mfa-start.sh
      
        3.3.3:下载配置文件模板
    
          wget https://github.com/doubleDimple/mfa-start/releases/download/v-0.0.3/mfa-start.yml

四:配置说明:
 
    server:
      port: 9999(修改为自己的端口号)

    spring:
      security:
        user:
          name: 面板登录用户名,自行指定
          password: 面板登录密码,自行指定


五:启动

  5.1:给mfa-start.sh 执行权限添加
    chmod 777 mfa-start.sh

  5.2:启动程序
    ./mfa-start.sh start

  5.3:查看程序启动状态
    ./mfa-start.sh status

  5.4:停止程序
    ./mfa-start.sh stop
