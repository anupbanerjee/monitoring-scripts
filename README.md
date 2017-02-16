# monitoring-scripts

/bin/systemstatistics.sh - This scripts gets information of CPU/Disk/Memory on any Linux box

/bin/javastatistics.sh - This scripts gets the running Java process id and get some statistics around
		Heap Configured, Heap Utilized, Minor GC Count, Minor GC Time, Full GC Count, Full GC Count, Total Pause, Utilization of heap etc

NOTE: This script is tested to run on JDK 1.8, also please modify your JDK path and test it prior to scheduling it.

The above scripts collects system statistics and using CURL command posts data to InfluxDB. InfluxDB exposes a REST URI to read/write.
The URL In Script is where InfluxDB is hosted - http://54.89.247.53:8086/write?db=qa_environment_statistics

The information can then be used to display graphs and reports in Grafana http://54.89.247.53:3000/

To create a cron job to run every 1 min

# Grafana Collector for System statistics
*/1 * * * * /your/script/location/systemstatistics.sh > /dev/null 2>&1

# Grafana Collector for Java statistics
*/1 * * * * /your/script/location/javastatistics.sh > /dev/null 2>&1
