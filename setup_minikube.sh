#!/bin/bash

install_fn() {
    echo "Installing minikube"
    which minikube 2>/dev/null || {
        curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
        sudo install minikube-linux-amd64 /usr/local/bin/minikube
        rm -rf minikube-linux-amd64
    }
}

uninstall_fn() {
    echo "Uninstalling minikube"
    minikube delete --all=true --purge=true
    sudo rm -rf /usr/local/bin/minikube
}

cd $(dirname $0)

source lib.sh

setup $@