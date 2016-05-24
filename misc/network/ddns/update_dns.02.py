#! /usr/bin/env python
import dns.query
import dns.tsigkeyring
import dns.update
import sys

# replace host-example with the appropriated value
keyring = dns.tsigkeyring.from_text({
    'rndc-key' : 'xsDJgO6KYgo7vVIArjsZ6Q=='
})

def usage():
	"""
	The usage of this py

	./update_dns.py add ipv6_ddr2 192.168.100.1 100.168.192.in-addr.arpa 100.100.168.192 PTR
	
	"""
	print "update_dns.py <cmd> <hostname> <dns server> <domain name> <ip> <prt>"

def main():

	if (len(sys.argv) != 7):
		usage()
		return

	cmd = sys.argv[1]
	print "cmd", cmd

	hostname = sys.argv[2]
	print "hostname", hostname

	dns_ip = sys.argv[3]
	print "hostname", dns_ip

	domainname = sys.argv[4]
	print "Domain name", domainname

	ip = sys.argv[5]
	print "ip", ip

	prt = sys.argv[6]
	print "ip", prt

	# replace example with the domainname
	# replace host w/ the hostame
	update = dns.update.Update(domainname, keyring=keyring)
	update.replace(hostname, 300, prt, ip)

	# replace 10.0.0.1 with the dns server ip
	response = dns.query.tcp(update, dns_ip)

	print response

if __name__ == '__main__':
	main()
