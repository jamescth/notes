#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/kprobes.h>
#include <linux/sched.h>
#include <linux/kallsyms.h>

static struct kretprobe kp1_ret;
static struct kprobe kp1;

// 1st probe kernel symbol
static long long_1;
module_param(long_1, long, 0000);

// 2nd probe kernel symbol
static long long_2;
module_param(long_2, long, 0000);

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

}

static int
sigabrt_pre_handler(struct kprobe *p, struct pt_regs *regs)
{
	dump_state(regs);
	return 0;
}

static int
sigabrt_ret_handler(struct kretprobe_instance *ri, struct pt_regs *regs)
{
	if (current->pid == long_2) {
		printk("sigabrt returns %ld\n", regs->rax);

		// change return value
		regs->rax = 1;
	}
	return 0;
}

// The probed addr is given by the user script
// The user script scan /proc/kallsyms
int init_module(void)
{
	int ret;

	kp1.pre_handler = sigabrt_pre_handler;
	kp1_ret.handler = sigabrt_ret_handler;

	if (NULL == (long *) long_1) {
		printk("must provide an instructmented addr\n");
		return 1;
	} else {
		printk("long_1 is %lx\n", long_1);
	}

	if (NULL == (long *) long_2) {
		printk("must provide an instructmented addr\n");
		return 1;
	} else {
		printk("long_2 is %lx\n", long_2);
	}

	kp1.addr = kp1_ret.kp.addr = (kprobe_opcode_t *)long_1;
	//kp1_ret.kp.addr = (kprobe_opcode_t *)kallsyms_lookup_name("sigabrt_is_pending");
	if ((ret = register_kprobe(&kp1)) < 0) {
		printk("register_kprobe failed, ret %d\n", ret);
		return -1;
	}
	if ((ret = register_kretprobe(&kp1_ret)) < 0) {
		printk("register_kretprobe failed, ret %d\n", ret);
		return -1;
	}
	printk("kprobe registered\n");
	return 0;
}

void cleanup_module(void)
{
	unregister_kprobe(&kp1);
	unregister_kretprobe(&kp1_ret);
	printk("kprobe unregistered\n");
}

MODULE_LICENSE("GPL");
