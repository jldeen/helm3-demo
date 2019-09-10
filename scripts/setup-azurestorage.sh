#!/bin/bash
set -eou pipefail
source ./scripts/variables.sh

az group create -n $(rg) -l $(location)

az storage account create \
-n $(blobStoreName)         \
-g $(rg)                  \
-l $(location)            \
--sku Standard_LRS        \
--kind BlobStorage        \
--access-tier Cool
# access-tier accepted values: Hot - Optimized for storing data that is accessed frequently. #Cool - Optimized for storing data that is infrequently accessed and stored for at least 30 days.

export AZURE_STORAGE_ACCOUNT=$(blobStoreName)
export AZURE_STORAGE_KEY=$(az storage account keys list --resource-group $(rg) --account-name $(blobStoreName) | grep -m 1 value | awk -F'"' '{print $4}')

# create container
az storage container create \
--name helm                 \
--public-access blob

h3 repo index --url https://$(blobStoreName).blob.core.windows.net/helm/ .

h3 package charts/<chart-name>

h3 repo add jdcharts https://$(blobStoreName).blob.core.windows.net/helm/

h3 repo list

# h3 repo index . 
# h3 package .

# az storage blob upload --container-name helm --file $file_to_upload --name $blob_name