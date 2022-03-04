#!/bin/bash

SOURCE=`dirname ${BASH_SOURCE[0]}`

function get_kubeconfig() {
  venture=$1
  cluster=$2

  describe_role=`jq -r .$venture.role $SOURCE/info.json`
  region=`jq -r .$venture.region $SOURCE/info.json`
  role=arn:aws:iam::514755528584:role/sc-codebuild-role

  aws sts assume-role --role-arn $describe_role --role-session-name deploy > /tmp/credentials.json

  export AWS_ACCESS_KEY_ID=`jq -r .Credentials.AccessKeyId /tmp/credentials.json`
  export AWS_SECRET_ACCESS_KEY=`jq -r .Credentials.SecretAccessKey /tmp/credentials.json`
  export AWS_SESSION_TOKEN=`jq -r .Credentials.SessionToken /tmp/credentials.json`

  aws eks update-kubeconfig --region $region --name $cluster --role-arn=$role --kubeconfig /tmp/kubeconfig-$cluster

  unset AWS_ACCESS_KEY_ID
  unset AWS_SECRET_ACCESS_KEY
  unset AWS_SESSION_TOKEN

  rm /tmp/credentials.json
}