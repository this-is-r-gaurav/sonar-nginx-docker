#!/usr/bin/env sh
set -e
SONAR_SERVER=$1
SONAR_PROJECT_KEY=$2
SONAR_PROJECT_LOGIN=$3
RED='\033[0;31m'
NC='\033[0m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
function manual(){
   printf "${GREEN}HELP${NC} $0 ${YELLOW}SONAR_SERVER SONAR_PROJECT_KEY SONAR_PROJECT_LOGIN${NC}\n\n"
}
function arg_required(){

  case $2 in
    1)
       if [[ -z $3 ]]; then 
         printf  "${RED}Error${NC}: ${YELLOW}$1${NC} Required\n\n"
         manual;
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
arg_required SONAR_SERVER_IP $REQUIRED $SONAR_SERVER;
arg_required  SONAR_PROJECT_KEY $REQUIRED $SONAR_PROJECT_KEY;
arg_required  SONAR_PROJECT_LOGIN $REQUIRED $SONAR_PROJECT_LOGIN;
arg_required GIT_BRANCH $NOT_REQUIRED $GIT_BRANCH;
ls /bin/sonar
GIT_PROJECT=$(find /workspace/ -mindepth 1 -maxdepth 1 -type d  -print)
echo $GIT_PROJECT
cp /workspace/sonar-project.properties $GIT_PROJECT/sonar-project.properties
cd $GIT_PROJECT
/bin/sonar/bin/sonar-scanner -Dsonar.projectKey="$SONAR_PROJECT_KEY" -Dsonar.sources=. -Dsonar.host.url="https://$SONAR_SERVER" -Dsonar.login="$SONAR_PROJECT_LOGIN"
