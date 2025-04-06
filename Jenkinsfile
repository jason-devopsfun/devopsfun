// try 2

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
        }
    }
}
