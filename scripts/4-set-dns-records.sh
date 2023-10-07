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
MANAGED_ZONE_LIST=`gcloud dns managed-zones list |awk '{print $1}' |egrep -v NAME`
DOMAIN_NAME_LIST=`gcloud dns managed-zones list |awk '{print $2}' |egrep -v DNS_NAME`
## vars/ ##

echo "### ${YEL}Your MANAGED ZONE${NC} ${GREEN}$MANAGED_ZONE_LIST${NC} ${YEL} records are:${NC} ###"
echo " "
    gcloud dns record-sets list -z $MANAGED_ZONE_LIST
echo " "
echo "### ${YEL}An example of ${GREEN}RR_DATA${NC} ${YEL}could be an IP ADDRESS:${NC} ###"
echo "### ${YEL}from the list below -${NC} ${GREEN}Static External IPs${NC} ###"
echo " " 
echo "### ${RED}List Static External IPs Created in Current Project${NC} ###"
    gcloud compute addresses list

echo " "
read -p "The RR_DATA is: " RR_DATA
echo " "
echo "### ${YEL}An example of${NC} ${GREEN}FQDN is:${NC} ${RED}my-app.domain${NC} ###"
echo "### ${YEL}We should only define DNS_NAME = ${GREEN}my-app${NC} - Don't type ${RED}.domain${NC} ###"
echo " "
read -p "The Record Set is: " DNS_NAME
echo " "
echo "### ${YEL}An example of TTL is 300= equal to 5 minutes${NC} ###"
echo " "
read -p "The TTL is: " TTL
echo " "
echo "### ${YEL}Sets a RECORD_TYPE:${NC} ${RED}${RECORD_TYPE}${NC} ${YEL}- Another types:${NC} ${RED}AAAA, ALIAS, MX, CNAME, NS, TXT${NC} ###"
echo " "
read -p "The RECORD_TYPE is: " RECORD_TYPE
echo " "
echo "### ${YEL}The MANAGED_ZONE already created is/are - copy/paste it:${NC} ###"
echo "${GREEN}$MANAGED_ZONE_LIST${NC}"
echo " "
read -p "The MANAGED_ZONE is: " MANAGED_ZONE
echo " "
echo "### ${YEL}The DOMAIN NAME already created is/are - copy/paste it:${NC} ###"
echo "${GREEN}$DOMAIN_NAME_LIST${NC}"
read -p "The DOMAIN_NAME is: " DOMAIN_NAME
echo " "
echo " "

echo "### ${YEL}1-To start a transaction - DNS Record Registration${NC} ###"
    gcloud dns record-sets transaction start \
    --zone="$MANAGED_ZONE"
echo " "
echo " "
echo "### ${YEL}2-To add a record set as part of a transaction${NC} ###"
    gcloud dns record-sets transaction add "$RR_DATA" \
    --name="$DNS_NAME.$DOMAIN_NAME" \
    --ttl="$TTL" \
    --type="$RECORD_TYPE" \
    --zone="$MANAGED_ZONE"
echo " "

echo " "
echo "### ${YEL}3-To execute the transaction - apply${NC} ###"
    gcloud dns record-sets transaction execute \
    --zone="$MANAGED_ZONE"
echo " "
echo "### ${YEL}4-To execute the transaction${NC} ###"
    gcloud dns record-sets list --zone="$MANAGED_ZONE"
}

### FUNCTIONS/ ###

## /RUN FUNCTIONS ##
## SCRIPT 1 ##

echo "### ${YEL}You can set your apps DNS Records now, but remember to change values in below files too:${NC} ###"
echo "### Change the ${GREEN}spec.domains${NC} value in ${GREEN}leosete-desafio-devops/k8s/deploy-*.yaml${NC} ###"
echo " "
echo "### Change the ${GREEN}spec.rules.host${NC} value in ${GREEN}leosete-desafio-devops/k8s/deploy-*.yaml${NC} ###"
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