#!/bin/bash

rm -rf home/groups/group666

deluser --remove-home testuser666

sudo -u mposada kubectl delete namespace group666
#done
