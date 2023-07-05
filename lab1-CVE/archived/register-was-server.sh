###Register WAS server to metering service / WSA


#usage

# ./register-was-server.sh 9056 (OR) 9057

######

echo "Login to CP"

oc login --username=ibmadmin --password=engageibm --insecure-skip-tls-verify=true --server=https://api.demo.ibmdte.net:6443

echo "swith to the websphere-automation project in OCP" 
oc project websphere-automation

echo "Gather the infromation needed to register the WAS 9056 or 9057 server to WSA"
echo https://$(oc get route cpd -n websphere-automation -o jsonpath='{.spec.host}')/websphereauto/meteringapi > /opt/IBM/WebSphere/metering-url.txt

oc -n websphere-automation get secret wsa-secure-metering-apis-encrypted-tokens -o jsonpath='{.data.wsa-secure-metering-apis-sa}' | base64 -d > /opt/IBM/WebSphere/api-key.txt; echo >> /opt/IBM/WebSphere/api-key.txt

oc get secret external-tls-secret -n websphere-automation -o jsonpath='{.data.cert\.crt}' | base64 -d > /opt/IBM/WebSphere/cacert.pem

echo "Start the WAS 9056 or 9057 server"

/opt/IBM/WebSphere/AppServer$1/bin/stopServer.sh tWAS_$1_server

/opt/IBM/WebSphere/AppServer$1/bin/startServer.sh tWAS_$1_server

/opt/IBM/WebSphere/AppServer$1/bin/serverStatus.sh tWAS_$1_server

echo "Register WAS 9056 or 9057 server to WSA"

/opt/IBM/WebSphere/AppServer$1/bin/wsadmin.sh -f /api-usagemetering/scripts/configuretWasUsageMetering.py url=$(cat /opt/IBM/WebSphere/metering-url.txt) apiKey=$(cat /opt/IBM/WebSphere/api-key.txt) trustStorePassword=th1nkpassword

echo "Server registered, go to the WSA Dashboard"


