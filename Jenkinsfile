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
                checkout scm
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
                    LATEST_TAG=\$(git describe --tags `git rev-list --tags --max-count=1`)
                    VERSION=\${LATEST_TAG#"v"}

                    MAJOR=\$(echo \$VERSION | cut -d. -f1)
                    MINOR=\$(echo \$VERSION | cut -d. -f2)
                    PATCH=\$(echo \$VERSION | cut -d. -f3)

                    PATCH=\$((PATCH+1))

                    if [ \$PATCH -gt 9 ]; then
                      PATCH=0
                      MINOR=\$((MINOR+1))
                    fi

                    NEW_TAG="v\$MAJOR.\$MINOR.\$PATCH"
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
                gh auth login --with-token <<< ${GITHUB_PSW}
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