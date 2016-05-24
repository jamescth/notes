#!/bin/sh

#LNXDIR=/p4/main/platform/os/linux-2.6.23
#LNXDIR=/auto/builds/5.1.0A/282511/os/linux-2.6.23
#LNXDIR=/auto/builds/main/309425/os/linux-2.6.23
LNXDIR=/auto/devbuilds/20120824005020_hoj9/324360/os/linux-2.6.23/

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
