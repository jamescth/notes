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
import pexpect

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

def py_sudo(arg=None):
	if arg is None:
		return
	py_logger.info("arg: %s", arg)
	sudo(arg)

def py_local(arg=None):
	if arg is None:
		return
	py_logger.info("arg: %s", arg)
	local(arg)

def py_put(arg=None):
	"""
	put("~/notes/network/ddsh_test/test_case","test_case",mode=0444)
	"""
	if arg is None:
		return
	py_logger.info("arg: %s", arg)

	arg_list = arg.split(" ")
	if (len(arg_list) != 3) or (arg_list[2] == ""):
		# if the arguments are less than 3, or the last argument is a white space
		# since we use split(" ") for white space, the last arg will be an empty str
		py_logger.error("len is less than 3 %s", arg_list)
		print("PUT cmd syntax error: source-file target file-mode")
		return
	
	if not os.path.isfile(arg_list[0]):
		py_logger.error("file access error %s", arg_list[0])
		print("PUT file access error %s" % arg_list[0])
		return

	if not arg_list[2].isdigit():
		py_logger.error("file mode error %s, must be digits", arg_list[2])
		print("PUT file mode error %s, must be digits" % arg_list[2])
		return

	upload = put(local_path=arg_list[0],remote_path=arg_list[1],mode=(arg_list[2]))
	upload.succeeded

def py_get(arg=None):
	"""
	run('/usr/bin/crash -i /root/crash_live_script > /tmp/crash.out')
	get('crash.out')
	"""
	if arg is None:
		return
	py_logger.info("arg: %s", arg)
	get(arg)

def py_cust(arg=None):
	"""
	This handles the 'PY' keyword, which is calling the cust py func.
	The routine will call the func dict again to get the rigth sub-routine.
	"""
	if arg is None:
		return
	py_logger.info("arg: %s", arg)
	func = PY_FUNC_DICT.get(arg)
	if func is not None:
		# run sudoers func
		func()

def py_pexpect(arg=None):
	"""
	This handles the 'PEXPECT' keyword, which calls 
	"""

PY_FUNC_DICT = {
	"PY":py_cust,
	"upload_mig":upload_mig,
	"sudoers":sudoers,
	"sudo":py_sudo,
	"LOCAL":py_local,
	"PUT":py_put,
	"GET":py_get,
	"PEXPECT":py_pexpect
}

def parsing(argv):
	"""
	parse the input arguments
	"""
	# py_logger.info('Number of arguments: %d', len(sys.argv))
	# py_logger.info('argument list: %s', str(sys.argv))

	user = None
	passwd = None
	ip = None
	conf = None
	cmd = None

	if (len(sys.argv) < 2):
		usage()
		sys.exit(1)

	try:
		opts, args = getopt.getopt(argv,"h",
					["user=","passwd=","ip=","conf=","cmd="])
	except getopt.GetoptError:
		usage()
		sys.exit(1)

	for opt, arg in opts:
		# py_logger.info('opt %s arg %s', opt, arg)
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
		elif opt in ("--cmd"):
			cmd = arg
	return (user, passwd, ip, conf, cmd)

def usage():
	print('   py_set_nis.py --user=<login name> --passwd=<password> --ip=<ip or hostname> --conf=<conf file>')
	print("   py_set_nis.py --user=<login name> --passwd=<password> --ip=<ip or hostname> --cmd='cmdline arg'")

def main():
	"""
	The main function
	"""
	# probably don't want to log due to credential
	# py_logger.info('argv: %s', sys.argv)

	user, passwd, ip, conf, cmd= parsing(sys.argv[1:])
	py_logger.info("user=%s ip=%s conf=%s cmd=%s", user, ip, conf, cmd)
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

	if cmd is not None:
		# we are running single command
		run(cmd, shell=False)
	else:
		# apply the conf file which is a list of cmds
		with open(conf, "r") as nis_conf:
			for line in nis_conf:
				# [:-1] is to get rid of the tailend newline
				# print() will add a new one anyway
				py_logger.info("CMD: %s", line[:-1])

				# ignore comments and newlines
				m = re.match('[\n#]|PY |sudo |LOCAL |PUT |GET ', line)
				if m is not None:
					cmd = line.split(" ")[0]
					py_logger.info("cmd: %s", cmd)
					# search through the function dict.
					func = PY_FUNC_DICT.get(cmd)

					if func is not None:
						# we want to pass the arg to the callees
						# the arg doesn't include the cmd AND the white space
						# line[ start pos : end pos ]
						func(line[len(cmd) + 1 : -1])

					# for newline '\n' & comment '#', the func will be None
					# move on
					continue

					"""
					cmd = m.group()
	
					if (cmd == 'PY '):
						# PY is to run the cust python fuct

						# search through the function dict.
						# If a keyword is pre-defined, its funcPtr will return
						func = PY_FUNC_DICT.get(line.split(" ")[0])
						if func is not None:
							# run sudoers func
							func()

					elif (cmd == 'sudo ') or (cmd == "LOCAL ") or (cmd== "GET "):
						# these cmds call the equivalent fabric APIs

						func = PY_FUNC_DICT.get(line.split(" ")[0])
						func(line.split(" ")[1])

					elif (cmd == 'PUT '):
						# what will be the fmt???					

					# for '\n' and '#', just continue
					continue
					"""
				# end of m is not None

				# here is to run remote cmd w/out sudo
				try:
					# if we want to use CMD:, we can use:
					#   sudo(line[len("CMD:"):-1], shell=False)
					# py_logger.info("RUN: %s", line[:-1])
					run(line[:-1], shell=False)
				except:
					py_logger.error("ERROR: running '%s'", line[:-1])
					print("Running command '%s' failed" % line[:-1])
					sys.exit(1)

if __name__ == '__main__':
	main()

