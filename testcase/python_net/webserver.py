#!/usr/bin/env python
"""
The most unusual and ignorant web server written ever
"""

import socket
import sys

#Config constants
CFG_SRV_BIND_IF="localhost"
CFG_SRV_BIND_PORT= 8080
CFG_SRV_LISTEN_BACKLOG = 10
#End of config constants

# Canned HTTP Response (we mimic an Apache response)
# if you change the embedded HTML, be so kind as to adapt
# the "Content-Length: 49" header field, too, please.
HTTP_RESPONSE = """HTTP/1.1 200 OK
Date: Fri, 27 May 2014 19:13:05 GMT
Server: Apache/2.2.17 (Unix) mod_ssl/2.2.17 OpenSSL/0.9.81 DAV/2
Last-Modified: Sat, 28 Aug 2014 22:17:02 GMT
ETag: "20e2b8b-3c-48ee99731f380"
Accept-Ranges: bytes
Content-Length: 49
Connection: close
Content-Type: text/html

<html><body><h1>Hello, world!</h1></body></html>
"""

# Create a TCP/IP socket to listen to
server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

# Prevent from "address already in use" upon server restart
server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)

# Bind the socket to the port
server_address = (CFG_SRV_BIND_IF, CFG_SRV_BIND_PORT)
print >>sys.stderr, 'our URL is http://localhost:%d/' % server_address[1]
print >>sys.stderr, 'we can only be stopped by CTRL+C'
server.bind(server_address)

# Listen for incomming connections
server.listen(CFG_SRV_LISTEN_BACKLOG)

while 1:
	try:
		# wait for inccmming connection
		connection, client_address = server.accept()
		print >>sys.stderr, 'New connection from', client_address

		# don't care what browser wants, we'll just send our response
		connection.send("%s" % HTTP_RESPONSE)
		print >>sys.stderr, 'Response sent.'

		# indicate we are going to disconnect
		connection.shutdown(socket.SHUT_WR | socket.SHUT_RD)

		# and finally we close the connection
		connection.close()
		print >>sys.stderr, 'Connection close'
	except:
		# CTRL+C pressed or worse, looks like we are dying
		print "\n *** Ouch, that hurts! ***"
		break

print >>sys.stderr, 'Shutting down...'
server.close()
print >>sys.stderr, 'Last line before exitting. Over and out'
