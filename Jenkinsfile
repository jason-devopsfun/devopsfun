// test 2
pipeline {
    agent any
    
    environment {
        // Change these variables to match your setup
        DOCKER_HUB_CREDENTIALS = credentials('dockerhub-credentials')
        GITHUB_CREDENTIALS = credentials('github-credentials')
        
        DOCKER_HUB_USERNAME = 'your-dockerhub-username'
        DOCKER_IMAGE_NAME = 'demo-api'
        
        GITHUB_USER = 'your-github-username'
        GITHUB_EMAIL = 'your-email@example.com'
        GITHUB_REPO = 'https://github.com/your-username/your-repo.git'
        
        // Path to Helm values.yaml relative to root
        HELM_VALUES_PATH = 'helm/demo-api/values.yaml'
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Build Application') {
            steps {
                sh './gradlew clean build'
            }
        }
        
        stage('Build and Push Docker Image') {
            steps {
                script {
                    // Generate a version tag based on build number and timestamp
                    def version = "v1.0.${BUILD_NUMBER}-${new Date().format('yyyyMMdd-HHmmss')}"
                    
                    // Login to Docker Hub
                    sh "echo ${DOCKER_HUB_CREDENTIALS_PSW} | docker login -u ${DOCKER_HUB_CREDENTIALS_USR} --password-stdin"
                    
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
        
        stage('Update Helm Values and Push to GitHub') {
            steps {
                script {
                    // Set up Git configuration
                    sh "git config user.email \"${GITHUB_EMAIL}\""
                    sh "git config user.name \"${GITHUB_USER}\""
                    
                    // Update the image tag in values.yaml
                    // For Linux/macOS
                    sh "sed -i 's|tag: .*|tag: \"${env.IMAGE_VERSION}\"|g' ${HELM_VALUES_PATH}"
                    // For Windows, use:
                    // sh "powershell -Command \"(Get-Content ${HELM_VALUES_PATH}) -replace 'tag: .*', 'tag: \\\"${env.IMAGE_VERSION}\\\"' | Set-Content ${HELM_VALUES_PATH}\""
                    
                    // Commit and push the changes
                    sh "git add ${HELM_VALUES_PATH}"
                    sh "git commit -m 'Update image tag to ${env.IMAGE_VERSION} [skip ci]'"
                    
                    // Push using the credentials
                    withCredentials([usernamePassword(credentialsId: 'github-credentials', usernameVariable: 'GIT_USERNAME', passwordVariable: 'GIT_PASSWORD')]) {
                        // Update the URL to include credentials
                        def githubUrl = GITHUB_REPO.replace('https://', "https://${GIT_USERNAME}:${GIT_PASSWORD}@")
                        sh "git push ${githubUrl} HEAD:main"
                    }
                }
            }
        }
    }
    
    post {
        always {
            // Clean up Docker images to free up space
            sh "docker rmi ${DOCKER_HUB_USERNAME}/${DOCKER_IMAGE_NAME}:${env.IMAGE_VERSION} ${DOCKER_HUB_USERNAME}/${DOCKER_IMAGE_NAME}:latest || true"
            
            // Logout from Docker Hub
            sh "docker logout"
        }
    }
}