#!/bin/sh
XEND=325
X=1
while [ $X -le $XEND ]
do
 #echo "X is ${X}"
 MOD25=`expr $X % 25`
 if [ "$MOD25" == "0" ]
 then
  echo "Decreased heap usage by ${X}MB"
 fi
 curl http://student.demo.ibmdte.net:9081/MLApp/MLVectorParam?myaction=removeLast 2&>1
 X=`expr $X + 1`
done
curl http://student.demo.ibmdte.net:9081/MLApp/GC 2&>1

echo

