一:说明:

    1.1主要功能:提供mfa的秘钥的验证,存储,导出等功能
  
    1.2此程序免费开源,仅可用于测试和学习,不可用于其他所有商业或者非法用途.

二:环境说明: 需要提前安装jdk8+版本

三:部署说明:

      3.1:登录linux服务器,切换到root用户下.
  
      3.2:创建文件夹 mkdir -p mfa-start && cd mfa-start
  
      3.3:下载部署包文件
  
        3.3.1:下载jar包
    
          wget https://github.com/doubleDimple/oci-start/releases/download/v-1.0.0/oci-start-release.jar
      
        3.3.2:下载运行脚本
    
          wget https://github.com/doubleDimple/oci-start/releases/download/v-1.0.0/oci-start.sh
      
        3.3.3:下载配置文件模板
    
          wget https://github.com/doubleDimple/oci-start/releases/download/v-1.0.0/oci-start.properties

四:配置说明:oci-start.properties文件里面的配置需要自行去修改,如果需要配置多个api进行通时创建实例,直接将  ###oracle抢机配置下的内容复制一份,将里面的user1全部修改为user2即可
  以此类推,配置多个api
 
  ###基本配置

    #端口号 自行指定
    server.port=9087

    #页面登录用户名 自行指定
    spring.security.user.name=页面登录用户名

    #页面登录密码 自行指定
    spring.security.user.password=页面登录密码

    #不需要修改
    spring.freemarker.template-loader-path=classpath:/templates/

    #不需要修改
    spring.freemarker.content-type=text/html

    #不需要修改
    spring.freemarker.cache=false

    #不需要修改
    spring.freemarker.charset=UTF-8

    #不需要修改
    spring.freemarker.check-template-location=true

    #不需要修改
    spring.freemarker.expose-request-attributes=false

    #不需要修改
    spring.freemarker.expose-session-attributes=false

    #不需要修改
    spring.freemarker.request-context-attribute=req

    #不需要修改
    spring.freemarker.suffix=.ftl

    #不需要修改
    spring.datasource.url=jdbc:h2:file:./mfa-start/otp_keys_db

    #不需要修改
    spring.datasource.driverClassName=org.h2.Driver

    #数据库用户名 自行指定
    spring.datasource.username=sa

    #数据库密码 自行指定
    spring.datasource.password=password

    #不需要修改
    spring.jpa.hibernate.ddl-auto=update

    #不需要修改
    spring.jpa.database-platform=org.hibernate.dialect.H2Dialect

    #不需要修改
    spring.h2.console.enabled=true


五:启动

  5.1:给oci-start.sh 执行权限添加
    chmod 777 oci-start.sh

  5.2:启动程序
    ./oci-start.sh start

  5.3:查看程序启动状态
    ./oci-start.sh status

  5.4:停止程序
    ./oci-start.sh stop
