# Mordhau

Quickly run a [Mordhau Server](https://store.steampowered.com/app/629760/MORDHAU/) on your server with Docker.

Be sure to open UDP ports 7777, 15000, and 27015 on your firewall.

## Build

    docker build . \
        --build-arg HTTP_PROXY=http://10.11.12.26:8000 \
        -t gitlab-registry.stytt.com/docker/mordhau:latest

## Run

    # host network should be faster but might be less secure
    # /transcode is my super-fast SSD, but you can use any full path or  docker volume
    docker run --rm -it \
        --network host \
        -e "SERVER_PASSWORD=1234"
        -e "ADMIN_PASSWORD=123456"
        -v "/transcode/Steam:/home/steam/Steam" \
        --name mordhau \
        gitlab-registry.stytt.com/docker/mordhau

    # Instead of "--network host" you can open just the necessary ports
        -p 7777:7777/udp \
        -p 15000:15000/udp \
        -p 27015:27015/udp \

## Status

    docker run --rm -it \
        --entrypoint quakestat \
        gitlab-registry.stytt.com/docker/mordhau \
        -a2s "$IP_OR_FQDN"

## TODO

* Put steamcmd stuff in a volume so the container saves updates
