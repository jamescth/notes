#!/bin/sh

#LNXDIR=/p4/main/platform/os/linux-2.6.23
#LNXDIR=/p4/82201_slab/platform/os/linux-2.6.23
#LNXDIR=/auto/builds/main/317538/os/linux-2.6.23
#LNXDIR=/auto/builds/koala/318977/os/linux-2.6.23
LNXDIR=/auto/devbuilds/20121112173847_hoj9/341279/os/linux-2.6.23

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
