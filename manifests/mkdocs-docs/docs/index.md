# Skynet Platform Documentation

Welcome to the Skynet Platform - a complete GitOps infrastructure platform built on Kubernetes, Talos, and ArgoCD.

## Overview

Skynet Platform provides a production-ready Kubernetes infrastructure with automated deployment, monitoring, and
scaling capabilities. Built following GitOps principles, everything is defined as code and managed through version
control.

## Quick Start

- **Developers**: Start with the [Developer Guide](developer/getting-started.md) to learn how to deploy applications
- **Operators**: Check the [Operations Guide](operations/commands.md) for platform management
- **Architects**: Review the [Architecture Overview](architecture/overview.md)

## Key Features

- **GitOps Workflow**: Everything is version controlled and automatically deployed
- **Secure by Default**: Built-in security policies and automated certificate management
- **Highly Available**: Multi-node setup with load balancing and failover
- **Monitoring & Observability**: Comprehensive monitoring and alerting
- **Developer Friendly**: Simple application deployment process

## Platform Components

The platform includes these core components:

- **Kubernetes**: Container orchestration with Talos OS
- **ArgoCD**: GitOps continuous deployment
- **Traefik**: Ingress controller and load balancer
- **cert-manager**: Automated SSL certificate management
- **MetalLB**: Bare metal load balancer

## Getting Help

If you need assistance:

1. Check the [Troubleshooting Guide](operations/troubleshooting.md)
2. Review the [Command Reference](operations/commands.md)
3. Consult the [Best Practices](developer/best-practices.md)

---

*This documentation is automatically built and deployed using MkDocs Material in our GitOps pipeline.*
# MkDocs Pipeline Test - Thu Jul 17 13:20:06 CEST 2025
