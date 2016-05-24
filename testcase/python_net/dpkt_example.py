#!/usr/bin/env python
"""
DPKT examples
"""
import dpkt
from dpkt.ans1 import decode
from dpkt.ip import IP
from dpkt.icmp import ICMP
from ipaddr import *

def pcap_test():
	with open("test.pcap") as f:
		pcap = dpkt.pcap.Reader(f)
		for ts, buf in pcap:
			eth = dpkt.ethernet.Ethernet(buf)
			ip = eth.data
			if type(eth.data) == dpkt.ip.IP:
				src = IPAddress(Bytes(ip.src))
				dst = IPAddress(Bytes(ip.dst))
				print str(src) + "->" + str(dst)
				tcp = ip.data
				port = tcp.dport
				print "%s, %d" % (port, len(tcp.data))
				if tcp.dport == 80 and len(tcp.data) > 0:
					http=dpkt.http.Request(tcp.data)
