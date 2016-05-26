#!/usr/bin/env python
import logging, logging.config
import sys, getopt, os

from DDFileList import DDFileList
from DDLogFile import DDLogFile
import py_json

# global
PROJ_PATH = '/auto/home12/hoj9/bin/py_dir/'
FLIST_JSON = 'py_dir.json'
LOG_CONFIG = 'py_dir_logging.conf'

output_handle = None

"""
how to deal w/ enum for print out flags?
may not be a good idea.  It's too ugly
"""
def enum(**named_values):
	return type('Enum', (), named_values)

pyp = enum (
	OUT = 0x01,
	SYN = 0x02,
	RST = 0x04,
	PSH = 0x08,
	ACK = 0x10,
	URG = 0x20,
	ECE = 0x40,
	CWR = 0x80
)

def py_print(*args, **kwargs):
	"""
	This func is to add additional features such as writing to a file on top of print

	WARNING:
	if ofile_handle is closed, it will not be None and it cant be writable.  Probably
	using a exception instead.
	"""
	if output_handle is not None:
		output_handle.write(args[0] + '\n')
	print(args[0])

#HELLO, NEED TO print the right msg
def usage():
	""" """

	print('   py_scapy.py --ifile=<input file>')
	print('   py_scapy.py --ifile=<input file> --ofile=<output file>')

def parsing(argv):
	"""
	parse the input arguments
	"""
	py_logger.info('Number of arguments: %d', len(sys.argv))
	py_logger.info('argument list: %s', str(sys.argv))

	input_dir = ''
	output_file = ''
	json = None

	if (len(sys.argv) < 2):
		usage()
		sys.exit(1)

	try:
		opts, args = getopt.getopt(argv,"hi:o:",
					["idir=","ofile=","json="])
	except getopt.GetoptError:
		usage()
		sys.exit(1)

	for opt, arg in opts:
		py_logger.info('opt %s arg %s', opt, arg)
		if opt == '-h':
			usage()
			sys.exit(0)
		elif opt in ("-i", "--idir"):
			input_dir = arg
		elif opt in ("-o", "--ofile"):
			output_file = arg
		elif opt in ("--json"):
			json = arg

	return (input_dir, output_file, json)

def main():
	"""
	The main function
	"""

	global output_handle

	idir, ofile, json = parsing(sys.argv[1:])

	if ofile is not None:
		try:
			output_handle = open(ofile, 'w')

		except IOError as e:
			py_print('Writing output file failed: %s' % e.strerror)
			py_logger.error('Writing output file failed: %s' % e.strerror)
			sys.exit(1)

	flist_obj = DDFileList(start_path = idir, given_json = PROJ_PATH + FLIST_JSON)

	# write the list to a local json 
	with open(idir+'/flist.json', 'w') as jfile:
		jfile.write(py_json.obj_to_json(flist_obj))

	with py_json.ignored(OSError):
		os.chmod(idir+'/flist.json', 0666)

	#########
	## creat FileLog
	#########
	for pat in flist_obj.get_patterns():
		py_print("%s" % pat)

		for fname in flist_obj.get_files(pat):
			py_print("%s" % fname)

	######################################
	## exit clean up
	######################################
	if output_handle:	
		output_handle.close()
		del output_handle

if __name__ == '__main__':
	try:
		logging.config.fileConfig(PROJ_PATH + LOG_CONFIG)
	except IOError:
		print("Error: log file open failed")
		sys.exit(1)

	# create logger
	py_logger = logging.getLogger('py_dir')

	main()

