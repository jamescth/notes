#!/usr/bin/env python
"""
http://bt3gl.github.io/building-a-udp-scanner-with-pythons-socket-module.html
"""

import socket, os
import ctypes

# host to listen
HOST = '137.69.76.181'

def sniffing(host, win, socket_prot):
	while 1:
		sniffer = socket.socket(socket.AF_INET, socket.SOCK_RAW, socket_prot)
		sniffer.bind((host, 0))

		# include the IP headers in the captured packets
		sniffer.setsockopt(socket.IPPROTO_IP, socket.IP_HDRINCL, 1)

		if win == 1:
			sniffer.ioctl(socket.SIO_RCVALL, socket_RCVALL_ON)

		# read the single packet
		print sniffer.recvfrom(65565)

def main(host):
	if os.name == 'nt':
		sniffing(host, 1, socket.IPPROTO_IP)
	else:
		sniffing(host, 0, socket.IPPROTO_ICMP)

if __name__ == '__main__':
	main(HOST)
