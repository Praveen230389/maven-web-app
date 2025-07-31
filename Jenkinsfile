pipeline {  

    agent any
        
    tools{
        maven "maven"
    }
    environment {
        AWS_ACCESS_KEY_ID     = credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
        AWS_DEFAULT_REGION    = 'us-east-1'
        DOCKER_SERVER_IP      = "18.206.162.90"
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

        stage('Docker Stop Container') {
            steps {
                sh 'docker stop justprojectcontainer || true'
            }
        }

        stage('Docker Remove Container') {
            steps {
                sh 'docker rm justprojectcontainer || true'
            }
        }

        stage('Docker Remove Image') {
            steps {
                sh 'docker rmi justproject || true'
            }
        }

        stage('Docker Image Build') {
            steps {
                sh 'docker build -t justproject .'
            }
        }

        stage('Docker Container Creation') {
            steps {
                sh 'docker run -d -p 8082:80 --name justprojectcontainer justproject'
            }
        }
        stage('Execute playbook') {
            steps {
                sh 'ansiblePlaybook credentialsId: 'webserver', disableHostKeyChecking: true, installation: 'Ansible', inventory: '/etc/ansible/inventory.ini', playbook: '/etc/ansible/playbook.yml', vaultTmpPath:'
            }
        }
        stage('Test') {
            steps {
                sh 'mvn test'
            }
        }
        
        stage('SonarQube Analysis') {
            environment {
                SONAR_HOST_URL = 'http://44.203.100.154:9000' // Replace with your SonarQube URL
                SONAR_AUTH_TOKEN = credentials('SonarQube') // Store your token in Jenkins credentials
            }
            steps {
                sh 'mvn sonar:sonar -Dsonar.projectKey=sample_project -Dsonar.host.url=$SONAR_HOST_URL -Dsonar.login=$SONAR_AUTH_TOKEN'
            }
        }
        
    }
}
