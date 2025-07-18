#!/bin/bash

# Get all services and their namespaces
kubectl get svc --all-namespaces -o json | jq -r '.items[] | [.metadata.namespace, .metadata.name] | @tsv' | while read namespace svcname; do
  echo "=== Service: $svcname (Namespace: $namespace) ==="
  kubectl describe svc $svcname -n $namespace
  kubectl get endpoints $svcname -n $namespace
  kubectl get pods -n $namespace -o wide
  echo "Testing connectivity from inside the cluster:"
  kubectl run curl-$svcname --image=curlimages/curl -it --rm --restart=Never -- curl http://$svcname.$namespace.svc.cluster.local || true
  echo
done

# Get all ingresses and their namespaces
kubectl get ingress --all-namespaces -o json | jq -r '.items[] | [.metadata.namespace, .metadata.name] | @tsv' | while read namespace ingname; do
  echo "=== Ingress: $ingname (Namespace: $namespace) ==="
  kubectl describe ingress $ingname -n $namespace
  echo
done