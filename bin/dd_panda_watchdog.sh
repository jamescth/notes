#! /bin/bash
# This script is called by /rc.d/init.d/panda_watchdog

#shell's pid
pid=$$
renice -20 $pid
echo Speacial panda watchdog pid $pid> /dev/kmsg

stage=0
read_err=0

while [ 1 ]
do
	#Get Pre-timeout
	preTimeout=`/usr/bin/ipmitool mc watchdog get | grep "Pre-timeout interval" | 
	            awk '{ print $3 }'`
	# if pretimeout is 0, then, it's disable.  sleep and check again later.
	if [[ $preTimeout = 0 ]]; then
		sleep 60
		continue
	fi

	#Get Present Count String
	presentString=`/usr/bin/ipmitool mc watchdog get | grep "Present Countdown"`

	presentLeadingString=`echo $presentString | awk '{ print $1 $2 }'`
	if [[ $presentLeadingString != "PresentCountdown:" ]]; then
		# if the leading String after awk is not "PresentCountdown",
		# BMC didn't return the wanted answer back to us.
		((read_err++))
		echo IPMI watchdog not able to get present time value $read_err > /dev/kmsg

		if [[ $read_err -eq 10 ]]; then
			# if we retry 10 times & still having issue, panic.
			echo IPMI mc watchdog get retry reached.  System panic. > /dev/kmsg
			echo crashdump > /proc/diskdump
		else
			# Crond runs every 60 secs.
			# sleep 70 here to avoid run with crond pretimeout reset.
			sleep 70
			continue
		fi
	else
		presentCount=`echo $presentString | awk '{ print $3 }'`
		# if we can read presentCount, reset read_err.
		read_err=0
	fi

	#set alarm is Pretimeout+5 secs
	alarm=`echo "$preTimeout + 5" | bc`

	# if the countdown value is less than pretimeout, take a core dump.
	if [[ $presentCount -le $alarm ]]; then
		echo IPMI pretimeout reached.  System panic. > /dev/kmsg
		echo crashdump > /proc/diskdump
	fi

	if [[ $presentCount -gt 900 ]]; then
		stage=0
	elif [[ $presentCount -le 900 ]] && [ $stage = 0 ]; then
		stage=1
		echo Watchdog has not been updated for 5 mins > /dev/kmsg
	elif [[ $presentCount -le 600 ]] && [ $stage = 1 ]; then
		stage=2
		echo  Watchdog has not been updated for 10 mins > /dev/kmsg
	elif [[ $presentCount -le 300 ]] && [ $stage = 2 ]; then
		stage=3
		echo  Watchdog has not been updated for 15 mins > /dev/kmsg
	fi

	# if the present count is getting close to the pretimeout value, 
	# sleep on the real delta instead of 60.
	if [[ $presentCount -le 320 ]]; then
		sleep_val=`echo "$presentCount - $preTimeout" | bc`
		sleep $sleep_val
	else
		sleep 60
	fi
done
