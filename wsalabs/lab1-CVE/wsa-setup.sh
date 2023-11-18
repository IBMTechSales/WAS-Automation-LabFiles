#!/bin/bash

###Setup WSA for lab and demo


#usage

# ./wsa-setup.sh

######

GOOD_MESSAGE="code=0"


echo ""
echo "-----------------------------------------------------------------------"
echo "Login to OCP"
echo "" 
echo "oc login --username=ibmadmin --password=engageibm"
echo ""
echo "-----------------------------------------------------------------------"
echo "" 

oc login --username=ibmadmin --password=engageibm

sleep 5

echo ""
echo "-----------------------------------------------------------------------"
echo "switch to the 'websphere-automation' project in OCP"
echo "" 
echo "oc project websphere-automation"
echo ""
echo "-----------------------------------------------------------------------"
echo "" 


oc project websphere-automation


#remove old test-connection pods. We canonly have 1 pod to search logs for reslts of the test... The latest test-connection pod
echo "remove any old 'test-connection' pods."

TEST_POD_COUNT=$(oc get pods -n websphere-automation --no-headers=true | awk '/test-connection/{print $1}' | wc -l)

if [[ "$TEST_POD_COUNT" -gt 0 ]]; then 
  oc get pods -n websphere-automation --no-headers=true | awk '/test-connection/{print $1}'| xargs  oc delete -n websphere-automation pod
fi

WSA_ANSIBLE_SECRET_COUNT=$(oc get secret | grep wsa-ansible | wc -l)

if [[ "$WSA_ANSIBLE_SECRET_COUNT" -gt 0 ]]; then 
  echo "removing old wsa-ansible secret"
  oc delete secret wsa-ansible -n websphere-automation
fi


ANSIBLE_KNOWN_HOSTS_CONFIGMAP_COUNT=$(oc get configmap wsa-ansible-known-hosts -n websphere-automation | wc -l)

if [[ "$ANSIBLE_KNOWN_HOSTS_CONFIGMAP_COUNT" -gt 0 ]]; then 
  echo "removing old wsa-ansible-known-hosts configmap"
  oc delete configmap wsa-ansible-known-hosts -n websphere-automation
fi



if [[ -f /home/ibmuser/.ssh/wsa ]]; then
  echo "removing old wsa file in ~/.ssh directory"  
  rm /home/ibmuser/.ssh/wsa
fi


if [[ -f /home/ibmuser/.ssh/known_hosts ]]; then
  echo "removing old known_hosts file in ~/.ssh directory"  
  rm /home/ibmuser/.ssh/known_hosts
fi

if [[ -f /home/ibmuser/.ssh/authorized_keys ]]; then
  echo "removing old authorized_keys file in ~/.ssh directory"  
  rm /home/ibmuser/.ssh/authorized_keys
fi



echo "list the home.ibmuser/.ssh directory after cleanup"
ls -al /home/ibmuser/.ssh

sleep 5


echo ""
echo "-----------------------------------------------------------------------"
echo "change to /home/ibmuser directory"
echo ""
echo "-----------------------------------------------------------------------"
echo ""

cd /home/ibmuser
 

echo ""
echo "-----------------------------------------------------------------------"
echo "run ssh-keygen command"
echo "" 
echo "--> Type 'passw0rd' if  prompted to set a password for the ssh key  (note the zero)"
echo ""
echo "-----------------------------------------------------------------------"
echo ""

ssh-keygen -N "passw0rd" -f ~/.ssh/wsa



echo "-------------------------------------------------------------------------"
echo "Run ssh-copy-id command"
echo ""
echo " -->  Type 'yes' if prompted to continue"
echo ""
echo "--->  Type 'engageibm' when prompted for the 'ibmuser' userID (note the zero)"
echo ""
echo "-------------------------------------------------------------------------"

sleep 4

## The command below requires a file named "config" in ~/.ssh with the folowing line in the file. 
## StrictHostKeyChecking no

\cp /home/ibmuser/WAS-Automation-LabFiles/wsalabs/lab1-CVE/ssh-config.txt ~/.ssh/config

sleep 1
chmod 700 ~/.ssh/config

ls -al ~/.ssh

sleep 3

sshpass -p "engageibm" ssh-copy-id -i ~/.ssh/wsa ibmuser@student.demo.ibmdte.net
#ssh-copy-id -i ~/.ssh/wsa ibmuser@student.demo.ibmdte.net


sleep 3

echo ""
echo "----------------------------------------------------------------------"
echo "create the 'wsa-ansible' secret in OCP"
echo ""
echo "oc create secret generic wsa-ansible "\"
echo "  --from-literal=ansible_user=ibmuser "\"
echo "  --from-literal=ansible_port=22 "\"
echo "  --from-file=ssh_private_key_file=/home/ibmuser/.ssh/wsa "\"
echo "  --from-literal=ssh_private_key_password=passw0rd"
echo ""
echo "----------------------------------------------------------------------"

oc create secret generic wsa-ansible \
 --from-literal=ansible_user=ibmuser \
 --from-literal=ansible_port=22 \
 --from-file=ssh_private_key_file=/home/ibmuser/.ssh/wsa \
 --from-literal=ssh_private_key_password=passw0rd

sleep 3


echo ""
echo "----------------------------------------------------------------------"
echo "run ssh-keyscan command to produce the 'wsa_known_hosts' file"
echo ""
echo "ssh-keyscan student.demo.ibmdte.net >> /home/ibmuser/wsa_known_hosts"
echo ""
echo "----------------------------------------------------------------------"

ssh-keyscan student.demo.ibmdte.net >> /home/ibmuser/wsa_known_hosts

sleep 4

sleep 4

echo ""
echo "---------------------------------------------------------------------"
echo "create the wsa-ansible-known-hosts configmap in OCP"
echo ""
echo "oc create configmap wsa-ansible-known-hosts --from-file=known_hosts=/home/ibmuser/wsa_known_hosts"
echo ""
echo "---------------------------------------------------------------------"


oc create configmap wsa-ansible-known-hosts --from-file=known_hosts=/home/ibmuser/wsa_known_hosts

sleep 3

echo ""
echo "---------------------------------------------------------------------"
echo "get the wsa-secure-fixcentral-creds secret"
echo ""
echo "oc get secret | grep wsa-secure-fixcentral-creds"
echo ""
echo "---------------------------------------------------------------------"

oc get secret | grep wsa-secure-fixcentral-creds

sleep 2

echo ""
echo "---------------------------------------------------------------------"
echo "List the WSA Pods, and see that they are running"
echo ""
echo "oc get pods | grep '\<fix\>\|installation'"
echo ""
echo "---------------------------------------------------------------------"

oc get pods | grep '\<fix\>\|installation'

sleep 4


echo "list the /home/ibmuser/.ssh dir to be sure the known-hosts file exists"
ls -al /home/ibmuser/.ssh 

sleep 4

########################
# Verfy the confguration
########################


echo "-----------------------------------------------"
echo ""
echo " Now verifying the configuration"
echo ""
echo "-----------------------------------------------"

sleep 5


echo ""
echo "Looking for '$GOOD_MESSAGE' in log output to indicate the configuration is correct"
echo ""


echo "----------------------------------------------------------------------------------------------"
echo ""
echo "Run the test connection Ansible runbook to test the connection"
echo ""
echo "MANAGER_POD=$(oc get pod -l app.kubernetes.io/component=runbook-manager -o name | head -n 1)"
echo""
echo "oc rsh $MANAGER_POD runcli testConnection student.demo.ibmdte.net linux"
echo ""
echo "-----------------------------------------------------------------------------------------------"


MANAGER_POD=$(oc get pod -l app.kubernetes.io/component=runbook-manager -o name | head -n 1)
oc rsh $MANAGER_POD runcli testConnection student.demo.ibmdte.net linux



echo ""
echo "waiting 90 seconds for pod to start and run the test conection Ansible playbook"
sleep 15
echo "75 seconds remaining..."
sleep 15
echo "60 seconds remaining..."
sleep 15
echo "45 seconds remaining..."
sleep 15
echo "30 seconds remaining..."
sleep 15 
echo "15 seconds remaining..."
sleep 15 
echo "00 seconds remaining..."

echo "get the name of the test-connection pod"

echo "----------------------------------------------------------------------------------------------"
echo ""
echo "TEST_CONN=$(oc get pods  | grep test-connection | head -n 1 | cut -d " " -f1)"
echo ""
echo "-----------------------------------------------------------------------------------------------"


#oc get pods  | grep test-connection | head -n 1 | cut -d " " -f1

#example output from command abpve: 'test-connection-1678461489800'
TEST_CONN=$(oc get pods  | grep test-connection | head -n 1 | cut -d " " -f1)

echo ""
echo "Test connection pod is: $TEST_CONN"
echo ""


echo "----------------------------------------------------------------------------------------------"
echo ""
echo "Find the Return Code of the Ansible Playbook from the log"
echo ""
echo "oc logs command: oc logs --tail=100 $TEST_CONN | grep $GOOD_MESSAGE"
echo ""
echo "----------------------------------------------------------------------------------------------"


IS_GOOD=$(oc logs --tail=100 $TEST_CONN | grep $GOOD_MESSAGE | wc -l)


#oc logs --tail=100 test-connection-1678468903189-8vw2g | grep code= | awk -F 'CLI' '{print $2}'

RESULT=$(oc logs --tail=100 $TEST_CONN | grep code= | awk -F 'CLI' '{print $2}')
echo ""
echo "The result of the search for the retun code in the log: $RESULT"
echo ""


if [[ "$IS_GOOD" -gt 0 ]]; then 
  echo ""
  echo "----------------------------------------------------------------------------------------------"
  echo "TEST PASSED!"
  echo ""
  echo " The Ansible playbook was able to connect to WebSphere environment."
  echo ""
  echo "Result = $RESULT" 
  echo ""
  echo "You can contiue with the lab or demo"
  echo ""
  echo "----------------------------------------------------------------------------------------------"
  echo "" 
  else 
  echo ""
  echo "----------------------------------------------------------------------------------------------"
  echo "TEST FAILED!"  
  echo "" 
  echo "ERROR! Test connection Ansible Playbook failed."
  echo ""
  echo "Result = $RESULT" 
  echo ""
  echo "You must correct the error and rerun the playbook before you can continue with the lab or demo"
  echo ""
  echo "----------------------------------------------------------------------------------------------"
  echo ""
fi

