#! /bin/bash
SPBDL_DIR=$1

# log file in /ddr/var/log
MSG=

# log file in /ddr/var/log/debug
DDFS_INFO=
MSG_ENGINEERING=
MSG_SPP=
REGISTRY=
TCP=

# log file in /ddr/var/log/debug/platform
KERN_INFO=
MEM_USG=
INFRA_LOG=
BIOS_TXT=
ETHTOOL=

# log file in /ddr/var/support
AUTOSUPPORT=

# log file in /var/log
CRON=

# use 'ipmitool sel readraw /ddr/var/log/debug/platform/ipmi_sel.raw -vv'
IPMI_SEL=

# set -x

# check if the given support bundle directory exists
if [ ! -d "$SPBDL_DIR" ]; then
	echo directory ${SPBDL_DIR} does not exist
#	exit 1
fi

# check a bunch of other directories
if [ ! -d "${SPBDL_DIR}/var/log" ]; then
	echo directory ${SPBDL_DIR}/var/log does not exist
#	exit 1
else
	if [ -f "${SPBDL_DIR}/var/log/cron" ]; then
		CRON="${SPBDL_DIR}/var/log/cron"
	else
		echo "cron doesn't exist"
	fi
fi

if [ ! -d "${SPBDL_DIR}/ddr/var/support" ]; then
	echo directory ${SPBDL_DIR}/ddr/var/support does not exist
#	exit 1
else
	if [ -f "${SPBDL_DIR}/ddr/var/support/autosupport" ]; then
		AUTOSUPPORT="${SPBDL_DIR}/ddr/var/support/autosupport"
	else
		echo "autosupport doesn't exist"
	fi
fi

# check a bunch of other directories
if [ ! -d "${SPBDL_DIR}/ddr/var/log" ]; then
	echo directory ${SPBDL_DIR}/ddr/var/log does not exist
#	exit 1
fi

# check ddr/var/log/debug & log files
if [ ! -d "${SPBDL_DIR}/ddr/var/log/debug" ]; then
	echo directory ${SPBDL_DIR}/ddr/var/log/debug does not exist
#	exit 1
fi

if [ ! -f "${SPBDL_DIR}/ddr/var/log/debug/messages.engineering" ]; then
	echo file ${SPBDL_DIR}/ddr/var/log/debug/messages.engineering does not exist
else
	MSG_ENGINEERING="${SPBDL_DIR}/ddr/var/log/debug/messages.engineering"
fi

if [ ! -f "${SPBDL_DIR}/ddr/var/log/debug/ddfs.info" ]; then
	echo file ${SPBDL_DIR}/ddr/var/log/debug/ddfs.info does not exist
else
	DDFS_INFO="${SPBDL_DIR}/ddr/var/log/debug/ddfs.info"
fi

if [ ! -f "${SPBDL_DIR}/ddr/var/log/debug/messages.support" ]; then
	echo file ${SPBDL_DIR}/ddr/var/log/debug/messages.support does not exist
else
	MSG_SPP="${SPBDL_DIR}/ddr/var/log/debug/messages.support"
fi

if [ ! -f "${SPBDL_DIR}/ddr/var/log/debug/registry.sub" ]; then
	echo file ${SPBDL_DIR}/ddr/var/log/debug/registry.sub does not exist
else
	REGISTRY="${SPBDL_DIR}/ddr/var/log/debug/registry.sub"
fi

if [ ! -f "${SPBDL_DIR}/ddr/var/log/debug/tcp.log" ]; then
	echo file ${SPBDL_DIR}/ddr/var/log/debug/tcp.log does not exist
else
	TCP="${SPBDL_DIR}/ddr/var/log/debug/tcp.log"
fi

# check ddr/var/log/debug/platform & log files
if [ ! -d "${SPBDL_DIR}/ddr/var/log/debug/platform" ]; then
	echo directory ${SPBDL_DIR}/ddr/var/log/debug/platform does not exist
#	exit 1
fi

# get kern.info
if [ ! -f "${SPBDL_DIR}/ddr/var/log/debug/platform/kern.info" ]; then
	echo file ${SPBDL_DIR}/ddr/var/log/debug/platform/kern.info does not exist
else
	KERN_INFO="${SPBDL_DIR}/ddr/var/log/debug/platform/kern.info"
fi

# get bios.txt
if [ ! -f "${SPBDL_DIR}/ddr/var/log/debug/platform/bios.txt" ]; then
	echo file ${SPBDL_DIR}/ddr/var/log/debug/platform/bios.txt does not exist
else
	BIOS_TXT="${SPBDL_DIR}/ddr/var/log/debug/platform/bios.txt"
fi

if [ ! -f "${SPBDL_DIR}/ddr/var/log/debug/platform/memory_usage.log" ]; then
	echo file ${SPBDL_DIR}/ddr/var/log/debug/platform/memory_usage.log does not exist
else
	MEM_USG="${SPBDL_DIR}/ddr/var/log/debug/platform/memory_usage.log"
fi

if [ ! -f "${SPBDL_DIR}/ddr/var/log/debug/platform/infra.log" ]; then
	echo file ${SPBDL_DIR}/ddr/var/log/debug/platform/infra.log does not exist
else
	INFRA_LOG="${SPBDL_DIR}/ddr/var/log/debug/platform/infra.log"
fi

if [ ! -f "${SPBDL_DIR}/ddr/var/log/debug/platform/ethtool_stats.log" ]; then
	echo file ${SPBDL_DIR}/ddr/var/log/debug/platform/ethtool_stats.log does not exist
else
	ETHTOOL="${SPBDL_DIR}/ddr/var/log/debug/platform/ethtool_stats.log"
fi

echo "********************************************************"
echo "MSG.ENG:   ${MSG_ENGINEERING}"
echo "DDFS.INFO: ${DDFS_INFO}"
echo "MSG.SPP:   ${MSG_SPP}"
echo "REG.SUB:   ${REGISTRY}"
echo "TCP:       ${TCP}"
echo "KERN.INFO: ${KERN_INFO}"
echo "BIOS.OUT:  ${BIOS_TXT}"
echo "MEM.USG:   ${MEM_USG}"
echo "INFRA.LOG: ${INFRA_LOG}"
echo "ETHTOOL.S: ${ETHTOOL}"
echo "AUTOSPP:   ${AUTOSUPPORT}"
echo "CRON:      ${CRON}"
echo
echo "********************************************************"
echo "Show sys info"
echo "********************************************************"

if [ -z "${AUTOSUPPORT}" ]; then
	echo AUTO SUPPORT is empty
else
	grep -m 1 -A9 "GENERAL INFO" ${AUTOSUPPORT}
	echo
	grep -m 1 -A20 "GENERAL STATUS" ${AUTOSUPPORT}
	#echo "Memory: this is not the info when panic occured, RFE"
	#grep -m 1 -e "MemTotal" ${MEM_USG}
	#grep -m 1 -e "MemFree" ${MEM_USG}
	#grep -m 1 -e "SwapTotal" ${MEM_USG}
	#grep -m 1 -e "SwapFree" ${MEM_USG}
	echo
	# bug 84305
	grep -m 1 "config.mem.total" ${AUTOSUPPORT}
	echo
	echo "partition size: RFE"
	grep -A15 "/ddr/var/core:" ${AUTOSUPPORT}
	echo
	echo "GMT Time:"
	grep -e "config.timezone" ${AUTOSUPPORT}
	grep -e "config.net.dns" ${AUTOSUPPORT}
	grep -e "config.log.hosts" ${AUTOSUPPORT}
	grep -e "config.nis.domainname" ${AUTOSUPPORT}
	grep -e "config.nis.enable" ${AUTOSUPPORT}
	grep -e "config.nis.servers" ${AUTOSUPPORT}

fi
echo
echo "********************************************************"
echo "Verify if there is HW error"
echo "********************************************************"
if [ -z "${MSG_ENGINEERING}" ]; then
	echo messages.engineering is empty
else
	echo "messages.engineering"
	#bug86913 BMC hang
	#bug101648 CATERR or EVT-ENVIRONMENT-00011
	#bug92688 host resolution timeout.  Need to check nis setting in autosupport as well. config.nis
	grep -e "host resolution timed out" -e "Corrected ECC error" -e " Correctable AER error" -e "Correctable ECC error" -e "BMC hang" -e "CATERR" -e "EVT-ENVIRONMENT" ${MSG_ENGINEERING}
	grep "MSG-DDSH-00009" ${MSG_ENGINEERING} | awk -F':' '{ print $1, $2, $3, $7}' | grep net > cli_net.out
fi
echo
echo "======================================="
echo "kern.info"
# bug84018: NVRAM => check_fatal_local_pci_errors: FATAL:
# bug93607: APIC error
# check_fatal_local_pci_errors may appear if IPMI hard reset or power on/off (need judgement)
# bug86489: NVRAM0: 1.05V rail out of limit
# causing ddfs/kernel panic
grep -e "rail out of limit" -e "APIC error" -e " FATAL:" -e "Machine check events logged" -e "IPMI Watchdog: response" -e "IPMI message handler:" -e "fuel gauge bad" -e "MEDIUM ERR" -e "Medium Error" -e "I/O error" ${KERN_INFO}
echo
echo "======================================="
# need to do GMT convertion
echo "bios.txt"
# Critical Interrupt bug #90821: unrecoverble PCI or BUS errors
grep -e "Correctable ECC" -e "0x86" -e" Processor CAT ERR" -e "AbnormalShutDown" -e "Watchdog 2" -e "IERR" -e "OEM" -e "SERR" -e "SMI" -e "Critical Interrupt" ${BIOS_TXT}
echo "End of HW error verification"
echo
echo "********************************************************"
echo "Verify number of reboots in kern.info"
echo "********************************************************"
grep -B2 "Linux version"  ${KERN_INFO}
echo
echo "======================================="
if [ -z "${MSG_ENGINEERING}" ]; then
	echo messages.engineering is empty
else
	echo "Verify number of reboots in msg.eng"
	grep -e "booting up" -e "syslogd starting" ${MSG_ENGINEERING}
fi
# grep -e "SSTEM ACPI Power State"  ${BIOS_TXT}
echo
echo "======================================="
if [ -z "${CRON}" ]; then
	echo cron is empty
else
	echo "Verify number of reboots in cron"
	grep -A10 -B10 -e "(CRON) STARTUP" ${CRON}
fi
# if no permission
#if [ "$?" == "2" ]; then
#	echo update permission
#fi
echo "End of reboot check"
echo
echo "********************************************************"
echo "Verify MSG-KERN"
echo "********************************************************"
echo "number of MSG-KERN-xxxxx: "`grep -c -e "MSG-KERN"  ${KERN_INFO}`
# List all the MSG-KERN msgs
echo
grep -e "MSG-KERN" -e "segfault" ${KERN_INFO}
#tac ${KERN_INFO} | grep -m 1 -A5 -B40 -e "MSG-KERN-" | grep -v "pgd_page_vddr_pgdref" | tac
echo
echo "********************************************************"
echo "verify kernel panic"
echo "********************************************************"
echo "number of kernel panic: " `grep -c -e "Oops:" -e "kernel BUG" -e "NULL pointer" -e "Kernel panic" -e "Starting Livedump" -e "soft lockup" ${KERN_INFO}`
echo
echo "Verify unique kernel panic string: (this ignore the same panic string as the last occurance)"
grep -e "Oops:" -e "kernel BUG" -e "NULL pointer" -e "Kernel panic" -e "Starting Livedump" ${KERN_INFO} | uniq -s 86
# get stack trace
echo
echo show the last 2 kernel panic stack trace
#### we reverse the output in order to grep the last instance (before/after line doesn't work well if more than 1 instance)
#### Since the output is reverse, we have to re-reverse again; that's why 2 tac
# we should grep CALL TRACE instead
# tac ${KERN_INFO} | grep -m 2 -A5 -B40 -e "Oops:" -e "kernel BUG" -e "NULL pointer" -e "Kernel panic"  -e "soft lockup" | grep -v "pgd_page_vddr_pgdref" | tac
tac ${KERN_INFO} | grep -m 2 -A5 -B40 -e "Call Trace:" | tac
echo "End of kernel panic"

echo
echo "======================================="
echo "ext3 issue"
grep -e "MSG-EXT3" -e "EXT3-fs error" ${KERN_INFO}

echo
echo "======================================="
echo "ddfs issue"
echo "ddfs.info"
if [ -z "${DDFS_INFO}" ]; then
	echo ddfs.info doesn't exist
else
	grep -e "MSG-INTRNL" -e "MSG-DDR" ${DDFS_INFO}
fi
echo
if [ -z "${MSG_ENGINEERING}" ]; then
	echo messages.engineering doesn't exist
else
	echo "msg.eng"
	grep -e "MSG-DDR-00001" -e "MSG-DDR-00002" -e "MSG-DDR-00003" -e "MSG-DDR-00004" -e "CRITICAL" -e "MSG-INTRNL" ${MSG_ENGINEERING}
fi
echo
echo "======================================="
echo "user space core"
grep -e "elf_core_dump" -e "general protection" -e "Signal" ${KERN_INFO}

# check ddsh commands
# grep -e "MSG-DDSH" ${MSG_ENGINEERING}


#RFE
#need to provide suggestion for potential known issues.
#use bug64811 as example, it p2 is not able to report I/O error, we need to identify who are the users of p2
