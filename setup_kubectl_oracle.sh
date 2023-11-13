#!/bin/bash


build_image() {

    which podman 2>/dev/null || {
        echo "Missing podman. please install" && exit 1
    }

    which microk8s 2>/dev/null || {
        echo "Missing microk8s. please install" && exit 1
    }

    which git 2>/dev/null || {
        echo "Missing git. please install" && exit 1
    }

    if [ $(microk8s ctr image ls | grep "^localhost/oracle/database:ext" | wc -l) -lt 1 ]; then
        DIR=/tmp/$$
        mkdir ${DIR} && cd ${DIR}
        git clone https://github.com/oracle/docker-images.git
        cd ${DIR}/docker-images/OracleDatabase/SingleInstance/dockerfiles
        ./buildContainerImage.sh -v 21.3.0 -
        cd ${DIR}/docker-images/OracleDatabase/SingleInstance/extensions
        ./buildExtensions.sh -x k8s -b localhost/oracle/database:21.3.0-xe
        podman image rm container-registry.oracle.com/os/oraclelinux:7-slim
        podman image rm localhost/oracle/database:21.3.0-xe
        podman image rm localhost/oracle/database:21.3.0-xe-base
        podman image save localhost/oracle/database:ext > oracle.tar
        podman image rm localhost/oracle/database:ext
        microk8s ctr image import oracle.tar
        rm ${DIR}
    fi
    microk8s ctr image ls | grep "^localhost/oracle/database:ext"
}

install_fn() {
    echo "Installing kube oracle"
    build_image
    which kubectl 2>/dev/null || {
        echo "Missing kubectl. please install" && exit 1
    }
    kubectl apply -f - <<EOF
apiVersion: v1
kind: Namespace
metadata:
  name: oracle
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: myoracle-db
  namespace: oracle
  labels:
    app: myoracle-db
spec:
  storageClassName: "microk8s-hostpath"
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: "10Gi"
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myoracle-db
  namespace: oracle
  labels:
    app: myoracle-db
spec:
  replicas: 1
  selector:
    matchLabels:
      app: myoracle-db
  template:
    metadata:
      labels:
        app: myoracle-db
    spec:
      containers:
        - name: oracle-db
          image: localhost/oracle/database:ext
          imagePullPolicy: "IfNotPresent"
          command: ["bash"]
          args: ["/opt/oracle/runOracle.sh"]
          volumeMounts:
            - mountPath: /opt/oracle/oradata
              name: datamount          
          env:
            - name: SVC_HOST
              value: "myoracle-db"
            - name: SVC_PORT
              value: "1521"
            - name: ORACLE_SID
              value: "XE"
            - name: ORACLE_PDB
              value: "ORCLPDB1"
            - name: ORACLE_PWD
              value: "admin"
            - name: ORACLE_CHARACTERSET
              value: "AL32UTF8"
            - name: ORACLE_EDITION
              value: "express"
            - name: ENABLE_ARCHIVELOG
              value: "false"
      volumes:
        - name: datamount
          persistentVolumeClaim:
            claimName: myoracle-db
---
apiVersion: v1
kind: Service
metadata:
  name: myoracle-db
  namespace: oracle
  labels:
    app: myoracle-db
spec:
  type: NodePort
  ports:
  - name: listener
    port: 1521
    protocol: TCP
    nodePort: 31001
  - name: xmldb
    port: 5500
    protocol: TCP
    nodePort: 31002
  selector:
    app: myoracle-db
EOF

cat <<-EOF
If the container is getting created for the first time, please exec into pod and run setPassword.sh \$ORACLE_PWD
EOF

kubectl -n oracle scale deployment myoracle-db --replicas=0
sleep 10
kubectl -n oracle scale deployment myoracle-db --replicas=1
}

uninstall_fn() {
    echo "Uninstalling kube oracle"
    kubectl delete ns/oracle
}

cd $(dirname $0)

source lib.sh

setup $@