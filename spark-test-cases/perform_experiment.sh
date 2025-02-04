#!/usr/bin/env bash

if [ -z "$2" ]
then
  task=5000
else
  task=$2
fi


SPARK_COMMAND="../spark/bin/spark-submit --master yarn --class org.apache.spark.examples.SparkPi --deploy-mode cluster"
SPARK_OPTS="--driver-memory 1024M --executor-memory 1024M --executor-cores 1"
#SPARK_JAR="./spark/lib/spark-examples*.jar 500000"
SPARK_JAR="../spark/examples/jars/spark-examples*.jar $task"

for i in `seq $1 $1`;
do
  >&2 echo "Running $i applications in parallel..."
  
  for j in `seq 1 $i`;
  do
	for k in `seq 1 $j`; # not necessary
	do
	    >&2 echo "	Starting application $j."
	    if [ -z "$3" ]
	    then
	      FULL_COMMAND="$SPARK_COMMAND $SPARK_OPTS --queue interactive $SPARK_JAR"
	    else
	      FULL_COMMAND="$SPARK_COMMAND $SPARK_OPTS --queue $3 $SPARK_JAR"
	    fi
	    #FULL_COMMAND="sleep 1"
	    #(TIMEFORMAT='%R'; time $FULL_COMMAND 2>application$i\.$j) 2> $j.time &
	    $FULL_COMMAND &
	done
  done
#  >&2 echo "Waiting for all applications to finish..."
  wait

  cat *.time > times$i.txt
  rm *.time

#  sleep 60
done
