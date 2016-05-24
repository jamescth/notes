#!/usr/bin/env python
"""
utilize scapy to read captured file
"""
import sys, getopt
import os
import logging

from scapy.all import *
import dpkt

logging.basicConfig(filename='python.log',level=logging.DEBUG, format='%(levelname)s:%(message)s')

logging.info('Number of arguments: %d', len(sys.argv))
logging.info('argument list: %s', str(sys.argv))

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
			logging.info("verbose")
		elif opt in ("-i", "--ifile"):
			inputfile = arg
		elif opt in ("-o", "--ofile"):
			outputfile = arg

	logging.info('Input file is %s', inputfile)
	logging.info('Output file is %s', outputfile)

	if os.path.isfile(inputfile):
		print inputfile, "exists"
	else:
		print inputfile, "doesn't exist"

	logging.info('end of py')

if __name__ == "__main__":
	main()

