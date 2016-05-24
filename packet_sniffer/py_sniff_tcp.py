#!/usr/bin/env python
"""
http://www.binarytides.com/python-packet-sniffer-code-linux/

1. The sniffer picks up only TCP packets, because of the declaration :

s = socket.socket(socket.AF_INET, socket.SOCK_RAW, socket.IPPROTO_TCP)
For UDP and ICMP the declaration has to be :

s = socket.socket(socket.AF_INET, socket.SOCK_RAW, socket.IPPROTO_UDP)
s = socket.socket(socket.AF_INET, socket.SOCK_RAW, socket.IPPROTO_ICMP)
You might be tempted to think of doing :

s = socket.socket(socket.AF_INET, socket.SOCK_RAW, socket.IPPROTO_IP)
but this will not work , since IPPROTO_IP is a dummy protocol not a real one.

2. This sniffer picks up only incoming packets.

3. This sniffer delivers only IP frames , which means ethernet headers are not available.

"""

import socket, sys
from struct import *

# create an INET, STREAMing socket
try:
	sk = socket.socket(socket.AF_INET, socket.SOCK_RAW, socket.IPPROTO_TCP)
except:
	print "Socket could not be create. Error code : " + str(msg[0]) + ' Message ' + msg[1]
	sys.exit(1)

# receive a packet
while True:
	# recvfrom(buf size)
	packet=sk.recvfrom(65565)

	#packet string from tuple
	packet = packet[0]

	# take 1st 20 chars from the ip header
	ip_header = packet[0:20]

	# 0                   1                   2                   3
	# 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	# |Version|  IHL  |Type of Service|          Total Length         |
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	# |         Identification        |Flags|      Fragment Offset    |
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	# |  Time to Live |    Protocol   |         Header Checksum       |
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	# |                       Source Address                          |
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	# |                    Destination Address                        |
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	# |                    Options                    |    Padding    |
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

	# struct ipheader {
	#	 unsigned char ip_hl:4, ip_v:4; /* this means that each member is 4 bits */
	#	 unsigned char ip_tos;
	#	 unsigned short int ip_len;
	#	 unsigned short int ip_id;
	#	 unsigned short int ip_off;
	#	 unsigned char ip_ttl;
	#	 unsigned char ip_p;
	#	 unsigned short int ip_sum;
	#	 unsigned int ip_src;
	#	 unsigned int ip_dst;
	#};

	# now unpack them
	# ! network (= big-endian)
	# B unsigned char
	# H unsigned short
	# s char[]

	# B[ip_hl, ip_v], B[ip_tos], H[ip_len], H[ip_id], H[ip_off], ...
	# 'I' is for int, but why use 4s instead?

	# he reason is the if 'I' is used as a format specifier then the
	# unpack() method returns the IP addresses in form of an integer
	# form (eg: 3232267778). Then you have to covert it to actual IP
	# address form (eg: 10.0.0.1). Usually in the sniffer programmes
	# that are available on internet simply use socket.inet_ntoa() 
	# for obtaining the actual ip addresses. This method accept a
	# string type and not an integer type. So that is the reason why
	# in case of unsigned int ip_src; & unsigned int ip_dst; 's' is
	# used instead of 'I' as a format specifier in struct.unpack()
	# so that the result can be later fed to socket.inet_ntoa() to
	# obtain the IP address in actual IP address format. Similarly
	# in the case for ethernet header. We use 's' instead of 'B' in
	# struct.unpack() because we need a string that can be later fed
	# to binascii.hexlify() in order to get the MAC in actual MAC address format.
	iph = unpack('!BBHHHBBH4s4s' , ip_header)

	version_ihl = iph[0]
	version = version_ihl >> 4
	ihl = version_ihl & 0XF

	iph_length = ihl * 4

	ttl = iph[5]
	protocol = iph[6]
	s_addr = socket.inet_ntoa(iph[8])
	d_addr = socket.inet_ntoa(iph[9])

	print('Version : ' + str(version) + ' IP Header Length : ' + \
		str(ihl) + ' TTL : ' + str(ttl) + ' Protocol : ' + \
		str(protocol) + ' Source Address : ' + str(s_addr) + \
		' Destination Address : ' + str(d_addr))

	tcp_header = packet[iph_length:iph_length + 20]

	# 0                   1                   2                   3
	# 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	# |          Source Port          |       Destination Port        |
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	# |                        Sequence Number                        |
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	# |                    Acknowledgment Number                      |
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	# |  Data |           |U|A|P|R|S|F|                               |
	# | Offset| Reserved  |R|C|S|S|Y|I|            Window             |
	# |       |           |G|K|H|T|N|N|                               |
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	# |           Checksum            |         Urgent Pointer        |
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	# |                    Options                    |    Padding    |
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	# |                             data                              |
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

	# now unpack them
	tcph = unpack('!HHLLBBHHH' , tcp_header)
	source_port = tcph[0]
	dest_port = tcph[1]
	sequence = tcph[2]
	acknowledgement = tcph[3]
	doff_reserved = tcph[4]
	tcph_length = doff_reserved >> 4

	print('Source Port : ' + str(source_port) + ' Dest Port : ' +
		str(dest_port) + ' Sequence Number : ' + str(sequence) + 
		' Acknowledgement : ' + str(acknowledgement) + 
		' TCP header length : ' + str(tcph_length))

	h_size = iph_length + tcph_length * 4
	data_size = len(packet) - h_size

	#get data from the packet
	data = packet[h_size:]

	print('Data : ' + data)
	print('')
