cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100025 batch0 >> ~/SWIM/scriptsTest/workGenLogs/batch-25.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-25.txt  &  batch25=$!  
wait $batch25 
