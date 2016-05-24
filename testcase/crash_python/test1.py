import sys
import gdb
gdb.execute("file " + sys.argv[1])
type = gdb.Type (sys.argv[0])
print "sizeof %s = %d" % (sys.argv[0], type.sizeof ())
