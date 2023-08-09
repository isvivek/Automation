#!/bin/bash
# Basic health check script of appliance
# Contact info : is_vivek@yahoo.co.in

# Memory Util Function
memutil ()
{
used=`free -m | grep "+" | awk {'print $3'}`
usd=`expr $used '*' 100`
total=`free -mt | grep Mem |awk {'print $2'}`
memusage=`expr $usd / $total`
echo "Memory Utilization is $memusage %"
echo
echo "Top 5 Memory Utilizing Processes are below : "
echo 
echo "Used% PID  ProcessInfo"
echo 
ps -eo pmem,pid -o comm | sort -k1nr | head -5
}

#CPU Util function
cpuutil ()
{
idl=`iostat  | head -4| tail -1 | awk '{print $6}'|cut -d. -f1`
usg=`expr 100 - $idl`
echo "CPU Utilization is $usg %"
echo
echo "Top 5 CPU Utilizing Processes are below : "
echo 
echo "Used% PID  ProcessInfo"
echo
ps -eo pcpu,pid -o comm | sort -k1nr | head -5
}

#System Load Function
load ()
{
load=`uptime | awk -F: '{print $4}'`
echo "CPU Load Avg is $load"
}

#Service Check Function and variable
outfile=/root/outfile
servicecheck ()
{
runl=`runlevel | awk '{print $2}'`
echo "All auto start Services are being checked..."
echo
for i in `chkconfig --list | grep $runl:on|egrep -v 'splash|nfs'|awk '{print $1}'`
do
/etc/init.d/$i status  > /dev/null 2>&1
if [ $? -ne 0 ]
then
echo "$i is Down" >> $outfile
fi
done
out=`cat $outfile|wc -l`
if [ $out -ne 0 ]
then
cat $outfile
else
echo "All services are up and running fine"
fi
> /root/outfile
}

echo "____________________________________________________________"
echo
memutil
echo
echo "____________________________________________________________"
echo
cpuutil
echo
echo "____________________________________________________________"
echo
load
echo
echo "____________________________________________________________"
echo
servicecheck
echo
echo "____________________________________________________________"
echo

