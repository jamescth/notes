#!/bin/sh

#LNXDIR=/p4/main/platform/os/linux-2.6.23
LNXDIR=/auto/builds/main/292579/os/linux-2.6.23

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
