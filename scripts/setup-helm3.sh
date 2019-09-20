#!/bin/bash
set -eou pipefail

#set helm version
# MacOS
#helmVersion=helm-v3.0.0-beta.3-darwin-amd64.tar.gz
# Linux 64bit
helmVersion=helm-v3.0.0-beta.3-linux-amd64.tar.gz

#download helm version
wget https://get.helm.sh/$helmVersion
tar xvzf $helmVersion

#mv helm3 binary to local tmp folder
if [[ -e /usr/local/bin/tmp ]] ; then
  echo "tmp folder already exists"
else
  sudo mkdir /usr/local/bin/tmp
fi


if [[ -e darwin-amd64 ]]; then
  sudo mv darwin-amd64/helm /usr/local/bin/tmp/helm
elif [[ -e linux-amd64 ]]; then
  sudo mv linux-amd64/helm /usr/local/bin/tmp/helm
fi

#TEMPORARY export $HELM_HOME so you don't overwrite Helm2 ~/.helm/
export HELM_HOME=/usr/local/bin/tmp/helm3

#set temp alias
h3=/usr/local/bin/tmp/helm

#add alias to .zshrc or .bashrc
if [[ -e ~/.zshrc ]]; then
  echo "alias h3=/usr/local/bin/tmp/helm" >> ~/.zshrc
  source ~/.zshrc
elif [[ -e ~/.bashrc ]]; then
  echo "alias h3=/usr/local/bin/tmp/helm" >> ~/.bashrc
  source ~/.bashrc
fi

# cleanup
rm -rf $helmVersion
if [[ -e darwin-amd64 ]]; then
  rm -rf darwin-amd64
elif [[ -e linux-amd64 ]]; then
  rm -rf linux-amd64
fi
