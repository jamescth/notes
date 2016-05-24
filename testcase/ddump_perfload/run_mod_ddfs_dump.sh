#!/bin/sh
rmmod -f scsi_dump
rmmod diskdump

insmod ./diskdump.ko
insmod ./scsi_dump.ko
/usr/sbin/config_crashdump

#pid=`pidof ddfs`
#echo kill -sigabrt $pid
#kill -sigabrt ${pid}

#echo dump > /proc/diskdump
#echo crashdump > /proc/diskdump
