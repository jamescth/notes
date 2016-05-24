/*
 * This module measure how much time a kernel function takes.
 * The time is measure in jiffies (/1000 to get sec). 
 *
 * The result is print in kern.info
 *
 * required files:
 * build.sh
 * Makefile
 * ddump_module.c
 * run_ddump
 *
 * run build.sh to build ddump_module.ko.
 * modify Makefile for wherever the kernel build is.
 *
 * run_ddump scan /proc/kallsyms to match up the given 
 * kernel symbol.  Pass the obtained address to 
 * ddump_module.ko when the module is inserted.
 *
 * cp ddump_module.ko & run_ddump to test machine.
 *
 * on test machine:
 * run_ddump <kernel symbol>
 */

#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/sched.h>
#include <linux/kprobes.h>
#include <linux/kallsyms.h>	// kallsyms_lookup_name()
#include <linux/jiffies.h>	// msecs_to_jiffies()
#include <linux/signal.h>
#include <asm/msr.h>		// rdtsc1()

#define DISKDUMP_CRASH_DAEMON	"crash_daemon"

static struct kprobe kp1;
static unsigned long ddump_start = 0;
static unsigned long ddump_end   = 0;

static void
do_livedump(void)
{
	struct task_struct *pproc;

	for_each_process(pproc) {
		if (!strcmp(pproc->comm, DISKDUMP_CRASH_DAEMON)) {
			force_sig(SIGUSR1, pproc);
			printk("crash daemon is triggered by %d (%s) to %d (%s)\n",
				current->pid, current->comm, pproc->pid, pproc->comm);
		}
	}
}

//#if 0
static int
umh_test(void)
{
	struct subprocess_info *sub_info;
	char *argv[] = { "/root/gdb_daemon", NULL};
	static char *envp[] = {
		"HOME=/",
		"TERM=linux",
		"PATH=/sbin:/bin:/usr/sbin:/usr/bin", NULL};
	sub_info = call_usermodehelper_setup(argv[0], argv, envp);
	if (sub_info == NULL)	return -ENOMEM;

	return call_usermodehelper_exec(sub_info, UMH_WAIT_PROC);

}
//#endif
#if 0
static int
umh_test(void)
{
	char *umh_wrapper_path = "/ddr/bin/call_usermodehelper_wrapper.sh";
	char *savecore_path = "/ddr/bin/invoke_save_core.sh";
	char *umh_args[] = { umh_wrapper_path,
				 "-o",
				 "/ddr/var/core/invoke_savecore.log",
				 "-c",
				 savecore_path, 
				 NULL
			   };
	char *envp[] = { "HOME=/", 
		      	 "PATH=/sbin:/bin:/usr/sbin:/usr/bin:/ddr/bin", 
		      	 NULL 
			};
	int ret;

	Info("calling daemon\n");
    	ret = call_usermodehelper(umh_wrapper_path, umh_args, envp, 0);
}
#endif 

static int
kp1_pre_handler(struct kprobe *p, struct pt_regs *regs)
{

#if 0
	{
		// see flush_signals()
		spin_lock_irqsave()
		clear_tsk_thread_flag()
		next_signal() //?
	}
#endif
	{
		printk("current 0x%p, current->user 0x%p, current->signal 0x%p\n",
			current, current->user, current->signal);
	}

	{
		sigaddset(&current->pending.signal, SIGSTOP);
	}

#if 0
	msleep(100000);
#endif
	return 0;
}

// The probed addr is given by the user script
// The user script scan /proc/kallsyms
int init_module(void)
{
	int	ret;

	kp1.pre_handler = kp1_pre_handler;
	kp1.addr = kallsyms_lookup_name("do_coredump");

	if (kp1.addr == NULL) {
		printk("ddump addr lookup failed\n");
		return -1;
	}

	if ((ret = register_kprobe(&kp1)) < 0) {
		printk("registered ddump_walk_pl failed, ret %d\n", ret);
		return ret;
	}

	//printk("ddump_walk_pl called %ld\n", jiffies);
	//do_livedump();
	//umh_test();
	printk("ddump_walk_pl registered \n");

	return 0;
}

void cleanup_module(void)
{
	unregister_kprobe(&kp1);
	printk("ddump_walk_pl unregistered\n");
}

MODULE_LICENSE("GPL");
