#!/bin/bash

##So we swap out 100 with the team name which will be the namespace as well. It will be used by the setUp.sh Script to get the IP address for Leune

echo $1
x="$(kubectl get all --all-namespaces | grep $1 | grep tool |grep -oP '192.168.43.\S+')"
sudo echo "$1 IP Address:" $x >> userInfo.txt
