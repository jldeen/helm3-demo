#!/bin/bash
set -eou pipefail

#set helm version
helmVersion=helm-v3.0.0-beta.3-darwin-amd64.tar.gz

#download helm version
wget https://get.helm.sh/$helmVersion
tar xvzf $helmVersion

#mv helm3 binary to local tmp folder
if [[ -e /usr/local/bin/tmp ]] ; then echo "tmp folder already exists" ; else mkdir /usr/local/bin/tmp ; fi
mv darwin-amd64/helm /usr/local/bin/tmp/helm

#TEMPORARY export $HELM_HOME so you don't overwrite Helm2 ~/.helm/
export HELM_HOME=/tmp/helm3

#set temp alias
h3=/usr/local/bin/tmp/helm

#add alias to .zshrc or .bashrc
echo "alias h3=/usr/local/bin/tmp/helm" >> ~/.zshrc
# echo "alias h3=/usr/local/bin/tmp/helm" >> ~/.bashrc

# cleanup
rm -rf $helmVersion
rm -rf darwin-amd64

