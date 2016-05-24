#!/bin/sh

#LNXDIR=/p4/main/platform/os/linux-2.6.23
LNXDIR=/p4/nk32_ddump_p1/platform/os/linux-3.2

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
