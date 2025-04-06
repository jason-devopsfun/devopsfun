pipeline {
    agent {
        kubernetes {
            yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: jnlp
    volumeMounts:
    - name: workspace-volume
      mountPath: /home/jenkins/agent
  - name: gradle
    image: gradle:7.4.2-jdk11
    command:
    - cat
    tty: true
    volumeMounts:
    - name: workspace-volume
      mountPath: /home/gradle/project
  - name: kaniko
    image: gcr.io/kaniko-project/executor:latest
    command:
    - /busybox/cat
    tty: true
    volumeMounts:
    - name: workspace-volume
      mountPath: /workspace
    - name: kaniko-secret
      mountPath: /kaniko/.docker
  volumes:
  - name: workspace-volume
    emptyDir: {}
  - name: kaniko-secret
    secret:
      secretName: regcred
"""
        }
    }

    environment {
        GITHUB_REPO = 'https://github.com/jason-devopsfun/devopsfun.git'
        DOCKER_IMAGE_NAME = 'demo-api'
        DOCKER_CLI_EXPERIMENTAL = 'enabled'
        IMAGE = "jkendall1975/demo-api:\${BUILD_NUMBER}-\${GIT_COMMIT[0..7]}"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Application') {
            steps {
                container('gradle') {
                    sh 'cd devopsfun/demo-api && ./gradlew clean build'
                }
            }
        }

        stage('Build with Kaniko') {
            steps {
                container('kaniko') {
                    sh """
                        /kaniko/executor \
                          --context=\$PWD/devopsfun/demo-api \
                          --dockerfile=\$PWD/devopsfun/demo-api/Dockerfile \
                          --destination=${IMAGE}
                    """
                }
            }
        }
    }
}