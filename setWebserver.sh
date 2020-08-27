sudo usermod -aG www-data postgres

echo "############################################################################################################################################################################################################################################"
echo "##													Setting Up the Postgres DBMS for WWW-DATA                                                                                         ##"
echo "#######################################################################################################################################################################################################################################"

sudo -su postgres psql -c "CREATE DATABASE ctf";
##Issue Here
sudo -su postgres psql -d ctf -c 'CREATE ROLE "www-data" LOGIN';
sudo -su postgres psql -d ctf -c "CREATE TABLE login(username VARCHAR(50) UNIQUE NOT NULL, password VARCHAR(50) NOT NULL)";
##Issue Here
sudo -su postgres psql -d ctf -c 'GRANT SELECT ON login TO "www-data"';



##sudo cat <<EOT >> /etc/apache2/apache2.conf
##<FilesMatch \.php$>
##SetHandler application/x-httpd-php
##</FilesMatch>
##EOT

sudo a2dismod mpm_event && sudo a2enmod mpm_prefork && sudo a2enmod php12.0

sudo systemctl restart apache2



