#!/bin/bash

set -e

[ "$(whoami)" = "steam" ]

echo "Updating..."
/home/steam/steamcmd/steamcmd.sh +runscript /home/steam/update_mordhau.txt

echo "Starting..."
exec MordhauServer.sh \
    -Port="${PORT:-7777}" \
    -QueryPort="${QUERY_PORT:-27015}" \
    -BeaconPort="${BEACON_PORT:-15000}" \
    -GAMEINI="${GAME_INI:-/home/steam/mordhau_game.ini}" \
    -ENGINEINI="${ENGINE_INI:-/home/steam/mordhau_engine.ini}" \
    "$@" \
;
