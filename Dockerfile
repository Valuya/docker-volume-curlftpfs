FROM alpine

RUN apk update && apk add sshfs

RUN mkdir -p /run/docker/plugins /mnt/state /mnt/volumes

COPY docker-volume-curlftpfs docker-volume-curlftpfs

CMD ["docker-volume-curlftpfs"]
