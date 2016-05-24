#!/bin/sh
###
#
###
apt-get -y install vim-gnome

# desktop env.
# choices: Unity (default), Xfce, KDE, LXDE
#    xubuntu-desktop
#    kubuntu-desktop
#    lubuntu-desktop
apt-get -y install ubuntu-desktop
#apt-get -y install unity-tweak-tool gnome-tweak-tool


####################################
### YP/NIS/AUTOFS 
####################################
# get modules
apt-get -y install portmap nis
apt-get -y install autofs

# We need to stop the service before modify the config files to prevent hung
service ypbind stop
service autofs stop

# additional login for NIC in boot
echo "greeter-show-manual-login=true" >> /usr/share/lightdm/lightdm.conf.d/50-ubuntu.conf
echo "greeter-session=unity-greeter" >> /usr/share/lightdm/lightdm.conf.d/50-ubuntu.conf

# set up dhclient
echo "prepend domain-search \"datadomain.com\";" >> /etc/dhcp/dhclient.conf

# set up resolve.conf
echo "search datadomain.com." >> /etc/resolvconf/resolv.conf.d/head

# set up yp.conf
echo "ypserver nislab3.datadomain.com" >> /etc/yp.conf
echo "ypserver nislab4.datadomain.com" >> /etc/yp.conf

# set up nsswitch.conf
echo "automount:      files nis" >> /etc/nsswitch.conf

# set up hosts.allow
echo "portmap: 137.69.71.140" >> /etc/hosts.allow

# set up passwd
echo "+::::::" >> /etc/passwd

# set up group
echo "+:::" >> /etc/group

# set up shadow
echo "+::::::::" >> /etc/shadow

# need this one for p4_synced_at
mkdir /usr/tmp

####################################
### DD
####################################
# required packages for DD
apt-get -y install libtool libtool-doc
apt-get -y install autotools-dev
apt-get -y install autoconf
apt-get -y install automake
apt-get -y install ssh
apt-get -y install build-essential
apt-get -y install libxml2-utils
apt-get -y install perl perl-base perl-debug perl-doc perl-modules perlmagick perltidy
apt-get -y install libxml-perl libxml-dom-perl libxml-xql-perl libxml-checker-perl
ln -s /usr/bin/basename /bin/basename
apt-get -y install gawk gawk-doc
ln -s /usr/bin/awk /bin/awk

# set up old ver of lib ld
# PUT /auto/home12/hoj9/ubuntu_img_conf/mig/ld-2.3.6.so.tar.gz /tmp/ld-2.3.6.so.tar.gz 0644
# sudo tar -xvf /tmp/ld-2.3.6.so.tar.gz -C /lib
# sudo ln -s /lib/ld-2.3.6.so /lib64/ld-linux.so.2

# install 32 bit lib.  
# ia32-libx has been replaced by lib32z1 lib32ncurses5 lib32bz2-1.0
# symptom:
#     $ console
#        -bash: /auto/tools/bin/console: No such file or directory
#     $ readelf -a /auto/tools/bin/console | grep Requesting
#        [Requesting program interpreter: /lib/ld-linux.so.2]
apt-get -y install lib32z1
apt-get -y install lib32ncurses5
apt-get -y install lib32bz2-1.0

apt-get -y install nfs-common
apt-get -y install nfs-kernel-server
ln -s /bin/pidof /sbin/pidof
apt-get -y install expect

apt-get -y install tkpng libpng12-0 libpng12-dev
apt-get -y install libmysqlclient-dev

#################
### Need to install perl modules manually
#################
# ECHO ================================================================================
# ECHO Please run the following cmds on the box to install the rest of the Perl modules:
# ECHO ================================================================================
# ECHO sudo -i
# ECHO perl -MCPAN -eshell
# ECHO install YAML
# ECHO install Tk::Event
# ECHO install DBI
# ECHO install DBD::mysql
# ECHO install Bundle::LWP
# ECHO exit
# ECHO exit

####################################
### Custom tools
####################################
apt-get -y install fabric
apt-get -y install ipython
apt-get -y install python-pip
apt-get -y install kdiff3
apt-get -y install wireshark
# apt-get -y install crash

