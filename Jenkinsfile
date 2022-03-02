//noinspection GroovyUnusedAssignment
@Library("jenkins-libraries@main") _

pipeline {
    agent any

    environment {
        SONARQUBE_ENV = "Sonarqube"
        SONARQUBE_CREDENTIAL_ID = "sonar-jenkins-user"
        ARTIFACTORY_SERVER_ID = "artifactory-server-saas"
        ARTIFACTORY_SERVER_URL = "https://springpetclinictestpro.jfrog.io/"
        ARTIFACTORY_REPOSITORY_URL = "artifactory/example-repo-local/"
        ARTIFACTORY_BUILD_NAME = "springpetclinic"
        ARTIFACTORY_PROJECT = "spc"
        ARTIFACTORY_CREDENTIAL_ID = "artifactory-jenkins-user"
        NEXUS_SERVER_URL = "10.3.1.6:8081"
        NEXUS_REPOSITORY_NAME = "emerasoft-maven-nexus-repo"
        NEXUS_VERSION = "nexus3"
        NEXUS_PROTOCOL = "http"
        NEXUS_CREDENTIAL_ID = "sonatype-jenkins-user"
        NEXUS_APPLICATION = "spring-petclinic"
        OKTETO_SERVER_URL = "https://cloud.okteto.com"
        OKTETO_TOKEN = "joXe00ffVhLf6wDadoPatXkvLQrMJ2zpsR3HO20yZSi2GkpX"
        OKTETO_GITHUB_REPOSITORY_NAME = "spring-petclinic-github"
        OKTETO_GITHUB_REPOSITORY_URL = "https://github.com/adeganutti/spring-petclinic-github.git"
        OKTETO_DEPLOYMENT_NAME = "spc"
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
            }
        }
        stage('Analysis') {
            parallel {
                stage('JaCoCo Analysis') {
                    steps {
                        jacoco(execPattern: 'target/jacoco.exec')
                    }
                }
                stage('SonarQube Analysis') {
                    steps {
                        script{
                            sonarqube.call(SONARQUBE_ENV, SONARQUBE_CREDENTIAL_ID)
                        }
                    }
                }
                stage("Nexus IQ Analysis") {
                    steps {
                        script {
                            nexusPolicyEvaluation advancedProperties: '', enableDebugLogging: false, failBuildOnNetworkError: false, iqApplication: selectedApplication(NEXUS_APPLICATION), iqStage: 'build', jobCredentialsId: ''
                        }
                    }
                }
            }
        }
        stage("Maven Package") {
            steps {
                sh "mvn package -DskipTests=true"
            }
        }

        stage('Artifact Repository Push') {
            parallel {
                stage("Artifactory Repository Push") {
                    steps {
                        script {
                            artifactory.call(ARTIFACTORY_SERVER_ID, ARTIFACTORY_SERVER_URL, ARTIFACTORY_REPOSITORY_URL, ARTIFACTORY_BUILD_NAME, ARTIFACTORY_PROJECT, ARTIFACTORY_CREDENTIAL_ID)
                        }
                    }
                }

                stage("Nexus Repository Push") {
                    steps {
                        script{
                            nexusRepository.call(NEXUS_SERVER_URL, NEXUS_REPOSITORY_NAME, NEXUS_VERSION, NEXUS_PROTOCOL, NEXUS_CREDENTIAL_ID)
                        }
                    }
                }
            }
        }

        stage("Okteto Deploy") {
            steps {
                script{
                    okteto.call(OKTETO_SERVER_URL, OKTETO_TOKEN, OKTETO_GITHUB_REPOSITORY_NAME, OKTETO_GITHUB_REPOSITORY_URL, OKTETO_DEPLOYMENT_NAME)
                }
            }
        }

    }
    post {
        always {
            junit allowEmptyResults: true, testResults: 'target/surefire-reports/*.xml'
        }
    }
}
