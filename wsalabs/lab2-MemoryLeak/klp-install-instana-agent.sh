#!/bin/bash

echo ""
echo "-------------------------"
echo "Install the instana agent" 
echo "-------------------------"
echo "" 
echo "curl -o setup_agent.sh https://setup.instana.io/agent && chmod 700 ./setup_agent.sh && sudo ./setup_agent.sh -a qUMhYJxjSv6uZh2SyqTEnw -t dynamic -e techsales.demos.net:1444 -s -y "
echo ""

curl -o setup_agent.sh https://setup.instana.io/agent && chmod 700 ./setup_agent.sh && sudo ./setup_agent.sh -a qUMhYJxjSv6uZh2SyqTEnw -t dynamic -e techsales.demos.net:1444 -s -y 


sleep 3

cd /home/ibmuser

echo ""
echo "Copy the instana configuration.yaml file for customization" 
echo "" 
echo "rm /home/ibmuser/configuration.yaml"
echo "cp /opt/instana/agent/etc/instana/configuration.yaml /home/ibmuser"
echo "cp /opt/instana/agent/etc/instana/configuration.yaml /opt/instana/agent/etc/instana/configuration.yaml.BAK"
echo ""

if [[ -f /home/ibmuser/configuration.yaml ]]; then
  echo "removing old configuration.yaml in /home/ibmuser directory"  
  sudo rm /home/ibmuser/configuration.yaml
fi



sleep 1
sudo \cp /opt/instana/agent/etc/instana/configuration.yaml /home/ibmuser
sleep 1
sudo cp /opt/instana/agent/etc/instana/configuration.yaml /opt/instana/agent/etc/instana/configuration.yaml.BAK
sleep 1

FILENAME="/home/ibmuser/configuration.yaml"




echo ""
echo "---------------------------------------------------------------------"
echo "Modifying the Instana configuration.yaml to enable the hardware plugin - HARDWARE & ZONE named 'WebSphere"
echo "---------------------------------------------------------------------"
echo ""
echo " changing this.... " 
echo "-------------------------------------------------"
echo ""
echo "# Hardware & Zone"
echo "#com.instana.plugin.generic.hardware:"
echo "#  enabled: true # disabled by default"
echo "#  availability-zone: 'Datacenter A / Rack 42'"
echo "-------------------------------------------------"
echo ""
echo ""
echo "  to this..."
echo "-------------------------------------------------"
echo ""
echo "Hardware & Zone"
echo "com.instana.plugin.generic.hardware:"
echo "   enabled: true # disabled by default"
echo "   availability-zone: 'WebSphere'"
echo "-------------------------------------------------"
echo ""

sleep 5

PLUGIN="#com.instana.plugin.generic.hardware:"
ENABLED="#  enabled: true # disabled by default"
ZONE="#  availability-zone: 'Datacenter A \/ Rack 42'"

R_PLUGIN="com.instana.plugin.generic.hardware:"
R_ENABLED="  enabled: true # disabled by default"
R_ZONE="  availability-zone: 'WebSphere'"

echo ""
echo "sudo sed -i "s/$PLUGIN/$R_PLUGIN/" $FILENAME"
echo ""

sudo sed -i "s/$PLUGIN/$R_PLUGIN/" $FILENAME

sleep 1
echo ""
echo "sudo sed -i "s/$ENABLED/$R_ENABLED/" $FILENAME"
echo ""

sudo sed -i "s/$ENABLED/$R_ENABLED/" $FILENAME

sleep 1
#  sudo sed -i s/"#  availability-zone: 'Datacenter A \/ Rack 42'"/"  availability-zone: 'WebSphere'"/ /home/ibmuser/configuration.yaml
echo ""
echo "sudo sed -i "s/$ZONE/$R_ZONE/" $FILENAME"
echo ""

sudo sed -i "s/$ZONE/$R_ZONE/" $FILENAME

sleep 1
echo ""
echo "Copy configuration.yaml back to the original directory"
echo ""
echo "cp /home/ibmuser/configuration.yaml /opt/instana/agent/etc/instana/configuration.yaml"
echo "" 

sudo \cp /home/ibmuser/configuration.yaml /opt/instana/agent/etc/instana/configuration.yaml

sleep 1 
echo ""
echo "---------------------------------------------------"
echo "Restarting Instana agent with the new configuration"
echo "---------------------------------------------------" 
echo "" 
echo "sudo systemctl start instana-agent.service" 
echo "" 
echo "--------------------------------------------------------------"
echo " ---> Note: If prompted, enter the sudo password as: engageibm" 
echo "--------------------------------------------------------------"

sudo systemctl start instana-agent.service

sleep 3

echo "" 
echo " End of klp-install-instana-agant.sh" 
echo ""









