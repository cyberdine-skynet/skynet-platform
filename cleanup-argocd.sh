#!/bin/bash

set -euo pipefail

NAMESPACE="argocd"

echo "🔄 Deleting all Argo CD Applications..."
kubectl delete applications --all -n $NAMESPACE || true

echo "🔄 Removing stuck finalizers from applications (if any)..."
for app in $(kubectl get applications -n $NAMESPACE -o jsonpath="{.items[*].metadata.name}"); do
  echo "  ➤ Patching finalizers on application: $app"
  kubectl patch application "$app" -n $NAMESPACE -p '{"metadata":{"finalizers":null}}' --type=merge || true
done

echo "📦 Deleting Argo CD namespace: $NAMESPACE"
kubectl delete namespace $NAMESPACE || true

echo "🧨 Deleting Argo CD CRDs..."
for crd in $(kubectl get crd | grep argoproj | awk '{print $1}'); do
  echo "  ➤ Deleting CRD: $crd"
  kubectl delete crd "$crd" || true
done

echo "🧹 Deleting Argo CD ClusterRoles..."
for role in $(kubectl get clusterrole | grep argocd | awk '{print $1}'); do
  echo "  ➤ Deleting ClusterRole: $role"
  kubectl delete clusterrole "$role" || true
done

echo "🧹 Deleting Argo CD ClusterRoleBindings..."
for binding in $(kubectl get clusterrolebinding | grep argocd | awk '{print $1}'); do
  echo "  ➤ Deleting ClusterRoleBinding: $binding"
  kubectl delete clusterrolebinding "$binding" || true
done

echo "✅ Argo CD fully removed."
