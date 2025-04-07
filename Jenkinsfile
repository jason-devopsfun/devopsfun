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
  volumes:
  - name: workspace-volume
    emptyDir: {}
"""
        }
    }

    environment {
        GITHUB_REPO = 'https://github.com/jason-devopsfun/devopsfun.git'
        DOCKER_IMAGE_NAME = 'demo-api'
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

        stage('Build and Push Image') {
            steps {
                container('kaniko') {
                    // Create a correctly formatted Docker config
                    sh '''
                        mkdir -p /kaniko/.docker
                        
                        echo '{
                          "auths": {
                            "https://index.docker.io/v1/": {
                              "auth": "'$(echo -n ${DOCKERHUB_CREDENTIALS_USR}:${DOCKERHUB_CREDENTIALS_PSW} | base64)'"
                            }
                          }
                        }' > /kaniko/.docker/config.json
                        
                        # Ensure right permissions
                        chmod 600 /kaniko/.docker/config.json
                    '''
                    
                    // Build and push
                    sh """
                        /kaniko/executor \
                          --context=/home/jenkins/agent/workspace/demo-api-pipeline/demo-api \
                          --dockerfile=/home/jenkins/agent/workspace/demo-api-pipeline/demo-api/Dockerfile \
                          --destination=${FULL_IMAGE_NAME}
                    """
                }
            }
        }

     stage('Update Helm Chart Image Tag') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'github-credentials', usernameVariable: 'GITHUB_USER', passwordVariable: 'GITHUB_TOKEN')]) {
                    container('jnlp') {
                        script {
                            // Configure git user
                            sh '''
                                git config --global user.email "jenkins@example.com"
                                git config --global user.name "Jenkins"
                            '''

                            // Update values.yaml with new image tag
                            sh """
                                sed -i 's/tag: .*/tag: ${IMAGE_TAG}/' helm-api/values.yaml
                            """

                            // Stage, commit, and push changes
                            sh """
                                git add helm-api/values.yaml
                                git commit -m "Update image tag to ${IMAGE_TAG}"
                                git push https://${GITHUB_USER}:${GITHUB_TOKEN}@github.com/jason-devopsfun/devopsfun.git HEAD:main
                            """
                        }
                    }
                }
            }
        }

    }
}