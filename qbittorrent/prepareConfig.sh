#! /bin/bash

mkdir -p /config/.config/qBittorrent

QBITTORRENT_CONFIG_FILE=/config/.config/qBittorrent/qBittorrent.conf
if [ ! -e "$QBITTORRENT_CONFIG_FILE" ] ; then
	# Create config file if not exists
    touch $QBITTORRENT_CONFIG_FILE
    chown ${RUN_AS}:${RUN_AS} $QBITTORRENT_CONFIG_FILE
fi

# Add legal notice accepted to avoid first start validation with input key 'y'
crudini --set $QBITTORRENT_CONFIG_FILE LegalNotice Accepted true

# Add or update environment vars (completed dir, incomplete dir, torrent dir)
crudini --set $QBITTORRENT_CONFIG_FILE Preferences Downloads\\SavePath /completeddir
crudini --set $QBITTORRENT_CONFIG_FILE Preferences Downloads\\TempPathEnabled true
crudini --set $QBITTORRENT_CONFIG_FILE Preferences Downloads\\TempPath /incompletedir
crudini --set $QBITTORRENT_CONFIG_FILE Preferences Downloads\\ScanDirs /torrentdir

export QBITTORRENT_CONFIG_FILE