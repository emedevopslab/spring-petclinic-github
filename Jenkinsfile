pipeline {
    agent any

    environment {
            NEXUS_VERSION = "nexus3"
            NEXUS_PROTOCOL = "http"
            NEXUS_URL = "10.3.1.6:8081"
            NEXUS_REPOSITORY = "emerasoft-maven-nexus-repo"
            NEXUS_CREDENTIAL_ID = "sonatype-jenkins-user"
    }

    stages {
        stage('Maven Build') {
            steps {
                sh 'mvn clean install -DskipTests'
            }
        }
        stage('Maven Test') {
            steps {
                sh 'mvn test'
                junit 'test-report.xml'
            }
        }
        stage('JaCoCo Analysis') {
            steps {
                jacoco(execPattern: 'target/jacoco.exec')
            }
        }
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('Sonarqube') {
                  sh "mvn clean verify sonar:sonar -Dsonar.login=jenkins -Dsonar.password=jenkins"
                }
            }
        }
        stage("Nexus IQ Analysis") {
            steps {
                nexusPolicyEvaluation advancedProperties: '', enableDebugLogging: false, failBuildOnNetworkError: false, iqApplication: selectedApplication('spring-petclinic'), iqStage: 'build', jobCredentialsId: ''
            }
        }
        stage("Maven Package") {
            steps {
                sh "mvn package -DskipTests=true"
            }
        }
        stage("Nexus Repository Push") {
            steps {
                script {
                    pom = readMavenPom file: "pom.xml";
                    filesByGlob = findFiles(glob: "target/*.${pom.packaging}");
                    echo "${filesByGlob[0].name} ${filesByGlob[0].path} ${filesByGlob[0].directory} ${filesByGlob[0].length} ${filesByGlob[0].lastModified}"
                    artifactPath = filesByGlob[0].path;
                    artifactExists = fileExists artifactPath;
                    if(artifactExists) {
                        echo "*** File: ${artifactPath}, group: ${pom.groupId}, packaging: ${pom.packaging}, version ${pom.version}";
                        nexusArtifactUploader(
                            nexusVersion: NEXUS_VERSION,
                            protocol: NEXUS_PROTOCOL,
                            nexusUrl: NEXUS_URL,
                            groupId: pom.groupId,
                            version: pom.version,
                            repository: NEXUS_REPOSITORY,
                            credentialsId: NEXUS_CREDENTIAL_ID,
                            artifacts: [
                                [artifactId: pom.artifactId,
                                classifier: '',
                                file: artifactPath,
                                type: pom.packaging],
                                [artifactId: pom.artifactId,
                                classifier: '',
                                file: "pom.xml",
                                type: "pom"]
                            ]
                        );
                    } else {
                        error "*** File: ${artifactPath}, could not be found";
                    }
                }
            }
        }
    }
    post {
        always {
            junit allowEmptyResults: true, testResults: 'test-report.xml'
        }
    }
}
