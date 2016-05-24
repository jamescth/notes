#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/kprobes.h>

static struct kprobe kp_gettimeofday;
static struct kprobe kp_settimeofday;
static struct kprobe kp_time;
static struct kprobe kp_adjtimex;


// 1st probe kernel symbol
static long addr_gettimeofday;
module_param(addr_gettimeofday, long, 0000);
static long addr_settimeofday;
module_param(addr_settimeofday, long, 0000);
static long addr_time;
module_param(addr_time, long, 0000);
static long addr_adjtimex;
module_param(addr_adjtimex, long, 0000);

static int
handler_gettimeofday(struct kprobe *p, struct pt_regs *regs)
{
	printk("Pid %d calls gettimeofday\n", current->pid);

	return 0;
}

static int
handler_settimeofday(struct kprobe *p, struct pt_regs *regs)
{
	printk("Pid %d calls settimeofday\n", current->pid);

	return 0;
}

static int
handler_time(struct kprobe *p, struct pt_regs *regs)
{
	printk("Pid %d calls time\n", current->pid);

	return 0;
}

static int
handler_adjtimex(struct kprobe *p, struct pt_regs *regs)
{
	printk("Pid %d calls adjtimex\n", current->pid);

	return 0;
}



// The probed addr is given by the user script
// The user script scan /proc/kallsyms
int init_module(void)
{
	int ret;

	if (NULL == (long *) addr_gettimeofday) {
		printk("must provide an instructmented gettimeofday\n");
		return -1;
	} else {
		printk("gettimeofday is %lx\n", addr_gettimeofday);
	}
	if (NULL == (long *) addr_settimeofday) {
		printk("must provide an instructmented settimeofday\n");
		return -1;
	} else {
		printk("settimeofday is %lx\n", addr_settimeofday);
	}
	if (NULL == (long *) addr_time) {
		printk("must provide an instructmented time\n");
		return -1;
	} else {
		printk("time is %lx\n", addr_time);
	}
	if (NULL == (long *) addr_adjtimex) {
		printk("must provide an instructmented adjtimex\n");
		return -1;
	} else {
		printk("adjtimex is %lx\n", addr_adjtimex);
	}

	kp_gettimeofday.pre_handler	= handler_gettimeofday;
	kp_gettimeofday.addr		= (kprobe_opcode_t *)addr_gettimeofday;
	kp_settimeofday.pre_handler	= handler_settimeofday;
	kp_settimeofday.addr		= (kprobe_opcode_t *)addr_settimeofday;
	kp_time.pre_handler		= handler_time;
	kp_time.addr			= (kprobe_opcode_t *)addr_time;
	kp_adjtimex.pre_handler		= handler_adjtimex;
	kp_adjtimex.addr		= (kprobe_opcode_t *)addr_adjtimex;


	if ((ret = register_kprobe(&kp_gettimeofday)) < 0) {
		printk("register kp_gettimeofday failed, ret %d\n", ret);
		return -1;
	}

	if ((ret = register_kprobe(&kp_settimeofday)) < 0) {
		printk("register kp_settimeofday failed, ret %d\n", ret);
		return -1;
	}

	if ((ret = register_kprobe(&kp_time)) < 0) {
		printk("register kp_time failed, ret %d\n", ret);
		return -1;
	}

	if ((ret = register_kprobe(&kp_adjtimex)) < 0) {
		printk("register kp_adjtimex failed, ret %d\n", ret);
		return -1;
	}

	printk("kprobe registered\n");
	return 0;
}


void cleanup_module(void)
{
	unregister_kprobe(&kp_gettimeofday);
	unregister_kprobe(&kp_settimeofday);
	unregister_kprobe(&kp_time);
	unregister_kprobe(&kp_adjtimex);
	printk("kprobe terminated\n");
}

MODULE_LICENSE("GPL");
