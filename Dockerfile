# 使用官方的 OpenJDK 运行时镜像作为基础镜像
FROM openjdk:17-jdk-slim

# 设置环境变量
ENV APP_HOME=/mfa-start

# 在容器中创建一个目录来存放应用
WORKDIR $APP_HOME

# 复制 jar 包到容器并命名为 mfa-start.jar
COPY target/mfa-start-release.jar mfa-start.jar

# 暴露应用运行端口
EXPOSE 9999

# 启动 Spring Boot 应用
ENTRYPOINT ["java", "-Xms256m", "-Xmx512m", "-jar", "mfa-start.jar"]
