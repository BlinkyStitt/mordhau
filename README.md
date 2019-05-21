# Mordhau

Quickly run a [Mordhau Server](https://mordhau.com/) with Docker.

The server is free, but you need to [buy the game](https://store.steampowered.com/app/629760/MORDHAU/) to play.

Be sure to open UDP ports 7777, 15000, and 27015 on your firewall.

## Build

    # HTTP_PROXY is a squid caching proxy
    docker build . \
        --build-arg HTTP_PROXY=http://10.11.12.26:8000 \
        --build-arg HTTPS_PROXY=http://10.11.12.26:8000 \
        -t gitlab-registry.stytt.com/docker/mordhau:latest

## Run

    # host network should be faster but might be less secure
    # /transcode is my super-fast SSD, but you can use any full path or  docker volume
    docker run --rm -it \
        --network host \
        --env "SERVER_PASSWORD=1234"
        --env "ADMIN_PASSWORD=123456"
        --mount type=tmpfs,destination=/tmp \
        --name mordhau \
        --volume "/transcode/Steam:/home/steam/Steam" \
        gitlab-registry.stytt.com/docker/mordhau

    # Instead of "--network host" you can open just the necessary ports
        -p 7777:7777/udp \
        -p 15000:15000/udp \
        -p 27015:27015/udp \

    # On a host with ZFS and drives larger than 2TB, steamcmd has a bug. Workaround by setting a  size for the container storage to something less than 2TB but larger than the size of the game with some overhead.
        --storage-opt size=10G

## Status

    docker run --rm -it \
        --entrypoint quakestat \
        gitlab-registry.stytt.com/docker/mordhau \
        -a2s "$IP_OR_FQDN"

## TODO

* Put steamcmd stuff in a volume so the container saves updates
* I had an update fail because I forgot to set --storage-opt, but the server still started

    mordhau_1              | [cont-init.d] update_mordhau: exited 254.
    mordhau_1              | [cont-init.d] done.
    mordhau_1              | [services.d] starting services
