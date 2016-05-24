#! /usr/bin/env python
import signal
import time
import sys
import os

def main():
	time.sleep(5)


def Exit_gracefully(signal, frame):
	print "received signal %d" % signal
	sys.exit(6)

if __name__ == '__main__':
	signal.signal(signal.SIGINT, Exit_gracefully)
	main()
