# 使用官方的 OpenJDK 运行时镜像作为基础镜像
FROM openjdk:17-jdk-slim

# 设置环境变量
ENV APP_HOME=/mfa-start

# 在容器中创建一个目录来存放应用
WORKDIR $APP_HOME

# 将生成的 JAR 文件复制到容器中
COPY target/mfa-start-release.jar.jar mfa-start-release.jar

# 暴露应用运行的端口
EXPOSE 23456

# 启动 Spring Boot 应用
ENTRYPOINT ["java", "-jar", "app.jar"]
