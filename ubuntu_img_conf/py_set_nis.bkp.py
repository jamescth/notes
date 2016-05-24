#!/usr/bin/env python
"""
# for a fresh install sys, back up the config files to .org first
./py_set_nis.py --user=james --passwd=jamescth --ip=jho4-dl.datadomain.com --conf=backup_conf

# If any thing goes wrong, run this one to copy .org back to conf
./py_set_nis.py --user=james --passwd=jamescth --ip=jho4-dl.datadomain.com --conf=resume_conf

# set up all the conf files
./py_set_nis.py --user=james --passwd=jamescth --ip=jho4-dl.datadomain.com --conf=nis_conf
"""
import sys, getopt, os
import logging
from fabric.api import *
import re

# set up logger
formatter = logging.Formatter('%(funcName)-12s: %(levelname)-5s %(lineno)4d %(message)s')
error_handler = logging.FileHandler("/tmp/py_set_nis.err", "w")
error_handler.setFormatter(formatter)

py_logger = logging.getLogger('py_set_nis')
py_logger.addHandler(error_handler)
py_logger.setLevel(logging.DEBUG)

# pre-defined func
def upload_mig():
	mig_dir = "/auto/home12/hoj9/ubuntu_img_conf/mig/"
	wk_dir = "/tmp/"

	# upload the /etc/... config files to /tmp first
	files = [f for f in os.listdir(mig_dir) if os.path.isfile(os.path.join(mig_dir,f))]
	for f in files:
		# we don't need to do error handling here.
		# put() will do it for as to show the error code & file name
		upload = put(local_path=mig_dir+f, remote_path=wk_dir+f,mode=0644)
		upload.succeeded

def sudoers():
	print("Setting up sudoers")
	lg_name = raw_input("Please provide the DD login name:")
	print(lg_name)
	dest_file = '/tmp/sudoers.mig'
	try:
		with open(dest_file,'w') as tmp_file:
			tmp_file.write(lg_name + "    ALL=NOPASSWD: ALL")

	except:
		py_logger.error("ERROR: open %s for write failed", dest_file)
		print("ERROR: open %s for write failed" % dest_file)
		sys.exit(1)

	upload = put(local_path=dest_file, remote_path=dest_file,mode=0644)
	upload.succeeded

PY_FUNC_DICT = {
	"upload_mig":upload_mig,
	"sudoers":sudoers
}

def parsing(argv):
	"""
	parse the input arguments
	"""
	py_logger.info('Number of arguments: %d', len(sys.argv))
	py_logger.info('argument list: %s', str(sys.argv))

	user = None
	passwd = None
	ip = None
	conf = None

	if (len(sys.argv) < 2):
		usage()
		sys.exit(1)

	try:
		opts, args = getopt.getopt(argv,"h",
					["user=","passwd=","ip=","conf="])
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
		elif opt in ("--conf"):
			conf = arg
	return (user, passwd, ip, conf)

def usage():
	print('   py_set_nis.py --user=<login name> --passwd=<password> --ip=<ip or hostname> --conf=<conf file>')

def main():
	"""
	The main function
	"""
	# probably don't want to log due to credential
	# py_logger.info('argv: %s', sys.argv)

	user, passwd, ip, conf= parsing(sys.argv[1:])

	# Probably don't want to do this
	# py_logger.info("give to fabric user %s passwd %s ip %s",
	#		user, passwd, ip)

	env.user = user
	env.password = passwd
	env.host_string = ip

	try:
		sudo('hostname')
	except:
		py_logger.error("ERROR: connect to %s failed", ip)
		print("ERROR: connect to %s failed" % ip)
		sys.exit(1)

	# apply the conf files to /etc/...
	with open(conf, "r") as nis_conf:
		for line in nis_conf:
			# [:-1] is to get rid of the tailend newline
			# print() will add a new one anyway
			py_logger.info("RUN:  %s", line[:-1])

			# ignore comments and newlines
			m = re.match('[\n#]|PY:', line)
			if m is not None:
				if (m.group() == '\n') or (m.group() == '#'):
					continue
				elif (m.group() == 'PY:'):
					cmd_len = len('PY:')

					# search through the function dict.
					# If a keyword is pre-defined, its funcPtr will return
					func = PY_FUNC_DICT.get(line[cmd_len:-1])
					if func is not None:
						# run sudoers func
						func()
						continue

			# from here, any cmd is for linux
			try:
				# if we want to use CMD:, we can use:
				#   sudo(line[len("CMD:"):-1], shell=False)
				# py_logger.info("RUN: %s", line[:-1])
				sudo(line[:-1], shell=False)
			except:
				py_logger.error("ERROR: running '%s'", line[:-1])
				print("Running command '%s' failed" % line[:-1])
				sys.exit(1)

if __name__ == '__main__':
	main()

