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
              sh '''
                rm -rf rootfs
                sudo docker build -q -t curlftpfsbuild -f Dockerfile.dev .
                sudo docker create --name curlftpfsbuild curlftpfsbuild
                sudo docker cp curlftpfsbuild:/go/bin/docker-volume-curlftpfs .
                sudo docker stop curlftpfsbuild
                sudo docker rm curlftpfsbuild
                sudo docker rmi curlftpfsbuild
                sudo docker build -t "${PLUGIN_NAME}":rootfs .

                mkdir -p rootfs
                sudo docker create --name pluginbuild "${PLUGIN_NAME}":rootfs
                sudo docker export pluginbuild | tar -x -C rootfs/rootfs
                sudo cp config.json rootfs/
                sudo docker stop pluginbuild
                sudo docker rm pluginbuild

                sudo docker plugin rm "${PLUGIN_NAME}":"${PLUGIN_TAG}"
                sudo docker plugin create "${PLUGIN_NAME}":"${PLUGIN_TAG}" rootfs

                sudo rm -rf rootfs
                sudo rm -rf docker-volume-curlftpfs
              '''
            }
        }
        stage ('Publish') {
            steps {
               sh 'sudo docker plugin push "${PLUGIN_NAME}":"${PLUGIN_TAG}"'
            }
        }
    }
}
