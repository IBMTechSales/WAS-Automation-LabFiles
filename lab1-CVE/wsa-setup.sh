#!/bin/bash

###Setup WSA for lab and demo


#usage

# ./wsa-setup.sh

######

GOOD_MESSAGE="code=0"

#remove old test-connection pods. We canonly have 1 pod to search logs for reslts of the test... The latest test-connection pod
echo "remove any old 'test-connection' pods."

TEST_POD_COUNT=$(oc get pods -n websphere-automation --no-headers=true | awk '/test-connection/{print $1}' | wc -l)

if [[ "$TEST_POD_COUNT" -gt 0 ]]; then 
  oc get pods -n websphere-automation --no-headers=true | awk '/test-connection/{print $1}'| xargs  oc delete -n websphere-automation pod
fi



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
echo "waiting 60 seconds for pod to start and run the test conection playbook"
echo ""
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

exit 1


echo "Login to CP"

oc login --username=ibmadmin --password=engageibm --insecure-skip-tls-verify=true --server=https://api.demo.ibmdte.net:6443

echo "swith to the websphere-automation project in OCP" 
oc project websphere-automation


echo "change to /home/ibmuser directory"
cd /home/ibmuser
 

echo "run ssh-keygen command"
echo "enter password as: passw0rd when prompted (note the zero)"
ssh-keygen -f ~/.ssh/wsa


echo "run ssh-copy-key command"
echo "Type 'yes' when prompted to contimue"
echo "ENter password as:  engageibm  when prompted for the ibmuser's password"
ssh-copy-id -i ~/.ssh/wsa ibmuser@student.demo.ibmdte.net


echo "create the 'wsa-ansible' secret in OCP"
oc create secret generic wsa-ansible \
 --from-literal=ansible_user=ibmuser \
 --from-literal=ansible_port=22 \
 --from-file=ssh_private_key_file=/home/ibmuser/.ssh/wsa \
 --from-literal=ssh_private_key_password=passw0rd


echo "run ssh-keyscan command to produce the 'wsa_known_hosts' file"
ssh-keyscan student.demo.ibmdte.net >> /home/ibmuser/wsa_known_hosts



echo "create the wsa-ansible-known-hosts configmap in OCP"
oc create configmap wsa-ansible-known-hosts --from-file=known_hosts=/home/ibmuser/wsa_known_hosts


### Can we test the commection here?


echo "get the wsa-secure-fixcentral-creds secret"
oc get secret | grep wsa-secure-fixcentral-creds


echo "List the WSA Pods, and see that they are running"
oc get pods | grep '\<fix\>\|installation'



GOOD_MESSAGE="code=0"
echo "Good message is: $GOOD_MESSSAGE"

echo "run the test connection runbook"
#MANAGER_POD=$(oc get pod -l app.kubernetes.io/component=runbook-manager -o name | head -n 1)
#oc rsh $MANAGER_POD runcli testConnection student.demo.ibmdte.net linux

echo "waiting 30 seconds for pod to start and run the test conection"
#sleep 30

echo "get the name of the test-connection pod"
oc get pods  | grep test-connection | head -n 1 | cut -d " " -f1
#example output from command abpve: 'test-connection-1678461489800'
TEST_CONN=$(oc get pods  | grep test-connection | head -n 1 | cut -d " " -f1)
echo "TEST_CON: $TEST_CONN"

echo "view the log from the test commection job"

echo "oc logs command: oc logs --tail=100 $TEST_CONN | grep $GOOD_MESSAGE"
IS_GOOD=$(oc logs --tail=100 $TEST_CONN | grep $GOOD_MESSAGE | wc -l)

if [[ "$IS_GOOD" -gt 0 ]]; then 
  echo "is good"
else 
  echo "not good"
fi



