#!/bin/bash

set -e

echo "Creating Kubernetes secrets for the application..."

# check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "kubectl is not installed or not in PATH"
    exit 1
fi


create_secret_if_not_exists() {
    local secret_name=$1
    local namespace=${2:-default}
    
    if kubectl get secret "$secret_name" -n "$namespace" &> /dev/null; then
        echo "Secret $secret_name already exists in namespace $namespace"
    else
        echo "Creating secret $secret_name in namespace $namespace..."
        return 1
    fi
}

if ! create_secret_if_not_exists "app-secrets" "default"; then
    read -s -p "Enter application password: " APP_PASSWORD
    echo
    kubectl create secret generic app-secrets \
        --from-literal=password="$APP_PASSWORD" \
        --namespace=default
fi

kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

if ! create_secret_if_not_exists "grafana-admin-secret" "monitoring"; then
    read -s -p "Enter Grafana admin password: " GRAFANA_PASSWORD
    echo
    kubectl create secret generic grafana-admin-secret \
        --from-literal=username="admin" \
        --from-literal=password="$GRAFANA_PASSWORD" \
        --namespace=monitoring
fi

if ! create_secret_if_not_exists "smtp-secret" "monitoring"; then
    read -p "Enter SMTP username: " SMTP_USERNAME
    read -s -p "Enter SMTP password: " SMTP_PASSWORD
    echo
    kubectl create secret generic smtp-secret \
        --from-literal=username="$SMTP_USERNAME" \
        --from-literal=password="$SMTP_PASSWORD" \
        --namespace=monitoring
fi