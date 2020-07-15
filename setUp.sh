certificate_data="LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUN5RENDQWJDZ0F3SUJBZ0lCQURBTkJna3Foa2lHOXcwQkFRc0ZBREFWTVJNd0VRWURWUVFERXdwcmRXSmwKY201bGRHVnpNQjRYRFRJd01EWXlOekU1TXpneU1sb1hEVE13TURZeU5URTVNemd5TWxvd0ZURVRNQkVHQTFVRQpBeE1LYTNWaVpYSnVaWFJsY3pDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnRVBBRENDQVFvQ2dnRUJBTmIrCkhRR1dOMEVHYW93eEc1QnJhUTdZMUMzT1pUUDFnaThzcXA1NjgxOERLbHE4dmJjaGVBZHFSeWxmTnhwMFdVYTYKL0phZHV0a2NlWGVzd3J3K0VXNW4xZ1lBTE8zTXNKUGlyQWlWbmlhUDM0V3ZjbEpZeDVrVlE0Y2V6K1NUV1JIQwpoS0N3bUZkVTJ5UWJUWG9RNW1lUlgybGJHT0ZOeTg0VHlNMzJiOEZlQmdTTTBXdXVmNmZRZm1EZkQ0N01RNnJNCjZ3bE9UMHRrMk0vQlVVVmFHSW5BQW1zNEhYY2lyRlRubkdwbEdLSVNQQjhEM0FjcUVqRmNnSS9Zb1lKRWpMS1UKUW9UWWxoWmFScnVQdEY0NXhTK3RTL25oZmV2cUYrZndRT2J0SVVFeSs3Mm9VRk1Tc3pZOGNxRUgzOVY0TmhtdwpxVHhUT0FGRzVkWHhUWG1EUG8wQ0F3RUFBYU1qTUNFd0RnWURWUjBQQVFIL0JBUURBZ0trTUE4R0ExVWRFd0VCCi93UUZNQU1CQWY4d0RRWUpLb1pJaHZjTkFRRUxCUUFEZ2dFQkFLcEtnb1Qrb1kxRXpSb3RSWlVhMmpjQlkrWGgKK2plNTVHQWwvOVRONEJRMms0dUNBQUNGUEdiaDlFdVI2OEZER1dwWjVTWTFSbWczZ2hTUXd5WlRjVFlpdmpoVQpISE44d0Fhb3hDMHVsdkdzVng1eTVnTHF0NkNlaExibW1tdWxZbWl4cmhtZjNHU0cvUnlpWElGNDRoazlOR3BLClg2aGIrZlhUSVVvVytnRUtjWXFnSnRjYWJ2WUF3QThEdXV0WndKSVp5VFBSVEVtZHNpUnV6K0xuTkFRSjdxZ2sKcEZxV1VJZGlXZHRIWmh1emxPYlgyTFVTL2ZIOFFudVV6VTdTaFBUQ1Y4TnNTeXBtNEo0SXNzUGhTeFRyQnRSeApCeURVL2JuU3Yzc1JhY0VqZTJORnJYZStNRkt1d1lXUU5UdUdaZHVUWjFUL2ZqemYrRDhxMHgyZFRLQT0KLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo="

ca_key=/etc/kubernetes/pki/ca.key
ca_crt=/etc/kubernetes/pki/ca.crt
ca_key_ENC=$(base64 -w 0 $ca_key)
ca_crt_ENC=$(base64 -w 0 $ca_crt)
#echo $ca_key_ENC
#echo $ca_crt_ENC

bash rmuser.sh

server="https://10.13.169.230:6443"

INPUTCSVFILE=./testUsers.csv ## Maybe update this later to take in user input and have a user give the file location of this file.


if [! -f $INPUTCSVFILE ] ;
then
        echo "$INPUTCSVFILE file not found"
        exit 1
fi

tmp=$(mktemp)
chmod 600 $tmp
grep -Ev '^[#;%]' $INPUTCSVFILE |tr -d ' \t' |grep -v '^$' >> $tmp
INPUTCSVFILE=$tmp
sh ./create_csv.sh $INPUTCSVFILE ## This will create the users and the grouping


for u in $(cat $INPUTCSVFILE)
do
    groupName="$(echo $u | cut -d "," -f 2)"
    usersName="$(echo $u | cut -d "," -f 1)"
    echo "The username is : $usersName"

    #kubectl create namespace $groupName

    echo "Creating a Private Key "
    #Make user key and csr
    openssl genrsa -out $usersName.key 2048
    openssl req -new -key $usersName.key -out $usersName.csr -subj "/CN=$usersName/O=$groupName"

    #make user crt
    openssl x509 -req -in $usersName.csr -CA $ca_crt -CAkey $ca_key -CAcreateserial -out $usersName.crt -days 500


    usr_key_ENC=$(base64 -w 0 $usersName.key)
    usr_crt_ENC=$(base64 -w 0 $usersName.crt)

    echo "We are now creating and moving files."
    mkdir /home/$usersName/.certs && mv $usersName.csr $usersName.crt $usersName.key /home/$usersName/.certs

    echo "Creating the .kube directory"
    mkdir -v /home/$usersName/.kube

    #Set context
    sudo -u mposada kubectl config set-context "$groupName-context" --cluster=kubernetes --user=$usersName --namespace=$groupName
userconfig="apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: $certificate_data
    server: $server
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    namespace: $groupName
    user: $usersName
  name: $groupName-context
current-context: $groupName-context
kind: Config
preferences: {}
users:
- name: $usersName
  user:
    client-certificate: /home/$usersName/.certs/$usersName.crt
    client-key: /home/$usersName/.certs/$usersName.key"

#Write to File
echo "Writing to config"
echo "$userconfig" >> /home/$usersName/.kube/config

roleconfig="apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
    namespace: $groupName
    name: $groupName-role
rules:
- apiGroups: ['*']
  resources: ['*']
  verbs: ['*']"

#Write to File
echo "Writing to role-deployment-manager"
echo "$roleconfig" >> /home/$usersName/.kube/role-deployment-manager.yml

rolebindingconfig="apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
    name: $groupName-rolebinding
    namespace: $groupName
subjects:
- kind: User
  name: $usersName
  apiGroup:
roleRef:
  kind: Role
  name: $groupName-role
  apiGroup: rbac.authorization.k8s.io"

#Write to File
echo "Writing to rolebinding-deployement-manager"
echo "$rolebindingconfig" >> /home/$usersName/.kube/rolebinding-deployment-manager.yml

echo "Creating the namespace for the group"
sudo -u mposada kubectl create namespace $groupName

echo "Manually setting certificates"
sudo -u mposada kubectl config set-credentials $usersName --client-certificate=/home/$usersName/.certs/$usersName.crt  --client-key=/home/$usersName/.certs/$usersName.key


echo "Create the role deployment"
sudo -u mposada kubectl create -f /home/$usersName/.kube/role-deployment-manager.yml
#sudo -u mposada kubectl apply -f /home/$usersName/.kube/role-deployment-manager.yml
echo "Create the role-binding"
#sudo -u mposada kubectl create -f /home/$usersName/.kube/rolebinding-deployment-manager.yml
sudo -u mposada kubectl apply -f /home/$usersName/.kube/rolebinding-deployment-manager.yml
echo "Giving the user a deployment!"
sudo -u mposada kubectl apply -n group666 -f /home/mposada/src/resource/deployment.yml
echo "Giving the user's rights for the new files that were created"
sudo chown -R $usersName:$groupName /home/$usersName/
done

#Exit
