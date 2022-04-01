#!/bin/sh
/opt/IBM/WebSphere/AppServer9056/bin/wsadmin.sh -f /home/ibmuser/WSAlab2/setMaxHeapAndJVMarg.py
/opt/IBM/WebSphere/AppServer9056/bin/wsadmin.sh -f /home/ibmuser/WSAlab2/install_MLApp.py
