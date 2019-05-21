FROM gitlab-registry.stytt.com/docker/ubuntu

RUN useradd -m steam

# steamcmd deps
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
    qstat \
    xdg-user-dirs \
;

# install steamcmd and a volume for Steam
# TODO: checksum
ENV HOME /home/steam
ENV PATH "$PATH:/home/steam/steamcmd:/home/steam/Steam/steamapps/common/Mordhau Dedicated Server"
USER steam
WORKDIR /home/steam
RUN { set -eux; \
    \
    mkdir -p steamcmd Steam; \
    cd steamcmd; \
    curl -fSL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf -; \
}

# i used to install the game now, but starting the container with /home/steam/Steam as a volume sounds better
# TODO: we need to make sure directory permissions are correct on start. s6-overlay can do this for us
VOLUME /home/steam/Steam

# mordhau install script
COPY --chown=steam:steam update_mordhau.txt /home/steam/

# TODO: use s6-overlay instead?
COPY --chown=steam:steam update_and_run.sh /usr/local/bin/
CMD ["update_and_run.sh"]

# keep game configs last since they will change most often
# TODO: generate these from consul
# mordhau server config
# do NOT put it into /mnt/steam/mordhau/Mordhau/Saved/Config/LinuxServer/ since the defaults dont exist there yet
# TODO: copy from a volume instead so we can quickly iterate?
COPY --chown=steam:steam *.ini /home/steam/
