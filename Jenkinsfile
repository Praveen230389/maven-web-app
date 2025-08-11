pipeline {  
    agent any
        
    tools {
        maven "maven3.9.11"
    }

    environment {
        AWS_ACCESS_KEY_ID     = credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
        AWS_DEFAULT_REGION    = 'us-east-1'
        DOCKER_SERVER_IP      = "52.91.251.90"
        REMOTE_USER           = "ubuntu"
    }

    stages {

        stage('Clone Repo') {
            steps {
                git branch: 'main', url: 'https://github.com/Praveen230389/maven-web-app.git'
            }
        }

        stage('Build') {
            steps {
                sh 'mvn clean package'
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
                ansiblePlaybook(
                    credentialsId: 'ansible',
                    disableHostKeyChecking: true,
                    installation: 'ansible',
                    inventory: '/etc/ansible/hosts',
                    playbook: '/home/ubuntu/workspace/mainproject/playbook.yaml',
                    vaultTmpPath: ''
                )
            }
        }

        stage('Test Maven') {
            steps {
                sh 'mvn test'
            }
        }

        stage('Stage IV: SAST') {
            steps { 
                echo "Running Static Application Security Testing using SonarQube Scanner ..."
                withSonarQubeEnv('SonarQube') {
                    sh 'mvn sonar:sonar -Dsonar.coverage.jacoco.xmlReportPaths=target/site/jacoco/jacoco.xml -Dsonar.dependencyCheck.jsonReportPath=target/dependency-check-report.json -Dsonar.dependencyCheck.htmlReportPath=target/dependency-check-report.html -Dsonar.projectName=Kubernetes'
                }
            }
        }

        stage('Stage V: Quality Gates') {
            steps { 
                echo "Running Quality Gates to verify the code quality"
                script {
                    timeout(time: 1, unit: 'MINUTES') {
                        def qg = waitForQualityGate()
                        if (qg.status != 'OK') {
                            error "Pipeline aborted due to quality gate failure: ${qg.status}"
                        }
                    }
                }
            }
        }

        stage('Trivy Scan') {
            steps { 
                echo "Scanning Image for Vulnerabilities"
                sh "trivy image --scanners vuln --offline-scan adamtravis/democicd:latest > trivyresults.txt"
            }
        }

        stage('SonarQube Analysis') {
            environment {
                SONAR_HOST_URL = 'http://54.87.160.236:9000'
                SONAR_AUTH_TOKEN = credentials('SonarQubetoken')
            }
            steps {
                sh 'mvn sonar:sonar -Dsonar.projectKey=sample_project -Dsonar.host.url=$SONAR_HOST_URL -Dsonar.login=$SONAR_AUTH_TOKEN'
            }
        }

        stage('K8s Deployment') {
            steps {
                withKubeConfig(
                    caCertificate: '',
                    clusterName: '',
                    contextName: '',
                    credentialsId: 'k8s-Sonar-server',
                    namespace: '',
                    restrictKubeConfigAccess: false,
                    serverUrl: ''
                ) {
                    sh 'kubectl apply -f k8s-deploy.yml'
                }
            }
        }

    } // end of stages
} // end of pipeline
