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
check_domain_name(){

echo "### ${YEL}1-Check Domain Name's Availability${NC} ###"
echo " "
read -p "The DOMAIN_NAME is: " DOMAIN_NAME
echo " "
    gcloud services enable dns.googleapis.com domains.googleapis.com
    gcloud domains registrations search-domains $DOMAIN_NAME

## /VARS ##
AVAILABILITY=`gcloud domains registrations get-register-parameters $DOMAIN_NAME |grep AVAILABLE`
PRICE=`gcloud domains registrations search-domains $DOMAIN_NAME |head -n2 |awk '{print $3}'|tail -n1`
## VARS/ ##

    if [[ $AVAILABILITY == "availability: AVAILABLE" ]]
    then
        echo "### ${GREEN}$DOMAIN_NAME${NC} is ${GREEN}AVAILABLE${NC} for ${YEL}$PRICE USD${NC} ###"
    else
        echo "### ${RED}$DOMAIN_NAME${NC} is ${RED}UNAVAILABLE${NC} ###"
        echo " "
        echo "### Choose another ${RED}DOMAIN NAME${NC} and run this scripts again ###"
        exit
    fi
}

configure_cloud_dns_provider(){

## /VARS ##
local check_domain_name=$DOMAIN_NAME
## VARS/ ##
    
echo "### The ${RED}Description's Domain Name:${NC} ###"
read -p "The DESCRIPTION is: " DESCRIPTION
echo " "
echo "### The ${RED}New Cloud DNS Zone Name -${NC} ${YEL}example-com${NC} ###"
read -p "The CLOUD_DNS_ZONE_NAME is: " CLOUD_DNS_ZONE_NAME
echo " "
echo " "
echo "### ${YEL}2-Create a Managed Public Zone${NC} ###"
echo " "
    gcloud dns managed-zones create $CLOUD_DNS_ZONE_NAME \
        --description="$DESCRIPTION" \
        --dns-name="$DOMAIN_NAME"
}

buy_domain_name(){

## /VARS ##
local check_domain_name=$PRICE
## VARS/ ##

echo " "
echo "### ${YEL}3-Buy a Domain Name${NC} ###"
echo " "
    gcloud beta domains registrations register "$DOMAIN_NAME" \
    --contact-data-from-file=contacts.yaml --contact-privacy=private-contact-data \
    --yearly-price="$PRICE USD" --cloud-dns-zone="$CLOUD_DNS_ZONE_NAME" --quiet
}


### FUNCTIONS/ ###

### /WARNING SECTION ###
echo "### ${RED} WARNING${NC} ###"
echo " "
echo "### ${YEL}ONLY RUN THIS SCRIPT IF YOU NEED TO ENABLE${NC} ${YEL}CLOUD DNS PROVIDER SERVICE${NC} ###"
echo "### ${YEL}AND BUY A NEW DOMAIN -${NC} ${RED}THIS WILL CAUSE BILLING CHARGES${NC} ###"
echo " "
echo "### ${RED} WARNING-2${NC} ###"
echo "### ${YEL}TO RUN THIS SCRIPT, FIRST YOU MUST CHANGE AT LEAST THE EMAIL IN${NC} ${GREEN}contacts.yaml${NC} ${YEL}FILE${NC} ###"
echo " "
### WARNING SECTION/ ###

### /RUN FUNCTIONS ###

## SCRIPT 1 ##
echo "### ${YEL}Check Availability's Domain Name${NC} ###"

read -p "Do you want to verify a Domain Name? (y/N)" answer
case ${answer:0:1} in
    y|Y )
        check_domain_name
    ;;
    * )
        echo No
        exit
    ;;
esac

### SCRIPT 2 ###
echo "### ${YEL}Configure Google Cloud DNS Provider${NC} ###"    
read -p "Do you want to create a Managed Public Zone? (y/N)? " answer
case ${answer:0:1} in
    y|Y )
        configure_cloud_dns_provider
    ;;
    * )
        echo No
        exit
    ;;
esac

### SCRIPT 3 ###
echo " "
echo "### ${RED}Buy a Domain Name${NC} ###"  

read -p "Do you REALLY want to buy a Domain Name? (y/N)? " answer
case ${answer:0:1} in
    y|Y )
    buy_domain_name
    ;;
    * )
        echo No
        exit
    ;;
esac
### /RUN FUNCTIONS ###

## /VERIFY YOUR CONTACT INFORMATION ##
echo " "
echo "### ${RED}IMPORTANT${NC} ###"
echo " "
echo "### ${RED}Verify your contact information${NC} ###"
echo " "
echo "${YEL}After you register your domain, Cloud Domains sends a verification email${NC}"
echo "${YEL}to the address that you provided in your contact information for the domain.${NC}"
echo " "
echo "${YEL}This email includes a subject line that states Action required:${NC}"
echo "${YEL}Please verify your email address.${NC}"
echo " "
echo "${YEL}You must verify your contact information within 15 days or your domain becomes inactive.${NC}"
echo "${YEL}To verify your email address, follow these steps:${NC}"
echo " "
echo "${YEL}1. Open the verification email from domains-noreply@google.com.${NC}"
echo "${YEL}2. Click Verify email now."
echo " "
echo "${YEL}Once Cloud Domains verifies your contact information, a Google Domains page${NC}"
echo "${YEL}with the message that your email address has been verified is displayed.${NC}"
## VERIFY YOUR CONTACT INFORMATION/ ##