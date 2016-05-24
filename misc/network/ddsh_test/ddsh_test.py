#!/usr/bin/env python
"""

"""
import sys, getopt
import os
import subprocess
import logging

logging.basicConfig(level=logging.DEBUG,
                    format='%(asctime)s %(name)-12s %(levelname)-8s %(message)s',
                    datefmt='%m-%d %H:%M',
                    filename='py_debug.log',
                    filemode='w')

py_logger = logging.getLogger('py_log')

class DDConfig:
	"""
	"""

	def __init__(self, str_cmd = "not defined", eth = "not defined"):
		if (eth == "not defined"):
			self.str_cmd = str_cmd
		else:
			self.str_cmd = str_cmd + " " + eth

		py_logger.info(self.str_cmd)

		# -------- class member --------
		self.output = []
		self.eth_list = []

	def scan_config(self):
		index = 0
		print "\n******** output for: %s ********" % self.str_cmd
		proc = subprocess.Popen(self.str_cmd, shell=True, stdout=subprocess.PIPE)

		# can we not copy so many times?  for now, quick hack
		self.output = proc.communicate()[0]

		for line in self.output.splitlines():
			if ('eth' in line):
				#print "%d %s" %(index, line.partition(' ')[0])
				key = line.partition(' ')[0]
				#print line
				self.eth_list.append([key,index])
			index += len(line)

	def print_config(self, start, end):
		for line in self.output[start:end].splitlines():
			if ('inet' in line) or ('eth' in line):
				print line

	def show_net_config(self, port):
		index = 0
		#print len(self.eth_list)
		# print self.eth_list
		# print the lable
		if (self.eth_list[0][1] != 0):
			print "%s" % self.output[0:self.eth_list[0][1]]

		# print the targeted content
		for key, offset in self.eth_list:
			if port in key:
				if (index+1 < len(self.eth_list)):
					self.print_config(offset, self.eth_list[index+1][1])
				else:
					self.print_config(offset, len(self.output))
				#print key
		 		#print offset, self.eth_list[index+1][1]
			index += 1

		# print the foot label if any
		#if (eth_list[len(eth_list) - 1][1] != len(self.output)):
			# print eth_list[len(eth_list) - 1][1]
			# print len(self.output)
			# print "%s" % self.output[eth_list[len(eth_list) - 1][1]:-1]

def show_port(port):
	a = DDConfig('ifconfig')
	a.scan_config()
	a.show_net_config(port)
	#del a
	b = DDConfig('ddsh -s net config')
	b.scan_config()
	b.show_net_config(port)
	#del b
	c = DDConfig('ddsh -s net show setting')
	c.scan_config()
	c.show_net_config(port)
	#del c

def usage():
	print 'ddsh_test.py -i <testcase>'
	print 'the 1st line in the testcase should be the physical port we want to examine'

def parsing(argv):
	"""
	parsing input arguments for main()
	"""

	input_dir = ''

	try:
		opts, args = getopt.getopt(argv,"hi:",["ifile="])
	except getopt.GetoptError:
		usage()
		sys.exit(1);

	for opt, arg in opts:
		if opt == '-h':
			usage()
			sys.exit(0)
		elif opt in ("-i", "--ifile"):
			input_dir = arg

	return (input_dir)

def main():
	port = ''
	ifile = parsing(sys.argv[1:])
	
	# check if the file exists
	if not os.path.isfile(ifile):
		print "file doesn't exist: %s" % (ifile)
		usage()
		sys.exit(1)

	with open(ifile, 'r') as f:
		for num, line in enumerate(f, 1):
			if num == 1:
				port = line[:-1]
				print port
				continue
			print "\n$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"
			print line[:-1]
			proc = subprocess.Popen(line[:-1], shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
			# proc = subprocess.Popen(line[:-1])
			# can we not copy so many times?  for now, quick hack
			proc.communicate()[0]

			show_port(port)

if __name__ == '__main__':
	main()


