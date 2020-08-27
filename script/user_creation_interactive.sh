#!/bin/bash

#To take from the admin-cluster config (to modify)
certificate_data="LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUN5RENDQWJDZ0F3SUJBZ0lCQURBTkJna3Foa2lHOXcwQkFRc0ZBREFWTVJNd0VRWURWUVFERXdwcmRXSmwKY201bGRHVnpNQjRYRFRJd01EWXlOekU1TXpneU1sb1hEVE13TURZeU5URTVNemd5TWxvd0ZURVRNQkVHQTFVRQpBeE1LYTNWaVpYSnVaWFJsY3pDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnRVBBRENDQVFvQ2dnRUJBTmIrCkhRR1dOMEVHYW93eEc1QnJhUTdZMUMzT1pUUDFnaThzcXA1NjgxOERLbHE4dmJjaGVBZHFSeWxmTnhwMFdVYTYKL0phZHV0a2NlWGVzd3J3K0VXNW4xZ1lBTE8zTXNKUGlyQWlWbmlhUDM0V3ZjbEpZeDVrVlE0Y2V6K1NUV1JIQwpoS0N3bUZkVTJ5UWJUWG9RNW1lUlgybGJHT0ZOeTg0VHlNMzJiOEZlQmdTTTBXdXVmNmZRZm1EZkQ0N01RNnJNCjZ3bE9UMHRrMk0vQlVVVmFHSW5BQW1zNEhYY2lyRlRubkdwbEdLSVNQQjhEM0FjcUVqRmNnSS9Zb1lKRWpMS1UKUW9UWWxoWmFScnVQdEY0NXhTK3RTL25oZmV2cUYrZndRT2J0SVVFeSs3Mm9VRk1Tc3pZOGNxRUgzOVY0TmhtdwpxVHhUT0FGRzVkWHhUWG1EUG8wQ0F3RUFBYU1qTUNFd0RnWURWUjBQQVFIL0JBUURBZ0trTUE4R0ExVWRFd0VCCi93UUZNQU1CQWY4d0RRWUpLb1pJaHZjTkFRRUxCUUFEZ2dFQkFLcEtnb1Qrb1kxRXpSb3RSWlVhMmpjQlkrWGgKK2plNTVHQWwvOVRONEJRMms0dUNBQUNGUEdiaDlFdVI2OEZER1dwWjVTWTFSbWczZ2hTUXd5WlRjVFlpdmpoVQpISE44d0Fhb3hDMHVsdkdzVng1eTVnTHF0NkNlaExibW1tdWxZbWl4cmhtZjNHU0cvUnlpWElGNDRoazlOR3BLClg2aGIrZlhUSVVvVytnRUtjWXFnSnRjYWJ2WUF3QThEdXV0WndKSVp5VFBSVEVtZHNpUnV6K0xuTkFRSjdxZ2sKcEZxV1VJZGlXZHRIWmh1emxPYlgyTFVTL2ZIOFFudVV6VTdTaFBUQ1Y4TnNTeXBtNEo0SXNzUGhTeFRyQnRSeApCeURVL2JuU3Yzc1JhY0VqZTJORnJYZStNRkt1d1lXUU5UdUdaZHVUWjFUL2ZqemYrRDhxMHgyZFRLQT0KLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo=
="
server="https://10.13.169.230:6443"

#The default path for Kubernetes CA
ca_path="/etc/kubernetes/pki"

#The default name for the Kubernetes cluster
cluster_name="kubernetes"


create_user() {

	#Create the user
	printf "User creation\n"
	useradd $user

	#Create private Key for the user
	printf "Private Key creation\n"
	openssl genrsa -out $filename.key 2048

	#Create the CSR
	printf "\nCSR Creation\n"
	if [ $group == "None" ]; then
		openssl req -new -key $filename.key -out $filename.csr -subj "/CN=$user"
	else
		openssl req -new -key $filename.key -out $filename.csr -subj "/CN=$user/O=$group"
	fi 

	#Sign the CSR 
	printf "\nCertificate Creation\n"
	openssl x509 -req -in $filename.csr -CA $ca_path/ca.crt -CAkey $ca_path/ca.key -CAcreateserial -out $filename.crt -days $days

	#Create the .certs and mv the cert file in it
	printf "\nCreate .certs directory and move the certificates in it\n" 
	mkdir $user_home/.certs && mv $filename.* $user_home/.certs

	#Create the credentials inside kubernetes
	printf "\nCredentials creation\n"
	kubectl config set-credentials $user --client-certificate=$user_home/.certs/$user.crt  --client-key=$user_home/.certs/$user.key

	#Create the context for the user
	printf "\nContext Creation\n"
	kubectl config set-context $user-context --cluster=$cluster_name --user=$user

	#Edit the config file
	printf "\nConfig file edition\n"
	mkdir $user_home/.kube
	cat <<-EOF > $user_home/.kube/config
	apiVersion: v1
	clusters:
	- cluster:
	    certificate-authority-data: $certificate_data
	    server: $server
	  name: $cluster_name
	contexts:
	- context:
	    cluster: $cluster_name
	    user: $user
	  name: $user-context
	current-context: $user-context
	kind: Config
	preferences: {}
	users:
	- name: $user
	  user:
	    client-certificate: $user_home/.certs/$user.crt
	    client-key: $user_home/.certs/$user.key
	EOF
	
	#Change the the ownership of the directory and all the files
	printf "\nOwnership update\n"
	sudo chown -R $user: $user_home



}




response=
echo "Give the CN of the user : "
read response
if [ -n "$response" ]; then
	
	user=$response
	
	echo "Give the Group of the user (If there is no group left it blank): "
	read response
	if [ -n "$response" ];then
		group=$response
	else
		group="None"
	fi

	echo "Give the number of days for the certificate (360 days by default if you left it blank): "
	read response
	if [ -n "$response" ];then
		days=$response
	else
		days=360
	fi

	
	#Set up variables
	user_home="/home/$user"
	filename=$user_home/$user
	
	echo "------------------------------------"
	
	#Execute the function create_user
	create_user
	exit

else
	echo "Username is required"
	exit
fi
