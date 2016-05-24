#!/usr/bin/env python
"""
This is similar to py_sniff_eth.py, but uses ctypes struct instead of unpakc().
The packet headers are defined in packet_header.py

Sniffs all incoming & outgoing packets

/usr/include/sys/socket.h	socket
/usr/include/linux/if_ether.h	ethernet header
/usr/include/netinet/ip.h	IP header
/usr/include/netinet/tcp.h	TCP header
/usr/include/netinet/udp.h	UDP header
/usr/include/netinet/ip_icmp.h	ICMP header

https://docs.python.org/2/library/socket.html

# the public network interface
HOST = socket.gethostbyname(socket.gethostname())
# create a raw socket and bind it to the public interface
s = socket.socket(socket.AF_INET, socket.SOCK_RAW, socket.IPPROTO_IP)
s.bind((HOST, 0))
# Include IP headers
s.setsockopt(socket.IPPROTO_IP, socket.IP_HDRINCL, 1)
# receive all packages
s.ioctl(socket.SIO_RCVALL, socket.RCVALL_ON)
# receive a package
print s.recvfrom(65565)
# disabled promiscuous mode
s.ioctl(socket.SIO_RCVALL, socket.RCVALL_OFF)
"""

import socket, sys
from struct import *
# c style struct
import packet_header

#Convert a string of 6 characters of ethernet address into a dash separated hex string
def eth_addr (a) :
	print(a)
	b = ("%.2x:%.2x:%.2x:%.2x:%.2x:%.2x" % 
		(ord(a[0]) , ord(a[1]) , ord(a[2]), ord(a[3]), ord(a[4]) , ord(a[5])))
	return b

def py_eth_addr (a) :
	b = ("%.2x:%.2x:%.2x:%.2x:%.2x:%.2x" % 
		(a[0], a[1], a[2], a[3], a[4], a[5]))
	return b

# create a AF_PACKET type raw socket (thats basically packet level)
# define ETH_P_ALL    0x0003          /* Every packet (be careful!!!) */

try:
	"""
	AF_INET for IPv4, AF_INET6 for IPv6.
	AF_PACKET for Packet sockets, which operate at the device driver layer (L2)
	pcap lib for Linux uses AF_PACKET for sniffing as well. 

	SOCK_STREAM for TCP, SCTP, BLUETOOTH
	SOCK_DGRAM for UDP
	SOCK_RAW for RAW sockets

	AF_UNIX can use either SOCK_STREAM or SOCK_DGRAM

	sock always refers to struct socket
	sk always refers to struct sock
	"""
	sock = socket.socket( socket.AF_PACKET , socket.SOCK_RAW , socket.ntohs(0x0003))

	# for TCP only
	# sock = socket.socket(socket.AF_INET, socket.SOCK_RAW, socket.IPPROTO_TCP)

	# for bluetooth/RFCOMM:
	# sock = socket.socket(socket.AF_BLUETOOTH, SOCK_STREAM, BTPROTO_RFCOMM)

except socket.error , msg:
	print('Socket could not be created. Error Code : ' + str(msg[0]) + ' Message ' + msg[1])
	sys.exit()

# receive a packet
while True:
	# recvfrom(buf size)
	packet = sock.recvfrom(65565)

	# packet string from tuple
	packet = packet[0]

	# parse ethernet header
	eth_length = 14

	eth_buf = packet[:eth_length]
	ethb = packet_header.PY_ETH(eth_buf)
	print('Dest MAC: %s Src MAC: %s Proto: %d' %
		(py_eth_addr(ethb.eth_dest[:]), py_eth_addr(ethb.eth_src[:]), ethb.eth_proto))
	
	# Parse IP packets, IP Protocol number = 8
	if ethb.eth_proto == 8:
		# Parse IP header
		# take 1st 20 chars fro the IP header

		buf = packet[eth_length:(20+eth_length)]
		iph = packet_header.PY_IP(buf)

		ver = iph.ip_hl >> 4
		ihl = iph.ip_hl & 0xF
		iph_length = ihl * 4

		print('Ver:%d h-len:%d TTL:%d Protocol:%d' % 
			(ver, iph.ip_len, iph.ip_ttl, iph.ip_proto))
		print('Src Addr:%s Dest Addr:%s' % 
			(socket.inet_ntoa(iph.ip_src),socket.inet_ntoa(iph.ip_dst)))
		# """
		# TCP
		if iph.ip_proto == 6:
			t_start = iph_length + eth_length
			tcp_header = packet[t_start:t_start+20]

			tcp = packet_header.PY_TCP(tcp_header)

			# doff_reserved = tcph[4]
			doff_reserved = tcp.tcp_off
			tcph_length = doff_reserved >> 4

			print('S Port: %d Dest Port: %d Seq %d Ack: %d Header Len: %d' %
				(tcp.tcp_sport, tcp.tcp_dport, tcp.tcp_seq, tcp.tcp_ack,
				 tcph_length))

			h_size = eth_length + iph_length + (tcph_length * 4)
			data_size = len(packet) - h_size

			# get data from the packet
			data = packet[h_size:]
			# print('Data : ' + data)

		# ICMP

		elif iph.ip_proto == 1:
			i_start = iph_length + eth_length
			icmph_length = 4

			# c style struct
			buf = packet[i_start:i_start+4]
			icmph = packet_header.PY_ICMP(buf)
			print('ICMP -> Type:%d, Code:%d Checksum: %d' %
				(icmph.type, icmph.code, icmph.checksum))

			h_size = eth_length + iph_length + icmph_length
			data_size = len(packet) - h_size

			# get data
			data = packet[h_size:]
			# print('Data : ' + data)

		# UDP
		elif iph.ip_proto == 17:
			u_start = iph_length + eth_length
			udph_length = 8
			udp_header = packet[u_start:u_start+8]

			udph = packet_header.PY_UDP(udp_header)

			print('Src Port: %d Dest Port: %d Len: %d Sum: %d' %
				(udph.udp_sport, udph.udp_dport, udph.udp_ulen,
				 udph.udp_sum))

			h_size = eth_length + iph_length + udph_length
			data_size = len(packet) - h_size

			# get data
			data = packet[h_size:]
			# print('Data : ' + data)

		# some other IP packet like IGMP
		else:
			print('Protocol %d' % iph.ip_proto)

		print('')
	# end of IP parsing
# end of While True


             
