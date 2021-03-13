# RSync
Simple to set up SSH daemon with RSync client.

## Running the server
```bash
docker run --detach --name rsync --publish 22:22/tcp hetsh/rsync
```

## Stopping the container
```bash
docker stop rsync
```

## Creating persistent storage
```bash
STORAGE="/path/to/storage"
mkdir -p "$STORAGE"
chown -R 1376:1376 "$STORAGE"
```
`1376` is the numerical id of the user running the server (see Dockerfile).
The user must have RW access to the storage directory.
Start the server with the additional mount flags:
```bash
docker run --mount type=bind,source=/path/to/storage,target=/rsync-data ...
```

## Time
Synchronizing the timezones will display the correct time in the logs.
The timezone can be shared with this mount flag:
```bash
docker run --mount type=bind,source=/etc/localtime,target=/etc/localtime,readonly ...
```

## Automate startup and shutdown via systemd
The systemd unit can be found in my GitHub [repository](https://github.com/Hetsh/docker-rsync).
```bash
systemctl enable rsync --now
```
By default, the systemd service assumes `/apps/rsync` for storage and `/etc/localtime` for timezone.
Since this is a personal systemd unit file, you might need to adjust some parameters to suit your setup.

## Fork Me!
This is an open project hosted on [GitHub](https://github.com/Hetsh/docker-rsync).
Please feel free to ask questions, file an issue or contribute to it.
