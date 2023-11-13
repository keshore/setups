#!/bin/bash

install_fn() {
    echo "Installing ibmmq"
    which helm 2>/dev/null || {
        echo "Missing helm. please install" && exit 1
    }
    helm repo add ibm-messaging-mq https://ibm-messaging.github.io/mq-helm
    helm upgrade ibmmq ibm-messaging-mq/ibm-mq --set license=accept --namespace ibmmq --create-namespace

    kubectl apply -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: ibmmq-svc
  namespace: ibmmq
  labels:
    app.kubernetes.io/name: ibm-mq
    app.kubernetes.io/instance: ibmmq
spec:
  type: NodePort
  ports:
  - name: console-https
    port: 9443
    protocol: TCP
    nodePort: 32500
  - name: qmgr
    port: 1414
    protocol: TCP
    nodePort: 32501
  selector:
    app.kubernetes.io/instance: ibmmq
    app.kubernetes.io/name: ibm-mq
EOF
}

uninstall_fn() {
    echo "Uninstalling ibmmq"
    kubectl delete ns/ibmmq
}

cd $(dirname $0)

source lib.sh

setup $@