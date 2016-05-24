#include <linux/kallsyms.h>		// kallsyms_lookup_name()
#include <linux/kprobes.h>
#include <linux/sched.h>		// sched_clock()
#include "dd_kperf.h"

extern struct dd_kperf_percpu *dd_kperf_percpu_pt;

// sched_clock() may not be exported.  do the warp funp
static unsigned long long (*dd_sched_clock)(void);

// probes
static struct kprobe 		kp_softirq;
static int 			is_kp_softirq;

void test()
{
	printk("hello world\n");
}

static void kprobe_exit(void)
{
	if (is_kp_softirq) {
		unregister_kprobe(&kp_softirq);
	}
}

static int
kp_softirq_hndlr(struct kprobe *p, struct pt_regs *regs)
{
	int 			cpu		= smp_processor_id();
	unsigned long long 	cur_time	= dd_sched_clock();
	struct dd_kperf_percpu	*ptr		= per_cpu_ptr(dd_kperf_percpu_pt, cpu);

	return 0;
}

static int kprobe_register(
	struct kprobe *kp, 
	int (*handlr) (struct kprobe *, struct pt_regs *),
	char *str,
	int *result)
{
	int	ret = 0;

	kp->addr = (void *)kallsyms_lookup_name(str);
	kp->pre_handler = handlr;

	if (kp_softirq.addr == NULL) {
		printk("symbol %s not found\n", str);
		return -1;
	}

	if ((ret = register_kprobe(kp)) < 0) {
		printk("register_kprobe %s failed, ret %d\n", str, ret);
		return ret;
	}
	*result = 1;

	return 0;
}

int __init dd_kprobe_init(void)
{
	int	ret;

	dd_sched_clock = kallsyms_lookup_name("sched_clock");

	if (dd_sched_clock == NULL) {
		return -1;
	}

	ret = kprobe_register(&kp_softirq, kp_softirq_hndlr,
				"__do_softirq", &is_kp_softirq);

	if (ret) {
		kprobe_exit();
		return -1;
	}

	return 0;
}

void __exit dd_kprobe_exit(void)
{
	kprobe_exit();
}

MODULE_LICENSE("GPL");
