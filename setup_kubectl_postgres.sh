#!/bin/bash

install_fn() {
    echo "Installing kube postgres"
    which kubectl 2>/dev/null || {
        echo "Missing kubectl. please install" && exit 1
    }
    kubectl apply -f - <<EOF
apiVersion: v1
kind: Namespace
metadata:
  name: postgres
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: postgres-pv-claim
  namespace: postgres
  labels:
    app: postgres
spec:
  storageClassName: "microk8s-hostpath"
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: "10Gi"
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: postgres-config
  namespace: postgres
  labels:
    app: postgres
data:
  POSTGRES_DB: postgresdb
  POSTGRES_USER: admin
  POSTGRES_PASSWORD: test123
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: postgres
  namespace: postgres
spec:
  replicas: 1
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
        - name: postgres
          image: postgres:16
          imagePullPolicy: "IfNotPresent"
          envFrom:
            - configMapRef:
                name: postgres-config
          volumeMounts:
            - mountPath: /var/lib/postgresql/data
              name: postgredb
      volumes:
        - name: postgredb
          persistentVolumeClaim:
            claimName: postgres-pv-claim
---
apiVersion: v1
kind: Service
metadata:
  name: postgres
  namespace: postgres
  labels:
    app: postgres
spec:
  type: NodePort
  ports:
  - name: listener
    port: 5432
    protocol: TCP
    nodePort: 30001
  selector:
   app: postgres
EOF

}

uninstall_fn() {
    echo "Uninstalling kube postgres"
    kubectl delete ns/postgres
}

cd $(dirname $0)

source lib.sh

setup $@