#include <linux/kallsyms.h>		// kallsyms_lookup_name()
#include <linux/kprobes.h>
#include <linux/module.h>
//#include <linux/sched.h>		// sched_clock()

// sched_clock() may not be exported.  do the warp funp
static unsigned long long (*dd_sched_clock)(void);

// add more symbols if needed
enum kp_comps {
	SYS_SENDTO,
	SYS_CONNECT,
	SYS_SHUTDOWN,
	KP_COMP_MAX
};

char *kp_comp_Strings[] = {
	"sys_sendto",
	"sys_connect",
	"sys_shutdown"
};

/*
 * init the array value here.  If we don't want the probe, use -1 instead.
 * For example, "is_kp_sendto = {0, -1};" only probes the 1st element.
 */
static int		is_kp[KP_COMP_MAX] 	= {0, 0, 0};
static int		is_kpret[KP_COMP_MAX]	= {0, -1, -1};

// add additional handlers if needed
static int kp1_hndlr(struct kprobe *, struct pt_regs *);
static int kp2_hndlr(struct kprobe *, struct pt_regs *);
static int kp3_hndlr(struct kprobe *, struct pt_regs *);

// make sure put the symbol into the function pointer array.
int (*kp_ptr[KP_COMP_MAX])(struct kprobe *, struct pt_regs *) =
	 {kp1_hndlr, kp2_hndlr, kp3_hndlr};

// add additional handlers if needed
static int kpret1_hndlr(struct kretprobe_instance *, struct pt_regs *);
static int kpret2_hndlr(struct kretprobe_instance *, struct pt_regs *);
static int kpret3_hndlr(struct kretprobe_instance *, struct pt_regs *);

// make sure put the symbol into the function pointer array.
int (*kpret_ptr[KP_COMP_MAX])(struct kretprobe_instance *, struct pt_regs *) =
	 {kpret1_hndlr, kpret2_hndlr, kpret3_hndlr};

static struct kprobe	kp_array[KP_COMP_MAX];
static struct kretprobe kpret_array[KP_COMP_MAX];

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

	for ( index = 0 ; index < KP_COMP_MAX ; index++) {
		// set up kp
		// if the init value is negative, no probe needed. reset to 0.
		if (is_kp[index] < 0) {
			continue;
		}

		kp_array[index].addr = 
			(void *)kallsyms_lookup_name(kp_comp_Strings[index]);
		kp_array[index].pre_handler = kp_ptr[index];

		if (kp_array[index].addr == NULL) {
			printk("symbol %s not found\n", kp_comp_Strings[index]);
			return -1;
		}

		if ((ret = register_kprobe(&kp_array[index])) < 0) {
			printk("register_kprobe %s failed, ret %d\n",
				kp_comp_Strings[index], ret);
			return ret;
		}
		printk("James: %s registered kprobe\n", kp_comp_Strings[index]);
		is_kp[index] = 1;

		// set up kpret
		// if the init value is negative, no probe needed. reset to 0.
		if (is_kpret[index] < 0) {
			continue;
		}

		kpret_array[index].kp.addr = 
			(void *)kallsyms_lookup_name(kp_comp_Strings[index]);
		kpret_array[index].handler = kpret_ptr[index];

		if (kpret_array[index].kp.addr == NULL) {
			printk("symbol %s not found\n", kp_comp_Strings[index]);
			return -1;
		}

		if ((ret = register_kretprobe(&kpret_array[index])) < 0) {
			printk("register_kretprobe %s failed, ret %d\n",
				kp_comp_Strings[index], ret);
			return ret;
		}

		printk("James: %s registered kretprobe\n", kp_comp_Strings[index]);
		is_kpret[index] = 1;

	} /* for () */
	return 0;

}

static void kprobe_exit(void)
{
	int	index;
	for (index = 0 ; index < KP_COMP_MAX ; index++) {
		if (is_kp[index] > 0) {
			unregister_kprobe(&kp_array[index]);
		}

		if (is_kpret[index] > 0) {
			unregister_kretprobe(&kpret_array[index]);
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
