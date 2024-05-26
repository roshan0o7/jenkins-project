pipeline {
    agent any
    tools {
        maven "MAVEN3"
        jdk "java17"
    }
    environment {
        SNAP_REPO = 'vprofile-snapshot'
        NEXUS_USER = 'admin'
        NEXUS_PASS = 'admin'
        RELEASE_REPO = 'vprofile-release'
        CENTRAL_REPO = 'vpro-maven-central'
        NEXUSIP = '54.210.8.28'
        NEXUSPORT = '8081'
        NEXUS_GRP_REPO = 'vpro-maven-group'
        NEXUS_CREDENTIAL_ID = "nexus-user-credentials"
        SONARSERVER = 'sonarserver'
        SONARSCANNER = 'sonarscanner'
    }
    stages {
        stage('Build') {
            steps {
                sh 'mvn -s pom.xml -DskipTests install'
            }
            post {
                success {
                    echo "Now Archiving."
                    archiveArtifacts artifacts: '**/*.war'
                }
            }
        }
        stage('Test') {
           steps {
            sh 'mvn test'
           }
        }
        stage('Checkstyle Analysis'){
            steps {
                sh 'mvn -s pom.xml checkstyle:checkstyle'
            }
        }
        stage('CODE ANALYSIS with SONARQUBE') {
          environment {
             scannerHome = tool "${sonarscanner}"
          }
          steps {
            withSonarQubeEnv("${SONARSERVER}") {
               sh '''${scannerHome}/bin/sonar-scanner -Dsonar.projectKey=vprofile \
                   -Dsonar.projectName=vprofile-repo \
                   -Dsonar.projectVersion=1.0 \
                   -Dsonar.sources=src/ \
                   -Dsonar.java.binaries=target/test-classes/com/visualpathit/account/controllerTest/ \
                   -Dsonar.junit.reportsPath=target/surefire-reports/ \
                   -Dsonar.jacoco.reportsPath=target/jacoco.exec \
                   -Dsonar.java.checkstyle.reportPaths=target/checkstyle-result.xml'''
            }
          }
        }
       stage('UPLOAD ARTIFACT') {
                steps {
                    nexusArtifactUploader(
                        nexusVersion: 'nexus3',
                        protocol: 'http',
                        nexusUrl: "${NEXUSIP}:${NEXUSPORT}",
                        groupId: 'QA',
                        version: "${env.BUILD_ID}-${env.BUILD_TIMESTAMP}",
                        repository: "${RELEASE_REPO}",
                        credentialsId: "${NEXUS_CREDENTIAL_ID}",
                        artifacts: [
                            [artifactId: 'vproapp' ,
                            classifier: '',
                            file: 'target/vprofile-v2.war',
                            type: 'war']
                        ]
                    )
                }
            }
        stage('Login to ECR') {
            steps {
                script {
                    withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'AWSLoginuser', 
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    ]]) {
                        sh 'aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 006432355300.dkr.ecr.us-east-1.amazonaws.com'
                    }
                }
            }
        }
      stage('Build Image') {
		steps {
		   script {
                    def imageName = '006432355300.dkr.ecr.us-east-1.amazonaws.com/webserverimage'
                    def imageTag = "webserver" // Ensure this tag is valid
                    def fullImageName = "${imageName}:${imageTag}"
	             sh "docker build -t ${fullImageName} ."
	            sh "docker push ${fullImageName}"
	          } 
	  }
      }
        stage('Deploy') {
            steps {
                script {
                    def remoteUser = "ubuntu"
                    def remoteHost = "10.0.4.154"
                    def credentialsId = "jem.pem" // This should match the ID of your Jenkins credentials
                    def deployScriptPath = "deploy.sh" // Relative path to the script

                    // Use SSH agent for SSH credentials
                    sshagent(['jem.pem']) {
                        sh "ssh -o StrictHostKeyChecking=no ${remoteUser}@${remoteHost} 'bash -s' < ${env.WORKSPACE}/${deployScriptPath}"
                    }
                }
            }
        }
    }
}
