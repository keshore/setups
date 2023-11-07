#!/bin/bash

install_fn() {
    echo "Installing kubectl"
    which kubectl 2>/dev/null || {
        curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
        sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    }
}

uninstall_fn() {
    echo "Uninstalling kubectl"
    sudo rm -f /usr/local/bin/kubectl
}

cd $(dirname $0)

source lib.sh

setup $@