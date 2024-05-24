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
        NEXUSIP = '18.210.20.175'
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
        stage('Deploy to Tomcat') {
            steps {
                script {
                    def remoteUser = "ubuntu"
                    def remoteHost = "10.0.4.154"
                    def remotePath = "/opt/tomcat/webapps"
                    def pemFile = "jem.pem"
                    def warFile = "vprofile-v2.war"
                    
                    // Copy WAR file to a temporary location
                    sh """
                        scp -i ${pemFile} /var/lib/jenkins/workspace/demo@2/target/${warFile} ${remoteUser}@${remoteHost}:/tmp/
                    """
                    
                    // Move the WAR file to the Tomcat webapps directory using sudo
                    sh """
                        ssh -i ${pemFile} ${remoteUser}@${remoteHost} 'sudo mv /tmp/${warFile} ${remotePath}/'
                    """
                }
            }
        }  
    }
}
