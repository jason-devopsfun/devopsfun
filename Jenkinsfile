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
    env:
    - name: DOCKER_CONFIG
      value: /kaniko/.docker
    volumeMounts:
    - name: workspace-volume
      mountPath: /workspace
    - name: workspace-volume
      mountPath: /home/jenkins/agent
      readOnly: false
    - name: docker-config
      mountPath: /kaniko/.docker
  volumes:
  - name: workspace-volume
    emptyDir: {}
  - name: docker-config
    emptyDir: {}
"""
        }
    }

    environment {
        GITHUB_REPO = 'https://github.com/jason-devopsfun/devopsfun.git'
        DOCKER_IMAGE_NAME = 'demo-api'
        DOCKER_CLI_EXPERIMENTAL = 'enabled'
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials')
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

        stage('Prepare Build Info') {
            steps {
                script {
                    env.SHORT_COMMIT = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                    env.IMAGE_TAG = "${BUILD_NUMBER}-${env.SHORT_COMMIT}"
                    env.FULL_IMAGE_NAME = "jkendall1975/demo-api:${env.IMAGE_TAG}"
                }
            }
        }

        stage('Build and Push with Kaniko') {
            steps {
                container('kaniko') {
                    // Create Docker config file inside the Kaniko container with proper JSON format
                    sh '''
                        echo "Docker Hub Username: $DOCKERHUB_CREDENTIALS_USR"
                        echo "Docker Hub Password: $DOCKERHUB_CREDENTIALS_PSW"
                        echo '{"auths":{"https://index.docker.io/v2/":{"auth":"'$(echo -n ${DOCKERHUB_CREDENTIALS_USR}:${DOCKERHUB_CREDENTIALS_PSW} | base64)'"}}}' > /kaniko/.docker/config.json
                        cat /kaniko/.docker/config.json
                  
                        echo "FULL IMAGE NAME: $FULL_IMAGE_NAME"
                        /kaniko/executor \
                          --context=/home/jenkins/agent/workspace/demo-api-pipeline/demo-api \
                          --dockerfile=/home/jenkins/agent/workspace/demo-api-pipeline/demo-api/Dockerfile \
                          --destination=${FULL_IMAGE_NAME}
                    """
                }
            }
        }
    }
}