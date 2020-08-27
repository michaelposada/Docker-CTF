echo "$(tput setaf 2)==============================================================================================================="
echo "==                                                  $(tput setaf 4)Set Up Script Now Launching                              =="
echo "==                                                  $(tput setaf 6)Version: 1.0 Beta                                        =="
echo "$(tput setaf 2)==============================================================================================================="

echo "$(tput setaf 7)"


echo $1



#This Certificate is for the Master Node of Kubes
certificate_data="LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUN5RENDQWJDZ0F3SUJBZ0lCQURBTkJna3Foa2lHOXcwQkFRc0ZBREFWTVJNd0VRWURWUVFERXdwcmRXSmwKY201bGRHVnpNQjRYRFRJd01EWXlOekU1TXpneU1sb1hEVE13TURZeU5URTVNemd5TWxvd0ZURVRNQkVHQTFVRQpBeE1LYTNWaVpYSnVaWFJsY3pDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnRVBBRENDQVFvQ2dnRUJBTmIrCkhRR1dOMEVHYW93eEc1QnJhUTdZMUMzT1pUUDFnaThzcXA1NjgxOERLbHE4dmJjaGVBZHFSeWxmTnhwMFdVYTYKL0phZHV0a2NlWGVzd3J3K0VXNW4xZ1lBTE8zTXNKUGlyQWlWbmlhUDM0V3ZjbEpZeDVrVlE0Y2V6K1NUV1JIQwpoS0N3bUZkVTJ5UWJUWG9RNW1lUlgybGJHT0ZOeTg0VHlNMzJiOEZlQmdTTTBXdXVmNmZRZm1EZkQ0N01RNnJNCjZ3bE9UMHRrMk0vQlVVVmFHSW5BQW1zNEhYY2lyRlRubkdwbEdLSVNQQjhEM0FjcUVqRmNnSS9Zb1lKRWpMS1UKUW9UWWxoWmFScnVQdEY0NXhTK3RTL25oZmV2cUYrZndRT2J0SVVFeSs3Mm9VRk1Tc3pZOGNxRUgzOVY0TmhtdwpxVHhUT0FGRzVkWHhUWG1EUG8wQ0F3RUFBYU1qTUNFd0RnWURWUjBQQVFIL0JBUURBZ0trTUE4R0ExVWRFd0VCCi93UUZNQU1CQWY4d0RRWUpLb1pJaHZjTkFRRUxCUUFEZ2dFQkFLcEtnb1Qrb1kxRXpSb3RSWlVhMmpjQlkrWGgKK2plNTVHQWwvOVRONEJRMms0dUNBQUNGUEdiaDlFdVI2OEZER1dwWjVTWTFSbWczZ2hTUXd5WlRjVFlpdmpoVQpISE44d0Fhb3hDMHVsdkdzVng1eTVnTHF0NkNlaExibW1tdWxZbWl4cmhtZjNHU0cvUnlpWElGNDRoazlOR3BLClg2aGIrZlhUSVVvVytnRUtjWXFnSnRjYWJ2WUF3QThEdXV0WndKSVp5VFBSVEVtZHNpUnV6K0xuTkFRSjdxZ2sKcEZxV1VJZGlXZHRIWmh1emxPYlgyTFVTL2ZIOFFudVV6VTdTaFBUQ1Y4TnNTeXBtNEo0SXNzUGhTeFRyQnRSeApCeURVL2JuU3Yzc1JhY0VqZTJORnJYZStNRkt1d1lXUU5UdUdaZHVUWjFUL2ZqemYrRDhxMHgyZFRLQT0KLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo="


#Locations of ca_key and ca_crt. This is needed for creating the nessecary key and certificates. 
ca_key=/etc/kubernetes/pki/ca.key
ca_crt=/etc/kubernetes/pki/ca.crt
ca_key_ENC=$(base64 -w 0 $ca_key)
ca_crt_ENC=$(base64 -w 0 $ca_crt)
#make sure we have the cert and key in base64 so it can be read
#Used for Testing
bash rmuser.sh
#sudo -u $USER sh ./setWebserver.sh
#sudo -u $USER touch userInfo.txt
#sudo -u $USER echo "" > userInfo.txt


#
server="https://192.168.42.11:6443"

INPUTCSVFILE=./testUsers.csv ## Maybe update this later to take in user input and have a user give the file location of this file.
path=$(pwd)
echo $path
TOOLPODDEPLOYMENT="${path}/resource/TOOLPOD/deploymentToolPod.yml" ##Location of deployment file
CTFPODDEPLOYMENT="${path}/resource/CTF-1/deploymentCTF1.yml" ##
CTF2PODDEPLOYMENT="${path}/resource/CTF-2/deploymentCTF2.yml" ##


if [$1 == ""];
then
	echo "You need to have entered a user with sudo privileges."
	exit 1
fi

sudo -u $1 ./req.sh ##Installs the Requierments that will be needed
sudo -u $1 sh ./setWebserver.sh ##Sets up the Webserver
sudo  sh ./setWWW-Data.sh $1 ##Connects www-data to the postgres dbms
sudo -u $1 touch userInfo.txt ##creates the user file
sudo -u $1 echo "" > userInfo.txt ##rewrites the file with nothing



##Checks the inputfilelocation
if [! -f "$INPUTCSVFILE"];
then
        echo "$INPUTCSVFILE file not found"
        exit 1
fi

echo "$USER"
##checks to see if you are running as root
if [ "$USER" != "root" ];
then
	echo "$(/usr/bin/whoami)"
        echo "$(tput setaf 1) Must be Root! $(tput setaf 1) "
        exit 1
fi
 

#Prepares Input
tmp=$(mktemp)
chmod 600 $tmp
grep -Ev '^[#;%]' $INPUTCSVFILE |tr -d ' \t' |grep -v '^$' >> $tmp
INPUTCSVFILE=$tmp
sudo  sh ./create_csv.sh $INPUTCSVFILE ## This will create the users and the grouping

mkdir tempKube ##Makes directory to hold kube files

#makes list of unique groups
tmp2=$(mktemp)
for u in $(cat $INPUTCSVFILE)
do
        g="$(echo $u | cut -d "," -f 2)"
        echo "$g" >> $tmp2
done

uniqueGroups=$( cat $tmp2 | sort | uniq)

#Processes Groups
for u in $(echo $uniqueGroups)
do	##Deletes the volume that was created previously, wont cause an error if doesnt existsw
	sudo -u $1 kubectl delete pv postgres-pv-volume-$u --grace-period=0 --force
        sudo -u $1 kubectl delete pv postgres-pv-volume-ctf2-$u --grace-period=0 --force
        
	echo "Creating the namespace for $u"
        sudo -u $1 kubectl create namespace $u
	sudo -u $1 sed -i 's/groupName/'$u'/g' $(pwd)/resource/CTF-1/postgres-storage.yml ##removing the [groupName] tag with the real groupName
	sudo -u $1 kubectl create -f $(pwd)/resource/CTF-1/postgres-configmap.yml -n $u ##Creates the config map
	sudo -u $1 kubectl create -f $(pwd)/resource/CTF-1/postgres-storage.yml -n $u ##creates and allocates the spacing needed
	sudo -u $1 cp $(pwd)/resource/CTF-1/STATIC_TEMPLATE/postgres-storage.yml $(pwd)/resource/CTF-1/postgres-storage.yml ##just makes the file clean and can re do the proccess above for the other teams
	
	##this is for CTF 2 If more are added we wouldcopy this
	sudo -u $1 sed -i 's/groupName/'$u'/g' $(pwd)/resource/CTF-2/postgres-storage.yml ##removing the [groupName] tag with the real groupName
        sudo -u $1 kubectl create -f $(pwd)/resource/CTF-2/postgres-configmap.yml -n $u  ##Creates the config map
        sudo -u $1 kubectl create -f $(pwd)/resource/CTF-2/postgres-storage.yml -n $u ##creates and allocates the spacing needed
        sudo -u $1 cp $(pwd)/resource/CTF-2/STATIC_TEMPLATE/postgres-storage.yml $(pwd)/resource/CTF-2/postgres-storage.yml ##just makes the file clean and can re do the proccess above for the other teams
	
	echo "Deploying $u"
        sudo -u $1 sed -i 's/groupName/'$u'/g' $(pwd)/resource/CTF-1/deploymentCTF1.yml ##removing the [groupName] tag with the real groupName
        sudo -u $1 sed -i 's/groupName/'$u'/g' $(pwd)/resource/CTF-2/deploymentCTF2.yml ##removing the [groupName] tag with the real groupName

	sudo -u $1 kubectl apply -n $u -f $TOOLPODDEPLOYMENT ##Deployes the pods
	sudo -u $1 kubectl apply -n $u -f $CTFPODDEPLOYMENT
        sudo -u $1 kubectl apply -n $u -f $CTF2PODDEPLOYMENT
        sudo -u $1 cp $(pwd)/resource/CTF-1/STATIC_TEMPLATE/deploymentCTF1.yml $(pwd)/resource/CTF-1/deploymentCTF1.yml ##just makes the file clean and can re do the proccess above for the other teams
        sudo -u $1 cp $(pwd)/resource/CTF-2/STATIC_TEMPLATE/deploymentCTF2.yml $(pwd)/resource/CTF-2/deploymentCTF2.yml ##just makes the file clean and can re do the proccess above for the other teams
	sudo -u $1 sh ./getIP.sh $u
	
	## echos the password and username 
	
	echo "$u and "echo "$(sudo pwgen 5 1)"" are the username and password for that team. They need it for the webserver that is running on 192.168.42.11" >> userInfo.txt
	sudo -su postgres psql -d ctf -c "INSERT INTO login VALUES('$u','test');"
        roleconfig="apiVersion: rbac.authorization.k8s.io/v1 ##creates role binding for each group, was needed if they are running locally
kind: Role
metadata:
    namespace: $u
    name: $u-role
rules:
- apiGroups: ['*']
  resources: ['*']
  verbs: ['*']"

        #Write to File
        echo "Making role-deployment for $u" ##saves the role config
        echo "$roleconfig" > tempKube/role_$u-deployment-manager.yml

        #Apply Role
        echo "Applying role-deployment for $u"
        sudo -u $1 kubectl apply -f tempKube/role_$u-deployment-manager.yml

        rolebindingconfig="apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
    name: $u-rolebinding
    namespace: $u
roleRef:
  kind: Role
  name: $u-role
  apiGroup: rbac.authorization.k8s.io
subjects:"

        #Apply Template
        echo "Applying Template rolebinding for $u"
        echo "$rolebindingconfig" > tempKube/rolebinding_$u-deployment-manager.yml

done


##Creates a Users keys to interactr with Kubernetes
for u in $(cat $INPUTCSVFILE)
do
 	echo "$(tput setaf 7)"
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
        sudo -u $1 kubectl config set-context "$groupName-context" --cluster=kubernetes --user=$usersName --namespace=$groupName
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

        #Adds user to binding file
        userBinding="- kind: User
  name: $usersName
  apiGroup:"

        echo "$userBinding" >> tempKube/rolebinding_$groupName-deployment-manager.yml

        #Performs relevant bindings of kube files
        echo "Manually setting certificates"
        sudo -u $1 kubectl config set-credentials $usersName --client-certificate=/home/$usersName/.certs/$usersName.crt  --client-key=/home/$usersName/.certs/$usersName.key

        echo "Giving the user's rights for the new files that were created"
        sudo chown -R $usersName:$groupName /home/$usersName/
done

##Pushes Binding for all groups

for u in $(echo $uniqueGroups)
do
        echo "Applying rolebinding for $u"
        sudo -u $1 kubectl apply -f tempKube/rolebinding_$u-deployment-manager.yml
done

#Cleans the Temporary Files

rm -rf tempKube

#Exit
                                                                                       
