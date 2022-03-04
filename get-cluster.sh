#!/bin/bash

function get_service_cluster() {
  venture=$1

  case $venture in
    dafiti1|dafiti3)
      echo "sc-cluster-dafiti1-service-live"
      ;;
    *)
      echo "sc-cluster-$venture-service-live"
      ;;
  esac
}

function get_classic_cluster() {
  venture=$1
  env=$2

  case $1 in
    dafiti1|dafiti3)
      echo "sc-cluster-${venture}use1-$env"
      ;;
    *)
      echo "sc-cluster-$venture-$env"
      ;;
  esac
}

function get_cluster_shortname() {
  venture=$1
  case $venture in
    dafiti1|dafiti3)
      echo "${venture}use1"
      ;;
    *)
      echo $venture
      ;;
  esac
}