#!/bin/sh

## The main goal of this script is: ##
## Creates a new Static External IP ##

## /vars ##
RED='\033[0;31m'
GREEN='\033[0;32m'
YEL='\033[0;33m'
NC='\033[0m' # No Color
## vars/ ##

### /FUNCTIONS ###
create_static_ext_ip(){
## /vars ##
REGION="us-central1"
## vars/ ##

# echo "### The ${RED}Static External IP${NC} Address Name to be created ###"
# read -p "The ADDRESS_NAME is: " ADDRESS_NAME
# echo " "
echo " "
read -p "The New NAME is: " ADDRESS_NAME
echo " "
echo "### ${RED}1-Creating a new static external IP${NC} ###"
echo "### ${RED}Reserving the $ADDRESS_NAME${NC} ###"
echo " "
    
    gcloud compute addresses create $ADDRESS_NAME --global

echo " "
echo "### ${YEL}2-Listing your new IP ADDRESS${NC} ###"
    gcloud compute addresses list

echo " "
echo "### ${YEL}And set the annotation value equal to: kubernetes.io/ingress.global-static-ip-name:: ${RED}VALUE${NC} ###"
echo "### ${YEL}File path:${NC} ${GREEN}../k8s/kustomize/*/ingress.yaml${NC} ###"

}
### FUNCTIONS/ ###

### /RUN FUNCTIONS ###

### SCRIPT 1 ###
echo " "
echo "### ${YEL}List Static External IPs Created in the Current Project${NC} ###"
    gcloud compute addresses list
echo " "
echo "### ${RED}Check before creating a new Static External IP${NC} ###"
echo "### ${RED}The above IP is already in use, choose a new Static External IP${NC} ###"
read -p "### Are you sure about the Static Externa IP creation? (y/N)" answer
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