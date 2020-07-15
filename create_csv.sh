#!/bin/bash
#Creates user accounts with random passwords and assigns users to group
#Made based off Dr. Leune's BULK_CREATE script

#Arg1: File with a username on each line
#Arg2: File with a group name on each line

EXPIRE="2028-07-15"

if [ "$(/usr/bin/whoami)" != "root" ] ;
then
        echo "Must be Root!"
        exit 1
fi

if [ $# != 1 ]
then
        echo "Must provide single CSV, with usernames in Column 1, and groups in Column2"
        exit 1
fi

if [ ! -f $1 ]
then
        echo "$1 is not a file or it cannot be read"
        exit 1
fi

# remove comments and empty lines
tmp=$(mktemp)
chmod 600 $tmp
grep -Ev '^[#;%]' $1 |tr -d ' \t' |grep -v '^$' >> $tmp

# Create Accounts
for u in $(cat $tmp);
do
        #Processes Line
        group="$(echo $u | cut -d "," -f 2)"
        u="$(echo $u | cut -d "," -f 1)"
        id=$(/usr/bin/id -a $u 2> /dev/null)

        #Checks if Group Exists
        if [ ! -d "/home/groups/$group" ];
        then
                groupadd $group
                mkdir /home/groups/$group
                chgrp $group /home/groups/$group
                chmod g+rwx -R /home/groups/$group
                chmod g+s -R /home/groups/$group
        fi

        if [ "$id" != "" ];
        then
                if [ "$group" != "" ];
                then
                        echo "Skipping $u (Already Exists). Updated Expiration, Added Group $group"
                        /usr/bin/chage -E ${EXPIRE} $u
                        usermod -a -G $group $u
                else
                        echo "$u Already Exists, and has no Group. Updating Expiration"
                        /usr/bin/chage -E ${EXPIRE} $u
                fi
        else
                pw=$(/usr/bin/makepasswd --chars=8)
                /usr/sbin/useradd -s /bin/bash -m --expiredate ${EXPIRE} $u
                chmod 751 /home/$u
                echo "$u:$pw" |/usr/sbin/chpasswd

                if [ "$group" != "" ];
                then
                        echo "New User: $u with password $pw, group $group" | tee -a created/newHistory.txt
                        usermod -a -G $group $u
                else
                        echo "New User: $u with password $pw, But no Group!" | tee -a created/newHistory.txt
                fi
                echo ""
        fi

done

