#!/bin/sh

################
## ENV COLOR####
################
RED='\033[0;31m'
GREEN='\033[0;32m'
YEL='\033[0;33m'
NC='\033[0m' # No Color

################
### WARNING ####
################
   
   echo " "
   echo "### ${YEL}ONLY RUN THIS SCRIPT ${GREEN}IF YOU NEED TO ENABLE${NC} ${YEL}CLOUD DNS PROVIDER SERVICE${NC} ###"
   echo "### ${YEL}AND BUY A NEW DOMAIN -${NC} ${RED}THIS WILL CAUSE BILLING CHARGES${NC} ###"
   echo " "

########################
## INTERACTIVE SCRIPT ##
########################

   echo " "
   echo "### ${RED}Check before creating a Cloud DNS Provider and Buying a Domain Name${NC} ###"  
   read -p "Are you sure about the Cloud DNS Provider and Buying a Domain Name (y/N)? " answer
   case ${answer:0:1} in
       y|Y )
           echo Yes
       ;;
       * )
           echo No
           exit
       ;;
   esac

########################
## INTERACTIVE SCRIPT ##
########################

   echo "### The ${RED}New Domain Name:${NC} ###"
   read -p "The DOMAIN_NAME is: " DOMAIN_NAME
   echo " "

#########################
## SEARCH TERMS/DOMAIN ##
########################

   echo " "
   echo "### ${YEL}1-Search if the Domain already exists${NC} ###"
   echo " "
   gcloud domains registrations search-domains $DOMAIN_NAME
   
   echo " "
   echo "### ${YEL}2-To check up-to-date availability for a domain name${NC} ###"
   echo " "
   AVAILABILITY=`gcloud domains registrations get-register-parameters $DOMAIN_NAME |grep AVAILABLE`

   if [[ $AVAILABILITY == "availability: AVAILABLE" ]]
   then
      echo "### The ${GREEN}$DOMAIN_NAME${NC} is ${GREEN}AVAILABLE${NC} ###"
   else
      echo "### The ${RED}$DOMAIN_NAME${NC} is ${RED}UNAVAILABLE${NC} ###"
      echo " "
      echo "### Choose another ${RED}DOMAIN NAME${NC} SEARCH and run this scripts again ###"
      exit
   fi

###########################################################################
### Check before creating a Cloud DNS Provider and Buying a Domain Name ###
###########################################################################
########################
## /INTERACTIVE SCRIPT ##
########################

   echo " "
   echo "### ${RED}Check before creating a Cloud DNS Provider and Buying a Domain Name${NC} ###"  

   read -p "Do you REALLY want to proceed with it? (y/n)? " answer
   case ${answer:0:1} in
       y|Y )
           echo Yes
       ;;
       * )
           echo No
           exit
       ;;
   esac


   read -p "REALLY??? There is no way back from here! ;) (y/n)? " answer
   case ${answer:0:1} in
       y|Y )
           echo Yes
       ;;
       * )
           echo No
           exit
       ;;
   esac

########################
## INTERACTIVE SCRIPT/ ##
########################

   echo "### The ${RED}New Cloud DNS Zone Name - example-com${NC} ###"
   read -p "The CLOUD_DNS_ZONE_NAME is: " CLOUD_DNS_ZONE_NAME
   echo " "

   echo "### The ${RED}Description's Domain Name:${NC} ###"
   read -p "The DESCRIPTION is: " DESCRIPTION
   echo " "

#############################################################
### Creating a new Cloud DNS managed zone for the domain ###
#############################################################

   echo " "
   echo "### ${YEL}3-Creating a managed public zone for your domain${NC} ###"
   echo " "
   gcloud dns managed-zones create $CLOUD_DNS_ZONE_NAME \
      --description="$DESCRIPTION" \
      --dns-name=$DOMAIN_NAME
   
   echo " "
   echo "### ${YEL}4-To register the domain${NC} ###"
   echo " "
   gcloud beta domains registrations register "$DOMAIN_NAME" \
   --contact-data-from-file=contacts.yaml --contact-privacy=private-contact-data \
   --yearly-price="12.00 USD" --cloud-dns-zone="$CLOUD_DNS_ZONE_NAME" --quiet

#######################################
### Verify your contact information ###
#######################################

   echo " "
   echo "### ${RED}IMPORTANT${NC} ###"
   echo " "
   echo "### ${RED}Verify your contact information${NC} ###"
   echo " "
   echo "After you register your domain, Cloud Domains sends a verification email"
   echo "to the address that you provided in your contact information for the domain."
   echo " "
   echo "This email includes a subject line that states Action required:"
   echo "Please verify your email address."
   echo " "
   echo "You must verify your contact information within 15 days or your domain becomes inactive."
   echo "To verify your email address, follow these steps:"
   echo " "
   echo "1. Open the verification email from domains-noreply@google.com."
   echo "2. Click Verify email now."
   echo " "
   echo "Once Cloud Domains verifies your contact information, a Google Domains page"
   echo "with the message that your email address has been verified is displayed."


###################
## END OF SCRIPT ##
###################

   echo " "
   echo " "
   echo "### ${YEL}Do you want to set a External Static IP and create a DNS Record in Cloud DNS Provider for this project:${NC} ${GREEN}$PROJECT_ID?${NC} ###"
   read -p "Type y or Y for it - (y/n)? " answer
   case ${answer:0:1} in
       y|Y )
           echo Yes
           sh 3-OPTIONAL-get-domain.sh
       ;;
       * )
           echo No
           exit
       ;;
   esac