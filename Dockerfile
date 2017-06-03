# qBittorrent and OpenVPN
#
# Version 1.0

FROM resin/rpi-raspbian:jessie
LABEL maintainer "ahuh"

# Volume torrentdir: use it in qBittorrent configuration for torrents (e.g. scan dir, downloading torrents dir, completed torrents dir) 
# WARNING: must have read/write accept for execution user (PUID/PGID)
VOLUME /torrentdir
# WARNING: must have read/write accept for execution user (PUID/PGID)
# Volume completeddir: use it in qBittorrent configuration for completed dir
VOLUME /completeddir
# Volume incompletedir: use it in qBittorrent configuration for incomplete dir
# WARNING: must have read/write accept for execution user (PUID/PGID)
VOLUME /incompletedir
# Volume userhome: home directory for execution user
# WARNING: must have read/write accept for execution user (PUID/PGID)
VOLUME /config
# Volume config: contains qBittorrent.conf (generated at first start if needed)
VOLUME /config/.config/qBittorrent

# Set environment variables
# - Set OpenVPN IDs (must be overloaded) and execution user (PUID/PGID)
ENV OPENVPN_USERNAME=**None** \
    OPENVPN_PASSWORD=**None** \
    OPENVPN_PROVIDER=**None** \
    PUID=\
    PGID=
# - Set xterm for nano
ENV TERM xterm

# Remove previous apt repos
RUN rm -rf /etc/apt/preferences.d* \
	&& mkdir /etc/apt/preferences.d \
	&& rm -rf /etc/apt/sources.list* \
	&& mkdir /etc/apt/sources.list.d \
	&& mkdir /root/tmp

# Copy custom bashrc to root (ll aliases)
COPY root/ /root/
# Copy apt config for jessie (stable) and stretch (testing) repos
COPY preferences.d/ /etc/apt/preferences.d/
COPY sources.list.d/ /etc/apt/sources.list.d/

# Update packages and install software
RUN apt-get update \
    && apt-get install -y qbittorrent-nox \
    && apt-get install -y openvpn curl nano iftop crudini \
    && apt-get install -y dumb-init -t stretch \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*    

# Create and set user & group for impersonation
RUN groupmod -g 1000 users \
    && useradd -u 911 -U -d /config -s /bin/false abc \
    && usermod -G users abc

# Copy configuration and scripts
COPY common/ /etc/common/
COPY openvpn/ /etc/openvpn/
COPY qbittorrent/ /etc/qbittorrent/

# Fix execution permissions after copy 
RUN chmod +x /etc/common/*.sh \
	&& chmod +x /etc/openvpn/*.sh \
    && chmod +x /etc/qbittorrent/*.sh

# Expose port
EXPOSE 8082

# Launch OpenVPN with qBittorrent at container start
CMD ["dumb-init", "/etc/openvpn/start.sh"]
