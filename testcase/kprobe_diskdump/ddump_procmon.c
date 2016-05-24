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
#include <linux/kprobes.h>
#include <asm/msr.h>		// rdtsc1()
#include <linux/kallsyms.h>		// kallsyms_lookup_name()

static struct kprobe kp1_disk_dump_write;
static struct kprobe kp2_get_signal_to_deliver;

static int
kp1_pre_handler(struct kprobe *p, struct pt_regs *regs)
{
	printk("current %p pid %d comm %s accessing disk_dump_write stopped\n", current, current->pid, current->comm);
	sigaddset(&current->pending.signal, SIGSTOP);
	return 0;
}

static int
kp2_pre_handler(struct kprobe *p, struct pt_regs *regs)
{
	if (0 == strcmp(current->comm, "ddr_procmon")) {
		printk("current %p pid %d comm %s accessing signal delivery\n", current, current->pid, current->comm);
	}
	return 0;
}


// The probed addr is given by the user script
// The user script scan /proc/kallsyms
int init_module(void)
{
	int	ret;

	kp1_disk_dump_write.pre_handler = kp1_pre_handler;
	kp2_get_signal_to_deliver.pre_handler = kp2_pre_handler;

	// need to export kallsyms_lookup_name first
	kp1_disk_dump_write.addr = (void *)kallsyms_lookup_name("disk_dump_write");

	if (kp1_disk_dump_write.addr == NULL) {
		printk("kallsyms_lookup_name() disk_dump_write failed\n");
		return -1;
	}

	if ((ret = register_kprobe(&kp1_disk_dump_write)) < 0) {
		printk("register_kprobe disk_dump_write failed, ret %d\n", ret);
		return -1;
	}

	kp2_get_signal_to_deliver.addr = (void *)kallsyms_lookup_name("get_signal_to_deliver");

	if (kp2_get_signal_to_deliver.addr == NULL) {
		unregister_kprobe(&kp1_disk_dump_write);
		printk("kallsyms_lookup_name() get_signal_to_deliver failed\n");
		return -1;
	}

	if ((ret = register_kprobe(&kp2_get_signal_to_deliver)) < 0) {
		unregister_kprobe(&kp1_disk_dump_write);
		printk("register_kprobe get_signal_to_deliver failed, ret %d\n", ret);
		return -1;
	}

error:

	printk("ddump_procmon\n");
	return 0;
}

void cleanup_module(void)
{
	unregister_kprobe(&kp1_disk_dump_write);
	unregister_kprobe(&kp2_get_signal_to_deliver);
	printk("kprobe unregistered\n");
}

MODULE_LICENSE("GPL");
