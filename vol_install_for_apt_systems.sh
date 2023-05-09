#!/bin/bash
# AUTHOR : Abyss Watcher

# Global vars

Help() {
    # Display Help
    echo ">>> Volatility easy install <<<"
    echo "Need to be run as root, for dependencies installation. Additional packages (sudo, wget...) may also be installed."
    echo "Syntax: vol_install.sh VOL_USER [option(s)]"
    echo "Specify the user which will be using volatility as first argument. For docker usage, 'docker' group needs to be part of the 'sudo' group (or run the container as root)."
    echo "options:"
    echo "vol2_local     Install latest volatility2 github master on the system"
    echo "vol3_local     Install latest volatility3 github master on the system"
    echo "vol2_docker    Setup volatility2 docker image. Use '/a/\$(readlink -f {{dumpfile}})' for volatility -f argument when using vol2 after install."
    echo "vol3_docker    Setup volatility3 docker image. Use '/a/\$(readlink -f {{dumpfile}})' for volatility -f argument when using vol3 after install."
}

add_alias() {

    check=false
    if [ -f "$VOL_USER_HOME/.zshrc" ]; then
        echo "alias $1" >>$VOL_USER_HOME/.zshrc
        check=true
    fi
    if [ -f "$VOL_USER_HOME/.bashrc" ]; then
        echo "alias $1" >>$VOL_USER_HOME/.bashrc
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
        apt install sudo build-essential autoconf dwarfdump git subversion pcregrep libssl-dev wget -y &&
        apt install libpcre++-dev -y || apt install libpcre3-dev -y &&
        apt install python2-dev -y || apt install python-dev -y && 
        wget https://bootstrap.pypa.io/pip/2.7/get-pip.py -P /tmp &&
        python2 /tmp/get-pip.py &&
        rm /tmp/get-pip.py &&
        sudo -u $VOL_USER pip2 install setuptools --upgrade &&
        sudo -u $VOL_USER pip2 install distorm3 yara-python pycryptodome pillow openpyxl ujson &&
        git clone https://github.com/volatilityfoundation/volatility.git /opt/volatility2 &&
        chown -R $VOL_USER:$VOL_USER /opt/volatility2/'
    eval $command
    check_install $? 'local volatility2'
    add_alias "vol2='python2 /opt/volatility2/vol.py'"

}

vol3_local() {

    echo 'Installing volatility3 from https://github.com/volatilityfoundation/volatility3.git...'
    command='
        apt install python3 python3-pip python3-dev libsnappy-dev git sudo -y &&
        git clone https://github.com/volatilityfoundation/volatility3.git /opt/volatility3 &&
        chown -R $VOL_USER:$VOL_USER /opt/volatility3/ &&
        sudo -u $VOL_USER pip3 install -r /opt/volatility3/requirements.txt'
    eval $command
    check_install $? 'local volatility3'
    add_alias "vol3='python3 /opt/volatility3/vol.py'"

}

vol2_docker() {

    echo 'Setup volatility2 docker from https://hub.docker.com/r/sk4la/volatility...'
    command='
        apt install docker.io -y &&
        docker pull sk4la/volatility'
    eval $command
    check_install $? 'docker volatility2'
    add_alias "vol2d='docker run --rm -v /:/a sk4la/volatility'"

}

vol3_docker() {

    echo 'Setup volatility3 docker from https://hub.docker.com/r/sk4la/volatility...'
    command='
        apt install docker.io -y &&
        docker pull sk4la/volatility3'
    eval $command
    check_install $? 'docker volatility3'
    add_alias "vol3d='docker run --rm -v /:/a sk4la/volatility3'"

}

if [ "$1" == "help" ] || [ "$1" == "" ]; then
    Help
    exit
fi

if ! id "$1"  > /dev/null 2>&1; then
        echo "User \"$1\" does not exist."
        exit
fi

VOL_USER=$1
VOL_USER_HOME="/home/$1"

messages=()
for arg in "${@:2}"; do
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
