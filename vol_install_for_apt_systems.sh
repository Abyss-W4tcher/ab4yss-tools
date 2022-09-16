#!/bin/bash
# AUTHOR : Abyss Watcher


# Global vars

  if [ ! -z ${ZSH_VERSION+x} ]; then
    rc_file="$HOME/.zshrc"
  elif [ ! -z ${BASH_VERSION+x} ]; then
    rc_file="$HOME/.bashrc"
  else
    echo "Shell is neither 'bash' nor 'zsh'. Try editing the 'rc_file' variable directly."
    exit
  fi


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

check_install() {
    if [ $1 -eq 0 ]; then
        echo "Done installing $2 !"
    else
        echo "Failed installing $2 (check errors) !"
        exit
    fi
}

vol2_local() {
    if ! grep -q 'vol2=' "$rc_file"; then
        echo 'Installing volatility2 from https://github.com/volatilityfoundation/volatility.git...'
        command='
        sudo apt-get install build-essential autoconf dwarfdump git subversion pcregrep libpcre++-dev python2-dev python-pip -y &&
        pip2 install distorm3 yara-python pycryptodome pillow openpyxl ujson &&
        mkdir -p $HOME/Tools &&
        cd $HOME/Tools &&
        git clone https://github.com/volatilityfoundation/volatility.git &&
        echo "alias vol2='"'"'python2 $HOME/Tools/volatility/vol.py'"'"'" >>'"$rc_file"
        eval $command
        check_install $? 'local volatility2'
    else
        echo "ERROR : volatility2 seems already installed on the system (presence of alias in $rc_file)"
    fi
}

vol3_local() {
    if ! grep -q 'vol3=' "$rc_file"; then
        echo 'Installing volatility3 from https://github.com/volatilityfoundation/volatility3.git...'
        command='
        sudo apt-get install python3-pip libsnappy-dev -y &&
        mkdir -p $HOME/Tools &&
        cd $HOME/Tools &&
        git clone https://github.com/volatilityfoundation/volatility3.git &&
        cd volatility3 &&
        pip3 install -r requirements.txt &&
        echo "alias vol3='"'"'python3 $HOME/Tools/volatility3/vol.py'"'"'" >>'"$rc_file"
        eval $command
        check_install $? 'local volatility3'
    else
        echo "ERROR : volatility3 seems already installed on the system (presence of alias in $rc_file)"
    fi
}

vol2_docker() {
    if ! grep -q 'vol2d=' "$rc_file"; then
        echo 'Setup volatility2 docker from https://hub.docker.com/r/sk4la/volatility...'
        command='
        sudo apt-get install docker.io -y &&
        sudo docker pull sk4la/volatility &&
        echo "alias vol2d='"'"'docker run --rm -v /:/a sk4la/volatility'"'"'" >>'"$rc_file"
        eval $command
        check_install $? 'docker volatility2'
    else
        echo "ERROR : volatility2 docker seems already present (presence of alias in $rc_file). Fetch latest with : \"docker pull sk4la/volatility\""
    fi
}

vol3_docker() {
    if ! grep -q 'vol3d=' "$rc_file"; then
        echo 'Setup volatility3 docker from https://hub.docker.com/r/sk4la/volatility...'
        command='
        sudo apt-get install docker.io -y &&
        sudo docker pull sk4la/volatility3 &&
        echo "alias vol3d='"'"'docker run --rm -v /:/a sk4la/volatility3'"'"'" >>'"$rc_file"
        eval $command
        check_install $? 'docker volatility3'
    else
        echo "ERROR : volatility3 docker seems already present (presence of alias in $rc_file). Fetch latest with : \"docker pull sk4la/volatility3\""
    fi
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
    echo "You can now run \"source $rc_file\" to reload the shell and get the commands ready !"
    else
    	Help
fi
