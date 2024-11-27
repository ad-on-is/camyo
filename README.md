# Camy-O

## Manage SSH tunneling automatically.

### Install with Docker

```yaml
services:
    camyo:
        container_name: camyo
        image: ghcr.io/ad-on-is/camyo:latest
        environment:
            - DB_FILE=/db.sqlite
        volumes:
            - ./db.sqlite:/db.sqlite

    sshtunnels:
        image: lscr.io/linuxserver/openssh-server:latest
        container_name: sshtunnels
        network_mode: host
        # ... other settings

```

### Usage

Edit `camyo.sh` to your needs, copy it to the device, and let it start on boot.

```bash
CAMYO_URL="" # the publicly accessible URL of camyo
SSH_TUNNEL_HOST="" # the host where sshtunnels is running on 
SSH_TUNNEL_PORT=2222 # the port sshtunnels is exposed to
DEVICE_ID="" # the ID of the current device

# for DEVICE_ID you can also use a script that returns a unique ID, like the serial number
# for example
DEVICE_ID=$(cat /path/to/file/with/id | grep dowhatever)

```


