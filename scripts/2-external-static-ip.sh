#!/bin/sh

## The main goal of this script is: ##
## Creates a new Static External IP ##

## /vars ##
GREEN='\033[0;32m'
YEL='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color
## vars/ ##

### /FUNCTIONS ###
create_static_ext_ip(){
## /vars ##
REGION="us-central1"
# ADDRESS_NAME_DEV="gke-lb-ext-leosete-dev"
# ADDRESS_NAME_HLG="gke-lb-ext-leosete-hlg"
# ADDRESS_NAME_PRD="gke-lb-ext-leosete-prd"
ADDRESS_NAME_MONITORING="gke-lb-ext-leosete-monitoring"

## vars/ ##

echo " "
echo "### ${RED}1-Creating a new static external IP${NC} ###"
echo "### ${RED}Reserving IPS${NC} ###"
echo " "
    # gcloud compute addresses create $ADDRESS_NAME_DEV --global
    # gcloud compute addresses create $ADDRESS_NAME_HLG --global
    # gcloud compute addresses create $ADDRESS_NAME_PRD --global
    gcloud compute addresses create $ADDRESS_NAME_MONITORING --global

echo " "
echo "### ${YEL}2-Listing your new IP ADDRESS${NC} ###"
    gcloud compute addresses list

echo " "
echo "### ${YEL}Lembre-se de verificar/configurar nos arquivos abaixo essa annotation: ${GREEN}kubernetes.io/ingress.global-static-ip-name:${NC} ${RED}$ADDRESS_NAME_DEV${NC} ###"
echo "### ${YEL}Lembre-se de verificar/configurar nos arquivos abaixo essa annotation: ${GREEN}kubernetes.io/ingress.global-static-ip-name:${NC} ${RED}$ADDRESS_NAME_HLG${NC} ###"
echo "### ${YEL}Lembre-se de verificar/configurar nos arquivos abaixo essa annotation: ${GREEN}kubernetes.io/ingress.global-static-ip-name:${NC} ${RED}$ADDRESS_NAME_PRD${NC} ###"
echo "### ${YEL}Lembre-se de verificar/configurar nos arquivos abaixo essa annotation: ${GREEN}kubernetes.io/ingress.global-static-ip-name:${NC} ${RED}$ADDRESS_NAME_MONITORING${NC} ###"
echo "### ${YEL}Caminho dos arquivos${NC} ${GREEN}leosete-desafio-devops/k8s/deploy-dev.yaml${NC} ###"
echo "### ${YEL}Caminho dos arquivos${NC} ${GREEN}leosete-desafio-devops/k8s/deploy-hlg.yaml${NC} ###"
echo "### ${YEL}Caminho dos arquivos${NC} ${GREEN}leosete-desafio-devops/k8s/deploy-prd.yaml${NC} ###"
echo "### ${YEL}Caminho dos arquivos${NC} ${GREEN}leosete-desafio-devops/k8s-monitoring/grafana.yaml.yaml${NC} ###"


}
### FUNCTIONS/ ###

### /RUN FUNCTIONS ###

### SCRIPT 1 ###
echo " "
echo "### ${YEL}List Static External IPs Created in the Current Project${NC} ###"
    gcloud compute addresses list
echo " "
echo "### ${RED}Creating 5 new Static External IP${NC} ###"
read -p "### Are you sure about the IP creation? (y/N)" answer
case ${answer:0:1} in
    y|Y )
        create_static_ext_ip
    ;;
    * )
        echo No
        exit
    ;;
esac

### END OF FUNCTIONS ###