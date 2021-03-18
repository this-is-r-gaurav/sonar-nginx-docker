#!/usr/bin/env sh
BASEPATH="$(realpath "$(dirname "$0")")"
set -e
if [[ -f "$BASEPATH/sonar.variables" ]]; then
  source "$BASEPATH/sonar.variables"
else
  if [[ -f "/var/sonar.variables" ]]; then
    source "/var/sonar.variables"
  fi
fi

[[ -n $SONAR_SERVER ]] && SONAR_SERVER=$SONAR_SERVER || SONAR_SERVER=$1;
[[ -n $SONAR_PROJECT_KEY ]] && SONAR_PROJECT_KEY=$SONAR_PROJECT_KEY || SONAR_PROJECT_KEY=$2;
[[ -n $SONAR_PROJECT_LOGIN ]] && SONAR_PROJECT_LOGIN=$SONAR_PROJECT_LOGIN || SONAR_PROJECT_LOGIN=$3
[[ -n $PROJECT_BRANCH ]] && PROJECT_BRANCH=$PROJECT_BRANCH || PROJECT_BRANCH=$4
[[ -n $SONAR_PROJECT_NAME ]] && SONAR_PROJECT_NAME=$SONAR_PROJECT_NAME || SONAR_PROJECT_NAME=$5
[[ -n $SONAR_COMMUNITY ]] && SONAR_COMMUNITY=$SONAR_COMMUNITY || SONAR_COMMUNITY=$6
if [[ -n $SONAR_COMMUNITY ]];then
  SONAR_COMMUNITY="yes"
fi 
RED='\033[0;31m'
NC='\033[0m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
function manual(){
	printf "${GREEN}HELP${NC} $0 ${YELLOW}SONAR_SERVER SONAR_PROJECT_KEY SONAR_PROJECT_LOGIN PROJECT_BRANCH [SONAR_PROJECT_NAME] [SONAR_COMMUNITY (yes/no, Default: yes) ] ${NC}\n\n"
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
arg_required PROJECT_BRANCH $REQUIRED $PROJECT_BRANCH
GIT_PROJECT=$(find /workspace/ -mindepth 1 -maxdepth 1 -type d  -print)
echo $GIT_PROJECT
cd $GIT_PROJECT
CURRENT_BRANCH=$(git branch --show-current);
if [[ $SONAR_COMMUNITY != "yes" &&  $CURRENT_BRANCH != $PROJECT_BRANCH ]]; then
  echo "Please checkout source code to $PROJECT_BRANCH, current branch is $CURRENT_BRANCH";
  exit 1
fi
if [[ $SONAR_COMMUNITY == "yes"  ]];then
  PROJECT_BRANCH=''
fi
cp /workspace/sonar-project.properties $GIT_PROJECT/sonar-project.properties
SCANNER_ARGS="-Dsonar.projectKey=$SONAR_PROJECT_KEY -Dsonar.sources=. -Dsonar.host.url=https://$SONAR_SERVER -Dsonar.login=$SONAR_PROJECT_LOGIN"
if [[ -n $SONAR_PROJECT_NAME ]];then
  SCANNER_ARGS="$SCANNER_ARGS -Dsonar.projectName=$SONAR_PROJECT_NAME"
fi
if [[ -n $PROJECT_BRANCH ]];then
  SCANNER_ARGS="$SCANNER_ARGS -Dsonar.branch.name=$PROJECT_BRANCH"
fi

/bin/sonar/bin/sonar-scanner $SCANNER_ARGS
