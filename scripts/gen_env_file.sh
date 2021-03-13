#!/usr/bin/env bash
BASEPATH=$(dirname "$(realpath "$(dirname "$0")")")
source "$BASEPATH/config.conf"
[[ -n $POSTGRES_USERNAME ]] && POSTGRES_USERNAME=$POSTGRES_USERNAME || POSTGRES_USERNAME=$1
[[ -n $POSTGRES_PASSWORD ]] && POSTGRES_PASSWORD=$POSTGRES_PASSWORD || POSTGRES_PASSWORD=$2
RED='\033[0;31m'
NC='\033[0m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'

function help_manual(){
  printf "${GREEN}HELP${NC} $0 ${YELLOW}POSTGRES_USERNAME POSTGRES_PASSWORD\n${NC}"
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
arg_required POSTGRES_USERNAME $REQUIRED $POSTGRES_USERNAME
arg_required POSTGRES_PASSWORD $REQUIRED $POSTGRES_PASSWORD
cp "$BASEPATH/env/db.env.template" "$BASEPATH/env/db.env"
cp "$BASEPATH/env/sonar.env.template" "$BASEPATH/env/sonar.env"
sed -i "s/TEMPLATE_POSTGRES_USER/$POSTGRES_USERNAME/g"  "$BASEPATH/env/db.env" 
sed -i "s/TEMPLATE_POSTGRES_PASSWORD/$POSTGRES_USERNAME/g"  "$BASEPATH/env/db.env" 
sed -i "s/TEMPLATE_POSTGRES_USER/$POSTGRES_PASSWORD/g"  "$BASEPATH/env/sonar.env" 
sed -i "s/TEMPLATE_POSTGRES_PASSWORD/$POSTGRES_PASSWORD/g"  "$BASEPATH/env/sonar.env" 
