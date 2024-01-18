# 10.100.1.51 student.ocp.ibm.edu.ocp.ibm.edu student.demo.ibmdte.net

cp /etc/hosts /etc/hosts.sav

sed -i '/10.100.1.51 student.ocp.ibm.edu.ocp.ibm.edu student.demo.ibmdte.net/d' /etc/hosts

echo "10.100.1.51 student.ocp.ibm.edu.ocp.ibm.edu student.demo.ibmdte.net" >> /etc/hosts

cp /etc/hosts new_hosts

cat /etc/hosts



#!/bin/bash

curl -o setup_agent.sh https://setup.instana.io/agent && chmod 700 ./setup_agent.sh && sudo ./setup_agent.sh -a qUMhYJxjSv6uZh2SyqTEnw -t dynamic -e techsales.demos.net:1444   -s -y

