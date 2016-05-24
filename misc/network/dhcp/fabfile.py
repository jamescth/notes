"""
        Requirement: The workstation requires python & fabric to be installed.
                     To install fabric, run "sudo apt-get install fabric".

	Cmd:         fab <func>
                     for example, to run the test suite:
                         # fab put_test_frame
                         # fab -R all hostname_check

                     fab -l: list all the defined funcs
"""
# import the Fabric api
from fabric.api import *

env.user='root'
# hosts requires a list instead of a string
# env.hosts=['root@aclddw01.datadomain.com']
env.roledefs = {
	'ddr1': ['discover.datadomain.com'],
	'ddr2': ['aclddw01.datadomain.com'],
	'koala96':['10.25.162.34']
}

env.roledefs['all'] = [h for r in env.roledefs.values() for h in r]

env.user='root'
env.password='abc123'
env.use_ssh_config = True
# env.mirror_local_mode = True

def get_msg_eng():
	"""
	get /ddr/var/log/debug/messages.engineering to the local directory
	"""
	with cd('/ddr/var/log/debug'):
		get('messages.engineering')

def uptime():
	"""
	show local host uptime
	"""
	local('uptime')

def hostname_check():
	"""
	show remote host name
	"""
	run('hostname')

@roles('ddr1')

def ddr1_set_dhcp6():
	"""
	set ddr1 eth0b to the default ipv6 addr
	We don't need to use -R to select host since @roles indicates exclusive for ddr1
	"""
	run("ddsh -s net config eth5c dhcp yes ipversion ipv6")
@roles('ddr1')
def ddr1_set_dhcp4():
	"""
	set ddr1 eth0b to ipv4 dhcp
	We don't need to use -R to select host since @roles indicates exclusive for ddr1
	"""
	run("ddsh -s net config eth5c dhcp yes ipversion ipv4")

@roles('ddr2')
def ddr2_set_ipv6():
	"""
	set ddr2 eth0b to the default ipv6 addr
	We don't need to use -R to select host since @roles indicates exclusive for ddr2
	"""
	run("ddsh -s net config eth0b 2100:bad:cafe:f00d::deed:2/64")

@roles('ddr2')
def ddr2_set_dhcp4():
	"""
	set ddr2 eth0b to ipv4 dhcp
	We don't need to use -R to select host since @roles indicates exclusive for ddr2
	"""
	run("ddsh -s net config eth0b dhcp yes ipversion ipv4")

def put_test_frame():
	"""
	cp ddsh_test.py & test_case to a remote ddr and start testing
	"""
	with cd("/ddr/var/home/sysadmin"):
		# both 'local_path' and 'remote_path' variables are for readability.
		upload = put(local_path="~/notes/network/ddsh_test/ddsh_test.py",remote_path="ddsh_test.py", mode=0555)
		# verify upload
		upload.succeeded

		upload = put("~/notes/network/ddsh_test/test_case","test_case",mode=0444)
		# verify upload
		upload.succeeded

		run("./ddsh_test.py -i test_case")

@roles('ddr2')
def ddr2_run_crash():
	with cd('/tmp'):
		run('/usr/bin/crash -i /root/crash_live_script > /tmp/crash.out')
		get('crash.out')
		run('rm /tmp/crash.out')

