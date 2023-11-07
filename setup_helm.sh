#!/bin/bash

install_fn() {
    echo "Installing helm"
    which helm 2>/dev/null || {
        curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
    }
}

uninstall_fn() {
    echo "Uninstalling helm"
    sudo rm -f /usr/local/bin/helm
}

cd $(dirname $0)

source lib.sh

setup $@