#include <linux/kallsyms.h>		// kallsyms_lookup_name()
#include <linux/kprobes.h>
#include <linux/module.h>
//#include <linux/sched.h>		// sched_clock()

// sched_clock() may not be exported.  do the warp funp
static unsigned long long (*dd_sched_clock)(void);

struct dd_kp {
	int			is_kp;
	int			is_kpret;
	char			kp_func[32];
	int (*kp_ptr)(struct kprobe *, struct pt_regs *);
	int (*kpret_ptr)(struct kretprobe_instance *, struct pt_regs *);
	struct kprobe		dd_kp_str;
	struct kretprobe	dd_kpret_str;
};
	
// add additional handlers if needed
static int kp1_hndlr(struct kprobe *, struct pt_regs *);
static int kp2_hndlr(struct kprobe *, struct pt_regs *);
static int kp3_hndlr(struct kprobe *, struct pt_regs *);

static int kpret1_hndlr(struct kretprobe_instance *, struct pt_regs *);
static int kpret2_hndlr(struct kretprobe_instance *, struct pt_regs *);
static int kpret3_hndlr(struct kretprobe_instance *, struct pt_regs *);

/*
 * init the array value here.  If we don't want the probe, use -1 instead.
 */

struct dd_kp my_dd_kp[] = {
	// is_kp, is_kpret, probe_func, kp, kpret, default, default

	// set the pre-handler & return handler for sys_sendto()
	{0, 0,"sys_sendto\0",kp1_hndlr,kpret1_hndlr,{0},{0}},
	// only set the pre-handler for sys_connect() and sys_shutdow()
	{0,-1,"sys_connect\0",kp2_hndlr,kpret2_hndlr,{0},{0}},
	{0,-1,"sys_shutdown\0",kp3_hndlr,kpret3_hndlr,{0},{0}}
};

/**************************************************************************/
/**************************************************************************/
/**************************************************************************/
/**************************************************************************/

static pid_t	target_pid = 0;

unsigned long 	sendto_counter;
unsigned long 	sendto_entry_time;
unsigned long	sendto_return_time;
unsigned long 	sendto_total_time;

#define COUNT_LIMIT	4000

static int
kp1_hndlr(struct kprobe *p, struct pt_regs *regs)
{
	if (current->pid == target_pid && (sendto_counter < COUNT_LIMIT)) {
		rdtscll(sendto_entry_time);
		//sendto_entry_time = dd_sched_clock();
	}

	return 0;
}

static int
kpret1_hndlr(struct kretprobe_instance *ri, struct pt_regs *regs)
{
	if (current->pid == target_pid && (sendto_counter < COUNT_LIMIT)) {
		rdtscll(sendto_return_time);
		if (unlikely(sendto_return_time < sendto_entry_time)) {
			panic("James: time revert\n");
		}
		sendto_total_time += sendto_return_time - sendto_entry_time;
		//sendto_total_time += (dd_sched_clock() - sendto_entry_time);
	}

	sendto_counter++;

	return 0;
}

// SYS_CONNECT
// trigger sendto counter
static int
kp2_hndlr(struct kprobe *p, struct pt_regs *regs)
{
	if (strcmp(current->comm, "netperf") == 0) {
		target_pid = current->pid;
		sendto_counter = 0;
		sendto_entry_time = 0;
		sendto_return_time = 0;
		sendto_total_time = 0;
	}
	return 0;
}

static int
kpret2_hndlr(struct kretprobe_instance *ri, struct pt_regs *regs)
{
	return 0;
}

// SYS_SHUTDOWN
// print result
static int
kp3_hndlr(struct kprobe *p, struct pt_regs *regs)
{
	if (current->pid == target_pid) {
		if (sendto_counter == 0) {
			printk("James: counter is 0\n");
		} else {
			printk("James: counter %ld ave %ld\n",
				sendto_counter,
				(sendto_total_time/COUNT_LIMIT));
		}
	}
	return 0;
}

static int
kpret3_hndlr(struct kretprobe_instance *ri, struct pt_regs *regs)
{
	return 0;
}

static int
kp_init(void)
{
	int	index;
	int	ret;

	for ( index = 0 ; index < (sizeof(my_dd_kp)/sizeof(struct dd_kp)) ; index++) {
		// set up kp
		// if the init value is negative, no probe needed. reset to 0.
		if (my_dd_kp[index].is_kp < 0) {
			continue;
		}

		my_dd_kp[index].dd_kp_str.addr = 
			(void *)kallsyms_lookup_name(my_dd_kp[index].kp_func);
		my_dd_kp[index].dd_kp_str.pre_handler = my_dd_kp[index].kp_ptr;

		if (my_dd_kp[index].dd_kp_str.addr == NULL) {
			printk("symbol %s not found\n", my_dd_kp[index].kp_func);
			return -1;
		}

		if ((ret = register_kprobe(&my_dd_kp[index].dd_kp_str)) < 0) {
			printk("register_kprobe %s failed, ret %d\n",
				my_dd_kp[index].kp_func, ret);
			return ret;
		}
		printk("James: %s registered kprobe\n", my_dd_kp[index].kp_func);
		my_dd_kp[index].is_kp = 1;

		// set up kpret
		// if the init value is negative, no probe needed. reset to 0.
		if (my_dd_kp[index].is_kpret < 0) {
			continue;
		}

		my_dd_kp[index].dd_kpret_str.kp.addr = my_dd_kp[index].dd_kp_str.addr;
		my_dd_kp[index].dd_kpret_str.handler = my_dd_kp[index].kpret_ptr;


		if ((ret = register_kretprobe(&my_dd_kp[index].dd_kpret_str)) < 0) {
			printk("register_kretprobe %s failed, ret %d\n",
				my_dd_kp[index].kp_func, ret);
			return ret;
		}

		printk("James: %s registered kretprobe\n", my_dd_kp[index].kp_func);
		my_dd_kp[index].is_kpret = 1;

	} /* for () */
	return 0;

}

static void kprobe_exit(void)
{
	int	index;
	for (index = 0 ; index < (sizeof(my_dd_kp)/sizeof(struct dd_kp)) ; index++) {
		if (my_dd_kp[index].is_kp > 0) {
			unregister_kprobe(&my_dd_kp[index].dd_kp_str);
		}

		if (my_dd_kp[index].is_kpret > 0) {
			unregister_kretprobe(&my_dd_kp[index].dd_kpret_str);
		}
	}
}

int __init init_module(void)
{
	int	ret;

	// or use 'rdtscll(unsigned long)' instead
	dd_sched_clock = (void *)kallsyms_lookup_name("sched_clock");

	if (dd_sched_clock == NULL) {
		return -1;
	}

	ret = kp_init();

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
