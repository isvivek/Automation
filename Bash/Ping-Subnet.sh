#!/bin/bash
echo -n "Enter the IP Range without last octet (Eg: 172.17.12) "
read IPRNG
for i in `echo {1..254}`
do
ping -c 2 $IPRNG.$i > /dev/null 2>&1
if [ $? -eq 0 ]
then
echo "$IPRNG.$i is Up" >> /tmp/output
else
echo "$IPRNG.$i is Down" >> /tmp/output
fi
done
