#!/bin/sh


echo ""
echo "Configuring WAS 9057 for the lab"
echo "" 
echo "Restart WAS 9057 server"


if [[ -f /home/ibmuser/startServer.log ]]; then
  echo "removing old startServer.log in /home/ibmuser directory"  
  rm /home/ibmuser/startServer.log
fi




/opt/IBM/WebSphere/AppServer9057/bin/serverStatus.sh tWAS_9057_server > /home/ibmuser/startServer.log

IS_STARTED=$(cat /home/ibmuser/startServer.log | grep STARTED | wc -l)

echo "IS STARTED: $IS_STARTED"

if [[ "$IS_STARTED" -gt 0 ]]; then 
  CERT_RESULT="PASS"	
  echo ""
  echo "Stopping the WAS 9057 server..."
  /opt/IBM/WebSphere/AppServer9057/bin/stopServer.sh tWAS_9057_server
fi


sleep 3

 echo ""
 echo "Now starting the WAS 9057 server..."
/opt/IBM/WebSphere/AppServer9057/bin/startServer.sh tWAS_9057_server

/opt/IBM/WebSphere/AppServer9057/bin/serverStatus.sh tWAS_9057_server

echo "" 
echo " Set the WAS JVM Heap to 512 MB"
echo "" 

/opt/IBM/WebSphere/AppServer9057/bin/wsadmin.sh -f /home/ibmuser/WAS-Automation-LabFiles/lab2-MemoryLeak/techxchange/klp-setMaxHeapAndJVMarg.py

echo ""
echo "Install the Memory leak application (MLAPP) in WebSphere"
echo ""
/opt/IBM/WebSphere/AppServer9057/bin/wsadmin.sh -f /home/ibmuser/WAS-Automation-LabFiles/lab2-MemoryLeak/techxchange/klp-install_MLApp.py

echo "Restarting WAS 9057 server..."
/opt/IBM/WebSphere/AppServer9057/bin/stopServer.sh tWAS_9057_server
sleep 2
/opt/IBM/WebSphere/AppServer9057/bin/startServer.sh tWAS_9057_server
sleep 2
/opt/IBM/WebSphere/AppServer9057/bin/serverStatus.sh tWAS_9057_server


echo "" 
echo "-----------------------------------------------------------------"
echo "                    INFORMATIONAL:"
echo "                    --------------"
echo " -->  WebSphere Admin Console: https://localhost:9043/ibm/console"
echo " "
echo " -->      WebSphere login credentials: wasadmin / wasadmin"
echo "" 
echo "-----------------------------------------------------------------"
echo ""
echo "--------------------------------------------------"
echo " End of klp-tWAS_configure_MLapp.sh"
echo "--------------------------------------------------"
echo "" 
