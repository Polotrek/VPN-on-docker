#!/bin/bash
clear

## IPSec Server Credentials ##
VPN_IPSEC_PSK=your_ipsec_psk
VPN_USER=your_usernname
VPN_PASSWORD=your_password

## OpenVPN Access Server Ports ##
PORTADMIN=943
PORTTCP=9933
PORTUDP=1194

######## Do not edit after this line ##############

## VARIABLES ##
DIRDOCKER=$HOME/docker
DIROVPNAS=$HOME/docker/OVPNAS
FILEDOCKER=/usr/bin/docker
FILEVPN=/$HOME/docker/ipsec.env

### Functions for menu ###
function_IPSec_VPN () {
	install_docker
	install_IPsec_VPN
	echo		
}

function_OpenVPN () {
	install_docker
	install_OpenVPN
	echo
}

function_all () {
# function not being used
	install_docker
	install_IPsec_VPN
	install_OpenVPN
	echo
}

apply_all () {
# function not being used
    echo "apply all"
    function_both
	docker_to_sudo
}

reset_default () {
	echo -e "kill and remove running container and delete created files and folders"
	echo -e "killed and remove container:"
	sudo docker kill ipsec-vpn-server openvpn-as
	sudo docker rm ipsec-vpn-server openvpn-as
	sudo rm -r /$HOME/docker	
}

### Functions to call in script ###
install_IPsec_VPN () {
if [[ ! "$(sudo docker ps -a | grep ipsec-vpn-server)" ]]; then
	echo -e "\e[93m\e[104m################################################################################\e[0m"
	echo -e "\e[104m\e[93m#\e[0m\e[104m                                                                              \e[93m#\e[0m"
	echo -e "\e[104m\e[93m#\e[0m\e[104m                           Install IPSec VPN docker                           \e[93m#\e[0m"
	echo -e "\e[104m\e[93m#\e[0m\e[104m                                                                              \e[93m#\e[0m"
	echo -e "\e[93m\e[104m################################################################################\e[0m"
	
	if [[ ! -f "$FILEVPN" ]]; then
    cat <<EOF > ${FILEVPN}
# Define your own values for these variables
# - DO NOT put "" or '' around values, or add space around =
# - DO NOT use these special characters within values: \ " '
VPN_IPSEC_PSK=$VPN_IPSEC_PSK
VPN_USER=$VPN_USER
VPN_PASSWORD=$VPN_PASSWORD

# (Optional) Define additional VPN users
# - Uncomment and replace with your own values
# - Usernames and passwords must be separated by spaces
# VPN_ADDL_USERS=additional_username_1 additional_username_2
# VPN_ADDL_PASSWORDS=additional_password_1 additional_password_2

# (Optional) Use alternative DNS servers
# - By default, clients are set to use Google Public DNS
# - Example below shows using Cloudflare's DNS service
VPN_DNS_SRV1=1.1.1.1
VPN_DNS_SRV2=1.0.0.1
EOF
		echo "***************************************************"
		echo "File $FILEVPN created"
		echo "***************************************************"
	else
		echo "***************************************************"
		echo "File $FILEVPN already exists"
		echo "***************************************************"
	fi
sudo docker pull hwdsl2/ipsec-vpn-server

sudo docker run -d \
	--name ipsec-vpn-server \
	--env-file /$HOME/docker/ipsec.env \
	--restart=always \
	-p 500:500/udp \
	-p 4500:4500/udp \
	--privileged \
	hwdsl2/ipsec-vpn-server

echo
sudo docker ps
	echo -e "\e[93m\e[104m################################################################################\e[0m"
	echo -e "\e[104m\e[93m#\e[0m\e[104m                                                                              \e[93m#\e[0m"
	echo -e "\e[104m\e[93m#\e[0m\e[104m   IPSec Server Information:                                                  \e[93m#\e[0m"
	echo -e "\e[104m\e[93m#\e[0m\e[104m   --------------------------------------------------------------------       \e[93m#\e[0m"
	echo -e "\e[104m\e[93m#\e[0m\e[104m                                                                              \e[93m#"
	echo -e "\e[104m    IPsec PSK: $VPN_IPSEC_PSK"
	echo -e "\e[104m    Username: $VPN_USER"
	echo -e "\e[104m    Password: $VPN_PASSWORD"
	echo -e "\e[104m\e[93m#\e[0m\e[104m                                                                              \e[93m#\e[0m"
	echo -e "\e[104m\e[93m#\e[0m\e[104m   Write these down. You'll need them to connect!                             \e[93m#\e[0m"
	echo -e "\e[104m\e[93m#\e[0m\e[104m                                                                              \e[93m#\e[0m"
	echo -e "\e[104m\e[93m#\e[0m\e[104m   UDP Ports: 500; 4500                                                       \e[93m#\e[0m"
	echo -e "\e[104m\e[93m#\e[0m\e[104m                                                                              \e[93m#\e[0m"
	echo -e "\e[93m\e[104m################################################################################\e[0m"
	echo -e
	echo -e
	echo -e

else
	echo -e "Docker *ipsec-vpn-server* already exists. Either running or stopped."
	echo -e "If you want to reinstall *Reset installation* first."
	echo -e "Attention: this deletes all dockers and created files."
	echo -e
fi
}

install_OpenVPN () {
if [ ! "$(sudo docker ps -a | grep openvpn-as)" ]; then
	echo -e "\e[93m\e[104m################################################################################\e[0m"
	echo -e "\e[104m\e[93m#\e[0m\e[104m                                                                              \e[93m#\e[0m"
	echo -e "\e[104m\e[93m#\e[0m\e[104m                   Install OpenVPN Access Server docker                       \e[93m#\e[0m"
	echo -e "\e[104m\e[93m#\e[0m\e[104m                                                                              \e[93m#\e[0m"
	echo -e "\e[93m\e[104m################################################################################\e[0m"
	
	if [[ ! -d $DIROVPNAS ]]; then
    mkdir ${DIROVPNAS}
    echo "***************************************************"
    echo "Directory $DIROVPNAS created"
    echo "***************************************************"
	else
    echo "***************************************************"
    echo "Directory $DIROVPNAS already exists"
    echo "***************************************************"
	fi

sudo docker pull linuxserver/openvpn-as

sudo docker run -d \
	--name=openvpn-as \
	--cap-add=NET_ADMIN \
	-e PUID=1000 \
	-e PGID=1000 \
	-e TZ=Europe/Berlin \
	-p $PORTADMIN:$PORTADMIN \
	-p $PORTTCP:$PORTTCP \
	-p $PORTUDP:$PORTUDP/udp \
	-v /$HOME/docker/OVPNAS:/config \
	--restart always \
	linuxserver/openvpn-as

echo
sudo docker ps
	echo -e
	echo -e "\e[93m\e[104m################################################################################\e[0m"
	echo -e "\e[104m\e[93m#\e[0m\e[104m                                                                              \e[93m#\e[0m"
	echo -e "\e[104m\e[93m#\e[0m\e[104m   OpenVPN Access Server Information:                                         \e[93m#\e[0m"
	echo -e "\e[104m\e[93m#\e[0m\e[104m   --------------------------------------------------------------------       \e[93m#\e[0m"
	echo -e "\e[104m\e[93m#\e[0m\e[104m   You can now continue configuring OpenVPN Access Server by                  \e[93m#\e[0m"
	echo -e "\e[104m\e[93m#\e[0m\e[104m   directing your Web browser to this URL:                                    \e[93m#\e[0m"
	echo -e "\e[104m\e[93m#\e[0m\e[104m   https://<server_ip>:$PORTADMIN/admin                                              \e[93m#\e[0m"
	echo -e "\e[104m\e[93m#\e[0m\e[104m   user: admin                                                                \e[93m#\e[0m"
	echo -e "\e[104m\e[93m#\e[0m\e[104m   password: password                                                         \e[93m#\e[0m"
	echo -e "\e[104m\e[93m#\e[0m\e[104m                                                                              \e[93m#\e[0m"
	echo -e "\e[104m\e[93m#\e[0m\e[104m                                                                              \e[93m#\e[0m"
	echo -e "\e[104m\e[93m#\e[0m\e[104m   During normal operation, OpenVPN AS can be accessed via these URLs:        \e[93m#\e[0m"
	echo -e "\e[104m\e[93m#\e[0m\e[104m   Admin  UI: https://<server_ip>:$PORTADMIN/admin                                   \e[93m#\e[0m"
	echo -e "\e[104m\e[93m#\e[0m\e[104m   Client UI: https://<server_ip>:$PORTADMIN/                                        \e[93m#\e[0m"
	echo -e "\e[104m\e[93m#\e[0m\e[104m                                                                              \e[93m#\e[0m"
	echo -e "\e[104m\e[93m#\e[0m\e[104m   TCP Port: $PORTTCP                                                             \e[93m#\e[0m"
	echo -e "\e[104m\e[93m#\e[0m\e[104m   UDP Port: $PORTUDP                                                             \e[93m#\e[0m"
	echo -e "\e[104m\e[93m#\e[0m\e[104m                                                                              \e[93m#\e[0m"
	echo -e "\e[93m\e[104m################################################################################\e[0m"
	echo -e
	echo -e


while true; do
	echo -e "\e[93m\e[104m################################################################################\e[0m"
	echo -e "\e[104m\e[93m#\e[0m\e[104m   Password change of default Admin account doesn't survive container         \e[93m#\e[0m"
	echo -e "\e[104m\e[93m#\e[0m\e[104m   restart. For security reasons, connect to the Admin User Interface now     \e[93m#\e[0m"
	echo -e "\e[104m\e[93m#\e[0m\e[104m   and follow the steps below                                                 \e[93m#\e[0m"
	echo -e "\e[104m\e[93m#\e[0m\e[104m                                                                              \e[93m#\e[0m"
	echo -e "\e[104m\e[93m#\e[0m\e[104m   1. wait until the WebUI comes up (may takes some minutes)                  \e[93m#\e[0m"
	echo -e "\e[104m\e[93m#\e[0m\e[104m   2. create a new Admin user                                                 \e[93m#\e[0m"
	echo -e "\e[104m\e[93m#\e[0m\e[104m   3. login with the newly created Admin user                                 \e[93m#\e[0m"
	echo -e "\e[104m\e[93m#\e[0m\e[104m   4. delete default Admin account                                            \e[93m#\e[0m"
	echo -e "\e[104m\e[93m#\e[0m\e[104m                                                                              \e[93m#\e[0m"
	echo -e "\e[104m\e[93m#\e[0m\e[104m   Do not proceed before you executed these steps. This script will           \e[93m#\e[0m"
    echo -e "\e[104m\e[93m#\e[0m\e[104m   harden this installation now.                                              \e[93m#\e[0m"
	echo -e "\e[93m\e[104m################################################################################\e[0m"


            read -p "Did you acomplish these steps to proceed? [yn]" yn
            case $yn in
                [Yy]* ) break;;
                [Nn]* ) exit;;
                * ) echo "Please answer yes or no";;
            esac
        done
        
RANDOMNAME=$(sudo head /dev/urandom | tr -dc A-Za-z0-9 | head -c 13 ; echo '')
sudo sed -i "s/boot_pam_users.0=admin/boot_pam_users.0=$RANDOMNAME/g" $HOME/docker/OVPNAS/etc/as.conf
echo "restart container"
sudo docker restart openvpn-as
sudo docker ps

else
	echo -e "Docker *openvpn-as* already exists. Either running or stopped."
	echo -e "If you want to reinstall *Reset installation* first."
	echo -e "Attention: this deletes all dockers and created files."
	echo -e
fi
}

install_docker () {
## Install Docker and Repositories
if [[ -f "$FILEDOCKER" ]]; then
	echo "***************************************************"
    echo "Docker already exists - no installation needed"
    echo "***************************************************"
		
	if [ "$(sudo systemctl is-active docker)" = "inactive" ]; then
		echo -e "***************************************************"
		echo -e "Docker doesn't seem to be started"
		echo -e "Please start docker and restart script"
		echo -e "***************************************************"
		exit
	fi
 
else
	echo "install updates"
	sudo apt-get update && sudo apt-get upgrade -y
	echo -e "\e[93m\e[104m################################################################################\e[0m"
	echo -e "\e[104m\e[93m#\e[0m\e[104m                                                                              \e[93m#\e[0m"
	echo -e "\e[104m\e[93m#\e[0m\e[104m                         Start Docker Installation                            \e[93m#\e[0m"
	echo -e "\e[104m\e[93m#\e[0m\e[104m                                                                              \e[93m#\e[0m"
	echo -e "\e[93m\e[104m################################################################################\e[0m"
    # install prerequisites
    sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common -y
    
    # add Docker gpg key	
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    echo
    echo -e "\e[93m\e[104m################################################################################\e[0m"
	echo -e
	sudo apt-key fingerprint 0EBFCD88
    echo -e "\e[93m\e[104m################################################################################\e[0m"
	echo -e "\e[104m\e[93m#\e[0m\e[104m                     compare last 8 characters with                           \e[93m#\e[0m"
	echo -e "\e[104m\e[93m#\e[0m\e[104m                                                                              \e[93m#\e[0m"
	echo -e "\e[104m\e[93m#\e[0m\e[104m              9DC8 5822 9FC7 DD38 854A E2D8 8D81 803C 0EBF CD88               \e[93m#\e[0m"
	echo -e "\e[93m\e[104m################################################################################\e[0m"
    
    
    
        while true; do
            read -p "Do the hashes match? [yn]" yn
            case $yn in
                [Yy]* ) break;;
                [Nn]* ) exit;;
                * ) echo "Please answer yes or no.";;
            esac
        done

    # add Docker repository
    sudo add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) \
    stable"
    sudo apt-get update
    
    # install Docker
    sudo apt-get install docker-ce docker-ce-cli containerd.io -y
fi

## create docker directory
if [[ ! -d "$DIRDOCKER" ]]; then
    mkdir ${DIRDOCKER}
    echo "***************************************************"
    echo "Directory $DIRDOCKER created"
    echo "***************************************************"
    sudo setfacl -Rdm g:docker:rwx $HOME/docker
    sudo chmod -R 775 $HOME/docker
else
    echo "***************************************************"
    echo "Directory $DIRDOCKER already exists"
    echo "***************************************************"
    echo
    echo
fi
}

docker_to_sudo () {
	# add USER to sudo group
	sudo gpasswd -a $USER docker
	newgrp docker
	echo
}

### Main ###
echo -e "\e[93m\e[104m################################################################################\e[0m"
echo -e "\e[104m\e[93m#\e[0m\e[104m  This script will install Docker if not installed yet and you've got         \e[93m#\e[0m"       
echo -e "\e[104m\e[93m#\e[0m\e[104m  the options below to install your desired VPN Servers as Docker             \e[93m#\e[0m"
echo -e "\e[104m\e[93m#\e[0m\e[104m  container files with credentials defined in header of script                \e[93m#\e[0m"
echo -e "\e[93m\e[104m################################################################################\e[0m"

while true; do
    options=("Install IPSec VPN Server" "Install OpenVPN Access Server" "Add docker to sudo & exit" "Reset container installation" "Quit")

    echo "Which actions do you want to perform?"
    echo "Choose an option:"
    select opt in "${options[@]}"; do
        case $REPLY in
            1) function_IPSec_VPN; break ;;
            2) function_OpenVPN; break ;;
    		3) docker_to_sudo; break ;;
            4) reset_default; break ;;
            5) exit ;;
            *) echo "That's not a possible choice?" >&2
        esac
    done

    echo "Do you want to perform another action?"
    select opt in "Yes" "No"; do
        case $REPLY in
            1) break ;;
            2) break 2;;
            *) echo "That's not a possible choice?" >&2
        esac
    done
done
