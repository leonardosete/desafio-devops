#!/bin/sh

## The main goal of this script is: ##
## Creates a DNS Record ##

## /vars ##
RED='\033[0;31m'
GREEN='\033[0;32m'
YEL='\033[0;33m'
NC='\033[0m' # No Color
## vars/ ##

## /FUNCTIONS ##

create_dns_record_entry(){

## /vars ##
# STATIC_EXT_IP=`gcloud compute addresses list |tail -n1 |awk '{print $2}'` ## I'm using my External Static IP on this case
TTL="300"
MANAGED_ZONE_LIST=`gcloud dns managed-zones list |awk '{print $1}' |egrep -v NAME`
DOMAIN_NAME_LIST=`gcloud dns managed-zones list |awk '{print $2}' |egrep -v DNS_NAME`
APP_HOST=`cat ../k8s/flask-app.yaml |grep "host:" |awk '{print $3}'`
## vars/ ##

echo " " 
echo "### ${YEL}One example of ${GREEN}RR_DATA${NC} ${YEL}could be an IP ADDRESS:${NC} ###"
echo "### ${YEL}from the list above -${NC} ${GREEN}Static External IPs${NC} ###"
echo " " 
echo "### ${YEL}The example of${NC} ${GREEN}DNS_NAME is:${NC} ${RED}$APP_HOST${NC} ###"
echo "### ${YEL}But don't type the${NC} ${RED}DOMAIN,${NC} ${YEL}just the${NC} ${GREEN}NAME${NC} ###"

echo " "
echo "### The default TTL is: ${RED}${TTL}${NC} = equal to 5 minutes ###" 
echo " "
echo "### Sets a RECORD_TYPE: ${RED}${RECORD_TYPE}${NC} - Another types: ${RED}AAAA, ALIAS, MX, CNAME, NS, TXT${NC} and etc... ###"
echo " "
echo "### The MANAGED_ZONE already created is/are: "
echo "${GREEN}$MANAGED_ZONE_LIST${NC}"
echo " "
echo "### The DOMAIN NAME already created is/are: "
echo "${GREEN}$DOMAIN_NAME_LIST${NC}"

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
read -p "The DOMAIN_NAME is: " DOMAIN_NAME
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

## /RUN FUNCTIONS ##
## SCRIPT 1 ##
echo " "
echo "### ${YEL}List Static External IPs Created in Current Project${NC} ###"
    gcloud compute addresses list

echo "### ${YEL}You can set your apps DNS Records now, but remember to change in below file too:${NC} ###"
echo "### Change the ${GREEN}spec.tls.hosts${NC} in ${GREEN}tembici-desafio-devops/k8s/flask-app.yaml${NC} ###"
echo " "
echo "### ${RED}2-Create a new DNS Record?${NC} ###"   
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

## RUN FUNCTIONS/ ##