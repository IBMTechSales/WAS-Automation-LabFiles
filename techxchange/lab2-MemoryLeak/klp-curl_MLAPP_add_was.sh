#!/bin/sh
XEND=285
X=1

#force a GC before running mem leak app
echo "--> forcing garbage collection"
curl http://localhost:9080/MLApp/GC 2&>1
sleep 3
echo "--> Wait 10 seconds for memory to be released"

#wait for memory to clear
sleep 10 

echo "--> Invoking memory leak app"

echo ""

while [ $X -le $XEND ]
do
 MOD25=`expr $X % 25`
 if [ "$MOD25" == "0" ]
 then
  echo "Increased heap usage by ${X}MB"
 fi
 curl http://localhost:9080/MLApp/MLVectorParam?myaction=add 2&>1
 X=`expr $X + 1`
done

echo
