#!/bin/sh

# Source our persisted env variables from container startup
. /etc/qbittorrent/environment-variables.sh

# This script will be called with tun/tap device name as parameter 1, and local IP as parameter 4
# See https://openvpn.net/index.php/open-source/documentation/manuals/65-openvpn-20x-manpage.html (--up cmd)
# TODO ; à supprimer ???
echo "Updating QBITTORRENT_BIND_ADDRESS_IPV4 to the ip of $1 : $4"
export QBITTORRENT_BIND_ADDRESS_IPV4=$4

if [ ! -e "/dev/random" ]; then
  # Avoid "Fatal: no entropy gathering module detected" error
  echo "INFO: /dev/random not found - symlink to /dev/urandom"
  ln -s /dev/urandom /dev/random
fi

. /etc/qbittorrent/userSetup.sh

echo "STARTING QBITTORRENT"
exec sudo -u ${RUN_AS} /usr/bin/qbittorrent-nox --webui-port=8082 &

if [ "$OPENVPN_PROVIDER" = "PIA" ]
then
    echo "CONFIGURING PORT FORWARDING"
    exec /etc/qbittorrent/updatePort.sh &
else
    echo "NO PORT UPDATER FOR THIS PROVIDER"
fi

echo "qBittorrent startup script complete."
