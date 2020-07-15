MOREF='sudo docker-compose ps | grep src'

echo $MOREF

sudo docker ps -aqf "$MOREF"

