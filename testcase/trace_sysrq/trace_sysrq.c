#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/kprobes.h>
#include <linux/sched.h>
#include <linux/kallsyms.h>
#include <linux/version.h>

#include "km.h"

static struct kprobe kp1;
static struct kprobe kp2;
static bool kp1_reg = false;
static bool kp2_reg = false;

typedef int (callback_func)(struct kprobe *, struct pt_regs *);

static int
sysrq_pre_handler(struct kprobe *p, struct pt_regs *regs)
{
	printk("kprobe triggered");
	dump_stack();
	return 0;
}

#if LINUX_VERSION_CODE >= KERNEL_VERSION(3,0,0)
static int
register_kp(struct kprobe *kp,
            char *func_name,
            callback_func kp_hdlr)
{
	int ret;

	kp->pre_handler = kp_hdlr;
	kp->symbol_name = func_name;

	if ((ret = register_kprobe(kp)) < 0) {
		printk("register_kprobe failed, ret %d\n", ret);
		return ret;
	}

	return 0;
}
#endif

#if LINUX_VERSION_CODE < KERNEL_VERSION(3,0,0)
int
register_kp(struct kprobe *kp, long param, callback_func kp_hdl)
{
	int ret;

	kp->pre_handler = kp_hdl;
	kp->addr = (kprobe_opcode_t *)param;

	if ((ret = register_kprobe(kp)) < 0) {
		printk("register_kprobe failed, ret %d\n", ret);
	}

	return ret;
}

#endif

int init_module(void)
{
	int ret;

	kp1.pre_handler = sysrq_pre_handler;

#if LINUX_VERSION_CODE >= KERNEL_VERSION(3,0,0)
	if (NULL == (char *) func_name) {
		if(register_kp(&kp1, "__handle_sysrq", sysrq_pre_handler) < 0) {
			return ret;
		}
	} else {
		if(register_kp(&kp1, func_name, sysrq_pre_handler) < 0) {
			return ret;
		}
	}

	printk("kprobe registered\n");
	kp1_reg = true;
#endif

#if LINUX_VERSION_CODE < KERNEL_VERSION(3,0,0)
	// verify 1st param
	if (NULL == (long *) long_1) {
		printk("must provide an instructmented addr\n");
		return -1;
	} else {
		printk("long_1 is %lx\n", long_1);
		if ((ret = register_kp(&kp1, long_1, sysrq_pre_handler))) {
			printk("1st param register failed\n");
			return ret;
		}
		printk("kprobe 1 registered\n");
		kp1_reg = true;
	}

	// verify 2nd param
	if (NULL == (long *) long_2) {
		printk("2nd param is ignored\n");
	} else {
		printk("long_2 is %lx\n", long_2);
		if ((ret = register_kp(&kp2, long_2, sysrq_pre_handler))) {
			printk("2nd param register failed\n");
			unregister_kprobe(&kp1);
			return ret;
		}
		printk("kprobe 2 registered\n");
		kp2_reg = true;
	}
#endif

	return 0;
}

void cleanup_module(void)
{
	if (kp1_reg) unregister_kprobe(&kp1);
	if (kp2_reg) unregister_kprobe(&kp2);
	printk("kprobe unregistered\n");
}

MODULE_LICENSE("GPL");
