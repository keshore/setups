#!/bin/bash

install_fn() {
    echo "Installing microk8s"
    which microk8s 2>/dev/null || {
        sudo snap install microk8s --classic --channel=1.28
        sudo usermod -a -G microk8s $USER
        mkdir $HOME/.kube
        sudo chown -R $USER ~/.kube
        microk8s config > ~/.kube/config
        chmod 600 ~/.kube/config
        microk8s enable hostpath-storage
    }
}

uninstall_fn() {
    echo "Uninstalling microk8s"
    sudo snap remove microk8s
}

cd $(dirname $0)

source lib.sh

setup $@