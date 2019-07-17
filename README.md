# Helm 3 Demo Repo

This demo has been shown at:
- Kubecon EU 2019
- OSCON 2019

## In this repo you will find
Install scripts for:
- [AKS](scripts/setup-aks.sh)
    - Be sure to update the [variables file](scripts/variables.sh) with variables specific to your environment.
- [Helm 3](scripts/setup-helm3.sh) with $HELM_HOME set to /tmp/helm3
    - Tested on macOS 10.14 and 10.15
- [Demo note commands](helm.sh)
- [Jenkins Values File used in Demo](jenkins-values-demo.yaml)
- [cluster-issuer.yaml](cluster-issuer.yaml)
