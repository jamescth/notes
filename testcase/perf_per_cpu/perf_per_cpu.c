#include <linux/kernel.h>
#include <linux/module.h>

#include <linux/fs.h>			// file operation
#include <linux/seq_file.h>		// seq operation
#include <linux/proc_fs.h>		// procfs
#include <linux/percpu.h>
#include <linux/kallsyms.h>		// kallsyms_lookup_name()
#include <linux/kprobes.h>

#include <linux/cache.h>		// ____cacheline_aligned_in_smp
#include <linux/sched.h>		// sched_clock()
#include <linux/cpumask.h>		// for_each_online_cpu()

#include <asm-x86_64/pda.h>		// cpu_pda()
#include <linux/slab_def.h>		// kmalloc_node()

/*
 * 1. cpu runq length => sched.c/struct rq
 * 2. memory info: free, swap, numa map?
 * 3. slic port queue
 * 4. sas port queue
 * 5. irq?
 */

#define CONFIG_NUMA

#define DD_KPERF_MAX_ENT		10000

enum {  KP_IDLE = 0x0,
	KP_SCHEDULE = 0x1,
	KP_IRQ = 0x2
};

struct dd_kperf_entry {
	unsigned long	dp_time;	// time stamp
	unsigned long	cs;		// context switch
}____cacheline_aligned_in_smp;

// globals for perf
static struct dd_kperf_entry	*dd_kperf_percpu_pt;
static unsigned long		dd_kperf_percpu_idx;

// nodeid => this array should be NUMA aware?
static struct dd_kperf_entry	*dd_kperf_array[NR_CPUS];

//static struct dd_kperf		*cpu_ddump_perf;	/* per CPU ptr */

static int			dd_kperf_num_cpu;
static int			kperf_cpu = 0;

static int			kperf_on = 0;

// probes
static struct kprobe 		kp_softirq;
static struct kretprobe 	kpret_softirq;
static int 			is_kp_softirq, is_kpret_softirq;

static struct kprobe		kp_cpu_idle;
static struct kretprobe 	kpret_cpu_idle;
static int 			is_kp_cpu_idle, is_kpret_cpu_idle;

static struct kprobe		kp_schedule;
static struct kretprobe 	kpret_schedule;
static int 			is_kp_schedule, is_kpret_schedule;

// procfs
struct proc_dir_entry 		*dd_kperf;

// time APIs
static unsigned long long (*sched_clock_p)(void);

/* Seq operations for dd_kperf: start, show, next, stop */
static void *dd_kperf_seq_start(struct seq_file *seq, loff_t *pos)
{
	printk("dd_kperf_seq_start *pos %lu\n", *pos);

	if (*pos == 0) {
		return &kperf_cpu;
	} else {
		*pos = 0;
		kperf_cpu = 0;
		return NULL;
	}
}

static void *dd_kperf_seq_next(struct seq_file *seq, void *v, loff_t *pos)
{
	unsigned int  *cpu = (unsigned long *)v;

	printk("dd_kperf_seq_next *cpu %d\n", *cpu);
	if (++(*cpu) < dd_kperf_num_cpu) {
		return &kperf_cpu;
	} else {
		(*pos)++;
		return NULL;
	}
}

static void dd_kperf_seq_stop(struct seq_file *seq, void *v)
{

}

static int dd_kperf_seq_show(struct seq_file *seq, void *v)
{
	unsigned int	*cpu = (int *) v;
	struct dd_kperf_entry	*perf_entry;

	printk("dd_kperf_seq_show %d\n", *cpu);
//	seq_printf(seq, "%ld\n", *spos);

#if 0
//	for_each_online_cpu(cpu) {
//	for (cpu = 0 ; cpu < dd_kperf_num_cpu ;  cpu++) {
		perf_entry =
			(struct dd_kperf_entry *)per_cpu_ptr(cpu_ddump_perf, *cpu);
		
		if (!perf_entry) {
			printk("not able to locate kperf entry\n");
//			return -1;
		}
		seq_printf(seq, "cpu %d time %lu cs %lu\n",
				*cpu, perf_entry->dp_time, perf_entry->cs);
//	}
#endif
	return 0;
}

static struct seq_operations dd_kperf_seq_ops = {
	.start	= dd_kperf_seq_start,
	.next	= dd_kperf_seq_next,
	.stop	= dd_kperf_seq_stop,
	.show	= dd_kperf_seq_show,
};

static int dd_kperf_open(struct inode *inode, struct file *file)
{
	return seq_open(file, &dd_kperf_seq_ops);
}

static ssize_t dd_kperf_write(struct file * file, const char __user *_buf,
			       size_t count, loff_t *ppos)
{
	printk("dd_kperf_write\n");

#if 0
    char buf[1];
    if (copy_from_user(buf, _buf, 1))
        return count;
    spin_lock(&sched_log_lock);
    if (count > 0 && buf[0] == '1') {
	/* enable logging */
	sched_log_idx = 0;
	sched_log_enable = 1;
	sched_log_wrapped = 0;
	sched_log_allow_wrap = 0;
    } else if (count > 0 && buf[0] == '2') {
	/* enable logging, allow wrap */
	sched_log_idx = 0;
	sched_log_enable = 1;
	sched_log_wrapped = 0;
	sched_log_allow_wrap = 1;
    } else {
	/* disable logging */
	sched_log_enable = 0;
    }
    spin_unlock(&sched_log_lock);
#endif
    return count;
}

static struct file_operations dd_kperf_fops = {
	.owner		= THIS_MODULE,
	.open		= dd_kperf_open,
	.read		= seq_read,
	.llseek		= seq_lseek,
	.release	= seq_release,
	.write		= dd_kperf_write,
};

/* should both kp & kpret to be the same? */
static int
kp_softirq_hndlr(struct kprobe *p, struct pt_regs *regs)
{
	int 			cpu = smp_processor_id();
        unsigned long long 	cur_time = sched_clock_p();
	struct dd_kperf_entry	*perf_entry;
#if 0
	// per_cpu_ptr( , cpu);
	perf_entry = (struct dd_kperf_entry *)per_cpu_ptr(cpu_ddump_perf, cpu);
	if (!perf_entry) {
		printk("can't locate per cpu entry\n");
		// panic()??
	}
	perf_entry->dp_time	= cur_time;
	perf_entry->cs		= KP_IRQ;
#endif
	return 0;
}

static int
kpret_softirq_hndlr(struct kretprobe_instance *ri, struct pt_regs *regs)
{
	return 0;
}

static int
kp_cpu_idle_hndlr(struct kprobe *p, struct pt_regs *regs)
{
	int 			cpu = smp_processor_id();
        unsigned long long 	cur_time = sched_clock_p();
	struct dd_kperf_entry	*perf_entry;
#if 0
	// per_cpu_ptr( , cpu);
	perf_entry = (struct dd_kperf_entry *)per_cpu_ptr(cpu_ddump_perf, cpu);
	if (!perf_entry) {
		printk("can't locate per cpu entry\n");
		// panic()??
	}
	perf_entry->dp_time	= cur_time;
	perf_entry->cs		= KP_IDLE;
#endif
	return 0;
}

static int
kpret_cpu_idle_hndlr(struct kretprobe_instance *ri, struct pt_regs *regs)
{
	return 0;
}

static int
kp_schedule_hndlr(struct kprobe *p, struct pt_regs *regs)
{
	int 			cpu = smp_processor_id();
        unsigned long long 	cur_time = sched_clock_p();
	struct dd_kperf_entry	*perf_entry;

#if 0
	// per_cpu_ptr( , cpu);
	perf_entry = (struct dd_kperf_entry *)per_cpu_ptr(cpu_ddump_perf, cpu);
	if (!perf_entry) {
		printk("can't locate per cpu entry\n");
		// panic()??
	}
	perf_entry->dp_time	= cur_time;
	perf_entry->cs		= KP_SCHEDULE;
#endif
	return 0;
}

static int
kpret_schedule_hndlr(struct kretprobe_instance *ri, struct pt_regs *regs)
{
	return 0;
}

static int __init my_init(void)
{
	int	ret;
	int	cpu;

	dd_kperf_num_cpu = num_online_cpus();

	// APIs
	sched_clock_p = (void *)kallsyms_lookup_name("sched_clock");
	if (sched_clock_p == NULL) {
		printk("Can't locate sched_clock\n");
		return -1;
	}

	// per cpu
	dd_kperf_percpu_pt = alloc_percpu(unsigned long);
	if (dd_kperf_percpu_pt == NULL) {
		printk("alloc_percpu() failed\n");
		ret = -1;
		goto init_error;
	}

	for ( cpu = 0 ; cpu < dd_kperf_num_cpu ;  cpu++) {
		int	nodeid;

		nodeid = cpu_pda(cpu)->nodenumber;
//		dd_kperf_array[cpu] = kmalloc_node(
//					sizeof((struct dd_kperf_entry) * DD_KPERF_MAX_ENT),
//					GFP_KERNEL, nodeid);
	}
#if 0
	/* Allocate node local memory for AP pdas */
	if (cpu_pda(cpu) == &boot_cpu_pda[cpu]) {
		struct x8664_pda *newpda, *pda;
		int node = cpu_to_node(cpu);
		pda = cpu_pda(cpu);
		newpda = kmalloc_node(sizeof (struct x8664_pda), GFP_ATOMIC,
				      node);
		if (newpda) {
			memcpy(newpda, pda, sizeof (struct x8664_pda));
			cpu_pda(cpu) = newpda;
		} else
			printk(KERN_ERR
		"Could not allocate node local PDA for CPU %d on node %d\n",
				cpu, node);
	}
#endif

	// kprobes
	kp_softirq.addr = kpret_softirq.kp.addr = 
		(void *)kallsyms_lookup_name("__do_softirq");

	kp_softirq.pre_handler = kp_softirq_hndlr;
	if (kp_softirq.addr == NULL) {
		printk("do_softirq failed\n");
		ret = -1;
		goto init_error;
	}

	if ((ret = register_kprobe(&kp_softirq)) < 0) {
		printk("register_kprobe failed, ret %d\n", ret);
		goto init_error;
	}
	is_kp_softirq = 1;

	kpret_softirq.handler = kpret_softirq_hndlr;
	if ((ret = register_kretprobe(&kpret_softirq)) < 0) {
		printk("register_kretprobe failed, ret %d\n", ret);
		goto init_error;
	}
	is_kpret_softirq = 1;

	// cpu_idle
	kp_cpu_idle.addr = kpret_cpu_idle.kp.addr = 
		(void *)kallsyms_lookup_name("cpu_idle");

	kp_cpu_idle.pre_handler = kp_cpu_idle_hndlr;
	if (kp_cpu_idle.addr == NULL) {
		printk("cpu_idle failed\n");
		ret = -1;
		goto init_error;
	}

	if ((ret = register_kprobe(&kp_cpu_idle)) < 0) {
		printk("register_kprobe failed, ret %d\n", ret);
		goto init_error;
	}
	is_kp_cpu_idle = 1;

	kpret_cpu_idle.handler = kpret_cpu_idle_hndlr;
	if ((ret = register_kretprobe(&kpret_cpu_idle)) < 0) {
		printk("register_kretprobe failed, ret %d\n", ret);
		goto init_error;
	}
	is_kpret_cpu_idle = 1;

	// schedule
	kp_schedule.addr = kpret_schedule.kp.addr = 
		(void *)kallsyms_lookup_name("schedule");

	kp_schedule.pre_handler = kp_schedule_hndlr;
	if (kp_schedule.addr == NULL) {
		printk("schedule failed\n");
		ret = -1;
		goto init_error;
	}

	if ((ret = register_kprobe(&kp_schedule)) < 0) {
		printk("register_kprobe failed, ret %d\n", ret);
		goto init_error;
	}
	is_kp_schedule = 1;

	kpret_schedule.handler = kpret_schedule_hndlr;
	if ((ret = register_kretprobe(&kpret_schedule)) < 0) {
		printk("register_kretprobe failed, ret %d\n", ret);
		goto init_error;
	}
	is_kpret_schedule = 1;

	// procfs
	dd_kperf = create_proc_entry("dd_kperf", S_IRUGO|S_IWUSR, NULL);
	if (dd_kperf == NULL) {
		printk("dd_kperf failed\n");
		ret = -1;
		goto init_error;
	}
	dd_kperf->proc_fops = &dd_kperf_fops;

	printk(KERN_INFO "\ndd_kperf OK\n");

	return 0;

init_error:
	if (dd_kperf_percpu_pt) {
		free_percpu(dd_kperf_percpu_pt);
		dd_kperf_percpu_pt = NULL;
	}

	if (is_kp_softirq) {
		unregister_kprobe(&kp_softirq);
	}

	if (is_kpret_softirq) {
		unregister_kretprobe(&kpret_softirq);
	}

	if (is_kp_cpu_idle) {
		unregister_kprobe(&kp_cpu_idle);
	}

	if (is_kpret_cpu_idle) {
		unregister_kretprobe(&kpret_cpu_idle);
	}

	if (is_kp_schedule) {
		unregister_kprobe(&kp_schedule);
	}

	if (is_kpret_schedule) {
		unregister_kretprobe(&kpret_schedule);
	}

	if (dd_kperf) {
		remove_proc_entry("dd_kperf", NULL);
	}

	return ret;
}

static void __exit my_exit(void)
{

	// per cpu
	free_percpu(dd_kperf_percpu_pt);
	dd_kperf_percpu_pt = NULL;

	// kprobes
	unregister_kprobe(&kp_softirq);
	unregister_kretprobe(&kpret_softirq);

	// procfs
	remove_proc_entry("dd_kperf", NULL);

	printk(KERN_INFO "\ndd_kperf free\n");
}

module_init(my_init);
module_exit(my_exit);

MODULE_LICENSE("GPL");
