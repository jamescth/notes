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
#include <asm/msr.h>		// rdtsc1()

static unsigned long ddump_start = 0;
static unsigned long ddump_end   = 0;
static unsigned long  ddump_rdtsc1_start;
static unsigned long  ddump_rdtsc1_end;

// static char *first_addr = NULL;
// module_param(first_addr, charp, 0000000000000000);

// 1st probe kernel symbol
static long addr_1st;
module_param(addr_1st, long, 0000);

// 2nd probe kernel symbol
static long addr_2nd;
module_param(addr_2nd, long, 0000);

static struct kprobe kp1;
static struct kretprobe kp1_ret;
static struct kprobe kp2;
static struct kretprobe kp2_ret;

static bool is_kp2 = false;

static int
kp1_pre_handler(struct kprobe *p, struct pt_regs *regs)
{
	ddump_start = jiffies;
	rdtscll(ddump_rdtsc1_start);
	printk("ddump start time %ld\n", ddump_start);
	return 0;
}

static int
kp2_pre_handler(struct kprobe *p, struct pt_regs *regs)
{
	ddump_start = jiffies;
	printk("ddump start time %ld\n", ddump_start);
	return 0;
}

static int
kp1_ret_handler(struct kretprobe_instance *ri, struct pt_regs *regs)
{
	ddump_end = jiffies;
	rdtscll(ddump_rdtsc1_end);
	printk("ddump end time %ld\n", ddump_end);
	printk("ddump total time is %ld rdtscl1 %ld\n", ddump_end - ddump_start,
		ddump_rdtsc1_end - ddump_rdtsc1_start);
	return 0;
}

static int
kp2_ret_handler(struct kretprobe_instance *ri, struct pt_regs *regs)
{
	ddump_end = jiffies;
	printk("ddump end time %ld\n", ddump_end);
	printk("ddump total time is %ld\n", ddump_end - ddump_start);
	return 0;
}

// The probed addr is given by the user script
// The user script scan /proc/kallsyms
int init_module(void)
{
	int	ret;

	kp1.pre_handler = kp1_pre_handler;
//	kp1.post_handler = kp1_post_handler;
	kp1_ret.handler = kp1_ret_handler;

	if (NULL == (long *) addr_1st) {
		printk("must provide an instructmented addr\n");
		return 1;
	} else {
		printk("addr_1st is %lx\n", addr_1st);
	}
	// need to export kallsyms_lookup_name first
	kp1.addr = kp1_ret.kp.addr = (kprobe_opcode_t *)addr_1st;

	if ((ret = register_kprobe(&kp1)) < 0) {
		printk("register_kprobe failed, ret %d\n", ret);
		return ret;
	}
	if ((ret = register_kretprobe(&kp1_ret)) < 0) {
		printk("register_kretprobe failed, ret %d\n", ret);
		unregister_kprobe(&kp1);
		return ret;
	}
	printk("kprobe 1 registered\n");

	if (NULL == (long *) addr_2nd) {
		printk("2nd param is ignored\n");
	} else {
		printk("addr_2nd is %lx\n", addr_2nd);

		// need to export kallsyms_lookup_name first
		kp2.addr = kp2_ret.kp.addr = (kprobe_opcode_t *)addr_2nd;

		if ((ret = register_kprobe(&kp1)) < 0) {
			printk("register_kprobe failed, ret %d\n", ret);
			return ret;
		}
		if ((ret = register_kretprobe(&kp1_ret)) < 0) {
			printk("register_kretprobe failed, ret %d\n", ret);
			unregister_kprobe(&kp1);
			return ret;
		}

		is_kp2 = true;
		printk("kprobe 2 registered\n");
	}
	return 0;
}

void cleanup_module(void)
{
	unregister_kprobe(&kp1);
	unregister_kretprobe(&kp1_ret);
	if (is_kp2) {
		unregister_kprobe(&kp2);
		unregister_kretprobe(&kp2_ret);
	}
	printk("kprobe unregistered\n");
}

MODULE_LICENSE("GPL");
