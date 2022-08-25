#!/bin/sh

## NOTES ##

## 1 - Download/install gcloud on your machine - based in your OS:
## https://cloud.google.com/sdk/docs/install

## 2 - After installation, initialize gcloud CLI:

## ENVS ##
YOUR_GCP_ACCOUNT="leonardosete@gmail.com"
REGION="us-central1"
PROJECT_ID="tembici-sre"
CONFIG_NAME="tembici-devops-sre"

## RUN ##

gcloud init
gcloud components update --quiet
gcloud auth login $YOUR_GCP_ACCOUNT

# gcloud config configurations create $CONFIG_NAME
# gcloud config configurations activate $CONFIG_NAME

# CLOUDSDK_CORE_PROJECT=$PROJECT_ID

# CLOUDSDK_COMPUTE_ZONE=[YOUR_ZONE_NAME]

# gcloud config set project $PROJECT_ID

# gcloud config set account $YOUR_GCP_ACCOUNT

# gcloud auth list

# gcloud services list --enabled --project $PROJECT_ID
