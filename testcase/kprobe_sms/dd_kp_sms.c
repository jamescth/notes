#include <linux/kallsyms.h>		// kallsyms_lookup_name()
#include <linux/kprobes.h>
#include <linux/module.h>
//#include <linux/sched.h>		// sched_clock()

// sched_clock() may not be exported.  do the warp funp
static unsigned long long (*dd_sched_clock)(void);

// add more symbols if needed
enum kp_comps {
	DO_COREDUMP,
	TRY_APPDUMP,
	SYS_SHUTDOWN,
	KP_COMP_MAX
};

char *kp_comp_Strings[] = {
	"do_coredump",
	"try_appdump",
	"sys_shutdown"
};

/*
 * init the array value here.  If we don't want the probe, use -1 instead.
 * For example, "is_kp_sendto = {0, -1};" only probes the 1st element.
 */
static int		is_kp[KP_COMP_MAX] 	= {0, 0, -1};
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

static int
kp1_hndlr(struct kprobe *p, struct pt_regs *regs)
{
	printk("James kp1 %s %d rawdump %d\n", current->comm, current->pid, current->rawdump_enabled);
	printk("James what the hack %ld\n",
		current->signal->rlim[RLIMIT_CORE].rlim_cur);
	return 0;
}

static int
kpret1_hndlr(struct kretprobe_instance *ri, struct pt_regs *regs)
{
	printk("James kp1ret %ld\n", regs->rax);
	return 0;
}

// SYS_CONNECT
// trigger sendto counter
static int
kp2_hndlr(struct kprobe *p, struct pt_regs *regs)
{
	printk("James kp2 %s %d rawdump %d\n", current->comm, current->pid, current->rawdump_enabled);
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
