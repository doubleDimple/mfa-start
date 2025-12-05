pipeline {
    agent any

    environment {
        DOCKERHUB = credentials('dockerhub-token')
        IMAGE = "lovele/mfa-start"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Version Bump') {
            steps {
                script {
                    // 读取当前版本号
                    def version = readFile('version.txt').trim()
                    echo "Current version: ${version}"

                    // 拆分
                    def parts = version.tokenize('.')
                    def major = parts[0].toInteger()
                    def minor = parts[1].toInteger()
                    def patch = parts[2].toInteger()

                    // patch递增
                    patch++

                    //进位规则 patch > 9 => 0, minor + 1
                    if (patch > 9) {
                        patch = 0
                        minor++
                    }

                    //进位规则 minor > 9 => 0, major + 1
                    if (minor > 9) {
                        minor = 0
                        major++
                    }

                    // 拼回新版本
                    def newVersion = "${major}.${minor}.${patch}"
                    echo "New version: ${newVersion}"

                    // 写回文件
                    writeFile file: 'version.txt', text: newVersion

                    // 设置为环境变量用于 Docker tag
                    env.TAG = newVersion

                    // 提交回仓库（不报错）
                    sh """
                        git config --global user.email "jenkins@local"
                        git config --global user.name "Jenkins"
                        git add version.txt
                        git commit -m "Version bump to ${newVersion}" || true
                        git push origin HEAD || true
                    """
                }
            }
        }

        stage('Build Maven') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Build Docker Images') {
            steps {
                sh """
                    docker build -t $IMAGE:$TAG .
                    docker build -t $IMAGE:latest .
                """
            }
        }

        stage('Login DockerHub') {
            steps {
                sh """
                    echo $DOCKERHUB_PSW | docker login -u $DOCKERHUB_USR --password-stdin
                """
            }
        }

        stage('Push Docker Images') {
            steps {
                sh """
                    docker push $IMAGE:$TAG
                    docker push $IMAGE:latest
                """
            }
        }
    }

    post {
        success {
            echo "Build success. Published version: ${env.TAG}"
        }
        failure {
            echo "Build failed!"
        }
    }
}
