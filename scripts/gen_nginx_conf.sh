#!/usr/bin/env bash
BASEPATH=$(dirname "$(realpath "$(dirname "$0")")")
source "$BASEPATH/config.conf"
[[ -n $HOST ]] && HOST=$HOST || HOST=$1
RED='\033[0;31m'
NC='\033[0m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'

function help_manual(){
  printf "${GREEN}HELP${NC} $0 ${YELLOW}HOST_NAME/HOST_IP_ADDRESS\n${NC}"
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
arg_required 'HOST_NAME/HOST_IP_ADDRESS without (protocol)' $REQUIRED $HOST
cp "$BASEPATH/nginx/nginx.conf.template" "$BASEPATH/nginx/nginx.conf"
sed -i "s/TEMPLATE_HOST_NAME/$1/g"  "$BASEPATH/nginx/nginx.conf" 
