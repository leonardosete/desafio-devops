#!/bin/sh

## The main goal of this script is: ##
## Create a Self-Signed Certificate in GCP ##
## DOCS: https://cloud.google.com/load-balancing/docs/ssl-certificates/self-managed-certs

################
## ENV COLOR####
################
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color
REGION="us-central1"
########################
## INTERACTIVE SCRIPT ##
########################
   read -p "Do you want to crete a Self-Signed Certificate? (y/n)? " answer
   case ${answer:0:1} in
       y|Y )
           echo Yes
       ;;
       * )
           echo No
           exit
       ;;
   esac

#########################
## INTERACTIVE SCRIPT/ ##
#########################


##################################
### Creating a Certificate SSL ###
##################################
### /VARS ###
PRIVATE_KEY_FILE="./scripts/certs/$DOMAIN_NAME-key.pem" ## The path and filename for the new private key file.
CONFIG_FILE="./scripts/certs/$DOMAIN_NAME.openssl_config" ## The path, including the file name, for the OpenSSL configuration file.
SUBJECT_ALTERNATIVE_NAME_1="$DOMAIN_NAME" ## Subject Alternative Names for your certificate
SUBJECT_ALTERNATIVE_NAME_2="www.$DOMAIN_NAME" ## Subject Alternative Names for your certificate
CSR_FILE="./scripts/certs/$DOMAIN_NAME.csr_file" ## The path to the CSR
CERTIFICATE_FILE="./scripts/certs/$DOMAIN_NAME-crt.pem" ## The path to the certificate file to create
TERM="365" ## The number of days, from now, during which the certificate should be considered valid by clients that verify it.
CERTIFICATE_NAME="$DOMAIN_NAME" ## A name for the global SSL certificate
DOMAIN_LIST= " " ## A single domain name or a comma-delimited list of domain names to use for this certificate
REGION="us-central1" ## Region for the regional SSL certificate ## Default region's Project - Change if needed.
### VARS/ ###

    echo "###${YEL}5-The Private Key Name to create${NC} ###"
    echo " "
    openssl genrsa 2048 > ./scripts/certs/$PRIVATE_KEY_FILE

    echo "###${YEL}6-The OpenSSL Config file to create${NC} ###"
    echo " "

#######################################
### Creating a  OpenSSL Config file ###
#######################################
cat <<'EOF' >$CONFIG_FILE
[req]
default_bits              = 2048
req_extensions            = extension_requirements
distinguished_name        = dn_requirements

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
#############################################
### END - Creating a  OpenSSL Config file ###
#############################################

    echo "###${YEL}7-Creating Certificate Signing Request file${NC} ###"
    echo " "
    openssl req -new -key $PRIVATE_KEY_FILE \
        -out $CSR_FILE \
        -config $CONFIG_FILE

    echo "###${YEL}8-Creating Self-Signed Certificate Resource ${NC} ###"
    echo " "
    openssl x509 -req \
        -signkey $PRIVATE_KEY_FILE \
        -in $CSR_FILE \
        -out $CERTIFICATE_FILE \
        -extfile $CONFIG_FILE \
        -extensions extension_requirements \
        -days $TERM

    echo "###${YEL}9-Creating Self-Signed Certificate${NC} ###"
    echo " "
    gcloud compute ssl-certificates create $CERTIFICATE_NAME \
        --certificate=$CERTIFICATE_FILE \
        --private-key=$PRIVATE_KEY_FILE \
        --region=$REGION

    echo "###${YEL}10-To associate a regional SSL certificate with a target HTTPS proxy${NC} ###"
    echo " "
    gcloud compute target-https-proxies update TARGET_PROXY_NAME \
        --region=$REGION \
        --ssl-certificates=$CERTIFICATE_LIST \
        --ssl-certificates-region=REGION