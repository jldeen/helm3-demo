#!/bin/bash
set -eou pipefail
source ./scripts/variables.sh

# set az sub
# az account set --subcription $(azSub)

# create rg
az group create -n $(rg) -l $(location)

# create aks cluster
az aks create \
--resource-group $(rg) \
--name $(clustername) \
--node-count $(nodecount) \
--enable-addons monitoring,http_application_routing \
--generate-ssh-keys \
--kubernetes-version 1.13.5


# get creds
az aks get-credentials \
-n $(clustername) \
-g $(rg)