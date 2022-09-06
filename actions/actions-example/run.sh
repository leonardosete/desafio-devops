#!/bin/bash

# cd $WORKSPACE_APP

# APPLY_NAMESPACE="-n ${NAMESPACE_PREFIX}-${TARGET_ENV}"

# if [[ ! -z $NOT_APPLY_NAMESPACE_AKS && $NOT_APPLY_NAMESPACE_AKS == "true" ]]; then
#     APPLY_NAMESPACE=""
# fi

# echo "kubectl config set-context --current --namespace=default"
# kubectl config set-context --current --namespace=default || true

# echo "kubectl apply -f ${FILE_TO_APPLY} ${APPLY_NAMESPACE} ${PRUNE_PARAMETERS}"

# kubectl apply -f $FILE_TO_APPLY $APPLY_NAMESPACE $PRUNE_PARAMETERS
