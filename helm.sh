#!/bin/bash

# update these variables
namespace=default
helmReleaseName=jenkins

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
# change namespace to kube-system
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

#helm3-alpha1 list all releases
h3 ls --all-namespaces

#quick change namespace back to default (get out of kube-system)
kubens default

# Test configuration - Demo!
h3 upgrade jenkins --install --namespace $namespace -f ./jenkins-values-demo.yaml stable/jenkins

# if using default namespace, the above will install to default regardless of which ns is specified with --namespace flag. --namespace flag currently is ignored, must change namespace first prior to helm chart install

kubens $namespace

# re-run helm 3 chart install

h3 upgrade jenkins --install --namespace $namespace -f ./jenkins-values-demo.yaml stable/jenkins

# get pods in specified namespace
kubectl get pods -n $namespace

#command to get admin password
printf $(kubectl get secret --namespace $namespace $helmReleaseName -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode);echo
