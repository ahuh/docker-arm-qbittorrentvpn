#!/bin/sh

# =======================================================================================
# Run Docker container
#
# The container is launched in background as a daemon. It is configured to restart
# automatically, even after host OS restart, unless it is stopped manually with the
# 'docker stop' command 
# =======================================================================================

# ------------------------------------------------------
# Custom parameters

# Add a 'docker-params.sh' file to set the following variables:
# export E_OPENVPN_PROVIDER=XXX
# export E_OPENVPN_CONFIG=XXX
# export E_OPENVPN_USERNAME=XXX
# export E_OPENVPN_PASSWORD=XXX
. docker-params.sh

export DOCKERHOST=$(ip route | grep docker | awk '{print $NF}')
export DNS_1=8.8.8.8
export DNS_2=8.8.4.4

export DEVICE=/dev/net/tun

export V_CONFIG=/shares/P2P/tools/qbittorrent
export V_TORRENT_DIR=/shares/P2P/tools/qbittorrent/torrent
export V_COMPLETED_DIR=/shares/P2P/tools/qbittorrent/completed
export V_INCOMPLETE_DIR=/shares/P2P/tools/qbittorrent/incomplete

export P_PORT=8082

export E_LOCAL_NETWORK=192.168.0.0/24
export E_PUID=500
export E_PGID=1000

# ------------------------------------------------------
# Common parameters

export CONTAINER_NAME=qbittorrentvpn
export IMAGE_NAME_1=arm-qbittorrentvpn
export IMAGE_NAME_2=ahuh/arm-qbittorrentvpn
export IMAGE_NAME=

if [[ "$1" = "h" ]] || [[ "$1" = "help" ]] || [[ "$1" = "-h" ]] || [[ "$1" = "-help" ]] || [[ "$1" = "--h" ]] || [[ "$1" = "--help" ]]; then
    echo 'Run a Docker container.'
    echo ''
    echo 'Usage:'    
    echo '  docker-run.sh [CONTAINER_NAME] [IMAGE_NAME]'
    echo '  docker-run.sh h | help | -h | -help | --h | --help'
    echo ''
    echo 'Options:'
    echo "  CONTAINER_NAME  Name of the container [default: ${CONTAINER_NAME}]"
    echo "  IMAGE_NAME      Name of the image [default: ${IMAGE_NAME_1} (if exists), ${IMAGE_NAME_2} (otherwise)]"
    echo ''
    exit 1
fi

if [[ $1 ]]; then
	CONTAINER_NAME=$1
else
	echo "Using default container name: ${CONTAINER_NAME}"
fi
if [[ $2 ]]; then
	IMAGE_NAME=$2
else
	if [[ $(docker images | awk '{ print $1,$3 }' | grep -E "^${IMAGE_NAME_1}\s" | wc -l) != 0 ]] ; then
		IMAGE_NAME=${IMAGE_NAME_1}
	else
		IMAGE_NAME=${IMAGE_NAME_2}
	fi
	echo "Using default image name: ${IMAGE_NAME}"
fi

# ------------------------------------------------------
# Common commands

if [[ $(docker ps -f name=${CONTAINER_NAME} -f status=running | grep ${CONTAINER_NAME} | wc -l) != 0 ]] ; then
	# Container already running: stop it
	echo "Stop running container: ${CONTAINER_NAME}"
	docker stop ${CONTAINER_NAME}
	RESULT=$?
	if [[ ${RESULT} != 0 ]] ; then
		exit 1
	fi
fi

if [[ $(docker ps -a -f name=${CONTAINER_NAME} | grep ${CONTAINER_NAME} | wc -l) != 0 ]] ; then
	# Container already exists: remove it
	echo "Remove existing container: ${CONTAINER_NAME}"
	docker rm ${CONTAINER_NAME}
	RESULT=$?
	if [[ ${RESULT} != 0 ]] ; then
		exit 1
	fi
fi

# ------------------------------------------------------
# Custom commands

echo "Run container: ${CONTAINER_NAME}"
docker run --name ${CONTAINER_NAME} --restart=always --add-host=dockerhost:${DOCKERHOST} --dns=${DNS_1} --dns=${DNS_2} -d -p ${P_PORT}:8082 --cap-add=NET_ADMIN --device=${DEVICE} -v ${V_CONFIG}:/config/.config/qBittorrent -v ${V_TORRENT_DIR}:/torrentdir -v ${V_COMPLETED_DIR}:/completeddir -v ${V_INCOMPLETE_DIR}:/incompletedir -v /etc/localtime:/etc/localtime:ro -e "OPENVPN_PROVIDER=${E_OPENVPN_PROVIDER}" -e "OPENVPN_CONFIG=${E_OPENVPN_CONFIG}" -e "OPENVPN_USERNAME=${E_OPENVPN_USERNAME}" -e "OPENVPN_PASSWORD=${E_OPENVPN_PASSWORD}" -e "OPENVPN_OPTS=--inactive 3600 --ping 10 --ping-exit 60" -e "LOCAL_NETWORK=${E_LOCAL_NETWORK}" -e "PUID=${E_PUID}" -e "PGID=${E_PGID}" ${IMAGE_NAME}
