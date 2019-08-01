FROM ubuntu:18.04

# create a simple user for steam files
# TODO: allow custom ID and GID
RUN useradd -m steam

# entrypoint for s6-overlay
# this isn't going to change, so keep it first
ENTRYPOINT ["/init"]
CMD []

# s6-overlay
ENV S6_VERSION=1.22.1.0
ENV S6_GPGKEY=DB301BA3F6F807E0D0E6CCB86101B2783B2FD161
RUN { set -eux; \
    \
    cd /tmp; \
    apt-get update; \
    apt-get install -y ca-certificates curl gnupg; \
    curl -L -o /tmp/s6-overlay-amd64.tar.gz https://github.com/just-containers/s6-overlay/releases/download/v${S6_VERSION}/s6-overlay-amd64.tar.gz; \
    curl -L -o /tmp/s6-overlay-amd64.tar.gz.sig https://github.com/just-containers/s6-overlay/releases/download/v${S6_VERSION}/s6-overlay-amd64.tar.gz.sig; \
    export GNUPGHOME="$(mktemp -d -p /tmp)"; \
    curl https://keybase.io/justcontainers/key.asc | gpg --import; \
    gpg --list-keys "$S6_GPGKEY"; \
    gpg --batch --verify s6-overlay-amd64.tar.gz.sig s6-overlay-amd64.tar.gz; \
    tar xzf /tmp/s6-overlay-amd64.tar.gz -C /; \
    rm -rf /tmp/* /var/lib/apt/lists/*; \
}

# if fix-attrs or cont-init fail, stop by sending a termination signal to the supervision tree
ENV S6_BEHAVIOUR_IF_STAGE2_FAILS 2
# How long (in milliseconds) s6 should wait services before sending a TERM signal
ENV S6_SERVICES_GRACETIME 20000

# install dependencies
RUN { set -eux; \
    \
    apt-get update; \
    apt-get install -y \
        # steamcmd
        lib32gcc1 \
        readline-common \
        locales \
        # mordhao
        libfontconfig1 \
        libpangocairo-1.0-0 \
        libnss3 \
        libgconf2-4 \
        libxi6 \
        libxcursor1 \
        libxss1 \
        libxcomposite1 \
        libasound2 \
        libxdamage1 \
        libxtst6 \
        libatk1.0-0 \
        libxrandr2 \
        qstat \
        xdg-user-dirs \
    ; \
    echo en_US.UTF-8 UTF-8 >> /etc/locale.gen; \
    locale-gen; \
    rm -rf /var/lib/apt/lists/*; \
}

# install steamcmd as the steam user
# TODO: checksum
# TODO: install into /opt/ instead. then we can copy it into a volume for the steam user if it doesn't exist and run it
ENV PATH "$PATH:/home/steam/steamcmd:/home/steam/Steam/steamapps/common/Mordhau Dedicated Server"
RUN { set -eux; \
    \
    mkdir -p /opt/steamcmd; \
    cd /opt/steamcmd; \
    curl -fSL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf -; \
}

VOLUME /home/steam/steamcmd

# put the user back to root for s6-overlay
USER root

# i used to install the game now, but starting the container with /home/steam/Steam as a volume sounds better

# s6-overlay things to manage a mordhau server
COPY rootfs/ /

# mordhau server config
# keep game configs last since they are small and will probably change often
# TODO: generate these from environment variables on container start instead? might be simpler to just mount from the host
# do NOT put it into /mnt/steam/mordhau/Mordhau/Saved/Config/LinuxServer/ since the defaults dont exist there yet
COPY --chown=steam:steam *.ini /etc/mordhau/
