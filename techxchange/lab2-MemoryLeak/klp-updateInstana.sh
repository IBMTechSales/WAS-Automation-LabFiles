#!/bin/bash

###KLP: Update Instana on the Instana VM. This script is called from Instana-setup.sh, and is run on the Instana VM. 

###Do not invoke this script manually. 


#usage

# ./klp-updateInstana.sh


echo ""
echo "-----------------------------------------------------------------------"
echo "Now running the updateInsna.sh script on the Instana VM."
echo "-----------------------------------------------------------------------"
echo "" 

sleep 2


GOOD_MESSAGE="Custom Keystore is enabled"

# change to home directory on Instana VM

echo ""
echo "-----------------------------------------------------------------------"
echo "switch to the '/home/ibmadmin' directory on the Instana VM"
echo "" 
echo "cd /home/ibmadmin"
echo ""
echo "-----------------------------------------------------------------------"
echo "" 

cd /home/ibmadmin


# update settings.hcl with location of cacerts keystore 
#    sudo vi settings.hcl
### Use shell commands to make the update.... 

# make a copy of "settings.hcl" just in case. 

echo ""
echo "-----------------------------------------------------------------------"
echo "update settings.hcl with location of cacerts keystore"
echo ""
echo "-----------------------------------------------------------------------"
echo "" 

echo ""
echo "-----------------------------------------------------------------------"
echo "make a copy of 'settings.hcl'"
echo ""
echo "   --> \cp /home/ibmadmin/settings.hcl /home/ibmadmin/settings.hcl.ORIG"
echo ""
echo "-----------------------------------------------------------------------"
echo "" 

\cp /home/ibmadmin/settings.hcl /home/ibmadmin/settings.hcl.ORIG


sleep 2

# try to remove the line that has: "custom_keystrore" if it exists

echo ""
echo "-----------------------------------------------------------------------"
echo "try to remove the line that has: 'custom_keystrore' if it exists"
echo ""
echo "   --> grep -v "custom_keystore" /home/ibmadmin/settings.hcl > /home/ibmadmin/tmpfile && mv -f /home/ibmadmin/tmpfile /home/ibmadmin/settings.hcl"
echo ""
echo "-----------------------------------------------------------------------"
echo "" 


grep -v "custom_keystore" /home/ibmadmin/settings.hcl > /home/ibmadmin/tmpfile && mv -f /home/ibmadmin/tmpfile /home/ibmadmin/settings.hcl

sleep 2

# insert the custom_keystore text at line 1" 

echo ""
echo "-----------------------------------------------------------------------"
echo "insert the custom_keysttore text at line 1"
echo ""
echo "   --> sed -i '1 i custom_keystore="/home/ibmadmin/cacerts"' /home/ibmadmin/settings.hcl"
echo ""
echo "-----------------------------------------------------------------------"
echo "" 


sed -i '1 i custom_keystore="/home/ibmadmin/cacerts"' /home/ibmadmin/settings.hcl

sleep 2



# restart Instana


echo ""
echo "-----------------------------------------------------------------------"
echo "Update Instana which will Restart Instana"
echo ""
echo "   --> sudo instana update -f /home/ibmadmin/settings.hcl"
echo ""
echo "-----------------------------------------------------------------------"
echo "" 


echo passw0rd | sudo -S instana update -f /home/ibmadmin/settings.hcl

sleep 7

# Verify that the custom keystore has been enabled and end the ssh session

echo ""
echo "Looking for '$GOOD_MESSAGE' in /var/log/instana/console.log to indicate the configuration is correct"
echo ""


IS_GOOD=$(cat /var/log/instana/console.log | grep "$GOOD_MESSAGE" | wc -l)

echo "IS_GOOD: $IS_GOOD"

if [[ "$IS_GOOD" -gt 0 ]]; then 
  RESULT="PASS"	
  echo ""
  echo "----------------------------------------------------------------------------------------------"
  echo "TEST PASSED!"
  echo ""
  echo " The custom keystore has been enabled!"
  echo ""
  echo "Result = $RESULT" 
  echo ""
  echo "You can contiue with the lab or demo"
  echo ""
  echo "----------------------------------------------------------------------------------------------"
  echo "" 
else 
    RESULT="FAIL"	
  echo ""
  echo "----------------------------------------------------------------------------------------------"
  echo "TEST FAILED!"  
  echo "" 
  echo "ERROR! custom keystore has been enabled. The Instana configuration FAILED."
  echo ""
  echo "Result = $RESULT" 
  echo ""
  echo "You must correct the error and rerun the instana-setup.sh script before you can continue with the lab or demo"
  echo ""
  echo "----------------------------------------------------------------------------------------------"
  echo ""
  exit 1
fi

