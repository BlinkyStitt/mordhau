# Mordhau

Quickly run a [Mordhau Server](https://mordhau.com/) with Docker.

The server is free, but you need to [buy the game](https://store.steampowered.com/app/629760/MORDHAU/) to play.

Be sure to open UDP ports 7777, 15000, and 27015 on your firewall.

This isn't yet working for me. Quakestat shows the server as running, but the client won't connect. I asked for help [on Reddit](https://www.reddit.com/r/Mordhau/comments/bpk8rz/dedicated_server_running_but_i_cant_connect/).

## Build

    # HTTP_PROXY is a squid caching proxy
    docker build . \
        --build-arg HTTP_PROXY=http://10.11.12.26:8000 \
        --build-arg HTTPS_PROXY=http://10.11.12.26:8000 \
        -t bwstitt/mordhau:latest

## Run

    # /transcode is my super-fast SSD, but you can use any full path or docker volume
    docker run --rm -it \
        --network host \
        --env "SERVER_PASSWORD=1234"
        --env "ADMIN_PASSWORD=123456"
        --mount type=tmpfs,destination=/tmp \
        --name mordhau \
        --volume "/transcode/Steam:/home/steam/Steam" \
        --volume "/transcode/steamcmd:/home/steam/steamcmd" \
        bwstitt/mordhau

Instead of "--network host" you can open just the necessary ports, but it might be a little slower

    -p 7777:7777/udp \
    -p 15000:15000/udp \
    -p 27015:27015/udp \

On a host with ZFS and drives larger than 2TB, steamcmd has a bug. Workaround by setting a  size for the container storage to something less than 2TB but larger than the size of the game with some overhead.

    --storage-opt size=10G \

If you want to do something more complex with the configs, simply mount one or both of them

    --volume "/path/to/mordhau/Game.ini:/etc/mordhau/Game.ini" \
    --volume "/path/to/mordhau/Engine.ini:/etc/mordhau/Engine.ini" \

If you have a graphics card, I think this will give the server access:

    --device /dev/dri:/dev/dri \

## Status

    docker run --rm -it \
        --entrypoint quakestat \
        bwstitt/mordhau \
        -a2s "$IP_OR_FQDN"

## TODO

Use https://github.com/kelseyhightower/confd instead of sed to generate config from environment variables
