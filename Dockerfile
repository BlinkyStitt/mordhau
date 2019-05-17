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

# install steamcmd
# TODO: checksum
ENV HOME /home/steam
ENV PATH $PATH:/home/steam/steamcmd:/home/steam/mordhau
USER steam
RUN { set -eux; \
    \
    mkdir -p /home/steam/steamcmd; \
    cd /home/steam/steamcmd; \
    curl -fSL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf -; \
    # cd /home/steam; \
    # steamcmd.sh +quit; \
}

# mordhau install script
COPY --chown=steam:steam update_mordhau.txt /home/steam/

# install mordhau
RUN /home/steam/steamcmd/steamcmd.sh +runscript /home/steam/update_mordhau.txt

# TODO: use s6-overlay instead?
COPY --chown=steam:steam update_and_run.sh /home/steam/mordhau/
CMD ["update_and_run.sh"]

# keep game configs last since they will change most often
# TODO: generate these from consul
# mordhau server config
# do NOT put it into /mnt/steam/mordhau/Mordhau/Saved/Config/LinuxServer/ since the defaults dont exist there yet
# TODO: copy from a volume instead so we can quickly iterate?
COPY --chown=steam:steam mordhau.ini /home/steam/
