/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package cpubound;

import java.io.PrintWriter;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.TimeZone;

import org.apache.flink.api.common.functions.FlatMapFunction;
import org.apache.flink.api.java.tuple.Tuple2;
import org.apache.flink.api.java.utils.ParameterTool;
import org.apache.flink.streaming.api.datastream.DataStream;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;
import org.apache.flink.util.Collector;

/**
 * Implements the "WordCount" program that computes a simple word occurrence
 * histogram over text files in a streaming fashion.
 * 
 * <p>
 * The input is a plain text file with lines separated by newline characters.
 * 
 * <p>
 * Usage: <code>WordCount --input &lt;path&gt; --output &lt;path&gt;</code><br>
 * If no parameters are provided, the program is run with default data from
 * {@link WordCountData}.
 * 
 * <p>
 * This example shows how to:
 * <ul>
 * <li>write a simple Flink Streaming program,
 * <li>use tuple data types,
 * <li>write and use user-defined functions.
 * </ul>
 *  
 */

// CPU bound + Disk IO bound
public class WordCount {
	private static final int BOUND = 1000;
	private static final boolean isDumpCompuation = true;
	private static final double counterBound = 30000; // 10000-> 2 mins,
//	private static final double counterBound = 3000; // 10000-> 2 mins,
	private static final double nLoop = 2*Math.pow(10, 6); // (10, 7) ~ 100% cpu
	private static final String timeStampFile = "cpubound.csv";	

	// *************************************************************************
	// PROGRAM
	// *************************************************************************

	public static void main(String[] args) throws Exception {
		try (PrintWriter out = new PrintWriter("filename.txt")) {
			out.println(Utils.currentTimestamp());
		}

		// Checking input parameters
		final ParameterTool params = ParameterTool.fromArgs(args);
		System.out.println("Usage: WordCount --input <path> --output <path>");

		// set up the execution environment
		final StreamExecutionEnvironment env = StreamExecutionEnvironment
				.getExecutionEnvironment();

		// make parameters available in the web interface
		env.getConfig().setGlobalJobParameters(params);

		// get input data
		DataStream<String> text;
		if (params.has("input")) {
			// read the text file from given input path
			text = env.readTextFile(params.get("input"));
		} else {
			System.out
					.println("Executing WordCount example with default input data set.");
			System.out.println("Use --input to specify file input.");
			// get default test text data
			text = env.fromElements(WordCountData.WORDS);
			// text = env.readTextFile("hdfs:///cpubound/cpubound1.txt");
		}
		// split up the lines in pairs (2-tuples) containing: (word,1)
		DataStream<Tuple2<String, Integer>> counts = text
				.flatMap(new Tokenizer())
				// group by the tuple field "0" and sum up tuple field "1"
				.keyBy(0).sum(1);

		// emit result
		if (params.has("output")) {
			counts.writeAsText(params.get("output"));
		} else {
			System.out
					.println("Printing result to stdout. Use --output to specify output path.");
			counts.print();
		}

		// execute program
		env.execute("Streaming WordCount");
	}

	// *************************************************************************
	// USER FUNCTIONS
	// *************************************************************************

	/**
	 * Implements the string tokenizer that splits sentences into words as a
	 * user-defined FlatMapFunction. The function takes a line (String) and
	 * splits it into multiple pairs in the form of "(word,1)" (
	 * {@code Tuple2<String,
	 * Integer>}).
	 */
	public static final class Tokenizer implements
			FlatMapFunction<String, Tuple2<String, Integer>> {
		private static final long serialVersionUID = 1L;
		

		@Override
		public void flatMap(String value, Collector<Tuple2<String, Integer>> out)
				throws Exception {
			// normalize and split the line
			String[] tokens = value.toLowerCase().split("\\W+");

			// emit the pairs
			for (String token : tokens) {
				if (token.length() > 0) {
					if (isDumpCompuation) 
						Utils.runDumpCompuation(nLoop);
					// Add dump computation
					out.collect(new Tuple2<String, Integer>(token, 1));
				}
			}
		}
	}

}
