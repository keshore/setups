#!/bin/bash

install_fn() {
    echo "Installing Podman"
    which podman 2>/dev/null || {
        sudo apt-get -y install podman
    }
}

uninstall_fn() {
    echo "Uninstalling Podman"
    sudo apt-get purge podman
    sudo apt-get autoremove
}

cd $(dirname $0)

source lib.sh

setup $@