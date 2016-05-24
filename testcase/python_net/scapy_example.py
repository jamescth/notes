#!/ust/bin/env python
"""
SCAPY examples
"""
from scapy.all import *

def pcap_test():
	pkts = rdpcap("test.pcap")
	pkts[0][IP].src = '1.8.3.5'
	del(pkts[0][TCP].chksum)
	del(pkts[0][IP].chksum)
	pkts[0].show2()
	wrpcap("result.pcap", pkts[0])
