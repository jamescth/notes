#!/usr/bin/env python

import json
from contextlib import contextmanager
def convert_to_builtin_type(obj):
	print("defaut (%s)" % repr(obj))
	#d = { '__class__':obj.__class__.__name__,
	#		'__module__':obj.__module__,
	#}
	d = {'__class__':obj.__class__.__name__}
	d.update(obj.__dict__)
	return d

def dict_to_object(d):
	if '__class__' in d:
		class_name = d.pop('__class__')
		module_name = d.pop('__module__')
		module = __import__(module_name)
		print("MODULE: %s" % (module))
		class_ = getattr(module, class_name)
		print("CLASS: %s" % (class_))
		args = dict ((key.encode('ascii'), value) for key, value in d.items())
		print("INSTANCE ARGS: %s" % args) 
		inst = class_(**args)
	else:
		inst = d
	return d

def obj_to_json(obj):
	return json.dumps(obj, default=convert_to_builtin_type, indent=3)

@contextmanager
def ignored(*exceptions):
	try:
		yield
	except exceptions:
		pass
