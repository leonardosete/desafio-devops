#!/bin/sh

## The main goal of this script is: ##
## Creates a new GCP Project and all sets needed to run this project properly. ##

## /VARS ##
RED='\033[0;31m'
GREEN='\033[0;32m'
YEL='\033[0;33m'
NC='\033[0m' # No Color
## VARS/ ##

## /FUNCTIONS ##
create_projects_and_dependencies(){

## /VARS ##
NEW_PROJECT_ID="projc-devops-sete" ## The new PROJECT ID to be created.
SERVICE_ACCOUNT_ID="terraform-svc-account" ## The new Service Account to be created to run Terraform.
SVC_DESCRIPTION="Terraform Service Account" ## Service Account Description.
LIST_ROLES=`cat ./roles-svc-account.md` ## Roles for the new Service Account.
TF_BACKEND_PATH="leosete-desafio-devops/terraform-gke" ## Terraform file's path.
TF_BACKEND_FILE="provider.tf" ## Terraform provider file.
BILLING_ID=`gcloud alpha billing accounts list |tail -n1 |awk '{print $1}'` ## The billing ID to set in the new project.
BUCKET_NAME="$NEW_PROJECT_ID" ## Bucket which will store the tfstate file.
## VARS/ ##

## /AUTH AND CONFIG GCLOUD ##
echo " "
echo "### ${YEL}1-Auth and Config gcloud${NC} ###"
echo " "
    gcloud components update --quiet
    gcloud components install alpha --quiet
    gcloud components install beta --quiet
    gcloud auth login --no-launch-browser
    # gcloud auth login ## Another option
## AUTH AND CONFIG GCLOUD/ ##

## /CREATING NEW PROJECT ##
echo " "
echo "### 1-The ${YEL}New Project-Name is: ${GREEN}$NEW_PROJECT_ID${NC} ${NC}###"

## /DINAMIC VARS ##
KEY_FILE="./svc-$NEW_PROJECT_ID-private-key.json" ## The key/json file to be created to the Service Account
echo "$SERVICE_ACCOUNT_ID@$NEW_PROJECT_ID.iam.gserviceaccount.com" > ./service_account.md
## DINAMIC VARS/ ##

echo " "
echo "### ${YEL}2-Creating New Project${NC} ###"
echo " "
    gcloud projects create $NEW_PROJECT_ID
    gcloud config set project $NEW_PROJECT_ID
## CREATING NEW PROJECT/ ##

## /CREATING SERVICE ACCOUNT ##
echo " "
echo "### ${YEL}3-Creating Service Account${NC} ###"
echo " "
    gcloud iam service-accounts create $SERVICE_ACCOUNT_ID \
        --description="$SVC_DESCRIPTION" \
        --display-name="$SERVICE_ACCOUNT_ID"
## CREATING SERVICE ACCOUNT/ ##

## /CREATING KEY TO SERVICE ACCOUNT ##
echo " "
echo "### ${YEL}4-Creating Key to Service Account${NC} ###"
echo " "
    gcloud iam service-accounts keys create $KEY_FILE \
        --iam-account="$SERVICE_ACCOUNT_ID@$NEW_PROJECT_ID.iam.gserviceaccount.com"
## CREATING KEY TO SERVICE ACCOUNT/ ##

## /ADD ROLES IN SERVICE ACCOUNT ##
echo " "
echo "### ${YEL}5-Add roles in Service Account${NC} ###"
echo " "
    for ROLES in $LIST_ROLES
        do gcloud projects add-iam-policy-binding $NEW_PROJECT_ID --member="serviceAccount:$SERVICE_ACCOUNT_ID@$NEW_PROJECT_ID.iam.gserviceaccount.com" --role="roles/$ROLES"
    done
## ADD ROLES IN SERVICE ACCOUNT/ ##

## /CHECK SERVICE ACCOUNT DETAILS ##
echo " "
echo "### ${YEL}6-Check Project and Service Account Details${NC} ###"
echo " "
    gcloud iam service-accounts describe $SERVICE_ACCOUNT_ID@$NEW_PROJECT_ID.iam.gserviceaccount.com
echo " "
    gcloud iam service-accounts list
echo " "
    gcloud projects list
echo " "
## CHECK SERVICE ACCOUNT DETAILS/ ##

## /CREATING BUCKET AND ACTIVATE PROJECT BILLING ##
echo " "
echo "### ${YEL}7-Activate Billing Project Account${NC} ###"
echo " "
    gcloud alpha billing projects link "${NEW_PROJECT_ID}" --billing-account "${BILLING_ID}"
echo "### ${YEL}8-Activate Requested APIs${NC} ###"
    gcloud services enable cloudresourcemanager.googleapis.com compute.googleapis.com container.googleapis.com artifactregistry.googleapis.com dns.googleapis.com domains.googleapis.com
echo " "

echo "### ${YEL}9-Create TFSTATE Bucket:${NC} ###"
echo " "
    gcloud alpha storage buckets create gs://$BUCKET_NAME --project="${NEW_PROJECT_ID}" --default-storage-class=standard --location=us
    
echo " "
echo "### ${YEL}10-Verify the new bucket ${NC} ###"
    gcloud alpha storage ls --project=$NEW_PROJECT_ID
echo " "
echo " "
echo " "
## CREATING BUCKET AND ACTIVATE PROJECT BILLING/ ##

## /LAST MESSAGE ##
echo " "
echo "Ao término da execução do script, será gerado o arquivo ${GREEN}[svc-$NEW_PROJECT_ID-private-key.json]${NC}."
echo " "
echo "Esse arquivo será utilizado na etapa seguinte:"
echo "- Configurando Secrets no Repositório:"
echo "    * No github, na home do projeto/repositório que foi realizado o fork, clique na opção ${RED}[Settings]${NC} que fica ao lado de ${RED}[Insights]${NC};"
echo "    * Dentro das opções na coluna ${RED}[General]${NC}, navegue na sessão até chegar na opção ${RED}"Actions": ${RED}[Security]${NC} >> ${RED}[Secrets]${NC} >> ${RED}[Actions]${NC};"
echo "    * Clique em ${RED}[New Repository Secret]${NC} >> Crie um nome baseado na finalidade dessa secret:"
echo "        - Defina: ${RED}[GCP_TERRAFORM_SVC_ACCOUNT]${NC} ## Esse é o valor configurado nos arquivos de workflows."
echo "    * Em ${RED}[Value]${NC}, cole o conteúdo do arquivo ${GREEN}[svc-$NEW_PROJECT_ID-private-key.json]${NC} e clique em ${RED}[Add Secret]${NC}."
echo " "
echo "### ${RED} Continue a leitura do arquivo${NC} ${YEL}ANSWER.md${NC} ###"
## /LAST MESSAGE ##
}

## FUNCTIONS/ ##

### /RUN FUNCTIONS ###

## /FIRST WARNING ##
echo "### ${YEL}First things first!${NC} ###"
echo " "
echo "### ${YEL}You need to install the${NC} ${GREEN}gcloud CLI:${NC} ###"
echo " "
echo "### ${YEL}Click/open the link:${NC} ${GREEN}https://cloud.google.com/sdk/docs/install${NC} ###"
echo " "
echo "### ${YEL}After installation, awswer${NC} ${GREEN}y|Y${NC} ${YEL}to proceed or:${NC} ###"
echo " "
echo "### ${YEL}If you do not install gcloud CLI, this script will not run properly!${NC} ###"
## FIRST WARNING/ ##

## SCRIPT 1 ##
read -p "Did install the gcloud CLI (y/N)? " answer
case ${answer:0:1} in
    y|Y )
        echo Yes
    ;;
    * )
        echo No
        exit
    ;;
esac

## SCRIPT 2 ##
read -p "Do you want to create a new GCP Project and its dependencies? (y/N)" answer
case ${answer:0:1} in
    y|Y )
        create_projects_and_dependencies
    ;;
    * )
        echo No
        exit
    ;;
esac
## RUN FUNCTIONS/ ##