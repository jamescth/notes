/*
 * This module measure how much time a kernel function takes.
 * The time is measure in jiffies (/1000 to get sec). 
 *
 * The result is print in kern.info
 *
 * required files:
 * build.sh
 * Makefile
 * ddump_module.c
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

#include <linux/fs.h>		// struct inode, file, block_device
#include <linux/dcache.h>	// struct dentry

#include <linux/ctype.h>	// isdigit()
#include <linux/list.h>		// list_for_each()
#include <linux/kobject.h>	// struct kset
#include <linux/genhd.h>	// struct gendisk
#include <linux/bio.h>		// struct bio

#define READ	0
#define WRITE	1

// use 'grep block_subsys /proc/kallsyms to get the value
static long block_subsys_addr;
module_param(block_subsys_addr, long, 0000);

// use 'grep generic_make_request /proc/kallsyms to get the value
static long generic_make_request_addr;
module_param(generic_make_request_addr, long, 0000);

static long do_sync_read_addr;
module_param(do_sync_read_addr, long, 0000);

static long do_sync_write_addr;
module_param(do_sync_write_addr, long, 0000);

static struct gendisk	*hu_sda, *hu_sdb, *hu_sdc, *hu_sdd;

// the part sec is set to the start of the next part.
// so, when use, always compare w/ '<'
// for example, to verify if the range is in MBR:
// 	if (sec < hu_mbr)
static sector_t		hu_mbr = 0, hu_part1 = 0, hu_part2 = 0, hu_part3 = 0;

// Are we probing generic_make_request()
static bool 		is_generic_make_request = false;
static bool		is_do_sync_read = false;
static bool		is_do_sync_write = false;

static bool		is_kret_do_sync_read = false;
static bool		is_kret_do_sync_write = false;

// kprobe for generic_make_request()
static struct kprobe	kp_generic_make_request;
static struct kprobe	kp_do_sync_read;
static struct kprobe	kp_do_sync_write;

static struct kretprobe	kret_do_sync_read;
static struct kretprobe	kret_do_sync_write;

static int
check_hu(struct file *filp, int rw)
{
	char			ch_rw;
	struct inode		*inode;
	struct block_device	*bdev;
	struct gendisk		*gp;

	struct dentry 		*dentry = filp->f_path.dentry;
	struct address_space	*mapping = filp->f_mapping;

	if (dentry == NULL) {
		return -1;
	}

	mapping = filp->f_mapping;
	if (mapping == NULL) {
		return -2;
	}

	inode = mapping->host;
	if (inode == NULL) {
		return -3;
	}

	bdev = inode->i_bdev;
	if (bdev == NULL) {
		return -4;
	}

	gp = bdev->bd_disk;
	if (gp == NULL) {
		return -5;
	}

	ch_rw = rw ? 87 : 82;

	if (gp == hu_sda || gp == hu_sdb || gp == hu_sdc) {
		printk("fs_probe %d %s is %c dev %s \n", 
			current->pid, current->comm, ch_rw,
			dentry->d_name.name);
	}

	return 0;
}

static int
do_sync_read_pre_handler(struct kprobe *kp, struct pt_regs *regs)
{
	struct file	*filp = (struct file *) regs->rdi;
	int		ret;

	if (filp == NULL) {
		printk("fs_probe filp is NULL\n");
		return -1;
	}
	// ret = check_hu(filp, READ);
	// if (ret) {
		// printk("fs_probe check_hu ret %d\n", ret);
	//}

	return 0;
}

static int
do_sync_write_pre_handler(struct kprobe *kp, struct pt_regs *regs)
{
	struct file	*filp = (struct file *) regs->rdi;
	int		ret;

	if (filp == NULL) {
		printk("fs_probe filp is NULL\n");
		return -1;
	}
	ret = check_hu(filp, WRITE);
	if (ret) {
		// printk("fs_probe check_hu ret %d\n", ret);
	}

	return 0;
}

static int
kret_do_sync_read_handler(struct kretprobe_instance *ri, struct pt_regs *regs)
{
	long	ret = (long) regs->rax;

	if (current->mm == NULL || current->mm->m_cmdline == NULL) {
		return 0;
	}

	if (strcmp(current->mm->m_cmdline,"/bin/sh ./test_SSD ")) {
		return 0;
	}

	if (ret < 0) {
		printk("fs_probe %d %s R ret %ld\n", 
			current->pid, current->comm, ret);
	}

	return 0;
}

static int
kret_do_sync_write_handler(struct kretprobe_instance *ri, struct pt_regs *regs)
{
	long	ret = (long) regs->rax;

	if (current->mm == NULL || current->mm->m_cmdline == NULL) {
		return 0;
	}

	if (strcmp(current->mm->m_cmdline,"/bin/sh ./test_SSD ")) {
		return 0;
	}

	if (ret < 0) {
		printk("fs_probe %d %s W ret %ld\n", 
			current->pid, current->comm, ret);
	}

	return 0;
}

/*
 * the resaon we don't probe blk_partition_remap() due to its a inline
 * function; compiler doesn't generate the symbol for it.  So, we have
 * to re-calculate the mapping again.
 */
static int
generic_make_request_pre_handler(struct kprobe *kp, struct pt_regs *regs)
{
	struct bio		*probe_bio;
	struct gendisk 		*probe_bio_disk;
	struct block_device	*bdev;
	int			rw;
	sector_t		sec;
	char			ch_rw;
	int			part;
	sector_t		p_sec = 0;

	// get the needed variables
	probe_bio	= (struct bio *) regs->rdi;
	bdev		= probe_bio->bi_bdev;
	rw		= bio_data_dir(probe_bio);

	// if (0 != strcmp(current->comm, "dummy")) {
	//	return 0;
	//}

	sec = probe_bio->bi_sector;
	// calculate the correct sector including partition
	if (bdev != bdev->bd_contains) {
		struct hd_struct *p = bdev->bd_part;
		p_sec = p->start_sect;
		sec += p_sec;
	}

	// return right away if we ain't interest to reduce perf overhead.
	if (sec >= hu_part3) {
		return 0;
	}

	ch_rw = rw ? 87 : 82;

	// if MBR on any device is modified, we want to know.
	if (sec < hu_mbr && rw) {
		printk("fs_probe %d %s is %c mbr bio sect %lu p sec %lu bdev %p\n", 
			current->pid, current->comm, ch_rw,
			probe_bio->bi_sector, p_sec, probe_bio->bi_bdev);
		return 0;
	}

	probe_bio_disk = probe_bio->bi_bdev->bd_disk;

	// if it's not head unit, we don't care
	if (probe_bio_disk != hu_sda &&
	    probe_bio_disk != hu_sdb &&
	    probe_bio_disk != hu_sdc ) {
		return 0;
	}

	if (sec < hu_mbr) {
		part = 0;
	} else if (sec < hu_part1) {
		part = 1;
	} else {
		part = 2;
	}

	printk("fs_probe %d %s is %c part %d bio sect %lu p sec %lu head %p\n",
		current->pid, current->comm, ch_rw, part,
		probe_bio->bi_sector, p_sec, probe_bio_disk);

	return 0;
}

static char *
ddump_disk_name(struct gendisk *hd, int part, char *buf)
{
	if (!part)
		snprintf(buf, BDEVNAME_SIZE, "%s", hd->disk_name);
	else if (isdigit(hd->disk_name[strlen(hd->disk_name)-1]))
		snprintf(buf, BDEVNAME_SIZE, "%sp%d", hd->disk_name, part);
	else
		snprintf(buf, BDEVNAME_SIZE, "%s%d", hd->disk_name, part);

	return buf;
}

static void
set_hu_gendisk(struct gendisk *gp)
{
	if (strcmp("sda", gp->disk_name) == 0) {
		hu_sda = gp;
		printk("hu_sda is %p\n", hu_sda);
	}
	if (strcmp("sdb", gp->disk_name) == 0) {
		hu_sdb = gp;
		printk("hu_sdb is %p\n", hu_sdb);
	}
	if (strcmp("sdc", gp->disk_name) == 0) {
		hu_sdc = gp;
		printk("hu_sdc is %p\n", hu_sdc);
	}
	if (strcmp("sdd", gp->disk_name) == 0) {
		hu_sdd = gp;
		printk("hu_sdd is %p\n", hu_sdd);
	}
}

static void
list_block_devs(struct kset *block_subsys)
{
	struct gendisk	*gp;
	int		n;

	// we may want to hold block_subsys_lock.  However, it's a static lock.

	list_for_each_entry(gp, &block_subsys->list, kobj.entry) {
		char buf[BDEVNAME_SIZE];

		// If the driver is NULL, it's not a disk. ignore.
		if (gp->driverfs_dev == NULL || 
                    gp->driverfs_dev->driver == NULL) {
			continue;
		}

		// set up HU global variables
		set_hu_gendisk(gp);

		printk("%02x%02x %10llu %s\n",
			gp->major, gp->first_minor,
			(unsigned long long)get_capacity(gp) >> 1,
			ddump_disk_name(gp, 0, buf));

		if (gp->driverfs_dev != NULL &&
		    gp->driverfs_dev->driver != NULL) {
			printk(" driver: %s\n",
				gp->driverfs_dev->driver->name);
		}
		else {
			printk(" (driver?)\n");

			// if there is no driver, we skip.
			// this include dm & dd_dg
			continue;
		} // gp

		/* now show the partitions */
		for (n = 0; n < gp->minors - 1; ++n) {
			if (gp->part[n] == NULL)
				continue;
			if (gp->part[n]->nr_sects == 0)
				continue;

			if (n == 0) {
				if (hu_mbr != 0 &&
				    (hu_mbr != (gp->part[n]->start_sect))) {
					printk("james mbr has issues\n");
				} else {
					hu_mbr = gp->part[n]->start_sect;
				}
			} else if (n == 1) {
				if (hu_part1 != 0 &&
				    (hu_part1 != (gp->part[n]->start_sect))) {
					printk("james hu_part1 has issues\n");
				} else {
					hu_part1 = gp->part[n]->start_sect;

				}
			} else if (n == 2) {
				if (hu_part2 != 0 &&
				    (hu_part2 != (gp->part[n]->start_sect))) {
					printk("james hu_part1 has issues\n");
				} else {
					hu_part2 = gp->part[n]->start_sect;

					hu_part3 = gp->part[n]->start_sect +
						   gp->part[n]->nr_sects;
				}
			}

			printk("  %02x%02x %10llu %10llu %s\n",
				gp->major, n + 1 + gp->first_minor,
				(unsigned long long)gp->part[n]->start_sect,
				// nr_sects should >> 1, 
				// devide by 2 boz the size is 512
				// but, we want to know the real #
				(unsigned long long)gp->part[n]->nr_sects,
				disk_name(gp, n + 1, buf));
		} // for partition

	} // list_for_each_entry
}

// The probed addr is given by the user script
// The user script scan /proc/kallsyms
int init_module(void)
{
	int		ret;
	struct kset	*ddump_block_subsys;

	if (NULL == (long *) block_subsys_addr) {
		printk("must provide an block_subsys addr\n");
		printk("use 'grep block_subsys /proc/kallsyms' to get addr\n");
		printk("insmod <mod> block_subsys_addr=0x<addr>\n");
		return -1;
	} else {
		printk("block_subsys is %lx\n", block_subsys_addr);
	}

	ddump_block_subsys = (struct kset *)block_subsys_addr;
	list_block_devs(ddump_block_subsys);

	if (NULL == (long *) generic_make_request_addr) {
		// use 'generic_make_request_addr=0x<addr>' if probing is need
		printk("No funcp provide for generic_make_request()\n");
	} else {
		printk("generic_make_request is %lx\n", 
			generic_make_request_addr);

		kp_generic_make_request.pre_handler = 
			generic_make_request_pre_handler;
		kp_generic_make_request.addr =
			(kprobe_opcode_t *) generic_make_request_addr;

		if ((ret = register_kprobe(&kp_generic_make_request)) < 0) {
			printk("register_kprobe failed, ret %d\n", ret);
			return ret;
		}

		is_generic_make_request = true;
		printk("probing generic_make_request\n");
	}

	if (NULL == (long *) do_sync_read_addr) {
		// use 'do_sync_read_addr=0x<addr>' if probing is need
		printk("No funcp provide for do_sync_read()\n");
	} else {
		printk("do_sync_read is %lx\n", 
			do_sync_read_addr);

		// kprobe
		kp_do_sync_read.pre_handler = 
			do_sync_read_pre_handler;
		kp_do_sync_read.addr =
			(kprobe_opcode_t *)do_sync_read_addr;

		if ((ret = register_kprobe(&kp_do_sync_read)) < 0) {
			printk("register_kprobe failed, ret %d\n", ret);
			return ret;
		}

		is_do_sync_read = true;
		printk("probing do_sync_read\n");

		// kretprobe
		kret_do_sync_read.handler = 
			kret_do_sync_read_handler;
		kret_do_sync_read.kp.addr =
			(kprobe_opcode_t *)do_sync_read_addr;

		if ((ret = register_kretprobe(&kret_do_sync_read)) < 0) {
			printk("register_kretprobe failed, ret %d\n", ret);
			return ret;
		}

		is_kret_do_sync_read = true;
		printk("kretprobing do_sync_read\n");

	}

	if (NULL == (long *) do_sync_write_addr) {
		// use 'do_sync_write_addr=0x<addr>' if probing is need
		printk("No funcp provide for do_sync_write()\n");
	} else {
		printk("do_sync_write is %lx\n", 
			do_sync_write_addr);

		// kprobe
		kp_do_sync_write.pre_handler = 
			do_sync_write_pre_handler;
		kp_do_sync_write.addr =
			(kprobe_opcode_t *)do_sync_write_addr;

		if ((ret = register_kprobe(&kp_do_sync_write)) < 0) {
			printk("register_kprobe failed, ret %d\n", ret);
			return ret;
		}

		is_do_sync_write = true;
		printk("probing do_sync_write\n");


		// kretprobe
		kret_do_sync_write.handler = 
			kret_do_sync_write_handler;
		kret_do_sync_write.kp.addr =
			(kprobe_opcode_t *)do_sync_write_addr;

		if ((ret = register_kretprobe(&kret_do_sync_write)) < 0) {
			printk("register_kretprobe failed, ret %d\n", ret);
			return ret;
		}

		is_kret_do_sync_write = true;
		printk("kretprobing do_sync_write\n");
	}

	return 0;
}

void cleanup_module(void)
{
	if (is_generic_make_request) {
		unregister_kprobe(&kp_generic_make_request);
	}

	if (is_do_sync_read) {
		unregister_kprobe(&kp_do_sync_read);
	}

	if (is_do_sync_write) {
		unregister_kprobe(&kp_do_sync_write);
	}

	if (is_kret_do_sync_read) {
		unregister_kretprobe(&kret_do_sync_read);
	}

	if (is_kret_do_sync_write) {
		unregister_kretprobe(&kret_do_sync_write);
	}

	printk("kprobe unregistered\n");
}

MODULE_LICENSE("GPL");
