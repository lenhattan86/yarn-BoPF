cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  4 bursty0 >> ~/SWIM/scriptsTest/workGenLogs/interactive-4_0.txt 2>> ~/SWIM/scriptsTest/workGenLogs/interactive-4_0.txt  &  interactive4="$interactive4 $!"  
wait $interactive4 
