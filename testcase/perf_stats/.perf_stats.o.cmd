cmd_/auto/home5/hoj9/testcase/perf_stats/perf_stats.o := /auto/home/lsbuild/desktop-380131/usr/local/gcc-4.5.1/bin/gcc -Wp,-MD,/auto/home5/hoj9/testcase/perf_stats/.perf_stats.o.d  -nostdinc -isystem /auto/toolset_nfs/toolchain/desktop-380131/usr/local/gcc-4.5.1/bin/../lib/gcc/x86_64-unknown-linux-gnu/4.5.1/include -D__KERNEL__ -I/p4/main/platform/os/linux-2.6.23/include -I/p4/main/platform/os/linux-2.6.23 -I/p4/main/platform/os/linux-2.6.23  -include include/linux/autoconf.h -Wall -Wundef -Wstrict-prototypes -Wno-trigraphs -fno-strict-aliasing -fno-common -Werror-implicit-function-declaration -Os  -march=core2 -m64 -mno-red-zone -mcmodel=kernel -pipe -Wno-sign-compare -fno-asynchronous-unwind-tables -funit-at-a-time -mno-sse -mno-mmx -mno-sse2 -mno-3dnow -maccumulate-outgoing-args -DCONFIG_AS_CFI=1  -fomit-frame-pointer -g -Wdeclaration-after-statement -Wno-pointer-sign    -DMODULE -D"KBUILD_STR(s)=\#s" -D"KBUILD_BASENAME=KBUILD_STR(perf_stats)"  -D"KBUILD_MODNAME=KBUILD_STR(perf_stats)" -c -o /auto/home5/hoj9/testcase/perf_stats/perf_stats.o /auto/home5/hoj9/testcase/perf_stats/perf_stats.c

deps_/auto/home5/hoj9/testcase/perf_stats/perf_stats.o := \
  /auto/home5/hoj9/testcase/perf_stats/perf_stats.c \
  /p4/main/platform/os/linux-2.6.23/include/linux/kernel.h \
    $(wildcard include/config/preempt/voluntary.h) \
    $(wildcard include/config/debug/spinlock/sleep.h) \
    $(wildcard include/config/printk.h) \
    $(wildcard include/config/ddr.h) \
    $(wildcard include/config/numa.h) \
  /auto/toolset_nfs/toolchain/desktop-380131/usr/local/gcc-4.5.1/bin/../lib/gcc/x86_64-unknown-linux-gnu/4.5.1/include/stdarg.h \
  /p4/main/platform/os/linux-2.6.23/include/linux/linkage.h \
  /p4/main/platform/os/linux-2.6.23/include/asm/linkage.h \
  /p4/main/platform/os/linux-2.6.23/include/linux/stddef.h \
  /p4/main/platform/os/linux-2.6.23/include/linux/compiler.h \
    $(wildcard include/config/enable/must/check.h) \
  /p4/main/platform/os/linux-2.6.23/include/linux/compiler-gcc4.h \
    $(wildcard include/config/forced/inlining.h) \
  /p4/main/platform/os/linux-2.6.23/include/linux/compiler-gcc.h \
  /p4/main/platform/os/linux-2.6.23/include/linux/types.h \
    $(wildcard include/config/uid16.h) \
    $(wildcard include/config/lbd.h) \
    $(wildcard include/config/lsf.h) \
    $(wildcard include/config/resources/64bit.h) \
  /p4/main/platform/os/linux-2.6.23/include/linux/posix_types.h \
  /p4/main/platform/os/linux-2.6.23/include/asm/posix_types.h \
  /p4/main/platform/os/linux-2.6.23/include/asm/types.h \
  /p4/main/platform/os/linux-2.6.23/include/linux/bitops.h \
  /p4/main/platform/os/linux-2.6.23/include/asm/bitops.h \
  /p4/main/platform/os/linux-2.6.23/include/asm/alternative.h \
    $(wildcard include/config/smp.h) \
    $(wildcard include/config/paravirt.h) \
  /p4/main/platform/os/linux-2.6.23/include/asm/cpufeature.h \
  /p4/main/platform/os/linux-2.6.23/include/asm-i386/cpufeature.h \
  /p4/main/platform/os/linux-2.6.23/include/asm/required-features.h \
    $(wildcard include/config/x86/use/3dnow.h) \
  /p4/main/platform/os/linux-2.6.23/include/asm-generic/bitops/sched.h \
  /p4/main/platform/os/linux-2.6.23/include/asm-generic/bitops/hweight.h \
  /p4/main/platform/os/linux-2.6.23/include/asm-generic/bitops/ext2-non-atomic.h \
  /p4/main/platform/os/linux-2.6.23/include/asm-generic/bitops/le.h \
  /p4/main/platform/os/linux-2.6.23/include/asm/byteorder.h \
  /p4/main/platform/os/linux-2.6.23/include/linux/byteorder/little_endian.h \
  /p4/main/platform/os/linux-2.6.23/include/linux/byteorder/swab.h \
  /p4/main/platform/os/linux-2.6.23/include/linux/byteorder/generic.h \
  /p4/main/platform/os/linux-2.6.23/include/asm-generic/bitops/minix.h \
  /p4/main/platform/os/linux-2.6.23/include/linux/log2.h \
    $(wildcard include/config/arch/has/ilog2/u32.h) \
    $(wildcard include/config/arch/has/ilog2/u64.h) \
  /p4/main/platform/os/linux-2.6.23/include/asm/bug.h \
    $(wildcard include/config/bug.h) \
    $(wildcard include/config/debug/bugverbose.h) \
  /p4/main/platform/os/linux-2.6.23/include/asm-generic/bug.h \
    $(wildcard include/config/generic/bug.h) \
  /p4/main/platform/os/linux-2.6.23/include/linux/module.h \
    $(wildcard include/config/modules.h) \
    $(wildcard include/config/modversions.h) \
    $(wildcard include/config/unused/symbols.h) \
    $(wildcard include/config/module/unload.h) \
    $(wildcard include/config/kallsyms.h) \
    $(wildcard include/config/gcov/profile.h) \
    $(wildcard include/config/sysfs.h) \
  /p4/main/platform/os/linux-2.6.23/include/linux/list.h \
    $(wildcard include/config/debug/list.h) \
  /p4/main/platform/os/linux-2.6.23/include/linux/poison.h \
  /p4/main/platform/os/linux-2.6.23/include/linux/prefetch.h \
  /p4/main/platform/os/linux-2.6.23/include/asm/processor.h \
    $(wildcard include/config/x86/vsmp.h) \
  /p4/main/platform/os/linux-2.6.23/include/asm/segment.h \
  /p4/main/platform/os/linux-2.6.23/include/asm/cache.h \
    $(wildcard include/config/x86/l1/cache/shift.h) \
  /p4/main/platform/os/linux-2.6.23/include/asm/page.h \
    $(wildcard include/config/physical/start.h) \
    $(wildcard include/config/flatmem.h) \
  /p4/main/platform/os/linux-2.6.23/include/linux/const.h \
  /p4/main/platform/os/linux-2.6.23/include/asm-generic/memory_model.h \
    $(wildcard include/config/discontigmem.h) \
    $(wildcard include/config/sparsemem.h) \
    $(wildcard include/config/out/of/line/pfn/to/page.h) \
  /p4/main/platform/os/linux-2.6.23/include/asm-generic/page.h \
  /p4/main/platform/os/linux-2.6.23/include/asm/sigcontext.h \
  /p4/main/platform/os/linux-2.6.23/include/linux/threads.h \
    $(wildcard include/config/nr/cpus.h) \
    $(wildcard include/config/base/small.h) \
  /p4/main/platform/os/linux-2.6.23/include/asm/msr.h \
    $(wildcard include/config/x86/64.h) \
  /p4/main/platform/os/linux-2.6.23/include/asm/msr-index.h \
  /p4/main/platform/os/linux-2.6.23/include/asm-i386/msr-index.h \
  /p4/main/platform/os/linux-2.6.23/include/linux/errno.h \
  /p4/main/platform/os/linux-2.6.23/include/asm/errno.h \
  /p4/main/platform/os/linux-2.6.23/include/asm-generic/errno.h \
  /p4/main/platform/os/linux-2.6.23/include/asm-generic/errno-base.h \
  /p4/main/platform/os/linux-2.6.23/include/asm/current.h \
  /p4/main/platform/os/linux-2.6.23/include/asm/pda.h \
    $(wildcard include/config/cc/stackprotector.h) \
  /p4/main/platform/os/linux-2.6.23/include/linux/cache.h \
  /p4/main/platform/os/linux-2.6.23/include/asm/system.h \
    $(wildcard include/config/unordered/io.h) \
  /p4/main/platform/os/linux-2.6.23/include/asm/cmpxchg.h \
  /p4/main/platform/os/linux-2.6.23/include/linux/irqflags.h \
    $(wildcard include/config/trace/irqflags.h) \
    $(wildcard include/config/trace/irqflags/support.h) \
    $(wildcard include/config/x86.h) \
  /p4/main/platform/os/linux-2.6.23/include/asm/irqflags.h \
  /p4/main/platform/os/linux-2.6.23/include/asm/processor-flags.h \
  /p4/main/platform/os/linux-2.6.23/include/asm-i386/processor-flags.h \
  /p4/main/platform/os/linux-2.6.23/include/asm/mmsegment.h \
  /p4/main/platform/os/linux-2.6.23/include/asm/percpu.h \
  /p4/main/platform/os/linux-2.6.23/include/linux/personality.h \
  /p4/main/platform/os/linux-2.6.23/include/linux/cpumask.h \
    $(wildcard include/config/hotplug/cpu.h) \
  /p4/main/platform/os/linux-2.6.23/include/linux/bitmap.h \
  /p4/main/platform/os/linux-2.6.23/include/linux/string.h \
  /p4/main/platform/os/linux-2.6.23/include/asm/string.h \
  /p4/main/platform/os/linux-2.6.23/include/linux/stat.h \
  /p4/main/platform/os/linux-2.6.23/include/asm/stat.h \
  /p4/main/platform/os/linux-2.6.23/include/linux/time.h \
  /p4/main/platform/os/linux-2.6.23/include/linux/seqlock.h \
  /p4/main/platform/os/linux-2.6.23/include/linux/spinlock.h \
    $(wildcard include/config/debug/spinlock.h) \
    $(wildcard include/config/preempt.h) \
    $(wildcard include/config/debug/lock/alloc.h) \
  /p4/main/platform/os/linux-2.6.23/include/linux/preempt.h \
    $(wildcard include/config/debug/preempt.h) \
    $(wildcard include/config/preempt/notifiers.h) \
  /p4/main/platform/os/linux-2.6.23/include/linux/thread_info.h \
  /p4/main/platform/os/linux-2.6.23/include/asm/thread_info.h \
    $(wildcard include/config/debug/stack/usage.h) \
  /p4/main/platform/os/linux-2.6.23/include/linux/stringify.h \
  /p4/main/platform/os/linux-2.6.23/include/linux/bottom_half.h \
  /p4/main/platform/os/linux-2.6.23/include/linux/spinlock_types.h \
  /p4/main/platform/os/linux-2.6.23/include/asm/spinlock_types.h \
  /p4/main/platform/os/linux-2.6.23/include/linux/lockdep.h \
    $(wildcard include/config/lockdep.h) \
    $(wildcard include/config/lock/stat.h) \
    $(wildcard include/config/generic/hardirqs.h) \
    $(wildcard include/config/prove/locking.h) \
  /p4/main/platform/os/linux-2.6.23/include/asm/spinlock.h \
  /p4/main/platform/os/linux-2.6.23/include/asm/atomic.h \
  /p4/main/platform/os/linux-2.6.23/include/asm-generic/atomic.h \
  /p4/main/platform/os/linux-2.6.23/include/asm/rwlock.h \
  /p4/main/platform/os/linux-2.6.23/include/linux/spinlock_api_smp.h \
  /p4/main/platform/os/linux-2.6.23/include/linux/kmod.h \
    $(wildcard include/config/kmod.h) \
  /p4/main/platform/os/linux-2.6.23/include/linux/elf.h \
  /p4/main/platform/os/linux-2.6.23/include/linux/auxvec.h \
  /p4/main/platform/os/linux-2.6.23/include/asm/auxvec.h \
  /p4/main/platform/os/linux-2.6.23/include/linux/elf-em.h \
  /p4/main/platform/os/linux-2.6.23/include/asm/elf.h \
  /p4/main/platform/os/linux-2.6.23/include/asm/ptrace.h \
  /p4/main/platform/os/linux-2.6.23/include/asm/ptrace-abi.h \
  /p4/main/platform/os/linux-2.6.23/include/asm/user.h \
  /p4/main/platform/os/linux-2.6.23/include/linux/kobject.h \
    $(wildcard include/config/hotplug.h) \
  /p4/main/platform/os/linux-2.6.23/include/linux/sysfs.h \
  /p4/main/platform/os/linux-2.6.23/include/linux/kref.h \
  /p4/main/platform/os/linux-2.6.23/include/linux/wait.h \
  /p4/main/platform/os/linux-2.6.23/include/linux/moduleparam.h \
  /p4/main/platform/os/linux-2.6.23/include/linux/init.h \
    $(wildcard include/config/memory/hotplug.h) \
    $(wildcard include/config/acpi/hotplug/memory.h) \
  /p4/main/platform/os/linux-2.6.23/include/asm/local.h \
  /p4/main/platform/os/linux-2.6.23/include/linux/percpu.h \
  /p4/main/platform/os/linux-2.6.23/include/linux/slab.h \
    $(wildcard include/config/slab/debug.h) \
    $(wildcard include/config/slub.h) \
    $(wildcard include/config/slob.h) \
    $(wildcard include/config/debug/slab.h) \
  /p4/main/platform/os/linux-2.6.23/include/linux/gfp.h \
    $(wildcard include/config/zone/dma.h) \
    $(wildcard include/config/zone/dma32.h) \
    $(wildcard include/config/highmem.h) \
  /p4/main/platform/os/linux-2.6.23/include/linux/mmzone.h \
    $(wildcard include/config/force/max/zoneorder.h) \
    $(wildcard include/config/arch/populates/node/map.h) \
    $(wildcard include/config/flat/node/mem/map.h) \
    $(wildcard include/config/have/memory/present.h) \
    $(wildcard include/config/need/node/memmap/size.h) \
    $(wildcard include/config/need/multiple/nodes.h) \
    $(wildcard include/config/have/arch/early/pfn/to/nid.h) \
    $(wildcard include/config/sparsemem/extreme.h) \
    $(wildcard include/config/nodes/span/other/nodes.h) \
    $(wildcard include/config/holes/in/zone.h) \
  /p4/main/platform/os/linux-2.6.23/include/linux/numa.h \
    $(wildcard include/config/nodes/shift.h) \
  /p4/main/platform/os/linux-2.6.23/include/linux/nodemask.h \
  /p4/main/platform/os/linux-2.6.23/include/linux/memory_hotplug.h \
    $(wildcard include/config/have/arch/nodedata/extension.h) \
  /p4/main/platform/os/linux-2.6.23/include/linux/notifier.h \
  /p4/main/platform/os/linux-2.6.23/include/linux/mutex.h \
    $(wildcard include/config/debug/mutexes.h) \
  /p4/main/platform/os/linux-2.6.23/include/linux/rwsem.h \
    $(wildcard include/config/rwsem/generic/spinlock.h) \
  /p4/main/platform/os/linux-2.6.23/include/linux/rwsem-spinlock.h \
  /p4/main/platform/os/linux-2.6.23/include/linux/srcu.h \
  /p4/main/platform/os/linux-2.6.23/include/linux/topology.h \
    $(wildcard include/config/sched/smt.h) \
    $(wildcard include/config/sched/mc.h) \
  /p4/main/platform/os/linux-2.6.23/include/linux/smp.h \
  /p4/main/platform/os/linux-2.6.23/include/asm/smp.h \
  /p4/main/platform/os/linux-2.6.23/include/asm/mpspec.h \
    $(wildcard include/config/acpi.h) \
  /p4/main/platform/os/linux-2.6.23/include/asm/apic.h \
    $(wildcard include/config/x86/good/apic.h) \
  /p4/main/platform/os/linux-2.6.23/include/linux/pm.h \
    $(wildcard include/config/suspend.h) \
    $(wildcard include/config/pm/sleep.h) \
  /p4/main/platform/os/linux-2.6.23/include/linux/delay.h \
  /p4/main/platform/os/linux-2.6.23/include/asm/delay.h \
  /p4/main/platform/os/linux-2.6.23/include/asm/fixmap.h \
  /p4/main/platform/os/linux-2.6.23/include/asm/apicdef.h \
  /p4/main/platform/os/linux-2.6.23/include/asm/vsyscall.h \
    $(wildcard include/config/generic/time.h) \
  /p4/main/platform/os/linux-2.6.23/include/asm/io_apic.h \
  /p4/main/platform/os/linux-2.6.23/include/asm/topology.h \
    $(wildcard include/config/acpi/numa.h) \
  /p4/main/platform/os/linux-2.6.23/include/asm-generic/topology.h \
  /p4/main/platform/os/linux-2.6.23/include/asm/mmzone.h \
    $(wildcard include/config/numa/emu.h) \
  /p4/main/platform/os/linux-2.6.23/include/linux/slab_def.h \
  /p4/main/platform/os/linux-2.6.23/include/linux/kmalloc_sizes.h \
  /p4/main/platform/os/linux-2.6.23/include/asm/module.h \
  /p4/main/platform/os/linux-2.6.23/include/linux/fs.h \
    $(wildcard include/config/dnotify.h) \
    $(wildcard include/config/quota.h) \
    $(wildcard include/config/inotify.h) \
    $(wildcard include/config/security.h) \
    $(wildcard include/config/epoll.h) \
    $(wildcard include/config/auditsyscall.h) \
    $(wildcard include/config/block.h) \
    $(wildcard include/config/fs/xip.h) \
    $(wildcard include/config/migration.h) \
  /p4/main/platform/os/linux-2.6.23/include/linux/limits.h \
  /p4/main/platform/os/linux-2.6.23/include/linux/ioctl.h \
  /p4/main/platform/os/linux-2.6.23/include/asm/ioctl.h \
  /p4/main/platform/os/linux-2.6.23/include/asm-generic/ioctl.h \
  /p4/main/platform/os/linux-2.6.23/include/linux/kdev_t.h \
  /p4/main/platform/os/linux-2.6.23/include/linux/dcache.h \
    $(wildcard include/config/profiling.h) \
  /p4/main/platform/os/linux-2.6.23/include/linux/rcupdate.h \
  /p4/main/platform/os/linux-2.6.23/include/linux/namei.h \
  /p4/main/platform/os/linux-2.6.23/include/linux/radix-tree.h \
  /p4/main/platform/os/linux-2.6.23/include/linux/prio_tree.h \
  /p4/main/platform/os/linux-2.6.23/include/linux/pid.h \
  /p4/main/platform/os/linux-2.6.23/include/linux/sysctl.h \
  /p4/main/platform/os/linux-2.6.23/include/linux/capability.h \
  /p4/main/platform/os/linux-2.6.23/include/asm/semaphore.h \
  /p4/main/platform/os/linux-2.6.23/include/linux/quota.h \
  /p4/main/platform/os/linux-2.6.23/include/linux/dqblk_xfs.h \
  /p4/main/platform/os/linux-2.6.23/include/linux/dqblk_v1.h \
  /p4/main/platform/os/linux-2.6.23/include/linux/dqblk_v2.h \
  /p4/main/platform/os/linux-2.6.23/include/linux/nfs_fs_i.h \
  /p4/main/platform/os/linux-2.6.23/include/linux/nfs.h \
  /p4/main/platform/os/linux-2.6.23/include/linux/sunrpc/msg_prot.h \
  /p4/main/platform/os/linux-2.6.23/include/linux/fcntl.h \
  /p4/main/platform/os/linux-2.6.23/include/asm/fcntl.h \
  /p4/main/platform/os/linux-2.6.23/include/asm-generic/fcntl.h \
    $(wildcard include/config/64bit.h) \
  /p4/main/platform/os/linux-2.6.23/include/linux/err.h \
  /p4/main/platform/os/linux-2.6.23/include/linux/seq_file.h \
  /p4/main/platform/os/linux-2.6.23/include/linux/proc_fs.h \
    $(wildcard include/config/proc/fs.h) \
    $(wildcard include/config/proc/devicetree.h) \
    $(wildcard include/config/proc/kcore.h) \
    $(wildcard include/config/mmu.h) \
  /p4/main/platform/os/linux-2.6.23/include/linux/magic.h \
  /p4/main/platform/os/linux-2.6.23/include/linux/kprobes.h \
    $(wildcard include/config/kprobes.h) \
  /p4/main/platform/os/linux-2.6.23/include/asm/kprobes.h \
  /p4/main/platform/os/linux-2.6.23/include/linux/ptrace.h \
  /p4/main/platform/os/linux-2.6.23/include/linux/sched.h \
    $(wildcard include/config/sched/debug.h) \
    $(wildcard include/config/no/hz.h) \
    $(wildcard include/config/detect/softlockup.h) \
    $(wildcard include/config/split/ptlock/cpus.h) \
    $(wildcard include/config/cgroup/mem/res/ctlr.h) \
    $(wildcard include/config/keys.h) \
    $(wildcard include/config/bsd/process/acct.h) \
    $(wildcard include/config/taskstats.h) \
    $(wildcard include/config/audit.h) \
    $(wildcard include/config/inotify/user.h) \
    $(wildcard include/config/schedstats.h) \
    $(wildcard include/config/task/delay/acct.h) \
    $(wildcard include/config/fair/group/sched.h) \
    $(wildcard include/config/blk/dev/io/trace.h) \
    $(wildcard include/config/sysvipc.h) \
    $(wildcard include/config/rt/mutexes.h) \
    $(wildcard include/config/task/xacct.h) \
    $(wildcard include/config/cpusets.h) \
    $(wildcard include/config/cgroups.h) \
    $(wildcard include/config/compat.h) \
    $(wildcard include/config/fault/injection.h) \
  /p4/main/platform/os/linux-2.6.23/include/asm/param.h \
    $(wildcard include/config/hz.h) \
  /p4/main/platform/os/linux-2.6.23/include/linux/timex.h \
  /p4/main/platform/os/linux-2.6.23/include/asm/timex.h \
  /p4/main/platform/os/linux-2.6.23/include/asm/8253pit.h \
  /p4/main/platform/os/linux-2.6.23/include/asm/tsc.h \
  /p4/main/platform/os/linux-2.6.23/include/asm-i386/tsc.h \
    $(wildcard include/config/x86/tsc.h) \
    $(wildcard include/config/x86/generic.h) \
  /p4/main/platform/os/linux-2.6.23/include/linux/jiffies.h \
  /p4/main/platform/os/linux-2.6.23/include/linux/calc64.h \
  /p4/main/platform/os/linux-2.6.23/include/asm/div64.h \
  /p4/main/platform/os/linux-2.6.23/include/asm-generic/div64.h \
  /p4/main/platform/os/linux-2.6.23/include/linux/rbtree.h \
  /p4/main/platform/os/linux-2.6.23/include/asm/mmu.h \
  /p4/main/platform/os/linux-2.6.23/include/asm/cputime.h \
  /p4/main/platform/os/linux-2.6.23/include/asm-generic/cputime.h \
  /p4/main/platform/os/linux-2.6.23/include/linux/sem.h \
  /p4/main/platform/os/linux-2.6.23/include/linux/ipc.h \
  /p4/main/platform/os/linux-2.6.23/include/asm/ipcbuf.h \
  /p4/main/platform/os/linux-2.6.23/include/asm/sembuf.h \
  /p4/main/platform/os/linux-2.6.23/include/linux/signal.h \
  /p4/main/platform/os/linux-2.6.23/include/asm/signal.h \
  /p4/main/platform/os/linux-2.6.23/include/asm-generic/signal.h \
  /p4/main/platform/os/linux-2.6.23/include/asm/siginfo.h \
  /p4/main/platform/os/linux-2.6.23/include/asm-generic/siginfo.h \
  /p4/main/platform/os/linux-2.6.23/include/linux/securebits.h \
  /p4/main/platform/os/linux-2.6.23/include/linux/fs_struct.h \
  /p4/main/platform/os/linux-2.6.23/include/linux/completion.h \
  /p4/main/platform/os/linux-2.6.23/include/linux/seccomp.h \
    $(wildcard include/config/seccomp.h) \
  /p4/main/platform/os/linux-2.6.23/include/linux/futex.h \
    $(wildcard include/config/futex.h) \
  /p4/main/platform/os/linux-2.6.23/include/linux/rtmutex.h \
    $(wildcard include/config/debug/rt/mutexes.h) \
  /p4/main/platform/os/linux-2.6.23/include/linux/plist.h \
    $(wildcard include/config/debug/pi/list.h) \
  /p4/main/platform/os/linux-2.6.23/include/linux/param.h \
  /p4/main/platform/os/linux-2.6.23/include/linux/resource.h \
  /p4/main/platform/os/linux-2.6.23/include/asm/resource.h \
  /p4/main/platform/os/linux-2.6.23/include/asm-generic/resource.h \
  /p4/main/platform/os/linux-2.6.23/include/linux/timer.h \
    $(wildcard include/config/timer/stats.h) \
  /p4/main/platform/os/linux-2.6.23/include/linux/ktime.h \
    $(wildcard include/config/ktime/scalar.h) \
  /p4/main/platform/os/linux-2.6.23/include/linux/hrtimer.h \
    $(wildcard include/config/high/res/timers.h) \
  /p4/main/platform/os/linux-2.6.23/include/linux/task_io_accounting.h \
    $(wildcard include/config/task/io/accounting.h) \
  /p4/main/platform/os/linux-2.6.23/include/linux/aio.h \
  /p4/main/platform/os/linux-2.6.23/include/linux/workqueue.h \
  /p4/main/platform/os/linux-2.6.23/include/linux/aio_abi.h \
  /p4/main/platform/os/linux-2.6.23/include/linux/uio.h \
  /p4/main/platform/os/linux-2.6.23/include/linux/kallsyms.h \
    $(wildcard include/config/ia64.h) \
    $(wildcard include/config/ppc64.h) \
  /p4/main/platform/os/linux-2.6.23/include/linux/kthread.h \
  /p4/main/platform/os/linux-2.6.23/include/linux/kernel_stat.h \
  /p4/main/platform/os/linux-2.6.23/include/asm/irq.h \
  /p4/main/platform/os/linux-2.6.23/include/linux/interrupt.h \
    $(wildcard include/config/generic/irq/probe.h) \
  /p4/main/platform/os/linux-2.6.23/include/linux/irqreturn.h \
  /p4/main/platform/os/linux-2.6.23/include/linux/hardirq.h \
    $(wildcard include/config/preempt/bkl.h) \
    $(wildcard include/config/virt/cpu/accounting.h) \
  /p4/main/platform/os/linux-2.6.23/include/linux/smp_lock.h \
    $(wildcard include/config/lock/kernel.h) \
  /p4/main/platform/os/linux-2.6.23/include/asm/hardirq.h \
  /p4/main/platform/os/linux-2.6.23/include/linux/irq.h \
    $(wildcard include/config/s390.h) \
    $(wildcard include/config/irq/per/cpu.h) \
    $(wildcard include/config/irq/release/method.h) \
    $(wildcard include/config/generic/pending/irq.h) \
    $(wildcard include/config/irqbalance.h) \
    $(wildcard include/config/auto/irq/affinity.h) \
    $(wildcard include/config/generic/hardirqs/no//do/irq.h) \
  /p4/main/platform/os/linux-2.6.23/include/asm/irq_regs.h \
  /p4/main/platform/os/linux-2.6.23/include/asm-generic/irq_regs.h \
  /p4/main/platform/os/linux-2.6.23/include/asm/hw_irq.h \
  /p4/main/platform/os/linux-2.6.23/include/linux/profile.h \
  /p4/main/platform/os/linux-2.6.23/include/linux/swap.h \
    $(wildcard include/config/swap.h) \
  /p4/main/platform/os/linux-2.6.23/include/linux/memcontrol.h \
    $(wildcard include/config/cgroup/mem/cont.h) \
  /p4/main/platform/os/linux-2.6.23/include/linux/mm.h \
    $(wildcard include/config/sysctl.h) \
    $(wildcard include/config/stack/growsup.h) \
    $(wildcard include/config/debug/vm.h) \
    $(wildcard include/config/shmem.h) \
    $(wildcard include/config/debug/pagealloc.h) \
  /p4/main/platform/os/linux-2.6.23/include/linux/debug_locks.h \
    $(wildcard include/config/debug/locking/api/selftests.h) \
  /p4/main/platform/os/linux-2.6.23/include/linux/backing-dev.h \
  /p4/main/platform/os/linux-2.6.23/include/linux/mm_types.h \
  /p4/main/platform/os/linux-2.6.23/include/asm/pgtable.h \
  /p4/main/platform/os/linux-2.6.23/include/asm-generic/pgtable.h \
  /p4/main/platform/os/linux-2.6.23/include/linux/page-flags.h \
  /p4/main/platform/os/linux-2.6.23/include/linux/vmstat.h \
    $(wildcard include/config/vm/event/counters.h) \
  /auto/home5/hoj9/testcase/perf_stats/struct_rq.h \

/auto/home5/hoj9/testcase/perf_stats/perf_stats.o: $(deps_/auto/home5/hoj9/testcase/perf_stats/perf_stats.o)

$(deps_/auto/home5/hoj9/testcase/perf_stats/perf_stats.o):
