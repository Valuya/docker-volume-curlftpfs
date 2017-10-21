PLUGIN_NAME ?= "valuya/curlftpfs"
PLUGIN_TAG ?= 1
PLUGIN_WD ?= "/tmp/docker-volume-curlftpfs"


all: clean docker rootfs create enable

clean:
	@echo "### rm ${PLUGIN_WD}"
	@rm -rf ${PLUGIN_WD}

docker:
	@echo "### docker build: builder image"
	@docker build -q -t builder -f Dockerfile.dev .
	@echo "### extract docker-volume-curlftpfs"
	@docker create --name tmp builder
	@docker cp tmp:/go/bin/docker-volume-curlftpfs .
	@docker rm -vf tmp
	@docker rmi builder
	@echo "### docker build: rootfs image with docker-volume-curlftpfs"
	@docker build -q -t ${PLUGIN_NAME}:rootfs .

rootfs:
	@echo "### create rootfs directory in ${PLUGIN_WD}/rootfs"
	@mkdir -p ${PLUGIN_WD}/rootfs
	@docker create --name tmp ${PLUGIN_NAME}:rootfs
	@docker export tmp | tar -x -C ${PLUGIN_WD}/rootfs
	@echo "### copy config.json to ${PLUGIN_WD}/"
	@cp config.json ${PLUGIN_WD}/
	@docker rm -vf tmp

create:
	@echo "### remove existing plugin ${PLUGIN_NAME}:${PLUGIN_TAG} if exists"
	@docker plugin rm -f ${PLUGIN_NAME}:${PLUGIN_TAG} || true
	@echo "### create new plugin ${PLUGIN_NAME}:${PLUGIN_TAG} from ${PLUGIN_WD}"
	@docker plugin create ${PLUGIN_NAME}:${PLUGIN_TAG} ${PLUGIN_WD}

enable:
	@echo "### enable plugin ${PLUGIN_NAME}:${PLUGIN_TAG}"
	@docker plugin enable ${PLUGIN_NAME}:${PLUGIN_TAG}

push:
	@echo "### push plugin ${PLUGIN_NAME}:${PLUGIN_TAG}"
	@docker plugin push ${PLUGIN_NAME}:${PLUGIN_TAG}
