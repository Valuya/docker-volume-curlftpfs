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
                sudo rm -rf rootfs
                sudo docker rm curlftpfsbuild || echo "."
                sudo docker rmi curlftpfsbuild || echo "."
                sudo docker rm pluginbuild || echo "."
                sudo docker rmi "${PLUGIN_NAME}":rootfs || echo "."

                sudo docker build -q -t curlftpfsbuild -f Dockerfile.dev .
                sudo docker create --name curlftpfsbuild curlftpfsbuild
                sudo docker cp curlftpfsbuild:/go/bin/docker-volume-curlftpfs .
                sudo docker stop curlftpfsbuild
                sudo docker rm curlftpfsbuild
                sudo docker rmi curlftpfsbuild
                sudo docker build -t "${PLUGIN_NAME}":rootfs .

                mkdir -p rootfs
                sudo docker create --name pluginbuild "${PLUGIN_NAME}":rootfs
                sudo docker export pluginbuild | tar -x -C rootfs
                sudo cp config.json rootfs/
                sudo docker stop pluginbuild
                sudo docker rm pluginbuild

                sudo docker plugin rm "${PLUGIN_NAME}":"${PLUGIN_TAG}" || echo "."
                sudo docker plugin create "${PLUGIN_NAME}":"${PLUGIN_TAG}" .

                sudo rm -rf rootfs
                sudo rm -rf docker-volume-curlftpfs
                sudo docker rmi "${PLUGIN_NAME}":rootfs
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
