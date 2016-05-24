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
	'ddr2': ['aclddw01.datadomain.com']
}

env.roledefs['all'] = [h for r in env.roledefs.values() for h in r]

env.user='root'
env.password='abc123'
env.use_ssh_config = True
# env.mirror_local_mode = True

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
def ddr2_set_dns():
	"""
	set ddr2 eth0b to ipv4 addr
	add dns 192.168.100.1 to ddr2 dns list
	"""
	run('ddsh -s net config eth0b up')
	run('ifconfig eth0b 192.168.100.100')
	run('ddsh -s net set dns 192.168.100.1')

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

@roles('ddr2')
def put_add_ddns_ip4(ip):
	"""
	cp ddsh_test.py & test_case to a remote ddr and start testing

	example:
		fab put_add_ddns_ip4:192.168.100.121/24
	"""
	with cd("/ddr/var/home/sysadmin"):
		# both 'local_path' and 'remote_path' variables are for readability.
		upload = put(local_path="ddns_query.py",remote_path="ddns_query.py", mode=0555)
		# verify upload
		upload.succeeded

		#upload = put("rndc.key.+157+28446.private","rndc.key.+157+28446.private",mode=0444)
		# verify upload
		#upload.succeeded

		run("./ddns_query.py add cherry.local ipv6_ddr1 %s 192.168.100.1 30 rndc-key xsDJgO6KYgo7vVIArjsZ6Q==" % ip)
		run("nslookup ipv6_ddr1")

@roles('ddr2')
def put_del_ddns_ip4(ip):
	"""
	cp ddsh_test.py & test_case to a remote ddr and start testing

	example:
		fab put_del_ddns_ip4:192.168.100.121/24
	"""
	with cd("/ddr/var/home/sysadmin"):
		# both 'local_path' and 'remote_path' variables are for readability.
		upload = put(local_path="ddns_query.py",remote_path="ddns_query.py", mode=0555)
		# verify upload
		upload.succeeded

		#upload = put("rndc.key.+157+28446.private","rndc.key.+157+28446.private",mode=0444)
		# verify upload
		#upload.succeeded

		run("./ddns_query.py delete cherry.local ipv6_ddr1 %s 192.168.100.1 30 rndc-key xsDJgO6KYgo7vVIArjsZ6Q==" % (ip))
		run("nslookup ipv6_ddr1")

@roles('ddr2')
def put_add_ddns_ip4_3():
	"""
	cp ddsh_test.py & test_case to a remote ddr and start testing
	"""
	with cd("/ddr/var/home/sysadmin"):
		# both 'local_path' and 'remote_path' variables are for readability.
		upload = put(local_path="ddns_query.py",remote_path="ddns_query.py", mode=0555)
		# verify upload
		upload.succeeded

		run("./ddns_query.py add cherry.local ipv6_ddr1 192.168.100.81/24 192.168.100.1 30 rndc-key xsDJgO6KYgo7vVIArjsZ6Q==")
		run("./ddns_query.py add cherry.local ipv6_ddr1 192.168.100.82/24 192.168.100.1 30 rndc-key xsDJgO6KYgo7vVIArjsZ6Q==")
		run("./ddns_query.py add cherry.local ipv6_ddr1 192.168.100.83/24 192.168.100.1 30 rndc-key xsDJgO6KYgo7vVIArjsZ6Q==")

@roles('ddr2')
def put_del_ddns_ip4_3():
	"""
	cp ddsh_test.py & test_case to a remote ddr and start testing
	"""
	with cd("/ddr/var/home/sysadmin"):
		# both 'local_path' and 'remote_path' variables are for readability.
		upload = put(local_path="ddns_query.py",remote_path="ddns_query.py", mode=0555)
		# verify upload
		upload.succeeded

		run("./ddns_query.py delete cherry.local ipv6_ddr1 192.168.100.81/24 192.168.100.1 30 rndc-key xsDJgO6KYgo7vVIArjsZ6Q==")
		run("./ddns_query.py delete cherry.local ipv6_ddr1 192.168.100.82/24 192.168.100.1 30 rndc-key xsDJgO6KYgo7vVIArjsZ6Q==")
		run("./ddns_query.py delete cherry.local ipv6_ddr1 192.168.100.83/24 192.168.100.1 30 rndc-key xsDJgO6KYgo7vVIArjsZ6Q==")

@roles('ddr1')
def put_add_ddns_ip6():
	"""
	cp ddsh_test.py & test_case to a remote ddr and start testing
	"""
	with cd("/ddr/var/home/sysadmin"):
		# both 'local_path' and 'remote_path' variables are for readability.
		upload = put(local_path="ddns_query.py",remote_path="ddns_query.py", mode=0555)
		# verify upload
		upload.succeeded

		#upload = put("rndc.key.+157+28446.private","rndc.key.+157+28446.private",mode=0444)
		# verify upload
		#upload.succeeded

		run("./ddns_query.py add cherry.local ipv6_ddr4 2100:bad:cafe:f00d::4:100/64 2100:bad:cafe:f00d::1:101 30 None None")
		#run("nslookup ipv6_ddr4")
		#run("nslookup 2100:bad:cafe:f00d::4:100")

@roles('ddr1')
def put_del_ddns_ip6():
	"""
	cp ddsh_test.py & test_case to a remote ddr and start testing
	"""
	with cd("/ddr/var/home/sysadmin"):
		# both 'local_path' and 'remote_path' variables are for readability.
		upload = put(local_path="ddns_query.py",remote_path="ddns_query.py", mode=0555)
		# verify upload
		upload.succeeded

		#upload = put("rndc.key.+157+28446.private","rndc.key.+157+28446.private",mode=0444)
		# verify upload
		#upload.succeeded

		run("./ddns_query.py delete cherry.local ipv6_ddr4 2100:bad:cafe:f00d::4:100/64 2100:bad:cafe:f00d::1:101 30 None None")
		#run("nslookup ipv6_ddr4")
		#run("nslookup 2100:bad:cafe:f00d::4:100")
