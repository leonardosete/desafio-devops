#!/bin/sh

################
## ENV COLOR####
################
RED='\033[0;31m'
NC='\033[0m' # No Color

########################
## INTERACTIVE SCRIPT ##
########################

echo "### First things first! ###"
echo " "
echo "### You need to install the gcloud CLI: ###"
echo " "
echo "### ${RED}Click/open the link: https://cloud.google.com/sdk/docs/install${NC} ###"
echo " "
echo "### After installation, awswer ${RED}"y or Y"${NC} to proceed: ###"
echo " "
echo "### If you do not install gcloud CLI, this script will not run properly! ###"

########################
## INTERACTIVE SCRIPT ##
########################

read -p "Did install the gcloud CLI (y/n)? " answer
case ${answer:0:1} in
    y|Y )
        echo Yes
    ;;
    * )
        echo No
    ;;
esac

#########################
## DEFINE DYNAMIC ENVS ##
#########################
echo " "
echo "### Please, define some inputs variables about the GCP ###"
echo " "
echo "### Default: ${RED}tembici-desafio-devops-1${NC} ###"
read -p "Your default PROJECT_ID is: " PROJECT_ID
echo " "
echo "### Default: ${RED}leonardosete@gmail.com${NC} ###"
read -p "YOUR_GCP_ACCOUNT is: " YOUR_GCP_ACCOUNT
echo " "
echo "### Must be different than: ${RED}tembici-desafio-devops-8${NC} ###"
read -p "The NEW_PROJECT_ID to be created is: " NEW_PROJECT_ID

#################
## STATIC ENVS ##
#################

SVC_DESCRIPTION="Terraform Service Account" ## Service Account Description
LIST_ROLES=`cat ./roles-svc-account.md` ## A list of the needed roles to be added to the new Service Account
KEY_FILE="./svc-$NEW_PROJECT_ID-private-key.json" ## The key/json file to be created to the Service Account
SERVICE_ACCOUNT_ID="terraform-svc-account" ## The new Service Account to be created to run Terraform

######################
## GCLOUD EXECUTION ##
######################

############################
## Auth and Config gcloud ##
############################
    echo " "
    echo "### ${RED}Auth and Config gcloud${NC} ###"
    echo " "
    gcloud components update --quiet
    gcloud auth login --account $YOUR_GCP_ACCOUNT
    gcloud config set project $PROJECT_ID
    gcloud config set account $YOUR_GCP_ACCOUNT

########################
## Create New Project ##
########################

    echo " "
    echo "### ${RED}Create New Project${NC} ###"
    echo " "
    gcloud projects create $NEW_PROJECT_ID
    gcloud config set project $NEW_PROJECT_ID
    gcloud config set account $YOUR_GCP_ACCOUNT


############################
## Create Service Account ##
############################

    echo " "
    echo "### ${RED}Create Service Account${NC} ###"
    echo " "
    gcloud iam service-accounts create $SERVICE_ACCOUNT_ID \
        --description="$SVC_DESCRIPTION" \
        --display-name="$SERVICE_ACCOUNT_ID"


###################################
## Create Key to Service Account ##
###################################

    echo " "
    echo "### ${RED}Create Key to Service Account${NC} ###"
    echo " "
    gcloud iam service-accounts keys create $KEY_FILE \
        --iam-account="$SERVICE_ACCOUNT_ID@$NEW_PROJECT_ID.iam.gserviceaccount.com"

###################################
## Add roles in Service Account ##
###################################

    echo " "
    echo "### ${RED}Add roles in Service Account${NC} ###"
    echo " "

for ROLES in $LIST_ROLES
    do gcloud projects add-iam-policy-binding $NEW_PROJECT_ID --member="serviceAccount:$SERVICE_ACCOUNT_ID@$NEW_PROJECT_ID.iam.gserviceaccount.com" --role="roles/$ROLES"
done

###################################
## Check Service Account Details ##
###################################

    echo " "
    echo "### ${RED}Check Service Account Details${NC} ###"
    echo " "
    gcloud iam service-accounts describe $SERVICE_ACCOUNT_ID@$NEW_PROJECT_ID.iam.gserviceaccount.com
    echo " "
    echo " "
    gcloud iam service-accounts list

###################
## END OF SCRIPT ##
###################

