"""

"""
# import the Fabric api
from fabric.api import *
import datetime
import os
import glob

# hosts requires a list instead of a string
# env.hosts=['root@aclddw01.datadomain.com']
env.roledefs = {
	'jho1': ['hoj9@jho1-dl.datadomain.com'],
        'ddr': ['root@10.25.163.144']
}

env.roledefs['all'] = [h for r in env.roledefs.values() for h in r]

#env.user='root'
env.password='abc123'

def uptime():
        """
        show local host uptime
        """
        local('uptime')

def check_host():
        """
        show remote host name
        """
        run('hostname')

@roles('ddr')
def check_gcov_dir():
	"""
	Check if the gcov dir exists on the DDR.  gcov will write fail if the dir doesn't exist

	step:
		check /auto/home5/hoj9/dhcp-4.2.6/client exists?
		check /auto/home5/hoj9/dhcp-4.3.1/client exists?
		mkdir -p if it doesn't
	"""
	try:
		run('ls -l /auto/home5/hoj9/dhcp-4.2.6/client')
	except:
		print ("dir doesn't exit")

	try:
		run('ls -l /auto/home5/hoj9/dhcp-4.3.1/client')
	except:
		print ("4.3.1 doesn't exist")
		try:
			run('mkdir -p /auto/home5/hoj9/dhcp-4.3.1/client')
		except:
			print "mkdir 4.3.1 failed"

@roles('ddr')
def get_run_gcov_files():
	"""
	get *.gcda files back from the target DDR, and run gcov <file>.c for each gcda
	"""

	# get *.gcda files back
	get(remote_path='/auto/home5/hoj9/dhcp-4.2.6/client/*.gcda',
	    local_path='/auto/home5/hoj9/dhcp-4.2.6/client')

	# run gcov for each of gcda file
	os.chdir('/auto/home5/hoj9/dhcp-4.2.6/client')
	for fi in glob.glob("*.gcda"):
		filename, ext = fi.split('.')
		print filename, ext
		with lcd('/auto/home5/hoj9/dhcp-4.2.6/client'):
			local('gcov %s.c' % filename)

# local
# run dcmp.py
