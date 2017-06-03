#! /bin/bash

# Source our persisted env variables from container startup
. /etc/qbittorrent/environment-variables.sh

if [ ! -e "/dev/random" ]; then
  # Avoid "Fatal: no entropy gathering module detected" error
  echo "INFO: /dev/random not found - symlink to /dev/urandom"
  ln -s /dev/urandom /dev/random
fi

. /etc/qbittorrent/userSetup.sh

echo "PREPARING QBITTORRENT CONFIG"
. /etc/qbittorrent/prepareConfig.sh

if [ "$OPENVPN_PROVIDER" = "PIA" ]
then
    echo "CONFIGURING PORT FORWARDING"
    . /etc/qbittorrent/updatePort.sh
else
    echo "NO PORT UPDATER FOR THIS PROVIDER"
fi

echo "STARTING QBITTORRENT"
exec sudo -u ${RUN_AS} /usr/bin/qbittorrent-nox --webui-port=8082 &

echo "qBittorrent startup script complete."
