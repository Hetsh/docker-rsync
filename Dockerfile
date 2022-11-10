FROM amd64/alpine:20221110
RUN apk add --no-cache \
        openssh=9.1_p1-r1 \
        rsync=3.2.7-r0

# App user
ARG APP_UID=1376
ARG APP_USER="rsync"
ARG DATA_DIR="/rsync"
RUN adduser --disabled-password --uid "$APP_UID" --home "$DATA_DIR" --gecos "$APP_USER" "$APP_USER"

# Configuration & Volumes
ARG CONF_FILE="/etc/ssh/sshd_config"
RUN sed -i "s|#HostKey /etc/ssh/ssh_host_rsa_key|HostKey $DATA_DIR/ssh_host_rsa_key|" "$CONF_FILE" && \
    sed -i "s|#HostKey /etc/ssh/ssh_host_ecdsa_key|HostKey $DATA_DIR/ssh_host_ecdsa_key|" "$CONF_FILE" && \
    sed -i "s|#HostKey /etc/ssh/ssh_host_ed25519_key|HostKey $DATA_DIR/ssh_host_ed25519_key|" "$CONF_FILE" && \
    sed -i "s|AuthorizedKeysFile	.ssh/authorized_keys|AuthorizedKeysFile $DATA_DIR/authorized_keys|" "$CONF_FILE" && \
    chown -R "$APP_USER":"$APP_USER" "/run"
VOLUME ["$DATA_DIR"]

#      SSH
EXPOSE 22/tcp

USER "$APP_USER"
WORKDIR "$DATA_DIR"
ENTRYPOINT ["/usr/sbin/sshd", "-D", "-e"]
