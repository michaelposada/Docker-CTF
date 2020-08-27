#!/bin/bash
#Applies Flag 8 to CreateDB.

if [ "$(/usr/bin/whoami)" != "root" ] ;
then
        echo "Must be Root!"
        exit 1
fi

if [ $# != 1 ]
then
        echo "Must provide flag 8!"
        exit 1
fi

sed "s/FLAG8/$1/" CreateDB.sql > CreateDB_Flagged.sql
