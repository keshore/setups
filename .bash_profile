#!/bin/bash

function remove_unused_microk8s_image() {
    microk8s ctr images ls | grep -E "^sha|@sha" | awk '{print $1}' | xargs -I {} microk8s ctr image rm {}
}

export PS1='\[\e]0;[$(date "+%Y%m%d %H:%M:%S")] \u@\h: \w\a\]${debian_chroot:+($debian_chroot)}\[\033[01;32m\][$(date "+%Y%m%d %H:%M:%S")] \u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

which kubectl >/dev/null 2>&1 && {
    [ ! -f ~/.kube/kubectl_completion.sh ] && kubectl completion bash > ~/.kube/kubectl_completion.sh
    source ~/.kube/kubectl_completion.sh
}

which helm >/dev/null 2>&1 && {
    [ ! -f ~/.kube/helm_completion.sh ] && helm completion bash > ~/.kube/helm_completion.sh
    source ~/.kube/helm_completion.sh
}

