#include <linux/kernel.h>
#include <linux/module.h>

#include <linux/fs.h>			// file operation
#include <linux/seq_file.h>		// seq operation
#include <linux/spinlock_types.h>	// DEFINE_SPINLOCK

#include <linux/proc_fs.h>		// procfs
#include <linux/percpu.h>
#include <linux/kprobes.h>

#include <linux/cache.h>		// ____cacheline_aligned_in_smp
#include <linux/sched.h>		// sched_clock()
#include <linux/cpumask.h>		// for_each_online_cpu()

// #include <asm-x86_64/pda.h>		// cpu_pda()
#include <linux/slab_def.h>		// kmalloc_node()
#include <linux/kallsyms.h>		// kallsyms_lookup_name()
#include <linux/kthread.h>		// kthread
#include <linux/kernel_stat.h>		// kstat
#include <linux/swap.h>			// swap
#include <linux/mm.h>			// si_meminfo()
#include <linux/interrupt.h>		// NET_TX_SOFTIRQ...
#include <linux/irq.h>			// irq_desc
#include <asm/cputime.h>		// cputime64_to_clock_t()
#include <asm/pda.h>			// x8664_pda
#include "struct_rq.h"

#define ASSERT_CONCAT_(a, b)	a##b
#define ASSERT_CONCAT(a, b)	ASSERT_CONCAT_(a, b)
#define ct_assert(e)		enum { ASSERT_CONCAT(assert_line_, __LINE__) = 1/(!!(e)) }

ct_assert(sizeof(struct rq) == 0x870);

#define SEQ_printf(m, x...)			\
 do {						\
	if (m)					\
		seq_printf(m, x);		\
	else					\
		printk(x);			\
 } while (0)

#define LOAD_INT(x) ((x) >> FSHIFT)
#define LOAD_FRAC(x) LOAD_INT(((x) & (FIXED_1-1)) * 100)

#define ARRAY_SZ		16

static long runq_array_1[ARRAY_SZ] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
static long runq_array_2[ARRAY_SZ] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
static long runq_array_3[ARRAY_SZ] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
static long runq_array_4[ARRAY_SZ] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
static long runq_array_5[ARRAY_SZ] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
static int  runq_array1_count = 0;
static int  runq_array2_count = 0;
static int  runq_array3_count = 0;
static int  runq_array4_count = 0;
static int  runq_array5_count = 0;
module_param_array(runq_array_1, long, &runq_array1_count, 0000);
module_param_array(runq_array_2, long, &runq_array2_count, 0000);
module_param_array(runq_array_3, long, &runq_array3_count, 0000);
module_param_array(runq_array_4, long, &runq_array4_count, 0000);
module_param_array(runq_array_5, long, &runq_array5_count, 0000);

static int num_runqs = 0;

// function prototype
static void print_cpu(struct seq_file *, int);
static void print_cpus(struct seq_file *);
static void print_kstat_01(struct seq_file *,int);
static void print_kstat_02(struct seq_file *,int);
static void print_memory(struct seq_file *);
static int kthread_init(void);
static int kthread_perf_main(void*);
static struct rq* get_rq(int);
static void print_parameters(void);

// global variables
static void (*si_swapinfo_p)(struct sysinfo *);
struct irq_desc *irq_desc_p;

struct task_struct		*ktperf;
struct proc_dir_entry		*ktperf_proc;
struct rq			kperf_rq[NR_CPUS];
static int			kperf_cpu = 0;

static struct rq* get_rq(int cpu)
{
	int	index = cpu % ARRAY_SZ;
	
	if (cpu < ARRAY_SZ) {
		return (struct rq*)runq_array_1[index];
	} else if (cpu < 2 * ARRAY_SZ) {
		return (struct rq*)runq_array_2[index];
	} else if (cpu < 3 * ARRAY_SZ) {
		return (struct rq*)runq_array_3[index];
	} else if (cpu < 4 * ARRAY_SZ) {
		return (struct rq*)runq_array_4[index];
	} else if (cpu < 5 * ARRAY_SZ) {
		return (struct rq*)runq_array_5[index];
	}
	return NULL;
}

static void print_cpus(struct seq_file *m)
{
	int	index;

	SEQ_printf(m, "cpu weight     switch  load                un-int load0 load1 load2\n");
	for ( index = 0 ; index < num_runqs ; index++ ) {
		print_cpu(m, index);
	}

	for ( index = 0 ; index < num_runqs ; index++ ) {
		print_kstat_01(m, index);
	}

	SEQ_printf(m, "cpu     user     nice   system  softirq      irq     idle   iowait    steal\n");
	for ( index = 0 ; index < num_runqs ; index++ ) {
		print_kstat_02(m, index);
	}
}

static void print_cpu(struct seq_file *m, int cpu)
{
	struct rq	*rq = get_rq(cpu);
	int		a, b, c;

	if (rq == NULL) {
		printk("not able to get rq\n");
		return;
	}
	// printk("cpu %d rq %p\n", cpu, rq);

	a = rq->cpu_load[0] + (FIXED_1/200);
	b = rq->cpu_load[1] + (FIXED_1/200);
	c = rq->cpu_load[2] + (FIXED_1/200);

	SEQ_printf(m, "%3d %6lu %10lld %5lu 0x%016lx %2d.%02d %2d.%02d %2d.%02d %p\n",
			cpu, rq->ls.load.weight, rq->nr_switches,
			rq->nr_load_updates, rq->nr_uninterruptible,
			LOAD_INT(a), LOAD_FRAC(a),
			LOAD_INT(b), LOAD_FRAC(b),
			LOAD_INT(c), LOAD_FRAC(c),
			rq);

#if 0
//	SEQ_printf(m, "\ncpu#%d\n", cpu);
#define P(x) \
	SEQ_printf(m, "  .%-20s: %Ld\n", #x, (long long)(rq->x))
	P(nr_running);
	SEQ_printf(m, "  .%-20s: %lu\n", "load",
		   rq->ls.load.weight);
	P(nr_switches);
	P(nr_load_updates);
	P(nr_uninterruptible);
	SEQ_printf(m, "  .%-20s: %lu\n", "jiffies", jiffies);
	P(cpu_load[0]);
	P(cpu_load[1]);
	P(cpu_load[2]);
	P(cpu_load[3]);
	P(cpu_load[4]);
#endif
}
static void print_kstat_02(struct seq_file *m, int cpu)
{
	SEQ_printf(m, "%3d %8llu %8llu %8llu %8llu %8llu %8llu %8llu %8llu\n",
		cpu,
		(unsigned long long)cputime64_to_clock_t(kstat_cpu(cpu).cpustat.user),
		(unsigned long long)cputime64_to_clock_t(kstat_cpu(cpu).cpustat.nice),
		(unsigned long long)cputime64_to_clock_t(kstat_cpu(cpu).cpustat.system),
		(unsigned long long)cputime64_to_clock_t(kstat_cpu(cpu).cpustat.softirq),
		(unsigned long long)cputime64_to_clock_t(kstat_cpu(cpu).cpustat.irq),
		(unsigned long long)cputime64_to_clock_t(kstat_cpu(cpu).cpustat.idle),
		(unsigned long long)cputime64_to_clock_t(kstat_cpu(cpu).cpustat.iowait),
		(unsigned long long)cputime64_to_clock_t(kstat_cpu(cpu).cpustat.steal));
}

static void print_kstat_01(struct seq_file *m, int cpu)
{
	int	index;
	for ( index = 0 ; index < NR_IRQS ; index++ ) {
		if (kstat_cpu(cpu).irqs[index] != 0) {
		   SEQ_printf(m, "cpu%02d %16s:%08d\n", cpu,
		      irq_desc_p[index].action ? irq_desc_p[index].action->name : irq_desc_p[index].name,
		      kstat_cpu(cpu).irqs[index]);
		}
	}

#if 0
	SEQ_printf(m, "  do_irq do_softirq sirq_defer netif_rx sirq_hi sirq_ti sirq_tx sirq_rx sirq_bl sirq_tk sirq_sh\n");
	// this stats reset every second, used for softlockup
	SEQ_printf(m, "%8d %10d %10lld %7d %7lld %7lld %7lld %7lld %7lld %7lld %7lld\n",
		kstat_cpu(cpu).do_irq_count,
		kstat_cpu(cpu).do_softirq_tot_count,
		kstat_cpu(cpu).softirq_deferred_count,
		kstat_cpu(cpu).from_netif_rx_ni_count,
		kstat_cpu(cpu).sirqstat[HI_SOFTIRQ].sum_time,
		kstat_cpu(cpu).sirqstat[TIMER_SOFTIRQ].sum_time,
		kstat_cpu(cpu).sirqstat[NET_TX_SOFTIRQ].sum_time,
		kstat_cpu(cpu).sirqstat[NET_RX_SOFTIRQ].sum_time,
		kstat_cpu(cpu).sirqstat[BLOCK_SOFTIRQ].sum_time,
		kstat_cpu(cpu).sirqstat[TASKLET_SOFTIRQ].sum_time,
		kstat_cpu(cpu).sirqstat[SCHED_SOFTIRQ].sum_time);
#endif
}

static void print_memory(struct seq_file *m)
{
	struct sysinfo	sinfo;
	int		a,b,c;

	si_swapinfo_p = (void *)kallsyms_lookup_name("si_swapinfo");
	if (si_swapinfo_p == NULL) {
		printk("si_swapinfo_p is NULL\n");
		return;
	}
	si_meminfo(&sinfo);
	si_swapinfo_p(&sinfo);

	a = avenrun[0] + (FIXED_1/200);
	b = avenrun[1] + (FIXED_1/200);
	c = avenrun[2] + (FIXED_1/200);

#define K(x) ((x) << (PAGE_SHIFT - 10))
#define M(x) (K(x) >> 10)
#define G(x) (M(x) >> 10)

	SEQ_printf(m, "Procs %d load %d.%02d %d.%02d %d.%02d\n",
		sinfo.procs, 
		LOAD_INT(a), LOAD_FRAC(a),
		LOAD_INT(b), LOAD_FRAC(b),
		LOAD_INT(c), LOAD_FRAC(c));
	SEQ_printf(m, "total(M)  free(M) buffers(M)  swap(M)  used(K)\n");
	SEQ_printf(m, "%8ld %8ld   %8ld %8ld %8ld\n",
		M(sinfo.totalram), M(sinfo.freeram), M(sinfo.bufferram), M(sinfo.totalswap),
		K((sinfo.totalswap - sinfo.freeswap)));
}

static int kthread_perf_main(void* data)
{
	// set up timer
	printk("ktperf data is %ld\n", (long) data);

	set_current_state(TASK_UNINTERRUPTIBLE);
	while (!kthread_should_stop())
	{
		//schedule();
		//print_cpu();
		// print_kstat(0);
		// print_memory();
		// wait_event_timeout()
		// run every 30 secs
		set_current_state(TASK_INTERRUPTIBLE);
		schedule_timeout(5 * HZ);
	}
	__set_current_state(TASK_RUNNING);

	// exit the loop, meaning remove the module

	printk("ktperf is exiting\n");

	return 0;
}

static int kthread_init()
{
	int	index = 0;

	ktperf = kthread_create(kthread_perf_main,
				(void *)(long)index,
				"ktperf");

	if (ktperf == NULL) {
		printk("kthread_create() failed\n");
		return -1;
	}

	printk("ktperf %p created\n", ktperf);
	wake_up_process(ktperf);

	return 0;
}

/* Seq operations for dd_kperf: start, show, next, stop */
static void *dd_kperf_seq_start(struct seq_file *seq, loff_t *pos)
{
	printk("dd_kperf_seq_start *pos %llu\n", *pos);

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
//	unsigned int  *cpu = (unsigned long *)v;

	printk("dd_kperf_seq_next\n");

#if 0
	if (++(*cpu) < num_online_cpus) {
		return &kperf_cpu;
	} else {
		(*pos)++;
		return NULL;
	}
#endif
	return NULL;
}

static void dd_kperf_seq_stop(struct seq_file *seq, void *v)
{
	printk("dd_kperf_seq_stop\n");
}

static int dd_kperf_seq_show(struct seq_file *seq, void *v)
{
//	unsigned int	*cpu = (int *) v;

	printk("dd_kperf_seq_show\n");

	print_cpus(seq);
	print_memory(seq);
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

	return count;
}

static void print_parameters()
{
	int	index;

	if (runq_array1_count) { 
		printk("runq_array1_count is %d\n", runq_array1_count);

		for ( index = 0 ; index < (sizeof(runq_array_1)/sizeof(long)) ; index++ ) {
			printk("runq_array_1[%d] = %lx\n", index, runq_array_1[index]);
		}
	}
	if (runq_array2_count) { 
		printk("runq_array2_count is %d\n", runq_array2_count);

		for ( index = 0 ; index < (sizeof(runq_array_2)/sizeof(long)) ; index++ ) {
			printk("runq_array_2[%d] = %lx\n", index, runq_array_2[index]);
		}
	}
	if (runq_array3_count) { 
		printk("runq_array3_count is %d\n", runq_array3_count);

		for ( index = 0 ; index < (sizeof(runq_array_3)/sizeof(long)) ; index++ ) {
			printk("runq_array_3[%d] = %lx\n", index, runq_array_3[index]);
		}
	}
	if (runq_array4_count) { 
		printk("runq_array4_count is %d\n", runq_array4_count);

		for ( index = 0 ; index < (sizeof(runq_array_4)/sizeof(long)) ; index++ ) {
			printk("runq_array_4[%d] = %lx\n", index, runq_array_4[index]);
		}
	}
	if (runq_array5_count) { 
		printk("runq_array5_count is %d\n", runq_array5_count);

		for ( index = 0 ; index < (sizeof(runq_array_5)/sizeof(long)) ; index++ ) {
			printk("runq_array_5[%d] = %lx\n", index, runq_array_5[index]);
		}
	}

}

static struct file_operations dd_kperf_fops = {
	.owner		= THIS_MODULE,
	.open		= dd_kperf_open,
	.read		= seq_read,
	.llseek		= seq_lseek,
	.release	= seq_release,
	.write		= dd_kperf_write,
};

static int kperf_runq_init(void)
{
	int			cpu_index;
	unsigned long		sym_per_cpu_runq;
	struct rq		*rq_addr;

	sym_per_cpu_runq = (unsigned long)kallsyms_lookup_name("per_cpu__runqueues");

	printk("sym_per_cpu_runq 0x%lx\n", sym_per_cpu_runq);

	for_each_online_cpu(cpu_index) {
		rq_addr = (struct rq *)(_cpu_pda[cpu_index]->data_offset + sym_per_cpu_runq);
		printk("cpu%d runq 0x%p\n", cpu_index, rq_addr);
	}
}

static int __init my_init(void)
{
	int	ret = -1;

	print_parameters();

	kperf_runq_init();

	num_runqs = runq_array1_count + runq_array2_count + runq_array3_count +
			runq_array4_count + runq_array5_count;

	printk("given runq number is %d\n", num_runqs);

	if (ret = kthread_init()) {
		goto error;
	}

	irq_desc_p = (void *)kallsyms_lookup_name("irq_desc");
	if (irq_desc_p == NULL) {
		printk("irq_desc_p is NULL\n");
		goto error;
	}

	ktperf_proc = create_proc_entry("dd_kperf", S_IRUGO|S_IWUSR, NULL);
	if (ktperf_proc == NULL) {
		goto error;
	}
	ktperf_proc->proc_fops = &dd_kperf_fops;

	return 0;

error:
	if (ktperf != NULL) {
		kthread_stop(ktperf);
		ktperf = NULL;
	}

	if (ktperf_proc != NULL) {
		remove_proc_entry("dd_kperf", NULL);
		ktperf_proc = NULL;
	}

	return ret;
}

static void __exit my_exit(void)
{

	if (ktperf != NULL) {
		kthread_stop(ktperf);
		ktperf = NULL;
	}

	if (ktperf_proc != NULL) {
		remove_proc_entry("dd_kperf", NULL);
		ktperf_proc = NULL;
	}

	printk(KERN_INFO "\ndd_kperf free\n");
}

module_init(my_init);
module_exit(my_exit);

MODULE_LICENSE("GPL");