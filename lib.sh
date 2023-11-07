#!/bin/bash


setup() {
    case $(echo $1 | tr '[a-z]' '[A-Z]') in
        "I")
            install_fn
        ;;
        "U")
            uninstall_fn
        ;;
        *)
            echo "Error: Unknown Option '$1'. Usage: $(basename $0) [i/u]"
        ;;
    esac
}


if [ $(cat /etc/os-release | grep Ubuntu | wc -l ) -lt 1 ]; then
    echo "Error: Only Ubuntu OS is supported"
    exit 1
fi