#!/bin/bash
#PARAMS:
#       Text file with Flags
#
#
#Assigns flags to docker exercise
#Number of expected flags is FLAGS

#Requires Posgress

FLAGS=10
GARBAGESIZE=100


if [ "$(/usr/bin/whoami)" != "root" ] ;
then
        echo "Must be Root!"
        exit 1
fi

if [ $# != 1 ]
then
        echo "Must provide text file full of flags"
        exit 1
fi

# remove comments and empty lines
tmp=$(mktemp)
chmod 600 $tmp
grep -Ev '^[#;%]' $1 |tr -d ' \t' |grep -v '^$' >> $tmp

numFlags=$(wc -l $tmp| cut -d ' ' -f 1)

if [ $numFlags != $FLAGS ]
then
        echo "Wrong Ammount of Flags! Try configuring expected flags"
        exit 1
fi

#Remove files if exist
rm -Rf garbage/
rm -f .flag1.txt
rm -Rf restricted/
rm -Rf work/
rm -Rf .passwords/
rm -Rf scripts/
rm -Rf .keys/
deluser --remove-home AdminDave

#Start Postgresql
update-rc.d postgresql enable
#systemctl enable postgresql
#systemctl start postgresql
service postgresql start

flag1=$(awk '{if(NR==1) print $0}' $tmp)
flag2=$(awk '{if(NR==2) print $0}' $tmp)
flag3=$(awk '{if(NR==3) print $0}' $tmp)
flag4=$(awk '{if(NR==4) print $0}' $tmp)
flag5=$(awk '{if(NR==5) print $0}' $tmp)
flag6=$(awk '{if(NR==6) print $0}' $tmp)
flag7=$(awk '{if(NR==7) print $0}' $tmp)
flag8=$(awk '{if(NR==8) print $0}' $tmp)
flag9=$(awk '{if(NR==9) print $0}' $tmp)
flag10=$(awk '{if(NR==10) print $0}' $tmp)

#Flag found with ls -a

echo $flag1 > .flag1.txt
chmod 744 .flag1.txt

#Flag found with restricted sudo
mkdir restricted
mkdir work
echo $flag3 > restricted/flag2.txt
chmod 600 restricted/flag2.txt

echo ALL ALL=NOPASSWD: /bin/cat | EDITOR='tee -a' visudo

#Flag found with grep -ri flag garbage/

mkdir garbage

#make $GARBAGESIZE garbage files
for n in $(seq 1 $GARBAGESIZE); do
        dd if=/dev/urandom of=/garbage/file$(printf %03d "$n" ).bin bs=1 count=$(( RANDOM + 1024 ))
done

#Randomly assign flag
randNum=$(( ( RANDOM % $GARBAGESIZE ) + 1 ))
randFile="file"$( printf %03d "$randNum")".bin"

#Append
echo "Flag: " > /garbage/"$randFile"
echo $flag3 >> /garbage/"$randFile"
chmod 744 -R /garbage

#Flag Found with various decoding methods

#Base64 encoded
mkdir .passwords
echo $flag4 | base64 > .passwords/bob.txt

#Des Encrypt with passphrase "Banana"
echo $flag5 > .passwords/plain.txt
openssl des -e -in .passwords/plain.txt -out .passwords/alice.txt -k "Banana"
rm -f .passwords/plain.txt

#Steal a user account
useradd -s /bin/bash -m --expiredate "2099-1-1" AdminDave
chmod 751 /home/AdminDave
echo "AdminDave:p4sswuuurd" | chpasswd
echo "AdminDave:p4sswuuurd" > .passwords/daveP.txt
echo "$flag6" >> .passwords/daveP.txt

mkdir .keys
openssl rand -base64 32 > .keys/key.bin
openssl enc -aes-256-cbc -salt -in .passwords/daveP.txt -out .passwords/dave.txt -pass file:.keys/key.bin
rm -f .passwords/daveP.txt

#Send an Email
echo "
/============================================\
|         Welcome to Arena Co. Server        |
|                                            |
|Email AdminDave@mail.adelphi.edu for support|
\============================================/
" > /etc/update-motd.d/99-motd-tail
chmod +x /etc/update-motd.d/99-motd-tail

#Put Flag7 in Email

#Find Flag in postgres
service postgresql status
#systemctl status postgresql
sudo -u postgres psql postgres -c "CREATE USER \"AdminDave\" WITH PASSWORD 'p4sswuuurd'";
#udo -u postgres psql postgres -c "CREATE ROLE \"AdminDave\" WITH ALL";
sudo -u postgres psql postgres -c "CREATE TABLE users(username char(256), password char(256))";
sudo -u postgres psql postgres -c "INSERT INTO users VALUES ('AdminDave','$flag8')"
echo "AdminDave  ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/AdminDave

#Hides Flag in Admindave's files, along with link to site
echo "Fix problems on webserver (Use NMAP to Find it)" > /home/AdminDave/TODO.txt
echo "Sell Bitcoins" >> /home/AdminDave/TODO.txt
echo "Fix Vulnerabilities on Server" >> /home/AdminDave/TODO.txt
echo "$flag9" >> /home/AdminDave/TODO.txt

chmod 700 -R /home/AdminDave
chown -R AdminDave:AdminDave /home/AdminDave

#Hides Flag in Visudo
echo "#$flag10" | sudo EDITOR='tee -a' visudo

#Exit
