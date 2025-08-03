pipeline {  

    agent any
        
    tools {
        maven "maven"
    }

    environment {
        AWS_ACCESS_KEY_ID     = credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
        AWS_DEFAULT_REGION    = 'us-east-1'
        JENKINS_SERVER_IP     = "54.226.59.54"
        REMOTE_USER           = "ubuntu"
    }

    stages {
        stage('Build') {
            steps {
                sh 'mvn clean package'
            }
        }

        stage('Clone Repo') {
            steps {
                git branch: 'main', url: 'https://github.com/Praveen230389/maven-web-app.git'
            }
        }

        stage('Terraform Init') {
            steps {
                sh 'terraform init'
            }
        }

        stage('Terraform Plan') {
            steps {
                sh 'terraform plan'
            }
        }

        stage('Terraform Validate') {
            steps {
                sh 'terraform validate'
            }
        }

        stage('Terraform Apply') {
            steps {
                sh 'terraform apply -auto-approve'
            }
        }

        stage('Docker Image Build') {
            steps {
                sh 'docker build -t ashokit/mavenwebapp .'
            }
        }

        stage('Execute playbook') {
            steps {
                ansiblePlaybook credentialsId: 'webserver', disableHostKeyChecking: true, installation: 'ansible', inventory: '/etc/ansible/inventory.ini', playbook: '/etc/ansible/playbook.yml', vaultTmpPath: ''
            }
        }
        stage('test maven') {
            steps {
                sh 'mvn test'
            }
        }

        stage('SonarQube Analysis') {
            environment {
                SONAR_HOST_URL = 'http://54.226.59.54:9000'
                SONAR_AUTH_TOKEN = credentials('SonarQubetoken')
            }
            steps {
                sh 'mvn sonar:sonar -Dsonar.projectKey=sample_project -Dsonar.host.url=$SONAR_HOST_URL -Dsonar.login=$SONAR_AUTH_TOKEN'
            }
        }
        stage('k8s deployment') {
            steps {
                sh 'kubectl apply -f k8s-deploy.yml'
            }
        }
    }
}
