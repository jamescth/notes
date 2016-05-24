#! /usr/bin/env python
"""
Support for RFC 2136 dynamic DNS updates.
Requires dnspython module
"""
try:
	import dns.query
	import dns.tsigkeyring
	import dns.update
	dns_support = True
except ImportError as e:
	dns_support = False

import sys

#JAMES: remove later
import logging

formatter = logging.Formatter('%(lineno)-4s %(funcName)-12s: %(message)s')

console_handler = logging.StreamHandler()
console_handler.setFormatter(formatter)

error_handler = logging.FileHandler("error.log", "a")
error_handler.setLevel(logging.ERROR)
error_handler.setFormatter(formatter)

log = logging.getLogger('ddns')
log.addHandler(console_handler)
#log.addHandler(error_handler)
log.setLevel(logging.DEBUG)

# replace host-example with the appropriated value
keyring = dns.tsigkeyring.from_text({
    'rndc-key' : 'xsDJgO6KYgo7vVIArjsZ6Q=='
})

def __virtual__():
	"""
	Confirm dnspython is available
	"""
	if dns_support:
		return 'ddns'
	return False

def usage():
	"""
	The usage of this py

  	./update_dns.py cherry.local ipv6_ddr1 192.168.100.201 192.168.100.1
	
	"""
	print "update_dns.py <zone/domain> <hostname> <ip> <dns ip>"

def update(zone, name, ttl, rdtype, data, nameserver='127.0.0.1', replace=False):
	"""
	Add, replace, or update a DNS record.
	nameserver must be an IP address and the minion running this module
	must have update privileges on the server.

	If replace is true, first deletes all records for this name and type.

	CLI Example:
	salt ns1 ddns.update example.com host1 60 A 10.0.0.1
	"""
	log.info("enter update()")
	log.info("zone:" + zone + " name:" + name + " data:" + data)

	name = str(name)
	fqdn = '{0}.{1}'.format(name,zone)
	log.info("requesting fqdn in update()")
	log.info(fqdn)

	request = dns.message.make_query(fqdn, rdtype)
	answer = dns.query.udp(request, nameserver)

	log.info(request)
	log.info(answer)

	rdtype = dns.rdatatype.from_text(rdtype)
	rdata = dns.rdata.from_text(dns.rdataclass.IN, rdtype, data)

	log.info("rdtype:")
	log.info(rdtype)
	log.info("rdata:")
	log.info(rdata)

	is_update = False
	for rrset in answer.answer:
		if rdata in rrset.items:
			rr = rrset.items
			if ttl == rrset.ttl:
				if replace and (len(answer.answer) > 1
				   or len(rrset.items) > 1):
					is_update = True
					break
				return None
			is_update = True
			break

	dns_update = dns.update.Update(zone, keyring=keyring)
	log.info("dns update request")
	log.info(dns_update)
	log.info("name")
	log.info(name)
	log.info(rdata)
	if is_update:
		#dns_update.replace(name, ttl, rdata)
		print "replace"
	else:
		#dns_update.add(name, ttl, rdata)
		print "add"

	answer = dns.query.udp(dns_update, nameserver)

	log.info("update final answer")
	log.info(answer)

	if answer.rcode() > 0:
		return False

	return True

def add_host(zone, name, ttl, ip, nameserver='127.0.0.1', replace=True):
	"""
	zone: is either the domain name
	name: the client hostname
	ttl:  time to live
	ip:   the client ip
	nameserver: dns server ip
	"""

	# We update the forward zone first

	# This is the update() prototype
	# update(zone, name, ttl, rdtype, data, nameserver='127.0.0.1', replace=False)
	log.info("add_host first update()")
	res = update(zone, name, ttl, 'A', ip, nameserver, replace)
	if res is False:
		return False

	fqdn = '{0}.{1}.'.format(name, zone)
	zone = "in-addr.arpa."
	parts = ip.split('.')
	log.info("log parts")
	log.info(parts)
	# popped is a list to store the reversed IP for reverse zone
	popped = []
	reverse_ip = ".".join(parts[::-1])
	data = '{0}.{1}'.format(reverse_ip, zone)
	log.info("data:" + data)

	#ptr = update('100.168.192.in-addr.arpa', parts[3], 600, 'PTR', reverse_ip, nameserver,replace)

	# Iterate over possible reverse zones
	while len(parts) > 1:
		p = parts.pop(0)
		popped.append(p)
		zone = '{0}.{1}'.format(p, zone)
		#name = ip.replace('{0}.'.format('.'.join(popped)), '', 1)
		name = ".".join(parts[::-1])

		'''
		log.info("in add_host, calling update()")
		log.info("zone:" + zone + " name:" + name + " data:" + fqdn)
		ptr = update(zone, name, ttl, 'PRT', fqdn, nameserver, replace)
		if ptr:
			log.info(ptr)
			return True
		'''
		# copy from update()

		dns_update = dns.update.Update(zone, keyring=keyring)
		log.info("dns update request")
		#log.info(dns_update)

		request = dns.message.make_query(fqdn, rdtype)
		answer = dns.query.udp(request, nameserver)

		rdtype = dns.rdatatype.from_text('PTR')
		rdata = dns.rdata.from_text(dns.rdataclass.IN, rdtype, data)

		dns_update.replace(data, ttl, 'PTR')

		answer = dns.query.udp(dns_update, nameserver)

		if answer.rcode() > 0:
			log.error("ddns failes:" + zone)
			continue

		log.info(answer)
	return res

def main():
	"""
	./update_dns.py cherry.local ipv6_ddr1 192.168.100.111 192.168.100.1
	"""
	if (len(sys.argv) != 5):
		log.error("the len(argv) %d is wrong", len(sys.argv))
		log.error(sys.argv)
		usage()
		return

	zone = sys.argv[1]
	log.info("Domain name %s", zone)

	name = sys.argv[2]
	log.info("hostname %s", name)

	ip = sys.argv[3]
	log.info("ip %s", ip)

	dns_ip = sys.argv[4]
	log.info("DNS %s", dns_ip)

	"""
	fqdn = '{0}.{1}.'.format(name, zone)
	log.info("fqdn %s", fqdn)

	zone = "in-addr.arpa."

	parts = ip.split('.')
	print parts
	popped = []
	while len(parts) > 1:
		p = parts.pop(0)
		popped.append(p)
		zone = '{0}.{1}'.format(p, zone)
		print zone
		name = ip.replace('{0}.'.format('.'.join(popped)), "", 1)
		print ".".join(parts[::-1])
	return
	"""
	# add_host function prototype
	# add_host(zone, name, ttl, ip, nameserver='127.0.0.1', replace=True):
	add_host(zone, name, 3600, ip, dns_ip)

	# replace example with the domainname
	# replace host w/ the hostame
	#update = dns.update.Update(zone, keyring=keyring)
	#update.replace(name, 300, prt, ip)

	# replace 10.0.0.1 with the dns server ip
	#response = dns.query.tcp(update, dns_ip)

	#print response

if __name__ == '__main__':
	main()
