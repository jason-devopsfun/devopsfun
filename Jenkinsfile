pipeline {
    agent any

    environment {
        GITHUB_REPO = 'https://github.com/jason-devopsfun/devopsfun.git'
        DOCKER_IMAGE_NAME = 'demo-api' // Replace with your image name
        DOCKER_CLI_EXPERIMENTAL = 'enabled'
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

        stage('Build') {
            steps {
                script {
                    // Define the image name and tag
                    def imageName = 'gcr.io/your-project/demo-api'
                    def tag = "${imageName}:v${env.BUILD_NUMBER}-${env.GIT_COMMIT.take(7)}"

                    // Use Kaniko to build the image
                    sh """
                        /kaniko/executor --context $PWD --dockerfile $PWD/Dockerfile --destination ${tag}
                    """
                }
            }
        }
    }
}
