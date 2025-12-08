pipeline {
    agent any

    tools {
            jdk 'JDK8'
            maven 'maven'
        }

    environment {
        APP_NAME = "mfa-start"
        IMAGE = "lovele/mfa-start"
        GITHUB_REPO = "doubleDimple/mfa-start"

        DOCKERHUB = credentials('dockerhub-token')
        GITHUB = credentials('github-token')
    }

    stages {

        stage('Checkout') {
            steps {
                deleteDir()
                git branch: 'master',
                    url: 'https://github.com/doubleDimple/mfa-start.git',
                    credentialsId: 'github-token'
            }
        }

        stage('Build Project') {
            steps {
                withMaven(maven: 'maven') {
                    sh "mvn clean package -DskipTests"
                }
            }
        }

        stage('Generate Version') {
            steps {
                script {
                    sh """
                    # 获取最新 tag，没有则从 2.2.2 开始
                    LATEST_TAG=\$(git describe --tags --abbrev=0 2>/dev/null || echo "2.2.2")

                    echo "Latest tag: \$LATEST_TAG"

                    # 去掉开头的 v 和 -
                    CLEAN_TAG=\$(echo \$LATEST_TAG | sed 's/^v//; s/^-//')

                    echo "Clean tag: \$CLEAN_TAG"

                    # 拆解为主次补丁
                    MAJOR=\$(echo \$CLEAN_TAG | cut -d. -f1)
                    MINOR=\$(echo \$CLEAN_TAG | cut -d. -f2)
                    PATCH=\$(echo \$CLEAN_TAG | cut -d. -f3)

                    # 自增补丁
                    PATCH=\$((PATCH+1))

                    # 到 9 自动进位
                    if [ \$PATCH -gt 9 ]; then
                      PATCH=0
                      MINOR=\$((MINOR+1))
                    fi

                    NEW_TAG="\$MAJOR.\$MINOR.\$PATCH"

                    echo "\$NEW_TAG" > new_version.txt
                    """

                    env.VERSION = sh(script: "cat new_version.txt", returnStdout: true).trim()
                    echo "🔢 New version: ${env.VERSION}"
                }
            }
        }

        stage('GitHub Release') {
            steps {
                sh """
                echo "${GITHUB_PSW}" | gh auth login --with-token
                gh release create ${VERSION} target/${APP_NAME}-release.jar \
                  --repo ${GITHUB_REPO} \
                  --title "Release ${VERSION}" \
                  --notes "Auto release by Jenkins"
                """
            }
        }

        stage('Build Docker Image') {
            steps {
                sh """
                docker build -t ${IMAGE}:${VERSION} .
                docker tag ${IMAGE}:${VERSION} ${IMAGE}:latest
                """
            }
        }

        stage('Push DockerHub') {
            steps {
                sh """
                echo ${DOCKERHUB_PSW} | docker login -u ${DOCKERHUB_USR} --password-stdin
                docker push ${IMAGE}:${VERSION}
                docker push ${IMAGE}:latest
                """
            }
        }

        stage('Deploy to K8s') {
            steps {
                withKubeConfig([credentialsId: 'k8s-token']) {
                    sh """
                    kubectl apply -f deploy.yaml
                    kubectl apply -f service.yaml
                    kubectl set image deployment/${APP_NAME} ${APP_NAME}=${IMAGE}:${VERSION}
                    kubectl rollout status deployment/${APP_NAME}
                    """
                }
            }
        }
    }
}