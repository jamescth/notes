#!/usr/bin/env python
"""
	return multiple items
"""

def simple_function():
	print "I am from simple_function"
	a = 5
	b = "string"
	c = 3.14
	d = [1,2,3]
	return (a, b, c, d)

#ra, rb, rc, rd = simpel_function()

# the above 1 line is equal to 6 lines

q = simple_function()
ra = q[0]
rb = q[1]
rc = q[2]
rd = q[3]
del q

print "the value of ra: ", ra
print "the value of rb: ", rb
print "the value of rc: ", rc
print "the value of rd: ", rd

