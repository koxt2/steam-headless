# steam-headless

**Steam client running in a _podman_ container and accessible from a browser at localhost:6080**

In it's current state this only works using podman. Docker hits namespace problems. 

## So far...

It installs the Steam client, it's capable of installing and playing native Linux games, and has audio. 

## Issues

There is no GPU acceleration, it's purely software rendered. 

Proton hasn't been tested.

X server key autorepeat not working.

## Setup

It assumes the host's user has a PUID=1000 and PGID=1000.

Create a directory for your container's /home and change permissions...

```shell
mkdir /path/to/directory
chmod 777 /path/to/directory
```

### Run...

```shell
podman run --detach \
  --ipc host \
  --interactive \
  --tty \
  --publish 6080:6080 \
  --name steam \
  -e PULSE_SERVER=unix:${XDG_RUNTIME_DIR}/pulse/native \
  -v ${XDG_RUNTIME_DIR}/pulse/native:${XDG_RUNTIME_DIR}/pulse/native \
  -v ~/.config/pulse/cookie:/root/.config/pulse/cookie \
  -v /path/to/directory:/home:Z \
koxt2/steam-headless
```

### podman-compose.yml

```yaml
name: steam-headless
services:
    steam-headless:
        ipc: host
        stdin_open: true
        tty: true
        ports:
            - 6080:6080
        container_name: steam
        environment:
            - PULSE_SERVER=unix:${XDG_RUNTIME_DIR}/pulse/native
        volumes:
            - ${XDG_RUNTIME_DIR}/pulse/native:${XDG_RUNTIME_DIR}/pulse/native
            - ~/.config/pulse/cookie:/root/.config/pulse/cookie
            - /path/to/directory:/home:Z
        image: koxt2/steam-headless
```
