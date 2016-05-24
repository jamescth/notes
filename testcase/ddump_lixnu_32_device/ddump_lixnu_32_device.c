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
#include <linux/kallsyms.h>

#include <linux/fs.h>		// struct inode, file, block_device
#include <linux/dcache.h>	// struct dentry

#include <linux/device.h>	// class_dev_iter_init()
#include <linux/klist.h>	// 

#include <linux/ctype.h>	// isdigit()
#include <linux/kobject.h>	// struct kset
#include <linux/genhd.h>	// struct gendisk
#include <linux/bio.h>		// struct bio

#include <asm/e820.h>		// e820

unsigned long next_ram_page(unsigned long pfn);

static struct class 		*my_block_class;
static struct device_type	*my_disk_type;

static struct kprobe		kp1;
static int counter = 0;

struct e820map 		*my_e820;
struct mm_struct 	*my_init_mm;
unsigned long		*my_max_pfn;

pgd_t *pgd;
pud_t *pud;
pmd_t *pmd;
pte_t *pte;
unsigned long above;
unsigned long            nr;

struct device *my_class_dev_iter_next(struct class_dev_iter *iter)
{
	struct klist_node *knode;
	struct device *dev;

	while (1) {
		knode = klist_next(&iter->ki);

		// printk("\nknode %p ", knode);

		if (!knode) {
		//	printk("\n");
			return NULL;
		}

		dev = container_of(knode, struct device, knode_class);
		if (!iter->type || iter->type == dev->type) {
		//	printk("\nf dev %p\n", dev);
			return dev;
		}
	}
	printk("nodev found\n");
}

static char *bdevt_str(dev_t devt, char *buf)
{
	if (MAJOR(devt) <= 0xff && MINOR(devt) <= 0xff) {
		char tbuf[BDEVT_SIZE];
		snprintf(tbuf, BDEVT_SIZE, "%02x%02x", MAJOR(devt), MINOR(devt));
		snprintf(buf, BDEVT_SIZE, "%-9s", tbuf);
	} else
		snprintf(buf, BDEVT_SIZE, "%03x:%05x", MAJOR(devt), MINOR(devt));

	return buf;
}

void show_gend(void)
{
	struct class_dev_iter iter;
	struct device *dev;

	class_dev_iter_init(&iter, my_block_class, NULL, my_disk_type);

	// struct class_dev_iter {
	//   [0] struct klist_iter ki;
	//  [16] const struct device_type *type;
	//}

	//printk("iter %p iter.ki %p i_klist %p i_cur %p\n",
	//	&iter, iter.ki, iter.ki.i_klist, iter.ki.i_cur);

	while ((dev = my_class_dev_iter_next(&iter))) {
		struct gendisk *disk = dev_to_disk(dev);
		struct disk_part_iter piter;
		struct hd_struct *part;
		char name_buf[BDEVNAME_SIZE];
		char devt_buf[BDEVT_SIZE];
		char uuid_buf[PARTITION_META_INFO_UUIDLTH * 2 + 5];

		// printk("gen %p name %s\n", disk, disk->disk_name);

		/*
		 * Don't show empty devices or things that have been
		 * suppressed
		 */
		if (get_capacity(disk) == 0 ||
		    (disk->flags & GENHD_FL_SUPPRESS_PARTITION_INFO))
			continue;

		// James: we only want to verify 'sda'
		if (strcmp(disk->disk_name, "sda") != 0)
			continue;

		/*
		 * Note, unlike /proc/partitions, I am showing the
		 * numbers in hex - the same format as the root=
		 * option takes.
		 */
		disk_part_iter_init(&piter, disk, DISK_PITER_INCL_PART0);

		printk("gen %p name %s\n disk_part_tbl %p ",
			disk, disk->disk_name, disk->part_tbl);

		while ((part = disk_part_iter_next(&piter))) {
			bool is_part0 = part == &disk->part0;

			printk("part %p\n", part);

			uuid_buf[0] = '\0';
			if (part->info)
				snprintf(uuid_buf, sizeof(uuid_buf), "%pU",
					 part->info->uuid);

			printk("%s%s %10llu %s %s", is_part0 ? "" : "  ",
			       bdevt_str(part_devt(part), devt_buf),
			       (unsigned long long)part->nr_sects >> 1,
			       disk_name(disk, part->partno, name_buf),
			       uuid_buf);
			if (is_part0) {
				if (disk->driverfs_dev != NULL &&
				    disk->driverfs_dev->driver != NULL)
					printk(" driver: %s\n",
					      disk->driverfs_dev->driver->name);
				else
					printk(" (driver?)\n");
			} else
				printk("\n");
		}
		disk_part_iter_exit(&piter);
	}
	class_dev_iter_exit(&iter);
}

void test_bdget(dev_t dev)
{
	struct block_device *bdev;

	bdev = bdget(dev);

	printk("test_bdget %d bdev %p\n", dev, bdev);
}

unsigned long my_next_ram_page(unsigned long pfn)
{
    int i;
    unsigned long min_pageno = ULONG_MAX;

    pfn++;

    for (i = 0; i < my_e820->nr_map; i++) {
    // for (i = 0; i < e820_saved.nr_map; i++) {
        unsigned long addr, end;

        if (my_e820->map[i].type != E820_RAM)	/* not usable memory */
            continue;

        addr = (my_e820->map[i].addr+PAGE_SIZE-1) >> PAGE_SHIFT;
        end = (my_e820->map[i].addr+my_e820->map[i].size) >> PAGE_SHIFT;
        // addr = (e820_saved.map[i].addr+PAGE_SIZE-1) >> PAGE_SHIFT;
        // end = (e820_saved.map[i].addr+e820.map[i].size) >> PAGE_SHIFT;
        if  ((pfn >= addr) && (pfn < end))
            return pfn;
        if ((pfn < addr) && (addr < min_pageno))
            min_pageno = addr;
    }
    return min_pageno;
}

#define my_pgd_offset_k(address) pgd_offset(my_init_mm, (address))
#define DIRECT_MAP_MIN	0xffff880000000000
#define DIRECT_MAP_MAX	0xffffc90000000000

unsigned long my_pte_index(unsigned long address)
{
	return (address >> PAGE_SHIFT) & (PTRS_PER_PTE - 1);
}

pte_t *my_pte_offset_kernel(pmd_t *pmd, unsigned long address)
{
	return (pte_t *)pmd_page_vaddr(*pmd) + my_pte_index(address);
}

static inline
int is_direct_map_addr(unsigned long addr) {
	if ((addr > (unsigned long)DIRECT_MAP_MIN) && (addr < (unsigned long)DIRECT_MAP_MAX)) {
		return 1;
	}
	return 0;
}

int my_kern_addr_valid(unsigned long addr)
{
	above = ((long)addr) >> __VIRTUAL_MASK_SHIFT;


	if (above != 0 && above != -1UL) {
		printk(KERN_EMERG "above 0x%lx addr 0x%lx\n", above, addr);
		return 0;
	}

	pgd = my_pgd_offset_k(addr);
	if (is_direct_map_addr(pgd) || pgd_none(*pgd)) {
		return 0;
	}

	pud = pud_offset(pgd, addr);
	if (is_direct_map_addr(pud) || pud_none(*pud)) {
		return 0;
	}

	pmd = pmd_offset(pud, addr);
	if (is_direct_map_addr(pmd) || pmd_none(*pmd)) {
		return 0;
	}

	if (pmd_large(*pmd))
		return pfn_valid(pmd_pfn(*pmd));

	pte = my_pte_offset_kernel(pmd, addr);

	if (is_direct_map_addr(pte) || pte_none(*pte))
		return 0;

	return pfn_valid(pte_pfn(*pte));
}

static test_next_ram_page()
{
	struct page             *page;
	int			i = 0;
	unsigned long		tmp_addr;

	printk("test_next_ram_page\n");
	my_e820 = (void *)kallsyms_lookup_name("e820");
	printk("my_e820 is %p\n", my_e820);
	my_init_mm = (void *)kallsyms_lookup_name("init_mm");
	printk("my_init_mm is %p\n", my_init_mm);
	my_max_pfn = (void *)kallsyms_lookup_name("max_pfn");
	printk("my_max_pfn is %p %ld\n", my_max_pfn, *my_max_pfn);

	for (nr = my_next_ram_page(ULONG_MAX); nr < ULONG_MAX; 
                nr = my_next_ram_page(nr)) 
        {
		if (!pfn_valid(nr))
			continue;

		if (nr > my_max_pfn)
			continue;

		page = pfn_to_page(nr);

		if (nr != page_to_pfn(page)) {
			printk("Bad page. PFN %lu flags %lx\n",
				nr, (unsigned long)page->flags);
		}

		i++;

		tmp_addr = (unsigned long)pfn_to_kaddr(nr);

		if (nr > *my_max_pfn) {
			printk(KERN_EMERG "over the limit\n");
		}  

		if (nr == 17036964) {
			printk(KERN_EMERG "nr %ld\n", nr);
			// i = 0;
			//printk("nr %ld\n", nr);
		}

		if (!my_kern_addr_valid((unsigned long)pfn_to_kaddr(nr))) {
			printk("Unmapped page PFN %lu\n", nr);
			//break;
		}
	}
}

static int
kp1_pre_handler(struct kprobe *kp, struct pt_regs *regs)
{
	if (counter == 400) {
		printk("kp1\n");
		counter = 0;
	}
	counter++;
	return 0;
}

// The probed addr is given by the user script
// The user script scan /proc/kallsyms
int init_module(void)
{
#if 0
	my_block_class = (void *)kallsyms_lookup_name("block_class");
	printk("my_block_class %p\n", my_block_class);

	my_disk_type = (void *)kallsyms_lookup_name("disk_type");
	printk("my_disk_type %p\n", my_disk_type);


	kp1.pre_handler = kp1_pre_handler;
	kp1.addr = (void *)kallsyms_lookup_name("mptsas_qcmd");

	if (kp1.addr == NULL) {
		printk("kallsyms_lookup_name failed\n");
		return -1;
	}

	if (register_kprobe(&kp1) < 0) {
		printk("kprobe register failed\n");
		return -1;
	}
#endif
//	show_gend();
//	test_bdget(8388610);
	test_next_ram_page();
	return 0;
}

void cleanup_module(void)
{
//	unregister_kprobe(&kp1);
	printk("kprobe unregistered\n");
}

MODULE_LICENSE("GPL");
