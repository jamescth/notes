#!/usr/bin/env bash
#
# https://github.com/docker/docker/blob/master/contrib/mkimage-yum.sh
# needs to run on jho1-dl.datadomain.com (FC4)
# https://github.com/docker/docker/blob/master/contrib/mkimage-busybox.sh

echo >&2
echo >&2 'warning: this script is deprecated - see mkimage.sh and mkimage/busybox-static'
echo >&2

BUSYBOX=$(which busybox)
[ "$BUSYBOX" ] || {
    echo "Sorry, I could not locate busybox."
    echo "Try 'apt-get install busybox-static'?"
    exit 1
}

set -e
ROOTFS=${TMPDIR:-/tmp}/rootfs-busybox-$$-$RANDOM
mkdir $ROOTFS
cd $ROOTFS

mkdir bin dev etc lib lib64 opt proc sbin sys tmp usr var
# touch etc/resolv.conf
# cp /etc/nsswitch.conf etc/nsswitch.conf
# echo root:x:0:0:root:/:/bin/sh > etc/passwd
# echo root:x:0: > etc/group

# /bin
cp -R /bin/* bin

# /dev
cp -R /dev/* dev

# /etc
cp -R /etc/* etc

# /lib
cp -R /lib/* lib

# /lib64
cp -R /lib64/* lib64

# /sbin
cp -R /sbin/* sbin

# /usr
cp -R /usr/* usr

# /var
cp -R /var/* var

# tar --numeric-owner -cf- . | docker import - busybox
# docker run -i -u root busybox /bin/echo Success.
# tar zcf ../$name.tar ./
# cat /tmp/fedora.tar | docker import - fedora

