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

    STATIC_EXT_IP=`gcloud compute addresses list |tail -n1 |awk '{print $2}'` ## I'm using my External Static IP on this case
    TTL="300"
    RECORD_TYPE="A"
    MANAGED_ZONE=`gcloud dns managed-zones list |tail -n1 |awk '{print $1}'`
    DOMAIN_NAME=`gcloud dns managed-zones list |tail -n1 |awk '{print $2}'`
    

###############################
### Create a new DNS Record ###
###############################
    
    echo "### The External Static IP created was ${RED}$STATIC_EXT_IP${NC} ###"
    echo " " 
    echo "### The example of RR_DATA is: ${RED}${STATIC_EXT_IP}${NC} ###"
    echo " " 
    echo "### The example of DNS_NAME is: ${RED}myapp${NC} ###"
    echo " "
    echo "### The default TTL is: ${RED}${TTL}${NC} = equal to 5 minutes ###" 
    echo " "
    echo "### The default RECORD_TYPE is: ${RED}${RECORD_TYPE}${NC} - Another types: ${RED}AAAA, ALIAS, MX, CNAME, NS, TXT${NC} and etc... ###"
    echo " "
    echo "### The default MANAGED_ZONE is: ${RED}$MANAGED_ZONE${NC} ###" 


    read -p "The RR_DATA is: " RR_DATA
    echo " "

    read -p "The DNS_NAME is: " DNS_NAME
    echo " "

    read -p "The TTL is: " TTL
    echo " "

    read -p "The RECORD_TYPE is: " RECORD_TYPE
    echo " "

    read -p "The MANAGED_ZONE is: " MANAGED_ZONE
    echo " "

    echo " "
    echo "### 4-To start a transaction - DNS Record Registration ###"
    gcloud dns record-sets transaction start \
    --zone="$MANAGED_ZONE"
    echo " "

    echo " "
    echo "### 5-To add a record set as part of a transaction ###"
    gcloud dns record-sets transaction add "$RR_DATA" \
    --name="$DNS_NAME.$DOMAIN_NAME" \
    --ttl="$TTL" \
    --type="$RECORD_TYPE" \
    --zone="$MANAGED_ZONE"
    echo " "

    echo " "
    echo "### 7-To execute the transaction - apply ###"
    gcloud dns record-sets transaction execute \
    --zone="$MANAGED_ZONE"

    echo " "
    echo "### 8-To execute the transaction ###"
    gcloud dns record-sets list --zone="$MANAGED_ZONE"

###################
## END OF SCRIPT ##
###################
