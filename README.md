# VPN-on-docker
VPN script to install several VPN docker container

VPN_on_docker_v1.1.sh:
The purpose of this script is to automate the installation interactively for several VPN servers as docker containers including automated configuration and easy deployment. Developed for Ubuntu Server 18.04.3.

This script installs the docker ppa as well as the latest docker version available. Use cases are e.g. setting up desired VPN server on a freshly installed AWS instance.

Currently one can pull and set up the following docker container from dockerhub by using the script menu:
1. IPSec VPN server https://hub.docker.com/r/hwdsl2/ipsec-vpn-server/
2. OpenVPN Access server https://hub.docker.com/r/linuxserver/openvpn-as/

All steps necessary to set these container up are integrated into this script. Just follow the information shown on your screen during installation.

Only thing to do before running the script, is to change the IPSec Server credentials in the header of this script under "## IPSec Server Credentials ##" to your desired values. 

check_vpn_status_v1.1.sh:
This script allows you to check the current status of installed VPN servers as well as getting additional information.
