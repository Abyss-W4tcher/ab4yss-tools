#!/bin/bash
# AUTHOR : Abyss Watcher

# Global vars

Help() {
    # Display Help
    echo "Volatility quick install"
    echo
    echo "Syntax: vol_install.sh [option(s)]"
    echo "options:"
    echo "vol2_local     Install latest volatility2 github master on the system"
    echo "vol3_local     Install latest volatility3 github master on the system"
    echo "vol2_docker    Setup volatility2 docker image. Use /a/\$(readlink -f {{filename}}) for -f argument when using vol2 after install."
    echo "vol3_docker    Setup volatility3 docker image. Use /a/\$(readlink -f {{filename}}) for -f argument when using vol3 after install."
}

add_alias() {

    check=false
    if [ -f "$HOME/.zshrc" ]; then
        echo "alias $1" >>$HOME/.zshrc
        check=true
    fi
    if [ -f "$HOME/.bashrc" ]; then
        echo "alias $1" >>$HOME/.bashrc
        check=true
    fi
    if [ ! "$check" ]; then
        echo "Shell is neither 'bash' nor 'zsh'."
        exit
    fi

}

check_install() {

    if [ $1 -eq 0 ]; then
        echo "Done installing $2 !"
    else
        echo "Failed installing $2 (check errors) !"
        exit
    fi
}

# https://github.com/volatilityfoundation/volatility/wiki/Installation#dependencies
vol2_local() {

    echo 'Installing volatility2 from https://github.com/volatilityfoundation/volatility.git...'
    command='
        sudo apt install build-essential autoconf dwarfdump git subversion pcregrep 
        sudo apt install libpcre++-dev -y || sudo apt install libpcre3-dev -y &&
        sudo apt install python2-dev -y || sudo apt install python-dev -y && 
        wget https://bootstrap.pypa.io/pip/2.7/get-pip.py -P /tmp &&
        python2 /tmp/get-pip.py &&
        rm /tmp/get-pip.py &&
        pip2 install setuptools --upgrade &&
        pip2 install distorm3 yara-python pycryptodome pillow openpyxl ujson &&
        sudo git clone https://github.com/volatilityfoundation/volatility.git /opt/volatility &&
        sudo chown -R $USER:$USER /opt/volatility/'
    eval $command
    check_install $? 'local volatility2'
    add_alias "vol2='python2 /opt/volatility/vol.py'"

}

vol3_local() {

    echo 'Installing volatility3 from https://github.com/volatilityfoundation/volatility3.git...'
    command='
        sudo apt install python3 python3-pip libsnappy-dev -y &&
        sudo git clone https://github.com/volatilityfoundation/volatility3.git /opt/volatility3 &&
        sudo chown -R $USER:$USER /opt/volatility3/ &&
        pip3 install -r /opt/volatility3/requirements.txt'
    eval $command
    check_install $? 'local volatility3'
    add_alias "vol3='python3 /opt/volatility3/vol.py'"

}

vol2_docker() {

    echo 'Setup volatility2 docker from https://hub.docker.com/r/sk4la/volatility...'
    command='
        sudo apt install docker.io -y &&
        sudo docker pull sk4la/volatility'
    eval $command
    check_install $? 'docker volatility2'
    add_alias "vol2d='docker run --rm -v /:/a sk4la/volatility'"

}

vol3_docker() {

    echo 'Setup volatility3 docker from https://hub.docker.com/r/sk4la/volatility...'
    command='
        sudo apt install docker.io -y &&
        sudo docker pull sk4la/volatility3'
    eval $command
    check_install $? 'docker volatility3'
    add_alias "vol3d='docker run --rm -v /:/a sk4la/volatility3'"

}

messages=()
for arg; do
    if [ "$arg" == "help" ]; then
        Help
        exit
    fi
    if [ "$arg" == "vol2_local" ]; then
        vol2_local
        messages+=('Run local volatility2 command with : "vol2"')
    fi
    if [ "$arg" == "vol3_local" ]; then
        vol3_local
        messages+=('Run local volatility3 command with : "vol3"')
    fi
    if [ "$arg" == "vol2_docker" ]; then
        vol2_docker
        messages+=('Run volatility2 docker command with : "vol2d"')
    fi
    if [ "$arg" == "vol3_docker" ]; then
        vol3_docker
        messages+=('Run volatility3 docker command with : "vol3d"')
    fi
done

if ((${#messages[@]})); then
    echo -e "\n-----------------------------------\n"
    for message in "${messages[@]}"; do
        echo -e "$message"
    done
    echo -e "\n-----------------------------------\n"
    echo "You can now run \"exec \$SHELL\" to reload the shell and get the commands ready !"
else
    Help
fi
