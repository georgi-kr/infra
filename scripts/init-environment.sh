#!/usr/bin/env bash
#
# Setup a separate environment for an already established project (with ./init-project.sh)
#
# Usage:
# scripts/init-environment.sh -p <<project name>> -e <<environment name>>

print_usage() {
  echo "Usage: ./init-environment.sh -p [prod|nonprod] -e envname"
}

set -e

while getopts ":p:e:" opt; do
  case ${opt} in
    e ) ENVIRONMENT=$OPTARG
      ;;
    p ) PROJECT=$OPTARG
      ;;
    \? )
      echo "Invalid option: $OPTARG" 1>&2
      print_usage
      exit 1
      ;;
    : )
      echo "Invalid option: $OPTARG requires an argument" 1>&2
      print_usage
      exit 1
      ;;
  esac
done
shift $((OPTIND -1))

echo "Setting up berglas"
berglas bootstrap \
  --project $PROJECT \
  --bucket $PROJECT-$ENVIRONMENT-berglas \
  --bucket-location europe-west1 \
  --kms-key berglas-key-$ENVIRONMENT \
  --kms-keyring berglas \
  --kms-location europe-west1
