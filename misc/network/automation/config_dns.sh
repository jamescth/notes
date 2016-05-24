#!/bin/sh
###
# Install and config dns(bind9) server
#
# Tested on Ubuntu 14.04
# run this script with 'sudo'
#
# https://help.ubuntu.com/lts/serverguide/dns.html
# dns and ddns
# http://blogging.dragon.org.uk/dns-with-bind9-and-dhcp-on-ubuntu-14-04/
###

# Installation
apt-get -y install bind9
apt-get -y install dnsutils

# Configuration
#  1. seting nds forward in /etc/bind/named.conf.options
#     forwarders {
#                <dns ip1>;
#                <dns ip2>;
#           };
#	//dnssec-validation auto;
#	dnssec-enable no;
#	auth-nxdomain no;    # conform to RFC1035
#	listen-on-v6 { any; };

#  2. seting primary master in /etc/bind/named.conf.local

include "/etc/bind/rndc.key";

zone "test.org" {
     type master;
     file "/var/lib/bind/db.test.org";
     // allow-update { key rndc-key; };
     allow-update { any; };
};

zone "1.168.192.in-addr.arpa" {
     type master;
     file "/var/lib/bind/db.192";
     // allow-update { key rndc-key; };
     allow-update { any; };
};

zone "d.0.0.f.e.f.a.c.d.a.e.d.0.0.1.2.ip6.arpa" {
     type master;
     file "/var/lib/bind/d.0.0.f.e.f.a.c.d.a.e.d.0.0.1.2.ip6.arpa";
     allow-update { key rndc-key; };
};

# $ ll -d /var/lib/bind
# drwxrwxr-x 2 root bind 4096 Jan  4 07:31 /var/lib/bind/
#   -rw-r--r--  1 bind bind  480 Jan  4 07:06 d.0.0.f.e.f.a.c.d.a.e.d.0.0.1.2.ip6.arpa
#   -rw-r--r--  1 bind bind  362 Jan  4 07:31 db.192
#   -rw-r--r--  1 bind bind  406 Jan  4 07:23 db.test.org

# Forward Zone /var/lib/bind/db.test.org
$ORIGIN .
$TTL 604800	; 1 week
test.org		IN SOA	ns.test.org. root.test.org. (
				9          ; serial
				604800     ; refresh (1 week)
				86400      ; retry (1 day)
				2419200    ; expire (4 weeks)
				604800     ; minimum (1 week)
				)
			NS	ns.test.org.
			A	127.0.0.1
			A	192.168.1.10
			AAAA	::1
$ORIGIN test.org.
$TTL 300	; 5 minutes
dr1			A	192.168.1.90
$TTL 604800	; 1 week
ns			A	192.168.1.10

# echo "" >> /etc/bind/named.conf.local
# echo 'zone "example.com" {' >> /etc/bind/named.conf.local
# echo '	type master;' >> /etc/bind/named.conf.local
# echo '	file "/etc/bind/db.example.com";' >> /etc/bind/named.conf.local
# echo '};' >> /etc/bind/named.conf.local

# echo ';' >> /etc/bind/db.example.com
# echo '; BIND data file for example.com' >> /etc/bind/db.example.com
# echo ';' >> /etc/bind/db.example.com
# echo '$TTL    604800' >> /etc/bind/db.example.com
# echo '@       IN      SOA     example.com. root.example.com. (' >> /etc/bind/db.example.com
# echo '                              2         ; Serial' >> /etc/bind/db.example.com
# echo '                         604800         ; Refresh' >> /etc/bind/db.example.com
# echo '                          86400         ; Retry' >> /etc/bind/db.example.com
# echo '                        2419200         ; Expire' >> /etc/bind/db.example.com
# echo '                         604800 )       ; Negative Cache TTL' >> /etc/bind/db.example.com
# echo '        IN      A       192.168.1.10' >> /etc/bind/db.example.com
# echo ';' >> /etc/bind/db.example.com
# echo '@       IN      NS      ns.example.com.' >> /etc/bind/db.example.com
# echo '@       IN      A       192.168.1.10' >> /etc/bind/db.example.com
# echo '@       IN      AAAA    ::1' >> /etc/bind/db.example.com
# echo 'ns      IN      A       192.168.1.10' >> /etc/bind/db.example.com

service bind9 restart

# Reverse Zone
$ORIGIN .
$TTL 604800	; 1 week
1.168.192.in-addr.arpa	IN SOA	ns.test.org. root.test.org. (
				4          ; serial
				604800     ; refresh (1 week)
				86400      ; retry (1 day)
				2419200    ; expire (4 weeks)
				604800     ; minimum (1 week)
				)
			NS	ns.
$ORIGIN 1.168.192.in-addr.arpa.
10			PTR	ns.test.org.
$TTL 300	; 5 minutes
90			PTR	dr1.test.org.

# echo "" >> /etc/bind/named.conf.local
# echo 'zone "1.168.192.in-addr.arpa" {' >> /etc/bind/named.conf.local
# echo '        type master;' >> /etc/bind/named.conf.local
# echo '        file "/etc/bind/db.192";' >> /etc/bind/named.conf.local
# echo '};' >> /etc/bind/named.conf.local

# echo ';' >> /etc/bind/db.192
# echo '; BIND reverse data file for local 192.168.1.XXX net' >> /etc/bind/db.192
# echo ';' >> /etc/bind/db.192
# echo '$TTL    604800' >> /etc/bind/db.192
# echo '@       IN      SOA     ns.example.com. root.example.com. (' >> /etc/bind/db.192
# echo '                              2         ; Serial' >> /etc/bind/db.192
# echo '                         604800         ; Refresh' >> /etc/bind/db.192
# echo '                          86400         ; Retry' >> /etc/bind/db.192
# echo '                        2419200         ; Expire' >> /etc/bind/db.192
# echo '                         604800 )       ; Negative Cache TTL' >> /etc/bind/db.192
# echo ';' >> /etc/bind/db.192
# echo '@       IN      NS      ns.' >> /etc/bind/db.192
# echo '10      IN      PTR     ns.example.com.' >> /etc/bind/db.192

service bind9 restart

# ipv6
# https://www.vaspects.com/2014/01/15/ipv6-for-the-debian-dns-server/
# echo 'zone "d.0.0.f.e.f.a.c.d.a.e.d.0.0.1.2.ip6.arpa" {' >> /etc/bind/named.conf.local
# echo '       type master;' >> /etc/bind/named.conf.local
# echo '       file "/etc/bind/d.0.0.f.e.f.a.c.d.a.e.d.0.0.1.2.ip6.arpa";' >> /etc/bind/named.conf.local
# echo '};' >> /etc/bind/named.conf.local

$TTL 604800
@       IN      SOA     test.org. root.test.org. (
                        2               ; Serial. This # needs to be incremented on each change.
                        604800          ; Refresh
                        86400           ; Retry
                        2419200         ; Expire
                        604800 )        ; Negative Cache TTL
	IN	NS	ns.test.org.
; 2100:dead:cafe:f00d::/64
@	IN	NS	ns.
1.0.1.0.f.e.e.b.0.0.0.0.0.0.0.0 IN	PTR	ns.test.org.

