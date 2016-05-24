#!/bin/sh

#LNXDIR=/p4/main/platform/os/linux-2.6.23
#LNXDIR=/p4/65528_ddump_msg/platform/os/linux-2.6.23
#LNXDIR=/auto/builds/main/317538/os/linux-2.6.23
#LNXDIR=/auto/builds/koala/318977/os/linux-2.6.23
#LNXDIR=/auto/builds/main/313432/os/linux-2.6.23
#LNXDIR=/auto/builds/main/319837/os/linux-2.6.23
LNXDIR=/p4/nk32_port_dd/platform/os/linux-3.2

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
