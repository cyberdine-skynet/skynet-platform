#!/bin/bash
# Traefik Dashboard Access Script
# This script port-forwards the Traefik dashboard to your local machine

echo "🚀 Starting Traefik Dashboard Port-Forward..."
echo "📡 Dashboard will be available at: http://localhost:8080"
echo "🛑 Press Ctrl+C to stop"
echo ""

kubectl port-forward -n traefik-system svc/traefik 8080:9000
