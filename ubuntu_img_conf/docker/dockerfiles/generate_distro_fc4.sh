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
ROOTFS=${TMPDIR:-/tmp}/rootfs-distrofc4-$$-$RANDOM
mkdir $ROOTFS
cd $ROOTFS

SRC="/distro/distro_main_test/262005/root"

mkdir bin dev etc include lib lib64 opt proc sbin sys tmp usr var
# touch etc/resolv.conf
# cp /etc/nsswitch.conf etc/nsswitch.conf
# echo root:x:0:0:root:/:/bin/sh > etc/passwd
# echo root:x:0: > etc/group

# /bin
cp -R ${SRC}/bin/* bin

# /dev
for X in console null ptmx random stdin stdout stderr tty tty0 urandom zero
do
    sudo cp -a /dev/$X dev
done

# /etc
cp -R ${SRC}/etc/* etc

# /include
cp -R ${SRC}/include/* include

# /lib
cp -R ${SRC}/lib/* lib

# /lib64
cp -R ${SRC}/lib64/* lib64

# /opt
cp -R ${SRC}/opt/* opt

# /sbin
cp -R ${SRC}/sbin/* sbin

# /usr
cp -R ${SRC}/usr/* usr

# /var
cp -R ${SRC}/var/* var

# tar --numeric-owner -cf- . | docker import - busybox
# docker run -i -u root busybox /bin/echo Success.
# tar zcf ../$name.tar ./
# cat /tmp/fedora.tar | docker import - fedora

