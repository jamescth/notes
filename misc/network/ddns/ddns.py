#! /usr/bin/env python
import dns.query
import dns.tsigkeyring
import dns.update
import dns.reversename
import sys

# replace host-example with the appropriated value
keyring = dns.tsigkeyring.from_text({
    'rndc-key' : 'xsDJgO6KYgo7vVIArjsZ6Q=='
})

def usage():
	"""
	The usage of this py

	./ddns.py cherry.local ipv6_ddr1 192.168.100.200 192.168.100.1
	
	"""
	print "update_dns.py <zone> <hostname> <ip> <dns server>"

def main():

	if (len(sys.argv) != 5):
		usage()
		return
	zone = sys.argv[1]
	print "Domain name", zone

	hostname = sys.argv[2]
	print "hostname", hostname

	ip = sys.argv[3]
	print "ip", ip

	dns_ip = sys.argv[4]
	print "hostname", dns_ip

	print "set up forward zone"
	# replace example with the domainname
	# replace host w/ the hostame
	update = dns.update.Update(zone, keyring=keyring)
	update.replace(hostname, 30, 'A', ip)

	# replace 10.0.0.1 with the dns server ip
	response = dns.query.tcp(update, dns_ip)

	print response

	print "set up reverse zone"
	parts = ip.split('.')
	#reverse_ip = ".".join(parts[-1::-1])
	#reverse_ip = '{0}.{1}'.format(reverse_ip,"in-addr.arpa")
	reverse_ip = dns.reversename.from_address(ip)
	print "reverse ip:%s" % format(reverse_ip)

	rzone = ".".join(parts[-2::-1])
	rzone = '{0}.{1}'.format(rzone,"in-addr.arpa")
	print "rzone :%s" % format(rzone)

	hostdo = '{0}.{1}'.format(hostname,zone)
	update = dns.update.Update(rzone, keyring=keyring)
	#update.replace(hostname, 600, 'PTR', reverse_ip)
	update.replace(reverse_ip, 30, 'PTR', hostname)

	# replace 10.0.0.1 with the dns server ip
	response = dns.query.tcp(update, dns_ip)

	print response

if __name__ == '__main__':
	main()
