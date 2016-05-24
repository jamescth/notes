#!/usr/bin/env python
"""
Don't know yet

To test Statement, which is defined in Statement_test():
	python -m doctest -v py_file.py
	or
	python -m doctest py_file.py

	python -m trace --trace --timing ./py_file.py | grep py_file

	to run:
	./py_file.py
"""
from fabric.api import *
import timeit

class Statement(object):
	"""
	A statment obj/line for test.
	for example, 'net ddns enable' is a statement
	"""
	def __init__(self, content=None, result=None):
		self.__content = content
		self.__result = result

	# content
	def st_get_content(self):
		return self.__content
	def st_set_content(self, content):
		self.__content = content
	content = property(st_get_content, st_set_content)

	# result
	def st_get_result(self):
		return self.__result
	def st_set_result(self, result):
		self.__result = result
	result = property(st_get_result, st_set_result)

	def __str__(self):
		return ('%s %s' % (self.__content, self.__result))

	def _exec_remote_cmd(self, cmd):
		"""
		This function is to replace 'run()'.  
		It hides the output from run(), and disable exception as well.
		return value:
			.succeeded:
				True: No error
				False: error occurs
		"""
		with hide('output','running','warnings'), settings(warn_only=True):
			return run(cmd)

	def st_run(self, output=True):
		#env.user='root'
		#env.password='abc123'
		#env.host_string = 'aclddw01.datadomain.com'
		#print "ENV %s" %(env.hosts)

		start = timeit.default_timer()

		if output:
			output = run(self.__content)
		else:
			output = self._exec_remote_cmd(self.__content)

		stop = timeit.default_timer()

		if None != self.__result:
			if -1 == output.find(self.__result):
				raise Exception('"%s" does not find in the output' % (self.__result))

		print "%3d seconds: %s" % ((stop - start), self.__content)

		return output

class TestCase(object):
	"""
	TestCase Obj
	"""
	def __init__(self, name=None, positive=True):
		self.__name = name
		self.__positive = positive
		self.statements = []
	def __str__(self):
		return self.__name

	def tc_set_pos(pos=True):
		self.__positive = pos
	def tc_get_pos():
		return self.__positive
	def tc_add_statement(self, statement):
		self.statements.append(statement)
	def tc_show_statements(self):
		for statement in self.statements:
			print statement

	def tc_show_all(self):
		print self.__name
		self.tc_show_statements()

	def tc_run(self, output=True):
		for statement in self.statements:
			statement.st_run(output)

class MyFile(object):
	"""
	File object
	"""
	def __init__(self, name=None, mode='r'):
		# super.__init__(self)
		self.__name = name
		self.__local = True
		self.__mode = mode
		self.file = None

	def read(self):
		if self.__name == None:
			print "file name is not set"
			return None
		if self.__mode != 'r':
			print "file mode is not readable"
			return None

		with open(self.__name, self.__mode) as f:
			return f.read()

	def write(self, content):
		if self.__name == None:
			print "file name is not set"
			return None

		if self.__mode != 'w':
			print "file mode is not writable"
			return None
		
		with open(self.__name, self.__mode) as f:
			return f.write(content)

	def set_mode(self, mode='r'):
		self.__mode = mode
	def get_mode(self):
		return self.__mode

	def set_local(self, local=True):
		self.__local = local
	def get_local(self):
		return self.__local

	def parsing(self):
		print "generic parsing func.  You gotta re-write this func"

class MyLogFile(MyFile):
	"""
	Remote Log File Obj
	"""
	def __init__(self, name=None, mode='r', local=False):
		super(MyTestFile,self).__init__(name, mode)
		super(MyTestFile,self).set_local(local)
		self.__size = 0

	def mlf_get_size(self):
		size = run('stat -c %%s %s' % self.__name)
		slef.__size = size

class MyTestFile(MyFile):
	"""
	Test File Obj
	"""
	def __init__(self, name=None, mode='r'):
		super(MyTestFile,self).__init__(name, mode)
		tests = []

	def parsing(self):
		test = None
		for line in self.read().split('\n'):
			test_str = 'TEST:'
			if 0 == line.find(test_str):
				#print 'test find'
				test = TestCase(line[len(test_str):], True)
				continue

			if test == None:
				print "No 'TEST' keyword found"
				return

			cmd_str = 'CMD:'
			exp_str = 'EXPECT:'
			cmd_loc = line.find(cmd_str)
			exp_loc = line.find(exp_str)

			# skip the line without CMD which includes comments & blanks
			if -1 == cmd_loc:
				continue

			# if don't care output
			if -1 == exp_loc:
				test.tc_add_statement(Statement(line[len(cmd_str):]))
			else:
				test.tc_add_statement(Statement(line[len(cmd_str):(exp_loc-1)],
				                             line[exp_loc+len(exp_str):]))

		test.tc_show_all()
		tests.append(test)

	def mtf_run(self):
		for test in tests:
			test.tc_run(output=False)

def _test_Stetement():
	"""
	>>> st = Statement("net ddns enable", "hello")
	>>> print st.get_content()
	net ddns enable
	>>> print st.content
	net ddns enable
	>>> print st.get_result()
	hello
	>>> print st
	net ddns enable hello 1
	>>> del st
	"""

def _test_TestCase():
	"""
	>>> test = TestCase("hello")
	>>> test.add_statement(Statement("net ddns enable", "hello"))
	>>> test.add_statement(Statement("net ddns show", "no no no"))
	>>> test.show_statements()
	net ddns enable hello 1
	net ddns show no no no 1
	>>> del test
	"""

tests = []

"""
test = TestCase("hello")
test.add_statement(Statement("net ddns enable", "hello"))
test.add_statement(Statement("net ddns show", "no no no"))
test.show_statements()
del test
"""

env.user='root'
env.password='abc123'
env.host_string = 'aclddw01.datadomain.com'
# print "ENV %s" %(env.hosts)

f = MyTestFile(name="dd_tests", mode='r')
f.parsing()
f.mtf_run()

del f
