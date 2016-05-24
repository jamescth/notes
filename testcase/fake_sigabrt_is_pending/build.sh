#!/bin/sh

#LNXDIR=/p4/main/platform/os/linux-2.6.23
#LNXDIR=/p4/65528_ddump_msg/platform/os/linux-2.6.23
#LNXDIR=/auto/devbuilds/20120510220006_hoj9/306617/os/linux-2.6.23
LNXDIR=/auto/builds/main/348629/os/linux-2.6.23

if [ $# -eq 0 ]; then
    action=all
else
    action=$1
fi

if [ $action = all ]; then
    make -C ${LNXDIR} M=`pwd`
elif [ $action = clean ]; then
    make -C ${LNXDIR} M=`pwd` clean
fi
