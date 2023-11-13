#!/bin/bash

install_fn() {
    echo "Installing kube postgres"
    which kubectl 2>/dev/null || {
        echo "Missing kubectl. please install" && exit 1
    }
    helm repo add bitnami https://charts.bitnami.com/bitnami
    cat > /tmp/$$ <<-EOF
    primary:
      extendedConfiguration: |-
        max_prepared_transactions = 64
EOF
    helm upgrade my-postgres bitnami/postgresql --namespace postgres --create-namespace -f /tmp/$$
    rm /tmp/$$
    kubectl apply -f - <<EOF
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
        app.kubernetes.io/component: primary
        app.kubernetes.io/instance: my-postgres
        app.kubernetes.io/name: postgresql
--
EOF

export POSTGRES_PASSWORD=$(kubectl get secret --namespace postgres my-postgres-postgresql -o jsonpath="{.data.postgres-password}" | base64 -d)

echo "POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}"
}

uninstall_fn() {
    echo "Uninstalling kube postgres"
    kubectl delete ns/postgres
}

cd $(dirname $0)

source lib.sh

setup $@

