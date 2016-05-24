/*
 * This module measure how much time a kernel function takes.
 * The time is measure in jiffies (/1000 to get sec). 
 *
 * The result is print in kern.info
 *
 * required files:
 * build.sh
 * Makefile
 * slab_trace.c
 * run_ddump
 *
 * run build.sh to build ddump_module.ko.
 * modify Makefile for wherever the kernel build is.
 *
 * run_ddump scan /proc/kallsyms to match up the given 
 * kernel symbol.  Pass the obtained address to 
 * ddump_module.ko when the module is inserted.
 *
 * cp ddump_module.ko & run_ddump to test machine.
 *
 * on test machine:
 * run_ddump <kernel symbol>
 */

#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/sched.h>
#include <linux/kprobes.h>

#include <linux/ctype.h>	// isdigit()
#include <linux/list.h>		// list_for_each()

#include <linux/types.h>	// gfp_t
#include <linux/spinlock_types.h>	// spinlock_t
#include <asm/atomic.h>		// atomic_t
#include <linux/numa.h>		// MAX_NUMNODES

#define READ	0
#define WRITE	1

// use 'grep block_subsys /proc/kallsyms to get the value
static long cache_alloc_refill_addr;
module_param(cache_alloc_refill_addr, long, 0000);

static bool		is_cache_alloc_refill = false;
static bool		is_kret_cache_alloc_refill = false;

static struct kprobe	kp_cache_alloc_refill;
static struct kretprobe	kret_cache_alloc_refill;

typedef unsigned int kmem_bufctl_t;

struct slab {
	struct list_head list;
	unsigned long colouroff;
	void *s_mem;		/* including colour offset */
	unsigned int inuse;	/* num of objs active in slab */
	kmem_bufctl_t free;
	unsigned short nodeid;
};

struct array_cache {
	unsigned int avail;
	unsigned int limit;
	unsigned int batchcount;
	unsigned int touched;
	spinlock_t lock;
	void *entry[0];	/*
			 * Must have this definition in here for the proper
			 * alignment of array_cache. Also simplifies accessing
			 * the entries.
			 * [0] is for gcc 2.95. It should really be [].
			 */
};

struct kmem_list3 {
	struct list_head slabs_partial;	/* partial list first, better asm code */
	struct list_head slabs_full;
	struct list_head slabs_free;
	unsigned long free_objects;
	unsigned int free_limit;
	unsigned int colour_next;	/* Per-node cache coloring */
	spinlock_t list_lock;
	struct array_cache *shared;	/* shared per node */
	struct array_cache **alien;	/* on other nodes */
	unsigned long next_reap;	/* updated without locking */
	int free_touched;		/* updated without locking */
};

struct kmem_cache {
/* 1) per-cpu data, touched during every alloc/free */
	struct array_cache *array[NR_CPUS];
/* 2) Cache tunables. Protected by cache_chain_mutex */
	unsigned int batchcount;
	unsigned int limit;
	unsigned int shared;

	unsigned int buffer_size;
	u32 reciprocal_buffer_size;
/* 3) touched by every alloc & free from the backend */

	unsigned int flags;		/* constant flags */
	unsigned int num;		/* # of objs per slab */

/* 4) cache_grow/shrink */
	/* order of pgs per slab (2^n) */
	unsigned int gfporder;

	/* force GFP flags, e.g. GFP_DMA */
	gfp_t gfpflags;

	size_t colour;			/* cache colouring range */
	unsigned int colour_off;	/* colour offset */
	struct kmem_cache *slabp_cache;
	unsigned int slab_size;
	unsigned int dflags;		/* dynamic flags */

	/* constructor func */
	void (*ctor) (void *, struct kmem_cache *, unsigned long);

/* 5) cache creation/removal */
	const char *name;
	struct list_head next;

/* 6) statistics */
#if STATS
	unsigned long num_active;
	unsigned long num_allocations;
	unsigned long high_mark;
	unsigned long grown;
	unsigned long reaped;
	unsigned long errors;
	unsigned long max_freeable;
	unsigned long node_allocs;
	unsigned long node_frees;
	unsigned long node_overflow;
	atomic_t allochit;
	atomic_t allocmiss;
	atomic_t freehit;
	atomic_t freemiss;
#endif
#if DEBUG
	/*
	 * If debugging is enabled, then the allocator can add additional
	 * fields and/or padding to every object. buffer_size contains the total
	 * object size including these internal fields, the following two
	 * variables contain the offset to the user object and its size.
	 */
	int obj_offset;
	int obj_size;
#endif
	/*
	 * We put nodelists[] at the end of kmem_cache, because we want to size
	 * this array to nr_node_ids slots instead of MAX_NUMNODES
	 * (see kmem_cache_init())
	 * We still use [MAX_NUMNODES] and not [1] or [0] because cache_cache
	 * is statically defined, so we reserve the max number of nodes.
	 */
	struct kmem_list3 *nodelists[MAX_NUMNODES];
	/*
	 * Do not add fields after nodelists[]
	 */
};

static int
cache_alloc_refill_pre_handler(struct kprobe *kp, struct pt_regs *regs)
{
	//struct file	*filp = (struct file *) regs->rdi;
	int		ret;

	//if (filp == NULL) {
	//	printk("fs_probe filp is NULL\n");
	//	return -1;
	//}
	// ret = check_hu(filp, READ);
	// if (ret) {
		// printk("fs_probe check_hu ret %d\n", ret);
	//}

	return 0;
}


static int
kret_cache_alloc_refill_handler(struct kretprobe_instance *ri, struct pt_regs *regs)
{
	long	ret = (long) regs->rax;

	return 0;
}

// The probed addr is given by the user script
// The user script scan /proc/kallsyms
int init_module(void)
{
	int		ret;

	if (NULL == (long *)cache_alloc_refill_addr ) {
		printk("must provide an block_subsys addr\n");
		printk("use 'grep block_subsys /proc/kallsyms' to get addr\n");
		printk("insmod <mod>cache_alloc_refill_addr=0x<addr>\n");
		return -1;
	} else {
		printk("cache_alloc_refill_addr is %lx\n", 
			cache_alloc_refill_addr);

		// kprobe
		kp_cache_alloc_refill.pre_handler = 
			cache_alloc_refill_pre_handler;
		kp_cache_alloc_refill.addr =
			(kprobe_opcode_t *)cache_alloc_refill_addr;

		if ((ret = register_kprobe(&kp_cache_alloc_refill)) < 0) {
			printk("register_kprobe failed, ret %d\n", ret);
			return ret;
		}

		is_cache_alloc_refill = true;
		printk("probing cache_alloc_refill\n");

		// kretprobe
		kret_cache_alloc_refill.handler = 
			kret_cache_alloc_refill_handler;
		kret_cache_alloc_refill.kp.addr =
			(kprobe_opcode_t *)cache_alloc_refill_addr;

		if ((ret = register_kretprobe(&kret_cache_alloc_refill)) < 0) {
			printk("register_kretprobe failed, ret %d\n", ret);
			return ret;
		}

		is_kret_cache_alloc_refill = true;
		printk("kretprobing cache_alloc_refill\n");

	}

	return 0;
}

void cleanup_module(void)
{
	if (is_cache_alloc_refill) {
		unregister_kprobe(&kp_cache_alloc_refill);
		printk("kprobe unregistered\n");

	}

	if (is_kret_cache_alloc_refill) {
		unregister_kretprobe(&kret_cache_alloc_refill);
		printk("kretprobe unregistered\n");

	}
}

MODULE_LICENSE("GPL");
