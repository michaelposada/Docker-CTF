path=$(pwd)
echo $path 

sudo  mkdir /var/www/.kube
sudo cp /etc/kubernetes/admin.conf /var/www/.kube 

sudo cp $path/resource/WebServer/* /var/www/html/

sudo echo $path >> /var/www/html/pathing.txt

sudo chown -R www-data:www-data /var/www/
