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

#helm 2 still installed
helm version

#helm3-alpha1 alias
h3 version

#helm3-alpha1 list releases
h3 ls

#quick change namespace
kubens kube-system

#quick change namespace
kubens kubecon

#quick change namespace
kubens default

# Test configuration - Demo!
h3 upgrade jenkins --install --namespace kubecon-live -f ./jenkins-values-demo.yaml stable/jenkins

#command to get admin password
#update these parameters
namespace=default
helmReleaseName=jenkins

printf $(kubectl get secret --namespace $namespace $helmReleaseName -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode);echo
