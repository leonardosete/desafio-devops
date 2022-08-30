#!/bin/sh

## The main goal of this script is: ##
## Sets a External Static IP in GCP and sets in Cloud DNS Provider a DNS Record ##
## with the new IP created ##

## /vars ##
RED='\033[0;31m'
GREEN='\033[0;32m'
YEL='\033[0;33m'
NC='\033[0m' # No Color
## vars/ ##

### /FUNCTIONS ###
create_ext_static_ip(){
## /vars ##
REGION="us-central1"
## vars/ ##

echo "### The ${RED}Static External IP${NC} Address Name to be created ###"
read -p "The ADDRESS_NAME is: " ADDRESS_NAME
echo " "
echo " "
echo "### ${RED}1-Creating a new static external IP${NC} ###"
echo "### ${RED}Reserving the $ADDRESS_NAME${NC} ###"
echo " "
    gcloud compute addresses create $ADDRESS_NAME --region="$REGION"
echo " "
echo "### ${RED}2-Describe your new static external IP${NC} ###"
echo " "
    gcloud compute addresses describe $ADDRESS_NAME --region="$REGION"
}

create_dns_record_entry(){
## /vars ##
STATIC_EXT_IP=`gcloud compute addresses list |tail -n1 |awk '{print $2}'` ## I'm using my External Static IP on this case
TTL="300"
RECORD_TYPE="A"
MANAGED_ZONE=`gcloud dns managed-zones list |tail -n1 |awk '{print $1}'`
DOMAIN_NAME=`gcloud dns managed-zones list |tail -n1 |awk '{print $2}'`
## vars/ ##

echo "### The External Static IP created was ${GREEN}$STATIC_EXT_IP${NC} ###"
echo " " 
echo "### The example of RR_DATA is: ${RED}${STATIC_EXT_IP}${NC} ###"
echo " " 
echo "### The example of DNS_NAME is: ${RED}myapp${NC} ###"
echo " "
echo "### The default TTL is: ${RED}${TTL}${NC} = equal to 5 minutes ###" 
echo " "
echo "### The default RECORD_TYPE is: ${RED}${RECORD_TYPE}${NC} - Another types: ${RED}AAAA, ALIAS, MX, CNAME, NS, TXT${NC} and etc... ###"
echo " "
echo "### The default MANAGED_ZONE is: ${GREEN}$MANAGED_ZONE${NC} ###" 

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

echo "### 1-To start a transaction - DNS Record Registration ###"
    gcloud dns record-sets transaction start \
    --zone="$MANAGED_ZONE"
echo " "
echo " "
echo "### 2-To add a record set as part of a transaction ###"
    gcloud dns record-sets transaction add "$RR_DATA" \
    --name="$DNS_NAME.$DOMAIN_NAME" \
    --ttl="$TTL" \
    --type="$RECORD_TYPE" \
    --zone="$MANAGED_ZONE"
echo " "

echo " "
echo "### 3-To execute the transaction - apply ###"
    gcloud dns record-sets transaction execute \
    --zone="$MANAGED_ZONE"
echo " "
echo "### 4-To execute the transaction ###"
    gcloud dns record-sets list --zone="$MANAGED_ZONE"
}
### FUNCTIONS/ ###

### /RUN FUNCTIONS ###

### SCRIPT 1 ###
echo " "
echo "### ${RED}1-Check before creating a new Static External IP${NC} ###"
read -p "### Are you sure about the External Static IP creation? (y/N)" answer
case ${answer:0:1} in
    y|Y )
        create_ext_static_ip
    ;;
    * )
        echo No
        exit
    ;;
esac

### SCRIPT 2 ###
echo " "
echo "### ${RED}2-Create a new DNS Record with this IP?${NC} ###"   
read -p "### Are you sure about this creation? (y/N)" answer
case ${answer:0:1} in
    y|Y )
        create_dns_record_entry
    ;;
    * )
        echo No
        exit
    ;;
esac
### RUN FUNCTIONS/ ###