import glob
import os
import sys
import threading
import gdbm
print 2 + 3

class Writer:
 def __init__(self, message):
	self.message = message;
 def __call__(self):
	gdb.write(self.message)

class MyThread (threading.Thread):
 def run (self):
	gdb.post_event(Writer("World\n"))

MyThread().start()
