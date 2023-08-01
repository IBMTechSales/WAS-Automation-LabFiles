#!/bin/sh
XEND=285
X=1
while [ $X -le $XEND ]
do
 #echo "X is ${X}"
 MOD25=`expr $X % 25`
 if [ "$MOD25" == "0" ]
 then
  echo "Decreased heap usage by ${X}MB"
 fi
 curl http://localhost:9080/MLApp/MLVectorParam?myaction=removeLast 2&>1
 X=`expr $X + 1`
done
curl http://localhost:9080/MLApp/MLApp/GC 2&>1

echo

