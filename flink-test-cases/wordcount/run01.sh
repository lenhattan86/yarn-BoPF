# Start timming
#flink="../../build-target"
flink="$HOME/flink-1.0.3"
#rm -rf app01.csv
for i in `seq 1 3`;	
do
	date --rfc-3339=seconds >> app01.csv
	# run the Flink app
	#$flink/bin/flink run -p 64 $flink/examples/streaming/WordCount.jar --input hdfs:///wordcount/app01.txt 
	$HOME/flink-1.0.3/bin/flink run -m yarn-cluster -yn 63 -yq -yst $HOME/flink-1.0.3/examples/streaming/WordCount.jar --input hdfs:///wordcount/app01.txt
	# Stop timming
	date --rfc-3339=seconds >> app01.csv        
	sleep 30
done  

