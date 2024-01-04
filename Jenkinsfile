#!groovy

def RELEASE = /^release\/.*/
def FEATURE = /^feature\/.*/
def BUGFIX = /^bugfix\/.*/

pipeline {
    agent {
        docker {
            image 'ivmak/jenkins:1.0.0'
            args '-it'
        }
    }
    // agent any
    parameters {
        string(
            name: "branch",
            defaultValue: "development",
            description: "Ветка git"
        )
    }
    stages {
        stage('clone') {
            steps {
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: branch]],
                    extensions: [],
                    userRemoteConfigs: [[url: 'https://github.com/ivmakar/TotalCoverage.git']]
                ])
            }
        }
        stage('detect') {
            when {
                allOf {
                    not { expression { "${branch}" ==~ RELEASE } }
                    not { expression { "${branch}" ==~ FEATURE } }
                    not { expression { "${branch}" ==~ BUGFIX } }
                }
            }
            steps {
                script {
                    report = "Вы запустили сборку на верке ${branch}, которая не является одной из release, feature или bugfix."
                    sh 'echo "${report}"'
                    writeFile file: 'report.txt', text: report
                    archiveArtifacts(artifacts: 'report.txt', allowEmptyArchive: true)
                    error(report)
                }
            }
        }
        stage("init") {
            steps {
                withCredentials([file(credentialsId: 'otus_keystore', variable: 'OTUS_KEY_FILE')]) {
                    sh "chmod +x gradlew"
                    sh "./gradlew"
                }
            }
        }
        
        stage("testRelease") {
            when {
                expression { "${branch}" ==~ RELEASE }
            }
            steps {
                script {
                    withCredentials([file(credentialsId: 'otus_keystore', variable: 'OTUS_KEY_FILE')]) {
                        sh "./gradlew testDebugUnitTest"
                        sh "./gradlew testDebugAndroidTest"
                    }
                }
            }
        }
        stage("buildRelease") {
            when {
                expression { "${branch}" ==~ RELEASE }
            }
            steps {
                withCredentials([file(credentialsId: 'otus_keystore', variable: 'OTUS_KEY_FILE')]) {
                    sh "./gradlew assembleRelease"
                }
            }
        }
        
        stage("testDebug") {
            when {
                anyOf {
                    expression { "${branch}" ==~ FEATURE }
                    expression { "${branch}" ==~ BUGFIX }
                }
            }
            steps {
                withCredentials([file(credentialsId: 'otus_keystore', variable: 'OTUS_KEY_FILE')]) {
                    sh "./gradlew testDebugUnitTest"
                }
            }
        }
        stage("buildDebug") {
            when {
                anyOf {
                    expression { "${branch}" ==~ FEATURE }
                    expression { "${branch}" ==~ BUGFIX }
                }
            }
            steps {
                withCredentials([file(credentialsId: 'otus_keystore', variable: 'OTUS_KEY_FILE')]) {
                    sh "./gradlew assembleDebug"
                }
            }
        }
        
        stage("publishMavenLocal") {
            steps {
                withCredentials([file(credentialsId: 'otus_keystore', variable: 'OTUS_KEY_FILE')]) {
                    sh "./gradlew publishToMavenLocal"
                }
            }
        }
    }
    
    post {
        failure {
            archiveArtifacts(artifacts: '**/build/reports/**', allowEmptyArchive: true)
        }
    }
}
