#!/usr/bin/env bash
#
# Generate a very minimal filesystem based on busybox-static,
# and load it into the local docker under the name "busybox"
#
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
ROOTFS=${TMPDIR:-/var/tmp}/rootfs-busybox-$$-$RANDOM
mkdir $ROOTFS
cd $ROOTFS

mkdir bin etc dev dev/pts lib lib64 usr proc sys tmp
touch etc/resolv.conf
cp /etc/nsswitch.conf etc/nsswitch.conf
echo root:x:0:0:root:/:/bin/sh > etc/passwd
echo root:x:0: > etc/group
ln -s bin sbin
cp $BUSYBOX bin

# /bin
#
# busybox 1.0 doesn't have the command list.  So, add them manually
# for X in $(busybox --list)
# do
#     ln -s busybox bin/$X
# done
ln -s busybox bin/basename
ln -s busybox bin/bunzip2
# ln -s busybox bin/busybox
ln -s busybox bin/bzcat
ln -s busybox bin/cat
ln -s busybox bin/chgrp
ln -s busybox bin/chmod
ln -s busybox bin/chown
ln -s busybox bin/chroot
ln -s busybox bin/chvt
ln -s busybox bin/clear
ln -s busybox bin/cmp
ln -s busybox bin/cp
ln -s busybox bin/cpio
ln -s busybox bin/cut
ln -s busybox bin/date
ln -s busybox bin/dc
ln -s busybox bin/dd
ln -s busybox bin/deallocvt
ln -s busybox bin/df
ln -s busybox bin/dirname
ln -s busybox bin/dmesg
ln -s busybox bin/dos2unix
ln -s busybox bin/du
ln -s busybox bin/dumpkmap
ln -s busybox bin/echo
ln -s busybox bin/egrep
ln -s busybox bin/env
ln -s busybox bin/expr
ln -s busybox bin/false
ln -s busybox bin/fbset
ln -s busybox bin/fgrep
ln -s busybox bin/find
ln -s busybox bin/free
ln -s busybox bin/freeramdisk
ln -s busybox bin/grep
ln -s busybox bin/gunzip
ln -s busybox bin/gzip
ln -s busybox bin/halt
ln -s busybox bin/head
ln -s busybox bin/hexdump
ln -s busybox bin/hostid
ln -s busybox bin/hostname
ln -s busybox bin/id
ln -s busybox bin/ifconfig
ln -s busybox bin/init
ln -s busybox bin/install
ln -s busybox bin/kill
ln -s busybox bin/killall
ln -s busybox bin/klogd
ln -s busybox bin/linuxrc
ln -s busybox bin/ln
ln -s busybox bin/load_policy
ln -s busybox bin/loadfont
ln -s busybox bin/loadkmap
ln -s busybox bin/logger
ln -s busybox bin/ls
ln -s busybox bin/lsmod
ln -s busybox bin/makedevs
ln -s busybox bin/md5sum
ln -s busybox bin/mkdir
ln -s busybox bin/mknod
ln -s busybox bin/mktemp
ln -s busybox bin/modprobe
ln -s busybox bin/more
ln -s busybox bin/mount
ln -s busybox bin/msh
ln -s busybox bin/mv
ln -s busybox bin/nc
ln -s busybox bin/openvt
ln -s busybox bin/pidof
ln -s busybox bin/ping
ln -s busybox bin/pivot_root
ln -s busybox bin/poweroff
ln -s busybox bin/ps
ln -s busybox bin/pwd
ln -s busybox bin/readlink
ln -s busybox bin/reboot
ln -s busybox bin/reset
ln -s busybox bin/rm
ln -s busybox bin/rmdir
ln -s busybox bin/rmmod
ln -s busybox bin/route
ln -s busybox bin/rpm2cpio
ln -s busybox bin/sed
ln -s busybox bin/sleep
ln -s busybox bin/sort
ln -s busybox bin/strings
ln -s busybox bin/stty
ln -s busybox bin/swapoff
ln -s busybox bin/swapon
ln -s busybox bin/sync
ln -s busybox bin/syslogd
ln -s busybox bin/tail
ln -s busybox bin/tar
ln -s busybox bin/tee
ln -s busybox bin/telnet
ln -s busybox bin/test
ln -s busybox bin/tftp
ln -s busybox bin/time
ln -s busybox bin/touch
ln -s busybox bin/tr
ln -s busybox bin/traceroute
ln -s busybox bin/true
ln -s busybox bin/tty
ln -s busybox bin/umount
ln -s busybox bin/uname
ln -s busybox bin/uniq
ln -s busybox bin/unix2dos
ln -s busybox bin/unzip
ln -s busybox bin/uptime
ln -s busybox bin/usleep
ln -s busybox bin/uudecode
ln -s busybox bin/uuencode
ln -s busybox bin/vi
ln -s busybox bin/wc
ln -s busybox bin/wget
ln -s busybox bin/which
ln -s busybox bin/whoami
ln -s busybox bin/xargs
ln -s busybox bin/yes
ln -s busybox bin/zcat

cp /bin/bash bin/bash
ln -s bin/bash bin/sh

rm bin/init
ln bin/busybox bin/init

# /lib
# cp /lib/x86_64-linux-gnu/lib{pthread,c,dl,nsl,nss_*}.so.* lib
# cp /lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 lib
# cp /lib/lib{pthread,c,dl,nsl,nss_*,term*}.so.* lib
# cp /lib/ld-* lib
sudo cp -R /lib/* lib

# /lib64
# cp /lib64/lib{pthread,c,dl,nsl,nss_*,term*}.so.* lib64
# cp /lib64/ld-* lib64
sudo cp -R /lib64/* lib64

# /dev
for X in console null ptmx random stdin stdout stderr tty urandom zero
do
    sudo cp -a /dev/$X dev
done

# gcc
# mkdir usr/bin usr/lib usr/lib/gcc usr/lib/gcc-lib usr/libexec
# cp /usr/bin/gcc usr/bin/gcc
# cp /usr/bin/gcc32 usr/bin/gcc32
# cp -R /usr/lib/gcc/* usr/lib/gcc
# cp -R /usr/lib/gcc-lib/* usr/lib/gcc-lib
# cp -R /usr/libexec/gcc/* usr/libexec/gcc

sudo cp -R /auto/home3/faroos1/gcc-3.4.4/lib/* lib
sudo cp -R /auto/home3/faroos1/gcc-3.4.4/lib64/* lib64
sudo cp -R /auto/home3/faroos1/gcc-3.4.4/usr/* usr

# tar --numeric-owner -cf- . | docker import - busybox
# docker run -i -u root busybox /bin/echo Success.
# tar zcf ../$name.tar ./
# cat /tmp/fedora.tar | docker import - fedora
