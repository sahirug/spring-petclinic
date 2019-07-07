pipeline {
    agent none
    stages {
        stage('Maven Install') {
            agent {
                docker {
                    image 'maven:3.5.3'
                }
            }
            steps {
                sh 'mvn clean install -U'
            }
        }
        stage('ls stage') {
            agent any
            steps {
                sh 'ls -la'
                sh 'ls -la target'
            }
        }
        stage('Docker build') {
            agent any
            steps {
                sh 'docker build -t sahirug/spring-petclinic:latest .'
            }
        }
    }
}