#!/bin/sh
###
#
###
# apt-get -y update
apt-get -y install vim-gnome

# desktop env.
# choices: Unity (default), Xfce, KDE, LXDE
#    xubuntu-desktop
#    kubuntu-desktop
#    lubuntu-desktop
# apt-get -y install ubuntu-desktop
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

service ypbind start
service autofs start

