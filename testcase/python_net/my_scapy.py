#!/usr/bin/env python
"""
utilize scapy to read captured file
"""
import sys, getopt
import os
import logging

from scapy.all import *
import dpkt

# set up logging to file
logging.basicConfig(level=logging.DEBUG,
                    format='%(asctime)s %(name)-12s %(levelname)-8s %(message)s',
                    datefmt='%m-%d %H:%M',
                    filename='python.log',
                    filemode='w')

#define a Handler which writes INFO msg or higher to the sys.stderr
console = logging.StreamHandler()
console.setLevel(logging.WARNING)

# set a format which is simpler for console use
formatter = logging.Formatter('%(name)-12s: %(levelname)-8s %(message)s')

# tell the handler to use this format
console.setFormatter(formatter)

# add the handler to the root logger
logging.getLogger('').addHandler(console)

# Now, we can log to the root logger, or any other logger.  First the root
# application:

scapy_logger = logging.getLogger('my_scapy')

scapy_logger.info('Number of arguments: %d', len(sys.argv))
scapy_logger.info('argument list: %s', str(sys.argv))

#INFILE='netcap-before.cap'
#OUTFILE='test.cap'

#paks = rdpcap(INFILE)
#lpaks = len(paks)
#print lpaks

# srcList = [pkt[1].src for pkt in paks# srcList = [pkt[1].src for pkt in paks]n]
#filtered = (pkt for pkt in pkts if UDP in pkt)

#wrpcap(OUTFILE, filtered)


#for pak in paks:
	#pak.show()
	#pak.show2()
	#print pak.mysummary()
#	print pak.summary()
	#pak.sprintf("%.time% %-15s,IP.src% -> %-15s,IP.dst% %IP.chksum% ""%03xr,IP.proto% %r,TCP.flags%")

	#pak[UDP].remove_payload()
	#print pak
#wrapcap(OUTFILE, paks)

def handling_scapy(ifile, ofile):
	paks = rdpcap(ifile)

	for pak in paks:
		pak.show()

def usage():
	print 'my_scapy.py -i <input file> -o <output file>'

def main():
	inputfile = ''
	outputfile = ''
	verbose = False

	try:
		opts, args = getopt.getopt(sys.argv[1:],"hi:o:v",["ifile=","ofile="])

	except getopt.GetoptError:
		usage()
		sys.exit(2)

	for opt, arg in opts:
		if opt == '-h':
			usage()
			sys.exit(0)
		elif opt in ("-v"):
			verbose = True
			scapy_logger.info("verbose")
		elif opt in ("-i", "--ifile"):
			inputfile = arg
		elif opt in ("-o", "--ofile"):
			outputfile = arg

	scapy_logger.info('Input file is %s', inputfile)
	scapy_logger.info('Output file is %s', outputfile)

	if os.path.isfile(inputfile):
		scapy_logger.info("%s exists", inputfile)
	else:
		scapy_logger.error("file does not exist: %d", inputfile)

	handling_scapy(inputfile, outputfile)

	scapy_logger.info('end of py')

if __name__ == "__main__":
	main()

