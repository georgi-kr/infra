#!/usr/bin/env bash
#
# Setup a project with berglas and tokens
#
# Usage:
# scripts/init-project.sh -p <<project name>> -t <<aiven token>>

set -e

while getopts ":p:t:" opt; do
  case ${opt} in
    t ) AIVEN_TOKEN=$OPTARG
      ;;
    p ) PROJECT=$OPTARG
      ;;
    \? )
      echo "Invalid option: $OPTARG" 1>&2
      ;;
    : )
      echo "Invalid option: $OPTARG requires an argument" 1>&2
      ;;
  esac
done
shift $((OPTIND -1))

echo "Setting up berglas"
berglas bootstrap \
  --project $PROJECT \
  --bucket $PROJECT-berglas \
  --bucket-location us-west1-a \
  --kms-key berglas-key \
  --kms-keyring berglas \
  --kms-location us-west1-a

echo "Creating tf-state bucket"
gsutil mb -b on -l us-west1-a gs://$PROJECT-tf-state
