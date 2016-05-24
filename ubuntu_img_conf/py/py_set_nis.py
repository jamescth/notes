#!/usr/bin/env python
"""
"""
import sys, getopt
import logging
from fabric.api import *

formatter = logging.Formatter('%(funcName)-12s: %(levelname)-5s %(lineno)4d %(message)s')
error_handler = logging.FileHandler("/tmp/py_set_nis.err", "w")
error_handler.setFormatter(formatter)

py_logger = logging.getLogger('py_set_nis')
py_logger.addHandler(error_handler)
py_logger.setLevel(logging.DEBUG)

def parsing(argv):
	"""
	parse the input arguments
	"""
	py_logger.info('Number of arguments: %d', len(sys.argv))
	py_logger.info('argument list: %s', str(sys.argv))

	user = None
	passwd = None
	ip = None

	if (len(sys.argv) < 2):
		usage()
		sys.exit(1)

	try:
		opts, args = getopt.getopt(argv,"h",
					["user=","passwd=","ip="])
	except getopt.GetoptError:
		usage()
		sys.exit(1)

	for opt, arg in opts:
		py_logger.info('opt %s arg %s', opt, arg)
		if opt == '-h':
			usage()
			sys.exit(0)
		elif opt in ("--user"):
			user = arg
		elif opt in ("--passwd"):
			passwd = arg
		elif opt in ("--ip"):
			ip = arg
	return (user, passwd, ip)

def usage():
	print('   py_set_nis.py --user=<login name> --passwd=<password> --ip=<ip or hostname>')

def main():
	"""
	The main function
	"""
	# probably don't want to log due to credential
	# py_logger.info('argv: %s', sys.argv)

	user, passwd, ip = parsing(sys.argv[1:])

	# Probably don't want to do this
	# py_logger.info("give to fabric user %s passwd %s ip %s",
	#		user, passwd, ip)

	env.user = user
	env.password = passwd
	env.host_string = ip

	files = [f for f in os.listdir('/auto/home12/hoj9/ubuntu_img_conf/mig') if os.path.isfile(f)]
	for f in files:
		print f
	"""
	try:
		sudo('hostname')
	except:
		py_logger.error("ERROR: connect to %s failed", ip)
		print("ERROR: connect to %s failed" % ip)
		sys.exit(1)
		
	with open("nis_conf", "r") as nis_conf:
		for line in nis_conf:
			py_logger.info("cmd %s", line)
			try:
				sudo(line[:-1], shell=False)
			except:
				py_logger.error("ERROR: running '%s'", line[:-1])
				print("Running command '%s' failed" % line[:-1])
				sys.exit(1)
	"""
if __name__ == '__main__':
	main()

