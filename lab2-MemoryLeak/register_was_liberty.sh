#!/bin/sh
oc login --username=ibmadmin --password=engageibm --insecure-skip-tls-verify=true --server=https://api.demo.ibmdte.net:6443

oc project websphere-automation

echo https://$(oc get route cpd -n websphere-automation -o jsonpath='{.spec.host}')/websphereauto/meteringapi > /opt/IBM/WebSphere/metering-url.txt

oc -n websphere-automation get secret wsa-secure-metering-apis-encrypted-tokens -o jsonpath='{.data.wsa-secure-metering-apis-sa}' | base64 -d > /opt/IBM/WebSphere/api-key.txt; echo >> /opt/IBM/WebSphere/api-key.txt

oc get secret external-tls-secret -n websphere-automation -o jsonpath='{.data.cert\.crt}' | base64 -d > /opt/IBM/WebSphere/cacert.pem

/opt/IBM/WebSphere/AppServer9056/bin/startServer.sh tWAS_9056_server

/opt/IBM/WebSphere/AppServer9056/bin/wsadmin.sh -f /api-usagemetering/scripts/configuretWasUsageMetering.py url=$(cat /opt/IBM/WebSphere/metering-url.txt) apiKey=$(cat /opt/IBM/WebSphere/api-key.txt) trustStorePassword=th1nkpassword

/home/ibmuser/WSAlab2/tWAS_setup_MLApp.sh

/opt/IBM/WebSphere/AppServer9056/bin/stopServer.sh tWAS_9056_server

/opt/IBM/WebSphere/Liberty200012/bin/server create Liberty_200012_server

cp -f /home/ibmuser/WSAlab2/server_wsa.xml /opt/IBM/WebSphere/Liberty200012/usr/servers/Liberty_200012_server/server.xml

/opt/IBM/WebSphere/Liberty200012/bin/server start Liberty_200012_server

sleep 5

keytool -import -trustcacerts -file /opt/IBM/WebSphere/cacert.pem -keystore /opt/IBM/WebSphere/Liberty200012/usr/servers/Liberty_200012_server/resources/security/key.p12 -storetype PKCS12 -storepass th1nkpassword -noprompt

sleep 5

echo "metering-url=$(cat /opt/IBM/WebSphere/metering-url.txt)" >> /opt/IBM/WebSphere/Liberty200012/usr/servers/Liberty_200012_server/bootstrap.properties

echo "api-key=$(cat /opt/IBM/WebSphere/api-key.txt)" >> /opt/IBM/WebSphere/Liberty200012/usr/servers/Liberty_200012_server/bootstrap.properties

echo "-Xmx98m" >> /opt/IBM/WebSphere/Liberty200012/usr/servers/Liberty_200012_server/jvm.options

echo "-javaagent:/opt/IBM/WebSphere/Liberty200012/bin/tools/ws-javaagent.jar" >> /opt/IBM/WebSphere/Liberty200012/usr/servers/Liberty_200012_server/jvm.options


/opt/IBM/WebSphere/Liberty200012/bin/server stop Liberty_200012_server 

cp -f /home/ibmuser/WSAlab2/MLApp.war /opt/IBM/WebSphere/Liberty200012/usr/servers/Liberty_200012_server/dropins/.

/opt/IBM/WebSphere/Liberty200012/bin/server start Liberty_200012_server --clean

sleep 5

/opt/IBM/WebSphere/Liberty200012/bin/server stop Liberty_200012_server
