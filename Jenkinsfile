pipeline {
    agent any

    environment {
        GITHUB_REPO = 'https://github.com/jason-devopsfun/devopsfun.git'
        DOCKER_IMAGE_NAME = 'demo-api' // Replace with your image name
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
                    // Dynamically generate a tag based on the current Git commit hash or Jenkins build number
                    def imageName = 'jkendall1975/demo-api'
                    def buildTag = "${imageName}:v${env.BUILD_NUMBER}-${env.BRANCH_NAME}-${env.GIT_COMMIT.take(7)}" // Using build number, branch name, and commit hash
                    def latestTag = "${imageName}:latest"

                    // Build the Docker image using BuildKit
                    sh """
                        docker build --build-arg BUILDKIT_INLINE_CACHE=1 -t ${buildTag} -t ${latestTag} .
                    """
                }
            }
        }
    }
}
