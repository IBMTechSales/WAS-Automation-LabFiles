cp /etc/hosts /etc/hosts.sav
sed 's/student/student.ocp.ibm.edu/' /etc/hosts > new_hosts
cp new_hosts /etc/hosts
cat /etc/hosts

#!/bin/bash
curl -o setup_agent.sh https://setup.instana.io/agent && chmod 700 ./setup_agent.sh && sudo ./setup_agent.sh -a qUMhYJxjSv6uZh2SyqTEnw -t dynamic -e techsales.demos.net:1444   -s
      
