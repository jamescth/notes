#!/usr/bin/env python
net_config = 'eth0a     Link encap:Ethernet  HWaddr 00:A0:D1:EC:EE:ED\n\
          inet addr:10.25.128.173  Bcast:10.25.143.255  Mask:255.255.240.0\n\
          inet6 addr: 2620:0:170:1106:2a0:d1ff:feec:eeed/64 Scope:Global\n\
          inet6 addr: fe80::2a0:d1ff:feec:eeed/64 Scope:Link\n\
          UP BROADCAST NOTRAILERS RUNNING MULTICAST  MTU:1500  Metric:1\n\
          RX packets:2442564 errors:0 dropped:0 overruns:0 frame:0\n\
          TX packets:11067 errors:0 dropped:0 overruns:0 carrier:0\n\
          collisions:0 txqueuelen:1000 \n\
          RX bytes:169758493 (161.8 MiB)  TX bytes:1230387 (1.1 MiB)\n\
\n\
eth0b     Link encap:Ethernet  HWaddr 00:A0:D1:EC:EE:EC\n\
          inet6 addr: 2100:bad:cafe:f00d::deed:100/64 Scope:Global\n\
          inet6 addr: 2100:bad:cafe:f00d::deed:2/64 Scope:Global\n\
          inet6 addr: fe80::2a0:d1ff:feec:eeec/64 Scope:Link\n\
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1\n\
          RX packets:37074 errors:0 dropped:0 overruns:0 frame:0\n\
          TX packets:2161 errors:0 dropped:0 overruns:0 carrier:0\n\
          collisions:0 txqueuelen:1000\n\
          RX bytes:3984081 (3.7 MiB)  TX bytes:166449 (162.5 KiB)\n\
\n\
eth0b:100 Link encap:Ethernet  HWaddr 00:A0:D1:EC:EE:EC\n\
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1\n\
\n\
eth4a     Link encap:Ethernet  HWaddr 00:15:17:7B:77:18  \n\
          inet6 addr: 2100:bad:cafe:f00d:0:dd2:e4a:1/64 Scope:Global\n\
          UP BROADCAST MULTICAST  MTU:1500  Metric:1\n\
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0\n\
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0\n\
          collisions:0 txqueuelen:1000 \n\
          RX bytes:0 (0.0 b)  TX bytes:0 (0.0 b)\n\
\n\
eth4b     Link encap:Ethernet  HWaddr 00:15:17:7B:77:19  \n\
          inet6 addr: 2100:dead:beef:cafe:0:dd2:e4b:1/64 Scope:Global\n\
          inet6 addr: fe80::215:17ff:fe7b:7719/64 Scope:Link\n\
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1\n\
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0\n\
          TX packets:217 errors:0 dropped:0 overruns:0 carrier:0\n\
          collisions:0 txqueuelen:1000 \n\
          RX bytes:0 (0.0 b)  TX bytes:15706 (15.3 KiB)\n\
\n\
lo        Link encap:Local Loopback  \n\
          inet addr:127.0.0.1  Mask:255.0.0.0\n\
          inet6 addr: ::1/128 Scope:Host\n\
          UP LOOPBACK RUNNING  MTU:16436  Metric:1\n\
          RX packets:586836 errors:0 dropped:0 overruns:0 frame:0\n\
          TX packets:586836 errors:0 dropped:0 overruns:0 carrier:0\n\
          collisions:0 txqueuelen:0 \n\
          RX bytes:521791029 (497.6 MiB)  TX bytes:521791029 (497.6 MiB)'

# net show setting
net_show_setting = '\
port        enabled   DHCP   IP address                             netmask          type   additional setting\n\
                                                                    /prefix length                            \n\
---------   -------   ----   ------------------------------------   --------------   ----   ------------------\n\
eth0a       yes       yes    10.25.128.173*                         255.255.240.0*   n/a                      \n\
                             2620:0:170:1106:2a0:d1ff:feec:eeed**   /64                                       \n\
                             fe80::2a0:d1ff:feec:eeed**             /64                                       \n\
eth0b       yes       no     2100:bad:cafe:f00d::deed:2             /64              n/a                      \n\
                             2100:bad:cafe:f00d::deed:100**         /64                                       \n\
                             fe80::2a0:d1ff:feec:eeec**             /64                                       \n\
eth0b:100   yes       no     2100:bad:cafe:f00d::deed:100           /64              n/a                      \n\
eth4a       no        n/a    n/a                                    n/a              n/a                      \n\
eth4b       no        n/a    n/a                                    n/a              n/a                      \n\
---------   -------   ----   ------------------------------------   --------------   ----   ------------------\n\
* Value from DHCP\n\
** auto_generated IPv6 address'

# reg show config.net.eth
reg_show = '\
config.net.eth0a.enabled = true\n\
config.net.eth0a.ip_address = 0\n\
config.net.eth0a.ip_cur_address = 0\n\
config.net.eth0a.mtusize = 1500\n\
config.net.eth0a.netmask = 255.255.240.0\n\
config.net.eth0a.noauto.enabled = false\n\
config.net.eth0a.use_dhcp = true\n\
config.net.eth0a.use_dhcpv6 = false\n\
config.net.eth0b.enabled = true\n\
config.net.eth0b.ip_address = 2100:bad:cafe:f00d::deed:2/64\n\
config.net.eth0b.ip_cur_address = 2100:bad:cafe:f00d::deed:2/128\n\
config.net.eth0b.mtusize = 1500\n\
config.net.eth0b.netmask = \n\
config.net.eth0b.noauto.enabled = false\n\
config.net.eth0b.use_dhcp = false\n\
config.net.eth0b.use_dhcpv6 = false\n\
config.net.eth0b:100.enabled = true\n\
config.net.eth0b:100.ip_address = 2100:bad:cafe:f00d::deed:100/64\n\
config.net.eth0b:100.ip_cur_address = 2100:bad:cafe:f00d::deed:100/128\n\
config.net.eth0b:100.mtusize = 1500\n\
config.net.eth0b:100.netmask = \n\
config.net.eth0b:100.noauto.enabled = true\n\
config.net.eth0b:100.noauto.full_duplex = true\n\
config.net.eth0b:100.noauto.speed = 0\n\
config.net.eth0b:100.use_dhcp = false\n\
config.net.eth0b:100.use_dhcpv6 = false\n\
config.net.eth4a.enabled = true\n\
config.net.eth4a.ip_address = 2100:bad:cafe:f00d:0:dd2:e4a:1/64\n\
config.net.eth4a.mtusize = 1500\n\
config.net.eth4a.netmask = \n\
config.net.eth4a.noauto.enabled = false\n\
config.net.eth4a.use_dhcp = false\n\
config.net.eth4a.use_dhcpv6 = false\n\
config.net.eth4b.enabled = true\n\
config.net.eth4b.ip_address = 2100:dead:beef:cafe:0:dd2:e4b:1/64\n\
config.net.eth4b.mtusize = 1500\n\
config.net.eth4b.netmask = \n\
config.net.eth4b.noauto.enabled = false\n\
config.net.eth4b.use_dhcp = false\n\
config.net.eth4b.use_dhcpv6 = false'

eth_config_list = []
eth_setting_list = []

# ******************* net show config *******************
def scan_config(istr, ostr):
	index = 0

	for line in istr.splitlines():
		if ('eth' in line):
			#print "%d %s" %(index, line.partition(' ')[0])
			key = line.partition(' ')[0]
			#print line
			ostr.append([key,index])
		index += len(line)

	#print eth_config_list

def print_config(istr, start, end):
	for line in istr[start:end].splitlines():
		if ('inet' in line) or ('eth' in line):
			print line

def show_net_config(port, istr, idx_str):
	index = 0
	#print len(idx_str)
	# print idx_str
	# print the lable
	if (idx_str[0][1] != 0):
		print "%s" % istr[0:idx_str[0][1]]

	# print the targeted content
	for key, offset in idx_str:
		if port in key:
			if (index+1 < len(idx_str)):
				print_config(istr, offset, idx_str[index+1][1])
			else:
				print_config(istr, offset, len(istr))
			#print key
	 		#print offset, idx_str[index+1][1]
		index += 1

	# print the foot label if any
	#if (idx_str[len(idx_str) - 1][1] != len(istr)):
		# print idx_str[len(idx_str) - 1][1]
		# print len(istr)
		# print "%s" % istr[idx_str[len(idx_str) - 1][1]:-1]

def main():
	# net show config/ifconfig
	scan_config(net_config, eth_config_list)
	# net show settings
	scan_config(net_show_setting, eth_setting_list)

	print "\nconfig eth0a"
	show_net_config('eth0a', net_config, eth_config_list)
	print "show setting eth0a"
	show_net_config('eth0a', net_show_setting, eth_setting_list)

	print "\nshow eth0b"
	show_net_config('eth0b', net_config, eth_config_list)
	print "show setting eth0b"
	show_net_config('eth0b', net_show_setting, eth_setting_list)
	print "\nshow eth0b:100"
	show_net_config('eth0b:100', net_config, eth_config_list)
	print "show setting eth0b:100"
	show_net_config('eth0b:100', net_show_setting, eth_setting_list)
	print "\nshow eth0a"
	show_net_config('eth4b', net_config, eth_config_list)
	print "show setting eth4b"
	show_net_config('eth4b', net_show_setting, eth_setting_list)

if __name__ == '__main__':
	main()
