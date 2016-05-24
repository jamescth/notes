#include <linux/kallsyms.h>		// kallsyms_lookup_name()
#include <linux/kprobes.h>
#include <linux/module.h>
//#include <linux/sched.h>		// sched_clock()

// sched_clock() may not be exported.  do the warp funp
static unsigned long long (*dd_sched_clock)(void);

// probes
static pid_t			target_pid = -1;

static struct kprobe 		kp_sendto;
static struct kretprobe		kpret_sendto;
static int 			is_kp_sendto;
static int 			is_kpret_sendto;


unsigned long sendto_counter	= 0;
unsigned long sendto_entry_time	= 0;
unsigned long sendto_total_time	= 0;

static void kprobe_exit(void)
{
	if (is_kp_sendto) {
		unregister_kprobe(&kp_sendto);
	}

	if (is_kpret_sendto) {
		unregister_kretprobe(&kpret_sendto);
	}
}

static int
kp_sendto_hndlr(struct kprobe *p, struct pt_regs *regs)
{
//	int 			cpu		= smp_processor_id();
//	sendto_entry_time = dd_sched_clock();

	return 0;
}

static int
kpret_sendto_hndlr(struct kretprobe_instance *ri, struct pt_regs *regs)
{
//	sendto_total_time += (dd_sched_clock() - sendto_entry_time);
	sendto_counter++;
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

	if (kp->addr == NULL) {
		printk("symbol %s not found\n", str);
		return -1;
	}

	printk("addr is %p\n", kp->addr);

	if ((ret = register_kprobe(kp)) < 0) {
		printk("register_kprobe %s failed, ret %d\n", str, ret);
		return ret;
	}
	*result = 1;

	return 0;
}

static int kretprobe_register(
	struct kretprobe *kp_ret, 
	kretprobe_handler_t handlr,
	char *str,
	int *result)
{
	int	ret = 0;

	kp_ret->kp.addr = (void *)kallsyms_lookup_name(str);
	kp_ret->handler = handlr;

	if (kp_ret->kp.addr == NULL) {
		printk("symbol %s not found\n", str);
		return -1;
	}

	if ((ret = register_kretprobe(kp_ret)) < 0) {
		printk("register_kretprobe %s failed, ret %d\n", str, ret);
		return ret;
	}
	*result = 1;

	return 0;
}

int __init init_module(void)
{
	int	ret;

	// or use 'rdtscll(unsigned long)' instead
	dd_sched_clock = (void *)kallsyms_lookup_name("sched_clock");

	if (dd_sched_clock == NULL) {
		return -1;
	}

	ret = kprobe_register(&kp_sendto, kp_sendto_hndlr,
				"sys_sendto", &is_kp_sendto);

	if (ret) {
		kprobe_exit();
		return -1;
	}

	ret = kretprobe_register(&kpret_sendto, kpret_sendto_hndlr,
				"sys_sendto", &is_kpret_sendto);

	if (ret) {
		kprobe_exit();
		return -1;
	}

	printk("dd_knet loaded\n");

	return 0;
}

void __exit cleanup_module(void)
{
	kprobe_exit();
	printk("dd_knet unloaded\n");
}

MODULE_LICENSE("GPL");
