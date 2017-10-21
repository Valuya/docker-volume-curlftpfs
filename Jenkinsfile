#!groovy

pipeline {
    agent any
    parameters {
        string(name:'PLUGIN_NAME', defaultValue: 'valuya/curlftpfs', description: '')
        string(name:'PLUGIN_TAG', defaultValue:'next', description: '')
    }
    options {
        disableConcurrentBuilds()
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }
    environment {
        PLUGIN_NAME="${params.PLUGIN_NAME}"
        PLUGIN_TAG="${params.PLUGIN_TAG}"
    }
    stages {
        stage ('Build') {
            steps {
                sh 'sudo -E make clean docker rootfs '
            }
        }
        stage ('Publish') {
            steps {
               sh 'sudo -E make create push clean'
            }
        }
    }
}
