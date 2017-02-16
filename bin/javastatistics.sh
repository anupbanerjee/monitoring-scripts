#!/bin/sh
JSTAT=/opt/app/java/current/bin/jstat

# Works for JDK 1.8, script for JDK 1.7 is little different

#PID=`pgrep -u jboss -f 'org.jboss.Main -c idm-was-sup -b 0.0.0.0'`
PID=`ps -ef | grep '/opt/app/java/current/bin/java' |grep -v grep | awk '{print $2}'`

#get hostname
HOST_NAME=$(hostname)

echo "PID IS "$PID

# Exit the shell script if PID is null
if [ "$PID" = '' ]
then
   echo "Exiting the application, PID is null"
   exit 1
fi

JSTAT_METRICS=`$JSTAT -gc $PID`

TOTAL_HEAP=`echo $JSTAT_METRICS | awk '{printf "%.0f\n", $18+$19+$22+$24}'`
HEAP_UTILIZED=`echo $JSTAT_METRICS | awk '{printf "%.0f\n", $20+$21+$23+$25}'`
GCT=`echo $JSTAT_METRICS | awk '{printf "%f\n", $34}'`
HEAP_UTILIZED_PERCENT=`expr $HEAP_UTILIZED \* 100 / $TOTAL_HEAP`

MINOR_GC=`echo $JSTAT_METRICS | awk '{printf "%.0f\n", $30}'`
MINOR_GC_TIME=`echo $JSTAT_METRICS | awk '{printf "%f\n", $31}'`

FULL_GC=`echo $JSTAT_METRICS | awk '{printf "%.0f\n", $32}'`
FULL_GC_TIME=`echo $JSTAT_METRICS | awk '{printf "%f\n", $33}'`


echo "***********************************************************"
echo "TOTAL HEAP :"$TOTAL_HEAP
echo "HEAP UTILIZED :"$HEAP_UTILIZED
echo "GARBAGE COLLECTION TIME :"$GCT
echo "HEAP UTILIZATION % :"$HEAP_UTILIZED_PERCENT
echo "MINOR GCs :"$MINOR_GC
echo "MINOR GC TIME :"$MINOR_GC_TIME
echo "FULL GCs :"$FULL_GC
echo "FULL GC TIME :"$FULL_GC_TIME
echo "***********************************************************"

curl -i -XPOST 'http://54.89.247.53:8086/write?db=qa_environment_statistics' --data-binary 'java_stats,hostname='$HOST_NAME',application=MOSAIC,component=DI total_heap='$TOTAL_HEAP',heap_utilized='$HEAP_UTILIZED',garbage_collection_time='$GCT',heap_percent_utilized='$HEAP_UTILIZED_PERCENT',minor_gc_count='$MINOR_GC',minor_gc_time='$MINOR_GC_TIME',full_gc_count='$FULL_GC',full_gc_time='$FULL_GC_TIME

