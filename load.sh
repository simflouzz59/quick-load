#!/bin/sh

#exemple
# ./load.sh "http://localhost:8080/api/v1/path" 1000 "-m 1"

BLACK='\033[0;30m'
RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHTGRAY='\033[0;37m'
DARKGRAY='\033[1;30m'
LIGHTRED='\033[1;31m'
LIGHTGREEN='\033[1;32m'
YELLOW='\033[1;33m'
LIGHTBLUE='\033[1;34m'
LIGHTPURPLE='\033[1;35m'
LIGHTCYAN='\033[1;36m'
WHITE='\033[1;37m'
NC='\033[0m'

i="0"
url=$1
count=$2
curlOptions=$3
executionCount="0"

validateNumber () {
	if [[ (! -z "$1") && ($1 =~ ^-?[0-9]+$) ]]
	then
		echo $1
	else 
		echo ''
	fi
}

validateHttpCode () {
	tmp=`validateNumber $1`
	if [ ! -z "$tmp" ]
	then
		echo $tmp
	else 
		echo 'Error curl, please check the log file'
	fi
}

validateYesNo () {
	if [[ "$1" =~ ^(y|yes)$ ]]
	then
		echo 'y'
	else 
		echo 'n'
	fi
}

launchLoadLoop () {
	responseCode="000"
    while [ $i -lt $count ]
    do
		displayProgress "$(($(($executionCount*100))/$count))" "${responseCode: -3}"
		responseCode=`curl -w ' - %{local_ip} - %{remote_ip} - %{time_total} sec - %{size_download} bytes downloaded- %{response_code}' -s $curlOptions $url 2>&1`
		echo "$responseCode" >> $(dirname $0)/curl.log

		i=$[$i+1]
		executionCount=$[$executionCount+1]
    done
	displayProgress "$(($(($executionCount*100))/$count))" "${responseCode: -3}"
}

getProgressString() {
	progressBarString=""
	value="0"
	while [ $value -lt $1 ]
	do
		progressBarString="$progressBarString#"
		value=$[$value+1]
	done
	value="0"
	while [ $value -lt $((50-$1)) ]
	do
		progressBarString="$progressBarString "
		value=$[$value+1]
	done
	echo "$progressBarString"
}

displayProgress () {
    pourcentage=$1
	lastResponseCode=`validateHttpCode $2`
	progressBar=`getProgressString $(($pourcentage/2))`
    echo -ne "\r${LIGHTGREEN}$progressBar| ${pourcentage}% ${NC}| ${LIGHTBLUE}$executionCount/$count ${NC}| ${LIGHTRED}$lastResponseCode (last response code)${NC}"
}

printf "${LIGHTCYAN}  _     ___    _    ____  _____ ____  \n";
printf " | |   / _ \  / \  |  _ \| ____|  _ \ \n";
printf " | |  | | | |/ _ \ | | | |  _| | |_) |\n";
printf " | |__| |_| / ___ \| |_| | |___|  _ < \n";
printf " |_____\___/_/   \_\____/|_____|_| \_\ \n";
printf "                                      ${NC}\n";

printf "${LIGHTGRAY}Exemple : \n> ${DARKGRAY}./load.sh \"http://localhost:8080/api/v1/path\" 1000${NC}\n\n"

user=`id -u -n`

printf "${LIGHTPURPLE}Hi${NC} ${LIGHTGREEN}$user${NC} !\n\n"

while [ -z "$url" ]
do
	printf "Please enter the ${LIGHTBLUE}url${NC} to load :\n> "
	read url
done

count=`validateNumber $count`

while [ -z "$count" ]
do
	printf "Please enter the ${LIGHTBLUE}number of curl${NC} to excecute :\n> "
	read count
	count=`validateNumber $count`
done

if [ -z "$curlOptions" ]
then
	printf "Please specify, if you want, the ${LIGHTBLUE}curl options${NC} (default : none, exemple : --ipv4 --keepalive-time 1 -m 1) :\n> "
	read curlOptions
fi

touch $(dirname $0)/curl.log
> $(dirname $0)/curl.log

printf "\nBegin of ${LIGHTBLUE}$count${NC} curl to ${LIGHTBLUE}$url${NC} ...${NC}\n\n"

launchLoadLoop

printf "\n\n${LIGHTBLUE}$executionCount${NC}/${LIGHTBLUE}$count${NC} curls done.\nLogs file is ${LIGHTGREEN}$(dirname $0)/curl.log${NC} , do you want print it ?(y/n)\n> "
read open
open=`validateYesNo $open`

if [ "$open" == "y" ]
then
	printf "\n"
	cat $(dirname $0)/curl.log
	printf "\n"
fi

printf "\n${LIGHTPURPLE}Bye !${NC}\n"

exit 0
