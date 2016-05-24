#!/usr/bin/env python
"""
Mini Client program
Make sure Mini Server is running
"""
import socket

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect(('localhost', 50000))
s.send('Happy Hacking')
data = s.recv(1024)
s.close()
print 'Received:'
print data
