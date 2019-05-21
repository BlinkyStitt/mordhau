# Mordhau

Quickly run a [Mordhau Server](https://store.steampowered.com/app/629760/MORDHAU/) on your server with Docker.

## Build

    docker build . \
        --build-arg HTTP_PROXY=http://10.11.12.26:8000 \
        -t gitlab-registry.stytt.com/docker/mordhau:latest

## Run

    # host network should be faster but might be less secure
    docker run --rm -it \
        --network host \
        -v "/transcode/Steam:/home/steam/Steam" \
        --name mordhau \
        gitlab-registry.stytt.com/docker/mordhau

    # open just the necessary ports
    docker run --rm -it \
        -p 7777:7777/udp \
        -p 15000:15000/udp \
        -p 27015:27015/udp \
        -v "/transcode/Steam:/home/steam/Steam" \
        --name mordhau \
        gitlab-registry.stytt.com/docker/mordhau
