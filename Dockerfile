FROM    debian:bookworm-slim

########## Setup Debian ########## 
ENV     DEBIAN_FRONTEND=noninteractive 
RUN     sed -i '/^Components: main/ s/$/ contrib non-free non-free-firmware/' /etc/apt/sources.list.d/debian.sources \
        && dpkg --add-architecture i386

########## Install and set locales ########## 
RUN     apt-get update && apt-get install -y --no-install-recommends \
        locales \
        && echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen \
        && echo 'en_GB.UTF-8 UTF-8' >> /etc/locale.gen \
        && locale-gen \
        && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV     LANG=en_GB.UTF-8 \
        LANGUAGE=en_GB:en \
        LC_ALL=en_GB.UTF-8

########## Install some needed packages ########## 
RUN     apt-get update && apt-get install -y --no-install-recommends \
        at-spi2-core \
        dbus-x11 \
        libfontconfig1 \
        libfontconfig1:i386 \
        pciutils \
        sudo \        
        xdg-user-dirs \
        xdg-utils \
        xfonts-base \ 
        xterm \
        && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

########## Configure user ########## 
ENV     PUID=1000 \
        PGID=1000 \
        USER="steam" \
        USER_PASSWORD="password" \
        USER_HOME="/home/steam" \
        TZ="Europe/London" \
        USER_LOCALES="en_GB.UTF-8 UTF-8"

RUN     mkdir -p ${USER_HOME} \
        && useradd -d ${USER_HOME} -s /bin/bash ${USER} \
        && chown -R ${USER} ${USER_HOME} \
        && echo "${USER} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers 
         

########## Install VNC ########## 
RUN     apt-get update && apt-get install -y --no-install-recommends \
        x11vnc \
        xvfb \
        novnc \
        && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

########## Install Vulkan and Mesa ##########
RUN     apt-get update && apt-get install -y --no-install-recommends \
        libgl1-mesa-dri:i386 \
        libglx-mesa0:i386 \
        mesa-vulkan-drivers \
        mesa-vulkan-drivers:i386 \
        vulkan-tools \
        && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

########## Install PulseAudio ##########
RUN     apt-get update && apt-get install -y --no-install-recommends \
        pulseaudio \
        && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

########## Install Steam ########## 
RUN     apt-get update && apt-get install -y --no-install-recommends \
        steam-installer \
        && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
        && ln -sf /usr/games/steam /usr/bin/steam

# Is this needed? Seems not on openSUSE host.
########### Create .Xauthority files ##########
#RUN     touch /root/.Xauthority \
#        && chown root:root /root/.Xauthority \
#        && touch ${USER_HOME}/.Xauthority \
#        && chown ${USER}:${USER} ${USER_HOME}/.Xauthority


########## Set port ##########
EXPOSE  6080

########## Generate SSL/TLS certificate ##########
RUN openssl req -x509 -newkey rsa:4096 -keyout /usr/share/novnc/self.pem -out /usr/share/novnc/self.pem -days 365 -nodes -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"

########## Setup entrypoint.sh ##########
COPY    entrypoint.sh / 
RUN     chmod +x /entrypoint.sh 

ENTRYPOINT ["/entrypoint.sh"]
