FROM library/alpine:20210212
RUN apk add --no-cache \
    openssh=8.5_p1-r0 \
    rsync=3.2.3-r1

# App user
ARG APP_UID=1376
ARG APP_USER="rsync"
ARG DATA_DIR="/rsync"
RUN adduser --disabled-password --uid "$APP_UID" --home "$DATA_DIR" --gecos "$APP_USER" "$APP_USER"
VOLUME ["$DATA_DIR"]

#      SSH
EXPOSE 22/tcp

USER "$APP_USER"
WORKDIR "$DATA_DIR"
ENTRYPOINT ["/usr/sbin/sshd", "-D", "-e"]
