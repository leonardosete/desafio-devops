#!/bin/sh

## The main goal of this script is: ##
## Create a Self-Signed Certificate in GCP ##
## And sets a SSL on target HTTPS Proxy/Load Balancer ##
## DOCS: https://cloud.google.com/load-balancing/docs/ssl-certificates/self-managed-certs

## /vars ##
RED='\033[0;31m'
GREEN='\033[0;32m'
YEL='\033[0;33m'
NC='\033[0m' # No Color
REGION="us-central1" ## Region for the regional SSL certificate ## Default region's Project - Change if needed.
## vars/ ##

create_self_ssl(){

echo " "
echo "### ${YEL}List of Domains Name Created in the Current Project${NC} ###"
    gcloud dns managed-zones list |awk '{print $2}' |egrep -v DNS_NAME |awk '{print substr($0, 1, length($0)-1)}'
echo " "
read -p "Choose a DOMAIN_NAME from the list above: " DOMAIN_NAME
echo " "

### /VARS ###
PRIVATE_KEY_FILE="./certs/$DOMAIN_NAME-key.pem" ## The path and filename for the new private key file.
CONFIG_FILE="./certs/$DOMAIN_NAME.openssl_config" ## The path, including the file name, for the OpenSSL configuration file.
SUBJECT_ALTERNATIVE_NAME_1="$DOMAIN_NAME" ## Subject Alternative Names for your certificate
SUBJECT_ALTERNATIVE_NAME_2="www.$DOMAIN_NAME" ## Subject Alternative Names for your certificate
CSR_FILE="./certs/$DOMAIN_NAME.csr" ## The path to the CSR
CERTIFICATE_FILE="./certs/$DOMAIN_NAME-crt.pem" ## The path to the certificate file to create
TERM="365" ## The number of days, from now, during which the certificate should be considered valid by clients that verify it.
CERTIFICATE_NAME=`echo $DOMAIN_NAME |tr -d "-" |tr -d "."` ## A name for the global SSL certificate
### VARS/ ###

echo "###${YEL}1-The Private Key Name to create${NC} ###"
echo " "
    openssl genrsa 2048 > $PRIVATE_KEY_FILE

echo "###${YEL}2-The OpenSSL Config file to create${NC} ###"
echo " "

## /Creating a  OpenSSL Config file ##
cat <<EOF > $CONFIG_FILE
[req]
default_bits              = 2048
req_extensions            = extension_requirements
distinguished_name        = dn_requirements
prompt = no

[extension_requirements]
basicConstraints          = CA:FALSE
keyUsage                  = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName            = @sans_list

[dn_requirements]
countryName               = BR
stateOrProvinceName       = Sao Paulo
localityName              = Sao Paulo
organizationalUnitName    = Tembici Devops Teste
commonName                = *.$DOMAIN_NAME

[sans_list]
DNS.1                     = $SUBJECT_ALTERNATIVE_NAME_1
DNS.2                     = $SUBJECT_ALTERNATIVE_NAME_2

EOF
## Creating a  OpenSSL Config file/ ##

echo "###${YEL}3-Creating Certificate Signing Request file${NC} ###"
echo " "
    openssl req -new -key $PRIVATE_KEY_FILE \
        -out $CSR_FILE \
        -config $CONFIG_FILE

echo "###${YEL}4-Creating Self-Signed Certificate Resource ${NC} ###"
echo " "
    openssl x509 -req \
        -signkey $PRIVATE_KEY_FILE \
        -in $CSR_FILE \
        -out $CERTIFICATE_FILE \
        -extfile $CONFIG_FILE \
        -extensions extension_requirements \
        -days $TERM

echo "###${YEL}5-Creating Self-Signed Certificate${NC} ###"
echo " "
    gcloud compute ssl-certificates create $CERTIFICATE_NAME \
        --certificate=$CERTIFICATE_FILE \
        --private-key=$PRIVATE_KEY_FILE \
        --region=$REGION

}

set_target_https_lb(){

## /VARS ##
local check_domain_name=$DOMAIN_NAME
## VARS/ ##

echo "###${YEL}6-Associate a regional SSL certificate with a target HTTP/S Proxy${NC} ###"
echo " "
echo "###${YEL}Your project has this target HTTP/S Proxy${NC} ###"
    gcloud compute target-https-proxies list
echo " "
echo " "
read -p "Choose a TARGET_PROXY_NAME: " TARGET_PROXY_NAME
echo " "
read -p "Choose a CERTIFICATE_LIST: " CERTIFICATE_LIST
echo " "
    gcloud compute target-https-proxies update $TARGET_PROXY_NAME \
        --region=$REGION \
        --ssl-certificates=$CERTIFICATE_LIST \
        --ssl-certificates-region=$REGION
}

create_certificate_authority(){
## https://cloud.google.com/certificate-authority-service/docs/request-certificates-gcloud?hl=en_US ##
## /VARS ##
local check_domain_name=$DOMAIN_NAME
POOL_ID=""
LOCATION="us-central1"
TIER="devops"
CA_ID="leosete-devops"
ORG="tembici"
## VARS/ ##

    gcloud services enable privateca.googleapis.com
    
    gcloud config set privateca/location $LOCATION

    gcloud privateca pools create $POOL_ID --tier "$TIER"

    gcloud privateca roots create $CA_ID --pool $POOL_ID --subject "CN=$Example Prod Root CA, O=$ORG"

    pip install --user "cryptography>=2.2.0"

    export CLOUDSDK_PYTHON_SITEPACKAGES=1

    gcloud privateca certificates create \
    --issuer-pool POOL_ID \
    --subject "CN=Example Prod,O=Google" \
    --generate-key \
    --key-output-file=./key \
    --cert-output-file=./cert.pem

}




## /RUN FUNCTIONS ##
## SCRIPT 1 ##
# echo " "
# echo "### ${YEL} Checking if already exist a SSL Certificate${NC} ###"
#     CHECK_SSL=`gcloud compute ssl-certificates list |head -n2 |awk '{print $2}' |grep "SELF_MANAGED"`
#     CHECK_SSL_NAMES=`gcloud compute ssl-certificates list |awk '{print $1}' |egrep -v NAME`

#     if [[ $CHECK_SSL == "SELF_MANAGED" ]]
#     then
#         echo "### ${YEL}Already exist a SSL Certificate in this project =${NC} ${GREEN}$CHECK_SSL_NAMES${NC}"
#     else
#         echo "### ${YEL}None SSL Certificate was found in this project${NC}"
#     fi

# echo " "
# read -p "Do you want to create a new Self-Signed Certificate? (y/N)? " answer
read -p "Do you want to create Certificate Authority and a new SSL Certificate? (y/N)? " answer
echo "### ${YEL} You can skip this step, if you only desire to set SSL on a target HTTPS/LB${NC} ###"
case ${answer:0:1} in
    y|Y )
        # create_self_ssl
        create_certificate_authority
    ;;
    * )
        echo No
        echo "### ${YEL} "
    ;;
esac

## SCRIPT 2 ##
read -p "Do you want to Associate a regional SSL certificate with a target HTTPS/LB? (y/N)" answer
case ${answer:0:1} in
    y|Y )
        set_target_https_lb
    ;;
    * )
        echo No
        exit
    ;;
esac

## RUN FUNCTIONS/ ##