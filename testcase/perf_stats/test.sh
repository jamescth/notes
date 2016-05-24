#!/bin/bash
#echo "$#, parameters"
#echo "$@";

TMP_FILE="runq.tmp"
OUTPUT_FILE="runq.txt"
ARRAY_SIZE=16
ARRAY_MINUS_1=$(( ${ARRAY_SIZE} - 1 ))
KPERF_MOD="perf_stats.ko"
OUTPUT_STRING=""
cpus=32
cpu_counter=0
cpu_index=1
array_index=0

runq_array_="`echo runq_array_${array_index}`"

OUTPUT_STRING="`echo insmod ${KPERF_MOD} ${runq_array_}=`"

while read line; do

	cpu_counter=$(( ${cpu_counter} + 1 ))
	if [ ${cpu_index} -eq ${ARRAY_SIZE} ]; then
		OUTPUT_STRING="`echo ${OUTPUT_STRING}0x${line}`"
		array_index=$(( ${array_index} + 1 ))
		runq_array_="`echo runq_array_${array_index}`"
		cpu_index=1

		if [ ${cpu_counter} == ${cpus} ]; then
			break
		else
			OUTPUT_STRING="`echo ${OUTPUT_STRING} ${runq_array_}=`"
		fi

	else
		OUTPUT_STRING="`echo ${OUTPUT_STRING}0x${line},`"
		cpu_index=$(( ${cpu_index} + 1 ))
	fi

#	runq_array_="`echo ${runq_array_},`"
done < ${OUTPUT_FILE}

#echo "insmod ${KPERF_MOD} runq_array_=${runq_array_}"
echo "${OUTPUT_STRING}"

