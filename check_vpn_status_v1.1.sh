#!/bin/bash
clear
while true; do
    clear
	echo -e "\e[93m\e[104m################################################################################\e[0m"
	echo -e "\e[104m\e[93m#\e[0m\e[104m  By using this script you can get status information from your               \e[93m#\e[0m"       
	echo -e "\e[104m\e[93m#\e[0m\e[104m  installed VPN docker containers. If a specific container is                 \e[93m#\e[0m"
	echo -e "\e[104m\e[93m#\e[0m\e[104m  not installed, you'll get an error message.                                 \e[93m#\e[0m"
	echo -e "\e[93m\e[104m################################################################################\e[0m"
    
    options=("IPSec Logs" "IPSec Status" "IPSec Traffic" "OpenVPN Logs" "OpenVPN container version" "OpenVPN image version" "Quit")

    echo "Which actions do you want to perform?"
    echo "Choose an option:"
    select opt in "${options[@]}"; do
        case $REPLY in
            1) docker logs ipsec-vpn-server; break ;;
            2) docker exec -it ipsec-vpn-server ipsec status; break ;;
            3) docker exec -it ipsec-vpn-server ipsec whack --trafficstatus; break ;; 
			4) docker logs openvpn-as; break;;
			5) docker inspect -f '{{ index .Config.Labels "build_version" }}' openvpn-as; break ;;
            6) docker inspect -f '{{ index .Config.Labels "build_version" }}' linuxserver/openvpn-as; break ;;
            7) exit ;;
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
