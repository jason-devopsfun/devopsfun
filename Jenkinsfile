// try 3

pipeline {
    agent any
    
    environment {
        // GitHub credentials
        GITHUB_CREDENTIALS = credentials('630f1da7-84c6-4eaa-a187-475d170d1886')
        GITHUB_REPO = 'https://github.com/jason-devopsfun/devopsfun.git'
    }
    
    stages {
        stage('Checkout') {
            steps {
                script {
                    // Checkout GitHub repository using credentials
                    withCredentials([usernamePassword(credentialsId: '630f1da7-84c6-4eaa-a187-475d170d1886', 
                                                      usernameVariable: 'GIT_USERNAME', 
                                                      passwordVariable: 'GIT_PASSWORD')]) {
                        // Construct Git URL with credentials
                        def githubUrl = GITHUB_REPO.replace('https://', "https://${GIT_USERNAME}:${GIT_PASSWORD}@")
                        sh "git clone ${githubUrl}"
                    }
                }
            }
        }

        stage('Build Application') {
            steps {
                script {
                    // Change to the demo-api directory inside the cloned repo
                    dir('devopsfun/demo-api') {
                        // Run Gradle build in the demo-api directory
                        sh './gradlew clean build'
                    }
                }
            }


         stage('Build and Push Docker Image') {
            steps {
                script {
                    // Generate a version tag based on build number and timestamp
                    def version = "v1.0.${BUILD_NUMBER}-${new Date().format('yyyyMMdd-HHmmss')}"
                    
                    // Login to Docker Hub with credentials from 'dockerhub-credentials'
                    withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKER_HUB_USERNAME', passwordVariable: 'DOCKER_HUB_PASSWORD')]) {
                        sh "echo ${DOCKER_HUB_PASSWORD} | docker login -u ${DOCKER_HUB_USERNAME} --password-stdin"
                    }
                    
                    // Build the Docker image
                    sh "docker build -t ${DOCKER_HUB_USERNAME}/${DOCKER_IMAGE_NAME}:${version} -t ${DOCKER_HUB_USERNAME}/${DOCKER_IMAGE_NAME}:latest ."
                    
                    // Push the Docker image to Docker Hub
                    sh "docker push ${DOCKER_HUB_USERNAME}/${DOCKER_IMAGE_NAME}:${version}"
                    sh "docker push ${DOCKER_HUB_USERNAME}/${DOCKER_IMAGE_NAME}:latest"
                    
                    // Save the version for use in next stage
                    env.IMAGE_VERSION = version
                }
            }
        }
        

        }
    }
}
