#!/bin/sh
###
# Install and config isc-dhcp(dhcp4) server
#
# Tested on Ubuntu 14.04
# run this script with 'sudo'
#
# https://help.ubuntu.com/community/isc-dhcp-server
###

apt-get -y install isc-dhcp-server

# Configuration
mv /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.orig

echo 'option domain-name "test.org";' >> /etc/dhcp/dhcpd.conf
echo 'option domain-name-servers 192.168.1.10;' >> /etc/dhcp/dhcpd.conf
echo 'default-lease-time 600;' >> /etc/dhcp/dhcpd.conf
echo 'max-lease-time 7200;' >> /etc/dhcp/dhcpd.conf

echo "" >> /etc/dhcp/dhcpd.conf
echo 'option subnet-mask 255.255.255.0;' >> /etc/dhcp/dhcpd.conf
echo 'option broadcast-address 192.168.1.255;' >> /etc/dhcp/dhcpd.conf
echo 'option routers 192.168.1.254;' >> /etc/dhcp/dhcpd.conf
echo 'option ntp-servers 192.168.1.1;' >> /etc/dhcp/dhcpd.conf

echo "" >> /etc/dhcp/dhcpd.conf
echo 'subnet 192.168.1.0 netmask 255.255.255.0 {' >> /etc/dhcp/dhcpd.conf
echo 'range 192.168.1.10 192.168.1.100;' >> /etc/dhcp/dhcpd.conf
echo 'range 192.168.1.150 192.168.1.200;' >> /etc/dhcp/dhcpd.conf
echo '}' >> /etc/dhcp/dhcpd.conf

# check /etc/default/isc-dhcp-server
# INTERFACES="eth1"

# service isc-dhcp-server restart
# service isc-dhcp-server start
# service isc-dhcp-server stop
