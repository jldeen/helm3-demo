#!/bin/bash

# Setup Nginx Ingress controller
h3 upgrade --install nginx-ingress stable/nginx-ingress

# Setup Certificate Manger
##optional
kubectl apply \
    -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.8/deploy/manifests/00-crds.yaml

#add jetstack repo
h3 repo add jetstack https://charts.jetstack.io

#change namespace for temp broken --namespace flag
#kubens and kubectx repo - https://github.com/ahmetb/kubectx | command: brew install kubectx
kubens kube-system
h3 upgrade --install cert-mgr jetstack/cert-manager

# Setup Certificate Cluster Issuer
kubectl apply -f cluster-issuer.yaml

# Test configuration - Demo!
h3 upgrade jenkins --install --namespace kubecon -f ./jenkins-values-demo.yaml stable/jenkins