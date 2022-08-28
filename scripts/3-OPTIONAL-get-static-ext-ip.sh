#!/bin/sh

################
## ENV COLOR####
################
RED='\033[0;31m'
NC='\033[0m' # No Color
REGION="us-central1"
########################
## INTERACTIVE SCRIPT ##
########################

echo "### The ${RED}Static External IP${NC} Address Name to be created ###"
read -p "The ADDRESS_NAME is: " ADDRESS_NAME
echo " "

#############################################################
### Check before creating a new Static External IP ###
#############################################################

    echo " "
    echo "### ${RED}Check before creating a new Static External IP${NC} ###"

    read -p "### Are you sure about the External Static IP creation? (y/n)" answer
    case ${answer:0:1} in
        y|Y )
            echo Yes
        ;;
        * )
            echo No
            exit
        ;;
    esac

#############################################################
### Create a new Static External IP ###
#############################################################

    echo " "
    echo "### ${RED}1-Creating a new static external IP${NC} ###"
    echo "### ${RED}Reserving the $ADDRESS_NAME${NC} ###"
    echo " "
    gcloud compute addresses create $ADDRESS_NAME --region="$REGION"

    echo " "
    echo "### ${RED}2-Describe your new static external IP${NC} ###"
    echo " "
    gcloud compute addresses describe $ADDRESS_NAME --region="$REGION"


########################
## INTERACTIVE SCRIPT ##
########################

    echo " "
    echo "### ${RED}3-Create a new DNS Record with this IP?${NC} ###"

    read -p "### Are you sure about this creation? (y/n)" answer
    case ${answer:0:1} in
        y|Y )
            echo Yes
        ;;
        * )
            echo No
            exit
        ;;
    esac

###############################
### DEFINE VARIABLES DNS ###
###############################

    RR_DATA=`gcloud compute addresses list |tail -n1 |awk '{print $2}'` ## I'm using my External Static IP on this case
    MANAGED_ZONE=`gcloud dns managed-zones list |tail -n1 |awk '{print $1}'`
    DOMAIN_NAME=`gcloud dns managed-zones list |tail -n1 |awk '{print $2}'`
    TTL="300"
    RECORD_TYPE="A"

###############################
### Create a new DNS Record ###
###############################
    
    echo "### The ${RED}DNS Record to be created${NC} example: ${RED}teste${NC}.mydomain.com. ###"
    read -p "The DNS_NAME is: " DNS_NAME
    echo " "

    echo " "
    gcloud dns record-sets transaction start \
    --zone="$MANAGED_ZONE"
    echo " "

    echo " "
    gcloud dns record-sets transaction add "$RR_DATA" \
    --name="$DNS_NAME.$DOMAIN_NAME" \
    --ttl="$TTL" \
    --type="$RECORD_TYPE" \
    --zone="$MANAGED_ZONE"
    echo " "


    gcloud dns record-sets transaction execute \
    --zone="$MANAGED_ZONE"

    gcloud dns record-sets list --zone="$MANAGED_ZONE"

###################
## END OF SCRIPT ##
###################
