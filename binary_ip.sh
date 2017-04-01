#!/bin/bash
##########################################################################################################
# Name: binary_ip
# Author: Hiei <blascogasconiban@gmail.com>
# Version: 2.0/stable
# Description:
#              This simple script transforms your IPV4 ip to binary and gives all related information about
#              it, If you also use other number [./binary_ip 192.168.1.1 4] Will show which mask and the ranges
#              for your subnetting
#
# (c) Hiei. You can redistribute this program under GNU GPL.
# sáb 01 abr 2017 15:00:23 CEST
##########################################################################################################

bold=$(tput bold);red=$(tput setaf 1);reset=$(tput sgr0);yellow=$(tput setaf 3) ; echo
D2B=({0..1}{0..1}{0..1}{0..1}{0..1}{0..1}{0..1}{0..1})
TYPE="Public"
NETWORK="Not defined"
BROADCAST="255.255.255.255"
BITS=8
BINARY=()
TOTAL_MASK=32
SUBREDES="$2"
FIRST=$(echo "$1" | cut -d"." -f1);FIRST_B=${D2B[$FIRST]} #Dividing and transforming the numbers by fields
SECOND=$(echo "$1" | cut -d"." -f2);SECOND_B=${D2B[$SECOND]}
THIRD=$(echo "$1" | cut -d"." -f3);THIRD_B=${D2B[$THIRD]}
FOURTH=$(echo "$1" | cut -d"." -f4);FOURTH_B=${D2B[$FOURTH]}

function ip-type() {
  if [ "$1" -lt 128 ]; then
    CLASS=A
    NETWORK="$FIRST.0.0.0"
    BROADCAST="255.0.0.0"
    CLASS_MASK=8
    if [ "$1" = 10 ]; then
      TYPE="Private"
    fi
  elif [ "$1" -lt 192 ]; then
    CLASS=B
    NETWORK="$FIRST.$SECOND.0.0"
    BROADCAST="255.255.0.0"
    CLASS_MASK=16
    if (( "$1" == 172 && "$2" >= 16 && "$2" <= 31 )); then
      TYPE="Private"
    fi
  elif [ "$1" -lt 224 ]; then
    CLASS=C
    NETWORK="$FIRST.$SECOND.$THIRD.0"
    BROADCAST="255.255.255.0"
    CLASS_MASK=24
    if (( "$1" == 192 && "$2" == 168 )); then
      TYPE="Private"
    fi
  elif [ "$1" -lt 240 ]; then
    CLASS=D
    TYPE="Multicasting"
  elif [ "$1" -le 255 ]; then
    CLASS=E
    TYPE="Reserved"
  else
    echo "Type a valid IP" ; exit 1
  fi
}

function subnet() {
  #MASK
  if [ "$CLASS" = "C" -o "$CLASS" = "B" ]; then
    for ((i=0;i<=32;i++))
    do
      if [ "$(echo "2 ^ $i - 2" | bc)" -ge "$SUBREDES" ]; then
        MASK=$((CLASS_MASK+i))
        F_CONSTANT_1=$((MASK-CLASS_MASK))
        F_CONSTANT_0=$((BITS-F_CONSTANT_1))
        echo "${bold}${yellow}The mask you need for $SUBREDES subnets is: ${red}$MASK "
        break
      fi
    done
  else
    for ((i=0;i<=32;i++))
    do
      if [ "$(echo "2 ^ $i" | bc)" -ge "$SUBREDES" ]; then
        MASK=$((CLASS_MASK+i))
        F_CONSTANT_1=$((MASK-CLASS_MASK))
        F_CONSTANT_0=$((BITS-F_CONSTANT_1))
        echo "${bold}${yellow}The mask you need for $SUBREDES subnets is: ${red}$MASK "
        break
      fi
    done
  fi
  #HOSTS
  USABLE_BITS=$((TOTAL_MASK-MASK))
  HOSTS=$(echo "2 ^ $USABLE_BITS - 2" | bc)
  echo "${yellow}HOSTS:${red} $HOSTS" ; echo
  #TRANSLATING MASK TO BINARY
  for ((i=1;i<=F_CONSTANT_1;i++))
  do
    BINARY+="1"
  done
  for ((i=1;i<=F_CONSTANT_0;i++))
  do
    BINARY+="0"
  done
  CONSTANT=$((256-$((2#${BINARY[*]})))) #jumps between different subnets
  NM=1

  if [ $CLASS = "C" ]; then
    for ((i=0;i<=$((CONSTANT*SUBREDES-1));i+=CONSTANT))
    do
      echo "${yellow}Subred $NM:${red} $FIRST.$SECOND.$THIRD.$i to $FIRST.$SECOND.$THIRD.$((i+CONSTANT-1))"
      NM=$((NM+1))
    done
    echo
  elif [ $CLASS = "B" ]; then
    for ((i=0;i<=$((CONSTANT*SUBREDES-1));i+=CONSTANT))
    do
      echo "${yellow}Subred $NM:${red} $FIRST.$SECOND.$i.0 to $FIRST.$SECOND.$((i+CONSTANT-1)).255"
      NM=$((NM+1))
    done
    echo
  else
    for ((i=0;i<=$((CONSTANT*SUBREDES-1));i+=CONSTANT))
    do
      echo "${yellow}Subred $NM:${red} $FIRST.$i.0.0 to $FIRST.$((i+CONSTANT-1)).255.255"
      NM=$((NM+1))
    done
    echo
  fi


}

if [ $# -eq 1 ]; then
  ip-type "$FIRST" "$SECOND" "$THIRD"
elif [ $# -eq 2 ]; then
  ip-type "$FIRST" "$SECOND" "$THIRD"
  subnet
fi

echo "${bold}${yellow}$1" ; echo "${red}$FIRST_B.$SECOND_B.$THIRD_B.$FOURTH_B"
echo "${yellow}$CLASS $TYPE $NETWORK $BROADCAST"
echo