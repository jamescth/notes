#!/bin/sh
###
# Install and config wide-dhcpv6 server
#
# Tested on Ubuntu 14.04
# run this script with 'sudo'
#
# http://www.r00tsec.com/2013/04/howto-setup-ipv6-network-with-ubuntu.html
###

# Install DHCPv6 Server
apt-get -y install wide-dhcpv6-server

# create /etc/wide-dhcpv6/dhcp6s.conf
echo "# Use 'man dhcp6s' and 'man dhcp6s.conf' to get more info" >> /etc/wide-dhcpv6/dhcp6s.conf
echo "# or " >> /etc/wide-dhcpv6/dhcp6s.conf
echo "# http://manpages.ubuntu.com/manpages/intrepid/man5/dhcp6s.conf.5.html" >> /etc/wide-dhcpv6/dhcp6s.conf
echo "# http://www.unix.com/man-page/suse/5/dhcp6s.conf/" >> /etc/wide-dhcpv6/dhcp6s.conf

echo "" >> /etc/wide-dhcpv6/dhcp6s.conf
echo "option domain-name-servers 2100:dead:cafe:f00d::beef:101/64" >> /etc/wide-dhcpv6/dhcp6s.conf
echo "" >> /etc/wide-dhcpv6/dhcp6s.conf
echo "interface eth1 {" >> /etc/wide-dhcpv6/dhcp6s.conf
echo "	address-pool pool1 3600;" >> /etc/wide-dhcpv6/dhcp6s.conf
echo "};" >> /etc/wide-dhcpv6/dhcp6s.conf

echo "" >> /etc/wide-dhcpv6/dhcp6s.conf
echo "pool pool1 {" >> /etc/wide-dhcpv6/dhcp6s.conf
echo "	range 2100:dead:cafe:f00d::beef:1000 to 2100:dead:cafe:f00d::beef:2000 ;" >> /etc/wide-dhcpv6/dhcp6s.conf
echo "};" >> /etc/wide-dhcpv6/dhcp6s.conf

# Set up /etc/sysctl.conf
echo "" >> /etc/sysctl.conf
echo "net.ipv6.conf.all.autoconf=1" >> /etc/sysctl.conf
echo "net.ipv6.conf.all.accept_ra=1" >> /etc/sysctl.conf

# run sysctl
sysctl -w net.ipv6.conf.all.autoconf=1
sysctl -w net.ipv6.conf.all.accept_ra=1

# Set up eth1 
echo "" >> /etc/network/interfaces
#echo "auto eth1" >> /etc/network/interfaces
#echo "iface eth1 inet6 auto" >> /etc/network/interfaces
echo 'iface eth1 inet6 static' >> /etc/network/interfaces
echo '        address 2100:dead:cafe:f00d::beef:101' >> /etc/network/interfaces
echo '        netmask 64' >> /etc/network/interfaces

# bring up eth1 w/ static IP, which is the DNS IP as well
ifconfig eth1 add 2100:dead:cafe:f00d::beef:101/64

# config eth1 to use dhcp
#dhclient -6 eth1
