#!/bin/bash

###KLP: Setup Instana for lab and demo


#usage

# ./klp-instana-setup.sh



# change to home directory on WSA VM

echo ""
echo "-----------------------------------------------------------------------"
echo "switch to the '/home/ibmuser' directory on the WSA VM"
echo "" 
echo "cd /home/ibmuser"
echo ""
echo "-----------------------------------------------------------------------"
echo "" 

cd /home/ibmuser


# remove cacerts from home dir, if it exists

if [  -f "/home/ibmuser/cacerts" ]; then
    rm  /home/ibmuser/cacerts ;
    echo "removed /home/ibmuser/cacerts"
fi


# remove certTest.log from home dir, if it exists

if [  -f "/home/ibmuser/certTest.log" ]; then
    rm  /home/ibmuser/certTest.log ;
    echo "removed /home/ibmuser/certTest.log"
fi


# remove cpd.pem from home dir, if it exists

if [  -f "/home/ibmuser/cpd.pem" ]; then
    rm  /home/ibmuser/cpd.pem ;
    echo "removed /home/ibmuser/cpd.pem"
fi




# make copy a current Instana agent cacerts

echo ""
echo "-----------------------------------------------------------------------"
echo "make copy a current Instana agent cacerts"
echo "" 
echo "cp /opt/instana/agent/jvm/lib/security/cacerts /home/ibmuser"
echo ""
echo "-----------------------------------------------------------------------"
echo "" 

cp /opt/instana/agent/jvm/lib/security/cacerts /home/ibmuser


# Retrieve WebSphere Automation certificate


echo ""
echo "-----------------------------------------------------------------------"
echo "Retrieve WebSphere Automation certificate"
echo "" 
echo "echo | openssl s_client -showcerts -servername cpd-websphere-automation.apps.ocp.ibm.edu -connect cpd-websphere-automation.apps.ocp.ibm.edu:443 2>/dev/null | openssl x509 -inform pem > cpd.pem"
echo ""
echo "-----------------------------------------------------------------------"
echo "" 


echo | openssl s_client -showcerts -servername cpd-websphere-automation.apps.ocp.ibm.edu -connect cpd-websphere-automation.apps.ocp.ibm.edu:443 2>/dev/null | openssl x509 -inform pem > cpd.pem

sleep 3

# import the cert into the keystore


echo ""
echo "-----------------------------------------------------------------------"
echo "import the cert into the keystore"
echo "" 
echo "keytool -importcert -file cpd.pem -alias ibm.com -keystore cacerts -storepass changeit -noprompt"
echo ""
echo "-----------------------------------------------------------------------"
echo "" 

keytool -importcert -file cpd.pem -alias ibm.com -keystore cacerts -storepass changeit -noprompt

sleep 2

# Verify the certificate was imported

echo ""
echo "-----------------------------------------------------------------------"
echo "Verify the certificate was imported"
echo "" 
echo "keytool -list -alias ibm.com -keystore cacerts -storepass changeit"
echo ""
echo "-----------------------------------------------------------------------"
echo "" 

##### In output, look for Certificate fingerprint (SHA1): AD:D6:9A:48:75:C8:99:5A:3F:67:8F:FA:92:7A:42:64:6B:DC:B8:6F


keytool -list -alias ibm.com -keystore cacerts -storepass changeit > /home/ibmuser/certTest.log

IS_CERT_GOOD=$(cat certTest.log | grep "Certificate fingerprint" | wc -l)


echo "IS_CERT_GOOD: $IS_CERT_GOOD"
echo ""

sleep 5

if [[ "$IS_CERT_GOOD" -gt 0 ]]; then 
  CERT_RESULT="PASS"	
  echo ""
  echo "----------------------------------------------------------------------------------------------"
  echo "TEST PASSED!"
  echo ""
  echo " The certificate was successfully imported!"
  echo ""
  echo "Result = $CERT_RESULT" 
  echo ""
  echo "OK to continue...."
  echo ""
  echo "----------------------------------------------------------------------------------------------"
  echo "" 
else 
    CERT_RESULT="FAIL"	
  echo ""
  echo "----------------------------------------------------------------------------------------------"
  echo "TEST FAILED!"  
  echo "" 
  echo "ERROR! The certificate was NOT imported into the keystroe. The keystore configuration FAILED."
  echo ""
  echo "Result = $RESULT" 
  echo ""
  echo "You must correct the error and rerun the instana-setup.sh script before you can continue with the lab or demo"
  echo ""
  echo "----------------------------------------------------------------------------------------------"
  echo ""
  
  exit 1
fi




sleep 2

#copy the keystore to the instana vm

echo ""
echo "-----------------------------------------------------------------------"
echo "Copy the keystore to the instana vm"
echo "" 
echo "scp cacerts ibmadmin@instana:cacerts"
echo ""
echo "-----------------------------------------------------------------------"
echo "" 

sshpass -p "passw0rd" scp /home/ibmuser/cacerts ibmadmin@instana:/home/ibmadmin/cacerts

sleep 2

#copy the remote script, updateInstana.sh to the instana vm

echo ""
echo "-----------------------------------------------------------------------"
echo "Copy the remote script, updateInstana.sh to the instana vm"
echo "" 
echo "scp /home/ibmuser/WAS-Automation-LabFiles/techxchange/lab2-MemoryLeak/klp-updateInstana.sh ibmadmin@instana:/home/ibmadmin/klp-updateInstana.sh"
echo ""
echo "-----------------------------------------------------------------------"
echo "" 

sshpass -p "passw0rd" scp /home/ibmuser/WAS-Automation-LabFiles/techxchange/lab2-MemoryLeak/klp-updateInstana.sh ibmadmin@instana:/home/ibmadmin/klp-updateInstana.sh

sleep 2


#ssh into instana vm

echo ""
echo "-----------------------------------------------------------------------"
echo "ssh into instana vm"
echo "" 
echo "ssh -t ibmadmin@instana . /home/ibmadmin/klp-updateInstana.sh"
echo ""
echo "-----------------------------------------------------------------------"
echo "" 


#ssh ibmadmin@instana

### sshpass -p "passw0rd" ssh -t ibmadmin@instana
sshpass -p "passw0rd" ssh -t ibmadmin@instana . /home/ibmadmin/klp-updateInstana.sh


exit
