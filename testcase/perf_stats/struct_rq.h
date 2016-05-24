#include <linux/list.h>
#include <asm/atomic.h>

struct load_stat {
	struct load_weight load;
	u64 load_update_start, load_update_last;
	unsigned long delta_fair, delta_exec, delta_stat;
};

struct cfs_rq {
	char pad[112];
};

struct rt_rq {
	char pad[1640];
};

struct rq {
	spinlock_t lock;	/* runqueue lock */

	/*
	 * nr_running and cpu_load should be in the same cacheline because
	 * remote CPUs use both these fields when doing load calculation.
	 */
	unsigned long nr_running;
	#define CPU_LOAD_IDX_MAX 5
	unsigned long cpu_load[CPU_LOAD_IDX_MAX];
	unsigned char idle_at_tick;

	struct load_stat ls;	/* capture load from *all* tasks on this cpu */
	unsigned long nr_load_updates;
	u64 nr_switches;

	struct cfs_rq cfs;

	struct rt_rq  rt;

	/*
	 * This is part of a global counter where only the total sum
	 * over all CPUs matters. A task can increase this counter on
	 * one CPU and if it got migrated afterwards it may decrease
	 * it on another CPU. Always updated under the runqueue lock:
	 */
	unsigned long nr_uninterruptible;

	struct task_struct *curr, *idle;
	unsigned long next_balance;
	struct mm_struct *prev_mm;

	u64 clock, prev_clock_raw;
	s64 clock_max_delta;

	unsigned int clock_warps, clock_overflows;
	u64 idle_clock;
	unsigned int clock_deep_idle_events;
	u64 tick_timestamp;

	atomic_t nr_iowait;

#ifdef CONFIG_SMP
	struct sched_domain *sd;

	/* For active balancing */
	int active_balance;
	int push_cpu;
	int cpu;		/* cpu of this runqueue */

	struct task_struct *migration_thread;
	struct list_head migration_queue;
#endif

#ifdef CONFIG_SCHEDSTATS
	/* latency stats */
	struct sched_info rq_sched_info;

	/* sys_sched_yield() stats */
	unsigned long yld_exp_empty;
	unsigned long yld_act_empty;
	unsigned long yld_both_empty;
	unsigned long yld_cnt;

	/* schedule() stats */
	unsigned long sched_switch;
	unsigned long sched_cnt;
	unsigned long sched_goidle;

	/* try_to_wake_up() stats */
	unsigned long ttwu_cnt;
	unsigned long ttwu_local;
#endif
	struct lock_class_key rq_lock_key;
};

