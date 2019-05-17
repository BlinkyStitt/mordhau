#!/bin/bash

[ "$(whoami)" = "steam" ] || exit 9

echo "Updating..."
/home/steam/steamcmd/steamcmd.sh +runscript /home/steam/update_mordhau.txt

echo "Starting..."
MordhauServer.sh \
    -Port="${PORT:-7777}" \
    -QueryPort="${QUERY_PORT:-27015}" \
    -Beaconport="${BEACON_PORT:-15000}" \
    -GAMEINI="${GAME_INI:-/home/steam/mordhau.ini}" \
    "$@" \
;
