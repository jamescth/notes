#!/usr/bin/env python
"""
The main script for logs screening.

TODO:
	bug 132602 - perf issue.  How to attack this kind of problem.
	bug 132569 - SPF+ issue.
	bug 132495 - SFP+

example:
	/auto/cores/c65592774$ ~/bin/py_log.py -d .

debug:
	python -m pdb ~/bin/py_log.py --dir=. --date=20141107093000 --ofile=/tmp/tt

Objective:

Needs something to automate the bug triage process.  The goal is
to reduce human labor involvement at max; for new or unknown 
symptoms only.

For any known issues, the tool should be able to triage and look 
up for the existing solution.  and most importantly, it gotta be
EASY to use & maintain.

In order to achieve the goal, the tool should be able to:
1. dig logs 
	a. eliminates any hw issue
	b. eliminates any kernel issue
	c. provide a registry diff before and after the incident.
	d. provide a list of CLIs had run right before the incident.
	e. diff on mem_log for ddr activities

	   how does the above translate to functional/object requirements in Python?
	   1. index for timestamp, line#, keywords so easily moving around the stream
	      is possible.
	   2. how many lines before & after keywords should be printed.
	   3. print out the content in certain duration.

	additional requests:
	users should be able to add, delete, modify the keywords EASILY. 
	additional os activities collections for live system???

2. provide perf triage guidline
	if item a is not able to root cause the issue, additional tasks
	are needed.

	1. check route
	2. iperf: to rule out line speed issue.
	3. tcpdump:

3. from the symptom, look up bugzilla for any known issue.


To do list:
1. finish all the date types in convert_input_date()

OO:
	__init__()
	__str__()
	get_filename()
	set_last_mtime()
	convert_input_date()
	show_dtime()
	run_log_analyze()
	show_line_content()
	get_ts_line_num()
	show_delta_time_content
	show_log_msg()
	diff()

TestCases:
	/auto/cores/130108/467344
	/auto/cores/129215

	/auto/cores/c68567232 bug 130284
		CET => CEST zone

	/auto/cores/c70193990 bug 136521
		the last file doesn't contain the issued date

	/auto/cores/c70069880 bug 135462
		rx_csum_offload_errors is non-zero
"""

import sys, getopt
import glob
import os
import logging
import stat
import datetime
import time
import re
import difflib

PATH_DDVAR = "/ddr/var/"
PATH_LOG = PATH_DDVAR+"log/"
PATH_SUPPORT = PATH_DDVAR+"support/"
PATH_DEBUG = PATH_LOG + "debug/"
PATH_PLATFORM = PATH_DEBUG + "platform/"
PATH_CRON = "/var/log/"

# Error msg we screening for kern.info
# ------- fix me -------   Should use dictionary and list for better query
# something like:
# reboot:['linux version', # lines before, # lines after]

# James: instead of symbols, we should use constants instead
# (Linux version, 1), (MSG-KERN, 2) ...
KERN = {
	# reboot
	"Linux version",
	# alert
	"MSG-KERN",
	"segfault",
	# kernel panics
	"Oops:",
	"kernel BUG",
	"NULL pointer",
	"Kernel panic",
	"Starting Livedump",
	"soft lockup",
	# kernel stack trace
	"Call Trace:",
	# user cores
	"elf_core_dump",
	"general protection",
	"Signal",
	# ext3
	"MSG-EXT3",
	"EXT3-fs error",
	# hw errors
	"rail out of limit",
	"APIC error",
	" FATAL:",
	"Machine check events logged",
	"IPMI Watchdog: response",
	"IPMI message handler:",
	"fuel gauge bad",
	"MEDIUM ERR",
	"Medium Error",
	"I/O error",
	"link is not ready",
	"Link is down",
	"Link is Down"
}

# Error msg we screening for message.engineering
MSG_ENG = {
	# reboot
	"booting up",
	"syslogd starting",
	# hw errors
	"host resolution timed out",
	"Corrected ECC error",
	"Correctable AER error",
	"Correctable ECC error",
	"BMC hang",
	"CATERR",
	"EVT-ENVIRONMENT",
	# alerts
	"MSG-DDR",
	"CRITICAL",
	"MSG-INTRNL"
	# check ddsh??
	# "MSG-DDSH"
}

MSG_SUP = {
	"MSG-ASUP",
	# Invalid non-interactive command
	"MSG-DDSH-00007",
	# exited with error code
	"MSG-DDSH-00017",
	"MSG-PMON"
}

# Error msg we screening for bios.txt
BIOS = {
	# hw errors
	"Correctable ECC",
	"0x86",
	" Processor CAT ERR",
	"AbnormalShutDown",
	"Watchdog 2",
	"IERR",
	"OEM",
	"SERR",
	"SMI",
	"Critical Interrupt"
}

CRON ={
	# reboot
	"(CRON) STARTUP",	# before 10 after 10

}

DDFS = {
	"MSG-INTRNL",
	"MSG-DDR"
}

# check ${SRC}/app/ddr/sm/autosupport/autosupport.report
ASUP = {
	"GENERAL INFO",
	"SERVER USAGE",
	# GENERAL STATUS
	"System Memory Summary",
	"Current Alerts",
	"Net Show Hardware",
	"Disk Status",
	"Filesys Verify Status",
	"NFS Status",
	"CIFS Status",
	"lw-status",
	"Replication Status",
	"NVRAM Status",
	# SOFTWARE CONFIGURATION
	# HARDWARE CONFIGURATION
	"Hardware VPD Information",
	"Net Show Config",
	"Net Show Settings",
	"Net Failover Show",
	"Net Aggregate Show",
	"Disk Show Hardware",
	"Detailed System PCI Info",
	"System Show Ports",
	"IPMI Show Config",
	"IPMI Show Hardware",
	# DETAILED STATISTICS
	# REGISTRY
	"config.mem.total",
	"config.timezone",
	"config.net",
	"dynamic.net",
	# SYSPARAMS
	# DETAILED FILESYSTEM LAYER
	# DETAILED NETWORK LAYER
	"Net Troubleshooting Duplicate-IP",
	"Net Show Stats",
	# DETAILED STORAGE LAYER
	"Storage Show All",
	"Disk Show State",
	"Disk Show Performance",
	"Disk Show Reliability-Data",
	"Disk Read Error History",
	"Read Verify Statistics",
	"Disk Logical Mapping Details",
	"Disk Show SCSI STATS",
	# ADDITIONAL INFORMATION
	# DDBOOST INFORMATION
	# CRASH INFORMATION
	"/ddr/var/core:",
	# "partition size: RFE",
	# PROCESSES
}

# what do we need for ethtool?
ETH = {
	"rx_fcs_errors",
	"rx_align_errors",
	"rx_frame_too_long_errors",
	"tx_mac_errors",
	"recoverable_errors",
	"unrecoverable_errors",
	"rx_errors",
	"tx_errors",
	"rx_csum_offload_errors",
	"rx_crc_errors"
	#"recoverable_errors",
	#"unrecoverable_errors"
}

TCP = {
	# flags
	'FIN',
	'RST',
	# buffer
	'window 0'
}

MEM = {
	"Output for ps",
	"Output for meminfo",
	"Output for free",
	"Output for slabinfo",
	"Output for select smaps"
}

def enum(**named_values):
	return type('Enum', (), named_values)

log_l = enum (
	NON = 0x00,
	OUT = 0x01,
	DEB = 0x02,
	INF = 0x04,
	WAR = 0x08,
	ERR = 0x10,
	CRI = 0x20
)

class DDLogFile(object):
	"""
	Class for Log File
	"""

	def __init__(self, date_type=0, idir = "not defined", fname = "not defined", pattern=None):
		"""
		DDLogFile constructor
		  1st param: the target path
		  2nd param: the target file name
		  3rd param: the pattern list to scan

		Internal data structure:

		  line_offset:

		    This is a list to store the offset value in the given file for each line
		    The fmt of the list is:
			( 0 //1st line offset, x //2nd line offset, ... )
			This field has the entire file line# offset; it's used for data mining

		  pattern_dic:

		    This is a dictionay to store the keyword line numbers
		    The format for the dict is:
			{'pattern':(1st occurance line#, 2nd, 3rd, ...)}
			We use the line# as an idx to point to line_offset (start from 0)


		Time: (use ipython)
			statbuf=os.stat('notes')
			statbuf
			datetime.datetime.fromtimestamp(statbuf.st_mtime).strftime('%Y-%m-%d %H:%M:%S')

			datetime.datetime.strptime('Feb', '%b')
			=> datetime.datetime(1900, 2, 1, 0, 0)

			time.strptime('Feb','%b').tm_mon

		time type:
			The timestamp for each log file veries.
			1. Jan 31 05:35:06		kern.info msg.eng cron msg.spt
			2. 12/15 12:36:56.673		ddfs.info infra.log
			3. Tue Jan 28 06:00:01 CET 2014 bios.txt
			   12/02/2014 | 13:16:19	bios.txt
			4. Tue Nov 4 18:07:29 2014..	tcp.log
			5. Tue Nov 4 17:00:01 PST 2014 mem.log ethtool_stats.log
			6. same as '5', but once a day	sutosupport

		"""
		self.__idir = idir
		self.__fname = fname
		self.__pattern = pattern
		self.__file_accessible = False
		self.__d_type = date_type
		self.__last_mtime = None
		self.__year_delta = 0 
		self.__cur_month = None
		self.__json_handle = None
		self.__ofile_handle = None

		"""
		The fmt of line_offset is:
		  [oft for line 0, oft for line 1, oft for line 2, ...]
		  For example:
		    [0, 80, 264, ...]
		"""
		self.line_offset = []

		"""
		The format of this dict is {date_string:int}
		"""
		self.dtime_offset = dict()

		"""
		The format for the dict is {string: (list)}:
		  {'pattern':(1st occurance line#, 2nd, 3rd, ...)}.
		  For example:
		    {'Linux version':(2, 1730, 3423), 'Call Trace:':(38810,38856)}
		  We use the line# as an idx to point to line_offset (start from 0)
		"""
		# self.pattern_dic = {}
		self.pattern_dic = dict()

		# run log analyze by default??
		# this has the side effect to its child
		# We probably want to leave the child to have freedom modifying
		# run_log_analyze() instead of calling it here

		# self.run_log_analyze()

	def __str__(self):
		"""
		print the object will get the path+filename
		"""
		return self.__idir + self.__fname

	def __print(self, log_level = 0, *args, **kwargs):
		if self.__ofile_handle is not None:
			ofile_handle.write(args[0] + '\n')

		if log_level & log_l.OUT:
			# print(args[:])
			print(args[0]) 
		elif log_level & log_l.DEB:
			py_logger.debug(args[0])
		elif log_level & log_l.INF:
			py_logger.info(args[0])
		elif log_level & log_l.WAR:
			py_logger.warning(args[0])
		elif log_level & log_l.CRI:
			py_logger.critical(args[0])

	def get_filename(self):
		"""
		return the object will get the path+filename
		"""

		return self.__idir + self.__fname

	def set_last_mtime(self, date):
		self.__last_mtime = date

	def convert_input_date(self, d_type, str_arg1):
		"""
		convert month from abbreviated name to number
		for example:
			Jan => 01
			Feb => 02
			Dec => 12

		if the format is different from "Feb  4 05:32:14", it will reture None.
		"""
		abbr_month='(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)'
		abbr_wkday='(Mon|Tue|Wed|Thu|Fri|Sat|Sun)'
		re_fmt=""
		dt_fmt=""

		if (d_type == 1):
			"""
			Jan 31 05:35:06 => 0131053506
			"""
			re_fmt='^'+abbr_month+'\s{1,2}\d{1,2}\s\d{2}:\d{2}:\d{2}'
			# dt_fmt = '%b %d %H:%M:%S'
			dt_fmt = '%b %d %H:%M:%S%Y'
		elif (d_type == 2):
			"""
			01/31 05:35:06.294 => 0131053506
			"""
			re_fmt = '^\d{2}/\d{2}\s\d{2}:\d{2}:\d{2}'
			#dt_fmt = '%m/%d %H:%M:%S'
			dt_fmt = '%m/%d %H:%M:%S%Y'
		elif (d_type == 4):
			"""
			Tue Nov 4 18:07:29 2014
			"""
			re_fmt = '^'+abbr_wkday+'\s'+abbr_month+'\s{1,2}\d{1,2}\s\d{2}:\d{2}:\d{2}\s\d{4}'
			dt_fmt = '%a %b %d %H:%M:%S %Y'
		elif (d_type == 5):
			"""
			Tue Nov 4 17:00:01 PST 2014
			ethtool_log is @ begining of the ling, but, mem_log is not.  So, we don't use '^'

			we don't handle year any way.  ignore zone and year due to bug in zone
			"""
			# re_fmt = abbr_wkday+'\s'+abbr_month+'\s{1,2}\d{1,2}\s\d{2}:\d{2}:\d{2}\s\w{3}\s\d{4}'
			# dt_fmt = '%a %b %d %H:%M:%S %Z %Y'
			re_fmt = abbr_wkday+'\s'+abbr_month+'\s{1,2}\d{1,2}\s\d{2}:\d{2}:\d{2}'
			dt_fmt = '%a %b %d %H:%M:%S'
		elif (d_type == 6):
			"""
			GENERATED_ON=Fri Nov  7 06:21:20 PST 2014

			we don't handle year any way.  ignore zone and year due to bug in zone
			"""
			# re_fmt = 'GENERATED_ON='+abbr_wkday+'\s'+abbr_month+'\s{1,2}\d{1,2}\s\d{2}:\d{2}:\d{2}\s\w{3}\s\d{4}'
			# dt_fmt = '%a %b %d %H:%M:%S %Z %Y'
			re_fmt = 'GENERATED_ON='+abbr_wkday+'\s'+abbr_month+'\s{1,2}\d{1,2}\s\d{2}:\d{2}:\d{2}'
			dt_fmt = '%a %b %d %H:%M:%S'
		else:
			return (None,None)

		try:
			mat = re.search(re_fmt, str_arg1)
			if mat is not None:
				"""
				REVISIT: datetime will raise an error on Feb 29 for leap year
				ValueError: day is out of range for month
				"""
				# print(mat.group(0))
				if d_type == 6:
					# for asup, we need to get rid of 'GENERATED_ON='
					dt = datetime.datetime.strptime(mat.group(0)[13:], dt_fmt)
				elif d_type == 5:
					dt = datetime.datetime.strptime(mat.group(0), dt_fmt)
				elif d_type == 1 or d_type == 2:
					# this is a hack.  Assign a leap year first
					dt = datetime.datetime.strptime(mat.group(0) + '2012', dt_fmt)
				else:
					dt = datetime.datetime.strptime(mat.group(0), dt_fmt)

				# return ('%02d%02d%02d%02d%02d' % (dt.month, dt.day, dt.hour, dt.minute, dt.second))
				return ('%02d' % (dt.month), '%02d%02d%02d%02d' % (dt.day, dt.hour, dt.minute, dt.second))

		except ValueError:
			self.__print((log_l.OUT | log_l.ERR), 'd_type %d str_arg1 %s re_fmt %s dt_fmt %s' %
					(d_type, str_arg1, re_fmt, dt_fmt))
			exit(1)

		return (None,None)

	def show_dtime(self):
		"""
		Print the timestamp index for debug purpose
		"""
		for key, value in sorted(self.dtime_offset.items()):
			# print("date %s line %d" % (key, self.dtime_offset[key][0]))
			 self.__print(log_l.OUT, "date %s line %d" % (key, value))

	def run_log_analyze(self):
		"""
		After a DDLogFile object is created, it should run this procudure first.

		This produce is to do 3 things:
		1. it scan the log file.
		2. For every pre-defined pattern, it will store the line# for every occurance
		   in pattern_dic.
		3. For every single line, the function stores its offset in line_offset.


		James: CAN WE multi-thread this one?
		"""
		# make sure it's a file
		if not os.path.isfile(self.__idir+self.__fname):
			self.__print((log_l.OUT | log_l.ERR), "file doesn't exist: %s" % self.get_filename())
			return

		# make sure it's accessible
		if not os.access(self.__idir+self.__fname, os.R_OK):
			self.__print((log_l.OUT | log_l.ERR), "file is not readable: %s" % self.get_filename())
			return

		# store the last modify time of the file.
		statbuf=os.stat(self.__idir+self.__fname)
		self.__last_mtime = datetime.datetime.fromtimestamp(statbuf.st_mtime).strftime('%Y%m%d %H:%M:%S')
		# self.__last_mtime = datetime.datetime.fromtimestamp(statbuf.st_mtime).strftime('%Y')
		self.__print(log_l.OUT, "last modify time is %s" % self.__last_mtime)

		offset = 0
		tmp_year = "00"

		self.__print(log_l.OUT, "Working on %s" % (self.__idir+self.__fname))

		with open(self.__idir+self.__fname, 'r') as temp_file:
			for line_num, line in enumerate(temp_file, 1):
				#line = line [:-1]

				# add the offset # to the array
				self.line_offset.append(offset)

				# should I use map() instead for perf optimization?
				# self.line_offset = map(lambda x:offset + len(line), self.line_offset)

				# pattern looks up.
				for ss in self.__pattern:
					if ss in line:
						if self.pattern_dic.get(ss) is None:
							# a new pattern is discovered
							self.pattern_dic.update({ss:[line_num]})
							#print self.pattern_dic
						else:
							# append the new line number in the existing pattern array
							self.pattern_dic[ss].append(line_num)
							#print self.pattern_dic

				# process timestamp
				ret_month, ret_date = self.convert_input_date(self.__d_type, line)
				# print("month %s, date %s line %s" % (ret_month, ret_date, line))

				if ret_date is not None and ret_month is not None:
					"""
					we get month and the rest of date in ret_date.
					for example, Dec 19 05:16:08 => '12' and '19051608'

					We need to calculate the year here w/out the year info in the line.
					since we can only read the file top down, we need to know how many 
					year the log file contains.

					for example,
						02 03 => 000203
						08 22 => 000822
						01 11 => 010111 year advnced due the month is smaller than prev. one
						11 22 => 011122
						02 23 => 020223 year advanced again

						and if the last modify is 2014 02 23,
						then getting 2013 will be 2014 - 2013 = '02'xxxx - 1 = '01'xxxx
						             2012 will be 2014 - 2012 = '02'xxxx - 2 = '00'xxxx
					"""
	
					# self.dtime_offset.append(ret_date)
					if (self.__d_type == 1) or (self.__d_type == 2):
						if self.__cur_month is not None:
							"""
							for certain date type (like kern.info or ddfs), 
							we don't have the year info.  So, we have to 
							calculate if the year # increment after Dec.
							"""
							if ret_month < self.__cur_month:
								self.__year_delta += 1
								tmp_year = str("%02d" % self.__year_delta)

						self.__cur_month = ret_month

					ret_date = tmp_year + ret_month + ret_date

					if self.dtime_offset.get(ret_date) is None:
						"""
						for debug purpose, put the line # 
						using offset should reduce the overhead for lookup
						"""
						# self.dtime_offset.update({ret_date:[offset]})
						# self.dtime_offset.update({ret_date:[line_num]})
						self.dtime_offset[ret_date] = line_num
					
				offset += len(line)
				#print("%6s %8s %s" % (line_num, self.offset, line[:-1]))

		 	self.__file_accessible = True

		return

	def show_line_content(self, start_line, total_lines):
		"""
		This function print the content of the file.
 
		It takes 2 parameters:
		1. the starting line to print.
		2. how many lines to print
		"""

		with open(self.__idir+self.__fname, 'r') as ifile:
			while (total_lines > 0):
				temp_offset = self.line_offset[start_line-1]
				ifile.seek(temp_offset,0)

				self.__print(log_l.OUT, "%s" % (ifile.readline()[:-1]))
				total_lines -= 1
				start_line += 1


	def get_ts_line_num(self, dtime_input = None, pos = 0):
		"""
		The func is to return the line # of the first timestamp wihch is greater
		than the given one.

			print(mem_log.get_ts_line_num("20141104170000"))
			=> ('20141104170001', 2)
			print(mem_log.get_ts_line_num("20141104170030"))
			=> ('20141104173001', 2772)
		"""

		if not self.__file_accessible:
			self.__print(log_l.OUT, "%s is not accessible" % self.get_filename())
			return (None, None)

		if self.dtime_offset == None:
			return (None, None)

		# let's sort the dict based on timestamp
		dtime_list = sorted(self.dtime_offset.items())
		
		dtime_key = None
		dtime_value = None

		if (dtime_input is None):
			# default is the last timestamp in the file
			dtime_key, dtime_value = dtime_list[-1]
		else:
			# calculate year
			# If the last modtime is 2014, and we are asking for 2013, the delta is 1
			year_delta = int(self.__last_mtime[0:4]) - int(dtime_input[0:4])
			# put 1 back as a string '01' plus the rest of the date
			lookup_date = ("%02d" % (self.__year_delta - year_delta)) + dtime_input[4:]

			if lookup_date < dtime_list[0][0]:
				# if the lookup date is smaller than the ealiest timestamp, 
				# return the 1st timestamp
				dtime_key, dtime_value = dtime_list[0]

			elif lookup_date > dtime_list[-1][0]:
				# if the lookup date is bigger than the last timestamp
				# return the last timestamp
				dtime_key, dtime_value = dtime_list[-1]
			else:
				# walkthrough the timestamp
				# for dtime_key, dtime_value in dtime_list:
				length = len(dtime_list)
				for index in range(length):
					if lookup_date <= dtime_list[index][0]:
						if (((index+pos) >= length) or ((index+pos) < 0)):
							self.__print(log_l.OUT, "%s timestamp index %d +/- pos %d is out of range" \
							      % (self.get_filename(), index, pos))
							self.__print(log_l.OUT, "use %s for now" % dtime_list[index][0])

							self.__print(log_l.INF, '%s index %d pos %d len %d\ndtime_list %s' %
									(self.get_filename(), index, pos, length, dtime_list))

							dtime_key, dtime_value = dtime_list[index]
						else:
							dtime_key, dtime_value = dtime_list[index + pos]
						break

		if dtime_key is None:
			self.__print((log_l.OUT | log_l.ERR),'Error: %s lookup_date %s dtime_list %s' %
					(self.get_filename(), lookup_date, dtime_list))
			sys.exit(1)

		# the 1st 2 digs from the key is the delta yr to the last modify time
		# so we use the last modify time's year minus the delta
		# for example, last modify yr is 2014, the delta is 01, then, yr = 2013
		yr = int(self.__last_mtime[0:4]) - int(dtime_key[0:2])
		return (str(yr) + dtime_key[2:], dtime_value)

	def show_delta_time_content(self, dtime=None, hour=0, minute=0, second=0):
		"""
		Calculate the delta time.  The input hour/minute/second can be a positive or 
		negative value.

		return to caller in a string format 'YearMonthDayHourMinuteSecond'
		"""
		fmt='%Y%m%d%H%M%S'

		if not self.__file_accessible:
			self.__print((log_l.OUT | log_l.ERR), "%s is not accessible" % self.get_filename())
			return

		dt1, l1 = self.get_ts_line_num(dtime, 0)

		if (self.__d_type == 5):
			dt2, l2 = self.get_ts_line_num(dtime, -1)
		else:
			# delta_time = del_time_cal(dtime, hour, minute, second)
			tmp_time=datetime.datetime.strptime(dtime, fmt)
			dt = tmp_time + datetime.timedelta(hours=hour,minutes=minute,seconds=second)
			delta_time = ('%04d%02d%02d%02d%02d%02d' % \
				(dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second))

			dt2, l2 = self.get_ts_line_num(delta_time, 0)

			if dt1 == dt2:
				# if the gap is not big enough, get the previous one to show something
				dt2, l2 = self.get_ts_line_num(delta_time, -1)

		py_logger.info('file %s dtime %s hour %d, minute %d second %d dt1 %s dt2 %s l1 %d l2 %d',
				self.get_filename(), dtime, hour, minute, second, dt1, dt2, l1, l2)

		if ofile_handle is not None:
			ofile_handle.write("\n***** %s %s/%s/%s %s:%s:%s - %s/%s/%s %s:%s:%s*****\n" %
				(self.get_filename(),
				 dt2[0:4],dt2[4:6],dt2[6:8],dt2[8:10],dt2[10:12],dt2[12:14],
				 dt1[0:4],dt1[4:6],dt1[6:8],dt1[8:10],dt1[10:12],dt1[12:14]))
		else:
			self.__print(log_l.OUT, ("\n***** %s %s/%s/%s %s:%s:%s - %s/%s/%s %s:%s:%s*****" %
				(self.get_filename(),
				 dt2[0:4],dt2[4:6],dt2[6:8],dt2[8:10],dt2[10:12],dt2[12:14],
				 dt1[0:4],dt1[4:6],dt1[6:8],dt1[8:10],dt1[10:12],dt1[12:14])))

		if dt1 == dt2:
			self.__print(log_l.ERR, "time delta is too small")
		else:
			self.show_line_content(l2, l1-l2)

	def diff(self, dtime=None):
		"""
		use os.system('diff <file1> <file2>') first.  optimize it later.
		"""
		if not self.__file_accessible:
			self.__print((log_l.OUT | log_l.ERR), "%s is not accessible" % self.get_filename())
			return

		if dtime is None:
			return

		# mem_log.show_delta_time_content(dtime, hour, minute, second)
		# mem_log.show_log_msg()
		# print(mem_log.get_ts_line_num("20141104170000"))

		# print(mem_log.get_ts_line_num("20141107113000", -1))
		# print(mem_log.get_ts_line_num(dtime))

		prev_ts, line1 = self.get_ts_line_num(dtime, -1)
		curr_ts, line2 = self.get_ts_line_num(dtime)

		py_logger.info('%s prev_ts %s line1 %d curr_ts %s line2 %d',
				self.get_filename(), prev_ts, line1, curr_ts, line2)

		with open("/tmp/james00001", "w") as temp_file1, \
		     open("/tmp/james00002", "w") as temp_file2:
			self.show_delta_time_content(temp_file1, prev_ts)
			self.show_delta_time_content(temp_file2, curr_ts)

		with open("/tmp/james00001", "r") as temp_file1, \
		     open("/tmp/james00002", "r") as temp_file2:

			diff = difflib.ndiff(temp_file1.readlines(), temp_file2.readlines())
			delta = ''.join(x[:] for x in diff if x[0] != ' ')
			# delta = ''.join(diff)

			if ofile_handle is not None:
				ofile_handle.write("%s diff from %s - %s" %
					 (self.get_filename(), prev_ts, curr_ts))
				ofile_handle.write(delta)

		#os.system("diff /tmp/james00001 /tmp/james00002")

	def show_log_msg(self, str_query="py_all", b4_lines=0, after_lines=0):
		"""
		This function is to print the content of the file
		
		parameters:
			1. str_query: It's the keyword of the dictionary
			2. b4_lines: how many lines before the keyword we want to print
			3. after_lines: how many lines after the keyword we want to print
		
		usage:
			<file>.show_log_msg()
			<file>.show_log_msg("config.mem.total")
			<file>.show_log_msg('Call Trace:', 0, 20)
		"""

		py_logger.info('str_query %s b4_lines %d after_lines %d',
				str_query, b4_lines, after_lines)

		if not self.__file_accessible:
			self.__print((log_l.OUT | log_l.ERR), "%s is not accessible" % self.get_filename())
			return

		if (str_query == "py_all"):
			for key, line_list in self.pattern_dic.items():
				self.__print(log_l.OUT, "\n******** %s Searching pattern:%s ********" % \
					(self.get_filename(), key))

				for idx in line_list:
					self.show_line_content(idx, 1)

				if ofile_handle:
					ofile_handle.write("\n")
				else:
					self.__print(log_l.OUT, "")

		elif str_query in self.pattern_dic:
			"""
			If pattern is matched in the dict, read the line #.
			if we want to print lines before the pattern, set the start line ahead.
			if we want to print lines after the patern, set the end line after.
			print the content in between.
			"""
			line_list = self.pattern_dic[str_query]

			self.__print(log_l.OUT, "\n******** %s Searching pattern:%s ********" % 
				(self.get_filename(), str_query))

			total_lines = 1
			start_line = 0

			for idx in line_list:
				if b4_lines != 0:
					"""
					if we want to print lines before the selected pattern, 
					we need to calculate line#
					"""
					if (idx - b4_lines) <= 1:
						start_line = 1
						tatol_lines = idx
					else:
						start_line = idx - b4_lines
						total_lines += b4_lines
				else:
					start_line = idx

				if after_lines != 0:
					"""
					calculate line # if we want lines AFTER the selected pattern
					"""
					max_line = len(self.line_offset)
					if (idx+after_lines) > max_line:
						total_lines += (max_line - idx)
					else:
						total_lines += after_lines

				self.show_line_content(start_line,total_lines)
			"""
			if ofile_handle:
				ofile_handle.write("\n")
			else:
				py_print("")
			"""
		else:
			self.__print((log_l.OUT | log_l.ERR), '******** "%s" keyword not found ********' % str_query)

