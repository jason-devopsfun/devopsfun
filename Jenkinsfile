pipeline {
    agent {
        kubernetes {
            yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: kaniko
    image: gcr.io/kaniko-project/executor:latest
    workingDir: /workspace
    volumeMounts:
    - name: kaniko-secret
      mountPath: /kaniko/.docker
  volumes:
  - name: kaniko-secret
    secret:
      secretName: regcred  # <-- Your Docker registry secret here
"""
            defaultContainer 'kaniko'
        }
    }

    environment {
        GITHUB_REPO = 'https://github.com/jason-devopsfun/devopsfun.git'
        DOCKER_IMAGE_NAME = 'demo-api'
        DOCKER_CLI_EXPERIMENTAL = 'enabled'
        IMAGE = "jkendall1975/demo-api:\${BUILD_NUMBER}-\${GIT_COMMIT}"
    }

    stages {
        stage('Checkout') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: '630f1da7-84c6-4eaa-a187-475d170d1886', 
                                                      usernameVariable: 'GIT_USERNAME', 
                                                      passwordVariable: 'GIT_PASSWORD')]) {
                        def githubUrl = GITHUB_REPO.replace('https://', "https://${GIT_USERNAME}:${GIT_PASSWORD}@")
                        sh "git clone ${githubUrl}"
                    }
                }
            }
        }

        stage('Build Application') {
            steps {
                dir('devopsfun/demo-api') {
                    sh './gradlew clean build'
                }
            }
        }

        stage('Build with Kaniko') {
            steps {
                container('kaniko') {
                    dir('devopsfun/demo-api') {
                        sh '''
                          /kaniko/executor \
                            --context=/workspace/devopsfun/demo-api \
                            --dockerfile=/workspace/devopsfun/demo-api/Dockerfile \
                            --destination=${IMAGE}
                        '''
                    }
                }
            }
        }
    }
}
