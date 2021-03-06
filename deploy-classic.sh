#!/bin/bash

SOURCE=`dirname ${BASH_SOURCE[0]}`

name=$1
github_sha=$2
venture=$3
env=$4

source $SOURCE/kubeconfig.sh
source $SOURCE/get-cluster.sh

set -e

cluster=`get_classic_cluster $venture $env`
shortcluster=`get_cluster_shortname $venture`
namespace=$name
countries=`jq -r .$venture.countries $SOURCE/info.json`

get_kubeconfig $venture $cluster

kubeconfig=/tmp/kubeconfig-$cluster

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
    --set cluster=$shortcluster,environment=$env,country=$country,imageTag=$github_sha > /tmp/deploy.log

  if [ $? -ne 0 ]; then
    echo "::error::Error when deploying $name on $cluster [$venture/$env/$country]"
    cat /tmp/deploy.log
    exit 1
  fi
done

popd > /dev/null
set +e
