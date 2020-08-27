<?php
session_start();
$path=shell_exec("cat pathing.txt");
$TOOLPODDEPLOYMENT="{$path}/resource/TOOLPOD/deploymentToolPod.yml";##Location of deployment file
$CTFPODDEPLOYMENT="{$path}/resource/CTF-1/deploymentCTF1.yml";
$CTF2PODDEPLOYMENT="{$path}/resource/CTF-2/deploymentCTF2.yml";

$static_ctf2="{$path}/resource/CTF-2/deploymentCTF2.yml";
$static_ctf="{$path}/resource/CTF-1/STATIC_TEMPLATE/deploymentCTF1.yml";

$username=escapeshellarg($_SESSION['username']);

$tool=shell_exec("kubectl get all -n $username | grep pod | grep -oP 'pod/ctf-t\S+'");

$ctf=shell_exec("kubectl get all -n $username | grep pod | grep -oP 'pod/ctf-v1\S+'");
$ctf2=shell_exec("kubectl get all -n $username | grep pod | grep -oP 'pod/ctf-v2\S+'");
shell_exec("kubectl delete -n $username $tool");
shell_exec("kubectl delete -n $username $ctf");
shell_exec("kubectl delete -n $username $ctf2");
shell_exec("kubectl apply -n $username -f $TOOLPODDEPLOYMENT");
shell_exec("kubectl apply -n $username -f $CTFPODDEPLOYMENT");
shell_exec("kubectl apply -n $username -f $CTF2PODDEPLOYMENT");
shell_exec("sudo cp $static_ctf $CTFPODDEPLOYMENT");
shell_exec("sudo cp $static_ctf2 $CTF2PODDEPLOYMENT");


echo "<h1 style=font-size:18px> Completed and Return to the CTF!</h1>";



?>
