#!/bin/bash

SOURCE=`dirname ${BASH_SOURCE[0]}`

name=$1
github_sha=$2
venture=$3
env=$4
flavor=$5

source $SOURCE/kubeconfig.sh
source $SOURCE/get-cluster.sh

set -e

cluster=`get_classic_cluster $venture`
shortcluster=`get_cluster_shortname $venture`
kubeconfig=`get_kubeconfig $venture $cluster`
countries=`jq -r .$venture.countries $SOURCE/info.json`
namespace=$name

pushd $GITHUB_WORKSPACE > /dev/null

for country in $countries; do
    echo "::notice::Deploying $name on $cluster [$venture/$env/$country]"
    value_file=$GITHUB_WORKSPACE/values/$env/$venture/${country}.yaml

    if [[ ! -f "$value_file" ]]; then
      echo "::warning::Skipping deployment, value file doesn't exist"
      continue
    fi

    helm upgrade \
      --install \
      --debug \
      --kubeconfig $kubeconfig \
      -f $value_file \
      $name-$country \
      --namespace $namespace \
      --create-namespace \
      ./chart \
      --set cluster=$shortcluster,environment=$env,country=$country,imageTag=$tag > /tmp/deploy.log

    if [ $? -ne 0 ]; then
      echo "::error::Error when deploying $name on $cluster [$venture/$env/$country]"
      cat /tmp/deploy.log
      exit 1
    fi
  done
done

echo "::notice::Deploying $name on $cluster [$venture/$env]"


value_file=$GITHUB_WORKSPACE/values/$env/$venture.yaml


if [[ ! -f "$value_file" ]]; then
  echo "::warning::Skipping deployment, value file doesn't exist"
  exit 0
fi

namespace=$name-$env

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

