#!/bin/sh
/opt/IBM/WebSphere/AppServer9056/bin/wsadmin.sh -f /home/ibmuser/WAS-Automation-LabFiles/lab2-MemoryLeak/setMaxHeapAndJVMarg.py
/opt/IBM/WebSphere/AppServer9056/bin/wsadmin.sh -f /home/ibmuser/WAS-Automation-LabFiles/lab2-MemoryLeak/install_MLApp.py
