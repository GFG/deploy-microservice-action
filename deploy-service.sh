#!/bin/bash

name=$1
github_sha=$2
venture=$3
env=$4
flavor=$5

source ./kubeconfig.sh
source ./get-cluster.sh

set -e

cluster=`get_service_cluster $venture`
shortcluster=`get_cluster_shortname $venture`
kubeconfig=`get_kubeconfig $venture $cluster`
namespace=$name-$env
value_file=$GITHUB_WORKSPACE/values/$env/$venture.yaml

pushd $GITHUB_WORKSPACE > /dev/null

echo "::notice::Deploying $name on $cluster [$venture/$env]"
if [[ ! -f "$value_file" ]]; then
  echo "::warning::Skipping deployment, value file doesn't exist"
  exit 0
fi


helm upgrade \
  --install \
  --debug \
  --kubeconfig $kubeconfig \
  -f $value_file \
  $name \
  --namespace $namespace \
  --create-namespace \
  ./chart \
  --set venture=$venture,cluster=$shortcluster,environment=$env,imageTag=$tag > /tmp/deploy.log

if [ $? -ne 0 ]; then
  echo "::error::Error when deploying $name on $cluster [$venture/$env]"
  cat /tmp/deploy.log
  exit 1
fi

popd > /dev/null
set +e
