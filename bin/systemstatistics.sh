#!/bin/sh

# Calculating Memory Metrics
free -m | awk 'NR==2{printf "Memory Usage: %s/%sMB (%.2f%%)\n", $3,$2,$3*100/$2 }'

TOTAL_MEMORY=$(free -m | awk 'NR==2{print $2}')
AVAILABLE_MEMORY=$(free -m | awk 'NR==2{print $3}')
MEMORY_UTILIZATION=$(free -m | awk 'NR==2{print $3*100/$2 }')


# CPU Utlization Metrics
#CPU_UTILIZATION=$(top -bn1 | grep load | awk '{print $(NF-2)}')
CPU_UTILIZATION=$(top -b -n2 -p 1 | fgrep "Cpu(s)" | tail -1 | awk -F'id,' -v prefix="$prefix" '{ split($1, vs, ","); v=vs[length(vs)]; sub("%", "", v); printf "%s%.1f%%\n", prefix, 100 - v }')

CPU_UTILIZATION="${CPU_UTILIZATION//%}"

# Get Host Name
HOST_NAME=$(hostname)

# DISK Utilization Metrics

DISK_STATS=$(df -P | awk '{ print $5 " " $1 }'| awk '{ print $1}' | cut -d'%' -f1)

DISK_STATS=${DISK_STATS[@]:4}

DISK_STATS=(${DISK_STATS// / })

MAX_DISK=${DISK_STATS[0]}
MIN_DISK=${DISK_STATS[0]}

# Loop through all elements in the array

for i in "${DISK_STATS[@]}"
do
    # Update MAX_DISK if applicable
    if [[ "$i" -gt "$MAX_DISK" ]]; then
        MAX_DISK="$i"
    fi

    # Update MIN_DISK if applicable
    if [[ "$i" -lt "$MIN_DISK" ]]; then
        MIN_DISK="$i"
    fi
done

SYSTEM_IDLE=$(top -bn1 | grep load | awk '{print $(NF-3)}')


echo "**********************************************************"
echo "TOTAL MEMORY : "$TOTAL_MEMORY
echo "AVAILABLEL MEMORY : "$AVAILABLE_MEMORY
echo "MEMORY UTILIZATION % : "$MEMORY_UTILIZATION
curl -i -XPOST 'http://54.89.247.53:8086/write?db=qa_it_operational_intelligence' --data-binary 'memory_stats,hostname='$HOST_NAME',application=MOSAIC,component=DI total_memory='$TOTAL_MEMORY',available_memory='$AVAILABLE_MEMORY',memory_utilization='$MEMORY_UTILIZATION 



echo "CPU UTILIZATION :"$CPU_UTILIZATION
curl -i -XPOST 'http://54.89.247.53:8086/write?db=qa_it_operational_intelligence' --data-binary 'cpu_stats,hostname='$HOST_NAME',application=MOSAIC,component=DI cpu='$CPU_UTILIZATION

echo "MAX DISK USAGE :"$MAX_DISK
curl -i -XPOST 'http://54.89.247.53:8086/write?db=qa_it_operational_intelligence' --data-binary 'disk_stats,hostname='$HOST_NAME',application=MOSAIC,component=DI disk='$MAX_DISK

echo "SYSTEM IDLE TIME :"$SYSTEM_IDLE
echo "HOST NAME :"$HOST_NAME
echo "**********************************************************"

