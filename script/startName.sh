echo This script is to meant to create the namespaces for kubectl, how many teams are there?

read varteam



for ((c=1; c<=$varteam; c++))
do
    echo "$i"
    kubectl create namespace team"$c"
done

kubectl get namespace
