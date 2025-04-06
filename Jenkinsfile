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
    image: gradle:8.6.0-jdk17
    command:
    - cat
    tty: true
    volumeMounts:
    - name: workspace-volume
      mountPath: /home/gradle/project
    - name: workspace-volume
      mountPath: /home/jenkins/agent
      readOnly: false
  - name: kaniko
    image: gcr.io/kaniko-project/executor:debug
    command:
    - /busybox/sh
    args:
    - -c
    - while true; do sleep 30; done
    volumeMounts:
    - name: workspace-volume
      mountPath: /workspace
    - name: kaniko-secret
      mountPath: /kaniko/.docker
    - name: workspace-volume
      mountPath: /home/jenkins/agent
      readOnly: false
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
                    sh 'cd demo-api && ./gradlew clean build'
                }
            }
        }

        stage('Build with Kaniko') {
            steps {
                container('kaniko') {
                    script {
                        // Get short commit hash
                        def shortCommit = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                        def imageTag = "${BUILD_NUMBER}-${shortCommit}"
                        def fullImageName = "jkendall1975/demo-api:${imageTag}"
                        
                        sh """
                            /kaniko/executor \
                              --context=/home/jenkins/agent/workspace/demo-api-pipeline/demo-api \
                              --dockerfile=/home/jenkins/agent/workspace/demo-api-pipeline/demo-api/Dockerfile \
                              --destination=${fullImageName}
                        """
                    }
                }
            }
        }
    }
}