#!/bin/bash

install_fn() {
    echo "Installing jdk"
    which java 2>/dev/null || {
        cd $HOME
        curl https://download.oracle.com/java/21/latest/jdk-21_linux-x64_bin.tar.gz | tar -xz
        mv $HOME/jdk-21.0.1 $HOME/java
        echo "export PATH='\$PATH':$HOME/java/bin" >> $HOME/.bash_profile
    }
}

uninstall_fn() {
    echo "Uninstalling jdk"
    rm -rf $HOME/java
}

cd $(dirname $0)

source lib.sh

setup $@