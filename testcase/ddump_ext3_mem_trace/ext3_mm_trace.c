/*
 * This module measure how much time a kernel function takes.
 * The time is measure in jiffies (/1000 to get sec). 
 *
 * The result is print in kern.info
 *
 * required files:
 * build.sh
 * Makefile
 * slab_trace.c
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
#include <linux/kallsyms.h>
#include <linux/aio.h>		// kiocb
//#include <linux/uio.h>		// struct iovec

#include <linux/ctype.h>	// isdigit()
#include <linux/list.h>		// list_for_each()

#include <linux/types.h>	// gfp_t
#include <linux/spinlock_types.h>	// spinlock_t
#include <asm/atomic.h>		// atomic_t
#include <linux/numa.h>		// MAX_NUMNODES


// use 'grep block_subsys /proc/kallsyms to get the value
static bool		is_generic_file_buffered_write = false;
static bool		is_kret_generic_file_buffered_write = false;

static struct kprobe	kp_generic_file_buffered_write;
static struct kretprobe	kret_generic_file_buffered_write;

static ssize_t (*generic_file_buffered_write_p)(struct kiocb *, const struct iovec *,
		unsigned long, loff_t, loff_t *, size_t, ssize_t);

generic_file_buffered_write_pre_handler(struct kprobe *kp, struct pt_regs *regs)
{
	//struct file	*filp = (struct file *) regs->rdi;
	int		ret;

	//if (filp == NULL) {
	//	printk("fs_probe filp is NULL\n");
	//	return -1;
	//}
	// ret = check_hu(filp, READ);
	// if (ret) {
		// printk("fs_probe check_hu ret %d\n", ret);
	//}

	return 0;
}


static int
kret_generic_file_buffered_write_handler(struct kretprobe_instance *ri, struct pt_regs *regs)
{
	//long	ret = (long) regs->rax;

	return 0;
}

// The probed addr is given by the user script
// The user script scan /proc/kallsyms
int init_module(void)
{
	int		ret;
	// kallsyms_lookup_name
	generic_file_buffered_write_p =
		(void *)kallsyms_lookup_name("generic_file_buffered_write");

	if (generic_file_buffered_write_p == NULL) {
		printk("Couldn't locate generic_file_buffered_write\n");
		return -1;
	} 

	// kprobe
	kp_generic_file_buffered_write.pre_handler = 
		generic_file_buffered_write_pre_handler;
	kp_generic_file_buffered_write.addr =
		(kprobe_opcode_t *) generic_file_buffered_write_p;

	if ((ret = register_kprobe(&kp_generic_file_buffered_write)) < 0) {
		printk("register_kprobe failed, ret %d\n", ret);
		return ret;
	}

	is_generic_file_buffered_write = true;
	printk("probing generic_file_buffered_write\n");

	// kretprobe
	kret_generic_file_buffered_write.handler = 
		kret_generic_file_buffered_write_handler;
	kret_generic_file_buffered_write.kp.addr =
		(kprobe_opcode_t *)generic_file_buffered_write_p;

	if ((ret = register_kretprobe(&kret_generic_file_buffered_write)) < 0) {
		printk("register_kretprobe failed, ret %d\n", ret);
		return ret;
	}

	is_kret_generic_file_buffered_write = true;
	printk("kretprobing generic_file_buffered_write\n");

	return 0;
}

void cleanup_module(void)
{
	if (is_generic_file_buffered_write) {
		unregister_kprobe(&kp_generic_file_buffered_write);
		printk("kprobe unregistered\n");

	}

	if (is_kret_generic_file_buffered_write) {
		unregister_kretprobe(&kret_generic_file_buffered_write);
		printk("kretprobe unregistered\n");

	}
}

MODULE_LICENSE("GPL");
