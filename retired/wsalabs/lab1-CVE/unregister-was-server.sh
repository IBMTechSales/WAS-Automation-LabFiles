########## Unregister server

#Usage 

# ./unregister-was-server.sh 9056 (OR) 9057 

####

echo "Usage: ./unregister-was-server.sh 9056 (OR) 9057"


if [ $1 == "9057" ] 
  then node="01"
    else if [ $1 == "9056" ]
    then node="02"
    else node="00"
    fi
fi
  
#echo "node is $node"


echo "Remove the was-usage-metering.properties file from /opt/IBM/WebSphere/AppServer9056/profiles/AppSrv01/config/cells/studentNode"$node"Cell/nodes/studentNode$node/servers/tWAS_$1_server"
 
#ls /opt/IBM/WebSphere/AppServer$1/profiles/AppSrv01/config/cells/studentNode"$node"Cell/nodes/studentNode$node/servers/tWAS_$1_server

rm /opt/IBM/WebSphere/AppServer$1/profiles/AppSrv01/config/cells/studentNode"$node"Cell/nodes/studentNode$node/servers/tWAS_$1_server/was-usage-metering.properties


echo "Stop WAS"

/opt/IBM/WebSphere/AppServer$1/bin/stopServer.sh tWAS_$1_server

/opt/IBM/WebSphere/AppServer$1/bin/serverStatus.sh tWAS_$1_server

echo "Server UN-registered from the WAS Metering service"
