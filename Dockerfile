FROM gitlab-registry.stytt.com/docker/linux-s6/ubuntu

RUN useradd -m steam

RUN { set -eux; \
    \
        docker-install \
        ca-certificates \
        curl \
        lib32gcc1 \
        readline-common \
        locales \
    ; \
    echo en_US.UTF-8 UTF-8 >> /etc/locale.gen; \
    locale-gen; \
}

# TODO: run this as steam
# TODO: checksum
RUN { set -eux; \
    \
    mkdir -p /mnt/steam /home/steam/steamcmd; \
    cd /home/steam/steamcmd; \
    curl -fSL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf -; \
    chown -R steam:steam /home/steam/steamcmd /mnt/steam; \
    su steam -c "./steamcmd.sh +quit"; \
}

# mordhao deps
RUN docker-install \
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
;

# mordhao install script
COPY --chown=steam:steam update_mordhao.txt /home/steam/

# install mordhao
RUN su steam -c "/home/steam/steamcmd/steamcmd.sh +runscript /home/steam/update_mordhao.txt"

COPY /rootfs /

# keep game configs last since they will change most often
# TODO: generate these from consul
# mordhao server config
# TODO: why did copying it directly into LinuxServer delete all the other configs?!
# TODO: copy from a volume instead so we can quickly iterate?
COPY --chown=steam:steam mordhao.ini /home/steam/
RUN { set -eux; \
    \
    ls -la /mnt/steam/mordhau/Mordhau/Saved/Config/LinuxServer/; \
    cp /home/steam/mordhao.ini /mnt/steam/mordhau/Mordhau/Saved/Config/LinuxServer/Game.ini; \
}
