#!/bin/sh

#LNXDIR=/auto/devbuilds/20120607012253_hoj9/310402/os/linux-3.2/
#LNXDIR=/auto/buildarchive/5.1.0A/282511/os/linux-2.6.23
#LNXDIR=/auto/builds/main/317538/os/linux-2.6.23
LNXDIR=/auto/builds/nk3_pre

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
