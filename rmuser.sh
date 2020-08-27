#!/bin/bash

echo "$(tput setaf 3)"

rm -rf home/groups/group100
rm -rf home/groups/group200

deluser --remove-home testuser101
deluser --remove-home testuser102
deluser --remove-home testuser201
deluser --remove-home testuser202

sudo -u mposada kubectl delete namespace group100
sudo -u mposada kubectl delete namespace group200

#done
