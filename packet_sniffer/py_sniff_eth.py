#!/usr/bin/env python
"""
http://www.binarytides.com/python-packet-sniffer-code-linux/

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

import socket, sys, getopt
from struct import *
import logging

# set a format which is simpler for console use
formatter = logging.Formatter('%(funcName)-12s: %(levelname)-5s %(lineno)4d %(message)s')
error_handler = logging.FileHandler("/tmp/py_sniff.err", "w")
error_handler.setFormatter(formatter)

py_logger = logging.getLogger('py_log')
py_logger.addHandler(error_handler)
py_logger.setLevel(logging.DEBUG)

def usage():
	print('   py_log.py -d <input directory> --ofile=<output file>')
	print('   py_log.py --dir=. --date=201411070930 --ofile=/tmp/tt')
	print('   the <input directory> should be the top dir of the support bundle')

def parsing(argv):
	"""
	parse the input arguments
	"""
	py_logger.info('Number of arguments: %d', len(argv))
	py_logger.info('argument list: %s', str(argv))

	input_file = None
	output_file = None

	#if (len(argv) < 2):
	#	usage()
	#	sys.exit(1)

	try:
		opts, args = getopt.getopt(argv,"hi:o:",
					["ifile=","ofile="])

	except getopt.GetoptError:
		usage()
		sys.exit(1)

	for opt, arg in opts:
		py_logger.info('opt %s arg %s', opt, arg)
		if opt == '-h':
			usage()
			sys.exit(0)
		elif opt in ("-i", "--dir"):
			input_file = arg
		elif opt in ("-o", "--ofile"):
			output_file = arg

	return (input_file, output_file)

#Convert a string of 6 characters of ethernet address into a dash separated hex string
def eth_addr (a) :
	b = ("%.2x:%.2x:%.2x:%.2x:%.2x:%.2x" % 
		(ord(a[0]) , ord(a[1]) , ord(a[2]), ord(a[3]), ord(a[4]) , ord(a[5])))
	return b

# create a AF_PACKET type raw socket (thats basically packet level)
# define ETH_P_ALL    0x0003          /* Every packet (be careful!!!) */

def main():

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

		# define ETH_ALEN	6		/* Octets in one ethernet addr	 */
		# struct ethhdr {
		#	unsigned char	h_dest[ETH_ALEN];	/* destination eth addr	*/
		#	unsigned char	h_source[ETH_ALEN];	/* source ether addr	*/
		#	__be16		h_proto;		/* packet type ID field	*/
		# } __attribute__((packed));

		# parse ethernet header
		eth_length = 14

		eth_header = packet[:eth_length]
		eth = unpack('!6s6sH', eth_header)
		eth_protocol = socket.ntohs(eth[2])
		print('Destination MAC : ' + eth_addr(packet[0:6]) + 
		' Source Mac : ' + eth_addr(packet[6:12]) +
		' Protocol : ' + str(eth_protocol))

		# Parse IP packets, IP Protocol number = 8
		if eth_protocol == 8:
			# Parse IP header
			# take 1st 20 chars fro the IP header
			ip_header = packet[eth_length:(20+eth_length)]
	
			# now unpack them
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
			iph = unpack('!BBHHHBBH4s4s', ip_header)

			version_ihl = iph[0]
			version = version_ihl >> 4
			ihl = version_ihl & 0xF

			iph_length = ihl * 4

			ttl = iph[5]
			protocol = iph[6]
			s_addr = socket.inet_ntoa(iph[8])
			d_addr = socket.inet_ntoa(iph[9])

			print('Version : ' + str(version) + ' IP Header Length : ' + str(ihl) +
				' TTL : ' + str(ttl) + ' Protocol : ' + str(protocol) + 
				' Source Address : ' + str(s_addr) +
				' Destination Address : ' + str(d_addr))

			# TCP
			if protocol == 6:
				t_start = iph_length + eth_length
				tcp_header = packet[t_start:t_start+20]

				# unpack TCP
				# struct tcphdr
				#   {
				#     __extension__ union
				#     {
				#       struct
				#       {
				# 	u_int16_t th_sport;		/* source port */
				# 	u_int16_t th_dport;		/* destination port */
				# 	tcp_seq th_seq;			/* sequence number 32bit */
				# 	tcp_seq th_ack;			/* acknowledgement number 32bit*/
				# # if __BYTE_ORDER == __LITTLE_ENDIAN
				# 	u_int8_t th_x2:4;		/* (unused) */
				# 	u_int8_t th_off:4;		/* data offset */
				# # endif
				# # if __BYTE_ORDER == __BIG_ENDIAN
				# 	u_int8_t th_off:4;		/* data offset */
				# 	u_int8_t th_x2:4;		/* (unused) */
				# # endif
				# 	u_int8_t th_flags;
				# # define TH_FIN	0x01
				# # define TH_SYN	0x02
				# # define TH_RST	0x04
				# # define TH_PUSH	0x08
				# # define TH_ACK	0x10
				# # define TH_URG	0x20
				# 	u_int16_t th_win;		/* window */
				# 	u_int16_t th_sum;		/* checksum */
				# 	u_int16_t th_urp;		/* urgent pointer */
				#       };

				tcph = unpack('!HHLLBBHHH', tcp_header)
				source_port = tcph[0]
				dest_port = tcph[1]
				sequence = tcph[2]
				acknowledgement = tcph[3]
				doff_reserved = tcph[4]
				tcph_length = doff_reserved >> 4
				flag = tcph[5]
				win = tcph[6]
				checksum = tcph[7]
				urp = tcph[8]

				print ('Source Port : ' + str(source_port) +
					' Dest Port : ' + str(dest_port) +
					' Sequence Number : ' + str(sequence) +
					' Acknowledgement : ' + str(acknowledgement) +
					' TCP header length : ' + str(tcph_length))

				h_size = eth_length + iph_length + (tcph_length * 4)
				data_size = len(packet) - h_size

				# get data from the packet
				data = packet[h_size:]
				# print('Data : ' + data)

			# ICMP

			elif protocol == 1:
				i_start = iph_length + eth_length
				icmph_length = 4
				icmp_header = packet[i_start:i_start+4]

				# unpack ICMP
				# struct icmp
				# {
				#   u_int8_t  icmp_type;	/* type of message, see below */
				#   u_int8_t  icmp_code;	/* type sub code */
				#   u_int16_t icmp_cksum;	/* ones complement checksum of struct */
				#   union
				#   {
				#     u_char ih_pptr;		/* ICMP_PARAMPROB */
				#     struct in_addr ih_gwaddr;	/* gateway address */
				#     struct ih_idseq		/* echo datagram */
				#     {

				icmph = unpack('!BBH', icmp_header)
	
				icmp_type = icmph[0]
				code = icmph[1]
				checksum = icmph[2]

				print('Type : ' + str(icmp_type) + ' Code : ' + str(code) +
					' Checksum : ' + str(checksum))

				h_size = eth_length + iph_length + icmph_length
				data_size = len(packet) - h_size

				# get data
				data = packet[h_size:]
				# print('Data : ' + data)

			# UDP
			elif protocol == 17:
				u_start = iph_length + eth_length
				udph_length = 8
				udp_header = packet[u_start:u_start+8]

				# unpack
				# struct udphdr
				# {
				#   __extension__ union
				#   {
				#     struct
				#     {
				#       u_int16_t uh_sport;		/* source port */
				#       u_int16_t uh_dport;		/* destination port */
				#       u_int16_t uh_ulen;		/* udp length */
				#       u_int16_t uh_sum;		/* udp checksum */
				#     };
				udph = unpack('!HHHH', udp_header)

				source_port = udph[0]
				dest_port = udph[1]
				length = udph[2]
				checksum = udph[3]

				print('Source Port : ' + str(source_port) +
					' Dest Port : ' + str(dest_port) +
					' Length : ' + str(length) +
					' Checksum : ' + str(checksum))

				h_size = eth_length + iph_length + udph_length
				data_size = len(packet) - h_size

				# get data
				data = packet[h_size:]
				# print('Data : ' + data)
	
			# some other IP packet like IGMP
			else:
				print('Protocol %d' % protocol)

			print('')
		# end of IP parsing
	# end of While True

if __name__ == '__main__':
	main()

