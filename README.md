一:说明:

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
    
          wget https://github.com/doubleDimple/mfa-start/releases/download/v-0.0.3/mfa-start-release.jar
      
        3.3.2:下载运行脚本
    
          wget https://github.com/doubleDimple/mfa-start/releases/download/v-0.0.3/mfa-start.sh
      
        3.3.3:下载配置文件模板
    
          wget https://github.com/doubleDimple/mfa-start/releases/download/v-0.0.3/mfa-start.properties

四:配置说明:
 
    server:
      port: 9999(修改为自己的端口号)

    spring:
      security:
        user:
          name: 面板登录用户名,自行指定
          password: 面板登录密码,自行指定


五:启动

  5.1:给oci-start.sh 执行权限添加
    chmod 777 mfa-start.sh

  5.2:启动程序
    ./mfa-start.sh start

  5.3:查看程序启动状态
    ./mfa-start.sh status

  5.4:停止程序
    ./mfa-start.sh stop
