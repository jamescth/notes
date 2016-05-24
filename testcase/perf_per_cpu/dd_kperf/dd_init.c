#include <linux/percpu.h>
#include <linux/kallsyms.h>		// kallsyms_lookup_name()
#include <linux/sched.h>		// sched_clock()
#include <linux/cpumask.h>		// for_each_online_cpu()
#include <asm-x86_64/pda.h>		// cpu_pda()
#include <linux/slab.h>			// kmalloc()
#include "dd_kperf.h"

struct dd_kperf_percpu *dd_kperf_percpu_pt;

static int mem_init(void);

static int mem_init()
{
	int		cpu;

	for_each_online_cpu(cpu) {
		struct dd_kperf_percpu	*ptr = per_cpu_ptr(dd_kperf_percpu_pt, cpu);

		ptr->dd_kp_buf = kmalloc(GFP_KERNEL, ALLOCATED_SIZE);

		if (NULL == ptr->dd_kp_buf) {
			ptr->dd_kp_bufsize = 0;
			return -1;
		} else {
			ptr->dd_kp_bufsize = ALLOCATED_SIZE;
		}
		ptr->dd_kp_index = 0;
		ptr->dd_kp_ver = 1;

		printk("cpu %d pt %p\n", cpu, ptr);
	}
	return 0;
}

static int __init my_init(void)
{
	int	ret = 0;
	int		cpu;

	// per cpu
	dd_kperf_percpu_pt = __alloc_percpu(sizeof(struct dd_kperf_percpu));
	if (dd_kperf_percpu_pt == NULL) {
		printk("alloc_percpu() failed\n");
		ret = -ENOMEM;
		goto init_error;
	}
	printk("dd_kperf_percpu_pt %p\n", dd_kperf_percpu_pt);

	if (mem_init()) {
		ret = -ENOMEM;
		goto init_error;
	}

	dd_kprobe_init();

	test();
	return ret;

init_error:
	// free buf 
	for_each_online_cpu(cpu) {
		struct dd_kperf_percpu	*ptr = per_cpu_ptr(dd_kperf_percpu_pt, cpu);
		if (ptr->dd_kp_buf) {
			printk("free cpu %d\n", cpu);
			kfree(ptr->dd_kp_buf);
		}
	}

	// free per cpu mem the last
	if (dd_kperf_percpu_pt)
		free_percpu(dd_kperf_percpu_pt);
	return ret;
}

static void __exit my_exit(void)
{
	int	cpu;
	for_each_online_cpu(cpu) {
		struct dd_kperf_percpu	*ptr = per_cpu_ptr(dd_kperf_percpu_pt, cpu);
		if (ptr->dd_kp_buf) {
			printk("free cpu %d\n", cpu);
			kfree(ptr->dd_kp_buf);
		}
	}

	if (dd_kperf_percpu_pt) {
		free_percpu(dd_kperf_percpu_pt);
		printk("dd_kperf_percpu_pt freed\n");
	}

	dd_kprobe_exit();
}

module_init(my_init);
module_exit(my_exit);

MODULE_LICENSE("GPL");
