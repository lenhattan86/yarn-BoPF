cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100015 batch7 >> ~/SWIM/scriptsTest/workGenLogs/batch-15.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-15.txt  &  batch15=$!  
wait $batch15 
