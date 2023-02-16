#!/usr/bin/env bash
#
# Enable services for nonprod and prod

set -e

for PROJECT in nonprod prod
do
  gcloud services enable --project $PROJECT \
    dns.googleapis.com \
    compute.googleapis.com \
    container.googleapis.com \
    sqladmin.googleapis.com \
    servicenetworking.googleapis.com \
    vpcaccess.googleapis.com \
    run.googleapis.com \
    cloudbuild.googleapis.com \
    cloudresourcemanager.googleapis.com
done
