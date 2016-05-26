#! /bin/bash
# This script is a workaround to fix a FW issue for Panda box.
# So, we only enable the OS customized watchdog if and only if
# the system is a panda box and its FW ver is less than 2.71

start() {
	# verify /boot/.modelno
	# panda model is DD610, DD630, or DD140
	while read line; do
		if [ $line = "DD610" ] || 
		   [ $line = "DD630" ] ||
		   [ $line = "DD140" ]; then
			echo $line
		else
			exit 0
		fi
	done < "/boot/.modelno"

	# get BMC FW version
	ver=`/usr/bin/ipmitool bmc info | grep "Firmware Revision" | awk '{ print $4 }'`

	# verify if version is greater than 2.71 
	# (FW has fixed the issue after this ver)
	compare_result=`echo "$ver < 2.71" | bc`
	if [ $compare_result == 0 ]; then
	    exit 0
	fi

	if [ -f /usr/sbin/dd_panda_watchdog ]; then
		/usr/sbin/dd_panda_watchdog &
	else
		exit 1
	fi
}

stop() {
	pid=`ps ux | awk '/dd_panda_watchdog/ && !/awk/ {print $2}'`
	kill -9 $pid
}

status() {
	# verify /boot/.modelno
	# panda model is DD610, DD630, or DD140
	while read line; do
		if [ $line = "DD610" ] || 
		   [ $line = "DD630" ] ||
		   [ $line = "DD140" ]; then
			echo $line
		else
			echo Model number is not supported.
			exit 0
		fi
	done < "/boot/.modelno"

	# get BMC FW version
	ver=`/usr/bin/ipmitool bmc info | grep "Firmware Revision" | awk '{ print $4 }'`

	# verify if version is greater than 2.71 
	# (FW has fixed the issue after this ver)
	compare_result=`echo "$ver < 2.71" | bc`
	if [ $compare_result == 0 ]; then
		echo Pre-timeout action is supported by BMC firmware version $ver.
	    exit 0
	fi

	pid=`ps ux | awk '/dd_panda_watchdog/ && !/awk/ {print $2}'`
	if [ -z $pid ]; then
		echo "panda watchdog is disabled"
	else
		echo "panda watchdog is enabled"
	fi
}

case "$1" in
    start)
		start
        ;;
    stop)
		stop
        ;;
    status)
		status
        ;;
    *)
        echo $"Usage: $0 {start|stop|status}"
        exit 1
esac

exit 0
