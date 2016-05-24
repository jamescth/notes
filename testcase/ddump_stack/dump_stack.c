#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/kprobes.h>
#include <linux/sched.h>
#include <linux/kallsyms.h>

static struct kprobe kp1;
static bool kp1_reg = false;
static struct kprobe kp2;
static bool kp2_reg = false;

typedef int (callback_func)(struct kprobe *, struct pt_regs *);

// 1st probe kernel symbol
static long long_1;
module_param(long_1, long, 0000);

// 2nd probe kernel symbol
static long long_2;
module_param(long_2, long, 0000);

#if 0
static void
dump_state(struct pt_regs *regs)
{
	print_symbol(KERN_INFO "RIP is at %p\n", regs->rip);
	printk(KERN_INFO "rax: %016lx rbx: %016lx rcx: %016lx rdx: %016lx\n",
		regs->rax, regs->rbx, regs->rcx, regs->rdx);
	printk(KERN_INFO "r8: %016lx r9: %016lx r10: %016lx r11: %016lx\n",
		regs->r8, regs->r9, regs->r10, regs->r11);
	printk(KERN_INFO "r12: %016lx r13: %016lx r14: %016lx r15: %016lx\n",
		regs->r12, regs->r13, regs->r14, regs->r15);
	printk(KERN_INFO "rsi: %016lx rdi: %016lx rbp: %016lx rsp: %016lx\n",
		regs->rsi, regs->rdi, regs->rbp, regs->rsp);
	printk(KERN_INFO "cs: %016lx ss: %016lx eflags: %016lx\n",
		regs->cs, regs->ss, regs->eflags);
	printk(KERN_INFO "Proc %s (pid: %d, threadinfo %p task %p)\n",
		current->comm, current->pid, current_thread_info(), current);

} // dump_state
#endif

static int
pre_hndlr_dump_state(struct kprobe *p, struct pt_regs *regs)
{
	//dump_state(regs);
	printk("reach dump state\n");
	return 0;
}

static int
pre_hndlr_dump_stack(struct kprobe *p, struct pt_regs *regs)
{
	dump_stack();
	return 0;
}

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

// The probed addr is given by the user script
// The user script scans /proc/kallsyms
int init_module(void)
{
	int ret;

	// if kallsyms_look:up_name() is exported, 
	// we can use it directly instead of /proc/kallsyms
	//
	//kp1_ret.kp.addr = (kprobe_opcode_t *)kallsyms_lookup_name("func name");


	// verify 1st param
	if (NULL == (long *) long_1) {
		printk("must provide an instructmented addr\n");
		return -1;
	} else {
		printk("long_1 is %lx\n", long_1);
		if ((ret = register_kp(&kp1, long_1, pre_hndlr_dump_stack))) {
			printk("1st param register failed\n");
			return ret;
		}
		kp1_reg = true;
		printk("kprobe 1 registered\n");
	}

	// verify 2nd param
	if (NULL == (long *) long_2) {
		printk("2nd param is ignored\n");
	} else {
		printk("long_2 is %lx\n", long_2);
		if ((ret = register_kp(&kp2, long_2, pre_hndlr_dump_state))) {
			printk("2nd param register failed\n");
			unregister_kprobe(&kp1);
			return ret;
		}
		kp2_reg = true;
		printk("kprobe 2 registered\n");
	}

	return 0;
} // init_module

void cleanup_module(void)
{
	if (kp1_reg) unregister_kprobe(&kp1);
	if (kp2_reg) unregister_kprobe(&kp2);
	printk("kprobe unregistered\n");
}

MODULE_LICENSE("GPL");
