# Docker ARM qBittorrent VPN
Docker image dedicated to ARMv7 processors, hosting a qBittorrent client with WebUI while connecting to OpenVPN.<br />
<br />
This project is based on an existing project, modified to work on ARMv7 WD My Cloud EX2 Ultra NAS.<br />
See GitHub repository: https://github.com/haugene/docker-transmission-openvpn<br />
<br />
This image is part of a Docker images collection, intended to build a full-featured seedbox, and compatible with WD My Cloud EX2 Ultra NAS (Docker v1.7.0):

Docker Image | GitHub repository | Docker Hub repository
------------ | ----------------- | -----------------
Docker image (ARMv7) hosting a Transmission torrent client with WebUI while connecting to OpenVPN | https://github.com/ahuh/docker-arm-transquidvpn | https://hub.docker.com/r/ahuh/arm-transquidvpn
Docker image (ARMv7) hosting a qBittorrent client with WebUI while connecting to OpenVPN | https://github.com/ahuh/docker-arm-qbittorrentvpn | https://hub.docker.com/r/ahuh/arm-qbittorrentvpn
Docker image (ARMv7) hosting SubZero with MKVMerge (subtitle autodownloader for TV shows) | https://github.com/ahuh/docker-arm-subzero | https://hub.docker.com/r/ahuh/arm-subzero
Docker image (ARMv7) hosting a SickChill server with WebUI | https://github.com/ahuh/docker-arm-sickchill | https://hub.docker.com/r/ahuh/arm-sickchill
Docker image (ARMv7) hosting a Medusa server with WebUI | https://github.com/ahuh/docker-arm-medusa | https://hub.docker.com/r/ahuh/arm-medusa
Docker image (ARMv7) hosting a Jackett server with WebUI | https://github.com/ahuh/docker-arm-jackett | https://hub.docker.com/r/ahuh/arm-jackett
Docker image (ARMv7) hosting a NGINX server to secure SickRage, Transmission and qBittorrent | https://github.com/ahuh/docker-arm-nginx | https://hub.docker.com/r/ahuh/arm-nginx

## Installation

### Preparation
Before running container, you have to retrieve UID and GID for the user used to mount your torrents data directory:
* Get user UID:
```
$ id -u <user>
```
* Get user GID:
```
$ id -g <user>
```
The container will run impersonated as this user, in order to have read/write access to the torrents data directory.

### Run container in background
```
$ docker run --name qbittorrent --restart=always -d \
		--add-host=dockerhost:<docker host IP> \
		--dns=<ip of dns #1> --dns=<ip of dns #2> \
		-p <webui port>:8082 --cap-add=NET_ADMIN \
		--device=<tunnel network interface> \			  
		-v <path to torrent dir to scan>:/torrentdir \
		-v <path to completed dir>:/completeddir \
		-v <path to incompleted dir>:/incompletedir \
		-v <path to qBittorrent configuration dir>:/config/.config/qBittorrent \
		-v /etc/localtime:/etc/localtime:ro \
		-e "OPENVPN_PROVIDER=<openvpn provider>" \
		-e "OPENVPN_CONFIG=<openvpn configuration>" \
		-e "OPENVPN_USERNAME=<openvpn user name>" \
		-e "OPENVPN_PASSWORD=<openvpn password> \
		-e "OPENVPN_OPTS=--inactive 3600 --ping 10 --ping-exit 60" \
		-e "LOCAL_NETWORK=<local network ip/mask>" \
		-e "PUID=<user uid>" \
		-e "PGID=<user gid>" \
		ahuh/arm-qbittorrentvpn
```
or
```
$ ./docker-run.sh qbittorrent ahuh/arm-qbittorrentvpn
```
(set parameters in `docker-run.sh` before launch, and generate a `docker-params.sh` to store secret OpenVPN parameters, as described in `docker-run.sh`)

### Configure qBittorrent
The container will use volumes directories to store torrent files, downloaded files, and configuration files.<br />
<br />
You have to create these volume directories with the PUID/PGID user permissions, before launching the container:
```
/torrentdir
/completeddir
/incompletedir
/config/.config/qBittorrent
```

The container will automatically create a `qBittorrent.conf` file in the qBittorrent configuration dir (only if none was present before).<br />
* Authentication is enabled in WebUI. The default credentials (you may change them in WebUI settings) are: 
	* Login: `admin`
	* Password: `adminadmin`
* This section will be automatically added to prevent manual validation at first start:
```
[LegalNotice]
Accepted=true
```
* The following parameters will be automatically modified at launch for compatibility with the Docker container:
```
[Preferences]
...
Downloads\SavePath=/completeddir
Downloads\TempPathEnabled=true
Downloads\TempPath=/incompletedir
Downloads\ScanDirs=/torrentdir
```
* With PIA VPN, the following parameter will be automatically modified at launch if port forwarding is available:
```
[Preferences]
Connection\PortRangeMin=XXX
```
<br />
If you modified the `qBittorrent.conf` file, restart the container to reload qBittorrent configuration:
```
$ docker stop qbittorrent
$ docker start qbittorrent
```

## HOW-TOs

### Get a new instance of bash in running container
Use this command instead of `docker attach` if you want to interact with the container while it's running:
```
$ docker exec -it qbittorrent /bin/bash
```
or
```
$ ./docker-bash.sh qbittorrent
```

### Build image
```
$ docker build -t arm-qbittorrentvpn .
```
or
```
$ ./docker-build.sh arm-qbittorrentvpn
```
