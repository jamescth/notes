#!/usr/bin/env python
"""

testcase:
1. super big pcap | -i any for veth:
   bug 133967 /auto/cores/c69183018/03122015/ddr/var/log/debug/cifs

2. bug 134785 => ZeroWindow
   /auto/cores/c69179222/tcpdumps/T01.pcapng
	  tcp.analysis.zero_window
	  tcp.analysis.window_update

3. bug 135685 => cooked linux
   /auto/cores/c69935854

4. bug 135637 => /auto/cores/c69044564 => standard test, include most of protocols

todo:
	1. date for the connection
	2. RTT
	3. Re-transmission such as double ack
	4. Known Protocol

pcapng => pcap
sudo find . -type f -name '*.pcapng' -print0 | while IFS= read -r -d '' f; do editcap -F libpcap "$f" "${f%.pcapng}.pcap"; done

take a look of 'tcptrace -l <pcap>' output
    # tcptrace -l T01.pcap | grep "zero"

use case:
http://www.linuxhomenetworking.com/wiki/index.php/Quick_HOWTO_:_Ch04_:_Simple_Network_Troubleshooting#.VQhutBDF938

http://www.linuxfoundation.org/collaborate/workgroups/networking/tcp_testing

requires python-pyx

Linux Performance Tools
http://www.brendangregg.com/Slides/LinuxConEU2014_LinuxPerfTools.pdf

Basic
	uptime: load averages.  1,5,15 minutes.
	top:	system & per-process interval
	htop:
	ps -ef f:
	ps -eo user,sz,rss,minflt,majflt,pcpu,args
	vmstat -Sm 1
*	iostat -xmdz 1
	mpstat -P ALL 1
	free -m

	Intermediate
	strace -tttT -P <pid>	-ttt/time since epoch, -T: syscall time
*	tcpdump -i <nic> -w /tmp/out.tcpdump
	tcpdump -nr /tmp/out.tcpdump | head
*	netstat -s
		-i: interface stats
		-r: route table
		-p: show process details
		-c: per-second interval
	nicstat 1:
*	pidstat -t 1		by-thread
	pidstat -d 1		disk i/o

	swapon -s
	lsof -iTCP -sTCP:ESTABLISHED
		echo /proc/PID/fd | wc -l

	sar -n TCP,ETCP,DEV 1
		sar -n [SOCK | SOCK6 | TCP | ETCP | UDP | IP | EIP | ICMP | EICMP | DEV | EDEV]

	# socket statistics:
	ss -mop
	ss -i

	iptraf
	iotop
	slabtop

	# show page cache residency by file:
	pcstat data0*
		
	tiptop

	rdmsr

	# benchmarking tools
	Multi:
		UnixBench, lmbench, sysbench, perf bench
	FS/disk
		dd, hdparm, fio
	App/lib
		ab, wrk, jmeter, openssl
	Networking
		ping, hping3, iperf, ttcp, traceroute, mtr, pchar

	# Tuning Tools
	Generic interfaces:
		sysctl, /sys
	CPU/Scheduler:
		nice, renice, taskset, ulimit, chcpu
	Storage I/O:
		tune2fs, ionice, hdparm, blockdev
	Network:
		ethtool, tc, ip, route
	Dynamic patching:
		stap, kpatch

	static tools
		system libraries: 	ldd
		file sys:		df
		volume:			mdadm
		IP:			ip, route
		CPU:			cpuid, lscpu
		mem:			numactl
		PCI:			lspci
		I/O controller:		MegaCli
		Disk:			lsblk, lsscsi, blockdev
		Swap:			swapon
		Nic port:		ethtool, ip, ifconfig

	# Tracing
	iosnoop -ts
	iolatency
	opensnoop
	funcgraph -Htp <pid> vfs_read
	kprobe
	ftrace

	# perf_events
	perf record -e skb:consume_skb -ag
"""
import sys, getopt, os
import logging, logging.config

from scapy.all import *
import pyx

PY_PACKET_TYPE = {
	1:"TCP",
	2:"UDP",
	3:"MISC"
}

def enum(**named_values):
	return type('Enum', (), named_values)

tcp_flags = enum (
	FIN = 0x01,
	SYN = 0x02,
	RST = 0x04,
	PSH = 0x08,
	ACK = 0x10,
	URG = 0x20,
	ECE = 0x40,
	CWR = 0x80
)

# global variables
ofile_handle = None

def py_print(*args, **kwargs):
	"""
	This func writes the output to the global variable 'ofile_handle'.
	If the global is not set, it will print to the screen instead.

	WARNING:
	if ofile_handle is closed, it will not be None and it cant be writable. 
	So, make sure delete it after closing.
	"""
	if ofile_handle is not None:
		ofile_handle.write(args[0] + '\n')
	else:
		print(args[0])

def usage():
	print('   py_scapy.py --ifile=<input file>')
	print('   py_scapy.py --ifile=<input file> --ofile=<output file>')

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
		elif opt in ("-i", "--ifile"):
			input_file = arg
		elif opt in ("-o", "--ofile"):
			output_file = arg

	return (input_file, output_file)

def Qos_ping(host, count=3):
	"""
	http://stackoverflow.com/questions/13163516/scapy-how-get-ping-time

	http://www.secdev.org/conf/scapy_csw05.pdf
	Ether(dst="ff:ff:ff:ff:ff:ff")
	/IP(dst=["ketchup.com","mayo.com"],ttl=(1,9))
	/UDP(dport=123)
	"""
	packet = Ether()/IP(dst=host)/ICMP()
	t = 0.0

	for x in range(count):
		# send & receive packets at layer 2
		# ans is a SndRcvList
		# unans is a PacketList
		ans, unans=srp(packet, iface='eth0', filter='icmp', verbose=0)

		# rx and tx are Ether
		rx = ans[0][1]
		tx = ans[0][0]
		delta = rx.time - tx.sent_time
		print "Ping:", delta
		t += delta

	return (t/count)*1000

def arp_display(pkt):
	"""
	use the last line as the caller to call this routine

	output:
	Request: 137.69.76.211 is asking about 137.69.76.222
	Request: 10.194.61.69 is asking about 10.194.61.1
	Request: 10.194.61.109 is asking about 10.194.61.1
	Request: 10.194.61.18 is asking about 10.194.61.1
	"""
	if pkt[ARP].op == 1: # who-has (request)
		return "Request: " + pkt[ARP].psrc + " is asking about " + pkt[ARP].pdst
	if pkt[ARP].op == 2: # is_at (response)
		return "Response: " + pkt[ARP].hwsrc + " has address " + pkt[ARP].psrc

	# sniff can read it from a pcap file as well
	# In [44]: pkts = sniff(offline='test.cap')
	# Out[44]: <Sniffed: TCP:97 UDP:21 ICMP:11 Other:71>
	# [pkt.summary() for pkt in pkts]

	# print (sniff(prn=arp_display, filter="arp", store=0, count=10))
class L5Conn(object):
	"""
	This represents a layer 5 connection in between 2 sessions.

	private:
		sport:	the source port
		dport:	The destination port
		pkts:		The frame numbers for all the packets in the connection
	"""
	def __init__(self, sport=None, dport=None):
		"""
		
		"""
		self.sport = sport
		self.dport = dport
		self.pkt_idx = []
		self.syn = []
		self.fin = []
		self.rst = []
		self.ack = []
		self.zero_win = []

	def is_port_match(self, port1, port2):
		""" Verify if the given ports matched """
		if port1 == port2:
			py_logger.warning("port1 %s port2 %s are the same", port1, port2)

		if (port1 == self.sport or port1 == self.dport) and \
		   (port2 == self.sport or port2 == self.dport):
			return True

		return False

	def ins_pkt(self, pkt):
		""" add the frame # into the embedded list """
		self.pkt_idx.append(pkt)

	def num_pkt(self):
		return len(self.pkt_idx)

	def get_pkts(self):
		return self.pkt_idx

	def print_pkt(self, pkts, pkts_idx):
		for idx, val in enumerate(pkts_idx):
			pkt = pkts[val]
			if len(pkt[TCP].options) != 0:
				py_print("      %s options %s" % (val, pkt[TCP].options))

	def show_content(self, pkts):
		py_print(" %s <-> %s" %(self.sport, self.dport))
		py_print("  pkt_idx %s" % self.pkt_idx)

		if len(self.syn) != 0:
			py_print("    syn packets %s" % self.syn)
			self.print_pkt(pkts, self.syn)
		if len(self.fin) != 0:
			py_print("    fin packets %s" % self.fin)

			# no need to print opts
			# 995 options [('NOP', None), ('NOP', None), ('Timestamp', (648522615, 3112164942))]
			# self.print_pkt(pkts, self.fin)
		if len(self.rst) != 0:
			py_print("    rst packets %s" % self.rst)
			# self.print_pkt(pkts, self.rst)

		if len(self.zero_win) != 0:
			py_print("    **** zero window packets %s" % self.zero_win)


	def process_pkts(self, pkts):

		for idx, val in enumerate(self.pkt_idx):
			"""
			we use idx and val together here.

			idx is the position of self.pkt_idx
			val is the value of the position in self.pkt_idx
			"""
			pkt = pkts[val]


			# list all the zero window packet
			if pkt[TCP].window == 0:
				self.zero_win.append(val)

			# check for TCP flags
			# SYN and SYN only
			if pkt[TCP].flags == tcp_flags.SYN:
				self.syn.append(val)
				if pkts[self.pkt_idx[idx+1]][TCP].flags != (tcp_flags.SYN | tcp_flags.ACK):
					py_print("SYN ACK doesn't follow SYN %d", val)
				if pkts[self.pkt_idx[idx+2]][TCP].flags != (tcp_flags.ACK):
					py_print("ACK doesn't follow SYN ACK %d", val)

			# if RST
			if pkt[TCP].flags & tcp_flags.RST:
				self.rst.append(val)
			# if FIN
			if pkt[TCP].flags & tcp_flags.FIN:
				self.fin.append(val)

			# how about RTT...

class L4Conn(object):
	"""
	This represents a layer 4 connection in between 2 addresses.

	private:
		pkt_type:	The type of the connection such as IP or IPv6...
		src:			source address
		dst:			destination address
		l5conn:	the list of layer 5 connections
	"""
	def __init__(self, pkt_type = None, src=None, dst=None):
		self.pkt_type = pkt_type
		self.src = src
		self.dst = dst
		self.l5conn = []

	def is_ip_match(self, pkt_type, ip1, ip2):
		"""
		Given the type and 2 addresses, return if the layer 4 connection already exists
		"""
		if pkt_type != self.pkt_type:
			return False

		if ip1 == ip2:
			py_logger.warning("ip1 %s ip2 %s are the same", ip1, ip2)

		if (ip1 == self.src or ip1 == self.dst) and \
		   (ip2 == self.src or ip2 == self.dst):
			return True
		return False

	def ins_L5Conn(self, l5conn):
		self.l5conn.append(l5conn)

	def num_conn(self):
		return len(self.l5conn)

	def get_L5Conn(self):
		return self.l5conn

	def show_content(self, pkts):
		# print("%s src %s dst %s" % (self.pkt_type, self.src, self.dst))
		py_print("%s src %s dst %s" % (self.pkt_type, self.src, self.dst))
		for l5conn in self.l5conn:
			l5conn.show_content(pkts)

	def L4_process_conn(self, pkts):
		for l5conn in self.l5conn:
			l5conn.process_pkts(pkts)

class DDPackets(object):
	"""
	Class for packets

		pkt is an Ether
		pkt.name
		'Ethernet'

		pkt.mysummary()
		'68:5b:35:a7:be:4d > 01:00:5e:00:00:fb (IPv4)'
		pkt.route()
		pkt.show()
		pkt.summary()
		pkt.pdfdump()
		pkt.time
	"""
	def __init__(self, pkts=None):
		self.__pkts = pkts
		self.__is_processed_pkts = False
		self.pkt_num = 0
		self.connections = []

	def ddp_set_pkts(self, pkts):
		if pkts is None:
			py_logger.error("ddp_set_pkts() does not accept None object")
			print("ddp_set_pkts() does not accept None object")
			return -1

		self.__pkts = pkts
		return 0

	def ddp_show_pkt(self):
		if self.__pkts is None:
			print("The object does not contain any packets")
			return

		for pkt in self.__pkts:
			pkt.show()

	def ddp_show_pkts(self):
		if self.__pkts is None:
			print("The object does not contain any packets")
			return

		self.__pkts.show()

	def ddp_show_connections(self):
		for conn in self.connections:
			conn.show_content(self.__pkts)
			py_print("")

	def ddp_process_conns(self):
		if not self.__is_processed_pkts:
			py_logger.error("packets have not been processed yet")
			print("packets have not been processed yet")
			sys.exit(1)

		for l4conn in self.connections:
			l4conn.L4_process_conn(self.__pkts)

	def ddp_read_pkts(self):
		if self.__pkts is None:
			print("The object does not contain any packets")
			return

		offset = 0
		self.__is_processed_pkts = True
		py_logger.debug('pkts %s', self.__pkts)

		for pkt in self.__pkts:

			###
			### cooked linux
			###
			if pkt.name == 'cooked linux':
				#/auto/cores/c69935854
				# CookedLinux uses pkttype 
				# CookedLinux only has src mac.
				pass

			###
			### Ethernet
			###
			elif pkt.name == 'Ethernet':
				# 1. IPv4
				if IP in pkt:
					# a. TCP
					if TCP in pkt:
						py_logger.debug("packet frame# %d is TCP",
								offset)
						# how about port, RTT...
						# pkt['TCP'].

						ip_is_found = False

						for conn in self.connections:
							if conn.is_ip_match('TCP', pkt[IP].src, pkt[IP].dst):
								prtconn_is_found = False

								for prt in conn.get_L5Conn():
									if prt.is_port_match(pkt[TCP].sport, pkt[TCP].dport):
										# if IPs and Ports are matched, just insert the frmt

										py_logger.debug("matched %s %s %s %s", \
														pkt[IP].src, pkt[IP].dst, \
														pkt[TCP].sport, pkt[TCP].dport)
										prt.ins_pkt(offset)
										prtconn_is_found = True
										break
								# end of 'for prt in conn.get_L5Conn()'
								if not prtconn_is_found:
									# if we don't find matched ports, create an obj & ins
									prt = L5Conn(pkt[TCP].sport, pkt[TCP].dport)
									prt.ins_pkt(offset)
									conn.ins_L5Conn(prt)

								ip_is_found = True
							# end of 'if conn.is_ip_match()'

						# end of 'for conn in self.connections'
						if not ip_is_found:
							# creating ports first
							prtconn = L5Conn(pkt[TCP].sport, pkt[TCP].dport)
							prtconn.ins_pkt(offset)
							# 
							ddconn = L4Conn('TCP', pkt[IP].src, pkt[IP].dst)
							ddconn.ins_L5Conn(prtconn)
							self.connections.append(ddconn)

					# b. ICMP
					elif ICMP in pkt:
						py_logger.debug("packet frame# %d is ICMP",
								offset)

					# c. UDP
					elif UDP in pkt:
						py_logger.debug("packet frame# %d is UDP",
								offset)

					# d. Unknown
					else:
						py_logger.warning("Unknown IP frame# %d %s %s",
								 offset, pkt.name, pkt.time)
				# 2. IPv6
				elif IPv6 in pkt:
					""" /auto/cores/c69044564 """
					if TCP in pkt:
						py_logger.debug("packet frame# %d is IPv6 TCP", offset)
					elif UDP in pkt:
						py_logger.debug("packet frame# %d is IPv6 UDP", offset)
					elif ICMP in pkt:
						py_logger.debug("packet frame# %d is IPv6 ICMP", offset)
					else:
						py_logger.debug("Unknown IPv6 frame# %d", offset)

				# 3. ARP
				elif ARP in pkt:
					""" /auto/cores/c69044564 """
					py_logger.debug("packet frame# %d is ARP", offset)

				# 4. Unknown
				else:
					py_logger.warning("Unknown Ethernet frame# %d %s %s",
							 offset, pkt.name, pkt.time)

			###
			### Dot3, which includes STP
			###
			elif Dot3 in pkt:
				""" /auto/cores/c69044564 """
				py_logger.debug("packet frame# %d is STP", offset)

			###
			### Unknown
			###
			else:
				py_logger.warning("Unknown Packet frame# %d %s %s", 
						offset, pkt.name, pkt.time)

			offset += 1
		# end of 'for pkt in self.__pkts'

		self.pkt_num = offset
		py_logger.debug("total packets %d", self.pkt_num)
		total_time = float(self.__pkts[offset-1].time) - float(self.__pkts[0].time)

		print("\ntotal packets %d" % self.pkt_num)
		#print("1st  pkt epoch time %s", self.__pkts[0].time)
		#print("last pkt epoch time %s", self.__pkts[offset-1].time)
		#print("total time %f ave time per pkt %f", total_time, total_time/offset)

def main():
	"""
	Main function
	"""

	global ofile_handle

	py_logger.info('argv: %s', sys.argv)

	ifile, ofile = parsing(sys.argv[1:])
	pcap_pkts = DDPackets(None)

	if ifile is not None:
		try:
			pcap_pkts.ddp_set_pkts(rdpcap(ifile))
			print("finished reading captured file")

		except IOError as e:
			py_logger.error("reading pcap failed")
			print("reading pcap file failed: %s" % e.strerror)
			sys.exit(1)

	if ofile is not None:
		try:
			ofile_handle = open(ofile, 'w')
		except IOError as e:
			print('Writing output file failed: %s' % e.strerror)
			sys.exit(1)

	"""
	# pkts.show()
	for pkt in pkts:
		if TCP in pkt:
			pkt.show()

		elif ARP in pkt:
			pkt.show()

	# pkts.pdfdump('/tmp/test.pdf')
	# pkts.conversations()
	"""
	print("processing the captured file")
	pcap_pkts.ddp_read_pkts()
	# pcap_pkts.ddp_show_pkts()
	pcap_pkts.ddp_process_conns()
	pcap_pkts.ddp_show_connections()

	if ofile_handle:
		ofile_handle.close()
		del ofile_handle

if __name__ == '__main__':
	try:
		logging.config.fileConfig("/auto/home12/hoj9/packet_sniffer/py_scapy_logging.conf")
	except IOError:
		print("Error: log file open failed")
		sys.exit(1)

	# create logger
	py_logger = logging.getLogger('py_scapy')

	main()

