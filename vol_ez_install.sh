Help() {
    # Display Help
    echo ">>> Volatility easy install <<<"
    echo "Syntax: vol_ez_install.sh [option(s)]"
    echo "options:"
    echo "vol2_local     Setup latest volatility2 github master on the system"
    echo "vol3_local     Setup latest volatility3 github master on the system"
}

add_rc() {

    check=false
    if [ -f ~/.zshrc ]; then
        echo "$1" >>~/.zshrc
        check=true
    fi
    if [ -f ~/.bashrc ]; then
        echo "$1" >>~/.bashrc
        check=true
    fi
    if [ ! "$check" ]; then
        echo "Shell is neither 'bash' nor 'zsh'. Cannot add alias."
    fi

}

vol2_install() {

    echo 'volatility2 setup...'

    # Create directories
    mkdir -p ~/vol2/
    mkdir -p ~/vol2/custom_plugins
    # Fetch Dockerfile
    wget https://github.com/Abyss-W4tcher/ab4yss-tools/raw/master/volatility/Dockerfile-vol2 -P ~/vol2/
    # Build container
    docker build -t vol2_dck -f ~/vol2/Dockerfile-vol2 ~/vol2
    # Clone volatility2
    git clone https://github.com/volatilityfoundation/volatility.git ~/vol2/volatility2
    # Add aliases
    grep -q 'wvol' ~/.zshrc ~/.bashrc || add_rc 'wvol() { echo "/bind"$(readlink -f "$1"); }'
    grep -q 'vol2d' ~/.zshrc ~/.bashrc || add_rc 'alias vol2d="docker run --rm -v /:/bind/ vol2_dck python2 $(wvol ~/vol2/volatility2/vol.py)"'

    echo 'volatility2 setup completed !'
}

vol3_install() {

    echo 'volatility3 setup...'

    # Create directories
    mkdir -p ~/vol3/
    mkdir -p ~/vol3/custom_plugins
    # Fetch Dockerfile
    wget https://github.com/Abyss-W4tcher/ab4yss-tools/raw/master/volatility/Dockerfile-vol3 -P ~/vol3/
    # Build container
    docker build -t vol3_dck -f ~/vol3/Dockerfile-vol3 ~/vol3
    # Clone volatility2
    git clone https://github.com/volatilityfoundation/volatility3.git ~/vol3/volatility3
    # Add aliases
    grep -q 'wvol' ~/.zshrc ~/.bashrc || add_rc 'wvol() { echo "/bind"$(readlink -f "$1"); }'
    grep -q 'vol3d' ~/.zshrc ~/.bashrc || add_rc 'alias vol3d="docker run --rm -v /:/bind/ vol3_dck python3 $(wvol ~/vol3/volatility3/vol.py)"'

    echo 'volatility3 setup completed !'

}

install=false
for arg in "$@"; do
    if [ "$arg" == "vol2_install" ]; then
        vol2_install
        install=true
    fi
    if [ "$arg" == "vol3_install" ]; then
        vol3_install
        install=true
    fi
done

if [ "$install" ]; then
    echo "You can now run \"exec \$SHELL\" to reload the shell and get the commands ready !"
else
    Help
fi