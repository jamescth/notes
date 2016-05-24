#!/usr/bin/env python
"""
This one requires dpkt module from Google.
"""
import dpkt

counter=0
ipcounter=0
tcpcounter=0
udpcounter=0

filename='netcap-before.cap'
mycap = open(filename, 'r')

for ts, pkt in dpkt.pcap.Reader(mycap):
	counter+=1
	eth=dpkt.ethernet.Ethernet(pkt)
	if eth.type != dpkt.ethernet.ETH_TYPE_IP:
		continue

	ip=eth.data
	ipcounter+=1

	if ip.p == dpkt.ip.IP_PROTO_TCP:
		tcpcounter+=1
	if ip.p == dpkt.ip.IP_PROTO_UDP:
		udpcounter+=1

mycap.close()

print "Total number of packets in the pcap file: ", counter
print "Total number of ip packets: ", ipcounter
print "Total number of tcp packets: ", tcpcounter
print "Total number of udp packets: ", udpcounter
