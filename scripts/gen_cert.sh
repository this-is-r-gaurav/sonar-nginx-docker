#!/usr/bin/env bash
BASEPATH=$(dirname "$(realpath "$(dirname "$0")")")
source "$BASEPATH/config.conf"
[[ -n $HOST ]] && HOST=$HOST || HOST=$1
[[ -n $COUNTRY ]] && COUNTRY=$COUNTRY || COUNTRY=$2
[[ -n $STATE ]] && STATE=$STATE || STATE=$3
[[ -n $CITY ]] && CITY=$CITY || CITY=$4
[[ -n $ORG ]] && ORG=$ORG || ORG=$5
[[ -n $EMAIL ]] && EMAIL=$EMAIL || EMAIL=$6
RED='\033[0;31m'
NC='\033[0m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'

function help_manual(){
  printf "${GREEN}HELP${NC} $0 ${YELLOW}HOST_IP_ADDRESS COUNTRY STATE CITY ORG EMAIL\n${NC}"
}
function arg_required(){

  case $2 in
    1)
       if [[ -z $3 ]]; then 
         printf  "${RED}Error${NC}: ${YELLOW}$1${NC} Required\n\n"
         help_manual;
         exit 1
       fi
    ;;
    -1)
        printf "${YELLOW}$1${NC}: ${GREEN}$3${NC}\n\n"
    ;;
  esac

}
REQUIRED=1
NOT_REQUIRED=-1
arg_required 'HOST_IP_ADDRESS without (protocol)' $REQUIRED $HOST
arg_required 'COUNTRY INITIAL (For eg for INDIA: IN, USA: US) For More eg: https://www.digicert.com/kb/ssl-certificate-country-codes.htm' $REQUIRED $COUNTRY
arg_required 'STATE NAME' $REQUIRED $STATE
arg_required 'CITY' $REQUIRED $CITY
arg_required 'ORGANISATION' $REQUIRED $ORG
arg_required 'EMAIL' $REQUIRED $EMAIL
cp "$BASEPATH/config/config.cnf.template" "$BASEPATH/config/config.cnf"
sed -i "s/TEMPLATE_HOST_NAME/$HOST/g"  "$BASEPATH/config/config.cnf" 

sed -i "s/TEMPLATE_COUNTRY/$COUNTRY/g"  "$BASEPATH/config/config.cnf" 

sed -i "s/TEMPLATE_CITY/$CITY/g"  "$BASEPATH/config/config.cnf" 

sed -i "s/TEMPLATE_ORG/$ORG/g"  "$BASEPATH/config/config.cnf" 

sed -i "s/TEMPLATE_EMAIL/$EMAIL/g"  "$BASEPATH/config/config.cnf" 

sed -i "s/TEMPLATE_STATE/$STATE/g"  "$BASEPATH/config/config.cnf" 



echo "Create the root key"
openssl genrsa -out "$BASEPATH/certs/ca/root-ca.key" 4096

echo "Create a Root Certificate and self-sign it"
# Generate Root CA cert
openssl req -new -key "$BASEPATH/certs/ca/root-ca.key" -out "$BASEPATH/certs/ca/root-ca.csr" -config "$BASEPATH/config/config.cnf"
openssl x509 -req -days 365 -in "$BASEPATH/certs/ca/root-ca.csr" -signkey "$BASEPATH/certs/ca/root-ca.key" -out "$BASEPATH/certs/ca/root-ca.crt" -extensions v3_req -extfile "$BASEPATH/config/config.cnf"

echo "Create Sonar Certificate"
openssl genrsa  -out "$BASEPATH/certs/sonar/sonar.key" 4096

echo "Create Sonar CSR"
openssl req -new  -key "$BASEPATH/certs/sonar/sonar.key" -out "$BASEPATH/certs/sonar/sonar.csr" -config "$BASEPATH/config/config.cnf"

openssl x509 -req -in "$BASEPATH/certs/sonar/sonar.csr" -CA  "$BASEPATH/certs/ca/root-ca.crt" -CAkey "$BASEPATH/certs/ca/root-ca.key" -CAcreateserial -out "$BASEPATH/certs/sonar/sonar.crt" -days 365 -extensions v3_req -extfile "$BASEPATH/config/config.cnf"
cp "$BASEPATH/certs/ca/root-ca.crt" "$BASEPATH/scanner/root-ca.crt"
cp "$BASEPATH/certs/sonar/sonar.crt" "$BASEPATH/scanner/sonar.crt"

openssl dhparam -out "$BASEPATH/certs/sonar/dhparam.pem" 4096


