#!/bin/bash
set -eou pipefail

#set helm version
helmVersion=helm-v3.0.0-alpha.1-darwin-amd64.tar.gz

#download helm version
wget https://get.helm.sh/$helmVersion
tar xvzf $helmVersion

#mv helm3 binary to local tmp folder
mkdir /usr/local/bin/tmp
mv darwin-amd64/helm /usr/local/bin/tmp/helm

#set temp alias
h3=/usr/local/bin/tmp/helm

#add alias to .zshrc or .bashrc
#set helm home to local tmp folder, to not overwrite your helm2 ~/.helm
echo "alias h3=/usr/local/bin/tmp/helm --home /usr/local/bin/tmp/.helm" >> ~/.zshrc
echo "alias h3=/usr/local/bin/tmp/helm --home /usr/local/bin/tmp/.helm" >> ~/.bashrc
# echo "alias h3=/usr/local/bin/tmp/helm" >> ~/.bashrc

