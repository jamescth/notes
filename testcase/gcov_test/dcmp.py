#!/usr/bin/env python
"""

"""
import re
import filecmp
import difflib

PATH426 = "/auto/home5/hoj9/dhcp-4.2.6/"
PATH432 = "/auto/home5/hoj9/dhcp-4.3.1/"

def print_diff_files(dcmp, output):
	for name in dcmp.diff_files:
		if (re.findall('/test/', name)):
			continue
		if (re.findall('\.[ch]\Z|\.gcov\Z', name)):
			# print "diff_file %s found in %s %s" % (name, dcmp.left, dcmp.right)
			output.write("%s/%s\n" % (dcmp.left, name))

			with open(("%s/%s") % (dcmp.left, name)) as left, open(("%s/%s") % (dcmp.right, name)) as right:
			
				diff = difflib.Differ()
			
				diff = difflib.ndiff(left.readlines(), right.readlines())
				delta = ''.join(x for x in diff if x.startswith('- ') or x.startswith('+ '))
				output.write(delta)

		# dcmp.report()

	for sub_dcmp in dcmp.subdirs.values():
		print_diff_files(sub_dcmp, output)

def main():
	dcmp = filecmp.dircmp(PATH426, PATH432, ["server"])
	# dcmp.report_full_closure()
	output = open('./result', 'w')
	print_diff_files(dcmp, output)
	output.close()

if __name__ == '__main__':
	main()
