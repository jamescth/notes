#! /usr/bin/env python
# import the Fabric api
from fabric.api import *
import sys

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

tsig_key = 'rndc-key'
tsig_secret = '"xsDJgO6KYgo7vVIArjsZ6Q=="'

MSG_ENG = '/ddr/var/log/debug/messages.engineering'

def hostname_check():
	"""
	show remote host name
	"""
	run('hostname')

@roles('ddr2')
def main():
	hostname_check()

if __name__ == '__main__':
	main()
