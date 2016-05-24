#! /usr/bin/env python
"""
This module is to enable debugability to verify MSG_ENG and KERN_INFO
"""
import threading
import functools
import time
import logging

logging.basicConfig(level=logging.NOTSET, format='%(threadName)s %(message)s')

class PeriodicTimer(object):
	"""
	The class 

	input:
	  interval, callback

	"""
	def __init__(self, interval = 5, callback=None):
		self.interval = interval

		@functools.wraps(callback)
		def wrapper(*args, **kwargs):
			# print 'args %s kwargs %s' % (args, kwargs)
			result = callback(*args, **kwargs)

			if result:
				self.thread = threading.Timer(self.interval,
				                              self.callback)
				self.thread.start()

		self.callback = wrapper

	def start(self):
		self.thread = threading.Timer(self.interval, self.callback)
		self.thread.start()

	def cancel(self):
		self.thread.cancel()

def foo(a=100):
	logging.info('Doing some work...')
	print a
	return True

class myThread(threading.Thread):
	def __init__(self, threadID, name, counter):
		threading.Thread.__init__(self)
		self.threadID = threadID
		self.name = name
		self.counter = counter

	def run(self):
		print "Starting " + self.name
		# Get lock to synchronize threads
		threadLock.acquire()
		foo(5)
		threadLock.release()

threadLock = threading.Lock()
threads = []

# create new threads
thread1 = myThread(1, "Thread1", 1)
thread2 = myThread(2, "Thread2", 1)

# start new threads
thread1.start()
thread2.start()

# Add threads to thread list
threads.append(thread1)
threads.append(thread2)

# wait for all threads to complete
for t in threads:
	t.join()

print PeriodicTimer.__name__
print PeriodicTimer.__doc__
print PeriodicTimer.__module__

timer = PeriodicTimer(1, foo)
timer.start()
for i in range(2):
	time.sleep(2)
	logging.info('Hello')

timer.cancel()

