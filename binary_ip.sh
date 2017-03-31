#!/bin/bash
##########################################################################################################
# Name: binary_ip
# Author: Hiei <blascogasconiban@gmail.com>
# Version: 1.0/stable
# Description:
#              This simple script transforms any ipv4 IP to binary. (Can also transform one single number)
##########################################################################################################

NUMBER=128 ; bold=$(tput bold);red=$(tput setaf 1);reset=$(tput sgr0);yellow=$(tput setaf 3) #colors

function transformation() {
IP="$1" #Just to avoid problems
for ((i=1;i<=8;i++)) #128 | 64 | 32 | 16 | 8 | 4 | 2 | 1
do
  if [ "$IP" -ge $NUMBER ] 2>/dev/null ; then
    echo -n "${red}1"
    IP=$((IP-NUMBER))
  else
    echo -n "${yellow}0"
  fi
  NUMBER=$((NUMBER/2))
done
NUMBER=128 #reset number back to 128
echo -n "${reset}$2"
}

if ! [[ "$1" =~ ^[0-9]*\.*[0-9]*\.*[0-9]*\.*[0-9]*$ ]] || [ ! $# -eq 1 ]; then #Regex to avoid non-number characters except '.'
  echo "${red}${bold}¡WARNING!: ${yellow}Give a good argument [e.g '192.168.221.103']"
  exit 1
fi

FIRST="$(echo "$1" | cut -d"." -f1)" ; transformation "$FIRST" "." #Dividing the numbers by fields
SECOND="$(echo "$1" | cut -d"." -f2)" ; transformation "$SECOND" "."
THIRD="$(echo "$1" | cut -d"." -f3)" ; transformation "$THIRD" "."
FOURTH="$(echo "$1" | cut -d"." -f4)" ; transformation "$FOURTH"
echo;echo "${yellow}${bold}IP: $FIRST.$SECOND.$THIRD.$FOURTH${reset}"
exit 0
