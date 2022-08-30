#!/bin/sh

################
## ENV COLOR####
################
RED='\033[0;31m'
GREEN='\033[0;32m'
YEL='\033[0;33m'
NC='\033[0m' # No Color

########################
## INTERACTIVE SCRIPT ##
########################

echo "### ${YEL}First things first!${NC} ###"
echo " "
echo "### ${YEL}You need to install the${NC} ${GREEN}gcloud CLI:${NC} ###"
echo " "
echo "### ${YEL}Click/open the link:${NC} ${GREEN}https://cloud.google.com/sdk/docs/install${NC} ###"
echo " "
echo "### ${YEL}After installation, awswer${NC} ${GREEN}y|Y${NC} ${YEL}to proceed or:${NC} ###"
echo " "
echo "### ${YEL}If you do not install gcloud CLI, this script will not run properly!${NC} ###"

########################
## INTERACTIVE SCRIPT ##
########################

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

###########
## VARS ##
########### 
LIST_ROLES=`cat ./roles-svc-account.md` ## A list of the needed roles to be added to the new Service Account
SERVICE_ACCOUNT_ID="terraform-svc-account" ## The new Service Account to be created to run Terraform
SVC_DESCRIPTION="Terraform Service Account" ## Service Account Description
TF_BACKEND_FILE="provider.tf"
TF_BACKEND_PATH="tembici-desafio-devops/terraform-gke/"
######################################
## DEFINE TERRAFORM SERVICE ACCOUNT ##
######################################

echo "$SERVICE_ACCOUNT_ID@$NEW_PROJECT_ID.iam.gserviceaccount.com" > ./service_account.md

######################
## GCLOUD EXECUTION ##
######################

############################
## Auth and Config gcloud ##
############################

    echo " "
    echo "### ${YEL}1-Auth and Config gcloud${NC} ###"
    echo " "
    gcloud components update --quiet
    gcloud components install alpha --quiet
    gcloud components install beta --quiet
    # gcloud auth login ## DESCOMENTAR QUANDO ENVIAR
    gcloud auth login --no-launch-browser

########################
## Creating New Project ##
########################

    echo "### ${YEL}Checking Project availability${NC} ###"
    echo "### The new ${YEL}PROJECT_ID to create${NC} must be different than: ###"
    echo " "
    gcloud projects list
    echo " "

    echo " "
    echo "### Please, define the variable below ###"
    echo " "
    echo "### The ${YEL}New Project-Name:${NC} ###"
    read -p "The NEW_PROJECT_ID to be created is: " NEW_PROJECT_ID
    echo " "

#################
## DINAMIC VAR ##
#################
## The key/json file to be created to the Service Account
KEY_FILE="./svc-$NEW_PROJECT_ID-private-key.json" 
#################

    echo " "
    echo "### ${YEL}2-Creating New Project${NC} ###"
    echo " "
    gcloud projects create $NEW_PROJECT_ID
    gcloud config set project $NEW_PROJECT_ID

############################
## Creating Service Account ##
############################

    echo " "
    echo "### ${YEL}3-Creating Service Account${NC} ###"
    echo " "
    gcloud iam service-accounts create $SERVICE_ACCOUNT_ID \
        --description="$SVC_DESCRIPTION" \
        --display-name="$SERVICE_ACCOUNT_ID"

###################################
## Creating Key to Service Account ##
###################################

    echo " "
    echo "### ${YEL}4-Creating Key to Service Account${NC} ###"
    echo " "
    gcloud iam service-accounts keys create $KEY_FILE \
        --iam-account="$SERVICE_ACCOUNT_ID@$NEW_PROJECT_ID.iam.gserviceaccount.com"

###################################
## Add roles in Service Account ##
###################################

    echo " "
    echo "### ${YEL}5-Add roles in Service Account${NC} ###"
    echo " "

    for ROLES in $LIST_ROLES
        do gcloud projects add-iam-policy-binding $NEW_PROJECT_ID --member="serviceAccount:$SERVICE_ACCOUNT_ID@$NEW_PROJECT_ID.iam.gserviceaccount.com" --role="roles/$ROLES"
    done

###################################
## Check Service Account Details ##
###################################

    echo " "
    echo "### ${YEL}6-Check Project and Service Account Details${NC} ###"
    echo " "
    gcloud iam service-accounts describe $SERVICE_ACCOUNT_ID@$NEW_PROJECT_ID.iam.gserviceaccount.com
    echo " "
    gcloud iam service-accounts list
    echo " "
    gcloud projects list
    echo " "

################################################
## Creating Bucket and activate Project Billing ##
################################################

    echo " "
    echo "### ${YEL}7-Activate Billing Project Account${NC} ###"
    BILLING_ID=`gcloud alpha billing accounts list |tail -n1 |awk '{print $1}'`
    gcloud alpha billing projects link "${NEW_PROJECT_ID}" --billing-account "${BILLING_ID}"

    echo "### ${YEL}8-Activate Requested APIs${NC} ###"
    gcloud services enable cloudresourcemanager.googleapis.com compute.googleapis.com container.googleapis.com artifactregistry.googleapis.com dns.googleapis.com domains.googleapis.com
    
    echo " "
    echo "### The ${YEL}9-New Bucket-Name to keep TFSTATE:${NC} ###"
    read -p "The BUCKET_NAME to be created is: " BUCKET_NAME
    echo " "
    gcloud alpha storage buckets create gs://$BUCKET_NAME --project="${NEW_PROJECT_ID}" --default-storage-class=standard --location=us
    
    echo " "
    echo "### ${YEL}10-Verify the new bucket ${NC} ###"
    gcloud alpha storage ls --project=$NEW_PROJECT_ID
    echo " "
    echo " "
    echo " "

##################
## LAST MESSAGE ##
##################

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
echo " "
echo "### ${YEL}VERY IMPORTANT${NC} ###"
echo "### ${YEL}SAVE THIS BUCKET NAME: ${NC} ${GREEN}$BUCKET_NAME${NC} ###"
echo "### ${YEL}WE GONNA NEED IN TERRAFORM FILE${NC} ${GREEN}$TF_BACKEND_FILE${NC} ###"
echo "### ${YEL}LOCATE IN:${NC} ${GREEN}$TF_BACKEND_PATH/$TF_BACKEND_FILE${NC} ###"
echo "### ${YEL}Change the current value:${NC} bucket = ${RED}CURRENT_VALUE${NC} ###"
echo "### ${YEL}For the new bucket name:${NC} bucket = ${GREEN}$BUCKET_NAME${NC} ###"
echo " "
echo "### ${YEL}Also, we need to change the follow value:${NC} ###"
echo "### ${GREEN}$NEW_PROJECT_ID${NC} ###"
echo "### ${RED}files' path:${NC} ${GREEN}tembici-desafio-devops/.github/workflows/*yaml${NC} ###"
echo "### ${RED}files' path:${NC} ${GREEN}tembici-desafio-devops/terraform-gke/variables.tf${NC} ###"
echo "### ${GREEN}END-OF-SCRIPT${NC} ###"

###################
## END OF SCRIPT ##
###################