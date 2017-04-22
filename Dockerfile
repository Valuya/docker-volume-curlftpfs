FROM debian

RUN apt-get update \
    && apt-get install -y curlftpfs

RUN echo "user_allow_other" >> /etc/fuse.conf

RUN mkdir -p /run/docker/plugins /mnt/state /mnt/volumes

COPY docker-volume-curlftpfs /docker-volume-curlftpfs

CMD ["/docker-volume-curlftpfs"]
