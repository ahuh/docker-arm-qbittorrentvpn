#! /bin/sh

kill $(ps aux | grep qbittorrent-nox | grep -v grep | awk '{print $2}')
